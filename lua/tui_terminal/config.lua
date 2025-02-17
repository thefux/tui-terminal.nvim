local M = {}

-- Deep copy a table
local function deep_copy(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local res = {}
    for k, v in pairs(tbl) do
        res[k] = deep_copy(v)
    end
    return res
end

-- Merge tool configurations, excluding the name field
local function merge_tool_config(target, source)
    if not source then return target end
    local result = deep_copy(target)

    for k, v in pairs(source) do
        if k ~= "name" and k ~= "inherit" then
            -- Only set value if it doesn't exist in target
            if result[k] == nil then
                result[k] = deep_copy(v)
            elseif type(v) == "table" and type(result[k]) == "table" then
                -- For tables, merge only missing keys
                for subk, subv in pairs(v) do
                    if result[k][subk] == nil then
                        result[k][subk] = deep_copy(subv)
                    end
                end
            end
        end
    end

    return result
end

-- Process tool inheritance
local function process_inheritance(tools)
    local processed = {}
    local tool_map = {}

    -- First pass: create tool map
    for _, tool in ipairs(tools) do
        tool_map[tool.name] = tool
    end

    -- Second pass: process inheritance
    for _, tool in ipairs(tools) do
        if not processed[tool.name] then
            local current = deep_copy(tool)

            -- Process inheritance chain
            while current.inherit do
                local parent = tool_map[current.inherit]
                if not parent then
                    error(string.format("Tool '%s' tries to inherit from non-existent tool '%s'",
                        tool.name, current.inherit))
                end

                if processed[current.inherit] then
                    current = merge_tool_config(current, processed[current.inherit])
                    break
                else
                    if parent.inherit then
                        -- Continue up the inheritance chain
                        current = merge_tool_config(current, parent)
                        current.inherit = parent.inherit
                    else
                        -- End of inheritance chain
                        current = merge_tool_config(current, parent)
                        current.inherit = nil
                    end
                end
            end

            processed[tool.name] = current
        end
    end

    -- Convert back to array
    local result = {}
    for _, tool in ipairs(tools) do
        table.insert(result, processed[tool.name])
    end

    return result
end

-- Validate tool configurations
local function validate_tools(tools)
    local names = {}
    for i, tool in ipairs(tools) do
        if not tool.name then
            error(string.format("Tool at index %d is missing a name", i))
        end

        if names[tool.name] then
            error(string.format("Duplicate tool name found: '%s'. Tool names must be unique.", tool.name))
        end

        names[tool.name] = true
    end

    -- Process inheritance after validation
    return process_inheritance(tools)
end

M.defaults = {
    -- Window dimensions as percentage of screen (0.0 to 1.0)
    width = 0.9,  -- 90% of screen width by default
    height = 0.9, -- 90% of screen height by default
    tools = {
    },
    -- Store detached buffers
    detached_buffers = {},
    -- Control whether <C-c> is mapped to close the window
    map_ctrl_c = true,
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
    -- Validate tools after merging configs
    if M.values.tools and #M.values.tools > 0 then
        M.values.tools = validate_tools(M.values.tools)
    end
end

return M
