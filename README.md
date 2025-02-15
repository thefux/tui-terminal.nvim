# 🪟 TUI Terminal

A Neovim plugin that makes your terminal UI applications float like a butterfly and look pretty doing it!

## 🦋 Why TUI Terminal?

Ever wanted your terminal applications to float gracefully above your code like a majestic butterfly? Well, now they can! TUI Terminal creates a beautiful floating window for your favorite terminal UI applications.

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
            name = "custom-grep",
            cmd = "rg",
            args = {
                default = "--color=always --line-number",  -- Default arguments
                prompt = true,  -- Will prompt for additional arguments
            },
        },
        {
            name = "dev-tool",
            cmd = "tool",
            pre_cmd = "~/.config/test.sh",  -- Run setup script before the command
            args = {
                default = "--dev",
                prompt = true,
            },
            env = {
                set = {
                    NODE_ENV = "development",
                    DEBUG = "1",
                },
                unset = {
                    PRODUCTION = true,
                }
            },
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
        {
            name = "dev-server",
            cmd = "npm run dev",
            env = {
                set = {
                    NODE_ENV = "development",
                    PORT = "3000",
                    DEBUG = "1",
                },
                unset = {
                    PRODUCTION = true,
                    CACHE = true,
                }
            }
        },
        {
            name = "dev-env",
            cmd = "npm start",
            pre_cmd = {
                script = "~/.config/test.sh",
                args = "--env development --setup-db"
            },
            env = {
                set = {
                    NODE_ENV = "development"
                }
            }
        },
        {
            name = "custom-env",
            cmd = "myapp",
            pre_cmd = "export CUSTOM_VAR=value && source ~/.env",  -- Inline commands
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
   :Telescope tui_terminal tools
   :Telescope tui_terminal detached  # List detached buffers
   ```

4. Open a tool with arguments:

   ```vim
   :TuiTerminal custom-grep
   " > Additional arguments: search_term *.lua
   ```

## ⌨️ Default Keymaps

- `<Esc>` - Passes through to the terminal application
- `hjkl` - Arrow key navigation (when vim_navigation is true)
- `<C-c>` - Force close the floating window (will not detach)
- `q` - Close the floating window (when quit_key is true)
- `<C-d>` - Detach the window (keep buffer running in background)
- `<A-n>` - Cycle to next floating window
- `<A-p>` - Cycle to previous floating window

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

           -- Tool with custom environment
           {
               name = "dev-server",
               cmd = "npm run dev",
               env = {
                   set = {
                       NODE_ENV = "development",
                       PORT = "3000",
                       DEBUG = "1",
                   },
                   unset = {
                       PRODUCTION = true,
                       CACHE = true,
                   }
               }
           },
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

## 🧬 Don't Repeat Yourself: Tool Inheritance

You can create base configurations and inherit from them to avoid repetition:

💡 Check out [INHERITANCE_EXAMPLES.md](./docs/INHERITANCE_EXAMPLES.md) for more advanced inheritance examples!

```lua
require("tui_terminal").setup({
    tools = {
        -- Base configuration for Node.js tools
        {
            name = "node-base",
            env = {
                set = {
                    NODE_ENV = "development",
                    DEBUG = "1"
                }
            },
            pre_cmd = {
                script = "~/.config/nvim/scripts/node-setup.sh",
                args = "--env dev"
            }
        },

        -- Inherit environment and pre-command from node-base
        {
            name = "dev-server",
            inherit = "node-base",  -- Inherit from node-base
            cmd = "npm run dev",
            args = {
                default = "--port 3000"  -- Add specific arguments
            }
        },

        -- Base configuration for Python tools
        {
            name = "python-base",
            env = {
                set = {
                    PYTHONPATH = "./src",
                    PYTHONUNBUFFERED = "1"
                }
            },
            pre_cmd = "source .venv/bin/activate"
        },

        -- Multiple tools can inherit from the same base
        {
            name = "pytest",
            inherit = "python-base",
            cmd = "pytest",
            args = {
                default = "-v",
                prompt = true
            }
        },
        {
            name = "flask-dev",
            inherit = "python-base",
            cmd = "flask run",
            env = {
                set = {
                    FLASK_ENV = "development"  -- Merge with inherited env
                }
            }
        }
    }
})
```

### Inheritance Rules:

- The `name` field is never inherited
- Child configurations override parent configurations
- For nested tables (like `env.set`), child values are merged with parent values
- You can inherit from any tool defined before the current one
- Multiple tools can inherit from the same base configuration
- Base configurations don't need to have a `cmd` field if they're just for inheritance

This feature is particularly useful for:

- Sharing common environment variables
- Reusing setup scripts
- Maintaining consistent configurations across similar tools
- Creating template configurations for different types of tools

## 🐛 Troubleshooting

If your terminal isn't floating:

1. Check if you're running Neovim 0.5+
2. Make sure gravity is working in your area
3. Ensure your computer isn't upside down

---

Made with 🦋 by a developer and their AI companion who think terminals should float like butterflies!
