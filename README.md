# mason-tool-installer
Install, or upgrade, your third-party tools automatically on startup. 

Uses [Mason](https://github.com/williamboman/mason.nvim) to do nearly all the work. This is a simple plugin that
helps users keep up-to-date with their tools and to make certain they have a consistent environment.

# Requirements
This plugin has the same requirements as [Mason](https://github.com/williamboman/mason.nvim).

# Installation
Install using your favorite plugin manager. 

If you use vim-plug:
```vim
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'
```
Or if you use Vim 8 style packages:
```bash
cd <plugin dir>
git clone https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
```

# Configuration
```
require'mason-tool-installer'.setup {
    -- a list of all tools you want to ensure are installed upon
    -- start
    ensure_installed = {
        'bash-language-server',
        'lua-language-server',
        'vim-language-server',
        'gopls',
        'stylua',
        'shellcheck',
        'editorconfig-checker',
        'gofumpt',
        'golangci-lint',
        'golines',
        'gomodifytags',
        'gotests',
        'impl',
        'json-to-struct',
        'luacheck',
        'misspell',
        'revive',
        'shellcheck',
        'shfmt',
        'staticcheck',
        'vint',
    },
    -- if set to true this will check each tool for updates. If updates
    -- are available the tool will be updated.
    auto_update = false
```
