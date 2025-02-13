# 🪟 TUI Terminal

A Neovim plugin that makes your terminal UI applications float like a butterfly and look pretty doing it!

## 🦋 Why TUI Terminal?

Ever wanted your terminal applications to float gracefully above your code like a majestic butterfly? Well, now they can! TUI Terminal creates a beautiful floating window for your favorite terminal UI applications.

> Q: Why did the TUI terminal float?
>
> A: Because it refused to sink to the bottom of the screen! 🥁

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "yourusername/tui_terminal.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim", -- Optional: for tool selection
    },
    config = function()
        require("tui_terminal").setup({
            -- your configuration here
        })
        -- Optional: Setup telescope extension
        require("telescope").load_extension("tui_terminal")
    end
}
```

## ⚙️ Configuration

Here's a sample configuration with all the bells and whistles:

```lua
require("tui_terminal").setup({
    -- Window dimensions (0.0 - 1.0)
    width = 0.8,   -- 80% of screen width
    height = 0.8,  -- 80% of screen height

    -- Configure your TUI tools
    tools = {
        {
            name = "glim",    -- Tool identifier
            cmd = "glim",     -- Both vim_navigation and quit_key default to true
        },
        {
            name = "htop",
            cmd = "htop",
            vim_navigation = false,   -- Disable vim navigation for native key handling
        },
        {
            name = "lazygit",
            cmd = "lazygit",
            vim_navigation = false,
            quit_key = false,        -- Disable 'q' as lazygit uses it
            detach = true,          -- Enable detaching by default (can still force close with <C-c>)
        },
        {
            name = "nu",
            cmd = "nu",
            vim_navigation = false,
            quit_key = false,        -- Let 'q' pass through to nu shell
        },
    },

    -- Window border (any valid Neovim border)
    border = {
        type = "rounded",  -- "none", "single", "double", "rounded", "solid", "shadow"
        -- Or use custom border characters
        -- type = "custom",
        -- chars = {
        --     top_left = "╭",
        --     top = "─",
        --     top_right = "╮",
        --     right = "│",
        --     bottom_right = "╯",
        --     bottom = "─",
        --     bottom_left = "╰",
        --     left = "│",
        -- }
    }
})
```

## 🎮 Usage

1. Open with the first configured tool:

   ```vim
   :TuiTerminal
   ```

> If Telescope is installed, this will open a picker to select from your configured tools

2. Open a specific configured tool:

   ```vim
   :TuiTerminal lazygit
   ```

3. Open Telescope picker directly:

   ```vim
   :Telescope tui_terminal
   :Telescope tui_terminal_detached  # List detached buffers
   ```

## ⌨️ Default Keymaps

- `<Esc>` - Passes through to the terminal application
- `hjkl` - Arrow key navigation (when vim_navigation is true)
- `<C-c>` - Force close the floating window (will not detach)
- `q` - Close the floating window (when quit_key is true)
- `<C-d>` - Detach the window (keep buffer running in background)

> Q: What's a terminal's favorite dance move?
>
> A: The float! 💃

## 🎨 Customization Tips

1. **Configure Multiple Tools:**

   ```lua
   require("tui_terminal").setup({
       tools = {
           -- Tools that work better with vim navigation
           { name = "glim", cmd = "glim" },     -- Both vim_navigation and quit_key are true by default
           { name = "btop", cmd = "btop" },     -- Uses all default settings

           -- Tools that need their native key bindings (including 'q')
           { name = "lazygit", cmd = "lazygit", vim_navigation = false, quit_key = false },
           { name = "k9s", cmd = "k9s", vim_navigation = false, quit_key = false },
       }
   })
   ```

2. **Window Size:**

   ```lua
   require("tui_terminal").setup({
       width = 0.9,   -- 90% of screen width
       height = 0.9,  -- 90% of screen height
   })
   ```

3. **Custom Border:**
   ```lua
   require("tui_terminal").setup({
       border = {
           type = "custom",
           chars = {
               top_left = "╔",
               top = "═",
               top_right = "╗",
               right = "║",
               bottom_right = "╝",
               bottom = "═",
               bottom_left = "╚",
               left = "║",
           }
       }
   })
   ```

## 🐛 Troubleshooting

If your terminal isn't floating:

1. Check if you're running Neovim 0.5+
2. Make sure gravity is working in your area
3. Ensure your computer isn't upside down

---

Made with 🦋 by a developer who thinks terminals should float like butterflies!
