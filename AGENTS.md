# AGENTS.md

## Purpose
- This repository is a personal Neovim config built on LazyVim.
- Instructions here guide agentic changes to Lua configs and plugin specs.
- No Cursor or Copilot rules found in repo.

## Quick Repo Map
- `init.lua` bootstraps LazyVim.
- `lua/config/` holds core config (options, keymaps, autocmds, lazy).
- `lua/plugins/` holds plugin specs and overrides.
- `stylua.toml` defines Lua formatting (2 spaces, 120 columns).

## Build / Setup Commands
- There is no build step; this is a Neovim configuration.
- Install/update plugins: `nvim --headless "+Lazy! sync" +qa`
- Check health: `nvim --headless "+checkhealth" +qa`
- Regenerate lockfile (if needed): `nvim --headless "+Lazy! sync" +qa`

## Lint / Format Commands
- Format all Lua: `stylua .`
- Check formatting only: `stylua --check .`
- Format a single file: `stylua lua/plugins/<file>.lua`
- `stylua.toml` enforces 2-space indentation and 120 cols.

## Test Commands
- No automated tests are present in this repo.
- There is no single-test command today.
- If tests are introduced, prefer `plenary.nvim` + `PlenaryBustedFile`.
- Example (if tests exist): `nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/foo_spec.lua" +qa`

## General Style Principles
- Keep changes minimal and consistent with existing config style.
- Prefer small, focused plugin specs over large monolith files.
- Avoid adding documentation files unless explicitly requested.
- Do not introduce new dependencies unless necessary.

## Lua Formatting
- Use 2 spaces for indentation (per `stylua.toml`).
- Keep lines within 120 characters when possible.
- Use `-- stylua: ignore start/end` for aligned one-liners.
- Prefer trailing commas in multi-line tables for clean diffs.

## Imports and Module Structure
- Use `local <name> = require("<module>")` at top of a function or file.
- Avoid side-effect `require` calls outside config modules.
- Export tables from plugin spec files via `return { ... }`.
- One module per file; keep `return` at the bottom.

## Import Ordering
- Group standard Lua modules first, then plugin modules, then local modules.
- Keep one blank line between import groups when there are 3+ requires.
- Avoid duplicate `require` calls inside the same scope.
- Prefer storing `require` results in locals for reuse.

## Naming Conventions
- Use descriptive `local` names (`neocodeium`, `cmp`, `opts`).
- Prefer lower_snake_case for variables and functions you own.
- Keep plugin identifiers as `"owner/repo"` strings.
- Use `opts`/`config` keys with clear intent.

## Plugin Spec Patterns
- Default pattern: `{ "owner/repo", opts = { ... } }`.
- Use `config = function()` when setup needs logic.
- Use `event`, `keys`, `cmd`, `ft`, or `lazy` for lazy-loading.
- Keep `keys` entries as tables: `{ "<lhs>", <fn>, desc = "..." }`.
- Prefer `opts = function(_, opts)` for extending existing options.

## Keymaps
- Prefer `vim.keymap.set` with `desc` for discoverability.
- Avoid `vim.api.nvim_set_keymap` unless required.
- Group related mappings together and keep them close to config.
- Keep keymap functions small; move logic to helpers if complex.

## Options and Globals
- Use `vim.opt` for options and `vim.g` for globals.
- Do not introduce new globals unless required by a plugin.
- Keep defaults in `lua/config/options.lua`.

## Error Handling
- Check `vim.v.shell_error` after shell calls (see `lua/config/lazy.lua`).
- Use `vim.api.nvim_echo` for user-facing errors.
- Prefer early returns when a prerequisite is missing.
- Do not swallow errors silently; add a short message when skipping.

## Types and Lua Idioms
- Use `local` for all variables.
- Prefer `local function name()` for helpers.
- Use tables for structured data; avoid nested anonymous functions when possible.
- Keep functions pure unless they must call Neovim APIs.

## Tables and Lists
- Use multi-line table formatting for 3+ entries.
- Align table keys only when it improves clarity; otherwise keep simple.
- Put `desc` keys last in keymap tables.
- Avoid duplicate plugin entries across files.

## Logging and Notifications
- Prefer `vim.notify` for informational messages.
- Use `vim.api.nvim_echo` for errors needing highlight groups.
- Keep messages short and actionable.
- Avoid noisy notifications during startup.

## Comments
- Keep comments short and actionable.
- Prefer comments explaining *why* rather than restating the code.
- Remove commented-out code unless it documents an intentional toggle.

## File-Specific Notes
- `init.lua` should remain minimal; bootstrap only.
- `lua/config/lazy.lua` controls LazyVim bootstrap and core setup.
- `lua/plugins/` files define user overrides and additions.
- Keep plugin files focused by topic (ui, completion, formatter, etc.).

## Dependency Management
- Use `lazy.nvim` defaults for plugin versions (version = false).
- Avoid pinning versions unless required for stability.
- Update `lazy-lock.json` only when plugin set changes.

## Suggested Workflow for Changes
- Edit Lua files directly; avoid generating new config layers.
- Run `stylua --check .` before committing.
- Run `nvim --headless "+Lazy! sync" +qa` if plugins changed.
- Validate by launching `nvim` manually for UI behavior.

## When Adding New Plugins
- Pick the right loading trigger (event/keys/ft).
- Add configuration in `opts` or `config` using `require`d module.
- Keep plugin-specific settings scoped to that plugin.
- Provide `desc` on keymaps and commands for clarity.

## When Editing Existing Plugins
- Preserve the existing structure and key order.
- Avoid rewriting table structures unless necessary.
- Reuse existing `opts` tables instead of replacing them.
- Prefer incremental changes to minimize diffs.

## Neovim API Usage
- Prefer `vim.api.nvim_*` for explicit APIs.
- Use `vim.cmd` for simple Ex commands.
- Use `vim.fn` for Vimscript functions; check return values.

## Miscellaneous
- Keep `lazyvim.json` and `.neoconf.json` as-is unless requested.
- Do not edit `.git` contents.
- Keep configuration compatible with current LazyVim defaults.

## References
- LazyVim docs: https://lazyvim.github.io/installation
- Lazy.nvim: https://github.com/folke/lazy.nvim
- Stylua: https://github.com/JohnnyMorganz/StyLua
