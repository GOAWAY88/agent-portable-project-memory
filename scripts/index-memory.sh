#!/usr/bin/env bash
# Build or query an optional derived SQLite FTS5/BM25 index for canonical Markdown.
# The database is disposable; Markdown remains the only project-memory authority.
set -u

CHECK_ONLY=0
QUERY=
QUERY_SET=0
LIMIT=10
ROOT=

while (( $# )); do
  case "$1" in
    --check) CHECK_ONLY=1; shift;;
    --query)
      [[ $# -ge 2 ]] || { echo "index-memory: --query needs a value" >&2; exit 2; }
      QUERY=$2; QUERY_SET=1; shift 2;;
    --limit)
      [[ $# -ge 2 && "$2" =~ ^[1-9][0-9]*$ ]] || { echo "index-memory: --limit needs a positive integer" >&2; exit 2; }
      LIMIT=$2; shift 2;;
    -h|--help)
      echo "usage: $0 [--check] [--query <term>] [--limit <n>] <project>"
      echo "  rebuilds .ai/index/memory.sqlite3, or searches an existing derived index"
      echo "  --check verifies optional Python/SQLite FTS5 support without writing"
      exit 0;;
    *)
      if [[ -n "$ROOT" ]]; then echo "index-memory: unexpected extra argument: $1" >&2; exit 2; fi
      ROOT=$1; shift;;
  esac
done

ROOT=${ROOT:-.}
ROOT=$(cd "$ROOT" 2>/dev/null && pwd) || { echo "index-memory: target does not exist" >&2; exit 2; }
if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "index-memory: target is not a Git repository: $ROOT" >&2
  exit 2
fi
[[ -d "$ROOT/.ai" ]] || { echo "index-memory: target has no .ai directory" >&2; exit 1; }

PYTHON_BIN=${PYTHON:-python3}
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "index-memory: optional retrieval requires python3" >&2
  exit 1
fi

MODE=rebuild
(( QUERY_SET )) && MODE=query
(( CHECK_ONLY )) && MODE=check

exec "$PYTHON_BIN" - "$ROOT" "$MODE" "$QUERY" "$LIMIT" <<'PY'
import hashlib
import os
import sqlite3
import subprocess
import sys
import tempfile

root, mode, query, limit_text = sys.argv[1:]
index_dir = os.path.join(root, ".ai", "index")
db_path = os.path.join(index_dir, "memory.sqlite3")

def fts5_available(connection):
    return bool(connection.execute(
        "SELECT sqlite_compileoption_used('ENABLE_FTS5')"
    ).fetchone()[0])

def require_fts5(connection):
    if not fts5_available(connection):
        raise RuntimeError(
            "Python sqlite3 was built without FTS5; canonical Markdown remains usable"
        )

def git_commit():
    try:
        return subprocess.check_output(
            ["git", "-C", root, "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"

def markdown_files():
    ai_root = os.path.join(root, ".ai")
    paths = []
    for directory, directories, filenames in os.walk(ai_root):
        directories[:] = sorted(
            name for name in directories if os.path.abspath(os.path.join(directory, name)) != os.path.abspath(index_dir)
        )
        for filename in sorted(filenames):
            if not filename.endswith(".md"):
                continue
            absolute = os.path.join(directory, filename)
            relative = os.path.relpath(absolute, root).replace(os.sep, "/")
            paths.append((relative, absolute))
    return sorted(paths)

def load_documents():
    documents = []
    for relative, absolute in markdown_files():
        with open(absolute, "r", encoding="utf-8", errors="replace") as source:
            content = source.read()
        documents.append((relative, content, hashlib.sha256(content.encode("utf-8")).hexdigest()))
    return documents

if mode == "check":
    connection = sqlite3.connect(":memory:")
    try:
        require_fts5(connection)
    finally:
        connection.close()
    print("index-memory: FTS5 available; no files written")
    raise SystemExit(0)

if mode == "query":
    if not os.path.isfile(db_path):
        print("index-memory: missing derived index; run without --query first", file=sys.stderr)
        raise SystemExit(1)
    try:
        limit = int(limit_text)
        if limit < 1:
            raise ValueError
        connection = sqlite3.connect(
            "file:{}?mode=ro".format(db_path), uri=True
        )
        require_fts5(connection)
        connection.execute("SELECT value FROM metadata WHERE key = 'schema_version'").fetchone()
        rows = connection.execute(
            "SELECT path, bm25(documents), snippet(documents, 1, '[', ']', '…', 20) "
            "FROM documents WHERE documents MATCH ? ORDER BY bm25(documents), path LIMIT ?",
            (query, limit),
        ).fetchall()
        for path, score, snippet in rows:
            safe_snippet = " ".join(str(snippet).split())
            print("{}\t{:.6f}\t{}".format(path, score, safe_snippet))
    except (sqlite3.Error, ValueError) as error:
        print("index-memory: query failed: {}".format(error), file=sys.stderr)
        raise SystemExit(1)
    finally:
        try:
            connection.close()
        except UnboundLocalError:
            pass
    raise SystemExit(0)

os.makedirs(index_dir, exist_ok=True)
documents = load_documents()
temporary = tempfile.NamedTemporaryFile(
    prefix=".memory-", suffix=".sqlite3.tmp", dir=index_dir, delete=False
)
temporary.close()
connection = None
try:
    connection = sqlite3.connect(temporary.name)
    require_fts5(connection)
    connection.execute("CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
    connection.execute("CREATE VIRTUAL TABLE documents USING fts5(path UNINDEXED, content)")
    connection.executemany(
        "INSERT INTO documents(path, content) VALUES (?, ?)",
        [(path, content) for path, content, _ in documents],
    )
    metadata = {
        "schema_version": "1",
        "generated_at_commit": git_commit(),
        "document_count": str(len(documents)),
        "source": ".ai/**/*.md",
    }
    connection.executemany("INSERT INTO metadata(key, value) VALUES (?, ?)", sorted(metadata.items()))
    connection.commit()
    connection.close()
    connection = None
    os.replace(temporary.name, db_path)
    print("index-memory: rebuilt {} documents -> .ai/index/memory.sqlite3".format(len(documents)))
except Exception as error:
    if connection is not None:
        connection.rollback()
        connection.close()
    try:
        os.unlink(temporary.name)
    except OSError:
        pass
    print("index-memory: rebuild failed: {}".format(error), file=sys.stderr)
    raise SystemExit(1)
PY
