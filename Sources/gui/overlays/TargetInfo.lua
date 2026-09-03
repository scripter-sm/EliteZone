

local targetinfo = {
	Targets = {},
	Object = Holder,
	Health = 0,
	MaxHealth = 0
}
local TargetInfoOverlay
local BackgroundTransparency = {
	Value = 0.1,
	Object = {Visible = {}}
}
local BorderColor
local BKGColor
local CustomColor
local DisplayName

TargetInfoOverlay = EZ:CreateOverlay({
	Name = 'Target Info',
	Icon = get_ez_asset('Elite Zone/Assets/targetinfo.png'),
	Size = UDim2.fromOffset(14, 14),
	Position = UDim2.fromOffset(12, 14),
	CategorySize = 240,
	Function = function(callback)
		if callback then
			TargetInfoOverlay:Clean(runService.RenderStepped:Connect(function()
				targetinfo:Update()
			end))
		end
	end
})

local accent = Color3.fromHSV(EZ.GUIColor.Hue, EZ.GUIColor.Sat, EZ.GUIColor.Value)
local font_regular, font_bold = {}, {}

local Holder = Instance.new('Frame')
Holder.Size = UDim2.fromOffset(240, 96)
Holder.Position = UDim2.fromOffset(0, -6)
Holder.ZIndex = 0
Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.05)
Holder.BackgroundTransparency = 0.1
Holder.Parent = TargetInfoOverlay.Children
local BlurHolder = addBlur(Holder, nil, true)
BlurHolder.Visible = false
BlurHolder.ZIndex = 0
addCorner(Holder)
local Headshot = Instance.new('ImageLabel')
Headshot.Size = UDim2.fromOffset(26, 27)
Headshot.Position = UDim2.fromOffset(19, 17)
Headshot.BackgroundColor3 = uipallet.Main
Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420'
Headshot.Parent = Holder
addCorner(Headshot)
local HurtFlash = Instance.new('Frame')
HurtFlash.Size = UDim2.fromScale(1, 1)
HurtFlash.BackgroundTransparency = 1
HurtFlash.BackgroundColor3 = Color3.new(1, 0, 0)
HurtFlash.Parent = Headshot
addCorner(HurtFlash)
local HeadshotBlur = addBlur(Headshot)
HeadshotBlur.Enabled = false
local Name = Instance.new('TextLabel')
Name.Size = UDim2.fromOffset(145, 20)
Name.Position = UDim2.fromOffset(54, 20)
Name.BackgroundTransparency = 1
Name.Text = 'Target name'
Name.TextXAlignment = Enum.TextXAlignment.Left
Name.TextYAlignment = Enum.TextYAlignment.Top
Name.TextScaled = true
Name.TextColor3 = color.Light(uipallet.Text, 0.4)
Name.TextStrokeTransparency = 1
Name.FontFace = uipallet.Font
local NameShadow = Name:Clone()
NameShadow.Position = UDim2.fromOffset(55, 21)
NameShadow.TextColor3 = Color3.new()
NameShadow.TextTransparency = 0.65
NameShadow.Visible = false
NameShadow.Parent = Holder
for _, prop in {'Size', 'Text', 'FontFace'} do
	Name:GetPropertyChangedSignal(prop):Connect(function()
		NameShadow[prop] = Name[prop]
	end)
