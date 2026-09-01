do
	local assetsUrl = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/'
	local getassetfn = getcustomasset or getsynasset

	local ezAssets = {
		['Elite Zone/Assets/add.png'] = 'rbxassetid://121642387707174',
		['Elite Zone/Assets/aim.png'] = 'rbxassetid://122207028123421',
		['Elite Zone/Assets/allowedicon.png'] = 'rbxassetid://112336790299036',
		['Elite Zone/Assets/allowediconmini.png'] = 'rbxassetid://90142384730147',
		['Elite Zone/Assets/back.png'] = 'rbxassetid://80523803497740',
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
		['Elite Zone/Assets/customtheme.png'] = 'rbxassetid://91756736022800',
		['Elite Zone/Assets/discord.png'] = 'rbxassetid://99871463341003',
		['Elite Zone/Assets/downexpand.png'] = 'rbxassetid://94197751291504',
		['Elite Zone/Assets/downexpandslider.png'] = 'rbxassetid://90289944682645',
		['Elite Zone/Assets/edit.png'] = 'rbxassetid://105801951237137',
		['Elite Zone/Assets/editlarge.png'] = 'rbxassetid://119233876755282',
		['Elite Zone/Assets/expandarrow.png'] = 'rbxassetid://86360332526471',
		['Elite Zone/Assets/friends.png'] = 'rbxassetid://92957214042038',
		['Elite Zone/Assets/inventory.png'] = 'rbxassetid://93264756888499',
		['Elite Zone/Assets/legit_mode_icon.png'] = 'rbxassetid://102858626075156',
		['Elite Zone/Assets/legit_switch.png'] = 'rbxassetid://127508881124779',
		['Elite Zone/Assets/min.png'] = 'rbxassetid://82175054487146',
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
		['Elite Zone/Assets/rainbow_1.png'] = 'rbxassetid://101329996188554',
		['Elite Zone/Assets/rainbow_2.png'] = 'rbxassetid://72739074644654',
		['Elite Zone/Assets/rainbow_3.png'] = 'rbxassetid://100716555253397',
		['Elite Zone/Assets/rainbow_4.png'] = 'rbxassetid://133424174227092',
		['Elite Zone/Assets/range.png'] = 'rbxassetid://107794917650053',
		['Elite Zone/Assets/rangeindicator.png'] = 'rbxassetid://107038094175283',
		['Elite Zone/Assets/render.png'] = 'rbxassetid://125472576898654',
		['Elite Zone/Assets/search.png'] = 'rbxassetid://115611852955611',
		['Elite Zone/Assets/settingdots.png'] = 'rbxassetid://130896840048276',
		['Elite Zone/Assets/settings.png'] = 'rbxassetid://73820177347303',
		['Elite Zone/Assets/settingsmini.png'] = 'rbxassetid://115732118290997',
		['Elite Zone/Assets/targetinfo.png'] = 'rbxassetid://121604266095276',
		['Elite Zone/Assets/textgui.png'] = 'rbxassetid://99438663817412',
		['Elite Zone/Assets/theme.png'] = 'rbxassetid://111525258317113',
		['Elite Zone/Assets/utility.png'] = 'rbxassetid://108303206513893',
		['Elite Zone/Assets/EZ.png'] = 'rbxassetid://92153855792786',
		['Elite Zone/Assets/vapelogo.png'] = 'rbxassetid://126205920310261',
		['Elite Zone/Assets/vapelogomini.png'] = 'rbxassetid://109041903452149',
		['Elite Zone/Assets/v4.png'] = 'rbxassetid://102549752760489',
		['Elite Zone/Assets/v4mini.png'] = 'rbxassetid://115213099001611',
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

	-- path looks like 'Elite Zone/Assets/combat.png'; the GitHub folder is flat
	-- (Dependencies/assets/combat.png) so we only need the file name for the URL.
	local function downloadFile(path, callback)
		if not isfile(path) then
			createDownloader(path)

			local fileName = path:match('([^/]+)$')
			local success, data = pcall(function()
				return game:HttpGet(assetsUrl..fileName, true)
			end)

			if not success or data == nil or data == '' or data == '404: Not Found' then
				error('[ Elite Zone ] Failed to download asset "'..tostring(fileName)..'": '..tostring(data))
			end

			writefile(path, data)
		end

		return (callback or readfile)(path)
	end

	-- download the real assets from GitHub when the executor can turn a cached
	-- file into an asset; otherwise fall back to the pre-uploaded asset ids.
	get_ez_asset = getassetfn and function(path)
		return downloadFile(path, getassetfn)
	end or function(path)
		return ezAssets[path] or ''
	end
end

getezasset = get_ez_asset
