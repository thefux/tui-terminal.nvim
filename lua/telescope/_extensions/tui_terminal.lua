return require("telescope").register_extension({
    exports = {
        -- Main picker for tools
        tools = require("telescope._extensions.tui_terminal.pickers.tools"),
        -- Picker for detached buffers
        detached = require("telescope._extensions.tui_terminal.pickers.detached")
    },
})