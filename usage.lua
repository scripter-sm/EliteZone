local gui_url = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/libraries/gui.lua'
local version_url = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/version.dat'
local cache_path = 'Elite Zone/Cache/__gui.lua'

for _, path in {'Elite Zone', 'Elite Zone/Cache'} do
	if not isfolder(path) then
		makefolder(path)
	end
end

-- a cached bundle that fails to compile is worse than no cache, so fall back to a fresh download
local source = isfile(cache_path) and readfile(cache_path)
local chunk = source and loadstring(source)
if not chunk then
	source = game:HttpGet(gui_url, true)
	writefile(cache_path, source)
	chunk = loadstring(source)
end

local EZ = chunk()

-- the compiler stamps the version into the first line, so the cached copy is checked against
-- version.dat instead of redownloading the bundle; a stale one is replaced for the next run only
task.spawn(function()
	local ok, data = pcall(game.HttpGet, game, version_url, true)
	if not ok then return end

	local latest = data:match('"version"%s*:%s*"(.-)"')
	if not latest or source:match('^[^\n]*%[(.-)%]') == latest then return end

	local fresh_ok, fresh = pcall(game.HttpGet, game, gui_url, true)
	if fresh_ok and fresh ~= '' then
		writefile(cache_path, fresh)
	end
end)
EZ.game = 'Rivals'

local farm = EZ.Categories.Combat:CreateModule({
	Name = 'Auto Farm',
	Function = function(enabled)
		print('Auto Farm', enabled)
	end
})

farm:CreateToggle({
	Name = 'Auto Collect',
	Default = true,
	Function = function(enabled)
		print('Auto Collect', enabled)
	end
})

farm:CreateSlider({
	Name = 'Speed',
	Min = 1,
	Max = 10,
	Default = 5,
	Function = function(value)
		print('Speed', value)
	end
})

EZ:Load()
EZ:CreateNotification('Elite Zone', 'Script loaded.', 5, 'info')

local players = game:GetService('Players')
local run_service = game:GetService('RunService')
local local_player = players.LocalPlayer

run_service.Heartbeat:Connect(function()
	local character = local_player.Character
	local origin = character and character:FindFirstChild('HumanoidRootPart')

	local nearest, closest = nil, math.huge
	if origin then
		for _, player in players:GetPlayers() do
			local part = player ~= local_player and player.Character and player.Character:FindFirstChild('HumanoidRootPart')
			if part then
				local distance = (part.Position - origin.Position).Magnitude
				if distance < closest then
					nearest, closest = player, distance
				end
			end
		end
	end

	EZ:SetTarget(nearest)
end)
