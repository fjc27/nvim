return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            auto_install = true,
            ensure_installed = {"lua", "javascript", "python", "c", "cpp", "html", "css", "vim", "vimdoc", "query", "markdown", "markdown_inline"},
            highlight = {enable = true },
            indent = { enable = true },
        })
    end
}
