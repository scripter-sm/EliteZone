-- Elite Zone GUI Library Usage Example
-- This demonstrates how to use the Elite Zone GUI library

-- Load the GUI library from GitHub
local EZ = loadstring(game:HttpGet("https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/libraries/gui.lua", true))()

-- Set custom script name (optional)
EZ.script_name = "MyScript"

-- Initialize the GUI
EZ:Load()

-- Create a simple toggle example
local my_module = EZ.Categories.Combat:CreateModule({
    Name = "Auto Farm",
    Function = function(enabled)
        print("Auto Farm is", enabled and "enabled" or "disabled")
    end
})

-- Add a toggle to the module
my_module:CreateToggle({
    Name = "Auto Collect",
    Default = true,
    Function = function(enabled)
        print("Auto Collect is", enabled and "enabled" or "disabled")
    end
})

-- Add a slider
my_module:CreateSlider({
    Name = "Speed",
    Min = 1,
    Max = 10,
    Default = 5,
    Function = function(value)
        print("Speed set to", value)
    end
})

-- Add a keybind
my_module:CreateBind({
    Name = "Toggle Key",
    Default = {"RightControl"},
    NoRemove = true
})

-- Save the config
EZ:Save()

-- Access paths
print("Config path:", EZ.config_path)
print("Cache path:", EZ.cache_path)
print("Themes path:", EZ.themes_path)

-- Set autoload configuration
EZ.autoload_data.autoload_config = "my_config"
EZ.autoload_data.autoload_theme = "dark_theme"
EZ:LoadAutoload(EZ.autoload_data)

print("GUI loaded successfully!")