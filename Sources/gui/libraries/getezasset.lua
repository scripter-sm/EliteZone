do
	local assetsUrl = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/assets/'
	local getassetfn = getcustomasset or getsynasset

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

	get_ez_asset = function(path)
		return downloadFile(path, getassetfn)
	end
end

getezasset = get_ez_asset
