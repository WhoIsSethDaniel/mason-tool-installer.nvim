vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  callback = require('mason-tool-installer').auto_install,
})

vim.api.nvim_create_user_command('MasonToolsUpdate', function()
  require('mason-tool-installer').check_install()
end, { force = true })
