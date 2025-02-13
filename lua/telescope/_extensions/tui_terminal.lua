local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local config = require("tui_terminal.config")
local window = require("tui_terminal.window")

local function run_tool(prompt_bufnr)
    local selection = action_state.get_selected_entry(prompt_bufnr)
    actions.close(prompt_bufnr)
    window.open_floating_terminal(selection.value)
end

local function tools_picker(opts)
    opts = opts or {}

    local tools = config.values.tools
    if #tools == 0 then
        vim.notify("No tools configured in TUI Terminal", vim.log.levels.WARN)
        return
    end

    pickers.new(opts, {
        prompt_title = "TUI Tools",
        finder = finders.new_table({
            results = tools,
            entry_maker = function(tool)
                return {
                    value = tool,
                    display = tool.name,
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

return require("telescope").register_extension({
    exports = {
        tui_terminal = tools_picker
    },
})