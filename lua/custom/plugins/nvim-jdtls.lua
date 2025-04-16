return{
    'mfussenegger/nvim-jdtls',
    config = function()
        cmd = {'/path/to/jdt-language-server/bin/jdtls'},
        root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1])
    end
    require('jdtls').start_or_attach(config)
}
