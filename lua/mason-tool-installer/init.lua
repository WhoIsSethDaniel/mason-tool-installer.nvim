local mr = require 'mason-registry'

local SETTINGS = {
  ensure_installed = {},
  auto_update = false,
}

local setup = function(settings)
  SETTINGS = vim.tbl_deep_extend('force', SETTINGS, settings)
end

local do_install = function(p, version)
  if version ~= nil then
    vim.schedule_wrap(print(string.format('%s: updating to %s', p.name, version)))
  else
    vim.schedule_wrap(print(string.format('%s: installing', p.name)))
  end
  p:on('install:success', function()
    vim.schedule_wrap(print(string.format('%s: successfully installed', p.name)))
  end)
  p:on('install:failed', function()
    vim.schedule_wrap(print(string.format('%s: failed to install', p.name)))
  end)
  p:install { version = version }
end

local check_install = function()
  for _, item in ipairs(SETTINGS['ensure_installed']) do
    local name, version, auto_update
    if type(item) == 'table' then
      name = item[1]
      version = item.version
      auto_update = item.auto_update
    else
      name = item
    end
    local p = mr.get_package(name)
    if p:is_installed() then
      if version ~= nil then
        p:get_installed_version(function(ok, installed_version)
          if ok then
            if installed_version ~= version then
              do_install(p, version)
            end
          end
        end)
      elseif (auto_update == true) or (auto_update == nil and SETTINGS['auto_update']) then
        p:check_new_version(function(ok, version)
          if ok then
            do_install(p, version.latest_version)
          end
        end)
      end
    else
      do_install(p)
    end
  end
end

return {
  check_install = check_install,
  setup = setup,
}
