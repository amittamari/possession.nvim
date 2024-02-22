local M = {}

local utils = require('possession.utils')

-- Close plugin windows in given tab (id) by filetype, return true if closed.
local function close_plugin_window_by_filetype(tab, ft)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(buf, 'filetype') == ft then
            vim.api.nvim_buf_delete(buf, { force = true })
            return true
        end
    end
    return false
end

-- Open plugin in given tab numbers using open_plugin function.
local function open_plugin_in_tabs(tab_nums, open_plugin)
    local num2id = utils.tab_num_to_id_map()
    local initial = vim.api.nvim_get_current_tabpage()

    for _, tab_num in ipairs(tab_nums) do
        local tab = num2id[tab_num]
        if tab then
            vim.api.nvim_set_current_tabpage(tab)
            local win = vim.api.nvim_get_current_win()

            open_plugin()

            -- Try to restore window
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
            end
        end
    end

    vim.api.nvim_set_current_tabpage(initial)
end

local function _before_save(opts, name, ft, has_plugin)
    if not has_plugin then
        return {}
    end

    -- First close plugin windows in tabs, then get numbers, filtering out any tabs that were closed.
    -- TODO: restore tabs that have been closed? probably not worth to handle this edge case
    local filter_func = function(tab)
        return close_plugin_window_by_filetype(tab, ft)
    end
    local tabs = vim.tbl_filter(filter_func, vim.api.nvim_list_tabpages())
    local nums = utils.filter_map(function(tab)
        local valid = vim.api.nvim_tabpage_is_valid(tab)
        return valid and vim.api.nvim_tabpage_get_number(tab) or nil
    end, tabs)

    return {
        tabs = nums,
    }
end

local function _after_save(opts, name, plugin_data, aborted, has_plugin, open_plugin)
    if not has_plugin then
        return
    end

    if plugin_data and plugin_data.tabs then
        open_plugin_in_tabs(plugin_data.tabs, open_plugin)
    end
end

local function _after_load(opts, name, plugin_data, has_plugin, open_plugin)
    if not has_plugin then
        return
    end

    if plugin_data and plugin_data.tabs then
        open_plugin_in_tabs(plugin_data.tabs, open_plugin)
    end
end

function M.create_plugin_reopener(ft, open_plugin, has_plugin_func)
    return {
        before_save = function(opts, name)
            return _before_save(opts, name, ft, has_plugin_func())
        end,
        after_save = function(opts, name, plugin_data, aborted)
            return _after_save(opts, name, plugin_data, aborted, has_plugin_func(), open_plugin)
        end,
        after_load = function(opts, name, plugin_data)
            return _after_load(opts, name, plugin_data, has_plugin_func(), open_plugin)
        end,
    }
end

return M
