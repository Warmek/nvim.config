-- Angular development enhancements
return {
  -- Angular Language Server and related tools
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      -- Ensure Angular file types are recognized
      vim.filetype.add({
        extension = {
          component = 'typescript',
          service = 'typescript',
          pipe = 'typescript',
          directive = 'typescript',
        },
        pattern = {
          ['.*%.component%.ts'] = 'typescript',
          ['.*%.service%.ts'] = 'typescript',
          ['.*%.pipe%.ts'] = 'typescript',
          ['.*%.directive%.ts'] = 'typescript',
          ['.*%.guard%.ts'] = 'typescript',
          ['.*%.resolver%.ts'] = 'typescript',
          ['.*%.interceptor%.ts'] = 'typescript',
        },
      })
    end,
  },

  -- JSON Schema support for Angular configuration files
  {
    'b0o/schemastore.nvim',
    lazy = true,
  },

  -- Enhanced TypeScript support
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    opts = {
      settings = {
        -- TypeScript server settings
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    },
  },

  -- Angular snippets and utilities
  {
    'johnpapa/vscode-angular-snippets',
    event = 'InsertEnter',
    dependencies = { 'L3MON4D3/LuaSnip' },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { vim.fn.stdpath('data') .. '/lazy/vscode-angular-snippets' }
      })
    end,
  },
}
