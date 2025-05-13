local mr = require 'mason-registry'

local mlsp, mnls, mdap

local IS_V1 = require('mason.version').MAJOR_VERSION == 1

local SETTINGS = {
  ensure_installed = {},
  auto_update = false,
  run_on_start = true,
  start_delay = 0,
  debounce_hours = nil,
  integrations = {
    ['mason-lspconfig'] = true,
    ['mason-null-ls'] = true,
    ['mason-nvim-dap'] = true,
  },
}

local setup_integrations = function()
  if SETTINGS.integrations['mason-lspconfig'] then
    local ok_mlsp, mlsp_mod = pcall(require, 'mason-lspconfig')
    if ok_mlsp then
      mlsp = mlsp_mod
    end
  end

  if SETTINGS.integrations['mason-null-ls'] then
    local ok_mnls, mnls_mod = pcall(require, 'mason-null-ls.mappings.source')
    if ok_mnls then
      mnls = mnls_mod
    end
  end

  if SETTINGS.integrations['mason-nvim-dap'] then
    local ok_mdap, mdap_mod = pcall(require, 'mason-nvim-dap.mappings.source')
    if ok_mdap then
      mdap = mdap_mod
    end
  end
end

local setup = function(settings)
  SETTINGS = vim.tbl_deep_extend('force', SETTINGS, settings)
  validators = {
    ensure_installed = { SETTINGS.ensure_installed, 'table', true },
    auto_update = { SETTINGS.auto_update, 'boolean', true },
    run_on_start = { SETTINGS.run_on_start, 'boolean', true },
    start_delay = { SETTINGS.start_delay, 'number', true },
    debounce_hours = { SETTINGS.debounce_hours, 'number', true },
    integrations = { SETTINGS.integrations, 'table', true },
    ['mason-lspconfig'] = { SETTINGS.integrations['mason-lspconfig'], 'boolean', true },
    ['mason-null-ls'] = { SETTINGS.integrations['mason-null-ls'], 'boolean', true },
    ['mason-nvim-dap'] = { SETTINGS.integrations['mason-nvim-dap'], 'boolean', true },
  }
  if vim.fn.has 'nvim-0.11.0' == 1 then
    for key, value in pairs(validators) do
      vim.validate(key, value[1], value[2], value[3])
    end
  else
    vim.validate(validators)
  end
  setup_integrations()
end

local debounce_file = vim.fn.stdpath 'data' .. '/mason-tool-installer-debounce'

local read_last_timestamp = function()
  local f = io.open(debounce_file)
  if f ~= nil then
    local last = f:read()
    f:close()
    return last
  end
  return nil
end

local write_new_timestamp = function()
  local f = assert(io.open(debounce_file, 'w+'))
  f:write(os.time())
  f:close()
end

local can_run = function(hours)
  local last = read_last_timestamp()
  if last == nil then
    write_new_timestamp()
    return true
  end
  if (os.time() - last) > hours * 3600 then
    write_new_timestamp()
    return true
  end
  return false
end

local show = vim.schedule_wrap(function(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = 'mason-tool-installer' })
end)

local show_error = vim.schedule_wrap(function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = 'mason-tool-installer' })
end)

local installed = false
local installed_packages = {}
local do_install = function(p, version, on_close)
  if version ~= nil then
    show(string.format('%s: updating to %s', p.name, version))
  else
    show(string.format('%s: installing', p.name))
  end
  p:once('install:success', function()
    show(string.format('%s: successfully installed', p.name))
  end)
  p:once('install:failed', function()
    show_error(string.format('%s: failed to install', p.name))
  end)
  if not installed then
    installed = true
    vim.schedule(function()
      vim.api.nvim_exec_autocmds('User', {
        pattern = 'MasonToolsStartingInstall',
      })
    end)
  end
  table.insert(installed_packages, p.name)
  if IS_V1 then
    p:install({ version = version }):once('closed', vim.schedule_wrap(on_close))
  else
    if not p:is_installing() then
      p:install({ version = version }, vim.schedule_wrap(on_close))
    end
  end
end

