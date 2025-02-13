local M = {}

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
    vim.keymap.set('t', '<C-c>', function()
        vim.api.nvim_win_close(win, true)
    end, close_opts)

    if tool.quit_key then
        vim.keymap.set('t', 'q', function()
            vim.api.nvim_win_close(win, true)
        end, close_opts)
    end
end

return M
