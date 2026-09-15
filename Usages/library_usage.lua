local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/scripter-sm/EliteZone/refs/heads/main/Dependencies/libraries/gui_library.lua"))()

-- unlike Linoria, Elite Zone does not put these on getgenv() - grab them off the library table instead.
local Toggles = Library.Toggles
local Options = Library.Options
local SaveManager = Library.SaveManager
local ThemeManager = Library.ThemeManager

local Window = Library:CreateWindow({
    --[[ 
         Position and Size are also valid options here,
         but you do not need to define them unless you are changing them.
    ]]

    Title = 'Example Hub',
    Game = 'Global', -- used for the per-game configs subfolder, savemanager saves folders like this Title/Game/configs and themes like this Title/themes.
    Center = true, --set Center to true, if u want the menu to appear in the center.
    AutoShow = true, --set AutoShow to true, if you want the menu to appear when ever script is runned. if not enabled than you gotta toggle menu through keybind or icon on mobile.
  --TabPadding = 8,
  --MenuFadeTime = 0.2,
})

--[[
   callback note:
   passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
   however, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the recommended way to do this.
   i strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.
]]

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- groupbox and tabbox inherit the same element functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

-- We can also get our Main tab via the following code:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Groupbox:AddToggle
-- Arguments: Idx, Info
LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Default = true,
    Tooltip = 'This is a tooltip', -- shown when you hover over the toggle

    Callback = function(Value)
        print('[cb] MyToggle changed to:', Value)
    end,
})

-- Fetching a toggle object for later use:
-- Toggles.MyToggle.Value

Toggles.MyToggle:OnChanged(function()
    print('MyToggle changed to:', Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(false)

--[[
    Groupbox:AddButton
    Arguments: {
        Text = string,
        Func = function,
        DoubleClick = boolean,
        Tooltip = string,
    }

    You can call :AddButton on a button to add a nested sub-button!
]]
local MyButton = LeftGroupBox:AddButton({
    Text = 'Button',
    Func = function()
        print('You clicked a button!')
    end,
    DoubleClick = false,
    Tooltip = 'This is the main button',
})

MyButton:AddButton({
    Text = 'Sub button',
    Func = function()
        print('You clicked a sub button!')
    end,
    DoubleClick = true, -- have to click this button twice to trigger the callback
    Tooltip = 'This is the sub button (double click me!)',
})

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap
LeftGroupBox:AddLabel('This is a label')
LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- Groupbox:AddDivider
LeftGroupBox:AddDivider()

--[[
    Groupbox:AddSlider
    Arguments: Idx, SliderInfo

    Text, Default, Min, Max, Rounding must be specified.
    Suffix, Increment and Compact are optional.
]]
LeftGroupBox:AddSlider('MySlider', {
    Text = 'This is my slider!',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        print('[cb] MySlider was changed! New value:', Value)
    end,
})

Options.MySlider:OnChanged(function()
    print('MySlider was changed! New value:', Options.MySlider.Value)
end)

Options.MySlider:SetValue(3)

-- Groupbox:AddInput
LeftGroupBox:AddInput('MyTextbox', {
    Default = 'My textbox!',
    Numeric = false,
    Finished = false, -- only calls callback when you press enter

    Text = 'This is a textbox',
    Tooltip = 'This is a tooltip',
    Placeholder = 'Placeholder text',

    Callback = function(Value)
        print('[cb] Text updated. New text:', Value)
    end,
})

Options.MyTextbox:OnChanged(function()
    print('Text updated. New text:', Options.MyTextbox.Value)
end)

-- Groupbox:AddDropdown
LeftGroupBox:AddDropdown('MyDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1, -- number index of the value / string
    Multi = false,

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip',

    Callback = function(Value)
        print('[cb] Dropdown got changed. New value:', Value)
    end,
})

Options.MyDropdown:OnChanged(function()
    print('Dropdown got changed. New value:', Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue('This')

-- Multi dropdowns
LeftGroupBox:AddDropdown('MyMultiDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = true,

    Text = 'A multi dropdown',
    Tooltip = 'This is a tooltip',

    Callback = function(Value)
        print('[cb] Multi dropdown got changed:', Value)
    end,
})

Options.MyMultiDropdown:OnChanged(function()
    print('Multi dropdown got changed:')
    for key, value in next, Options.MyMultiDropdown.Value do
        print(key, value) -- e.g. This, true
    end
end)

Options.MyMultiDropdown:SetValue({
    This = true,
    is = true,
})

-- Special dropdowns fetch and keep their own value list updated (e.g. player list)
LeftGroupBox:AddDropdown('MyPlayerDropdown', {
    SpecialType = 'Player',
    Text = 'A player dropdown',
    Tooltip = 'This is a tooltip',

    Callback = function(Value)
        print('[cb] Player dropdown got changed:', Value)
    end,
})

-- Label:AddColorPicker / Toggle:AddColorPicker
-- You can attach a ColorPicker (and a KeyPicker) to a Label or a Toggle
LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0),
    Title = 'Some color', -- custom title shown when the picker is opened
    Transparency = 0, -- omit to disable transparency changing

    Callback = function(Value)
        print('[cb] Color changed!', Value)
    end,
})