end
Name.Parent = Holder
font_regular[#font_regular + 1] = Name
local HealthBKG = Instance.new('Frame')
HealthBKG.Name = 'HealthBKG'
HealthBKG.Size = UDim2.fromOffset(200, 9)
HealthBKG.Position = UDim2.fromOffset(20, 56)
HealthBKG.BackgroundColor3 = uipallet.Main
HealthBKG.BorderSizePixel = 0
HealthBKG.Parent = Holder
addCorner(HealthBKG, UDim.new(1, 0))
local Health = HealthBKG:Clone()
Health.Size = UDim2.fromScale(0.8, 1)
Health.Position = UDim2.new()
Health.BackgroundColor3 = accent
Health.Parent = HealthBKG
Health:GetPropertyChangedSignal('Size'):Connect(function()
	Health.Visible = Health.Size.X.Scale > 0.01
end)
local Armor = Health:Clone()
Armor.Size = UDim2.new()
Armor.Position = UDim2.fromScale(1, 0)
Armor.AnchorPoint = Vector2.new(1, 0)
Armor.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
Armor.Visible = false
Armor.Parent = HealthBKG
Armor:GetPropertyChangedSignal('Size'):Connect(function()
	Armor.Visible = Armor.Size.X.Scale > 0.01
end)
local HealthBlur = addBlur(HealthBKG)
HealthBlur.Enabled = false
local HealthText = Instance.new('TextLabel')
HealthText.Name = 'HealthText'
HealthText.BackgroundTransparency = 1
HealthText.Position = UDim2.fromOffset(20, 41)
HealthText.Size = UDim2.fromOffset(200, 13)
HealthText.FontFace = uipallet.FontSemiBold
font_bold[#font_bold + 1] = HealthText
HealthText.Text = ''
HealthText.TextColor3 = color.Light(uipallet.Text, 0.2)
HealthText.TextSize = 11
HealthText.TextXAlignment = Enum.TextXAlignment.Right
HealthText.TextYAlignment = Enum.TextYAlignment.Bottom
HealthText.Parent = Holder
local Stroke = Instance.new('UIStroke')
Stroke.Enabled = false
Stroke.Color = Color3.fromHSV(0.44, 1, 1)
Stroke.Parent = Holder

local rivals_extra_height = 160
local devices = {MouseKeyboard = 'computer', Touch = 'mobile', Gamepad = 'controller', VR = 'vr'}
local device_pool = {'computer', 'mobile', 'controller', 'vr'}
local ranks = {
	'Bronze 1', 'Bronze 2', 'Bronze 3', 'Silver 1', 'Silver 2', 'Silver 3',
	'Gold 1', 'Gold 2', 'Gold 3', 'Platinum 1', 'Platinum 2', 'Platinum 3',
	'Diamond 1', 'Diamond 2', 'Diamond 3', 'Onyx 1', 'Onyx 2', 'Onyx 3', 'Nemesis'
}
local preview_icons = {
	'rbxassetid://17225649668', 'rbxassetid://17225650488',
	'rbxassetid://17225650859', 'rbxassetid://17225651405'
}
local local_player = cloneref(game:GetService('Players')).LocalPlayer

local rivals
local function rivals_libs()
	if rivals == nil then
		rivals = false
		pcall(function()
			local storage = cloneref(game:GetService('ReplicatedStorage'))
			rivals = {
				fighters = require(local_player.PlayerScripts.Controllers.FighterController),
				items = require(storage.Modules.ItemLibrary),
				season = require(storage.Modules.SeasonLibrary)
			}
		end)
	end

	return rivals
end

local rivals_parts = {}
local damage_up = Color3.fromRGB(90, 209, 107)
local damage_down = Color3.fromRGB(255, 90, 90)
local stat_text = color.Light(uipallet.Text, 0.15)
local label_text = color.Light(uipallet.Text, 0.32)

local weapon_row = Instance.new('Frame')
weapon_row.BackgroundTransparency = 1
weapon_row.Position = UDim2.fromOffset(20, 78)
weapon_row.Size = UDim2.fromOffset(200, 44)
weapon_row.Visible = false
weapon_row.Parent = Holder
rivals_parts[#rivals_parts + 1] = weapon_row
local weapon_layout = Instance.new('UIListLayout')
weapon_layout.FillDirection = Enum.FillDirection.Horizontal
weapon_layout.Padding = UDim.new(0, 8)
weapon_layout.Parent = weapon_row
local weapon_icons = {}
for i = 1, 4 do
	local slot = Instance.new('Frame')
	slot.BackgroundColor3 = color.Dark(uipallet.Main, 0.15)
	slot.BorderSizePixel = 0
	slot.LayoutOrder = i
	slot.Size = UDim2.fromOffset(44, 44)
	slot.Parent = weapon_row
	addCorner(slot, UDim.new(0, 6))
	local border = Instance.new('UIStroke')
	border.Color = color.Light(uipallet.Main, 0.2)
	border.Transparency = 0.45
	border.Parent = slot
	local icon = Instance.new('ImageLabel')
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromScale(0.7, 0.7)
	icon.Image = preview_icons[i]
	icon.ImageColor3 = color.Light(uipallet.Main, 0.6)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = slot
	weapon_icons[i] = icon
end

local divider = Instance.new('Frame')
divider.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
divider.BackgroundTransparency = 0.3
divider.BorderSizePixel = 0
divider.Position = UDim2.fromOffset(20, 134)
divider.Size = UDim2.fromOffset(200, 1)
divider.Visible = false
divider.Parent = Holder
rivals_parts[#rivals_parts + 1] = divider

local function stat_cell(x, y, title, value_color)
	local label = Instance.new('TextLabel')
	label.BackgroundTransparency = 1
	label.FontFace = uipallet.Font
	label.Position = UDim2.fromOffset(x, y)
	label.Size = UDim2.fromOffset(96, 12)
	label.Text = title
	label.TextColor3 = label_text
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Visible = false
	label.Parent = Holder
	font_regular[#font_regular + 1] = label

	local value = Instance.new('TextLabel')
	value.BackgroundTransparency = 1
	value.FontFace = uipallet.FontSemiBold
	value.Position = UDim2.fromOffset(x, y + 13)
	value.Size = UDim2.fromOffset(96, 16)
	value.Text = '--'
	value.TextColor3 = value_color
	value.TextSize = 14
	value.TextTruncate = Enum.TextTruncate.AtEnd
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.Visible = false
	value.Parent = Holder
	font_bold[#font_bold + 1] = value
	rivals_parts[#rivals_parts + 1] = label
	rivals_parts[#rivals_parts + 1] = value
	return value
end
local level_value = stat_cell(20, 146, 'level', accent)
local rank_value = stat_cell(124, 146, 'rank', accent)
local device_value = stat_cell(20, 178, 'device', accent)
local streak_value = stat_cell(124, 178, 'streak', accent)

local ratio_title = Instance.new('TextLabel')
ratio_title.BackgroundTransparency = 1
ratio_title.FontFace = uipallet.Font
ratio_title.Position = UDim2.fromOffset(20, 212)
ratio_title.Size = UDim2.fromOffset(120, 12)
ratio_title.Text = 'damage ratio'
ratio_title.TextColor3 = label_text
ratio_title.TextSize = 11
ratio_title.TextXAlignment = Enum.TextXAlignment.Left
ratio_title.Visible = false
ratio_title.Parent = Holder

local ratio_value = ratio_title:Clone()
ratio_value.FontFace = uipallet.FontSemiBold
ratio_value.Position = UDim2.fromOffset(80, 211)
ratio_value.RichText = true
ratio_value.Size = UDim2.fromOffset(140, 12)
ratio_value.Text = '50 <font color="#5ad16b">▲</font>  50 <font color="#ff5a5a">▼</font>'
ratio_value.TextColor3 = stat_text
ratio_value.TextSize = 11
ratio_value.TextXAlignment = Enum.TextXAlignment.Right
ratio_value.Parent = Holder
font_regular[#font_regular + 1] = ratio_title
font_bold[#font_bold + 1] = ratio_value

local ratio_bg = Instance.new('Frame')
ratio_bg.BackgroundColor3 = color.Dark(uipallet.Main, 0.15)
ratio_bg.BorderSizePixel = 0
ratio_bg.ClipsDescendants = true
ratio_bg.Position = UDim2.fromOffset(20, 228)
ratio_bg.Size = UDim2.fromOffset(200, 5)
ratio_bg.Visible = false
ratio_bg.Parent = Holder
addCorner(ratio_bg, UDim.new(1, 0))
rivals_parts[#rivals_parts + 1] = ratio_title
rivals_parts[#rivals_parts + 1] = ratio_value
rivals_parts[#rivals_parts + 1] = ratio_bg
local ratio_fill = Instance.new('Frame')
ratio_fill.BackgroundColor3 = damage_up
ratio_fill.BorderSizePixel = 0
ratio_fill.Size = UDim2.fromScale(0.5, 1)
ratio_fill.Parent = ratio_bg
addCorner(ratio_fill, UDim.new(0, 2))
local ratio_taken = ratio_fill:Clone()
ratio_taken.AnchorPoint = Vector2.new(1, 0)
ratio_taken.BackgroundColor3 = damage_down
ratio_taken.Position = UDim2.fromScale(1, 0)
ratio_taken.Parent = ratio_bg

local function pick(list)
	return list[math.random(#list)]
end

local function show_weapons(names, items)
	for i = 1, 4 do
		local weapon = names[i]
		local image = weapon and items:GetViewModelImage(weapon) or ''
		if EZ.ThreadFix then
			setthreadidentity(8)
		end

		weapon_icons[i].Image = image
	end
end

local function update_rivals(player)
	local libs = rivals_libs()
	if not libs then return end

	local now = tick()
	local delta = math.min(now - (targetinfo.rivals_time or now), 0.1)
	targetinfo.rivals_time = now

	local subject = player or local_player
	local key = player and subject.UserId or 0
	local fresh = targetinfo.rivals_key ~= key
	targetinfo.rivals_key = key

	local level, rank, device, streak
	if player then
		local fighter = libs.fighters:GetFighter(subject)
		level = subject:GetAttribute('Level') or 0
		rank = libs.season:GetRank(subject:GetAttribute('DisplayELO') or 0, subject.UserId)
		device = devices[fighter and fighter:Get('Controls')] or '?'
		streak = subject:GetAttribute('StatisticDuelsWinStreak') or 0

		if fresh then
			targetinfo.dealt, targetinfo.taken = 0, 0
			targetinfo.last_hp, targetinfo.own_hp = nil, nil
			targetinfo.weapon_time = 0
		end

		if fighter and now - targetinfo.weapon_time > 0.5 then
			targetinfo.weapon_time = now
			local names = {}
			for item in fighter:GetEquippedItems() or {} do
				names[#names + 1] = item.Name
			end
			show_weapons(names[1] and names or {'Assault Rifle', 'Handgun', 'Fists', 'Grenade'}, libs.items)
		end

		local hp = fighter and fighter:GetHealth()
		local own_fighter = libs.fighters:GetFighter(local_player)
		local own = own_fighter and own_fighter:GetHealth()
		if EZ.ThreadFix then
			setthreadidentity(8)
		end

		if hp and targetinfo.last_hp and hp < targetinfo.last_hp then
			targetinfo.dealt += targetinfo.last_hp - hp
		end
		if own and targetinfo.own_hp and own < targetinfo.own_hp then
			targetinfo.taken += targetinfo.own_hp - own
		end
		targetinfo.last_hp, targetinfo.own_hp = hp or targetinfo.last_hp, own or targetinfo.own_hp

		local total = targetinfo.dealt + targetinfo.taken
		targetinfo.ratio = total > 0 and targetinfo.dealt / total or 0.5
	else
		if fresh then
			targetinfo.level = math.random(1, 50)
			targetinfo.rank = pick(ranks)
			targetinfo.device = pick(device_pool)
			targetinfo.streak = math.random(0, 30)
			for i = 1, 4 do
				weapon_icons[i].Image = preview_icons[i]
			end

			Name.Text = DisplayName.Enabled and subject.DisplayName or subject.Name
			Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..subject.UserId..'&w=420&h=420'
		end
		level, rank, device, streak = targetinfo.level, targetinfo.rank, targetinfo.device, targetinfo.streak

		local sweep = 0.5 - 0.5 * math.cos(now * 0.8)
		Health.Size = UDim2.fromScale(sweep, 1)
		HealthText.Text = math.floor(sweep * 100)..' / 100'
		targetinfo.ratio = 0.5 + 0.32 * math.sin(now * 0.45)
	end

	targetinfo.shown = (targetinfo.shown or targetinfo.ratio) + (targetinfo.ratio - (targetinfo.shown or targetinfo.ratio)) * math.min(delta * 4, 1)
	local dealt = math.clamp(math.floor(targetinfo.shown * 100 + 0.5), 0, 100)

	level_value.Text, level_value.TextColor3 = tostring(level), accent
	rank_value.Text, rank_value.TextColor3 = tostring(rank):lower(), accent
	device_value.Text, device_value.TextColor3 = tostring(device), accent
	streak_value.Text, streak_value.TextColor3 = tostring(streak), accent
	ratio_value.Text = dealt..' <font color="#5ad16b">▲</font>  '..(100 - dealt)..' <font color="#ff5a5a">▼</font>'
	ratio_fill.Size = UDim2.fromScale(targetinfo.shown, 1)
	ratio_taken.Size = UDim2.fromScale(1 - targetinfo.shown, 1)
end

TargetInfoOverlay:CreateFont({
	Name = 'Font',
	Default = 'Arial',
	Function = function(val)
		local bold = Font.new(val.Family, Enum.FontWeight.SemiBold)
		for _, obj in font_regular do
			obj.FontFace = val
		end
		for _, obj in font_bold do
			obj.FontFace = bold
		end
	end
})
DisplayName = TargetInfoOverlay:CreateToggle({
	Name = 'Use Displayname',
	Default = true
})
TargetInfoOverlay:CreateToggle({
	Name = 'Render Background',
	Function = function(callback)
		Holder.BackgroundTransparency = callback and BackgroundTransparency.Value or 1
		NameShadow.Visible = not callback
		BlurHolder.Visible = callback
		HealthBlur.Enabled = not callback
		HeadshotBlur.Enabled = not callback
		BackgroundTransparency.Object.Visible = callback
	end,
	Default = true
})
BackgroundTransparency = TargetInfoOverlay:CreateSlider({
	Name = 'Transparency',
	Min = 0,
	Max = 1,
	Default = 0.1,
	Decimal = 10,
	Function = function(val)
		Holder.BackgroundTransparency = val
	end,
	Darker = true
})
CustomColor = TargetInfoOverlay:CreateToggle({
	Name = 'Custom Color',
	Function = function(callback)
		BKGColor.Object.Visible = callback
		if callback then
			Holder.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, BKGColor.Value)
			Headshot.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, math.max(BKGColor.Value - 0.1, 0.075))
			HealthBKG.BackgroundColor3 = Headshot.BackgroundColor3
		else
			Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.05)
			Headshot.BackgroundColor3 = uipallet.Main
			HealthBKG.BackgroundColor3 = uipallet.Main
		end
	end
})
BKGColor = TargetInfoOverlay:CreateColorSlider({
	Name = 'Color',
	Function = function(hue, sat, val)
		if CustomColor.Enabled then
			Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			Headshot.BackgroundColor3 = Color3.fromHSV(hue, sat, math.max(val - 0.1, 0))
			HealthBKG.BackgroundColor3 = Headshot.BackgroundColor3
		end
	end,
	Darker = true,
	Visible = false
})
TargetInfoOverlay:CreateToggle({
	Name = 'Border',
	Function = function(callback)
		Stroke.Enabled = callback
		BorderColor.Object.Visible = callback
	end
})
BorderColor = TargetInfoOverlay:CreateColorSlider({
	Name = 'Border Color',
	Function = function(hue, sat, val, opacity)
		Stroke.Color = Color3.fromHSV(hue, sat, val)
		Stroke.Transparency = 1 - opacity
	end,
	Darker = true,
	Visible = false
})

function targetinfo:Update()
	local entitylib = EZ.Libraries
	if not entitylib then return end

	accent = Color3.fromHSV(EZ.GUIColor.Hue, EZ.GUIColor.Sat, EZ.GUIColor.Value)
	Health.BackgroundColor3 = accent

	local tucked = clickgui.Visible
	local is_rivals = EZ.game == 'Rivals'
	Holder.Position = UDim2.fromOffset(0, tucked and -6 or 0)
	Holder.Size = UDim2.fromOffset(240, (tucked and 96 or 90) + (is_rivals and rivals_extra_height or 0))
	for _, part in rivals_parts do
		part.Visible = is_rivals
	end

	local cloned = table.clone(self.Targets)
	for index, expire in cloned do
		if expire < tick() then
			self.Targets[index] = nil
		end
	end
	table.clear(cloned)

	local entity, highest = nil, tick()
	for index, level in self.Targets do
		if level > highest then
			entity = index
			highest = level
		end
	end

	Holder.Visible = entity ~= nil or clickgui.Visible

	if is_rivals and Holder.Visible then
		update_rivals(entity and entity.Player or nil)
	end

	if entity then
		if entity == self.Manual and entity.Player then
			local libs = is_rivals and rivals_libs()
			local fighter = libs and libs.fighters:GetFighter(entity.Player)
			local humanoid = not fighter and entity.Player.Character and entity.Player.Character:FindFirstChildWhichIsA('Humanoid')
			entity.Character = nil
			entity.Health = fighter and fighter:GetHealth() or humanoid and humanoid.Health or 0
			entity.MaxHealth = fighter and fighter:GetMaxHealth() or humanoid and humanoid.MaxHealth or 100

			if fighter and EZ.ThreadFix then
				setthreadidentity(8)
			end
		end

		Name.Text = entity.Player and (DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character and entity.Character.Name or Name.Text
		Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..(entity.Player and entity.Player.UserId or 1)..'&w=420&h=420'

		if not entity.Character then
			entity.Health = entity.Health or 0
			entity.MaxHealth = entity.MaxHealth or 100
		end

		if entity.Health ~= self.Health or entity.MaxHealth ~= self.MaxHealth then
			local percent = math.max(entity.Health / entity.MaxHealth, 0)
			HealthText.Text = math.floor(entity.Health)..' / '..math.floor(entity.MaxHealth)

			tween:Tween(Health, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(math.min(percent, 1), 1)
			})

			tween:Tween(Armor, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(math.clamp(percent - 1, 0, 0.8), 1)
			})

			if self.Health > entity.Health and self.LastTarget == entity then
				tween:Cancel(HurtFlash)
				HurtFlash.BackgroundTransparency = 0.3
				tween:Tween(HurtFlash, TweenInfo.new(0.5), {
					BackgroundTransparency = 1
				})
			end

			self.Health = entity.Health
			self.MaxHealth = entity.MaxHealth
		end

		if not entity.Character and entity ~= self.Manual then
			table.clear(entity)
		end

		self.LastTarget = entity
	end
end

function EZ:SetTarget(target)
	if typeof(target) == 'Instance' and targetinfo.Manual and targetinfo.Manual.Player == target then
		return
	end

	if targetinfo.Manual then
		targetinfo.Targets[targetinfo.Manual] = nil
		targetinfo.Manual = nil
	end

	if not target then
		return
	end

	local entity = typeof(target) == 'Instance' and {Player = target} or target
	targetinfo.Manual = entity
	targetinfo.Targets[entity] = math.huge
end

function EZ:GetTarget()
	return targetinfo.Manual and (targetinfo.Manual.Player or targetinfo.Manual)
end

EZ.Libraries.targetinfo = targetinfo
