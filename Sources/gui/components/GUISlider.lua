local component = {
	Hue = 0.46,
	Rainbow = false,
	Sat = 0.96,
	Type = 'GUISlider',
	Value = 0.52
}

local slider = Instance.new('TextButton')
slider.AutoButtonColor = false
slider.BackgroundTransparency = 1
slider.Name = props.Name..'Slider'
slider.Size = UDim2.fromOffset(220, 32)
slider.Text = ''
slider.Parent = children
component.Object = slider
local title = Instance.new('TextLabel')
title.BackgroundTransparency = 1
title.FontFace = uipallet.Font
title.Name = 'Title'
title.Position = UDim2.fromOffset(10, 0)
title.Size = UDim2.new(1, -60, 0, 32)
title.Text = props.Name
title.TextColor3 = color.Dark(uipallet.Text, 0.16)
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = slider
local preview = Instance.new('ImageButton')
preview.BackgroundTransparency = 1
preview.Image = get_ez_asset('Elite Zone/Assets/colorpreview.png')
preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
preview.Position = UDim2.new(1, -22, 0, 10)
preview.Size = UDim2.fromOffset(12, 12)
preview.Parent = slider
local rainbow = Instance.new('TextButton')
rainbow.BackgroundTransparency = 1
rainbow.Position = UDim2.new(1, -42, 0, 10)
rainbow.Size = UDim2.fromOffset(12, 12)
rainbow.Text = ''
rainbow.Parent = slider
local ring1 = Instance.new('ImageLabel')
ring1.BackgroundTransparency = 1
ring1.Image = get_ez_asset('Elite Zone/Assets/rainbow_1.png')
ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
ring1.Size = UDim2.fromOffset(12, 12)
ring1.Parent = rainbow
local ring2 = Instance.fromExisting(ring1)
ring2.Image = get_ez_asset('Elite Zone/Assets/rainbow_2.png')
ring2.Parent = rainbow
local ring3 = Instance.fromExisting(ring1)
ring3.Image = get_ez_asset('Elite Zone/Assets/rainbow_3.png')
ring3.Parent = rainbow
local ring4 = Instance.fromExisting(ring1)
ring4.Image = get_ez_asset('Elite Zone/Assets/rainbow_4.png')
ring4.Parent = rainbow
props.Function = props.Function or function() end

-- a full screen catcher behind the window: any click that is not on the picker closes it
local backdrop = Instance.new('TextButton')
backdrop.BackgroundTransparency = 1
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.Text = ''
backdrop.Visible = false
backdrop.ZIndex = 5
backdrop.Parent = clickgui
local picker = Instance.new('TextButton')
picker.AutoButtonColor = false
picker.BackgroundColor3 = uipallet.Main
picker.BorderSizePixel = 0
picker.Position = UDim2.fromOffset(456, 139)
picker.Size = UDim2.fromOffset(220, 219)
picker.Text = ''
picker.Visible = false
picker.ZIndex = 6
picker.Parent = clickgui
component.Window = picker
addBlur(picker)
addCorner(picker)
local windowicon = Instance.new('ImageLabel')
windowicon.BackgroundTransparency = 1
windowicon.Image = get_ez_asset('Elite Zone/Assets/colorpreview.png')
windowicon.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
windowicon.Position = UDim2.fromOffset(10, 14)
windowicon.Size = UDim2.fromOffset(14, 14)
windowicon.ZIndex = 7
windowicon.Parent = picker
local windowtitle = Instance.new('TextLabel')
windowtitle.BackgroundTransparency = 1
windowtitle.FontFace = uipallet.Font
windowtitle.Position = UDim2.fromOffset(32, 11)
windowtitle.Size = UDim2.new(1, -68, 0, 20)
windowtitle.Text = props.Name
windowtitle.TextColor3 = uipallet.Text
windowtitle.TextSize = 13
windowtitle.TextXAlignment = Enum.TextXAlignment.Left
windowtitle.ZIndex = 7
windowtitle.Parent = picker
local close = addCloseButton(picker)
close.ZIndex = 7

