do
	local assets_url = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/'
	local get_asset_fn = getcustomasset or getsynasset

	local ezAssets = {
		['Elite Zone/Assets/add.png'] = 'rbxassetid://121642387707174',
		['Elite Zone/Assets/aim.png'] = 'rbxassetid://122207028123421',
		['Elite Zone/Assets/allowedicon.png'] = 'rbxassetid://112336790299036',
		['Elite Zone/Assets/allowediconmini.png'] = 'rbxassetid://90142384730147',
		['Elite Zone/Assets/backmini.png'] = 'rbxassetid://85859225495272',
		['Elite Zone/Assets/bind.png'] = 'rbxassetid://81399857677684',
		['Elite Zone/Assets/bindbkg.png'] = 'rbxassetid://101996225428926',
		['Elite Zone/Assets/blatant.png'] = 'rbxassetid://126929923309265',
		['Elite Zone/Assets/blur.png'] = 'rbxassetid://79246816170155',
		['Elite Zone/Assets/blurnoti.png'] = 'rbxassetid://124705876663719',
		['Elite Zone/Assets/close.png'] = 'rbxassetid://121816018671466',
		['Elite Zone/Assets/closemini.png'] = 'rbxassetid://108320409341289',
		['Elite Zone/Assets/closetiny.png'] = 'rbxassetid://71393233149714',
		['Elite Zone/Assets/colorpreview.png'] = 'rbxassetid://140438628568318',
		['Elite Zone/Assets/combat.png'] = 'rbxassetid://94762732349053',
		['Elite Zone/Assets/discord.png'] = 'rbxassetid://99871463341003',
		['Elite Zone/Assets/downexpand.png'] = 'rbxassetid://94197751291504',
		['Elite Zone/Assets/edit.png'] = 'rbxassetid://105801951237137',
		['Elite Zone/Assets/editlarge.png'] = 'rbxassetid://119233876755282',
		['Elite Zone/Assets/expandarrow.png'] = 'rbxassetid://86360332526471',
		['Elite Zone/Assets/friends.png'] = 'rbxassetid://92957214042038',
		['Elite Zone/Assets/inventory.png'] = 'rbxassetid://93264756888499',
		['Elite Zone/Assets/noti_alert.png'] = 'rbxassetid://82356478726846',
		['Elite Zone/Assets/noti_info.png'] = 'rbxassetid://102614825645099',
		['Elite Zone/Assets/noti_warning.png'] = 'rbxassetid://119631730212167',
		['Elite Zone/Assets/notification.png'] = 'rbxassetid://90300780458781',
		['Elite Zone/Assets/npcs.png'] = 'rbxassetid://104434365485227',
		['Elite Zone/Assets/overlaydots.png'] = 'rbxassetid://78012624671930',
		['Elite Zone/Assets/overlays.png'] = 'rbxassetid://136535637407545',
		['Elite Zone/Assets/overlayslarge.png'] = 'rbxassetid://127574141208160',
		['Elite Zone/Assets/pin.png'] = 'rbxassetid://92459145800579',
		['Elite Zone/Assets/players.png'] = 'rbxassetid://105137446428129',
		['Elite Zone/Assets/configs.png'] = 'rbxassetid://126051451865127',
		['Elite Zone/Assets/radar.png'] = 'rbxassetid://97983828696086',
		['Elite Zone/Assets/range.png'] = 'rbxassetid://107794917650053',
		['Elite Zone/Assets/rangeindicator.png'] = 'rbxassetid://107038094175283',
		['Elite Zone/Assets/render.png'] = 'rbxassetid://125472576898654',
		['Elite Zone/Assets/search.png'] = 'rbxassetid://115611852955611',
		['Elite Zone/Assets/settingdots.png'] = 'rbxassetid://130896840048276',
		['Elite Zone/Assets/settings.png'] = 'rbxassetid://73820177347303',
		['Elite Zone/Assets/targetinfo.png'] = 'rbxassetid://121604266095276',
		['Elite Zone/Assets/textgui.png'] = 'rbxassetid://99438663817412',
		['Elite Zone/Assets/theme.png'] = 'rbxassetid://111525258317113',
		['Elite Zone/Assets/utility.png'] = 'rbxassetid://108303206513893',
		['Elite Zone/Assets/EZ.png'] = 'rbxassetid://92153855792786',
		['Elite Zone/Assets/logo.png'] = '',
		['Elite Zone/Assets/world.png'] = 'rbxassetid://118917453153459'
	}

	local function createDownloader(text)
		if EZ.Loaded ~= true then
			local downloader = EZ.Downloader
			if not downloader then
				downloader = Instance.new('TextLabel')
				downloader.BackgroundTransparency = 1
				downloader.FontFace = uipallet.Font
				downloader.Size = UDim2.new(1, 0, 0, 40)
				downloader.TextColor3 = Color3.new(1, 1, 1)
				downloader.TextSize = 20
				downloader.TextStrokeTransparency = 0
				downloader.Parent = EZ.gui
				EZ.Downloader = downloader
			end

			downloader.Text = 'Downloading '..text
		end
	end

	local function is_png(data)
		return type(data) == 'string' and data:sub(1, 8) == '\137PNG\r\n\26\n'
	end

	local function downloadFile(path)
		if isfile(path) and is_png(readfile(path)) then
			return true
		end

		createDownloader(path)

		local success, data = pcall(function()
			return game:HttpGet(assets_url..path:gsub('.*/', ''), true)
		end)

		if not success or not is_png(data) then
			return false
		end

		writefile(path, data)
		return true
	end

	-- components resolve their icons per instance, so the same path arrives hundreds of times a
	-- load; without this every one re-reads the whole png off disk just to check the header
	local resolved = {}

	get_ez_asset = get_asset_fn and function(path)
		local id = resolved[path]
		if not id then
			id = downloadFile(path) and get_asset_fn(path) or ezAssets[path] or ''
			resolved[path] = id
		end

		return id
	end or function(path)
		return ezAssets[path] or ''
	end
