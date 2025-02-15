local config = require('tui_terminal.config')
local window = require('tui_terminal.window')

local M = {}

local function has_telescope()
    local ok, _ = pcall(require, "telescope")
    return ok
end

local function handle_pre_cmd_nvim(config, callback)
    if config.pre_cmd_nvim then
        if type(config.pre_cmd_nvim) == "function" then
            config.pre_cmd_nvim(callback)
        else
            vim.notify("pre_cmd_nvim must be a function", vim.log.levels.ERROR)
            callback(nil)
        end
    else
        callback(nil)
    end
end

function M.setup(user_config)
    config.setup(user_config)

    vim.api.nvim_create_user_command("TuiTerminal", function(opts)
        local tools = config.values.tools
        if opts.args ~= "" then
            for _, tool in ipairs(tools) do
                if tool.name == opts.args then
                    window.open_floating_terminal(tool)
                    return
                end
            end
            window.open_floating_terminal({
                name = opts.args,
                cmd = opts.args,
                vim_navigation = false,
                quit_key = true -- Use default quit_key setting
            })
        else
            if has_telescope() then
                require("telescope").extensions.tui_terminal.tools()
            else
                window.open_floating_terminal(tools[1])
            end
        end
    end, { nargs = "?" })
end

function M.launch_terminal(config)
    handle_pre_cmd_nvim(config, function(result)
        if result then
            -- If pre_cmd_nvim provided a result, add it to args
            if type(config.args) == "table" then
                table.insert(config.args, result)
            else
                config.args = { result }
            end
        end
        -- Continue with terminal launch
        -- ... rest of launch code ...
    end)
end

return M
