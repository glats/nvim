-- Skip Mason installation for tools that are either:
--   a) already available in PATH (installed via system package manager), or
--   b) explicitly unsupported on musl libc (no binary available anywhere).
--
-- This config works on both:
--   - Alpine (musl, aarch64): uses tools from apk, skips glibc-only binaries
--   - Arch (glibc, x86_64): uses tools from pacman if available, Mason otherwise

-- Detect musl once at load time.
local is_musl = (function()
  local f = io.open("/usr/bin/ldd", "r") or io.open("/bin/ldd", "r")
  if not f then
    return false
  end
  local content = f:read("*a")
  f:close()
  return content:find("musl") ~= nil
end)()

-- Mason package name -> binary name (only needed when they differ).
local bin_for = {
  ["lua-language-server"] = "lua-language-server",
  ["clangd"] = "clangd",
  ["gopls"] = "gopls",
  ["delve"] = "dlv",
  ["goimports"] = "goimports",
  ["gofumpt"] = "gofumpt",
  ["zls"] = "zls",
  ["vtsls"] = "vtsls",
  ["stylua"] = "stylua",
  ["shfmt"] = "shfmt",
  ["yaml-language-server"] = "yaml-language-server",
  ["dockerfile-language-server"] = "docker-langserver",
  ["docker-compose-language-service"] = "docker-compose-langserver",
  ["marksman"] = "marksman",
}

-- Packages unavailable on musl: Mason ships glibc binaries, no apk equivalent.
local musl_unsupported = {
  ["codelldb"] = true,
  ["tree-sitter-cli"] = true, -- glibc binary; install tree-sitter-cli via apk
}

local function skip(pkg)
  if is_musl and musl_unsupported[pkg] then
    return true
  end
  local bin = bin_for[pkg] or pkg
  return vim.fn.executable(bin) == 1
end

-- LSP servers to disable Mason for when binary is in PATH
-- Map: lspconfig name -> binary name
local lsp_in_path = {
  lua_ls = "lua-language-server",
  clangd = "clangd",
  gopls = "gopls",
}

-- Build servers opts dynamically: only set mason=false if binary exists
local servers_opts = {}
for lsp, bin in pairs(lsp_in_path) do
  if vim.fn.executable(bin) == 1 then
    servers_opts[lsp] = { mason = false }
  end
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Filter ensure_installed to skip tools already in PATH or unsupported on musl
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not skip(pkg)
      end, opts.ensure_installed or {})
      return opts
    end,
  },
  {
    "nvim-lspconfig",
    optional = true,
    opts = {
      -- Disable Mason for LSPs already available in PATH
      -- On Alpine: installed via apk
      -- On Arch: may or may not be installed - respects system config
      servers = servers_opts,
    },
  },
}
