vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  callback = require('mason-tool-installer').check_install,
})
