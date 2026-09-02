local EZ = loadstring(game:HttpGet('https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/libraries/gui.lua', true))()
EZ.game = 'rivals'

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

farm:CreateBind({
	Name = 'Toggle Key',
	Default = {'RightControl'},
	NoRemove = true
})

EZ:Load()
