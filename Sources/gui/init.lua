addMaid(EZ)
gui = Instance.new('ScreenGui')
gui.Name = randomString()
gui.DisplayOrder = 9999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.IgnoreGuiInset = true

if EZ.ThreadFix then
	local holder = Instance.new('Folder')
	holder.Parent = cloneref(game:GetService('CoreGui'))
	gui.OnTopOfCoreBlur = true
	gui.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'))
	EZ.holder = holder
else
	gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
	gui.ResetOnSpawn = false
	EZ.holder = gui
end
EZ.gui = gui

scaledgui = Instance.new('Frame')
scaledgui.BackgroundTransparency = 1
scaledgui.Name = 'ScaledGui'
scaledgui.Size = UDim2.fromScale(1, 1)
scaledgui.Parent = gui
clickgui = Instance.new('Frame')
clickgui.BackgroundTransparency = 1
clickgui.Name = 'ClickGui'
clickgui.Size = UDim2.fromScale(1, 1)
clickgui.Visible = false
clickgui.Parent = scaledgui
local scarcitybanner = Instance.new('TextLabel')
scarcitybanner.BackgroundTransparency = 1
scarcitybanner.FontFace = uipallet.Font
scarcitybanner.Position = UDim2.fromScale(0, 0.97)
scarcitybanner.Size = UDim2.fromScale(1, 0.02)
scarcitybanner.Text = 'The discord link has been fixed, click the discord icon to join.'
scarcitybanner.TextColor3 = Color3.new(1, 1, 1)
scarcitybanner.TextScaled = true
scarcitybanner.TextStrokeTransparency = 0.5
scarcitybanner.Parent = clickgui
local modal = Instance.new('TextButton')
modal.BackgroundTransparency = 1
modal.Modal = true
modal.Text = ''
modal.Parent = clickgui
local cursor = Instance.new('ImageLabel')
cursor.BackgroundTransparency = 1
cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
cursor.Size = UDim2.fromOffset(64, 64)
cursor.Visible = false
cursor.Parent = gui
notifications = Instance.new('Folder')
notifications.Name = 'Notifications'
notifications.Parent = scaledgui
tooltip = Instance.new('TextLabel')
tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
tooltip.FontFace = uipallet.Font
tooltip.Position = UDim2.fromScale(-1, -1)
tooltip.RichText = true
tooltip.Text = ''
tooltip.TextColor3 = color.Dark(uipallet.Text, 0.16)
tooltip.TextSize = 12
tooltip.Visible = false
tooltip.ZIndex = 5
tooltip.Parent = scaledgui
toolblur = addBlur(tooltip)
addCorner(tooltip)
scale = Instance.new('UIScale')
scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
scale.Parent = scaledgui
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
components.GUI({})

EZ:CreateCategory({
	Name = 'Combat',
	Icon = get_ez_asset('Elite Zone/Assets/combat.png'),
	Size = UDim2.fromOffset(13, 14)
})
EZ:CreateCategory({
	Name = 'Blatant',
	Icon = get_ez_asset('Elite Zone/Assets/blatant.png'),
	Size = UDim2.fromOffset(14, 14)
})
EZ:CreateCategory({
	Name = 'Render',
	Icon = get_ez_asset('Elite Zone/Assets/render.png'),
	Size = UDim2.fromOffset(15, 14)
})
EZ:CreateCategory({
	Name = 'Utility',
	Icon = get_ez_asset('Elite Zone/Assets/utility.png'),
	Size = UDim2.fromOffset(15, 14)
})
EZ:CreateCategory({
	Name = 'World',
	Icon = get_ez_asset('Elite Zone/Assets/world.png'),
	Size = UDim2.fromOffset(14, 14)
})
EZ:CreateCategory({
	Name = 'Inventory',
	Icon = get_ez_asset('Elite Zone/Assets/inventory.png'),
	Size = UDim2.fromOffset(15, 14)
})
EZ.Categories.Main:CreateDivider({
	Text = 'misc'
})

