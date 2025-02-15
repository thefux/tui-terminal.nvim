local M = {}

-- Store active floating windows
M.active_windows = {}

-- Add window to tracking
function M.add_window(win, buf, tool)
    table.insert(M.active_windows, {
        win = win,
        buf = buf,
        tool = tool,
        created = os.time()
    })
end

-- Remove window from tracking
function M.remove_window(win)
    for i, w in ipairs(M.active_windows) do
        if w.win == win then
            table.remove(M.active_windows, i)
            break
        end
    end
end

-- Get next/previous window
function M.cycle_windows(direction)
    if #M.active_windows <= 1 then return end

    local current_win = vim.api.nvim_get_current_win()
    local current_idx = nil

    -- Find current window index
    for i, w in ipairs(M.active_windows) do
        if w.win == current_win then
            current_idx = i
            break
        end
    end

    if current_idx then
        local next_idx
        if direction == 'next' then
            next_idx = current_idx % #M.active_windows + 1
        else
            next_idx = (current_idx - 2) % #M.active_windows + 1
        end

        local next_win = M.active_windows[next_idx].win
        if vim.api.nvim_win_is_valid(next_win) then
            vim.api.nvim_set_current_win(next_win)
            -- Schedule entering insert mode to ensure it works
            vim.schedule(function()
                vim.cmd('startinsert')
            end)
        end
    end
end

return M
