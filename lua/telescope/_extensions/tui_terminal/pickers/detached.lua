local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local api = vim.api

local window = require("tui_terminal.window")
local config = require("tui_terminal.config")

local term_previewer = require("telescope.previewers").new_buffer_previewer({
    title = "Terminal Preview",
    get_buffer_by_name = function(_, entry)
        return entry.value.buf
    end,
    define_preview = function(self, entry)
        local buf = entry.value.buf
        if api.nvim_buf_is_valid(buf) then
            vim.bo[self.state.bufnr].modifiable = true

            api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {})

            local metadata = {
                string.format("Terminal: %s", entry.value.name),
                string.format("Command: %s", entry.value.cmd),
                string.format("Detached at: %s", os.date("%H:%M:%S", entry.value.time)),
                string.rep("-", 40),
                ""
            }
            api.nvim_buf_set_lines(self.state.bufnr, 0, 0, false, metadata)

            local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
            local preview_lines = {}
            local start_idx = #lines > 30 and #lines - 30 or 1
            for i = start_idx, #lines do
                table.insert(preview_lines, lines[i])
            end

            api.nvim_buf_set_lines(self.state.bufnr, -1, -1, false, preview_lines)

            vim.bo[self.state.bufnr].filetype = "terminal"
            vim.bo[self.state.bufnr].modifiable = false
        end
    end
})

return function(opts)
    opts = opts or {}

    local detached = config.values.detached_buffers or {}

    local valid_detached = {}
    for _, stored in ipairs(detached) do
        if vim.api.nvim_buf_is_valid(stored.buf) then
            table.insert(valid_detached, stored)
        end
    end

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
        previewer = term_previewer,
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
