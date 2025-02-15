local M = {}

M.defaults = {
    -- Window dimensions as percentage of screen (0.0 to 1.0)
    width = 0.9,  -- 90% of screen width by default
    height = 0.9, -- 90% of screen height by default
    tools = {
        -- Example of a tool with arguments and pre-command
        {
            name = "custom-tool",
            cmd = "mytool",
            args = {
                default = "-f --color",   -- Default arguments
                prompt = true,            -- Prompt for additional arguments
            },
            pre_cmd = {                   -- Script with arguments
                script = "~/.config/test.sh",
                args = "--env dev --debug"
            },
            env = {
                set = {                   -- Set these environment variables
                },
                unset = {                 -- Unset these environment variables
                },
            },
        }
    },
    -- Store detached buffers
    detached_buffers = {},
    border = {
        -- Can be "none", "single", "double", "rounded", "solid", "shadow", or "custom"
        type = "rounded",
        chars = {
            top_left = "╭",
            top = "─",
            top_right = "╮",
            right = "│",
            bottom_right = "╯",
            bottom = "─",
            bottom_left = "╰",
            left = "│",
        },
    }
}

M.values = {}

function M.setup(config)
    M.values = vim.tbl_deep_extend("force", {}, M.defaults, config or {})
end

return M