local svmap = Instance.new('ImageButton')
svmap.AutoButtonColor = false
svmap.BackgroundColor3 = Color3.fromHSV(component.Hue, 1, 1)
svmap.BorderSizePixel = 0
svmap.Position = UDim2.fromOffset(10, 45)
svmap.Size = UDim2.fromOffset(180, 130)
svmap.ZIndex = 7
svmap.ClipsDescendants = true
svmap.Parent = picker
addCorner(svmap)
local svgradient = Instance.new('ImageLabel')
svgradient.BackgroundTransparency = 1
svgradient.Image = 'rbxassetid://4155801252'
svgradient.Position = UDim2.fromOffset(-1, -1)
svgradient.Size = UDim2.new(1, 2, 1, 2)
svgradient.ZIndex = 7
svgradient.Parent = svmap
local svcursor = Instance.new('Frame')
svcursor.AnchorPoint = Vector2.new(0.5, 0.5)
svcursor.BackgroundColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
svcursor.BorderSizePixel = 0
svcursor.Position = UDim2.fromScale(component.Sat, 1 - component.Value)
svcursor.Size = UDim2.fromOffset(12, 12)
svcursor.ZIndex = 10
svcursor.Parent = svmap
addCorner(svcursor, UDim.new(1, 0))
local svring = Instance.new('UIStroke')
svring.Color = Color3.new(1, 1, 1)
svring.Thickness = 2
svring.Parent = svcursor

local huebar = Instance.new('ImageButton')
huebar.AutoButtonColor = false
huebar.BackgroundColor3 = Color3.new(1, 1, 1)
huebar.BorderSizePixel = 0
huebar.Position = UDim2.fromOffset(198, 45)
huebar.Size = UDim2.fromOffset(12, 130)
huebar.ZIndex = 7
huebar.Parent = picker
addCorner(huebar, UDim.new(1, 0))
local rainbowTable = {}
for i = 0, 1, 0.1 do
	table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
end
local huegradient = Instance.new('UIGradient')
huegradient.Color = ColorSequence.new(rainbowTable)
huegradient.Rotation = 90
huegradient.Parent = huebar
local huecursor = Instance.new('Frame')
huecursor.AnchorPoint = Vector2.new(0.5, 0.5)
huecursor.BackgroundColor3 = Color3.new(1, 1, 1)
huecursor.BorderSizePixel = 0
huecursor.Position = UDim2.fromScale(0.5, component.Hue)
huecursor.Size = UDim2.new(1, 4, 0, 3)
huecursor.ZIndex = 8
huecursor.Parent = huebar
addCorner(huecursor, UDim.new(1, 0))

local swatchholder = Instance.new('Frame')
swatchholder.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
swatchholder.BorderSizePixel = 0
swatchholder.Position = UDim2.fromOffset(10, 185)
swatchholder.Size = UDim2.fromOffset(24, 24)
swatchholder.ZIndex = 7
swatchholder.Parent = picker
addCorner(swatchholder)
local swatch = Instance.new('Frame')
swatch.BackgroundColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
swatch.BorderSizePixel = 0
swatch.Position = UDim2.fromOffset(1, 1)
swatch.Size = UDim2.new(1, -2, 1, -2)
swatch.ZIndex = 7
swatch.Parent = swatchholder
addCorner(swatch)
local hexholder = Instance.new('Frame')
hexholder.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
hexholder.BorderSizePixel = 0
hexholder.Position = UDim2.fromOffset(42, 185)
hexholder.Size = UDim2.fromOffset(168, 24)
hexholder.ZIndex = 7
hexholder.Parent = picker
addCorner(hexholder)
local hexinner = Instance.new('Frame')
hexinner.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
hexinner.BorderSizePixel = 0
hexinner.Position = UDim2.fromOffset(1, 1)
hexinner.Size = UDim2.new(1, -2, 1, -2)
hexinner.ZIndex = 7
hexinner.Parent = hexholder
addCorner(hexinner)
local hexbox = Instance.new('TextBox')
hexbox.BackgroundTransparency = 1
hexbox.ClearTextOnFocus = false
hexbox.FontFace = uipallet.Font
hexbox.Position = UDim2.fromOffset(10, 0)
hexbox.Size = UDim2.new(1, -20, 1, 0)
hexbox.Text = ''
hexbox.TextColor3 = uipallet.Text
hexbox.TextSize = 13
hexbox.TextXAlignment = Enum.TextXAlignment.Left
hexbox.ZIndex = 8
hexbox.Parent = hexholder

local rainbowthread

-- both bars share this: press to jump, hold to scrub, release to drop the connections
local function addDrag(target, callback)
	target.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		callback(input.Position)

		local releaseConnection
		local moveConnection = inputService.InputChanged:Connect(function(newInput)
			if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
				callback(newInput.Position)
			end
		end)

		releaseConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				moveConnection:Disconnect()
				releaseConnection:Disconnect()
			end
		end)
	end)
end

function component:Load(data)
	if data.Rainbow then
		self:Toggle()
	end

	self:SetValue(data.Hue, data.Sat, data.Value)
