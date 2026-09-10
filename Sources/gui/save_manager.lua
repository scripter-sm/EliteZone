local SaveManager = {};

do
	SaveManager.Ignore = {};
	SaveManager.Library = EZ;

	SaveManager.Parser = {
		Toggle = {
			Save = function(Idx, Object)
				return { type = 'Toggle', idx = Idx, value = Object.Value };
			end;
			Load = function(Idx, Data)
				if Toggles[Idx] then
					Toggles[Idx]:SetValue(Data.value);
				end;
			end;
		};
		Slider = {
			Save = function(Idx, Object)
				return { type = 'Slider', idx = Idx, value = tostring(Object.Value) };
			end;
			Load = function(Idx, Data)
				if Options[Idx] then
					Options[Idx]:SetValue(Data.value);
				end;
			end;
		};
		Dropdown = {
			Save = function(Idx, Object)
				return { type = 'Dropdown', idx = Idx, value = Object.Value, mutli = Object.Multi };
			end;
			Load = function(Idx, Data)
				if Options[Idx] then
					Options[Idx]:SetValue(Data.value);
				end;
			end;
		};
		ColorPicker = {
			Save = function(Idx, Object)
				return { type = 'ColorPicker', idx = Idx, value = Object.Value:ToHex(), transparency = Object.Transparency };
			end;
			Load = function(Idx, Data)
				if Options[Idx] then
					Options[Idx]:SetValueRGB(Color3.fromHex(Data.value), Data.transparency);
				end;
			end;
		};
		KeyPicker = {
			Save = function(Idx, Object)
				return { type = 'KeyPicker', idx = Idx, mode = Object.Mode, key = Object.Value };
			end;
			Load = function(Idx, Data)
				if Options[Idx] then
					Options[Idx]:SetValue({ Data.key, Data.mode });
				end;
			end;
		};
		Input = {
			Save = function(Idx, Object)
				return { type = 'Input', idx = Idx, text = Object.Value };
			end;
			Load = function(Idx, Data)
				if Options[Idx] and type(Data.text) == 'string' then
					Options[Idx]:SetValue(Data.text);
				end;
			end;
		};
	};

	function SaveManager:ConfigFolder()
		return 'Elite Zone/' .. EZ.Game:lower() .. '/config';
	end;

	function SaveManager:CheckFolderTree()
		EZ:EnsureFolders();
	end;

	function SaveManager:SetIgnoreIndexes(List)
		for _, Key in next, List do
			self.Ignore[Key] = true;
		end;
	end;

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({
			'ThemeManager_ThemeList',
			'ThemeManager_CustomThemeList',
			'ThemeManager_CustomThemeName',

			'FontColor', 'MainColor', 'AccentColor',
			'BackgroundColor', 'OutlineColor', 'RiskColor',

			'Background_Color', 'Background_Transparency', 'Background_Blur',
			'Background_Contrast', 'Background_Saturation', 'Background_Brightness',

			'KeybindMenu', 'KeybindMenuTransparency', 'KeybindMenuMode',
			'NotificationClips', 'NotificationClipsDistance',
			'NotificationPositionX', 'NotificationPositionY', 'NotificationTransparency',
			'NotificationAnchorStyle', 'NotificationBarStyle', 'NotificationStyleSortOrder',
		});
	end;

	function SaveManager:Save(Name, NoWrite)
		if not Name then
			return false, 'no config file is selected';
		end;

		self:CheckFolderTree();

		local File = self:ConfigFolder() .. '/' .. Name .. '.json';
		local Data = { objects = {} };

		for Idx, Object in next, Toggles do
			if self.Ignore[Idx] then
				continue;
			end;

			table.insert(Data.objects, self.Parser[Object.Type].Save(Idx, Object));
		end;

		for Idx, Object in next, Options do
			if not self.Parser[Object.Type] then
				continue;
			end;

			if self.Ignore[Idx] then
				continue;
			end;

			table.insert(Data.objects, self.Parser[Object.Type].Save(Idx, Object));
		end;

		local Success, Encoded = pcall(HttpService.JSONEncode, HttpService, Data);

		if not Success then
			return false, 'failed to encode data';
		end;

		if not NoWrite then
			writefile(File, Encoded);
		end;

		return true, Encoded;
	end;

	function SaveManager:Load(Name)
		if not Name then
			return false, 'no config file is selected';
		end;

		if type(Name) == 'table' then
			for _, Object in next, Name.objects do
				if self.Parser[Object.type] then
					task.spawn(function()
						self.Parser[Object.type].Load(Object.idx, Object);
					end);
				end;
			end;

			return true;
		end;

		self:CheckFolderTree();

		local File = self:ConfigFolder() .. '/' .. Name .. '.json';

		if not isfile(File) then
			return false, 'invalid file';
		end;

		local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, readfile(File));

		if not Success then
			return false, 'decode error';
		end;

		for _, Object in next, Decoded.objects do
			if self.Parser[Object.type] then
				task.spawn(function()
					self.Parser[Object.type].Load(Object.idx, Object);
				end);
			end;
		end;

		return true;
	end;

	function SaveManager:Delete(Name)
		if not Name then
			return false, 'no config file is selected';
		end;

		local File = self:ConfigFolder() .. '/' .. Name .. '.json';

		if not isfile(File) then
			return false, 'invalid file';
		end;

		local Success = pcall(delfile, File);

		if not Success then
			return false, 'delete file error';
		end;

		return true;
	end;

	function SaveManager:RefreshConfigList()
		local Files = listfiles(self:ConfigFolder());
		local List = {};

		for Index = 1, #Files do
			local Path = Files[Index];

			if Path:sub(-5) == '.json' then

				local Start = Path:find('.json', 1, true);
				local Finish = Start;
				local Char = Path:sub(Start, Start);

				while Char ~= '/' and Char ~= '\\' and Char ~= '' do
					Start = Start - 1;
					Char = Path:sub(Start, Start);
				end;

				if Char == '/' or Char == '\\' then
					table.insert(List, Path:sub(Start + 1, Finish - 1));
				end;
			end;
		end;

		return List;
	end;

	function SaveManager:GetAutoloadConfig()
		local Cache = EZ:ReadCache();
		return Cache.configs and Cache.configs[EZ.Game];
	end;

	function SaveManager:SaveAutoloadConfig(Name)
		local Cache = EZ:ReadCache();
		Cache.configs = Cache.configs or {};
		Cache.configs[EZ.Game] = Name;
		EZ:WriteCache(Cache);
	end;

	function SaveManager:UnsetAutoloadConfig()
		local Cache = EZ:ReadCache();
		if Cache.configs then
			Cache.configs[EZ.Game] = nil;
			EZ:WriteCache(Cache);
		end;
	end;

	function SaveManager:LoadAutoloadConfig()
		local Name = self:GetAutoloadConfig();

		if Name then
			local Success, Err = self:Load(Name);

			if not Success then
				return self.Library:Notify('Failed to load autoload config: ' .. Err);
			end;

			if not SILENT then
				self.Library:Notify(string.format('Auto loaded config %q', Name));
			end;
		end;
	end;

	function SaveManager:BuildConfigTab(Window)
		self:BuildConfigSection(Window:AddTab('settings'));
	end;

	function SaveManager:BuildConfigSection(Tab)
		local Section = Tab:AddRightGroupbox('Configuration');

		Section:AddInput('SaveManager_ConfigName', { Text = 'Config name' });
		Section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true });

		Section:AddButton('Create config', function()
			local Name = Options.SaveManager_ConfigName.Value;

			if Name:gsub(' ', '') == '' then
				return self.Library:Notify('Invalid config name (empty)', 2);
			end;

			if isfile(self:ConfigFolder() .. '/' .. Name .. '.json') then
				return self.Library:Notify(string.format('Config %q already exists, use the overwrite button to replace it', Name), 3);
			end;

			local Success, Err = self:Save(Name);

			if not Success then
				return self.Library:Notify('Failed to save config: ' .. Err);
			end;

			self.Library:Notify(string.format('Created config %q', Name));

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList());
			Options.SaveManager_ConfigList:SetValue(nil);
			Options.SaveManager_ConfigCopyList:SetValues(self:RefreshConfigList());
		end):AddButton('Load config', function()
			local Name = Options.SaveManager_ConfigList.Value;

			local Success, Err = self:Load(Name);

			if not Success then
				return self.Library:Notify('Failed to load config: ' .. Err);
			end;

			self.Library:Notify(string.format('Loaded config %q', Name));
		end);

		Section:AddButton({ Text = 'Overwrite config', DoubleClick = true, Func = function()
			local Name = Options.SaveManager_ConfigList.Value;

			local Success, Err = self:Save(Name);

			if not Success then
				return self.Library:Notify('Failed to overwrite config: ' .. Err);
			end;

			self.Library:Notify(string.format('Overwrote config %q', Name));
		end }):AddButton({ Text = 'Delete config', DoubleClick = true, Func = function()
			local Name = Options.SaveManager_ConfigList.Value;

			local Success, Err = self:Delete(Name);

			if not Success then
				return self.Library:Notify('Failed to delete config: ' .. Err);
			end;

			self.Library:Notify(string.format('Deleted config %q', Name));

			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList());
			Options.SaveManager_ConfigList:SetValue(nil);
			Options.SaveManager_ConfigCopyList:SetValues(self:RefreshConfigList());
			Options.SaveManager_ConfigCopyList:SetValue(nil);
		end });

		Section:AddButton('Refresh list', function()
			local List = self:RefreshConfigList();

			Options.SaveManager_ConfigList:SetValues(List);
			Options.SaveManager_ConfigList:SetValue(nil);

			Options.SaveManager_ConfigCopyList:SetValues(List);
			Options.SaveManager_ConfigCopyList:SetValue(nil);
		end);

		Section:AddButton('Set autoload', function()
			local Name = Options.SaveManager_ConfigList.Value;

			if not Name then
				return self.Library:Notify('No config selected');
			end;

			self:SaveAutoloadConfig(Name);
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. Name);
			self.Library:Notify(string.format('Set %q to auto load', Name));
		end):AddButton('Remove autoload', function()
			self:UnsetAutoloadConfig();
			SaveManager.AutoloadLabel:SetText('Current autoload config: none');
			self.Library:Notify('Removed autoload config');
		end);

		SaveManager.AutoloadLabel = Section:AddLabel('Current autoload config: none', true);

		local Autoload = self:GetAutoloadConfig();
		if Autoload then
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. Autoload);
		end;

		Section:AddDivider();

		Section:AddInput('SaveManager_ConfigImport', {
			Text = 'Import from clipboard';
			Placeholder = 'Paste config here...';
			Callback = function(Raw)
				local Trimmed = type(Raw) == 'string' and Raw:gsub('%s', '') or '';

				if Trimmed == '' or Trimmed:sub(1, 1) ~= '{' then
					return;
				end;

				local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, Raw);

				if not Success or type(Decoded) ~= 'table' or type(Decoded.objects) ~= 'table' then
					Options.SaveManager_ConfigImport:SetValue('');
					return self.Library:Notify('Invalid config', 3);
				end;

				local Loaded, Err = self:Load(Decoded);

				Options.SaveManager_ConfigImport:SetValue('');

				if not Loaded then
					return self.Library:Notify('Failed to import config: ' .. tostring(Err), 3);
				end;

				self.Library:Notify('Applied Config');
			end;
		});

		Section:AddDropdown('SaveManager_ConfigCopyList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true });

		Section:AddButton('Copy config to clipboard', function()
			local SetClipboard = setclipboard or set_clipboard or toclipboard;

			if not SetClipboard then
				return self.Library:Notify('Clipboard is not supported by your executor', 3);
			end;

			local Name = Options.SaveManager_ConfigCopyList.Value;

			if not Name then
				return self.Library:Notify('No config selected', 2);
			end;

			self:CheckFolderTree();

			local File = self:ConfigFolder() .. '/' .. Name .. '.json';

			if not isfile(File) then
				return self.Library:Notify(string.format('Config %q does not exist', Name), 3);
			end;

			local Ok, Encoded = pcall(readfile, File);

			if not Ok or type(Encoded) ~= 'string' or Encoded:gsub('%s', '') == '' then
				return self.Library:Notify(string.format('Failed to read config %q', Name), 3);
			end;

			pcall(SetClipboard, Encoded);
			self.Library:Notify(string.format('Copied config %q to clipboard', Name));
		end);

		self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigCopyList', 'SaveManager_ConfigName', 'SaveManager_ConfigImport' });
	end;
end;

EZ.SaveManager = SaveManager;
