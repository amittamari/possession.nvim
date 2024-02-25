local create_plugin_win_reopener = require('possession.plugins.plugin_win_reopener').create_plugin_win_reopener

local has_fugitive = function()
    -- TODO has solution?
    return true
end

local M = create_plugin_win_reopener('fugitive', function()
    vim.cmd('G')
end, has_fugitive)

return M
