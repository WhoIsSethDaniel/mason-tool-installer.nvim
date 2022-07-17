local mr = require 'mason-registry'

local SETTINGS = {
  ensure_installed = {},
}

local setup = function(settings)
  SETTINGS['ensure_installed'] = settings['ensure_installed']
end

local check_install = function()
  for _, name in ipairs(SETTINGS['ensure_installed']) do
    local p = mr.get_package(name)
    if not p:is_installed() then
      p:on('install:success', function()
        vim.schedule_wrap(print(string.format('%s: successfully installed', p.name)))
      end)
      p:on('install:failed', function()
        vim.schedule_wrap(print(string.format('%s: failed to install', p.name)))
      end)
      p:install()
    end
  end
end

return {
  check_install = check_install,
  setup = setup,
}
