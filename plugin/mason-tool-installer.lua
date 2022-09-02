vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  callback = require('mason-tool-installer').run_on_start,
})
vim.api.nvim_create_user_command('MasonToolsUpdate', function()
  require('mason-tool-installer').check_install(true)
end, { force = true })
vim.api.nvim_create_user_command('MasonToolsInstall', function()
  require('mason-tool-installer').check_install(false)
end, { force = true })
