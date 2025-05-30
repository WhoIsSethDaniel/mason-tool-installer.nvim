# mason-tool-installer

Install or upgrade all of your third-party tools.

Can run at startup or may be run manually via a command (see the [Configuration](#configuration) section below).

Uses [Mason](https://github.com/williamboman/mason.nvim) to do nearly all the work. This is a simple plugin that
helps users keep up-to-date with their tools and to make certain they have a consistent environment.

## Requirements

This plugin has the same requirements as [Mason](https://github.com/williamboman/mason.nvim). And, of course,
this plugin requires that Mason be installed.

Optionally:

-   [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) can be installed for the
    option to use lspconfig names instead of Mason names.
-   [mason-null-ls](https://github.com/jay-babu/mason-null-ls.nvim) can be installed for the
    option to use null-ls names instead of Mason names.
-   [mason-nvim-dap](https://github.com/jay-babu/mason-nvim-dap.nvim) can be installed for the
    option to use nvim-dap names instead of Mason names.

## Installation

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

## Configuration

When passing a list of tools to `ensure_installed`, `mason-tool-installer` is expecting Mason
package names by default.

If `mason-lspconfig` is installed, `mason-tool-installer` can accept `lspconfig` package names unless the integration is disabled.

If `mason-null-ls` is installed, `mason-tool-installer` can accept `null-ls` package names unless the integration is disabled.

If `mason-nvim-dap` is installed, `mason-tool-installer` can accept `nvim-dap` package names unless the integration is disabled.

```lua
require('mason-tool-installer').setup {

  -- a list of all tools you want to ensure are installed upon
  -- start
  ensure_installed = {

    -- you can pin a tool to a particular version
    { 'golangci-lint', version = 'v1.47.0' },

    -- you can turn off/on auto_update per tool
    { 'bash-language-server', auto_update = true },

    -- you can do conditional installing
    { 'gopls', condition = function() return vim.fn.executable('go') == 1  end },
    'lua-language-server',
    'vim-language-server',
    'stylua',
    'shellcheck',
    'editorconfig-checker',
    'gofumpt',
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
  -- are available the tool will be updated. This setting does not
  -- affect :MasonToolsUpdate or :MasonToolsInstall.
  -- Default: false
  auto_update = false,

  -- automatically install / update on startup. If set to false nothing
  -- will happen on startup. You can use :MasonToolsInstall or
  -- :MasonToolsUpdate to install tools and check for updates.
  -- Default: true
  run_on_start = true,

  -- set a delay (in ms) before the installation starts. This is only
  -- effective if run_on_start is set to true.
  -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
  -- Default: 0
  start_delay = 3000, -- 3 second delay

  -- Only attempt to install if 'debounce_hours' number of hours has
  -- elapsed since the last time Neovim was started. This stores a
  -- timestamp in a file named stdpath('data')/mason-tool-installer-debounce.
  -- This is only relevant when you are using 'run_on_start'. It has no
  -- effect when running manually via ':MasonToolsInstall' etc....
  -- Default: nil
  debounce_hours = 5, -- at least 5 hours between attempts to install/update

  -- By default all integrations are enabled. If you turn on an integration
  -- and you have the required module(s) installed this means you can use
  -- alternative names, supplied by the modules, for the thing that you want
  -- to install. If you turn off the integration (by setting it to false) you
  -- cannot use these alternative names. It also suppresses loading of those
  -- module(s) (assuming any are installed) which is sometimes wanted when
  -- doing lazy loading.
  integrations = {
    ['mason-lspconfig'] = true,
    ['mason-null-ls'] = true,
    ['mason-nvim-dap'] = true,
  },
}
```

## Commands

`:MasonToolsInstall` - only installs tools that are missing or at the incorrect version

`:MasonToolsInstallSync` - execute `:MasonToolsInstall` in blocking manner. It's useful in Neovim headless mode.

`:MasonToolsUpdate` - install missing tools and update already installed tools

`:MasonToolsUpdateSync` - execute `:MasonToolsUpdate` in blocking manner. It's useful in Neovim headless mode.

`:MasonToolsClean` - remove installed packages that are not listed in `ensure_installed`

## Events

Prior to installing the first package `mason-tool-installer` will emit a user event named
`MasonToolsStartingInstall`. If there are no packages to install then no event will be emitted.
This event will only be emitted once -- at the start of installing packages. To use this
event you can setup an event handler like so:

```lua
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsStartingInstall',
    callback = function()
      vim.schedule(function()
        print 'mason-tool-installer is starting'
      end)
    end,
  })
```

Upon completion of any `mason-tool-installer` initiated installation/update a user event will be
emitted named `MasonToolsUpdateCompleted`. If you have at least neovim 0.8 the programs that were
just installed or updated will be in the `data` element of the argument to the callback (see `
:h nvim_create_autocmd` for much more information). To use this event you can setup an event handler
like so:

```lua
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    callback = function(e)
      vim.schedule(function()
        print(vim.inspect(e.data)) -- print the table that lists the programs that were installed
      end)
    end,
  })
```

## Suggestions / Complaints / Help

Please feel free to start a [discussion](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/discussions) or
file a [bug report](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues).