do
	local friends
	local friendscolor = {
		Hue = 1,
		Sat = 1,
		Value = 1
	}

	friends = EZ:CreateCategoryList({
		Name = 'Friends',
		Icon = get_ez_asset('Elite Zone/Assets/friends.png'),
		Size = UDim2.fromOffset(17, 16),
		Placeholder = 'Roblox username',
		Color = Color3.fromRGB(5, 134, 105),
		Function = function()
			friends.Update:Fire()
			friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
		end
	})
	friends.Update = Instance.new('BindableEvent')
	friends.ColorUpdate = Instance.new('BindableEvent')
	friends:CreateToggle({
		Name = 'Recolor visuals',
		Darker = true,
		Default = true,
		Function = function()
			friends.Update:Fire()
			friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
		end
	})
	friendscolor = friends:CreateColorSlider({
		Name = 'Friends color',
		Darker = true,
		Function = function(hue, sat, val)
			for _, v in friends.Object.Children:GetChildren() do
				local dot = v:FindFirstChild('Dot')
				if dot and dot.BackgroundColor3 ~= color.Light(uipallet.Main, 0.37) then
					dot.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
					dot.Dot.BackgroundColor3 = dot.BackgroundColor3
				end
			end

			friends.ColorUpdate:Fire(hue, sat, val)
		end
	})
	friends:CreateToggle({
		Name = 'Use friends',
		Darker = true,
		Default = true,
		Function = function()
			friends.Update:Fire()
			friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
		end
	})
	EZ:Clean(friends.Update)
	EZ:Clean(friends.ColorUpdate)
end

EZ:CreateCategoryList({
	Name = 'configs',
	Icon = get_ez_asset('Elite Zone/Assets/configs.png'),
	Size = UDim2.fromOffset(17, 10),
	Position = UDim2.fromOffset(12, 16),
	Placeholder = 'Type name',
	configs = true
})

local targets
targets = EZ:CreateCategoryList({
	Name = 'Targets',
	Icon = get_ez_asset('Elite Zone/Assets/friends.png'),
	Size = UDim2.fromOffset(17, 16),
	Placeholder = 'Roblox username',
	Function = function()
		targets.Update:Fire()
	end
})
targets.Update = Instance.new('BindableEvent')
EZ:Clean(targets.Update)

components.LegitWindow()
EZ.SearchBar = components.SearchBar()
EZ.Categories.Main:CreateOverlayBar()

local general = EZ.Categories.Main.Settings:CreateSettingsPane({Name = 'General'})
local settingConnections = {}
EZ.MultiKeybind = general:CreateToggle({
	Name = 'Enable Multi-Keybinding',
	Tooltip = 'Allows multiple keys to be bound to a module (eg. G + H)'
})
general:CreateToggle({
	Name = 'Allow setting keybinds',
	Function = function(callback)
		if callback then
			for _, container in {EZ.Modules, EZ.Legit.Modules} do
				for _, module in container do
					for _, component in module.Options do
						if component.Type == 'Toggle' then
							local bind = components.Bind({
								Module = true
							}, nil, component)
							bind.Object.Position = UDim2.new(1, -40, 0, 5)

							table.insert(settingConnections, bind.Triggered:Connect(function(isDown)
								if bind.Hold then
									if component.Enabled ~= isDown then
										if EZ.SettingToggleNotifications.Enabled then
											EZ:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and '<font color="#00AA00">ON</font>' or '<font color="#FF5A5A">OFF</font>'), 1.5)
										end

										component:Toggle()
									end
								else
									if EZ.SettingToggleNotifications.Enabled then
										EZ:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and '<font color="#00AA00">ON</font>' or '<font color="#FF5A5A">OFF</font>'), 1.5)
									end

									component:Toggle()
								end
							end))

							table.insert(settingConnections, component.Object.MouseEnter:Connect(function()
								bind:SetVisible(true)
							end))

							table.insert(settingConnections, component.Object.MouseLeave:Connect(function()
								bind:SetVisible(false)
							end))
						end
					end
				end
			end
		else
			for _, container in {EZ.Modules, EZ.Legit.Modules} do
				for _, module in container do
					for _, component in module.Options do
						if component.Bind then
							component.Bind:Destroy()
						end
					end
				end
			end

			for _, connection in settingConnections do
				connection:Disconnect()
			end
			table.clear(settingConnections)
		end
	end,
	Tooltip = 'Hover a toggle setting to bind it to a key'
})

general:CreateButton({
	Name = 'Reset current Config',
	Function = function()
	EZ.Save = function() end
		if isfile('Elite Zone/Configs/'..EZ.config..EZ.Place..'.txt') and delfile then
			delfile('Elite Zone/Configs/'..EZ.config..EZ.Place..'.txt')
		end

		shared.EZreload = true
	end,
	Tooltip = 'This will set your Config to the default settings'
})

general:CreateButton({
	Name = 'Self destruct',
	Function = function()
		EZ:Uninject()
	end,
	Tooltip = 'Removes EZ from the current game'
})

general:CreateButton({
	Name = 'Reinject',
	Function = function()
		shared.EZreload = true
	end,
	Tooltip = 'Reloads EZ for debugging purposes'
})

local modules = EZ.Categories.Main.Settings:CreateSettingsPane({Name = 'Modules'})
modules:CreateToggle({
	Name = 'Teams by server',
	Tooltip = 'Ignore players on your team designated by the server',
	Default = true,
	Function = function()
		if EZ.Libraries.entity and EZ.Libraries.entity.Running then
			EZ.Libraries.entity.refresh()
		end
	end
})