end

function component:Save(data)
	data[props.Name] = {
		Hue = self.Hue,
		Sat = self.Sat,
		Value = self.Value,
		Rainbow = self.Rainbow
	}
end

function component:SetValue(h, s, v)
	self.Hue = h or self.Hue
	self.Sat = s or self.Sat
	self.Value = v or self.Value

	local shade = Color3.fromHSV(self.Hue, self.Sat, self.Value)
	preview.ImageColor3 = shade

	-- rainbow drives this every frame, so skip the picker writes while it is closed
	if picker.Visible then
		windowicon.ImageColor3 = shade
		svmap.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
		svcursor.Position = UDim2.fromScale(self.Sat, 1 - self.Value)
		svcursor.BackgroundColor3 = shade
		huecursor.Position = UDim2.fromScale(0.5, self.Hue)
		swatch.BackgroundColor3 = shade
		hexbox.Text = '#'..shade:ToHex()
	end

	props.Function(self.Hue, self.Sat, self.Value)
end

function component:Toggle()
	self.Rainbow = not self.Rainbow
	if rainbowthread then
		task.cancel(rainbowthread)
	end

	if self.Rainbow then
		table.insert(EZ.RainbowSliders, self)

		ring1.ImageColor3 = Color3.fromRGB(5, 127, 100)
		rainbowthread = task.delay(0.1, function()
			ring2.ImageColor3 = Color3.fromRGB(228, 125, 43)
			rainbowthread = task.delay(0.1, function()
				ring3.ImageColor3 = Color3.fromRGB(225, 46, 52)
				rainbowthread = nil
			end)
		end)
	else
		local index = table.find(EZ.RainbowSliders, self)
		if index then
			table.remove(EZ.RainbowSliders, index)
		end

		ring3.ImageColor3 = color.Light(uipallet.Main, 0.37)
		rainbowthread = task.delay(0.1, function()
			ring2.ImageColor3 = color.Light(uipallet.Main, 0.37)
			rainbowthread = task.delay(0.1, function()
				ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
				rainbowthread = nil
			end)
		end)
	end
end

addDrag(svmap, function(position)
	if component.Rainbow then
		component:Toggle()
	end

	component:SetValue(
		nil,
		math.clamp((position.X - svmap.AbsolutePosition.X) / svmap.AbsoluteSize.X, 0, 1),
		1 - math.clamp((position.Y - svmap.AbsolutePosition.Y) / svmap.AbsoluteSize.Y, 0, 1)
	)
end)

addDrag(huebar, function(position)
	if component.Rainbow then
		component:Toggle()
	end

	component:SetValue(math.clamp((position.Y - huebar.AbsolutePosition.Y) / huebar.AbsoluteSize.Y, 0, 1))
end)

preview.MouseButton1Click:Connect(function()
	picker.Visible = not picker.Visible
	backdrop.Visible = picker.Visible
	if not picker.Visible then return end

	-- absolute positions are real screen pixels, so divide back out of the ui scale to land in
	-- clickgui's own offsets, then keep the whole window on screen
	local room = clickgui.AbsoluteSize / scale.Scale
	local origin = (slider.AbsolutePosition - clickgui.AbsolutePosition) / scale.Scale
	picker.Position = UDim2.fromOffset(
		math.clamp(origin.X + (slider.AbsoluteSize.X / scale.Scale) + 8, 8, math.max(room.X - picker.Size.X.Offset - 8, 8)),
		math.clamp(origin.Y - 8, 8, math.max(room.Y - picker.Size.Y.Offset - 8, 8))
	)

	component:SetValue()
end)

rainbow.MouseButton1Click:Connect(function()
	component:Toggle()
end)

close.MouseButton1Click:Connect(function()
	picker.Visible = false
end)

backdrop.MouseButton1Click:Connect(function()
	picker.Visible = false
end)

picker:GetPropertyChangedSignal('Visible'):Connect(function()
	backdrop.Visible = picker.Visible
end)

hexbox.FocusLost:Connect(function(enter)
	local success, parsed = enter and pcall(Color3.fromHex, hexbox.Text)

	if not success or not parsed then
		hexbox.Text = '#'..Color3.fromHSV(component.Hue, component.Sat, component.Value):ToHex()
		return
	end

	if component.Rainbow then
		component:Toggle()
	end

	component:SetValue(parsed:ToHSV())
end)

slider:GetPropertyChangedSignal('Visible'):Connect(function()
	if not slider.Visible then
		picker.Visible = false
	end
end)

api.Options[props.Name] = component

return component
