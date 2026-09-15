local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/scripter-sm/EliteZone/refs/heads/main/Dependencies/libraries/gui_library.lua"))()

-- unlike Linoria, Elite Zone does not put these on getgenv() - grab them off the library table instead.
local window = library:CreateWindow({
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

local tabs = {
    main = window:AddTab('main'),
}

-- groupbox and tabbox inherit the same element functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local left_groupbox = tabs.main:AddLeftGroupbox('Groupbox')

-- We can also get our Main tab via the following code:
-- local left_groupbox = window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Groupbox:AddToggle
-- Arguments: Idx, Info
left_groupbox:AddToggle('my_toggle', {
    Text = 'This is a toggle',
    Default = true,
    Tooltip = 'This is a tooltip', -- shown when you hover over the toggle

    Callback = function(value)
        print('[cb] MyToggle changed to:', value)
    end,
})

-- fetching a toggle object for later use:
-- library.Toggles.my_toggle.Value

library.Toggles.my_toggle:OnChanged(function()
    print('MyToggle changed to:', library.Toggles.my_toggle.Value)
end)

library.Toggles.my_toggle:SetValue(false)

--[[
    Groupbox:AddButton
    Arguments: {
        Text = string,
        Func = function,
        DoubleClick = boolean,
        Tooltip = string,
    }

    you can call :AddButton on a button to add a nested sub-button!
]]
local my_button = left_groupbox:AddButton({
    Text = 'Button',
    Func = function()
        print('You clicked a button!')
    end,
    DoubleClick = false,
    Tooltip = 'This is the main button',
})

my_button:AddButton({
    Text = 'Sub button',
    Func = function()
        print('You clicked a sub button!')
    end,
    DoubleClick = true, -- have to click this button twice to trigger the callback
    Tooltip = 'This is the sub button (double click me!)',
})

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap
left_groupbox:AddLabel('This is a label')
left_groupbox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- Groupbox:AddDivider
left_groupbox:AddDivider()

--[[
    Groupbox:AddSlider
    Arguments: Idx, SliderInfo

    Text, Default, Min, Max, Rounding must be specified.
    Suffix, Increment and Compact are optional.
]]
left_groupbox:AddSlider('my_slider', {
    Text = 'This is my slider!',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,

    Callback = function(value)
        print('[cb] MySlider was changed! New value:', value)
    end,
})

library.Options.my_slider:OnChanged(function()
    print('MySlider was changed! New value:', library.Options.my_slider.Value)
end)

library.Options.my_slider:SetValue(3)

-- Groupbox:AddInput
left_groupbox:AddInput('my_textbox', {
    Default = 'My textbox!',
    Numeric = false,
    Finished = false, -- only calls callback when you press enter

    Text = 'This is a textbox',
    Tooltip = 'This is a tooltip',
    Placeholder = 'Placeholder text',

    Callback = function(value)
        print('[cb] Text updated. New text:', value)
    end,
})

library.Options.my_textbox:OnChanged(function()
    print('Text updated. New text:', library.Options.my_textbox.Value)
end)

-- Groupbox:AddDropdown
left_groupbox:AddDropdown('my_dropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1, -- number index of the value / string
    Multi = false,

    Text = 'A dropdown',
    Tooltip = 'This is a tooltip',

    Callback = function(value)
        print('[cb] Dropdown got changed. New value:', value)
    end,
})

library.Options.my_dropdown:OnChanged(function()
    print('Dropdown got changed. New value:', library.Options.my_dropdown.Value)
end)

library.Options.my_dropdown:SetValue('This')

-- multi dropdowns
left_groupbox:AddDropdown('my_multi_dropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = true,

    Text = 'A multi dropdown',
    Tooltip = 'This is a tooltip',

    Callback = function(value)
        print('[cb] Multi dropdown got changed:', value)
    end,
})

library.Options.my_multi_dropdown:OnChanged(function()
    print('Multi dropdown got changed:')
    for key, value in next, library.Options.my_multi_dropdown.Value do
        print(key, value) -- e.g. This, true
    end
end)

library.Options.my_multi_dropdown:SetValue({
    This = true,
    is = true,
})

-- Label:AddColorPicker / Toggle:AddColorPicker
-- you can attach a ColorPicker (and a KeyPicker) to a Label or a Toggle
left_groupbox:AddLabel('Color'):AddColorPicker('color_picker', {
    Default = Color3.new(0, 1, 0),
    Title = 'Some color', -- custom title shown when the picker is opened
    Transparency = 0, -- omit to disable transparency changing

    Callback = function(value)
        print('[cb] Color changed!', value)
    end,
})

library.Options.color_picker:OnChanged(function()
    print('Color changed!', library.Options.color_picker.Value)
    print('Transparency changed!', library.Options.color_picker.Transparency)
end)