modules:CreateToggle({
	Name = 'Use team color',
	Tooltip = 'Uses the TeamColor property on players for render modules',
	Default = true,
	Function = function()
		if EZ.Libraries.entity and EZ.Libraries.entity.Running then
			EZ.Libraries.entity.refresh()
		end
	end
})

local guipane = EZ.Categories.Main.Settings:CreateSettingsPane({Name = 'GUI'})
EZ.Blur = guipane:CreateToggle({
	Name = 'Blur background',
	Function = function()
		EZ:BlurCheck()
	end,
	Default = true,
	Tooltip = 'Blur the background of the GUI'
})

guipane:CreateToggle({
	Name = 'GUI bind indicator',
	Default = true,
	Tooltip = "Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'"
})

guipane:CreateToggle({
	Name = 'Show tooltips',
	Function = function(enabled)
		tooltip.Visible = false
		toolblur.Enabled = enabled
	end,
	Default = true,
	Tooltip = 'Toggles visibility of these'
})

guipane:CreateToggle({
	Name = 'Show legit mode',
	Function = function(enabled)
		clickgui.Search.Legit.Visible = enabled
		clickgui.Search.LegitDivider.Visible = enabled
		clickgui.Search.TextBox.Size = UDim2.new(1, enabled and -50 or -10, 0, 37)
		clickgui.Search.TextBox.Position = UDim2.fromOffset(enabled and 50 or 10, 0)
	end,
	Default = true,
	Tooltip = 'Shows the button to switch to the legit mod menu'
})

local ScaleSlider = {Object = {}, Value = 1}
EZ.Scale = guipane:CreateToggle({
	Name = 'Auto rescale',
	Default = true,
	Function = function(callback)
		ScaleSlider.Object.Visible = not callback
		if callback then

		else
			scale.Scale = ScaleSlider.Value
		end
	end,
	Tooltip = 'Automatically rescales the gui using the screens resolution'
})

ScaleSlider = guipane:CreateSlider({
	Name = 'Scale',
	Min = 0.1,
	Max = 2,
	Decimal = 10,
	Function = function(val, final)
		if final and not EZ.Scale.Enabled then
			scale.Scale = val
		end
	end,
	Default = 1,
	Darker = true,
	Visible = false
})

EZ.RainbowSpeed = guipane:CreateSlider({
	Name = 'Rainbow speed',
	Min = 0.1,
	Max = 10,
	Decimal = 10,
	Default = 1,
	Tooltip = 'Adjusts the speed of rainbow values'
})

EZ.RainbowUpdateSpeed = guipane:CreateSlider({
	Name = 'Rainbow update rate',
	Min = 1,
	Max = 144,
	Default = 60,
	Tooltip = 'Adjusts the update rate of rainbow values',
	Suffix = 'hz'
})

guipane:CreateDropdown({
	Name = 'Search bar style',
	List = {'Floating', 'None'},
	Default = 'Floating',
	Function = function(value)
		EZ.SearchBar.Object.Visible = value == 'Floating'
	end,
	Tooltip = 'Switch between search bar styles'
})

EZ.RainbowMode = guipane:CreateDropdown({
	Name = 'Rainbow Mode',
	List = {'Normal', 'Gradient', 'Retro'},
	Tooltip = 'Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color'
})

guipane:CreateButton({
	Name = 'Reset GUI positions',
	Function = function()
		for _, category in EZ.Categories do
			category.Object.Position = UDim2.fromOffset(6, 42)
		end
	end,
	Tooltip = 'This will reset your GUI back to the default'
})

guipane:CreateButton({
	Name = 'Sort GUI',
	Function = function()
		local priority = {
			GUICategory = 1,
			CombatCategory = 2,
			BlatantCategory = 3,
			RenderCategory = 4,
			UtilityCategory = 5,
			WorldCategory = 6,
			InventoryCategory = 7,
			FriendsCategory = 8,
			configsCategory = 9
		}

		local categories = {}
		for _, category in EZ.Categories do
			if category.Type ~= 'Overlay' then
				table.insert(categories, category)
			end
		end

		table.sort(categories, function(a, b)
			return (priority[a.Object.Name] or 99) < (priority[b.Object.Name] or 99)
		end)

		local index = 0
		for _, category in categories do
			if category.Object.Visible then
				category.Object.Position = UDim2.fromOffset(6 + (index % 8 * 230), 60 + (index > 7 and 360 or 0))
				index += 1
			end
		end
	end,
	Tooltip = 'Sorts GUI by category order'
})

