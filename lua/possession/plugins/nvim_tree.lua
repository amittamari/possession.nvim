local create_plugin_win_reopener = require('possession.plugins.plugin_win_reopener').create_plugin_win_reopener

local has_nvim_tree = function()
    return pcall(require, 'nvim-tree')
end

local M = create_plugin_win_reopener('NvimTree', require('nvim-tree.api').tree.open, has_nvim_tree)

return M
