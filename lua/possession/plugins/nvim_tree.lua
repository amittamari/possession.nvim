local create_plugin_reopener = require('possession.plugins.plugin_reopener').create_plugin_reopener

local has_nvim_tree = function()
    return pcall(require, 'nvim-tree')
end

local M = create_plugin_reopener('NvimTree', require('nvim-tree.api').tree.open, has_nvim_tree)

return M