library.Options.color_picker:SetValueRGB(Color3.fromRGB(0, 255, 140))

-- Label:AddKeyPicker
left_groupbox:AddLabel('Keybind'):AddKeyPicker('key_picker', {
    -- SyncToggleState only works when attached to a toggle - it keeps the keybind
    -- state and the toggle state in sync (e.g. a keybind used to toggle flyhack).
    Default = '...',
    SyncToggleState = false,

    Mode = 'Always', -- Modes: Always, Toggle, Hold

    Text = 'keybind test',
    NoUI = false, -- hide from the keybind menu

    Callback = function(value) -- fired when the keybind is pressed, Value is true/false
        print('someone clicked the keybind', value)
    end,

    ChangedCallback = function(new) -- fired when the bound key itself changes
        print('why did u changed keybind bro', new)
    end,
})

library.Options.key_picker:OnClick(function()
    print('umm u clicked keybind?', library.Options.key_picker:GetState())
end)

library.Options.key_picker:OnChanged(function()
    print('why did u changed keybind bro', library.Options.key_picker.Value)
end)

library.Options.key_picker:SetValue({ '...', 'Toggle' })

-- long text label to demonstrate UI scrolling behaviour.
local left_groupbox2 = tabs.main:AddLeftGroupbox('Groupbox #2')
left_groupbox2:AddLabel('Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\n\n\n\n\n\n\nHello from below!', true)

-- tabboxes work the same as groupboxes, except you call the element functions on Tabbox:AddTab(name)
local tab_box = tabs.main:AddRightTabbox()

local tab1 = tab_box:AddTab('Tab 1')
tab1:AddToggle('tab1_toggle', { Text = 'Tab1 Toggle' })

local tab2 = tab_box:AddTab('Tab 2')
tab2:AddToggle('tab2_toggle', { Text = 'Tab2 Toggle' })

-- dependency boxes let you show/hide elements depending on another element's state.
-- e.g. a 'Feature Enabled' toggle, and you only want to show its sliders/dropdowns while it's enabled.
local right_groupbox = tabs.main:AddRightGroupbox('Groupbox #3')
right_groupbox:AddToggle('control_toggle', { Text = 'Dependency box toggle' })

local depbox = right_groupbox:AddDependencyBox()
depbox:AddDropdown('depbox_dropdown', { Text = 'Dropdown', Default = 1, Values = { 'a', 'b', 'c' } })
depbox:AddToggle('depbox_toggle', { Text = 'Sub-dependency box toggle' })

-- dependency boxes nest fine - a nested box automatically also depends on its parent box being visible
local sub_depbox = depbox:AddDependencyBox()
sub_depbox:AddSlider('depbox_slider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 })

depbox:SetupDependencies({
    { library.Toggles.control_toggle, true }, -- pass `false` if a feature should only show when the toggle is off
})

sub_depbox:SetupDependencies({
    { library.Options.depbox_dropdown, 'b' }, -- dependencies can also key off a dropdown's value
    { library.Toggles.depbox_toggle, true },
})

-- a dependency box can also key directly off a dropdown, with no toggle involved
right_groupbox:AddDropdown('mode_dropdown', { Text = 'Mode', Default = 1, Values = { 'basic', 'advanced' } })

local advanced_depbox = right_groupbox:AddDependencyBox()
advanced_depbox:AddSlider('advanced_slider', { Text = 'Advanced slider', Default = 0, Min = 0, Max = 10, Rounding = 0 })

advanced_depbox:SetupDependencies({
    { library.Options.mode_dropdown, 'advanced' },
})


--[[
example of a watermark

library:SetWatermarkVisibility(true)
local frame_timer = tick()
local frame_counter = 0
local fps = 60

game:GetService('RunService').RenderStepped:Connect(function()
    frame_counter += 1

    if (tick() - frame_timer) >= 1 then
        fps = frame_counter
        frame_timer = tick()
        frame_counter = 0
    end

    library:SetWatermark(('Example Hub | %s fps | %s ms'):format(
        math.floor(fps),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)
]]

library:Notify('Library Example Loaded', 5)

library.KeybindFrame.Visible = true

-- Library:SetFolder sets where config, theme and cache is created.
library:SetFolder('Example Hub')

-- ignore keys that are used by ThemeManager - we don't want configs saving themes.
library.SaveManager:IgnoreThemeSettings()

--[[
   ignore our menu keybind too - probably don't want every config using a different menu key.
   library.SaveManager:SetIgnoreIndexes({ 'menu_keybind' }) 
   commented out because i switched to "library.SaveManager:BuildConfigTab(window)" rather than custom tab, but using method u can make config ignore some stuff.
]]

library.ThemeManager:ApplyToWindow(window)
library.SaveManager:BuildConfigTab(window)

-- loads the config marked to autoload, if any
library.SaveManager:LoadAutoloadConfig()
