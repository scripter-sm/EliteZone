do
	local fonts_url = 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/Dependencies/fonts/'
	local get_asset_fn = getcustomasset or getsynasset

	ez_fonts = {
		Burbank = {{'Burbank-Big-Condensed.otf', 400}},
		Comfortaa = {{'Comfortaa-Regular.ttf', 400}},
		Eurostile = {{'Eurostile-Extended.ttf', 400}},
		['Hanken Grotesk'] = {{'Hanken-Grotesk-Semi-Bold.ttf', 400}},
		Inter = {{'Inter-Medium.ttf', 400}, {'Inter-Semi-Bold.ttf', 600}},
		['Light Modern'] = {{'Light-Modern.ttf', 400}},
		Minecraftia = {{'Minecraftia-Regular.ttf', 400}},
		Monocraft = {{'Monocraft.ttf', 400}, {'Monocraft-Bold.ttf', 700}},
		['Open Sans Px'] = {{'Open-Sans-Px.ttf', 400}},
		['Pixel Arial'] = {{'Pixel-Arial.ttf', 400}},
		['Proggy Clean'] = {{'Proggy-Clean.ttf', 400}},
		['Proggy Tiny'] = {{'Proggy-Tiny.ttf', 400}},
		Rubik = {{'Rubik-Regular.ttf', 400}},
		Silkscreen = {{'Silkscreen.ttf', 400}},
		['Smallest Pixel'] = {{'Smallest-Pixel.ttf', 400}},
		['Smallest Pixel 7'] = {{'Smallest-Pixel-7.ttf', 400}},
		['Tahoma 8px'] = {{'Fs-Tahoma-8-Px.ttf', 400}},
		['Tahoma Custom'] = {{'Tahoma.ttf', 400}, {'Tahoma-Bold.ttf', 700}},
		['Tahoma Modern'] = {{'Tahoma-Modern.ttf', 400}, {'Tahoma-Modern-Bold.ttf', 700}},
		['Verdana Custom'] = {{'Verdana-Font.ttf', 400}}
	}

	ez_font_names = {}
	for name in ez_fonts do
		ez_font_names[#ez_font_names + 1] = name
	end
	table.sort(ez_font_names)

	local cache = {}

	local function download(file)
		local path = 'Elite Zone/Assets/'..file
		if isfile(path) then
			return path
		end

		local success, data = pcall(function()
			return game:HttpGet(fonts_url..file, true)
		end)

		if not success or #data < 1024 then
			return
		end

		writefile(path, data)
		return path
	end

	-- builds a roblox font family file whose faces point at the downloaded ttf/otf assets
	get_ez_font = get_asset_fn and function(name)
		local cached = cache[name]
		if cached ~= nil then
			return cached or nil
		end

		local faces = ez_fonts[name]
		if not faces then
			return
		end

		local built = table.create(#faces)
		for i, face in faces do
			local file = download(face[1])
			if not file then
				cache[name] = false
				return
			end

			built[i] = string.format('{"name":"%d","weight":%d,"style":"normal","assetId":"%s"}', face[2], face[2], get_asset_fn(file))
		end

		local path = 'Elite Zone/Assets/'..name:gsub(' ', '')..'.font'
		writefile(path, '{"name":"'..name..'","faces":['..table.concat(built, ',')..']}')

		local font = Font.new(get_asset_fn(path))
		cache[name] = font
		return font
	end or function() end
end

getezfont = get_ez_font
