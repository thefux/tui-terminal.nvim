local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local api = vim.api

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

local function detached_picker(opts)
    opts = opts or {}
    
    -- Ensure detached_buffers exists and is valid
    local detached = config.values.detached_buffers or {}

    -- Filter out invalid buffers
    local valid_detached = {}
    for _, stored in ipairs(detached) do
        if vim.api.nvim_buf_is_valid(stored.buf) then
            table.insert(valid_detached, stored)
        end
    end

    -- Update the stored list
    config.values.detached_buffers = valid_detached

    if #valid_detached == 0 then
        vim.notify("No detached TUI Terminal buffers", vim.log.levels.INFO)
        return
    end
    
    pickers.new(opts, {
        prompt_title = "Detached TUI Terminals",
        finder = finders.new_table({
            results = valid_detached,
            entry_maker = function(stored)
                local time_str = os.date("%H:%M:%S", stored.time)
                return {
                    value = stored,
                    display = string.format("%s (%s) - %s", 
                        stored.name, stored.cmd, time_str),
                    ordinal = stored.name,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry(prompt_bufnr)
                actions.close(prompt_bufnr)
                window.restore_detached_buffer(selection.value)
            end)
            return true
        end,
    }):find()
end

return require("telescope").register_extension({
    exports = {
        -- Main picker for tools
        tools = tools_picker,
        -- Picker for detached buffers
        detached = detached_picker
    },
})