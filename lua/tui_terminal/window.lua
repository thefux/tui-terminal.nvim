local config = require('tui_terminal.config')
local mappings = require('tui_terminal.mappings')

local M = {}

local function get_window_config()
    -- Calculate window dimensions based on config
    local width = math.floor(vim.o.columns * config.values.width)
    local height = math.floor(vim.o.lines * config.values.height)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local border = config.values.border
    return {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = border.type == "custom" and {
            border.chars.top_left,
            border.chars.top,
            border.chars.top_right,
            border.chars.right,
            border.chars.bottom_right,
            border.chars.bottom,
            border.chars.bottom_left,
            border.chars.left,
        } or border.type,
    }
end

local function setup_autocmds(buf, win)
    -- Close the floating window when the buffer is left
    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        callback = function()
            pcall(vim.api.nvim_win_close, win, true)
        end,
    })

    -- Also ensure to close the window if the buffer is wiped out
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        callback = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
    })
end

-- Opens a floating terminal and runs the specified TUI command
function M.open_floating_terminal(tool)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local win = vim.api.nvim_open_win(buf, true, get_window_config())

    vim.fn.termopen(tool.cmd, { cwd = vim.fn.getcwd() })
    vim.cmd("startinsert")

    mappings.setup_mappings(buf, win, tool)
    setup_autocmds(buf, win)
end

return M
