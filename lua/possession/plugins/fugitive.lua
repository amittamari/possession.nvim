local create_plugin_reopener = require('possession.plugins.plugin_reopener').create_plugin_reopener

local has_fugitive = function()
    -- TODO has solution?
    return true
end

local M = create_plugin_reopener('fugitive', function()
    vim.cmd('G')
end, has_fugitive)

return M
