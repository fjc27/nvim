return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    -- add lspconfig as a dep so it's available when Mason enables servers
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      -- Using "ts_ls" as requested
      ensure_installed = { "lua_ls", "pyright", "clangd", "html", "cssls", "ts_ls" },
      automatic_enable = true, -- be explicit
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- 1) on_attach: keep your bufer-local keymaps
      local on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "K",  vim.lsp.buf.hover,      opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      -- 2) capabilities for nvim-cmp (and clangd offsetEncoding)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.offsetEncoding = { "utf-8" }

      -- 3) Apply defaults to ALL servers via the new API
      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- 4) (Optional) per-server tweaks go here
      -- Lua: recognize 'vim' and skip third-party checks
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      -- If you prefer forcing clangd's offset-encoding via cmd instead of capabilities:
      -- vim.lsp.config("clangd", { cmd = { "clangd", "--offset-encoding=utf-8" } })

      -- 5) Diagnostics UI (unchanged)
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      -- NOTE: No require('lspconfig').<server>.setup(...) calls anymore.
      -- Mason-lspconfig will call vim.lsp.enable() for ensured servers.
      -- If you ever disable automatic_enable, you can do:
      -- vim.lsp.enable({ "lua_ls", "pyright", "clangd", "html", "cssls", "ts_ls" })
    end,
  },
}
