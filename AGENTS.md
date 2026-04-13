# AGENTS.md

Personal Neovim config built on LazyVim. No build step, no tests.

## Repo Structure

- `init.lua` -- bootstrap only, keep minimal
- `lua/config/` -- options, keymaps, autocmds, lazy
- `lua/plugins/` -- one spec file per topic (ui, completion, etc.)
- `stylua.toml` -- 2 spaces, 120 cols

## Commands

- Format: `stylua .` | Check: `stylua --check .`
- Sync plugins: `nvim --headless "+Lazy! sync" +qa`

## Style Rules

- Follow existing code style; match surrounding context.
- Run `stylua --check .` before committing.
- Plugin specs: `{ "owner/repo", opts = { ... } }`. Use `event`/`keys`/`cmd`/`ft` for lazy-loading.
- Extend options with `opts = function(_, opts)` instead of replacing.
- Keymaps: `vim.keymap.set` with `desc`. Keep functions small.
- Prefer incremental edits over rewrites. Minimize diffs.
- Don't add files/dependencies unless necessary.

## musl / Alpine Compatibility

This config also runs on Alpine/postmarketOS (musl + aarch64) where Mason can't
install precompiled binaries. `lua/plugins/mason.lua` skips tools already in PATH.

### Adding a Mason tool on Alpine

1. Add tool to `ensure_installed` or enable the LazyVim extra.
2. If Mason fails ("unsupported platform"), install via `doas apk add <pkg>`.
3. The `mason.lua` filter auto-skips PATH-available tools. No Lua changes needed
   unless Mason package name differs from binary -- then add to `bin_for` table.
4. If there is no apk package either, add the Mason package name to `musl_unsupported`
   in `mason.lua` so it is silently skipped on musl only.
5. If the tool needs a compiler/runtime (e.g. Go), install that via apk too.

### Current Alpine apk packages

`go`, `stylua`, `lua-language-server`, `clang22-extra-tools` (clangd),
`tree-sitter-cli` (Mason ships a glibc binary that won't run on musl).
`codelldb` unavailable on this platform; use `gdb` instead.

### Treesitter parsers on Alpine

nvim-treesitter uses `tree-sitter build` to compile parsers from source.
Mason's `tree-sitter-cli` is a glibc binary (fails on musl); it is listed in
`musl_unsupported`. The apk `tree-sitter-cli` package is used instead.

If parsers are missing (nvim downloads on every start), compile them manually:

```sh
PARSER_DIR=~/.local/share/nvim/site/parser
WORK=/tmp/ts-build
mkdir -p "$WORK"
for tarball in ~/.cache/nvim/tree-sitter-*.tar.gz; do
  lang=$(basename "$tarball" .tar.gz | sed 's/tree-sitter-//')
  [ -f "$PARSER_DIR/$lang.so" ] && continue
  mkdir -p "$WORK/src" && tar xzf "$tarball" -C "$WORK/src" --strip-components=1
  (cd "$WORK/src" && tree-sitter build -o "$PARSER_DIR/$lang.so" 2>/dev/null)
done
```

Multi-directory parsers (markdown, typescript, tsx, xml, dtd) need `cd` into
their subdirectory before building. See session history for the full script.
