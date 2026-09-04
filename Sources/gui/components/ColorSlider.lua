local component = {
	Type = 'ColorSlider',
	Hue = props.DefaultHue or 0.44,
	Sat = props.DefaultSat or 1,
	Value = props.DefaultValue or 1,
	Opacity = props.DefaultOpacity or 1,
	Rainbow = false,
	Index = 0
}

local hasAlpha = props.Transparency == true

local colorslider = Instance.new('TextButton')
colorslider.AutoButtonColor = false
colorslider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
colorslider.BorderSizePixel = 0
colorslider.Size = UDim2.new(1, 0, 0, 32)
colorslider.Text = ''
colorslider.Visible = props.Visible == nil or props.Visible
colorslider.Parent = children
component.Object = colorslider
addTooltip(colorslider, props.Tooltip)
local title = Instance.new('TextLabel')
title.BackgroundTransparency = 1
title.FontFace = uipallet.Font
title.Position = UDim2.fromOffset(10, 0)
title.Size = UDim2.new(1, -60, 0, 32)
title.Text = props.Name
title.TextColor3 = color.Dark(uipallet.Text, 0.16)
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = colorslider
local preview = Instance.new('ImageButton')
preview.BackgroundTransparency = 1
preview.Image = get_ez_asset('Elite Zone/Assets/colorpreview.png')
preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
preview.ImageTransparency = 1 - component.Opacity
preview.Position = UDim2.new(1, -22, 0, 10)
preview.Size = UDim2.fromOffset(12, 12)
preview.Parent = colorslider
local rainbow = Instance.new('TextButton')
rainbow.BackgroundTransparency = 1
rainbow.Position = UDim2.new(1, -42, 0, 10)
rainbow.Size = UDim2.fromOffset(12, 12)
rainbow.Text = ''
rainbow.Parent = colorslider
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

local hexY = hasAlpha and 200 or 182
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
picker.Size = UDim2.fromOffset(220, hexY + 36)
picker.Text = ''
picker.Visible = false
picker.ZIndex = 6
picker.Parent = clickgui
component.Window = picker
addBlur(picker)
addCorner(picker)
local pickerstroke = Instance.new('UIStroke')
pickerstroke.Color = color.Light(uipallet.Main, 0.4)
pickerstroke.Transparency = 0.6
pickerstroke.Parent = picker
local windowtitle = Instance.new('TextLabel')
windowtitle.BackgroundTransparency = 1
windowtitle.FontFace = uipallet.Font
windowtitle.Position = UDim2.fromOffset(12, 9)
windowtitle.Size = UDim2.new(1, -36, 0, 18)
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
svmap.Position = UDim2.fromOffset(12, 42)
svmap.Size = UDim2.fromOffset(176, 130)
svmap.ZIndex = 7
svmap.Image = 'rbxassetid://4155801252'
svmap.Parent = picker
addCorner(svmap, UDim.new(0, 6))
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
huebar.Position = UDim2.fromOffset(196, 42)
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

local alphabar, alphacursor
if hasAlpha then
	alphabar = Instance.new('ImageButton')
	alphabar.AutoButtonColor = false
	alphabar.BackgroundColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
	alphabar.BorderSizePixel = 0
	alphabar.Image = 'rbxassetid://12978095818'
	alphabar.Position = UDim2.fromOffset(12, 182)
	alphabar.Size = UDim2.fromOffset(196, 10)
	alphabar.ZIndex = 7
	alphabar.Parent = picker
	addCorner(alphabar, UDim.new(1, 0))
	alphacursor = Instance.new('Frame')
	alphacursor.AnchorPoint = Vector2.new(0.5, 0.5)
	alphacursor.BackgroundColor3 = Color3.new(1, 1, 1)
	alphacursor.BorderSizePixel = 0
	alphacursor.Position = UDim2.fromScale(component.Opacity, 0.5)
	alphacursor.Size = UDim2.new(0, 3, 1, 4)
	alphacursor.ZIndex = 8
	alphacursor.Parent = alphabar
	addCorner(alphacursor, UDim.new(1, 0))
end

local swatch = Instance.new('Frame')
swatch.BackgroundColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
swatch.BorderSizePixel = 0
swatch.Position = UDim2.fromOffset(12, hexY)
swatch.Size = UDim2.fromOffset(24, 24)
swatch.ZIndex = 7
swatch.Parent = picker
addCorner(swatch, UDim.new(0, 6))
local swatchstroke = Instance.new('UIStroke')
swatchstroke.Color = color.Light(uipallet.Main, 0.4)
swatchstroke.Transparency = 0.5
swatchstroke.Parent = swatch
local swatchchecker
if hasAlpha then
	swatchchecker = Instance.new('ImageLabel')
	swatchchecker.BackgroundTransparency = 1
	swatchchecker.Image = 'rbxassetid://12977615774'
	swatchchecker.ImageTransparency = component.Opacity
	swatchchecker.Size = UDim2.fromScale(1, 1)
	swatchchecker.ZIndex = 8
	swatchchecker.Parent = swatch
	addCorner(swatchchecker, UDim.new(0, 6))
