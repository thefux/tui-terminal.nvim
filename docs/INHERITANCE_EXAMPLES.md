# 🧬 Advanced Inheritance Examples

## 🤖 [Goose](https://github.com/block/goose) Configuration

Here's a real-world example of using inheritance to manage goose's different AI providers:

```lua
{
    -- Base configuration for Goose AI Assistant
    name = "goose",
    cmd = "goose",
    args = {
        default = "session",
        prompt = false,
    },
    quit_key = false,
    detach = true,
    pre_cmd = { -- Script with arguments
        script = "~/.config/nvim/config/goose.sh",
        args = "activate developer computercontroller deactivate memory"
    },
    env = {
        set = {
            GOOSE_PROVIDER = "ollama",
            GOOSE_MODEL = "llama3.2:latest",
            OLLAMA_HOST = "http://localhost:11434",
        },
    },
},
{
    -- Inherit everything from base goose but use OpenAI
    name = "gooseOpenAI",
    inherit = "goose",
    env = {
        set = {
            GOOSE_PROVIDER = "openai",
            GOOSE_MODEL = "o3-mini",
        },
    },
}
```

### 🔧 Pre-command Script

The `pre_cmd` script (`goose.sh`) manages extension configurations:

```bash
#!/bin/bash

CONFIG_FILE=~/.config/goose/config.yaml

if [ $# -lt 2 ]; then
    echo "Usage: $0 [activate|deactivate] extension_name1 [extension_name2 ...] [activate|deactivate] extension_nameN ..."
    echo "Available extensions: computercontroller, developer, memory"
    exit 1
fi

ACTION=""

for ARG in "$@"; do
    case $ARG in
        activate|deactivate)
            ACTION=$ARG
            ;;
        computercontroller|developer|memory)
            if [ -n "$ACTION" ]; then
                if [ "$ACTION" == "activate" ]; then
                    echo "Activating $ARG extension..."
                    yq -i ".extensions.$ARG.enabled = true" $CONFIG_FILE
                elif [ "$ACTION" == "deactivate" ]; then
                    echo "Deactivating $ARG extension..."
                    yq -i ".extensions.$ARG.enabled = false" $CONFIG_FILE
                fi
            else
                echo "Action not specified before extension $ARG."
                exit 1
            fi
            ;;
        *)
            echo "Invalid argument: $ARG"
            echo "Use 'activate' or 'deactivate' followed by one or more extension names."
            exit 1
            ;;
    esac
done
```

### 🎯 What Makes This Cool?

1. **Single Source of Truth**: The base `goose` configuration contains all the common settings:
   - Command and arguments
   - Detach behavior
   - Extension management script
   - Base environment setup

2. **Easy Provider Switching**: The inherited `gooseOpenAI` configuration only needs to specify what's different:
   - Changes the provider to OpenAI
   - Updates the model
   - Inherits everything else automatically

3. **Smart Extension Management**: The pre-command script:
   - Handles multiple extensions in one command
   - Supports both activation and deactivation
   - Validates inputs
   - Uses `yq` to modify YAML configs safely

4. **Maintainability**: 
   - Adding a new provider just requires inheriting from base
   - Updating common settings only needs to be done in one place
   - Script changes automatically apply to all configurations

This example shows how inheritance can make complex configurations more manageable while keeping the code DRY (Don't Repeat Yourself). 