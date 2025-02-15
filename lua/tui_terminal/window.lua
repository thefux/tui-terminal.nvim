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

    -- Handle arguments
    local args = ""
    if tool.args then
        if type(tool.args) == "table" then
            -- Handle array of arguments
            if #tool.args > 0 then
                args = table.concat(tool.args, " ")
                -- Handle object with default/prompt
            elseif tool.args.default then
                args = tool.args.default
            end
        elseif type(tool.args) == "string" then
            args = tool.args
        end
    end

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

    -- If prompt is enabled, ask for additional arguments
    if tool.args and tool.args.prompt then
        local additional_args = vim.fn.input("Additional arguments: ")
        if additional_args ~= "" then
            args = args .. " " .. additional_args
        end
    end

    -- Add arguments to command if they exist
    if args ~= "" then
        cmd = cmd .. " " .. args
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
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            vim.cmd('startinsert')
        end
    end)

    return true
end

function M.open_floating_terminal(tool_config)
    -- Handle pre_cmd_nvim before opening terminal
    if tool_config.pre_cmd_nvim then
        tool_config.pre_cmd_nvim(function(result)
            if result then
                -- Format args for goose session command
                if type(result) == "table" then
                    tool_config.args = result
                else
                    tool_config.args = { result }
                end
            end
            M._create_terminal_window(tool_config)
        end)
    else
        M._create_terminal_window(tool_config)
    end
end

function M._create_terminal_window(tool_config)
    -- Calculate window dimensions
    local width = math.floor(vim.o.columns * config.values.width)
    local height = math.floor(vim.o.lines * config.values.height)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local border = config.values.border
    local win_config = {
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

    if tool_config.detach then
        config.values.detached_buffers = config.values.detached_buffers or {}
        for _, stored in ipairs(config.values.detached_buffers) do
            if stored.tool.name == tool_config.name then
                if M.restore_detached_buffer(stored) then
                    return
                end
            end
        end
    end

    local buf = vim.api.nvim_create_buf(false, true)
    -- If detaching is enabled, don't wipe the buffer on window close.
    if tool_config.detach then
        vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    else
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    end

    vim.b[buf].tui_detach = tool_config.detach or false

    local win = vim.api.nvim_open_win(buf, true, win_config)

    -- Add window to manager
    window_manager.add_window(win, buf, tool_config)

    -- Prepare environment variables
    local env = prepare_environment(tool_config)

    local cmd = build_command(tool_config)
    vim.fn.termopen(cmd, {
        cwd = vim.fn.getcwd(),
        env = env
    })

    -- Ensure we enter insert mode after a short delay
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            vim.cmd('startinsert')
        end
    end)

    mappings.setup_mappings(buf, win, tool_config)
    setup_autocmds(buf, win)

    if tool_config.detach or vim.b[buf].tui_detach then
        utils.store_detached_buffer(buf, tool_config)
    end
end

return M
