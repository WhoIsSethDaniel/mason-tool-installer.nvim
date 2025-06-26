vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('mti_start', {}),
  callback = function()
    vim.api.nvim_del_augroup_by_name 'mti_start'
    require('mason-tool-installer').run_on_start()
  end,
})
vim.api.nvim_create_user_command('MasonToolsUpdate', function()
  require('mason-tool-installer').check_install(true)
end, { force = true })
vim.api.nvim_create_user_command('MasonToolsUpdateSync', function()
  require('mason-tool-installer').check_install(true, true)
end, { force = true })
vim.api.nvim_create_user_command('MasonToolsInstall', function()
  require('mason-tool-installer').check_install(false)
end, { force = true })
vim.api.nvim_create_user_command('MasonToolsInstallSync', function()
  require('mason-tool-installer').check_install(false, true)
end, { force = true })
vim.api.nvim_create_user_command('MasonToolsClean', function()
  require('mason-tool-installer').clean()
end, { force = true })
