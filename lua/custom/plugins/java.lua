-- Java development enhancements
return {
  -- Java LSP (jdtls)
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local jdtls = require('jdtls')

      -- Setup function for jdtls
      local function setup_jdtls()
        local home = os.getenv('HOME')
        local workspace_dir = home .. '/.cache/jdtls/workspace'
        local config_dir = home .. '/.cache/jdtls/config'

        -- Determine OS specific paths
        local os_name = vim.loop.os_uname().sysname
        local mason_path = vim.fn.stdpath('data') .. '/mason/packages'
        local jdtls_path = mason_path .. '/jdtls'
        local launcher_path = nil

        if os_name == 'Linux' then
          launcher_path = jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'
        elseif os_name == 'Darwin' then
          launcher_path = jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'
        elseif os_name == 'Windows_NT' then
          launcher_path = jdtls_path .. '\\plugins\\org.eclipse.equinox.launcher_*.jar'
        end

        -- Find the launcher jar
        local launcher_jar = vim.fn.glob(launcher_path)
        if launcher_jar == '' then
          vim.notify('jdtls launcher jar not found', vim.log.levels.ERROR)
          return
        end

        -- Configuration
        local config = {
          cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xmx1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', launcher_jar,
            '-configuration', config_dir,
            '-data', workspace_dir,
          },
          root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),
          settings = {
            java = {
              signatureHelp = { enabled = true },
              contentProvider = { preferred = 'fernflower' },
              completion = {
                favoriteStaticMembers = {
                  'org.hamcrest.MatcherAssert.assertThat',
                  'org.hamcrest.Matchers.*',
                  'org.hamcrest.CoreMatchers.*',
                  'org.junit.jupiter.api.Assertions.*',
                  'java.util.Objects.requireNonNull',
                  'java.util.Objects.requireNonNullElse',
                  'org.mockito.Mockito.*',
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              codeGeneration = {
                toString = {
                  template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                },
                hashCodeEquals = {
                  useJava7Objects = true,
                },
                useBlocks = true,
              },
            },
          },
          init_options = {
            bundles = {},
          },
        }

        -- Start jdtls
        jdtls.start_or_attach(config)
      end

      -- Auto-setup on Java files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = setup_jdtls,
      })
    end,
  },

  -- Java DAP (Debug Adapter Protocol)
  {
    'mfussenegger/nvim-dap',
    ft = 'java',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- DAP UI setup
      dapui.setup()

      -- Java DAP configuration
      dap.configurations.java = {
        {
          type = 'java',
          request = 'launch',
          name = 'Debug (Attach) - Remote',
          hostName = '127.0.0.1',
          port = 5005,
        },
        {
          type = 'java',
          request = 'launch',
          name = 'Debug (Launch) - Current File',
          mainClass = '${file}',
        },
        {
          type = 'java',
          request = 'launch',
          name = 'Debug (Launch) - Main',
          mainClass = 'com.example.Main',
        },
      }

      -- Keymaps for DAP
      vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'DAP: Continue' })
      vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = 'DAP: Step Over' })
      vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = 'DAP: Step Into' })
      vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = 'DAP: Step Out' })
      vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'DAP: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'DAP: Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = 'DAP: Log Point' })
      vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = 'DAP: Open REPL' })
      vim.keymap.set('n', '<leader>dl', function() dap.run_last() end, { desc = 'DAP: Run Last' })
      vim.keymap.set({ 'n', 'v' }, '<leader>dh', function() require('dap.ui.widgets').hover() end, { desc = 'DAP: Hover' })
      vim.keymap.set({ 'n', 'v' }, '<leader>dp', function() require('dap.ui.widgets').preview() end, { desc = 'DAP: Preview' })
      vim.keymap.set('n', '<leader>df', function() dapui.float_element('scopes') end, { desc = 'DAP: Float Scopes' })
      vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = 'DAP: Toggle UI' })
    end,
  },

  -- Java Test Runner
  {
    'nvim-neotest/neotest',
    ft = 'java',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'mfussenegger/nvim-jdtls', -- For Java test support
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-java')({
            ignore_wrapper = false, -- Whether to ignore maven/gradle wrapper
          }),
        },
      })

      -- Keymaps for testing
      vim.keymap.set('n', '<leader>tt', function() require('neotest').run.run() end, { desc = 'Test: Run nearest' })
      vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, { desc = 'Test: Run file' })
      vim.keymap.set('n', '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, { desc = 'Test: Debug nearest' })
      vim.keymap.set('n', '<leader>ts', function() require('neotest').run.stop() end, { desc = 'Test: Stop' })
      vim.keymap.set('n', '<leader>ta', function() require('neotest').run.attach() end, { desc = 'Test: Attach' })
      vim.keymap.set('n', '<leader>to', function() require('neotest').output.open({ enter = true }) end, { desc = 'Test: Open output' })
      vim.keymap.set('n', '<leader>tO', function() require('neotest').output_panel.toggle() end, { desc = 'Test: Toggle output panel' })
      vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = 'Test: Toggle summary' })
    end,
  },

  -- Java Test Adapter for neotest
  {
    'rcasia/neotest-java',
    ft = 'java',
  },
}