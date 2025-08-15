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
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {
			ensure_installed = { "codelldb", "debugpy" },
			automatic_installation = true,
			handlers = {}, -- use default auto-setup
		},
		config = function(_, opts)
			require("mason-nvim-dap").setup(opts)

			-- Fallback: explicitly register codelldb if auto-setup didn't
			local dap = require("dap")
			if not dap.adapters.codelldb then
				local ok, registry = pcall(require, "mason-registry")
				if ok and registry.is_installed("codelldb") then
					local pkg = registry.get_package("codelldb")
					local path = pkg:get_install_path()
					local codelldb = path .. "/extension/adapter/codelldb"
					dap.adapters.codelldb = {
						type = "server",
						port = "${port}",
						executable = { command = codelldb, args = { "--port", "${port}" } },
					}
				end
			end
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
			local ok, registry = pcall(require, "mason-registry")
			local py
			if ok and registry.is_installed("debugpy") then
				py = registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python"
			else
				py = "python"
			end
			require("dap-python").setup(py)
		end,
	},
}