end

getezasset = get_ez_asset

-- icons a script can pick from by name, sized to the artwork
EZ.CategoryIcons = {
	combat = {Asset = 'Elite Zone/Assets/combat.png', Size = UDim2.fromOffset(13, 14)},
	blatant = {Asset = 'Elite Zone/Assets/blatant.png', Size = UDim2.fromOffset(14, 14)},
	render = {Asset = 'Elite Zone/Assets/render.png', Size = UDim2.fromOffset(15, 14)},
	utility = {Asset = 'Elite Zone/Assets/utility.png', Size = UDim2.fromOffset(15, 14)},
	world = {Asset = 'Elite Zone/Assets/world.png', Size = UDim2.fromOffset(14, 14)},
	inventory = {Asset = 'Elite Zone/Assets/inventory.png', Size = UDim2.fromOffset(15, 14)},
	aim = {Asset = 'Elite Zone/Assets/aim.png', Size = UDim2.fromOffset(18, 12)},
	friends = {Asset = 'Elite Zone/Assets/friends.png', Size = UDim2.fromOffset(17, 16)},
	players = {Asset = 'Elite Zone/Assets/players.png', Size = UDim2.fromOffset(16, 16)},
	npcs = {Asset = 'Elite Zone/Assets/npcs.png', Size = UDim2.fromOffset(12, 16)},
	radar = {Asset = 'Elite Zone/Assets/radar.png', Size = UDim2.fromOffset(14, 14)},
	range = {Asset = 'Elite Zone/Assets/range.png', Size = UDim2.fromOffset(9, 16)},
	targetinfo = {Asset = 'Elite Zone/Assets/targetinfo.png', Size = UDim2.fromOffset(14, 14)},
	textgui = {Asset = 'Elite Zone/Assets/textgui.png', Size = UDim2.fromOffset(16, 12)},
	notification = {Asset = 'Elite Zone/Assets/notification.png', Size = UDim2.fromOffset(15, 15)},
	search = {Asset = 'Elite Zone/Assets/search.png', Size = UDim2.fromOffset(14, 14)},
	settings = {Asset = 'Elite Zone/Assets/settings.png', Size = UDim2.fromOffset(14, 14)},
	configs = {Asset = 'Elite Zone/Assets/configs.png', Size = UDim2.fromOffset(17, 10)},
	pin = {Asset = 'Elite Zone/Assets/pin.png', Size = UDim2.fromOffset(14, 14)},
	overlays = {Asset = 'Elite Zone/Assets/overlays.png', Size = UDim2.fromOffset(14, 14)},
	theme = {Asset = 'Elite Zone/Assets/theme.png', Size = UDim2.fromOffset(26, 12)},
	add = {Asset = 'Elite Zone/Assets/add.png', Size = UDim2.fromOffset(16, 16)},
	edit = {Asset = 'Elite Zone/Assets/edit.png', Size = UDim2.fromOffset(10, 10)}
}
