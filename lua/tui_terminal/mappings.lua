local M = {}
local utils = require('tui_terminal.utils')
local window_manager = require('tui_terminal.window_manager')
local api = vim.api

function M.setup_mappings(buf, win, tool)
    -- Use Esc to toggle between terminal and normal mode
    vim.keymap.set('t', '<Esc>', function()
        vim.cmd('stopinsert')
    end, { buffer = buf, noremap = true, silent = true })

    -- Use 'i' or 'a' in normal mode to enter terminal mode
    vim.keymap.set('n', 'i', function()
        vim.cmd('startinsert')
    end, { buffer = buf, noremap = true, silent = true })

    vim.keymap.set('n', 'a', function()
        vim.cmd('startinsert')
    end, { buffer = buf, noremap = true, silent = true })

    -- Window navigation
    vim.keymap.set('t', '<A-n>', function()
        window_manager.cycle_windows('next')
    end, { buffer = buf, noremap = true, silent = true })

    vim.keymap.set('t', '<A-p>', function()
        window_manager.cycle_windows('prev')
    end, { buffer = buf, noremap = true, silent = true })

    if tool.vim_navigation then
        vim.api.nvim_buf_set_keymap(buf, 't', 'h', '<Left>',
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 't', 'j', '<Down>',
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 't', 'k', '<Up>',
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 't', 'l', '<Right>',
            { noremap = true, silent = true })
    end

    local close_opts = { buffer = buf, noremap = true, silent = true }

    pcall(vim.keymap.del, 't', '<C-c>', { buffer = buf })
    pcall(vim.keymap.del, 't', '<C-d>', { buffer = buf })
    pcall(vim.keymap.del, 't', 'q', { buffer = buf })

    vim.keymap.set('t', '<C-c>', function()
        utils.remove_detached_buffer(buf)
        window_manager.remove_window(win)
        vim.b[buf].tui_detach = false
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        if api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, true)
        end
    end, close_opts)

    vim.keymap.set('t', '<C-d>', function()
        vim.b[buf].tui_detach = true
        utils.store_detached_buffer(buf, tool)
        vim.notify(string.format("Terminal '%s' detached", tool.name), vim.log.levels.INFO)
        if api.nvim_win_is_valid(win) then
            vim.api.nvim_win_hide(win)
        else
            vim.notify("Window is already hidden", vim.log.levels.INFO)
        end
    end, close_opts)

    if tool.quit_key ~= false then
        vim.keymap.set('t', 'q', function()
            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end
        end, close_opts)
    end
end

return M
