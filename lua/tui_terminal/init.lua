local config = require('tui_terminal.config')
local window = require('tui_terminal.window')

local M = {}

local function has_telescope()
    local ok, _ = pcall(require, "telescope")
    return ok
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

return M