local notifpane = EZ.Categories.Main.Settings:CreateSettingsPane({Name = 'Notifications'})
EZ.Notifications = notifpane:CreateToggle({
	Name = 'Notifications',
	Function = function(enabled)
		if EZ.ToggleNotifications.Object then
			EZ.ToggleNotifications.Object.Visible = enabled
		end

		if EZ.SettingToggleNotifications.Object then
			EZ.SettingToggleNotifications.Object.Visible = enabled
		end
	end,
	Tooltip = 'Shows notifications',
	Default = true
})

EZ.ToggleNotifications = notifpane:CreateToggle({
	Name = 'Toggle alert',
	Tooltip = 'Notifies you if a module is enabled/disabled.',
	Default = true,
	Darker = true
})
EZ.SettingToggleNotifications = notifpane:CreateToggle({
	Name = 'Setting toggle alert',
	Tooltip = 'Notifies you when a bound setting is toggled.',
	Default = true,
	Darker = true
})

EZ.GUIColor = EZ.Categories.Main.Settings:CreateGUISlider({
	Name = 'GUI Theme',
	Function = function(h, s, v)
		EZ:UpdateGUI()
	end
})

EZ.GUIBind = EZ.Categories.Main.Settings:CreateBind({
	Name = 'Rebind GUI',
	Default = {'RightShift'},
	NoRemove = true,
	Tooltip = 'Change the bind of the GUI'
})

--Overlays

EZ:Clean(task.spawn(function()
	local hue = 0
	repeat
		for _, component in EZ.RainbowSliders do
			if component.Type == 'GUISlider' then
				component:SetValue(EZ:Color(hue))
			else
				component:SetValue(hue)
			end
		end

		local delta = task.wait(1 / EZ.RainbowUpdateSpeed.Value)
		hue = (hue + (delta * (0.2 * EZ.RainbowSpeed.Value))) % 1
	until false
end))

local cursorConnection
EZ:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
	EZ:UpdateGUI()

	if clickgui.Visible and inputService.MouseEnabled then
		if cursorConnection then
			cursorConnection:Disconnect()
		end

		cursorConnection = runService.RenderStepped:Connect(function()
			local isVisible = clickgui.Visible
			for _, window in EZ.Windows do
				isVisible = isVisible or window.Visible
			end

			if not isVisible then
				cursor.Visible = false
				cursorConnection:Disconnect()
				cursorConnection = nil
				return
			end

			cursor.Visible = not inputService.MouseIconEnabled
			if cursor.Visible then
				local mouseLocation = inputService:GetMouseLocation()
				cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32)
			end
		end)
	end
end))

EZ:Clean(function()
	if cursorConnection then
		cursorConnection:Disconnect()
	end
end)

EZ:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	if EZ.Scale.Enabled then
		scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
	end
end))

EZ:Clean(notifications.ChildRemoved:Connect(function()
	for index, notif in notifications:GetChildren() do
		if tween.Tween then
			tween:Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				Position = UDim2.new(1, 0, 1, -(29 + (78 * index)))
			})
		end
	end
end))

EZ:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
	scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

	for _, obj in scaledgui:QueryDescendants('GuiObject >> [Visible = true]') do
		obj.Visible = false
		obj.Visible = true
	end
end))

EZ:Clean(EZ.GUIBind.Triggered:Connect(function()
	if EZ.ThreadFix then
		setthreadidentity(8)
	end

	for _, window in self.Windows do
		window.Visible = false
	end

	for _, module in self.Modules do
		if module.Bind.Mobile then
			module.Bind.Mobile.Visible = clickgui.Visible
		end
	end

	clickgui.Visible = not clickgui.Visible
	EZ:BlurCheck()
end))

EZ:Clean(inputService.InputBegan:Connect(function(input)
	if EZ.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
		EZ.CurrentTooltip()
	end

	if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
		table.insert(EZ.HeldKeybinds, input.KeyCode.Name)
		if EZ.Binding then return end

		for _, bind in EZ.ActiveBinds do
			if checkKeybinds(EZ.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
				bind.Triggered:Fire(true)
			end
		end
	end
end))

EZ:Clean(inputService.InputEnded:Connect(function(input)
	if EZ.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
		EZ.CurrentTooltip()
	end

	if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
		if EZ.Binding then
			if not EZ.MultiKeybind.Enabled then
				EZ.HeldKeybinds = {input.KeyCode.Name}
			end

			EZ.Binding:SetBind(EZ.HeldKeybinds, true)
			EZ.Binding = nil
		else
			for _, bind in EZ.ActiveBinds do
				if bind.Hold and checkKeybinds(EZ.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
					bind.Triggered:Fire(false)
				end
			end
		end
	end

	local index = table.find(EZ.HeldKeybinds, input.KeyCode.Name)
	if index then
		table.remove(EZ.HeldKeybinds, index)
	end
end))
