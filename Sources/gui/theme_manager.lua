local ThemeManager = {};

do
	ThemeManager.Library = EZ;
	ThemeManager.DefaultTheme = 'Default';

	local NonColorDefaults = {
		Background_Color = '000000';
		Background_Transparency = 0.7;
		Background_Blur = 15;
		Background_Contrast = 0;
		Background_Saturation = 0;
		Background_Brightness = 0;

		KeybindMenu = true;
		KeybindMenuTransparency = 100;
		KeybindMenuMode = 'Toggled';

		NotificationClips = true;
		NotificationClipsDistance = 200;
		NotificationPositionX = 50;
		NotificationPositionY = 60;
		NotificationTransparency = 25;
		NotificationAnchorStyle = 'Center';
		NotificationBarStyle = 'Below';
		NotificationStyleSortOrder = 'Default';
	};

	local function MakeTheme(FontColor, MainColor, AccentColor, BackgroundColor, OutlineColor, RiskColor)
		local Data = {
			FontColor = FontColor;
			MainColor = MainColor;
			AccentColor = AccentColor;
			BackgroundColor = BackgroundColor;
			OutlineColor = OutlineColor;
			RiskColor = RiskColor;
		};

		for Key, Value in next, NonColorDefaults do
			Data[Key] = Value;
		end;

		return { 1, Data };
	end;

	ThemeManager.BuiltInThemes = {
		['Default']      = MakeTheme('ffffff', '181818', '4777b6', '141414', '1f1f1f', 'e50000');
		['Tokyo Night']  = MakeTheme('ffffff', '191925', '6956cb', '15151e', '272727', 'fb5f5f');
		['Nord']         = MakeTheme('ffffff', '1c1e20', '9effc8', '1c1e20', '24282d', 'ff7a00');
		['Skeet']        = MakeTheme('ffffff', '131313', '81ff54', '151515', '2a2a2a', 'e50000');
		['Neverlose']    = MakeTheme('ffffff', '0c1014', '01a3f1', '0c0f14', '191919', 'e50000');
		['Onetap']       = MakeTheme('ffffff', '1e1d22', 'faa614', '18181c', '313033', 'e50000');
		['Imgui']        = MakeTheme('ffffff', '151617', '406ba8', '151617', '242424', 'e50000');
		['Iniuria']      = MakeTheme('ffffff', '1e1d1e', 'c41275', '1e1d1e', '33252b', 'e50000');
		['Primordial']   = MakeTheme('ffffff', '181818', 'd7a6b0', '1f1f1f', '2a2a2a', 'e50000');
		['Monolith']     = MakeTheme('ffffff', '141115', 'c707bd', '171417', '272427', 'e50000');
		['V3rmillion']   = MakeTheme('ffffff', '202020', 'cd1818', '202020', '2a2a2a', 'e50000');
		['Dark']         = MakeTheme('ffffff', '0a0a0a', '5945ff', '0a0a0a', '171717', 'e50000');

		['Sage']         = MakeTheme('ffffff', '171917', '8ba888', '141613', '262a25', 'e50000');
		['Dusk']         = MakeTheme('ffffff', '17171c', '8a90b8', '141419', '26262e', 'e50000');
		['Clay']         = MakeTheme('ffffff', '1a1817', 'c08a6a', '161413', '2a2624', 'e50000');
		['Slate']        = MakeTheme('ffffff', '16181b', '6d8ba8', '131518', '252a2e', 'e50000');
		['Rosewater']    = MakeTheme('ffffff', '1a1719', 'c99aa8', '161315', '2a2528', 'e50000');
		['Mauve']        = MakeTheme('ffffff', '181518', 'a888a8', '151215', '282328', 'e50000');
		['Harbor']       = MakeTheme('ffffff', '15191a', '6fa39c', '121617', '242a2b', 'e50000');
	};

	ThemeManager.ColorKeys = {
		'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor', 'RiskColor',
	};

	ThemeManager.BackgroundKeys = {
		Background_Color        = 'Color';
		Background_Transparency = 'Transparency';
		Background_Blur         = 'Blur';
		Background_Contrast     = 'Contrast';
		Background_Saturation   = 'Saturation';
		Background_Brightness   = 'Brightness';
	};

	ThemeManager.ThemeKeys = {
		'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor', 'RiskColor',

		'Background_Color', 'Background_Transparency', 'Background_Blur',
		'Background_Contrast', 'Background_Saturation', 'Background_Brightness',

		'KeybindMenu', 'KeybindMenuTransparency', 'KeybindMenuMode',

		'NotificationClips', 'NotificationClipsDistance',
		'NotificationPositionX', 'NotificationPositionY', 'NotificationTransparency',
		'NotificationAnchorStyle', 'NotificationBarStyle', 'NotificationStyleSortOrder',
	};

	local function GetFlag(Key)
		return Options[Key] or Toggles[Key];
	end;

	function ThemeManager:ApplyTheme(Name)
		if not Name then
			return;
		end;

		local Data = self:GetCustomTheme(Name);
		local BuiltIn = self.BuiltInThemes[Name];

		if not Data and BuiltIn then
			Data = BuiltIn[2];
		end;

		if not Data then
			return;
		end;

		for Key, Value in next, Data do
			local Flag = GetFlag(Key);

			if Flag then
				if Key:find('Color') and type(Value) == 'string' then
					Flag:SetValueRGB(Color3.fromHex(Value));
				else

					Flag:SetValue(Value);
				end;
			end;
		end;

		self:ThemeUpdate();
	end;

	function ThemeManager:ThemeUpdate()
		local Library = self.Library;

		for _, Key in next, self.ColorKeys do
			if Options[Key] then
				Library[Key] = Options[Key].Value;
			end;
		end;

		Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);
		Library:UpdateColorsUsingRegistry();
	end;

	function ThemeManager:LoadDefault()
		local Name = self.DefaultTheme;
		local Saved = EZ:ReadCache().theme;

		local IsBuiltIn = true;

		if Saved then
			if self.BuiltInThemes[Saved] then
				Name = Saved;
			elseif self:GetCustomTheme(Saved) then
				Name = Saved;
				IsBuiltIn = false;
			end;
		end;

		if IsBuiltIn then
			Options.ThemeManager_ThemeList:SetValue(Name);
		else
			self:ApplyTheme(Name);
		end;
	end;

	function ThemeManager:SaveDefault(Name)
		local Cache = EZ:ReadCache();
		Cache.theme = Name;
		EZ:WriteCache(Cache);
	end;

	function ThemeManager:ResetDefault()
		local Cache = EZ:ReadCache();
		Cache.theme = nil;
		EZ:WriteCache(Cache);
	end;

	function ThemeManager:GetCustomTheme(File)
		if not File then
			return;
		end;

		if not File:find('%.json$') then
			File = File .. '.json';
		end;

		local Path = 'Elite Zone/themes/' .. File;

		if not isfile(Path) then
			return nil;
		end;

		local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, readfile(Path));

		if not Success then
			return nil;
		end;

		return Decoded;
	end;

	function ThemeManager:SaveCustomTheme(File)
		if not File or File:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3);
		end;

		if not File:find('%.json$') then
			File = File .. '.json';
		end;

		local Data = {};

		for _, Key in next, self.ThemeKeys do
			local Flag = GetFlag(Key);

			if Flag then
				if Key:find('Color') and typeof(Flag.Value) == 'Color3' then
					Data[Key] = Flag.Value:ToHex();
				else
					Data[Key] = Flag.Value;
				end;
			end;
		end;

		writefile('Elite Zone/themes/' .. File, HttpService:JSONEncode(Data));
	end;

	function ThemeManager:Delete(File)
		if not File then
			return false, 'no theme file is selected';
		end;

		if not File:find('%.json$') then
			File = File .. '.json';
		end;

		local Path = 'Elite Zone/themes/' .. File;

		if not isfile(Path) then
			return false, 'invalid file';
		end;

		local Success = pcall(delfile, Path);

		if not Success then
			return false, 'delete file error';
		end;

		return true;
	end;

	function ThemeManager:ReloadCustomThemes()
		local Files = listfiles('Elite Zone/themes');
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

	function ThemeManager:CreateGroupBox(Tab)
		return Tab:AddLeftTabbox();
	end;

	function ThemeManager:ApplyToTab(Tab)
		local MenuBox = Tab:AddLeftTabbox();
		self:BuildMenuTab(MenuBox:AddTab('Menu'));
		self:BuildNotificationsTab(MenuBox:AddTab('Notifications'));

		self:CreateThemeManager(Tab:AddLeftTabbox());
	end;

	function ThemeManager:ApplyToWindow(Window)
		self:ApplyToTab(Window:AddTab('settings'));
	end;

	function ThemeManager:ApplyToGroupbox(Groupbox)
		self:CreateThemeManager(Groupbox);
	end;

	function ThemeManager:BuildMenuTab(Tab)
		local Library = self.Library;

		Tab:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
			Default = 'RightShift'; NoUI = true; Text = 'Menu bind';
		});
		Library.ToggleKeybind = Options.MenuKeybind;

		Tab:AddToggle('KeybindMenu', { Text = 'Keybind Menu'; Default = true });

		local KeybindMenuBox = Tab:AddDependencyBox();
		KeybindMenuBox:AddSlider('KeybindMenuTransparency', {
			Text = 'Menu Transparency'; Compact = true;
			Default = 100; Min = 0; Max = 100; Rounding = 0; Suffix = '%';
		});

		KeybindMenuBox:AddDropdown('KeybindMenuMode', {
			Text = 'Keybind Menu Mode';
			Values = { 'Toggled', 'Active', 'All' };
			Default = 'Toggled';
		});

		KeybindMenuBox:SetupDependencies({ { Toggles.KeybindMenu, true } });

		Toggles.KeybindMenu:OnChanged(function(Value)
			Library.KeypickerListVisible = Value;
			Library:UpdateKeybindFrame();
		end);

		Options.KeybindMenuTransparency:OnChanged(function(Value)
			Library.KeybindMenuTransparency = Value / 100;
			Library:UpdateKeybindMenu();
		end);

		Options.KeybindMenuMode:OnChanged(function(Value)
			Library.KeypickerListMode = Value;
			Library:UpdateKeybindFrame();
		end);
	end;

	function ThemeManager:BuildNotificationsTab(Tab)
		local Library = self.Library;
		local S = Library.NotificationStyle;

		local BarSides = { Up = 'Top', Below = 'Bottom', Right = 'Right', Left = 'Left' };

		Tab:AddToggle('NotificationClips', {
			Text = 'Clip Descendants'; Default = true;
			Tooltip = 'if enabled, will hide notifications past a certain point';
		});

		local ClipBox = Tab:AddDependencyBox();
		ClipBox:AddSlider('NotificationClipsDistance', {
			Text = 'Clip Past Distance'; Compact = true;
			Default = 200; Min = 100; Max = 1000; Rounding = 0; Suffix = 'px';
		});
		ClipBox:SetupDependencies({ { Toggles.NotificationClips, true } });

		Tab:AddToggle('NotificationForceColors', {
			Text = 'Force Colors'; Default = false;
			Tooltip = "override notification's colors, saved in config instead of theme";
		})
			:AddColorPicker('NotificationForcedAccent',  { Default = Library.AccentColor,  Title = 'Accent Color' })
			:AddColorPicker('NotificationForcedOutline', { Default = Library.OutlineColor, Title = 'Outline Color' })
			:AddColorPicker('NotificationForcedText',    { Default = Library.FontColor,    Title = 'Text Color' });

		local ForceColorsBox = Tab:AddDependencyBox();
		ForceColorsBox:AddButton({
			Text = 'Copy Colors'; DoubleClick = true;
			Tooltip = 'replaces colors with your current colors';
			Func = function()
				Options.NotificationForcedAccent:SetValueRGB(Library.AccentColor);
				Options.NotificationForcedOutline:SetValueRGB(Library.OutlineColor);
				Options.NotificationForcedText:SetValueRGB(Library.FontColor);
			end;
		});
		ForceColorsBox:SetupDependencies({ { Toggles.NotificationForceColors, true } });

		Tab:AddSlider('NotificationPositionX', {
			Text = 'Position X'; Compact = true;
			Default = 50; Min = 0; Max = 100; Rounding = 0; Suffix = '%';
		}):AddSlider('NotificationPositionY', {
			Text = 'Position Y'; Compact = true;
			Default = 60; Min = 0; Max = 100; Rounding = 0; Suffix = '%';
		});

		Tab:AddSlider('NotificationTransparency', {
			Text = 'Transparency'; Compact = true;
			Default = 25; Min = 0; Max = 100; Rounding = 0; Suffix = '%';
		});

		Tab:AddDropdown('NotificationAnchorStyle', {
			Text = 'Alignment'; Values = { 'Center', 'Right', 'Left' }; Default = 'Center';
		});

		Tab:AddDropdown('NotificationBarStyle', {
			Text = 'Bar Side'; Values = { 'Up', 'Below', 'Right', 'Left' }; Default = 'Below';
			Tooltip = 'shows a line on the selected side';
		});

		Tab:AddDropdown('NotificationStyleSortOrder', {
			Text = 'Sort Order'; Values = { 'Text Length', 'Default' }; Default = 'Default';
		});

		local TestValue = 1;
		Tab:AddButton('Send notification', function()
			Library:Notify('notification test ' .. TestValue, 5);
			TestValue = TestValue * 2;
		end);

		Toggles.NotificationClips:OnChanged(function(Value)
			S.Clips = Value;
			Library:UpdateNotifications();
		end);

		Options.NotificationClipsDistance:OnChanged(function(Value)
			S.ClipsDistance = Value;
			Library:UpdateNotifications();
		end);

		local function UpdateForcedColors()
			if Toggles.NotificationForceColors.Value then
				S.OverrideColor = function()
					return Library.MainColor,
						Options.NotificationForcedAccent.Value,
						Options.NotificationForcedOutline.Value,
						Options.NotificationForcedText.Value;
				end;
			else
				S.OverrideColor = nil;
			end;
		end;

		Toggles.NotificationForceColors:OnChanged(UpdateForcedColors);
		Options.NotificationForcedAccent:OnChanged(UpdateForcedColors);
		Options.NotificationForcedOutline:OnChanged(UpdateForcedColors);
		Options.NotificationForcedText:OnChanged(UpdateForcedColors);
		UpdateForcedColors();

		Options.NotificationPositionX:OnChanged(function(Value)
			S.PositionX = Value / 100;
			Library:UpdateNotifications();
		end);

		Options.NotificationPositionY:OnChanged(function(Value)
			S.PositionY = Value / 100;
			Library:UpdateNotifications();
		end);

		Options.NotificationTransparency:OnChanged(function(Value)
			S.Transparency = 1 - Value / 100;
		end);

		Options.NotificationAnchorStyle:OnChanged(function(Value)
			S.Anchor = Value;
			Library:UpdateNotifications();
		end);

		Options.NotificationBarStyle:OnChanged(function(Value)
			S.BarSide = BarSides[Value] or 'Bottom';
		end);

		Options.NotificationStyleSortOrder:OnChanged(function(Value)
			S.SortOrder = Value;
		end);
	end;

	function ThemeManager:BuildBackgroundTab(Tab)
		local Library = self.Library;
		local B = Library.Background;

		Tab:AddLabel('Background color'):AddColorPicker('Background_Color', {
			Default = B.Color;
		});

		Tab:AddSlider('Background_Transparency', {
			Text = 'Transparency'; Compact = false;
			Default = B.Transparency; Min = 0; Max = 1; Rounding = 2;
		}):AddSlider('Background_Blur', {
			Text = 'Blur'; Compact = false;
			Default = B.Blur; Min = 0; Max = 50; Rounding = 0;
		});

		Tab:AddSlider('Background_Contrast', {
			Text = 'Contrast'; Compact = false;
			Default = B.Contrast; Min = -10; Max = 10; Rounding = 1;
		}):AddSlider('Background_Saturation', {
			Text = 'Saturation'; Compact = false;
			Default = B.Saturation; Min = -10; Max = 10; Rounding = 1;
		});

		Tab:AddSlider('Background_Brightness', {
			Text = 'Brightness'; Compact = false;
			Default = B.Brightness; Min = -1; Max = 1; Rounding = 1;
		});

		for Flag, Field in next, self.BackgroundKeys do
			if Options[Flag] then
				Options[Flag]:OnChanged(function(Value)
					B[Field] = Value;
					Library:UpdateBackground('snap');
				end);
			end;
		end;

		Library:UpdateBackground('snap');
	end;

	function ThemeManager:CreateThemeManager(Container)
		local Groupbox = Container;
		local IsTabbox = type(Container.AddTab) == 'function' and type(Container.AddLabel) ~= 'function';

		if IsTabbox then
			Groupbox = Container:AddTab('Themes');
		end;

		Groupbox:AddLabel('Background Color') :AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		Groupbox:AddLabel('Main Color')      :AddColorPicker('MainColor',       { Default = self.Library.MainColor });
		Groupbox:AddLabel('Accent Color')    :AddColorPicker('AccentColor',     { Default = self.Library.AccentColor });
		Groupbox:AddLabel('Outline Color')   :AddColorPicker('OutlineColor',    { Default = self.Library.OutlineColor });
		Groupbox:AddLabel('Text Color')      :AddColorPicker('FontColor',       { Default = self.Library.FontColor });
		Groupbox:AddLabel('Risk Text Color') :AddColorPicker('RiskColor',       { Default = self.Library.RiskColor });

		Groupbox:AddDivider();

		local ThemesArray = {};

		for Name in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name);
		end;

		table.sort(ThemesArray, function(A, B)
			if A == self.DefaultTheme then return true; end;
			if B == self.DefaultTheme then return false; end;
			return A < B;
		end);

		Groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 });

		Groupbox:AddButton('Set default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value);
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value));
		end):AddButton('Reset default', function()
			self:ResetDefault();
			self.Library:Notify('Reset default theme');
		end);

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value);
		end);

		Groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' });

		Groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 });

		Groupbox:AddButton('Create theme', function()
			local Name = Options.ThemeManager_CustomThemeName.Value;
			if not Name or Name:gsub(' ', '') == '' then
				return self.Library:Notify('Invalid file name for theme (empty)', 3);
			end;

			local Display = Name:gsub('%.json$', '');

			if isfile('Elite Zone/themes/' .. Display .. '.json') then
				return self.Library:Notify(string.format('Theme %q already exists, use the overwrite button to replace it', Display), 3);
			end;

			self:SaveCustomTheme(Name);

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes());
			Options.ThemeManager_CustomThemeList:SetValue(Display);

			self.Library:Notify(string.format('Created theme %q', Display));
		end):AddButton('Load theme', function()
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value);
		end);

		Groupbox:AddButton({ Text = 'Overwrite theme', DoubleClick = true, Func = function()
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeList.Value);
		end }):AddButton({ Text = 'Delete theme', DoubleClick = true, Func = function()
			local Name = Options.ThemeManager_CustomThemeList.Value;
			local Success, Err = self:Delete(Name);

			if not Success then
				return self.Library:Notify('Failed to delete theme: ' .. Err);
			end;

			self.Library:Notify(string.format('Deleted theme %q', Name));

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes());
			Options.ThemeManager_CustomThemeList:SetValue(nil);
		end });

		Groupbox:AddButton('Set default', function()
			local Name = Options.ThemeManager_CustomThemeList.Value;
			if Name ~= nil and Name ~= '' then
				self:SaveDefault(Name);
				self.Library:Notify(string.format('Set default theme to %q', Name));
			end;
		end):AddButton('Reset default', function()
			self:ResetDefault();
			self.Library:Notify('Reset default theme');
		end);

		Groupbox:AddButton('Refresh', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes());
			Options.ThemeManager_CustomThemeList:SetValue(nil);
		end);

		for _, Key in next, self.ColorKeys do
			if Options[Key] then
				Options[Key]:OnChanged(function()
					self:ThemeUpdate();
				end);
			end;
		end;

		if IsTabbox then
			self:BuildBackgroundTab(Container:AddTab('Background'));
		end;

		self:LoadDefault();
	end;
end;

EZ.ThemeManager = ThemeManager;
