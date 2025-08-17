-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'node-debug2-adapter',
        'chrome-debug-adapter',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Configure node-debug2-adapter for Node.js/TypeScript debugging
    dap.adapters.node2 = {
      type = 'executable',
      command = 'node',
      args = {vim.fn.resolve(vim.fn.stdpath('data') .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js')},
    }

    -- Configure chrome-debug-adapter for Chrome debugging
    dap.adapters.chrome = {
      type = 'executable',
      command = 'node',
      args = {vim.fn.resolve(vim.fn.stdpath('data') .. '/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js')},
    }

    -- Angular/TypeScript specific debug configurations
    for _, language in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
      dap.configurations[language] = {
        -- Debug single nodejs files
        {
          type = 'node2',
          request = 'launch',
          name = 'Launch Node.js File',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        -- Debug nodejs processes (make sure to add --inspect when you run the process)
        {
          type = 'node2',
          request = 'attach',
          name = 'Attach to Node.js Process',
          port = 9229,
          restart = true,
          sourceMaps = true,
          localRoot = '${workspaceFolder}',
          remoteRoot = null,
          protocol = 'inspector',
        },
        -- Debug Angular application in Chrome
        {
          type = 'chrome',
          request = 'launch',
          name = 'Launch Angular App (WSL)',
          url = 'https://localhost/path/', -- Update to your exact URL
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
          userDataDir = '${workspaceFolder}/.chrome-debug',
          runtimeExecutable = '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe',
          runtimeArgs = {
            '--remote-debugging-port=9222',
            '--no-first-run',
            '--no-default-browser-check',
            '--disable-extensions',
            '--disable-web-security',
            '--disable-features=VizDisplayCompositor',
            '--user-data-dir=${workspaceFolder}/.chrome-debug',
          },
        },
        -- Debug Angular application (attach to running Chrome)
        {
          type = 'chrome',
          request = 'attach',
          name = 'Attach to Chrome',
          port = 9222,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
        -- Debug Jest tests with Node.js
        {
          type = 'node2',
          request = 'launch',
          name = 'Debug Jest Tests',
          program = '${workspaceFolder}/node_modules/.bin/jest',
          args = {
            '--runInBand',
            '--no-coverage',
            '--no-cache',
          },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
        -- Debug specific Jest test file
        {
          type = 'node2',
          request = 'launch',
          name = 'Debug Current Jest Test',
          program = '${workspaceFolder}/node_modules/.bin/jest',
          args = {
            '--runInBand',
            '--no-coverage',
            '--no-cache',
            '${relativeFile}',
          },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
        -- Debug Karma tests in Chrome
        {
          type = 'chrome',
          request = 'launch',
          name = 'Debug Karma Tests',
          url = 'http://localhost:9876/debug.html',
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
          userDataDir = '${workspaceFolder}/.vscode/chrome-debug-profile',
        },
        -- Debug Angular CLI commands
        {
          type = 'node2',
          request = 'launch',
          name = 'Debug Angular CLI',
          program = '${workspaceFolder}/node_modules/@angular/cli/bin/ng',
          args = { 'serve', '--source-map' },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        -- Debug Angular build process
        {
          type = 'node2',
          request = 'launch',
          name = 'Debug Angular Build',
          program = '${workspaceFolder}/node_modules/@angular/cli/bin/ng',
          args = { 'build', '--source-map' },
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ -----',
          type = '',
          request = 'launch',
        },
      }
    end

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
