local augroup = vim.api.nvim_create_augroup('MasonToolInstaller', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = augroup,
  pattern = { '*' },
  once = true,
  callback = require('mason-tool-installer').check_install,
})
