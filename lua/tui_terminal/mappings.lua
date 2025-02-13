local M = {}
local utils = require('tui_terminal.utils')
local api = vim.api

function M.setup_mappings(buf, win, tool)
    vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<Esc>',
        { noremap = true, silent = true })

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

    -- Clear any existing mappings for this buffer
    pcall(vim.keymap.del, 't', '<C-c>', { buffer = buf })
    pcall(vim.keymap.del, 't', '<C-d>', { buffer = buf })
    pcall(vim.keymap.del, 't', 'q', { buffer = buf })

    vim.keymap.set('t', '<C-c>', function()
        -- First, remove from detached list
        utils.remove_detached_buffer(buf)

        -- Then mark as not detached and set to wipe
        vim.b[buf].tui_detach = false

        -- Stop the terminal job
        pcall(vim.api.nvim_buf_delete, buf, { force = true })

        -- Finally close the window if it's still valid
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
