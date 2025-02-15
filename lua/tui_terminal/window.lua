local config = require('tui_terminal.config')
local mappings = require('tui_terminal.mappings')
local utils = require('tui_terminal.utils')
local window_manager = require('tui_terminal.window_manager')
local api = vim.api

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
    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        callback = function()
            if not vim.b[buf].tui_detach then
                pcall(vim.api.nvim_win_close, win, true)
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        callback = function()
            utils.remove_detached_buffer(buf)
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
    })
end

local function build_command(tool)
    local cmd = tool.cmd

    -- Handle pre-command script execution
    if tool.pre_cmd then
        -- Handle script with potential arguments
        if type(tool.pre_cmd) == "table" then
            local script = tool.pre_cmd.script
            local args = tool.pre_cmd.args or ""

            -- Execute the script with its arguments, then run the command
            cmd = string.format("bash %s %s && %s", script, args, cmd)
            -- If pre_cmd is a path to a script
        elseif type(tool.pre_cmd) == "string" and tool.pre_cmd:match("%.sh$") then
            cmd = string.format("bash %s && %s", tool.pre_cmd, cmd)
        else
            -- Regular pre-command (not a script)
            cmd = tool.pre_cmd .. " && " .. cmd
        end
    end

    -- Add default arguments if they exist
    if tool.args and tool.args.default then
        cmd = cmd .. " " .. tool.args.default
    end

    -- If prompt is enabled, ask for additional arguments
    if tool.args and tool.args.prompt then
        local additional_args = vim.fn.input("Additional arguments: ")
        if additional_args ~= "" then
            cmd = cmd .. " " .. additional_args
        end
    end

    return cmd
end

local function prepare_environment(tool)
    local env = vim.fn.environ() -- Get current environment
    local modified_env = vim.deepcopy(env)

    if tool.env then
        -- Set new environment variables
        if tool.env.set then
            for key, value in pairs(tool.env.set) do
                modified_env[key] = value
            end
        end

        -- Unset environment variables
        if tool.env.unset then
            for key, _ in pairs(tool.env.unset) do
                modified_env[key] = nil
            end
        end
    end

    return modified_env
end

function M.restore_detached_buffer(stored_buf)
    local buf = stored_buf.buf

    if not api.nvim_buf_is_valid(buf) then
        utils.remove_detached_buffer(buf)
        return false
    end

    local win = api.nvim_open_win(buf, true, get_window_config())
    mappings.setup_mappings(buf, win, stored_buf.tool)
    vim.b[buf].tui_detach = false -- Clear detach flag upon restoration

    -- Schedule entering insert mode to ensure it works
    vim.schedule(function()
        vim.cmd('startinsert')
    end)

    return true
end

function M.open_floating_terminal(tool)
    if tool.detach then
        config.values.detached_buffers = config.values.detached_buffers or {}
        for _, stored in ipairs(config.values.detached_buffers) do
            if stored.tool.name == tool.name then
                if M.restore_detached_buffer(stored) then
                    return
                end
            end
        end
    end

    local buf = vim.api.nvim_create_buf(false, true)
    -- If detaching is enabled, don't wipe the buffer on window close.
    if tool.detach then
        vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    else
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    end

    vim.b[buf].tui_detach = tool.detach or false

    local win = vim.api.nvim_open_win(buf, true, get_window_config())

    -- Add window to manager
    window_manager.add_window(win, buf, tool)

    -- Prepare environment variables
    local env = prepare_environment(tool)

    local cmd = build_command(tool)
    vim.fn.termopen(cmd, {
        cwd = vim.fn.getcwd(),
        env = env
    })
    vim.cmd("startinsert")

    mappings.setup_mappings(buf, win, tool)
    setup_autocmds(buf, win)

    if tool.detach or vim.b[buf].tui_detach then
        utils.store_detached_buffer(buf, tool)
    end
end

return M
