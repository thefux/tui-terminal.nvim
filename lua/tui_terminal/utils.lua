local config = require('tui_terminal.config')

local M = {}

function M.store_detached_buffer(buf, tool)
    config.values.detached_buffers = config.values.detached_buffers or {}

    for _, stored in ipairs(config.values.detached_buffers) do
        if stored.buf == buf then
            return
        end
    end

    table.insert(config.values.detached_buffers, {
        buf = buf,
        tool = tool,
        name = tool.name,
        cmd = tool.cmd,
        time = os.time(),
    })
end

function M.remove_detached_buffer(buf)
    config.values.detached_buffers = config.values.detached_buffers or {}

    for i, stored in ipairs(config.values.detached_buffers) do
        if stored.buf == buf then
            table.remove(config.values.detached_buffers, i)
            break
        end
    end
end

return M