Options.ColorPicker:OnChanged(function()
    print('Color changed!', Options.ColorPicker.Value)
    print('Transparency changed!', Options.ColorPicker.Transparency)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

-- Label:AddKeyPicker
LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
    -- SyncToggleState only works when attached to a toggle - it keeps the keybind
    -- state and the toggle state in sync (e.g. a keybind used to toggle flyhack).
    Default = 'MB2',
    SyncToggleState = false,

    Mode = 'Toggle', -- Modes: Always, Toggle, Hold

    Text = 'Auto lockpick safes',
    NoUI = false, -- hide from the keybind menu

    Callback = function(Value) -- fired when the keybind is pressed, Value is true/false
        print('[cb] Keybind clicked!', Value)
    end,

    ChangedCallback = function(New) -- fired when the bound key itself changes
        print('[cb] Keybind changed!', New)
    end,
})

Options.KeyPicker:OnClick(function()
    print('Keybind clicked!', Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
    print('Keybind changed!', Options.KeyPicker.Value)
end)

Options.KeyPicker:SetValue({ 'MB2', 'Toggle' })

-- Long text label to demonstrate UI scrolling behaviour.
local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Groupbox #2')
LeftGroupBox2:AddLabel('Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!', true)

-- Tabboxes work the same as Groupboxes, except you call the element functions on Tabbox:AddTab(name)
local TabBox = Tabs.Main:AddRightTabbox()

local Tab1 = TabBox:AddTab('Tab 1')
Tab1:AddToggle('Tab1Toggle', { Text = 'Tab1 Toggle' })

local Tab2 = TabBox:AddTab('Tab 2')
Tab2:AddToggle('Tab2Toggle', { Text = 'Tab2 Toggle' })

-- Dependency boxes let you show/hide elements depending on another element's state.
-- e.g. a 'Feature Enabled' toggle, and you only want to show its sliders/dropdowns while it's enabled.
local RightGroupbox = Tabs.Main:AddRightGroupbox('Groupbox #3')
RightGroupbox:AddToggle('ControlToggle', { Text = 'Dependency box toggle' })

local Depbox = RightGroupbox:AddDependencyBox()
Depbox:AddDropdown('DepboxDropdown', { Text = 'Dropdown', Default = 1, Values = { 'a', 'b', 'c' } })
Depbox:AddToggle('DepboxToggle', { Text = 'Sub-dependency box toggle' })

-- Dependency boxes nest fine - a nested box automatically also depends on its parent box being visible
local SubDepbox = Depbox:AddDependencyBox()
SubDepbox:AddSlider('DepboxSlider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 })

Depbox:SetupDependencies({
    { Toggles.ControlToggle, true }, -- pass `false` if a feature should only show when the toggle is off
})

SubDepbox:SetupDependencies({
    { Options.DepboxDropdown, 'b' }, -- dependencies can also key off a dropdown's value
    { Toggles.DepboxToggle, true },
})

-- Library functions
Library:SetWatermarkVisibility(true)

-- Example of a dynamically-updating watermark with fps and ping
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    Library:SetWatermark(('Elite Zone demo | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library:Notify('Elite Zone example script loaded', 5)

Library.KeybindFrame.Visible = true

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- gives the menu a custom open/close keybind

-- SaveManager (configs) and ThemeManager (themes) are already wired to this window,
-- no addon loading or SetLibrary calls needed - just set the folder they should save into.

-- Library:SetFolder changes where BOTH the config and theme folders are created.
-- This example creates: "Elite Zone/global/configs/" and "Elite Zone/themes/"
Library:SetFolder('Elite Zone')

-- Ignore keys that are used by ThemeManager - we don't want configs saving themes.
SaveManager:IgnoreThemeSettings()

-- Ignore our menu keybind too - probably don't want every config using a different menu key.
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- Builds the config section (create/load/save/delete/autoload/import/export) on this tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds the theme section (built-in themes + custom theme saving) on this tab
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Loads the config marked to autoload, if any
SaveManager:LoadAutoloadConfig()
