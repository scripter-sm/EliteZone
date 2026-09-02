local EZ = loadstring(game:HttpGet('https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/libraries/gui.lua', true))()
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
