local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

if not vim.g.vscode then
    require("vim-options")
end

require("lazy").setup({
    spec = {
        { import = "plugins", cond = not vim.g.vscode }
    },
    checker = {
        enabled = true,
        notify = false,
    },
    install = { missing = true },
    performance = { cache = { enabled = true } },
})
