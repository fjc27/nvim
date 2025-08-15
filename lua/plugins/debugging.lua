return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
            vim.keymap.set("n", "<Leader>dc", dap.continue, {})
            vim.keymap.set("n", "<Leader>do", dap.step_over, {})
            vim.keymap.set("n", "<Leader>di", dap.step_into, {})
            vim.keymap.set("n", "<Leader>dO", dap.step_out, {})
            vim.keymap.set("n", "<Leader>dr", dap.repl.open, {})
            vim.keymap.set("n", "<Leader>dB", function()
                dap.set_breakpoint(vim.fn.input("Condition: "))
            end, {})
        end,
    },
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
        ensure_installed = { "debugpy", "codelldb" },
        automatic_installation = true,
        handlers = {},
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            local dap = require("dap")

            -- C/C++ via codelldb
            dap.configurations.cpp = {
                {
                    name = "Launch (codelldb)",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
                {
                    name = "Attach to process",
                    type = "codelldb",
                    request = "attach",
                    pid = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
            }
            dap.configurations.c = dap.configurations.cpp
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = { "python" },
        dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
        config = function()
            -- Use Mason’s debugpy venv python
            local ok, registry = pcall(require, "mason-registry")
            local py
            if ok then
                local pkg = registry.get_package("debugpy")
                py = pkg:get_install_path() .. "/venv/bin/python"
            else
                py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            end
            require("dap-python").setup(py)
        end,
    },
}