end
local hexbox = Instance.new('TextBox')
hexbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.05)
hexbox.BorderSizePixel = 0
hexbox.ClearTextOnFocus = false
hexbox.FontFace = uipallet.Font
hexbox.Position = UDim2.fromOffset(44, hexY)
hexbox.Size = UDim2.fromOffset(164, 24)
hexbox.Text = ''
hexbox.TextColor3 = uipallet.Text
hexbox.TextSize = 11
hexbox.ZIndex = 7
hexbox.Parent = picker
addCorner(hexbox, UDim.new(0, 6))
local hexpadding = Instance.new('UIPadding')
hexpadding.PaddingLeft = UDim.new(0, 8)
hexpadding.Parent = hexbox
hexbox.TextXAlignment = Enum.TextXAlignment.Left

-- every bar shares this: press to jump, hold to scrub, release to drop the connections
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
	if data.Rainbow ~= self.Rainbow then
		self:Toggle()
	end

	if self.Hue ~= data.Hue or self.Sat ~= data.Sat or self.Value ~= data.Value or self.Opacity ~= data.Opacity then
		self:SetValue(data.Hue, data.Sat, data.Value, data.Opacity)
	end
end

function component:Save(data)
	data[props.Name] = {
		Hue = self.Hue,
		Sat = self.Sat,
		Value = self.Value,
		Opacity = self.Opacity,
		Rainbow = self.Rainbow
	}
end

function component:SetValue(h, s, v, o)
	self.Hue = h or self.Hue
	self.Sat = s or self.Sat
	self.Value = v or self.Value
	self.Opacity = o or self.Opacity

	local shade = Color3.fromHSV(self.Hue, self.Sat, self.Value)
	preview.ImageColor3 = shade
	preview.ImageTransparency = 1 - self.Opacity

	-- the picker is the only thing the rest of these touch, so skip them while it is closed
	if picker.Visible then
		svmap.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
		svcursor.Position = UDim2.fromScale(self.Sat, 1 - self.Value)
		svcursor.BackgroundColor3 = shade
		huecursor.Position = UDim2.fromScale(0.5, self.Hue)
		swatch.BackgroundColor3 = shade
		hexbox.Text = '#'..shade:ToHex()

		if hasAlpha then
			alphabar.BackgroundColor3 = shade
			alphacursor.Position = UDim2.fromScale(self.Opacity, 0.5)
			swatchchecker.ImageTransparency = self.Opacity
		end
	end

	props.Function(self.Hue, self.Sat, self.Value, self.Opacity)
end

function component:Toggle()
	self.Rainbow = not self.Rainbow

	if self.Rainbow then
		table.insert(EZ.RainbowSliders, self)

		ring1.ImageColor3 = Color3.fromRGB(5, 127, 100)
		task.delay(0.1, function()
			if not self.Rainbow then return end
			ring2.ImageColor3 = Color3.fromRGB(228, 125, 43)
			task.delay(0.1, function()
				if not self.Rainbow then return end
				ring3.ImageColor3 = Color3.fromRGB(225, 46, 52)
			end)
		end)
	else
		local index = table.find(EZ.RainbowSliders, self)
		if index then
			table.remove(EZ.RainbowSliders, index)
		end

		ring3.ImageColor3 = color.Light(uipallet.Main, 0.37)
		task.delay(0.1, function()
			if self.Rainbow then return end
			ring2.ImageColor3 = color.Light(uipallet.Main, 0.37)
			task.delay(0.1, function()
				if self.Rainbow then return end
				ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
			end)
		end)
	end
end

addDrag(svmap, function(position)
	component:SetValue(
		nil,
		math.clamp((position.X - svmap.AbsolutePosition.X) / svmap.AbsoluteSize.X, 0, 1),
		1 - math.clamp((position.Y - svmap.AbsolutePosition.Y) / svmap.AbsoluteSize.Y, 0, 1)
	)
end)

addDrag(huebar, function(position)
	component:SetValue(math.clamp((position.Y - huebar.AbsolutePosition.Y) / huebar.AbsoluteSize.Y, 0, 1))
end)

if hasAlpha then
	addDrag(alphabar, function(position)
		component:SetValue(nil, nil, nil, math.clamp((position.X - alphabar.AbsolutePosition.X) / alphabar.AbsoluteSize.X, 0, 1))
	end)
end

preview.MouseButton1Click:Connect(function()
	picker.Visible = not picker.Visible
	backdrop.Visible = picker.Visible
	if not picker.Visible then return end

	-- absolute positions are real screen pixels, so divide back out of the ui scale to land in
	-- clickgui's own offsets, then keep the whole window on screen
	local room = clickgui.AbsoluteSize / scale.Scale
	local origin = (colorslider.AbsolutePosition - clickgui.AbsolutePosition) / scale.Scale
	picker.Position = UDim2.fromOffset(
		math.clamp(origin.X + (colorslider.AbsoluteSize.X / scale.Scale) + 8, 8, math.max(room.X - picker.Size.X.Offset - 8, 8)),
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

colorslider:GetPropertyChangedSignal('Visible'):Connect(function()
	if not colorslider.Visible then
		picker.Visible = false
	end
end)

api.Options[props.Name] = component

return component
