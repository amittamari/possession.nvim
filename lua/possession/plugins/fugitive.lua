local M = {}

local api = vim.api
local utils = require('possession.utils')

-- Close fugitive windows in given tab (id), return true if closed.
local function close_fugitive(tab)
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
        local buf = api.nvim_win_get_buf(win)
        if api.nvim_buf_get_option(buf, 'filetype') == 'fugitive' then
            api.nvim_buf_delete(buf, { force = true })
            return true
        end
    end
    return false
end

-- Open fugitive in given tab numbers.
local function open_fugitive(tab_nums)
    local num2id = utils.tab_num_to_id_map()
    local initial = api.nvim_get_current_tabpage()

    for _, tab_num in ipairs(tab_nums) do
        local tab = num2id[tab_num]
        if tab then
            api.nvim_set_current_tabpage(tab)
            local win = api.nvim_get_current_win()

            vim.cmd('G')

            -- Try to restore window
            if api.nvim_win_is_valid(win) then
                api.nvim_set_current_win(win)
            end
        end
    end

    vim.api.nvim_set_current_tabpage(initial)
end

function M.before_save(opts, name)
    -- First close fugitive in tabs, then get numbers, filtering out any tabs that were closed.
    -- TODO: restore tabs that have been closed? probably not worth to handle this edge case
    local tabs = vim.tbl_filter(close_fugitive, vim.api.nvim_list_tabpages())
    local nums = utils.filter_map(function(tab)
        local valid = api.nvim_tabpage_is_valid(tab)
        return valid and api.nvim_tabpage_get_number(tab) or nil
    end, tabs)

    return {
        tabs = nums,
    }
end

function M.after_save(opts, name, plugin_data, aborted)
    if plugin_data and plugin_data.tabs then
        open_fugitive(plugin_data.tabs)
    end
end

function M.after_load(opts, name, plugin_data)
    if plugin_data and plugin_data.tabs then
        open_fugitive(plugin_data.tabs)
    end
end

return M