local mlsp_get_mappings_cache
local map_name = function(name)
  if mlsp then
    if IS_V1 then
      name = mlsp.get_mappings().lspconfig_to_mason[name] or name
    elseif mlsp_get_mappings_cache then
      name = mlsp_get_mappings_cache.lspconfig_to_package[name] or name
    else
      mlsp_get_mappings_cache = mlsp.get_mappings()
      name = mlsp_get_mappings_cache.lspconfig_to_package[name] or name
    end
  end
  if mnls then
    name = mnls.getPackageFromNullLs(name) or name
  end
  if mdap then
    name = mdap.nvim_dap_to_package[name] or name
  end
  return name
end

local check_install = function(force_update, sync)
  sync = sync or false
  if not force_update and SETTINGS.debounce_hours ~= nil and not can_run(SETTINGS.debounce_hours) then
    return
  end
  installed = false -- reset for triggered events
  installed_packages = {} -- reset
  local completed = 0
  local total = vim.tbl_count(SETTINGS.ensure_installed)
  local all_completed = false
  local on_close = function()
    completed = completed + 1
    if completed >= total then
      local event = {
        pattern = 'MasonToolsUpdateCompleted',
      }
      if vim.fn.has 'nvim-0.8' == 1 then
        event.data = installed_packages
      end
      vim.api.nvim_exec_autocmds('User', event)
      all_completed = true
    end
  end
  local ensure_installed = function()
    for _, item in ipairs(SETTINGS.ensure_installed or {}) do
      local name, version, auto_update, condition
      if type(item) == 'table' then
        name = item[1]
        version = item.version
        auto_update = item.auto_update
        condition = item.condition
      else
        name = item
      end
      if condition ~= nil and not condition() then
        vim.schedule(on_close)
      else
        name = map_name(name)
        local p = mr.get_package(name)
        if p:is_installed() then
          if version ~= nil then
            if IS_V1 then
              p:get_installed_version(function(ok, installed_version)
                if ok and installed_version ~= version then
                  do_install(p, version, on_close)
                else
                  vim.schedule(on_close)
                end
              end)
            else
              local installed_version = p:get_installed_version()
              if installed_version ~= version then
                do_install(p, version, on_close)
              else
                vim.schedule(on_close)
              end
            end
          elseif
            force_update or (force_update == nil and (auto_update or (auto_update == nil and SETTINGS.auto_update)))
          then
            if IS_V1 then
              p:check_new_version(function(ok, version_info)
                if ok then
                  do_install(p, version_info.latest_version, on_close)
                else
                  vim.schedule(on_close)
                end
              end)
            else
              local latest_version = p:get_latest_version()
              local installed_version = p:get_installed_version()
              if latest_version ~= installed_version then
                do_install(p, latest_version, on_close)
              else
                vim.schedule(on_close)
              end
            end
          else
            vim.schedule(on_close)
          end
        else
          name = map_name(name)
          local p = mr.get_package(name)
          if p:is_installed() then
            if version ~= nil then
              p:get_installed_version(function(ok, installed_version)
                if ok and installed_version ~= version then
                  do_install(p, version, on_close)
                else
                  vim.schedule(on_close)
                end
              end)
            elseif
              force_update or (force_update == nil and (auto_update or (auto_update == nil and SETTINGS.auto_update)))
            then
              p:check_new_version(function(ok, version)
                if ok then
                  do_install(p, version.latest_version, on_close)
                else
                  vim.schedule(on_close)
                end
              end)
            else
              vim.schedule(on_close)
            end
          else
            do_install(p, version, on_close)
          end
        end
      end
    end
  end
  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end
  if sync then
    while true do
      vim.wait(10000, function()
        return all_completed
      end)
      if all_completed then
        break
      end
    end
  end
end

local run_on_start = function()
  if SETTINGS.run_on_start then
    vim.defer_fn(check_install, SETTINGS.start_delay or 0)
  end
end

local clean = function()
  local expected = {}
  for _, item in ipairs(SETTINGS.ensure_installed or {}) do
    local name
    if type(item) == 'table' then
      name = item[1]
    else
      name = item
    end
    name = map_name(name)
    table.insert(expected, name)
  end

  local all = mr.get_all_package_names()
  for _, name in ipairs(all) do
    if mr.is_installed(name) and not vim.tbl_contains(expected, name) then
      vim.notify(string.format('Uninstalling %s', name), vim.log.levels.INFO, { title = 'mason-tool-installer' })
      mr.get_package(name):uninstall()
    end
  end
end

return {
  run_on_start = run_on_start,
  check_install = check_install,
  setup = setup,
  clean = clean,
}
