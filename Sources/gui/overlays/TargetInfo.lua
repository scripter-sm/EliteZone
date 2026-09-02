

local targetinfo = {
	Targets = {},
	Object = Holder,
	Health = 0,
	MaxHealth = 0
}
local TargetInfoOverlay
local BackgroundTransparency = {
	Value = 0.5,
	Object = {Visible = {}}
}
local BorderColor
local BKGColor
local CustomColor
local DisplayName

local local_player = cloneref(game:GetService('Players')).LocalPlayer
local target_gui = Instance.new('ScreenGui')
target_gui.Name = randomString()
target_gui.DisplayOrder = 9999999
target_gui.IgnoreGuiInset = true
target_gui.ResetOnSpawn = false
target_gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
target_gui.Enabled = false
target_gui.Parent = local_player.PlayerGui
local target_scale = Instance.new('UIScale')
target_scale.Scale = scale.Scale
target_scale.Parent = target_gui
EZ:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
	target_scale.Scale = scale.Scale
end))

TargetInfoOverlay = EZ:CreateOverlay({
	Name = 'Target Info',
	Icon = get_ez_asset('Elite Zone/Assets/targetinfo.png'),
	Size = UDim2.fromOffset(14, 14),
	Position = UDim2.fromOffset(12, 14),
	CategorySize = 240,
	Function = function(callback)
		target_gui.Enabled = callback
		if callback then
			TargetInfoOverlay:Clean(runService.RenderStepped:Connect(function()
				targetinfo:Update()
			end))
		end
	end
})

local Holder = Instance.new('Frame')
Holder.Size = UDim2.fromOffset(240, 96)
Holder.Position = UDim2.fromOffset(0, -6)
Holder.ZIndex = 0
Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
Holder.BackgroundTransparency = 0.5
Holder.Parent = target_gui
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
Health.BackgroundColor3 = Color3.fromHSV(1 / 2.5, 0.89, 0.75)
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
local Stroke = Instance.new('UIStroke')
Stroke.Enabled = false
Stroke.Color = Color3.fromHSV(0.44, 1, 1)
Stroke.Parent = Holder

local rivals_extra_height = 112
local devices = {MouseKeyboard = 'computer', Touch = 'mobile', Gamepad = 'controller', VR = 'vr'}
local device_pool = {'computer', 'mobile', 'controller', 'vr'}
local ranks = {
	'Bronze 1', 'Bronze 2', 'Bronze 3', 'Silver 1', 'Silver 2', 'Silver 3',
	'Gold 1', 'Gold 2', 'Gold 3', 'Platinum 1', 'Platinum 2', 'Platinum 3',
	'Diamond 1', 'Diamond 2', 'Diamond 3', 'Onyx 1', 'Onyx 2', 'Onyx 3', 'Nemesis'
}
local weapon_pool = {
	'Assault Rifle', 'Burst Rifle', 'Energy Rifle', 'Minigun', 'Sniper', 'Shotgun',
	'Shorty', 'Uzi', 'Revolver', 'Handgun', 'Energy Pistols', 'Bow', 'Crossbow',
	'RPG', 'Grenade Launcher', 'Flamethrower', 'Katana', 'Scythe', 'Battle Axe',
	'Spear', 'Daggers', 'Knife', 'Fists', 'Grenade', 'Molotov', 'Riot Shield'
}
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

local rivals_box = Instance.new('Frame')
rivals_box.Name = 'Rivals'
rivals_box.BackgroundColor3 = color.Dark(uipallet.Main, 0.05)
rivals_box.BorderSizePixel = 0
rivals_box.Position = UDim2.fromOffset(10, 74)
rivals_box.Size = UDim2.fromOffset(220, 122)
rivals_box.Visible = false
rivals_box.Parent = Holder
addCorner(rivals_box)
local weapon_row = Instance.new('Frame')
weapon_row.BackgroundTransparency = 1
weapon_row.Position = UDim2.fromOffset(8, 8)
weapon_row.Size = UDim2.fromOffset(204, 40)
weapon_row.Parent = rivals_box
local weapon_layout = Instance.new('UIListLayout')
weapon_layout.FillDirection = Enum.FillDirection.Horizontal
weapon_layout.Padding = UDim.new(0, 6)
weapon_layout.Parent = weapon_row
local weapon_icons, weapon_labels = {}, {}
for i = 1, 4 do
	local slot = Instance.new('Frame')
	slot.BackgroundColor3 = uipallet.Main
	slot.BorderSizePixel = 0
	slot.LayoutOrder = i
	slot.Size = UDim2.fromOffset(46, 40)
	slot.Parent = weapon_row
	addCorner(slot, UDim.new(0, 4))
	local icon = Instance.new('ImageLabel')
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromOffset(3, 1)
	icon.Size = UDim2.fromOffset(40, 27)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = slot
	local label = Instance.new('TextLabel')
	label.BackgroundTransparency = 1
	label.FontFace = uipallet.Font
	label.Position = UDim2.fromOffset(0, 28)
	label.Size = UDim2.fromOffset(46, 10)
	label.Text = ''
	label.TextColor3 = color.Dark(uipallet.Text, 0.2)
	label.TextSize = 8
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = slot
	weapon_icons[i], weapon_labels[i] = icon, label
