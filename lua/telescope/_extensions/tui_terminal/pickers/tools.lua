local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local window = require("tui_terminal.window")

local function run_tool(prompt_bufnr)
    local selection = action_state.get_selected_entry(prompt_bufnr)
    actions.close(prompt_bufnr)
    vim.cmd("stopinsert")
    window.open_floating_terminal(selection.value)

    vim.schedule(function()
        vim.cmd("startinsert")
    end)
end

return function(opts)
    opts = opts or {}

    local tools = require("tui_terminal.config").values.tools
    if #tools == 0 then
        vim.notify("No tools configured in TUI Terminal", vim.log.levels.WARN)
        return
    end

    pickers.new(opts, {
        prompt_title = "TUI Tools",
        finder = finders.new_table({
            results = tools,
            entry_maker = function(tool)
                local display = tool.name
                if tool.args then
                    if tool.args.default then
                        display = display .. " [" .. tool.args.default .. "]"
                    end
                    if tool.args.prompt then
                        display = display .. " [+args]"
                    end
                end
                return {
                    value = tool,
                    display = display,
                    ordinal = tool.name,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                run_tool(prompt_bufnr)
            end)
            return true
        end,
    }):find()
end