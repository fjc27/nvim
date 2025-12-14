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

      -- Recommended listener pattern:
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
      vim.keymap.set("n", "<Leader>dc", dap.continue, {})
      vim.keymap.set("n", "<Leader>do", dap.step_over, {})
      vim.keymap.set("n", "<Leader>di", dap.step_into, {})
      vim.keymap.set("n", "<Leader>dO", dap.step_out, {})
      vim.keymap.set("n", "<Leader>dr", dap.repl.open, {})
      vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end, {})
      -- Optional: quick toggle for the UI
      vim.keymap.set("n", "<Leader>dui", dapui.toggle, {})
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- Use the new org for Mason here too:
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "codelldb", "debugpy" },
      automatic_installation = true,
      handlers = {}, -- keep defaults
    },
    config = function(_, opts)
      local dap = require("dap")
      require("mason-nvim-dap").setup(opts)

      -- Python (debugpy)
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            -- 1) active venv takes priority
            local venv = vim.env.VIRTUAL_ENV
            if venv and venv ~= "" and vim.fn.executable(venv .. "/bin/python") == 1 then
              return venv .. "/bin/python"
            end
            -- 2) project-local .venv next to pyproject.toml
            local pyproject = vim.fn.findfile("pyproject.toml", ".;")
            if pyproject ~= "" then
              local p = vim.fn.fnamemodify(pyproject, ":h") .. "/.venv/bin/python"
              if vim.fn.executable(p) == 1 then
                return p
              end
            end
            -- 3) fallback
            local sys = vim.fn.exepath("python3")
            return (sys ~= "" and sys) or "/usr/bin/python3"
          end,
        },
      }

      -- C/C++ (codelldb)
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
      }
      dap.configurations.c = dap.configurations.cpp
    end,
  },
  -- Optional sugar: inline variable values during debug sessions
  -- { "theHamsta/nvim-dap-virtual-text", opts = {} },
}