end

local function line(x, y, width)
	local label = Instance.new('TextLabel')
	label.BackgroundTransparency = 1
	label.FontFace = uipallet.Font
	label.Position = UDim2.fromOffset(x, y)
	label.RichText = true
	label.Size = UDim2.fromOffset(width, 14)
	label.TextColor3 = color.Light(uipallet.Text, 0.3)
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rivals_box
	return label
end
local name_line = line(8, 52, 204)
local stat_line = line(8, 69, 204)
local device_line = line(8, 86, 204)
local health_line = line(8, 103, 70)
local ratio_line = line(84, 103, 128)

local function pick(list)
	return list[math.random(#list)]
end

local function show_weapons(names, items)
	for i = 1, 4 do
		local weapon = names[i]
		weapon_icons[i].Image = weapon and items:GetViewModelImage(weapon) or ''
		weapon_labels[i].Text = weapon or ''
	end
end

local function update_rivals(player)
	if EZ.ThreadFix then
		setthreadidentity(8)
	end

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
		if hp and targetinfo.last_hp and hp < targetinfo.last_hp then
			targetinfo.dealt += targetinfo.last_hp - hp
		end
		if own and targetinfo.own_hp and own < targetinfo.own_hp then
			targetinfo.taken += targetinfo.own_hp - own
		end
		targetinfo.last_hp, targetinfo.own_hp = hp or targetinfo.last_hp, own or targetinfo.own_hp

		local total = targetinfo.dealt + targetinfo.taken
		targetinfo.ratio = total > 0 and targetinfo.dealt / total or 0.5
		health_line.Text = hp and (math.floor(hp)..'/'..math.floor(fighter:GetMaxHealth() or 100)) or '--'
	else
		if fresh then
			targetinfo.level = math.random(1, 50)
			targetinfo.rank = pick(ranks)
			targetinfo.device = pick(device_pool)
			targetinfo.streak = math.random(0, 30)
			targetinfo.weapons = {pick(weapon_pool), pick(weapon_pool), pick(weapon_pool), pick(weapon_pool)}
			show_weapons(targetinfo.weapons, libs.items)
		end
		level, rank, device, streak = targetinfo.level, targetinfo.rank, targetinfo.device, targetinfo.streak

		local sweep = 0.5 - 0.5 * math.cos(now * 0.8)
		Health.Size = UDim2.fromScale(sweep, 1)
		Health.BackgroundColor3 = Color3.fromHSV(math.clamp(sweep / 2.5, 0, 1), 0.89, 0.75)
		health_line.Text = math.floor(sweep * 100)..'/100'
		targetinfo.ratio = 0.5 + 0.32 * math.sin(now * 0.45)
	end

	targetinfo.shown = (targetinfo.shown or targetinfo.ratio) + (targetinfo.ratio - (targetinfo.shown or targetinfo.ratio)) * math.min(delta * 4, 1)
	local dealt = math.clamp(math.floor(targetinfo.shown * 100 + 0.5), 0, 100)

	name_line.Text = '@'..subject.Name
	stat_line.Text = 'lvl '..level..'  ·  '..rank
	device_line.Text = device..'  ·  streak '..streak
	ratio_line.Text = dealt..' <font color="#5ad16b">▲</font>   '..(100 - dealt)..' <font color="#ff5a5a">▼</font>'
end

TargetInfoOverlay:CreateFont({
	Name = 'Font',
	Default = 'Arial',
	Function = function(val)
		Name.FontFace = val
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
	Default = 0.5,
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
			Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
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

	local tucked = clickgui.Visible
	local is_rivals = EZ.game == 'Rivals'
	Holder.Position = UDim2.fromOffset(0, tucked and -6 or 0)
	Holder.Size = UDim2.fromOffset(240, (tucked and 96 or 90) + (is_rivals and rivals_extra_height or 0))
	rivals_box.Visible = is_rivals or false

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
		end

		Name.Text = entity.Player and (DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character and entity.Character.Name or Name.Text
		Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..(entity.Player and entity.Player.UserId or 1)..'&w=420&h=420'

		if not entity.Character then
			entity.Health = entity.Health or 0
			entity.MaxHealth = entity.MaxHealth or 100
		end

		if entity.Health ~= self.Health or entity.MaxHealth ~= self.MaxHealth then
			local percent = math.max(entity.Health / entity.MaxHealth, 0)

			tween:Tween(Health, TweenInfo.new(0.3), {
				Size = UDim2.fromScale(math.min(percent, 1), 1), BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
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
