-- This file was compiled by Elite Zone's Compiler. [v3.10]
--Library Version (Used for caching purposes.) v7.5

--[[ Library ]]

local cloneref = cloneref or function(obj)
	return obj
end

local function GetService(Name)
	return cloneref(game:GetService(Name));
end

local InputService = GetService('UserInputService');
local TextService = GetService('TextService');
local HttpService = GetService('HttpService');

local function ensurefolder(path)
	if not isfolder(path) then makefolder(path) end
end

local CoreGui = (function()
	if gethui then
		local ok, hui = pcall(gethui);
		if ok and hui then return hui end
	end

	local ok, cg = pcall(function()
		local c = GetService('CoreGui');

		local probe = Instance.new('ScreenGui');
		probe.Parent = c;
		probe:Destroy();

		return c;
	end);

	if ok and cg then return cg end

	local Player = GetService('Players').LocalPlayer;
	return Player:FindFirstChildOfClass('PlayerGui') or Player:WaitForChild('PlayerGui');
end)();
local Players = GetService('Players');
local RunService = GetService('RunService')
local TweenService = GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = cloneref(LocalPlayer:GetMouse());

local ContextActionService = GetService('ContextActionService');
local GuiService = GetService('GuiService');

local ProtectGuiRaw = protectgui or (syn and syn.protect_gui) or (function() end);
local function ProtectGui(Gui)
	pcall(ProtectGuiRaw, Gui);
end

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;
ScreenGui.DisplayOrder = 999;

local OutlineGui = Instance.new('ScreenGui');
ProtectGui(OutlineGui);
OutlineGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
OutlineGui.Parent = CoreGui;
OutlineGui.DisplayOrder = 1000;

local CursorGui = Instance.new('ScreenGui');
ProtectGui(CursorGui);
CursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
CursorGui.Parent = CoreGui;
CursorGui.DisplayOrder = 1001;

local Lighting = GetService('Lighting');

local MenuBlur = Instance.new('BlurEffect');
MenuBlur.Name = '\0';
MenuBlur.Size = 0;
MenuBlur.Enabled = false;

local MenuColor = Instance.new('ColorCorrectionEffect');
MenuColor.Name = '\0';
MenuColor.Enabled = false;

local MenuDimGui = Instance.new('ScreenGui');
ProtectGui(MenuDimGui);
MenuDimGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
MenuDimGui.IgnoreGuiInset = true;
MenuDimGui.DisplayOrder = 997;
MenuDimGui.Parent = CoreGui;

local MenuDim = Instance.new('Frame');
MenuDim.BackgroundColor3 = Color3.new(0, 0, 0);
MenuDim.BackgroundTransparency = 1;
MenuDim.BorderSizePixel = 0;
MenuDim.Size = UDim2.fromScale(1, 1);
MenuDim.ZIndex = 0;
MenuDim.Visible = false;
MenuDim.Parent = MenuDimGui;

local Toggles = {};
local Options = {};

local EZ = {
	Folder = 'Elite Zone';

	Registry = {};
	RegistryMap = {};

	HudRegistry = {};

	FontColor = Color3.fromRGB(255, 255, 255);
	MainColor = Color3.fromRGB(24, 24, 24);
	BackgroundColor = Color3.fromRGB(20, 20, 20);
	AccentColor = Color3.fromRGB(71, 119, 182);
	OutlineColor = Color3.fromRGB(31, 31, 31);
	RiskColor = Color3.fromRGB(229, 0, 0),

	Black = Color3.new(0, 0, 0);
	Font = Enum.Font.RobotoMono,

	OpenedFrames = {};
	DependencyBoxes = {};

	KeypickerListVisible = true;
	KeypickerListMode = "Toggled";

	Signals = {};
	ScreenGui = ScreenGui;
	OutlineGui = OutlineGui;
	CursorGui = CursorGui;

	MenuBlur = MenuBlur;
	MenuColor = MenuColor;
	MenuDim = MenuDim;
	MenuFadeTime = 0.2;

	Background = {
		Enabled = true;
		Color = Color3.new(0, 0, 0);
		Transparency = 0.7;
		Blur = 15;
		Contrast = 0;
		Saturation = 0;
		Brightness = 0;
	};

	Events = {};
	Tabs = {};

	NotifyOnError = false;
	FlagCopying = false;

	IsDragging = false;
	CanDrag = true;
	CantDragForced = false;

	MinSize = Vector2.new(550, 300);

	IsMobile = (function()
		local Ok, Touch = pcall(function()
			return InputService.TouchEnabled or (getgenv and getgenv().mobile) or false;
		end);
		return Ok and Touch or false;
	end)();

	NotificationStyle = {
		BarSide = 'Bottom';
		Transparency = 0.75;
		PositionX = 0.5;
		PositionY = 0.6;
		Clips = true;
		ClipsDistance = 200;
		Anchor = 'Center';
		SortOrder = 'Default';
		OverrideColor = nil;
	};

	KeybindMenuTransparency = 1;

	TotalTabs = 0;
	Visible = false;
	BlockInput = false;
	ToggleKeybind = nil;

	ShowCustomCursor = true;
};

EZ.Toggles = Toggles;
EZ.Options = Options;

function EZ:SetFolder(Folder)
	self.Folder = Folder;
end

function EZ:EnsureFolders()
	ensurefolder(self.Folder);
	ensurefolder(self.Folder .. '/cache');
	ensurefolder(self.Folder .. '/themes');
	ensurefolder(self.Folder .. '/' .. self.Game:lower());
	ensurefolder(self.Folder .. '/' .. self.Game:lower() .. '/configs');
end

function EZ:ReadCache()
	if not isfile(self.Folder .. '/cache/autoload.dat') then return {} end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(self.Folder .. '/cache/autoload.dat'));
	end);
	return ok and type(data) == 'table' and data or {};
end

function EZ:WriteCache(data)
	ensurefolder(self.Folder);
	ensurefolder(self.Folder .. '/cache');
	writefile(self.Folder .. '/cache/autoload.dat', HttpService:JSONEncode(data));
end

local RainbowStep = 0
local Hue = 0

table.insert(EZ.Signals, RenderStepped:Connect(function(Delta)
	RainbowStep = RainbowStep + Delta

	if RainbowStep >= (1 / 60) then
		RainbowStep = 0

		Hue = Hue + (1 / 400);

		if Hue > 1 then
			Hue = 0;
		end;

		EZ.CurrentRainbowHue = Hue;
		EZ.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
	end
end))

function EZ:SafeCallback(f, ...)
	if (not f) then
		return;
	end;

	local success, event = pcall(f, ...);

	if (not success) and EZ.NotifyOnError then
		local _, i = event:find(":%d+: ");

		if not i then
			return EZ:Notify(event);
		end;

		return EZ:Notify(event:sub(i + 1), 3);
	end;
end;

function EZ:AttemptSave()
	if EZ.SaveManager then
		EZ.SaveManager:Save();
	end;
end;

function EZ:Create(Class, Properties)
	local _Instance = Class;

	if type(Class) == 'string' then
		_Instance = Instance.new(Class);
	end;

	local Success = pcall(function()
		for Property, Value in next, Properties do
			_Instance[Property] = Value;
		end;
	end);

	if not Success then
		for Property, Value in next, Properties do
			local Ok = pcall(function()
				_Instance[Property] = Value;
			end);

			if not Ok then
				warn(('EZ:Create - failed to set %q'):format(tostring(Property)));
			end;
		end;
	end;

	return _Instance;
end;

function EZ:ApplyTextStroke(Inst)
	Inst.TextStrokeTransparency = 1;

	EZ:Create('UIStroke', {
		Color = Color3.new(0, 0, 0);
		Thickness = 1;
		LineJoinMode = Enum.LineJoinMode.Miter;
		Parent = Inst;
	});
end;

function EZ:CreateLabel(Properties, IsHud)
	local _Instance = EZ:Create('TextLabel', {
		BackgroundTransparency = 1;
		Font = EZ.Font;
		TextColor3 = EZ.FontColor;
		TextSize = 16;
		TextStrokeTransparency = 0;
	});

	EZ:ApplyTextStroke(_Instance);

	EZ:AddToRegistry(_Instance, {
		TextColor3 = 'FontColor';
	}, IsHud);

	return EZ:Create(_Instance, Properties);
end;

function EZ:MakeDraggable(Instance, Cutoff, IgnoreForced)
	Instance.Active = true;

	Instance.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			if IgnoreForced == true and EZ.CantDragForced == true then
				return;
			end;

			local Touch = Input.UserInputType == Enum.UserInputType.Touch;
			local Pos = Touch and Input.Position or Vector2.new(Mouse.X, Mouse.Y);

			local ObjPos = Vector2.new(
				Pos.X - Instance.AbsolutePosition.X,
				Pos.Y - Instance.AbsolutePosition.Y
			);

			if ObjPos.Y > (Cutoff or 40) then
				return;
			end;

			while if Touch then Input.UserInputState ~= Enum.UserInputState.End else InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				Pos = Touch and Input.Position or Vector2.new(Mouse.X, Mouse.Y);

				Instance.Position = UDim2.new(
					0,
					Pos.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
					0,
					Pos.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
				);

				RenderStepped:Wait();
			end;
		end;
	end)
end;

function EZ:IsTap(Input)
	if Input.UserInputType ~= Enum.UserInputType.Touch then
		return true;
	end;

	local Start = Input.Position;

	while Input.UserInputState ~= Enum.UserInputState.End do
		Input.Changed:Wait();
	end;

	local D = Input.Position - Start;
	return D:Dot(D) < 100;
end;

function EZ:MakeDraggableOutline(Instance, Cutoff, IgnoreForced)
	Instance.Active = true;

	Instance.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if IgnoreForced == true and EZ.CantDragForced == true then
				return;
			end;

			local ObjPos = Vector2.new(
				Mouse.X - Instance.AbsolutePosition.X,
				Mouse.Y - Instance.AbsolutePosition.Y
			);

			if ObjPos.Y > (Cutoff or 40) then
				return;
			end;

			local Outline = EZ:Create('Frame', {
				Parent = OutlineGui;
				AnchorPoint = Instance.AnchorPoint;
				BackgroundTransparency = 1;
				Size = Instance.Size;
				Position = Instance.Position;
			});

			local Stroke = EZ:Create('UIStroke', {
				Parent = Outline;
				Color = EZ.AccentColor or Color3.new(0, 0, 0);
			});

			EZ.IsDragging = true;

			while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				Outline.Position = UDim2.new(
					0,
					Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
					0,
					Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
				);

				Stroke.Color = EZ.AccentColor or Color3.new(0, 0, 0);

				RenderStepped:Wait();
			end;

			Instance.Position = Outline.Position;
			Outline:Destroy();

			EZ.IsDragging = false;
		elseif Input.UserInputType == Enum.UserInputType.Touch then
			if IgnoreForced == true and EZ.CantDragForced == true then
				return;
			end;

			local ObjPos = Vector2.new(
				Input.Position.X - Instance.AbsolutePosition.X,
				Input.Position.Y - Instance.AbsolutePosition.Y
			);

			if ObjPos.Y > (Cutoff or 40) then
				return;
			end;

			local Outline = EZ:Create('Frame', {
				Parent = OutlineGui;
				AnchorPoint = Instance.AnchorPoint;
				BackgroundTransparency = 1;
				Size = Instance.Size;
				Position = Instance.Position;
			});

			local Stroke = EZ:Create('UIStroke', {
				Parent = Outline;
				Color = EZ.AccentColor or Color3.new(0, 0, 0);
			});

			EZ.IsDragging = true;

			local Held = true;
			local Conn;

			Conn = Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Held = false;
				end;
			end);

			while Held do
				Outline.Position = UDim2.new(
					0,
					Input.Position.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
					0,
					Input.Position.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
				);

				Stroke.Color = EZ.AccentColor or Color3.new(0, 0, 0);

				RenderStepped:Wait();
			end;

			Instance.Position = Outline.Position;

			if Conn then
				Conn:Disconnect();
			end;

			Outline:Destroy();

			EZ.IsDragging = false;
		end;
	end)
end;

function EZ:MakeDraggableUsingParent(Handle, Target, Cutoff, IgnoreForced)
	Handle.Active = true;

	if EZ.IsMobile == false then
		Handle.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if IgnoreForced == true and EZ.CantDragForced == true then
					return;
				end;

				local ObjPos = Vector2.new(
					Mouse.X - Target.AbsolutePosition.X,
					Mouse.Y - Target.AbsolutePosition.Y
				);

				if ObjPos.Y > (Cutoff or 40) then
					return;
				end;

				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					Target.Position = UDim2.new(
						0,
						Mouse.X - ObjPos.X + (Target.Size.X.Offset * Target.AnchorPoint.X),
						0,
						Mouse.Y - ObjPos.Y + (Target.Size.Y.Offset * Target.AnchorPoint.Y)
					);

					RenderStepped:Wait();
				end;
			end;
		end)
	else
		EZ:MakeDraggable(Target, Cutoff, IgnoreForced);
	end;
end;

function EZ:MakeResizable(Instance, MinSize)
	Instance.Active = true;

	local GripSize = 25;
	local GripTransparency = 0.5;

	local GripRegion = EZ:Create('Frame', {
		SizeConstraint = Enum.SizeConstraint.RelativeXX;
		BackgroundColor3 = Color3.new(0, 0, 0);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.fromOffset(GripSize, GripSize);
		Position = UDim2.new(1, -GripSize, 1, -GripSize);
		Visible = true;
		ClipsDescendants = true;
		ZIndex = 1;
		Parent = Instance;
	});

	local Grip = EZ:Create('ImageButton', {
		BackgroundColor3 = EZ.AccentColor;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new(2, 0, 2, 0);
		Position = UDim2.new(1, -30, 1, -30);
		ZIndex = 2;
		Parent = GripRegion;
	});

	local GripCorner = EZ:Create('UICorner', {
		CornerRadius = UDim.new(0.5, 0);
		Parent = Grip;
	});

	EZ:AddToRegistry(Grip, { BackgroundColor3 = 'AccentColor' });

	MinSize = MinSize or EZ.MinSize;

	local DragOffset = nil;
	local Outline = nil;

	local Stroke = EZ:Create('UIStroke', {
		Color = EZ.AccentColor or Color3.new(0, 0, 0);
	});

	EZ:AddToRegistry(Stroke, { Color = 'AccentColor' });

	local function Reset(Transparency)
		Grip.Position = UDim2.new();
		Grip.Size = UDim2.new(2, 0, 2, 0);
		Grip.Parent = GripRegion;
		Grip.BackgroundTransparency = Transparency;
		GripCorner.Parent = Grip;

		DragOffset = nil;

		if Outline then
			Stroke.Parent = nil;
			Instance.Size = Outline.Size;
			Outline:Destroy();
			Outline = nil;
		end;
	end;

	if EZ.IsMobile ~= true then
		Grip.MouseButton1Down:Connect(function()
			if DragOffset then
				return;
			end;

			DragOffset = Vector2.new(
				Mouse.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X),
				Mouse.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y)
			);

			Outline = EZ:Create('Frame', {
				Parent = OutlineGui;
				AnchorPoint = Instance.AnchorPoint;
				BackgroundTransparency = 1;
				Size = Instance.Size;
				Position = Instance.Position;
			});

			Stroke.Parent = Outline;

			Grip.BackgroundTransparency = 1;
			Grip.Size = UDim2.fromOffset(ScreenGui.AbsoluteSize.X, ScreenGui.AbsoluteSize.Y);
			Grip.Position = UDim2.new();
			GripCorner.Parent = nil;
			Grip.Parent = ScreenGui;
		end);

		Grip.MouseMoved:Connect(function()
			if not DragOffset then
				return;
			end;

			local Corner = Vector2.new(Mouse.X - DragOffset.X, Mouse.Y - DragOffset.Y);

			local NewSize = Vector2.new(
				math.clamp(Corner.X - Instance.AbsolutePosition.X, MinSize.X, math.huge),
				math.clamp(Corner.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge)
			);

			Outline.Size = UDim2.fromOffset(NewSize.X, NewSize.Y);
		end);

		Grip.MouseButton1Up:Connect(function()
			Reset(GripTransparency);
		end);
	else
		Grip.InputBegan:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch or DragOffset then
				return;
			end;

			DragOffset = Vector2.new(
				Input.Position.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X),
				Input.Position.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y)
			);

			Outline = EZ:Create('Frame', {
				Parent = OutlineGui;
				AnchorPoint = Instance.AnchorPoint;
				BackgroundTransparency = 1;
				Size = Instance.Size;
				Position = Instance.Position;
			});

			Stroke.Parent = Outline;
		end);

		Grip.InputChanged:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch or not DragOffset then
				return;
			end;

			local Corner = Vector2.new(Input.Position.X - DragOffset.X, Input.Position.Y - DragOffset.Y);

			local NewSize = Vector2.new(
				math.clamp(Corner.X - Instance.AbsolutePosition.X, MinSize.X, math.huge),
				math.clamp(Corner.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge)
			);

			Outline.Size = UDim2.fromOffset(NewSize.X, NewSize.Y);
		end);

		Grip.InputEnded:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch then
				return;
			end;

			Reset(GripTransparency);
		end);
	end;

	Reset(GripTransparency);
end;

function EZ:UpdateBackground(Mode)
	local B = EZ.Background;
	local Open = (EZ.Visible == true) and (B.Enabled ~= false);

	MenuDim.BackgroundColor3 = B.Color;

	local Contrast   = Open and B.Contrast     or 0;
	local Saturation = Open and B.Saturation   or 0;
	local Brightness = Open and B.Brightness   or 0;
	local Blur       = Open and math.max(B.Blur, 0) or 0;
	local Dim        = Open and B.Transparency or 1;

	local WantColor = Contrast ~= 0 or Saturation ~= 0 or Brightness ~= 0;
	local WantBlur  = Blur > 0;

	if Open then
		MenuColor.Enabled = WantColor;
		MenuColor.Parent  = WantColor and Lighting or nil;
		MenuBlur.Enabled  = WantBlur;
		MenuBlur.Parent   = WantBlur and Lighting or nil;
		MenuDim.Visible   = true;
	end;

	if Mode == 'finalize' then
		if not WantColor then MenuColor.Enabled = false; MenuColor.Parent = nil; end;
		if not WantBlur  then MenuBlur.Enabled  = false; MenuBlur.Parent  = nil; end;
		if not Open      then MenuDim.Visible   = false; end;
		return;
	end;

	if Mode == 'snap' then
		if MenuColor.Parent then
			MenuColor.Contrast, MenuColor.Saturation, MenuColor.Brightness = Contrast, Saturation, Brightness;
		end;

		if MenuBlur.Parent then
			MenuBlur.Size = Blur;
		end;

		MenuDim.BackgroundTransparency = Dim;
		return;
	end;

	local Info = TweenInfo.new(EZ.MenuFadeTime, Enum.EasingStyle.Linear);

	if MenuColor.Parent then
		TweenService:Create(MenuColor, Info, {
			Contrast = Contrast; Saturation = Saturation; Brightness = Brightness;
		}):Play();
	end;

	if MenuBlur.Parent then
		TweenService:Create(MenuBlur, Info, { Size = Blur }):Play();
	end;

	TweenService:Create(MenuDim, Info, { BackgroundTransparency = Dim }):Play();
end;

function EZ:UpdateKeybindFrame()
	for _, Option in next, Options do
		if type(Option) == 'table' and Option.Type == 'KeyPicker' and Option.Update then
			Option:Update();
		end;
	end;

	EZ:UpdateKeybindMenu();
end;

function EZ:UpdateKeybindMenu()
	if not EZ.KeybindInner then
		return;
	end;

	local T = 1 - math.clamp(EZ.KeybindMenuTransparency or 1, 0, 1);

	EZ.KeybindInner.BackgroundTransparency = T;

	if T == 0 and not EZ._KeybindFaded then
		return;
	end;

	EZ._KeybindFaded = T > 0;

	for _, Desc in next, EZ.KeybindInner:GetDescendants() do
		if Desc:IsA('Frame') and Desc ~= EZ.KeybindContainer then
			Desc.BackgroundTransparency = T;
		end;
	end;
end;

function EZ:UpdateNotifications()
	local S = EZ.NotificationStyle;

	if EZ.NotificationOuter then
		local PX = S.PositionX or 0.5;

		local Height = S.Clips ~= false and (S.ClipsDistance or 200) or 8192;

		EZ.NotificationOuter.AnchorPoint = Vector2.new(PX, 0);
		EZ.NotificationOuter.Position = UDim2.fromScale(PX, S.PositionY or 0.6);
		EZ.NotificationOuter.ClipsDescendants = S.Clips ~= false;
		EZ.NotificationOuter.Size = UDim2.fromOffset(8192, Height);
	end;

	if EZ.NotificationLayout then
		local Align = ({
			Left = Enum.HorizontalAlignment.Left;
			Center = Enum.HorizontalAlignment.Center;
			Right = Enum.HorizontalAlignment.Right;
		})[S.Anchor] or Enum.HorizontalAlignment.Center;

		EZ.NotificationLayout.HorizontalAlignment = Align;
		EZ.NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	end;
end;

function EZ:AddToolTip(InfoStr, HoverInstance)
	local X, Y = EZ:GetTextBounds(InfoStr, EZ.Font, 14);
	local Tooltip = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor,
		BorderColor3 = EZ.OutlineColor,

		Size = UDim2.fromOffset(X + 5, Y + 4),
		ZIndex = 100,
		Parent = EZ.ScreenGui,

		Visible = false,
	})

	local Label = EZ:CreateLabel({
		Position = UDim2.fromOffset(3, 1),
		Size = UDim2.fromOffset(X, Y);
		TextSize = 14;
		Text = InfoStr,
		TextColor3 = EZ.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left;
		ZIndex = Tooltip.ZIndex + 1,

		Parent = Tooltip;
	});

	EZ:AddToRegistry(Tooltip, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	});

	EZ:AddToRegistry(Label, {
		TextColor3 = 'FontColor',
	});

	local IsHovering = false

	HoverInstance.MouseEnter:Connect(function()
		if EZ:MouseIsOverOpenedFrame() then
			return
		end

		IsHovering = true

		Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
		Tooltip.Visible = true

		while IsHovering do
			RunService.Heartbeat:Wait()
			Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
		end
	end)

	HoverInstance.MouseLeave:Connect(function()
		IsHovering = false
		Tooltip.Visible = false
	end)

	if EZ.MainFrame then
		EZ.MainFrame:GetPropertyChangedSignal('Visible'):Connect(function()
			if EZ.MainFrame.Visible == false then
				IsHovering = false
				Tooltip.Visible = false
			end
		end)
	end
end

function EZ:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault, Condition)
	local function ApplyDefault()
		local Reg = EZ.RegistryMap[Instance];

		for Property, ColorIdx in next, PropertiesDefault do
			Instance[Property] = EZ[ColorIdx] or ColorIdx;

			if Reg and Reg.Properties[Property] then
				Reg.Properties[Property] = ColorIdx;
			end;
		end;
	end;

	local function ApplyHighlight()
		if Condition and not Condition() then
			ApplyDefault();
			return;
		end;

		local Reg = EZ.RegistryMap[Instance];

		for Property, ColorIdx in next, Properties do
			Instance[Property] = EZ[ColorIdx] or ColorIdx;

			if Reg and Reg.Properties[Property] then
				Reg.Properties[Property] = ColorIdx;
			end;
		end;
	end;

	HighlightInstance.MouseEnter:Connect(ApplyHighlight);
	HighlightInstance.MouseMoved:Connect(ApplyHighlight);
	HighlightInstance.MouseLeave:Connect(ApplyDefault);
end;

function EZ:MouseIsOverOpenedFrame()
	for Frame, _ in next, EZ.OpenedFrames do
		local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

		if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
			and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

			return true;
		end;
	end;
end;

function EZ:IsMouseOverFrame(Frame)
	local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

	if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
		and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

		return true;
	end;
end;

function EZ:UpdateDependencyBoxes(Element)
	for _, Depbox in next, (Element and Element.DependencyBoxes or EZ.DependencyBoxes) do
		Depbox:Update();
	end;
end;

function EZ:MapValue(Value, MinA, MaxA, MinB, MaxB)
	return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function EZ:GetTextBounds(Text, Font, Size, Resolution)
	local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
	return Bounds.X, Bounds.Y
end;

function EZ:GetDarkerColor(Color)
	local H, S, V = Color3.toHSV(Color);
	return Color3.fromHSV(H, S, V / 1.5);
end;
EZ.AccentColorDark = EZ:GetDarkerColor(EZ.AccentColor);

function EZ:AddToRegistry(Instance, Properties, IsHud)
	local Idx = #EZ.Registry + 1;
	local Data = {
		Instance = Instance;
		Properties = Properties;
		Idx = Idx;
	};

	table.insert(EZ.Registry, Data);
	EZ.RegistryMap[Instance] = Data;

	if IsHud then
		table.insert(EZ.HudRegistry, Data);
	end;
end;

function EZ:RemoveFromRegistry(Instance)
	local Data = EZ.RegistryMap[Instance];

	if Data then
		for Idx = #EZ.Registry, 1, -1 do
			if EZ.Registry[Idx] == Data then
				table.remove(EZ.Registry, Idx);
				break;
			end;
		end;

		for Idx = #EZ.HudRegistry, 1, -1 do
			if EZ.HudRegistry[Idx] == Data then
				table.remove(EZ.HudRegistry, Idx);
				break;
			end;
		end;

		EZ.RegistryMap[Instance] = nil;
	end;
end;

function EZ:UpdateColorsUsingRegistry()
	for Idx, Object in next, EZ.Registry do
		for Property, ColorIdx in next, Object.Properties do
			if type(ColorIdx) == 'string' then
				Object.Instance[Property] = EZ[ColorIdx];
			elseif type(ColorIdx) == 'function' then
				Object.Instance[Property] = ColorIdx()
			end
		end;
	end;
end;

function EZ:GiveSignal(Signal)

	table.insert(EZ.Signals, Signal)
end

function EZ:EnableFlagCopying(Bool)
	EZ.FlagCopying = Bool;
end

function EZ:IsVisible()
	return EZ.Visible;
end

function EZ:CreateEvent(Name)
	EZ.Events[Name] = Instance.new('BindableEvent');
end

function EZ:FireEvent(Name, ...)
	if EZ.Events[Name] then
		EZ.Events[Name]:Fire(...);
	end;
end

function EZ:OnEvent(Name)
	if not EZ.Events[Name] then
		EZ:CreateEvent(Name);
	end;

	return EZ.Events[Name].Event;
end

EZ:CreateEvent('VisibilityChanged');

local InputBinds = {};

function EZ:BindToInput(Key, Callback)
	InputBinds[Key] = InputBinds[Key] or {};
	table.insert(InputBinds[Key], Callback);
end

EZ:GiveSignal(InputService.InputBegan:Connect(function(Input, ...)
	if not EZ.Visible then
		return;
	end;

	local Callbacks = InputBinds[Input.KeyCode] or InputBinds[Input.UserInputType];

	if Callbacks then
		for _, Callback in pairs(Callbacks) do
			task.spawn(Callback, Input, ...);
		end;
	end;
end))

function EZ:AddContextMenu(Anchor, Trigger)
	local ContextMenu = { Visible = false };

	ContextMenu.Options = {};

	ContextMenu.Container = EZ:Create('ImageButton', {
		BorderColor3 = Color3.new();
		ZIndex = 14;
		Visible = false;
		Parent = ScreenGui;
		Image = '';
		Active = false;
		AutoButtonColor = false;
	});

	ContextMenu.Inner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = EZ.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.fromScale(1, 1);
		ZIndex = 15;
		Parent = ContextMenu.Container;
	});

	EZ:Create('UIListLayout', {
		Name = 'Layout';
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = ContextMenu.Inner;
	});

	EZ:Create('UIPadding', {
		Name = 'Padding';
		PaddingLeft = UDim.new(0, 0);
		Parent = ContextMenu.Inner;
	});

	local function UpdatePosition()
		ContextMenu.Container.Position = UDim2.fromOffset(
			(Anchor.AbsolutePosition.X + Anchor.AbsoluteSize.X) + 4,
			Anchor.AbsolutePosition.Y + 1
		);
	end;

	local function UpdateSize()
		local MenuWidth = 60;

		for _, Label in next, ContextMenu.Inner:GetChildren() do
			if Label:IsA('TextLabel') then
				MenuWidth = math.max(MenuWidth, Label.TextBounds.X);
			end;
		end;

		ContextMenu.Container.Size = UDim2.fromOffset(
			MenuWidth + 8,
			ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
		);
	end;

	local IsOpen = false;

	(Trigger or Anchor).InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame() then
			return ContextMenu:Hide();
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not EZ:MouseIsOverOpenedFrame() then
			return ContextMenu:Show();
		end;
	end);

	EZ:BindToInput(Enum.UserInputType.MouseButton1, function()
		if IsOpen and not EZ:IsMouseOverFrame(ContextMenu.Container) then
			ContextMenu:Hide();
		end;
	end);

	EZ:BindToInput(Enum.UserInputType.MouseButton2, function()
		if IsOpen and not EZ:IsMouseOverFrame(ContextMenu.Container) and not EZ:IsMouseOverFrame(Anchor) then
			ContextMenu:Hide();
		end;
	end);

	Anchor:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdatePosition);

	task.spawn(UpdatePosition);
	task.spawn(UpdateSize);

	EZ:AddToRegistry(ContextMenu.Inner, {
		BackgroundColor3 = 'BackgroundColor';
		BorderColor3 = 'OutlineColor';
	});

	function ContextMenu:Show()
		UpdatePosition();
		UpdateSize();

		IsOpen = true;

		for Frame in next, EZ.OpenedFrames do
			if Frame.Name == 'Color' then
				Frame.Visible = false;
				EZ.OpenedFrames[Frame] = nil;
			end;
		end;

		self.Container.Visible = true;
		EZ.OpenedFrames[ContextMenu.Container] = true;
	end;

	function ContextMenu:Hide()
		IsOpen = false;
		self.Container.Visible = false;

		task.wait();

		EZ.OpenedFrames[ContextMenu.Container] = nil;
	end;

	function ContextMenu:AddOption(Str, Callback)
		if type(Callback) ~= 'function' then
			Callback = function() end;
		end;

		local Button = EZ:CreateLabel({
			Active = false;
			Size = UDim2.new(1, 0, 0, 15);
			TextSize = 13;
			Text = Str;
			ZIndex = 16;
			Parent = self.Inner;
			TextXAlignment = Enum.TextXAlignment.Center;
		});

		EZ:OnHighlight(Button, Button,
			{ TextColor3 = 'AccentColor' },
			{ TextColor3 = 'FontColor' }
		);

		Button.InputBegan:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return;
			end;

			Callback();
		end);

		table.insert(self.Options, Button);

		return Button;
	end;

	return ContextMenu;
end

EZ:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
	if EZ.RegistryMap[Instance] then
		EZ:RemoveFromRegistry(Instance);
	end;
end))

local BaseAddons = {};

do
	local Funcs = {};

	function Funcs:AddColorPicker(Idx, Info)
		local ParentObj = self;
		local ToggleLabel = self.TextLabel;

		assert(Info.Default, 'AddColorPicker: Missing default value.');

		local ColorPicker = {
			Idx = Idx;
			Value = Info.Default;
			Transparency = Info.Transparency or 0;
			Type = 'ColorPicker';
			Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
			HasTransparency = not not Info.Transparency;
			Callback = Info.Callback or function(Color) end;
		};

		function ColorPicker:SetHSVFromRGB(Color)
			local H, S, V = Color3.toHSV(Color);

			ColorPicker.Hue = H;
			ColorPicker.Sat = S;
			ColorPicker.Vib = V;
		end;

		ColorPicker:SetHSVFromRGB(ColorPicker.Value);

		local DisplayFrame = EZ:Create('Frame', {
			BackgroundColor3 = ColorPicker.Value;
			BorderColor3 = EZ:GetDarkerColor(ColorPicker.Value);
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(0, 28, 0, 14);
			ZIndex = 6;
			Parent = ToggleLabel;
		});

		local CheckerFrame = EZ:Create('ImageLabel', {
			BorderSizePixel = 0;
			Size = UDim2.new(0, 27, 0, 13);
			ZIndex = 5;
			Image = 'http://www.roblox.com/asset/?id=12977615774';
			Visible = not not Info.Transparency;
			Parent = DisplayFrame;
		});

		local PickerFrameOuter = EZ:Create('Frame', {
			Name = 'Color';
			BackgroundColor3 = Color3.new(1, 1, 1);
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
			Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
			Visible = false;
			ZIndex = 15;
			Parent = ScreenGui,
		});

		DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
		end)

		local PickerFrameInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 16;
			Parent = PickerFrameOuter;
		});

		local Highlight = EZ:Create('Frame', {
			BackgroundColor3 = EZ.AccentColor;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 0, 2);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		local SatVibMapOuter = EZ:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 4, 0, 25);
			Size = UDim2.new(0, 200, 0, 200);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		local SatVibMapInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Parent = SatVibMapOuter;
		});

		local SatVibMap = EZ:Create('ImageLabel', {
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Image = 'rbxassetid://4155801252';
			Parent = SatVibMapInner;
		});

		local CursorOuter = EZ:Create('ImageLabel', {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Size = UDim2.new(0, 6, 0, 6);
			BackgroundTransparency = 1;
			Image = 'http://www.roblox.com/asset/?id=9619665977';
			ImageColor3 = Color3.new(0, 0, 0);
			ZIndex = 19;
			Parent = SatVibMap;
		});

		local CursorInner = EZ:Create('ImageLabel', {
			Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
			Position = UDim2.new(0, 1, 0, 1);
			BackgroundTransparency = 1;
			Image = 'http://www.roblox.com/asset/?id=9619665977';
			ZIndex = 20;
			Parent = CursorOuter;
		})

		local HueSelectorOuter = EZ:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 208, 0, 25);
			Size = UDim2.new(0, 15, 0, 200);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		local HueSelectorInner = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(1, 1, 1);
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Parent = HueSelectorOuter;
		});

		local HueCursor = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(1, 1, 1);
			AnchorPoint = Vector2.new(0, 0.5);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, 0, 0, 1);
			ZIndex = 18;
			Parent = HueSelectorInner;
		});

		local HueBoxOuter = EZ:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(4, 228),
			Size = UDim2.new(0.5, -6, 0, 20),
			ZIndex = 18,
			Parent = PickerFrameInner;
		});

		local HueBoxInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18,
			Parent = HueBoxOuter;
		});

		EZ:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = HueBoxInner;
		});

		local HueBox = EZ:Create('TextBox', {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);
			Font = EZ.Font;
			PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
			PlaceholderText = 'Hex color',
			Text = '#FFFFFF',
			TextColor3 = EZ.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 20,
			Parent = HueBoxInner;
		});

		EZ:ApplyTextStroke(HueBox);

		local RgbBoxBase = EZ:Create(HueBoxOuter:Clone(), {
			Position = UDim2.new(0.5, 2, 0, 228),
			Size = UDim2.new(0.5, -6, 0, 20),
			Parent = PickerFrameInner
		});

		local RgbBox = EZ:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
			Text = '255, 255, 255',
			PlaceholderText = 'RGB color',
			TextColor3 = EZ.FontColor
		});

		local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;

		if Info.Transparency then
			TransparencyBoxOuter = EZ:Create('Frame', {
				BorderColor3 = Color3.new(0, 0, 0);
				Position = UDim2.fromOffset(4, 251);
				Size = UDim2.new(1, -8, 0, 15);
				ZIndex = 19;
				Parent = PickerFrameInner;
			});

			TransparencyBoxInner = EZ:Create('Frame', {
				BackgroundColor3 = ColorPicker.Value;
				BorderColor3 = EZ.OutlineColor;
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.new(1, 0, 1, 0);
				ZIndex = 19;
				Parent = TransparencyBoxOuter;
			});

			EZ:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

			EZ:Create('ImageLabel', {
				BackgroundTransparency = 1;
				Size = UDim2.new(1, 0, 1, 0);
				Image = 'http://www.roblox.com/asset/?id=12978095818';
				ZIndex = 20;
				Parent = TransparencyBoxInner;
			});

			TransparencyCursor = EZ:Create('Frame', {
				BackgroundColor3 = Color3.new(1, 1, 1);
				AnchorPoint = Vector2.new(0.5, 0);
				BorderColor3 = Color3.new(0, 0, 0);
				Size = UDim2.new(0, 1, 1, 0);
				ZIndex = 21;
				Parent = TransparencyBoxInner;
			});
		end;

		local DisplayLabel = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 0, 14);
			Position = UDim2.fromOffset(5, 5);
			TextXAlignment = Enum.TextXAlignment.Left;
			TextSize = 14;
			Text = ColorPicker.Title,
			TextWrapped = false;
			ZIndex = 16;
			Parent = PickerFrameInner;
		});

		local ContextMenu = {}
		do
			ContextMenu.Options = {}
			ContextMenu.Container = EZ:Create('Frame', {
				BorderColor3 = Color3.new(),
				ZIndex = 14,

				Visible = false,
				Parent = ScreenGui
			})

			ContextMenu.Inner = EZ:Create('Frame', {
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = EZ.OutlineColor;
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.fromScale(1, 1);
				ZIndex = 15;
				Parent = ContextMenu.Container;
			});

			EZ:Create('UIListLayout', {
				Name = 'Layout',
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = ContextMenu.Inner;
			});

			EZ:Create('UIPadding', {
				Name = 'Padding',
				PaddingLeft = UDim.new(0, 4),
				Parent = ContextMenu.Inner,
			});

			local function updateMenuPosition()
				ContextMenu.Container.Position = UDim2.fromOffset(
					(DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
					DisplayFrame.AbsolutePosition.Y + 1
				)
			end

			local function updateMenuSize()
				local menuWidth = 60
				for i, label in next, ContextMenu.Inner:GetChildren() do
					if label:IsA('TextLabel') then
						menuWidth = math.max(menuWidth, label.TextBounds.X)
					end
				end

				ContextMenu.Container.Size = UDim2.fromOffset(
					menuWidth + 8,
					ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
				)
			end

			DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
			ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

			task.spawn(updateMenuPosition)
			task.spawn(updateMenuSize)

			EZ:AddToRegistry(ContextMenu.Inner, {
				BackgroundColor3 = 'BackgroundColor';
				BorderColor3 = 'OutlineColor';
			});

			function ContextMenu:Show()
				self.Container.Visible = true
			end

			function ContextMenu:Hide()
				self.Container.Visible = false
			end

			function ContextMenu:AddOption(Str, Callback)
				if type(Callback) ~= 'function' then
					Callback = function() end
				end

				local Button = EZ:CreateLabel({
					Active = false;
					Size = UDim2.new(1, 0, 0, 15);
					TextSize = 13;
					Text = Str;
					ZIndex = 16;
					Parent = self.Inner;
					TextXAlignment = Enum.TextXAlignment.Left,
				});

				EZ:OnHighlight(Button, Button,
					{ TextColor3 = 'AccentColor' },
					{ TextColor3 = 'FontColor' }
				);

				Button.InputBegan:Connect(function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					Callback()
				end)
			end

			local function GetSiblingPickers()
				local Pickers = {};

				for _, Addon in next, (ParentObj.Addons or {}) do
					if Addon.Type == 'ColorPicker' then
						table.insert(Pickers, Addon);
					end;
				end;

				return Pickers;
			end;

			ContextMenu:AddOption('Make gradient', function()
				local Pickers = GetSiblingPickers();

				if #Pickers < 3 then
					ContextMenu:Hide();
					return EZ:Notify('not enough colors for a gradient.', 2);
				end;

				local First, Last = Pickers[1].Value, Pickers[#Pickers].Value;

				for Index = 2, #Pickers - 1 do
					local Picker = Pickers[Index];
					Picker:SetValueRGB(First:Lerp(Last, Index / #Pickers), Picker.Transparency);
				end;

				EZ:Notify('created gradient!', 2);
				ContextMenu:Hide();
			end)

			ContextMenu:AddOption('Match color', function()
				for _, Picker in next, GetSiblingPickers() do
					Picker:SetValueRGB(ColorPicker.Value, Picker.Transparency);
				end;

				EZ:Notify('matched all colors!', 2);
				ContextMenu:Hide();
			end)

			ContextMenu:AddOption('Copy color', function()
				EZ.ColorClipboard = ColorPicker
				EZ:Notify('Copied color!', 2)
				ContextMenu:Hide();
			end)

			ContextMenu:AddOption('Paste color', function()
				if not EZ.ColorClipboard then
					return EZ:Notify('You have not copied a color!', 2)
				end

				ColorPicker:SetValueRGB(EZ.ColorClipboard.Value, EZ.ColorClipboard.Transparency)
				ContextMenu:Hide();
			end)

			ContextMenu:AddOption('Copy HEX', function()
				pcall(setclipboard, ColorPicker.Value:ToHex())
				EZ:Notify('Copied hex code to clipboard!', 2)
			end)

			ContextMenu:AddOption('Copy RGB', function()
				pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
				EZ:Notify('Copied RGB values to clipboard!', 2)
			end)

			if EZ.FlagCopying then
				ContextMenu:AddOption('Copy Flag', function()
					pcall(setclipboard, ColorPicker.Idx);
					task.wait();
					EZ:Notify('Copied flag to clipboard!', 2);
					ContextMenu:Hide();
				end)
			end
		end

		EZ:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
		EZ:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
		EZ:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

		EZ:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
		EZ:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
		EZ:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
		EZ:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

		local SequenceTable = {};

		for Hue = 0, 1, 0.1 do
			table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
		end;

		local HueSelectorGradient = EZ:Create('UIGradient', {
			Color = ColorSequence.new(SequenceTable);
			Rotation = 90;
			Parent = HueSelectorInner;
		});

		HueBox.FocusLost:Connect(function(enter)
			if enter then
				local success, result = pcall(Color3.fromHex, HueBox.Text)
				if success and typeof(result) == 'Color3' then
					ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
				end
			end

			ColorPicker:Display()
		end)

		RgbBox.FocusLost:Connect(function(enter)
			if enter then
				local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
				if r and g and b then
					ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
				end
			end

			ColorPicker:Display()
		end)

		function ColorPicker:Display()
			ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
			SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

			EZ:Create(DisplayFrame, {
				BackgroundColor3 = ColorPicker.Value;
				BackgroundTransparency = ColorPicker.Transparency;
				BorderColor3 = EZ:GetDarkerColor(ColorPicker.Value);
			});

			local Cache = EZ.TransparencyCache and EZ.TransparencyCache[DisplayFrame];

			if Cache then
				Cache.BackgroundTransparency = ColorPicker.Transparency;
			end;

			if TransparencyBoxInner then
				TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
				TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
			end;

			CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
			HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

			HueBox.Text = '#' .. ColorPicker.Value:ToHex()
			RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

			EZ:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
			EZ:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
		end;

		function ColorPicker:OnChanged(Func)
			ColorPicker.Changed = Func;
			Func(ColorPicker.Value)
		end;

		function ColorPicker:Show()
			for Frame, Val in next, EZ.OpenedFrames do
				if Frame.Name == 'Color' then
					Frame.Visible = false;
					EZ.OpenedFrames[Frame] = nil;
				end;
			end;

			PickerFrameOuter.Visible = true;
			EZ.OpenedFrames[PickerFrameOuter] = true;
		end;

		function ColorPicker:Hide()
			PickerFrameOuter.Visible = false;
			EZ.OpenedFrames[PickerFrameOuter] = nil;
		end;

		function ColorPicker:SetValue(HSV, Transparency)
			local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

			ColorPicker.Transparency = Transparency or 0;
			ColorPicker:SetHSVFromRGB(Color);
			ColorPicker:Display();
		end;

		function ColorPicker:SetValueRGB(Color, Transparency)
			ColorPicker.Transparency = Transparency or 0;
			ColorPicker:SetHSVFromRGB(Color);
			ColorPicker:Display();
		end;

		SatVibMap.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinX = SatVibMap.AbsolutePosition.X;
					local MaxX = MinX + SatVibMap.AbsoluteSize.X;
					local MouseX = math.clamp(Mouse.X, MinX, MaxX);

					local MinY = SatVibMap.AbsolutePosition.Y;
					local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

					ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
					ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
					ColorPicker:Display();

					RenderStepped:Wait();
				end;

				EZ:AttemptSave();
			end;
		end);

		HueSelectorInner.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinY = HueSelectorInner.AbsolutePosition.Y;
					local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

					ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
					ColorPicker:Display();

					RenderStepped:Wait();
				end;

				EZ:AttemptSave();
			end;
		end);

		DisplayFrame.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame() then
				if PickerFrameOuter.Visible then
					ColorPicker:Hide()
				else
					ContextMenu:Hide()
					ColorPicker:Show()
				end;
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not EZ:MouseIsOverOpenedFrame() then
				ContextMenu:Show()
				ColorPicker:Hide()
			end
		end);

		if TransparencyBoxInner then
			TransparencyBoxInner.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						local MinX = TransparencyBoxInner.AbsolutePosition.X;
						local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
						local MouseX = math.clamp(Mouse.X, MinX, MaxX);

						ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

						ColorPicker:Display();

						RenderStepped:Wait();
					end;

					EZ:AttemptSave();
				end;
			end);
		end;

		EZ:GiveSignal(InputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

					ColorPicker:Hide();
				end;

				if not EZ:IsMouseOverFrame(ContextMenu.Container) then
					ContextMenu:Hide()
				end
			end;

			if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
				if not EZ:IsMouseOverFrame(ContextMenu.Container) and not EZ:IsMouseOverFrame(DisplayFrame) then
					ContextMenu:Hide()
				end
			end
		end))

		function ColorPicker:Remove()
			Options[Idx] = nil;

			local Pickers = ParentObj.Addons or {};
			local Index = table.find(Pickers, ColorPicker);

			if Index then
				table.remove(Pickers, Index);
			end;

			PickerFrameOuter:Destroy();
			DisplayFrame:Destroy();
			ContextMenu.Container:Destroy();
			table.clear(ColorPicker);
		end;

		ColorPicker:Display();
		ColorPicker.DisplayFrame = DisplayFrame

		ParentObj.Addons = ParentObj.Addons or {};
		table.insert(ParentObj.Addons, ColorPicker);

		Options[Idx] = ColorPicker;

		if (self.ToggleRegion) then
			self.ColorPickerCount += 1;
			if (self.ColorPickerCount > 2) then
				self.ToggleRegion.Size -= UDim2.new(0,32,0,0);
			end
		end
		return self;
	end;

	function Funcs:AddKeyPicker(Idx, Info)
		local ParentObj = self;
		local ToggleLabel = self.TextLabel;
		local Container = self.Container;

		assert(Info.Default, 'AddKeyPicker: Missing default value.');

		local KeyPicker = {
			Idx = Idx;
			Value = Info.Default;
			Toggled = false;
			Override = false;
			Connections = {};
			Mode = Info.Mode or 'Toggle';
			Type = 'KeyPicker';
			Callback = Info.Callback or function(Value) end;
			ChangedCallback = Info.ChangedCallback or function(New) end;
			NoUI = Info.NoUI;
			SyncToggleState = Info.SyncToggleState or false;
			Parent = ParentObj;
		};

		if KeyPicker.SyncToggleState then
			Info.Modes = { 'Toggle' }
			Info.Mode = 'Toggle'
		end

		local PickOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 28, 0, 15);
			Visible = not EZ.IsMobile;
			ZIndex = 6;
			Parent = ToggleLabel;
		});

		local PickInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 7;
			Parent = PickOuter;
		});

		EZ:AddToRegistry(PickInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local DisplayLabel = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 13;
			Text = Info.Default;
			TextWrapped = true;
			ZIndex = 8;
			Parent = PickInner;
		});

		local ModeSelectOuter = EZ:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
			Size = UDim2.new(0, 60, 0, 45 + 2);
			Visible = false;
			ZIndex = 14;
			Parent = ScreenGui;
		});

		ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
		end);

		local ModeSelectInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 15;
			Parent = ModeSelectOuter;
		});

		EZ:AddToRegistry(ModeSelectInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		EZ:Create('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ModeSelectInner;
		});

		local ContainerLabel = EZ:CreateLabel({
			TextXAlignment = Enum.TextXAlignment.Left;
			Size = UDim2.new(1, 0, 0, 18);
			TextSize = 13;
			Visible = false;
			ZIndex = 110;
			Parent = EZ.KeybindContainer;
		},  true);

		local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
		local ModeButtons = {};

		for Idx, Mode in next, Modes do
			local ModeButton = {};

			local Label = EZ:CreateLabel({
				Active = false;
				Size = UDim2.new(1, 0, 0, 15);
				TextSize = 13;
				Text = Mode;
				ZIndex = 16;
				Parent = ModeSelectInner;
			});

			function ModeButton:Select()
				for _, Button in next, ModeButtons do
					Button:Deselect();
				end;

				KeyPicker.Mode = Mode;

				Label.TextColor3 = EZ.AccentColor;
				EZ.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

				ModeSelectOuter.Visible = false;
			end;

			function ModeButton:Deselect()
				KeyPicker.Mode = nil;

				Label.TextColor3 = EZ.FontColor;
				EZ.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
			end;

			Label.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					ModeButton:Select();
					EZ:AttemptSave();
				end;
			end);

			if Mode == KeyPicker.Mode then
				ModeButton:Select();
			end;

			ModeButtons[Mode] = ModeButton;
		end;

		local update = function(State)

			local ModeText = KeyPicker.Mode;
			if ModeText ~= 'Always' and KeyPicker.Override then
				ModeText = 'Override';
			end;

			ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, ModeText);

			ContainerLabel.Visible = true;
			ContainerLabel.TextColor3 = State and EZ.AccentColor or EZ.FontColor;

			EZ.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';
		end;

		function KeyPicker:Update()
			if not KeyPicker.NoUI then
				local mode = EZ.KeypickerListMode;
				local State = KeyPicker:GetState();

				if (mode == "Active" and KeyPicker.Parent.Type == "Toggle" and (not State or not KeyPicker.Parent.Value)) then
					ContainerLabel.Visible = false;
				elseif (mode == "Toggled" and KeyPicker.Parent.Type == "Toggle" and not KeyPicker.Parent.Value) then
					ContainerLabel.Visible = false;
				else
					update(State);
				end;
			else
				ContainerLabel.Visible = false;
			end;

			local YSize = 0
			local XSize = 0

			for _, Label in next, EZ.KeybindContainer:GetChildren() do
				if Label:IsA('TextLabel') and Label.Visible then
					YSize = YSize + 18;
					if (Label.TextBounds.X > XSize) then
						XSize = Label.TextBounds.X
					end
				end;
			end;

			EZ.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)

			EZ.KeybindFrame.Visible = EZ.KeypickerListVisible and (YSize ~= 0) and not EZ.IsMobile;
		end;

		function KeyPicker:OverrideState(State)
			if KeyPicker.Override == State then
				return;
			end;

			KeyPicker.Override = State;
			KeyPicker.Toggled = false;
			KeyPicker:Update();
		end;

		function KeyPicker:GetState()

			if KeyPicker.Parent and KeyPicker.Parent.Type == 'Toggle' and not KeyPicker.Parent.Value then
				return false;
			end;

			if KeyPicker.Mode == 'Always' then
				return true;
			end;

			local Key = KeyPicker.Value;

			local State;

			if KeyPicker.Mode == 'Hold' then

				if Key == 'None' or Key == '...' then
					return false;
				end;

				if Key == 'MB1' or Key == 'MB2' then
					State = Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
						or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
				else
					State = InputService:IsKeyDown(Enum.KeyCode[Key]);
				end;
			else
				State = KeyPicker.Toggled;
			end;

			if State and KeyPicker.Override then
				KeyPicker:OverrideState(false);
			end;

			return State or KeyPicker.Override;
		end;

		function KeyPicker:SetModePickerVisibility(Bool)
			ModeSelectOuter.Visible = Bool;
		end;

		function KeyPicker:GetModePickerVisibility()
			return ModeSelectOuter.Visible;
		end;

		function KeyPicker:SetupConnection(Connection)
			table.insert(KeyPicker.Connections, Connection);
			EZ:GiveSignal(Connection);
		end;

		function KeyPicker:Remove()
			Options[Idx] = nil;

			for _, Connection in next, KeyPicker.Connections do
				Connection:Disconnect();
			end;

			table.clear(KeyPicker);

			PickOuter:Destroy();
			ContainerLabel:Destroy();
			ModeSelectOuter:Destroy();
		end;

		function KeyPicker:SetValue(Data)
			local Key, Mode = Data[1], Data[2];
			DisplayLabel.Text = Key;
			KeyPicker.Value = Key;
			ModeButtons[Mode]:Select();
			KeyPicker:Update();
		end;

		function KeyPicker:OnClick(Callback)
			KeyPicker.Clicked = Callback
		end

		function KeyPicker:OnChanged(Callback)
			KeyPicker.Changed = Callback
			Callback(KeyPicker.Value)
		end

		if ParentObj.Addons then
			table.insert(ParentObj.Addons, KeyPicker)
		end

		function KeyPicker:DoClick()
			if KeyPicker.Override then
				KeyPicker.Override = false;
				KeyPicker.Toggled = false;
			end;

			if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
				ParentObj:SetValue(not ParentObj.Value)
			end

			EZ:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
			EZ:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
		end

		local Picking = false;

		local UnbindKeys = {
			[Enum.KeyCode.Escape] = true;
			[Enum.KeyCode.Backspace] = true;
		};

		PickOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame() then
				Picking = true;

				DisplayLabel.Text = '';

				local Break;
				local Text = '';

				task.spawn(function()
					while (not Break) do
						if Text == '...' then
							Text = '';
						end;

						Text = Text .. '.';
						DisplayLabel.Text = Text;

						wait(0.4);
					end;
				end);

				wait(0.2);

				local Event;
				Event = InputService.InputBegan:Connect(function(Input)
					local Key;

					if Input.UserInputType == Enum.UserInputType.Keyboard then
						Key = UnbindKeys[Input.KeyCode] and "..." or Input.KeyCode.Name;
					elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Key = 'MB1';
					elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
						Key = 'MB2';
					end;

					Break = true;
					Picking = false;

					DisplayLabel.Text = Key;
					KeyPicker.Value = Key;

					EZ:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
					EZ:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

					EZ:AttemptSave();

					Event:Disconnect();
				end);
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not EZ:MouseIsOverOpenedFrame() then
				ModeSelectOuter.Visible = true;
			end;
		end);

		KeyPicker:SetupConnection(InputService.InputBegan:Connect(function(Input, Processed)
			if (not Picking and not Processed) then
				local ParentOff = KeyPicker.Parent and KeyPicker.Parent.Type == 'Toggle' and not KeyPicker.Parent.Value;

				if KeyPicker.Mode == 'Toggle' and not ParentOff then
					local Key = KeyPicker.Value;

					if Key == 'MB1' or Key == 'MB2' then
						if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
							or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
							KeyPicker.Toggled = not KeyPicker.Toggled
							KeyPicker:DoClick()
						end;
					elseif Input.UserInputType == Enum.UserInputType.Keyboard then
						if Input.KeyCode.Name == Key then
							KeyPicker.Toggled = not KeyPicker.Toggled;
							KeyPicker:DoClick()
						end;
					end;
				end;

				KeyPicker:Update();
			end;

			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

					ModeSelectOuter.Visible = false;
				end;
			end;
		end))

		KeyPicker:SetupConnection(InputService.InputEnded:Connect(function(Input)
			if (not Picking) then
				KeyPicker:Update();
			end;
		end))

		if EZ.FlagCopying then
			local ContextMenu = EZ:AddContextMenu(PickOuter);

			ContextMenu:AddOption('Copy Flag', function()
				pcall(setclipboard, KeyPicker.Idx);
				task.wait();
				EZ:Notify('Copied flag to clipboard!', 2);
				ContextMenu:Hide();
			end);
		end;

		KeyPicker:Update();

		Options[Idx] = KeyPicker;

		return self;
	end;

	BaseAddons.__index = Funcs;
	BaseAddons.__namecall = function(Table, Key, ...)
		return Funcs[Key](...);
	end;
end;

local BaseGroupbox = {};

do
	local Funcs = {};

	function Funcs:AddBlank(Size)
		local Groupbox = self;
		local Container = Groupbox.Container;

		return EZ:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 0, Size);
			ZIndex = 1;
			Parent = Container;
		});
	end;

	function Funcs:AddContainer(Info)
		Info = Info or {};

		local Element = { Type = 'Container' };

		local Groupbox = self;
		local Container = Groupbox.Container;

		local Outer = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, Info.Size or 100);
			ZIndex = 5;
			Parent = Container;
		});

		local Inner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = Outer;
		});

		EZ:AddToRegistry(Inner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		function Element:SetSize(Y)
			Outer.Size = UDim2.new(1, -4, 0, Y);
			Groupbox:Resize();
		end;

		function Element:GetOuter()
			return Outer;
		end;

		function Element:GetInner()
			return Inner;
		end;

		function Element:GetSize()
			return Inner.AbsoluteSize;
		end;

		local Instances = {};
		table.insert(Instances, Groupbox:AddBlank(5));

		function Element:Remove()
			for _, Instance in next, Instances do
				Instance:Destroy();
			end;

			Outer:Destroy();
			table.clear(Element);
			Groupbox:Resize();
		end;

		Groupbox:Resize();

		return Element;
	end;

	function Funcs:AddLabel(Text, DoesWrap)
		local Label = {};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local TextLabel = EZ:CreateLabel({
			Size = UDim2.new(1, -4, 0, 15);
			TextSize = 14;
			Text = Text;
			TextWrapped = DoesWrap or false,
			TextXAlignment = Enum.TextXAlignment.Left;
			RichText = true,
			ZIndex = 5;
			Parent = Container;
		});

		if DoesWrap then
			local Y = select(2, EZ:GetTextBounds(Text, EZ.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
			TextLabel.Size = UDim2.new(1, -4, 0, Y)
		else
			EZ:Create('UIListLayout', {
				Padding = UDim.new(0, 4);
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Right;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = TextLabel;
			});
		end

		Label.TextLabel = TextLabel;
		Label.Container = Container;

		function Label:SetText(Text)
			TextLabel.Text = Text

			if DoesWrap then
				local Y = select(2, EZ:GetTextBounds(Text, EZ.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
				TextLabel.Size = UDim2.new(1, -4, 0, Y)
			end

			Groupbox:Resize();
		end

		if (not DoesWrap) then
			setmetatable(Label, BaseAddons);
		end

		local Instances = {};
		table.insert(Instances, Groupbox:AddBlank(5));

		function Label:Remove()
			for _, Instance in next, Instances do
				Instance:Destroy();
			end;

			TextLabel:Destroy();
			table.clear(Label);
			Groupbox:Resize();
		end;

		Groupbox:Resize();

		return Label;
	end;

	function Funcs:AddButton(...)

		local Button = {};
		local function ProcessButtonParams(Class, Obj, ...)
			local Props = select(1, ...)
			if type(Props) == 'table' then
				Obj.Text = Props.Text
				Obj.Func = Props.Func
				Obj.DoubleClick = Props.DoubleClick
				Obj.Tooltip = Props.Tooltip
			else
				Obj.Text = select(1, ...)
				Obj.Func = select(2, ...)
			end

			assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
		end

		ProcessButtonParams('Button', Button, ...)

		local Groupbox = self;
		local Container = Groupbox.Container;

		local function CreateBaseButton(Button)
			local Outer = EZ:Create('Frame', {
				BackgroundColor3 = Color3.new(0, 0, 0);
				BorderColor3 = Color3.new(0, 0, 0);
				Size = UDim2.new(1, -4, 0, 20);
				ZIndex = 5;
			});

			local Inner = EZ:Create('Frame', {
				BackgroundColor3 = EZ.MainColor;
				BorderColor3 = EZ.OutlineColor;
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.new(1, 0, 1, 0);
				ZIndex = 6;
				Parent = Outer;
			});

			local Label = EZ:CreateLabel({
				Size = UDim2.new(1, 0, 1, 0);
				TextSize = 14;
				Text = Button.Text;
				ZIndex = 6;
				Parent = Inner;
			});

			EZ:Create('UIGradient', {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
				});
				Rotation = 90;
				Parent = Inner;
			});

			EZ:AddToRegistry(Outer, {
				BorderColor3 = 'Black';
			});

			EZ:AddToRegistry(Inner, {
				BackgroundColor3 = 'MainColor';
				BorderColor3 = 'OutlineColor';
			});

			EZ:OnHighlight(Outer, Outer,
				{ BorderColor3 = 'OutlineColor' },
				{ BorderColor3 = 'Black' }
			);

			return Outer, Inner, Label
		end

		local function InitEvents(Button)
			local function WaitForEvent(event, timeout, validator)
				local bindable = Instance.new('BindableEvent')
				local connection = event:Once(function(...)

					if type(validator) == 'function' and validator(...) then
						bindable:Fire(true)
					else
						bindable:Fire(false)
					end
				end)
				task.delay(timeout, function()
					connection:disconnect()
					bindable:Fire(false)
				end)
				return bindable.Event:Wait()
			end

			local function ValidateClick(Input)
				if Input.UserInputType == Enum.UserInputType.Touch then
					return EZ:IsTap(Input)
				end

				return Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame()
			end

			Button.Outer.InputBegan:Connect(function(Input)
				if not ValidateClick(Input) then return end
				if Button.Locked then return end

				if Button.DoubleClick then
					EZ:RemoveFromRegistry(Button.Label)
					EZ:AddToRegistry(Button.Label, { TextColor3 = 'RiskColor' })

					Button.Label.TextColor3 = EZ.RiskColor
					Button.Label.Text = 'Are you sure?'
					Button.Locked = true

					local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

					EZ:RemoveFromRegistry(Button.Label)
					EZ:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

					Button.Label.TextColor3 = EZ.FontColor
					Button.Label.Text = Button.Text
					task.defer(rawset, Button, 'Locked', false)

					if clicked then
						EZ:SafeCallback(Button.Func)
					end

					return
				end

				EZ:SafeCallback(Button.Func);
			end)
		end

		Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
		Button.Outer.Parent = Container

		InitEvents(Button)

		function Button:AddTooltip(tooltip)
			if type(tooltip) == 'string' then
				EZ:AddToolTip(tooltip, self.Outer)
			end
			return self
		end

		function Button:AddButton(...)
			local SubButton = {}

			ProcessButtonParams('SubButton', SubButton, ...)

			self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

			SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

			SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
			SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
			SubButton.Outer.Parent = self.Outer

			function SubButton:AddTooltip(tooltip)
				if type(tooltip) == 'string' then
					EZ:AddToolTip(tooltip, self.Outer)
				end
				return SubButton
			end

			if type(SubButton.Tooltip) == 'string' then
				SubButton:AddTooltip(SubButton.Tooltip)
			end

			InitEvents(SubButton)
			return SubButton
		end

		if type(Button.Tooltip) == 'string' then
			Button:AddTooltip(Button.Tooltip)
		end

		Groupbox:AddBlank(5);
		Groupbox:Resize();

		return Button;
	end;

	function Funcs:AddDivider()
		local Groupbox = self;
		local Container = self.Container

		local Divider = {
			Type = 'Divider',
		}

		Groupbox:AddBlank(2);
		local DividerOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 5);
			ZIndex = 5;
			Parent = Container;
		});

		local DividerInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = DividerOuter;
		});

		EZ:AddToRegistry(DividerOuter, {
			BorderColor3 = 'Black';
		});

		EZ:AddToRegistry(DividerInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Groupbox:AddBlank(9);
		Groupbox:Resize();
	end

	function Funcs:AddInput(Idx, Info)
		assert(Info.Text, 'AddInput: Missing `Text` string.')

		local Textbox = {
			Idx = Idx;
			Value = Info.Default or '';
			Numeric = Info.Numeric or false;
			Finished = Info.Finished or false;
			MaxLength = Info.MaxLength;
			Type = 'Input';
			Callback = Info.Callback or function(Value) end;
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local InputLabel = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 0, 15);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 5;
			Parent = Container;
		});

		Groupbox:AddBlank(1);

		local TextBoxOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		});

		local TextBoxInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = TextBoxOuter;
		});

		EZ:AddToRegistry(TextBoxInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		EZ:OnHighlight(TextBoxOuter, TextBoxOuter,
			{ BorderColor3 = 'OutlineColor' },
			{ BorderColor3 = 'Black' }
		);

		if type(Info.Tooltip) == 'string' then
			EZ:AddToolTip(Info.Tooltip, TextBoxOuter)
		end

		EZ:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = TextBoxInner;
		});

		local Container = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			ClipsDescendants = true;

			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);

			ZIndex = 7;
			Parent = TextBoxInner;
		})

		local Box = EZ:Create('TextBox', {
			BackgroundTransparency = 1;

			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(5, 1),

			Font = EZ.Font;
			PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
			PlaceholderText = Info.Placeholder or '';

			ClearTextOnFocus = Info.Clear or false;
			Text = Info.Default or '';
			TextColor3 = EZ.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Left;

			ZIndex = 7;
			Parent = Container;
		});

		EZ:ApplyTextStroke(Box);

		function Textbox:SetValue(Text)
			if Info.MaxLength and #Text > Info.MaxLength then
				Text = Text:sub(1, Info.MaxLength);
			end;

			if Textbox.Numeric then
				if (not tonumber(Text)) and Text:len() > 0 then
					Text = Textbox.Value
				end
			end

			Textbox.Value = Text;
			Box.Text = Text;

			EZ:SafeCallback(Textbox.Callback, Textbox.Value);
			EZ:SafeCallback(Textbox.Changed, Textbox.Value);
		end;

		if Textbox.Finished then
			Box.FocusLost:Connect(function(enter)
				if not enter then return end

				Textbox:SetValue(Box.Text);
				EZ:AttemptSave();
			end)
		else
			Box:GetPropertyChangedSignal('Text'):Connect(function()
				Textbox:SetValue(Box.Text);
				EZ:AttemptSave();
			end);
		end

		local function Update()
			local PADDING = 2
			local reveal = Container.AbsoluteSize.X

			if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then

				Box.Position = UDim2.new(0, PADDING, 0, 0)
			else

				local cursor = Box.CursorPosition
				if cursor ~= -1 then

					local subtext = string.sub(Box.Text, 1, cursor-1)
					local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

					local currentCursorPos = Box.Position.X.Offset + width

					if currentCursorPos < PADDING then
						Box.Position = UDim2.fromOffset(PADDING-width, 0)
					elseif currentCursorPos > reveal - PADDING - 1 then
						Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
					end
				end
			end
		end

		task.spawn(Update)

		Box:GetPropertyChangedSignal('Text'):Connect(Update)
		Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
		Box.FocusLost:Connect(Update)
		Box.Focused:Connect(Update)

		EZ:AddToRegistry(Box, {
			TextColor3 = 'FontColor';
		});

		function Textbox:OnChanged(Func)
			Textbox.Changed = Func;
			Func(Textbox.Value);
		end;

		if EZ.FlagCopying then
			local ContextMenu = EZ:AddContextMenu(TextBoxOuter);

			ContextMenu:AddOption('Copy Flag', function()
				pcall(setclipboard, Textbox.Idx);
				task.wait();
				EZ:Notify('Copied flag to clipboard!', 2);
				ContextMenu:Hide();
			end);
		end;

		Textbox.Instances = {};
		table.insert(Textbox.Instances, Groupbox:AddBlank(5));

		function Textbox:Remove()
			for _, Instance in next, Textbox.Instances do
				Instance:Destroy();
			end;

			Options[Idx] = nil;
			TextBoxOuter:Destroy();
			InputLabel:Destroy();
			table.clear(Textbox);
			Groupbox:Resize();
		end;

		Groupbox:Resize();

		Options[Idx] = Textbox;

		return Textbox;
	end;

	function Funcs:AddToggle(Idx, Info)
		assert(Info.Text, 'AddInput: Missing `Text` string.')

		local Toggle = {
			Idx = Idx;
			Value = Info.Default or false;
			Type = 'Toggle';
			Visible = true;

			Callback = Info.Callback or function(Value) end;
			ChangedFuncs = {};
			Addons = {},
			Risky = Info.Risky,
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local ToggleOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 13, 0, 13);
			ZIndex = 5;
			Parent = Container;
		});

		EZ:AddToRegistry(ToggleOuter, {
			BorderColor3 = 'Black';
		});

		local ToggleInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = ToggleOuter;
		});

		EZ:AddToRegistry(ToggleInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local ToggleLabel = EZ:CreateLabel({
			Size = UDim2.new(0, 216, 1, 0);
			Position = UDim2.new(1, 6, 0, 0);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 6;
			Parent = ToggleInner;
		});

		EZ:Create('UIListLayout', {
			Padding = UDim.new(0, 4);
			FillDirection = Enum.FillDirection.Horizontal;
			HorizontalAlignment = Enum.HorizontalAlignment.Right;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ToggleLabel;
		});

		local ToggleRegion = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(0, 170, 1, 0);
			ZIndex = 8;
			Parent = ToggleOuter;
		});

		EZ:OnHighlight(ToggleRegion, ToggleOuter,
			{ BorderColor3 = 'OutlineColor' },
			{ BorderColor3 = 'Black' }
		);

		function Toggle:UpdateColors()
			Toggle:Display();
		end;

		if type(Info.Tooltip) == 'string' then
			EZ:AddToolTip(Info.Tooltip, ToggleRegion)
		end

		function Toggle:Display()
			ToggleInner.BackgroundColor3 = Toggle.Value and EZ.AccentColor or EZ.MainColor;
			ToggleInner.BorderColor3 = Toggle.Value and EZ.AccentColorDark or EZ.OutlineColor;

			EZ.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
			EZ.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
		end;

		function Toggle:OnChanged(Func)
			table.insert(Toggle.ChangedFuncs, Func);
			Func(Toggle.Value);
		end;

		function Toggle:SetValue(Bool)

			if Toggle.SettingValue then
				return;
			end;

			Toggle.SettingValue = true;

			Bool = (not not Bool);

			Toggle.Value = Bool;
			Toggle:Display();

			for _, Addon in next, Toggle.Addons do
				if Addon.Type == 'KeyPicker' then
					if Addon.SyncToggleState then
						Addon.Toggled = Bool;
					elseif not Bool then

						Addon.Toggled = false;
						Addon.Override = false;
					end;
					Addon:Update();
				end;
			end

			EZ:SafeCallback(Toggle.Callback, Toggle.Value);
			EZ:SafeCallback(Toggle.Changed, Toggle.Value);

			for _, Func in next, Toggle.ChangedFuncs do
				EZ:SafeCallback(Func, Toggle.Value);
			end;

			EZ:UpdateDependencyBoxes(Toggle);

			Toggle.SettingValue = false;
		end;

		function Toggle:SetVisible(Bool)
			Toggle.Visible = Bool;
			ToggleOuter.Visible = Bool;

			for _, Instance in next, Toggle.Instances do
				Instance.Visible = Bool;
			end;

			Groupbox:Resize();
		end;

		function Toggle:Remove()
			for _, Instance in next, Toggle.Instances do
				Instance:Destroy();
			end;

			Toggles[Idx] = nil;
			ToggleOuter:Destroy();
			table.clear(Toggle);
			Groupbox:Resize();
		end;

		ToggleRegion.InputBegan:Connect(function(Input)

			if EZ.IsDragging then
				return;
			end;

			if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame())
				or Input.UserInputType == Enum.UserInputType.Touch and EZ:IsTap(Input) then

				Toggle:SetValue(not Toggle.Value)
				EZ:AttemptSave();
			end;
		end);

		if EZ.FlagCopying then
			local ContextMenu = EZ:AddContextMenu(ToggleOuter, ToggleRegion);

			ContextMenu:AddOption('Copy Flag', function()
				pcall(setclipboard, Toggle.Idx);
				task.wait();
				EZ:Notify('Copied flag to clipboard!', 2);
				ContextMenu:Hide();
			end);
		end;

		if Toggle.Risky then
			EZ:RemoveFromRegistry(ToggleLabel)
			ToggleLabel.TextColor3 = EZ.RiskColor
			EZ:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
		end

		Toggle:Display();

		Toggle.Instances = {};
		table.insert(Toggle.Instances, Groupbox:AddBlank(Info.BlankSize or 7));

		Groupbox:Resize();

		Toggle.ColorPickerCount = 0;
		Toggle.ToggleRegion = ToggleRegion;
		Toggle.TextLabel = ToggleLabel;
		Toggle.Container = Container;
		setmetatable(Toggle, BaseAddons);

		Toggles[Idx] = Toggle;

		EZ:UpdateDependencyBoxes();

		return Toggle;
	end;

	function Funcs:AddSlider(Idx, Info, SliderParent)
		assert(Info.Default, 'AddSlider: Missing default value.');
		assert(Info.Text, 'AddSlider: Missing slider text.');
		assert(Info.Min, 'AddSlider: Missing minimum value.');
		assert(Info.Max, 'AddSlider: Missing maximum value.');
		assert(Info.Rounding, 'AddSlider: Missing rounding value.');

		local Slider = {
			Idx = Idx;
			Value = Info.Default;
			Min = Info.Min;
			Max = Info.Max;
			Rounding = Info.Rounding;
			Increment = Info.Increment;
			MaxSize = 232;
			Type = 'Slider';
			Callback = Info.Callback or function(Value) end;
			ChangedFuncs = {};
		};

		Slider.Parent = SliderParent;

		local Groupbox = self;
		local Container = SliderParent and SliderParent.Outer or Groupbox.Container;

		if Info.Compact == nil then
			Info.Compact = SliderParent == nil;
		end;

		if not Info.Compact then
			EZ:CreateLabel({
				Size = UDim2.new(1, 0, 0, 10);
				Position = SliderParent and UDim2.new(1, 4, 0, -12) or UDim2.new();
				TextSize = 14;
				Text = Info.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				ZIndex = 5;
				Parent = Container;
			});

			Groupbox:AddBlank(3);
		end;

		local SliderOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);

			Size = UDim2.new(1,0,0,13);
			ZIndex = 5;
			Parent = Container;
		});

		Slider.Outer = SliderOuter;

		EZ:AddToRegistry(SliderOuter, {
			BorderColor3 = 'Black';
		});

		local SliderInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = SliderOuter;
		});

		EZ:AddToRegistry(SliderInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local Fill = EZ:Create('Frame', {
			BackgroundColor3 = EZ.AccentColor;
			BorderColor3 = EZ.AccentColorDark;
			Size = UDim2.new(0, 0, 1, 0);
			ZIndex = 7;
			Parent = SliderInner;
		});

		EZ:AddToRegistry(Fill, {
			BackgroundColor3 = 'AccentColor';
			BorderColor3 = 'AccentColorDark';
		});

		local HideBorderRight = EZ:Create('Frame', {
			BackgroundColor3 = EZ.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(1, 0, 0, 0);
			Size = UDim2.new(0, 1, 1, 0);
			ZIndex = 8;
			Parent = Fill;
		});

		EZ:AddToRegistry(HideBorderRight, {
			BackgroundColor3 = 'AccentColor';
		});

		local DisplayLabel = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = 'Infinite';
			ZIndex = 9;
			Parent = SliderInner;
		});

		EZ:OnHighlight(SliderOuter, SliderOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		);

		if type(Info.Tooltip) == 'string' then
			EZ:AddToolTip(Info.Tooltip, SliderOuter)
		end

		local get_count = function()
			local parent, count = Slider, 1;
			repeat
				parent = parent.Parent or nil;
				if (parent) then
					count += 1;
				end
			until not parent;
			return count;
		end;

		function Slider:UpdateColors()
			Fill.BackgroundColor3 = EZ.AccentColor;
			Fill.BorderColor3 = EZ.AccentColorDark;
		end;

		local FillTween = nil;

		function Slider:Display()
			local Suffix = Info.Suffix or '';

			if Info.Compact then
				DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix;
			elseif Info.HideMax then
				DisplayLabel.Text = Slider.Value .. Suffix;
			else
				DisplayLabel.Text = Slider.Value .. Suffix .. '/' .. Slider.Max .. Suffix;
			end;

			local Alpha = EZ:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, 1);

			if FillTween then
				FillTween:Cancel();
			end;

			FillTween = TweenService:Create(
				Fill,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.new(Alpha, 0, 1, 0) }
			);

			FillTween:Play();

			HideBorderRight.Visible = not (Alpha == 1 or Alpha == 0);
		end;

		function Slider:OnChanged(Func)
			table.insert(Slider.ChangedFuncs, Func);
			Func(Slider.Value);
		end;

		local function Round(Value)
			if Slider.Increment then
				local Snapped = math.round(Value / Slider.Increment) * Slider.Increment;
				return tonumber(string.format('%.10f', Snapped));
			elseif Slider.Rounding == 0 then
				return math.floor(Value);
			end;

			return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
		end;

		function Slider:GetValueFromXOffset(X)
			return Round(EZ:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max)) + 0;
		end;

		function Slider:SetValue(Str)
			local Num = tonumber(Str);

			if (not Num) then
				return;
			end;

			Num = math.clamp(Num, Slider.Min, Slider.Max);

			Slider.Value = Num;
			Slider:Display();

			EZ:SafeCallback(Slider.Callback, Slider.Value);
			EZ:SafeCallback(Slider.Changed, Slider.Value);

			for _, Func in next, Slider.ChangedFuncs do
				EZ:SafeCallback(Func, Slider.Value);
			end;
		end;

		if (get_count() < 3) then
			function Slider:AddSlider(idx, info)

				if Info.Compact and info.Compact ~= true then
					Info.Compact = false;

					EZ:CreateLabel({
						Size = UDim2.new(1, 0, 0, 10);
						Position = UDim2.new(0, 0, 0, -12);
						TextSize = 14;
						Text = Info.Text;
						TextXAlignment = Enum.TextXAlignment.Left;
						TextYAlignment = Enum.TextYAlignment.Bottom;
						ZIndex = 5;
						Parent = SliderOuter;
					});
				end;

				Slider:Display();
				return Funcs.AddSlider(Groupbox, idx, info, Slider);
			end;
		end

		local function FireChanged(NewValue)
			EZ:SafeCallback(Slider.Callback, Slider.Value);
			EZ:SafeCallback(Slider.Changed, Slider.Value);

			for _, Func in next, Slider.ChangedFuncs do
				EZ:SafeCallback(Func, NewValue);
			end;
		end;

		SliderInner.InputBegan:Connect(function(Input)
			if EZ.IsDragging then
				return;
			end;

			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame() then
				local mPos = Mouse.X;
				local gPos = Fill.Size.X.Offset;
				local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local nMPos = Mouse.X;
					local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

					local nValue = Slider:GetValueFromXOffset(nX);
					local OldValue = Slider.Value;
					Slider.Value = nValue;

					Slider:Display();

					if nValue ~= OldValue then
						FireChanged(nValue);
					end;

					RenderStepped:Wait();
				end;

				EZ:AttemptSave();
			end;

			if Input.UserInputType == Enum.UserInputType.Touch and not EZ:MouseIsOverOpenedFrame() then
				local mPos = Input.Position.X;
				local gPos = Fill.Size.X.Offset;
				local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

				local Start = Input.Position;

				while Input.UserInputState ~= Enum.UserInputState.End do
					local D = Input.Position - Start;
					local X, Y = math.abs(D.X), math.abs(D.Y);

					if Y > 8 and Y > X then
						return;
					elseif X > 8 then
						break;
					end;

					RenderStepped:Wait();
				end;

				repeat
					local nMPos = Input.Position.X;
					local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

					local nValue = Slider:GetValueFromXOffset(nX);
					local OldValue = Slider.Value;
					Slider.Value = nValue;

					Slider:Display();

					if nValue ~= OldValue then
						FireChanged(nValue);
					end;

					RenderStepped:Wait();
				until Input.UserInputState == Enum.UserInputState.End;

				EZ:AttemptSave();
			end;
		end);

		if EZ.FlagCopying then
			local ContextMenu = EZ:AddContextMenu(SliderOuter);

			ContextMenu:AddOption('Copy Flag', function()
				pcall(setclipboard, Slider.Idx);
				task.wait();
				EZ:Notify('Copied flag to clipboard!', 2);
				ContextMenu:Hide();
			end);
		end;

		Slider:Display();

		local size = get_count();
		local get_slider = function(count)
			local slider = Slider;
			for i=1,count-1 do
				slider = slider.Parent;
			end;
			return slider;
		end;

		local wanted_size = (Groupbox.Container.AbsoluteSize.X) / size;
		wanted_size += size - 2;

		local n_size = math.round(wanted_size);

		for i = size, 1, -1 do
			local slider = get_slider(i);
			slider.Outer.Size = UDim2.new(0, n_size - 3, 0, 13)
			slider.Outer.Position = UDim2.new(1, 2, 0, 0);
			slider.MaxSize = slider.Outer.AbsoluteSize.X - 2;

			slider:Display();
		end;

		if (n_size ~= wanted_size) then
			local slider = get_slider(1);
			slider.Outer.Size = UDim2.new(0, n_size - (size + 1), 0, 13)
			slider.Outer.Position = UDim2.new(1, 2, 0, 0);
			slider.MaxSize = slider.Outer.AbsoluteSize.X - 2;

			slider:Display();
		end;

		Slider.Instances = {};

		if (not SliderParent) then
			table.insert(Slider.Instances, Groupbox:AddBlank(Info.BlankSize or 6));
			Groupbox:Resize();
		end;

		function Slider:Remove()
			for _, Instance in next, Slider.Instances do
				Instance:Destroy();
			end;

			Options[Idx] = nil;
			SliderOuter:Destroy();
			table.clear(Slider);
			Groupbox:Resize();
		end;

		Options[Idx] = Slider;

		return Slider;
	end;

	function Funcs:AddDropdown(Idx, Info)
		assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
		assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

		if (not Info.Text) then
			Info.Compact = true;
		end;

		local Dropdown = {
			Idx = Idx;
			Illegal = Info.Illegal;
			Values = Info.Values;
			Value = Info.Multi and {};
			Multi = Info.Multi;
			Type = 'Dropdown';
			Callback = Info.Callback or function(Value) end;
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local RelativeOffset = 0;

		if not Info.Compact then
			local DropdownLabel = EZ:CreateLabel({
				Size = UDim2.new(1, 0, 0, 10);
				TextSize = 14;
				Text = Info.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				ZIndex = 5;
				Parent = Container;
			});

			Groupbox:AddBlank(3);
		end

		for _, Element in next, Container:GetChildren() do
			if not Element:IsA('UIListLayout') then
				RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
			end;
		end;

		local DropdownOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		});

		EZ:AddToRegistry(DropdownOuter, {
			BorderColor3 = 'Black';
		});

		local DropdownInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = DropdownOuter;
		});

		EZ:AddToRegistry(DropdownInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		EZ:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = DropdownInner;
		});

		local DropdownArrow = EZ:CreateLabel({
			AnchorPoint = Vector2.new(0.5, 0.5);
			BackgroundTransparency = 1;
			Position = UDim2.new(1, -11, 0.5, 0);
			Size = UDim2.fromOffset(14, 14);
			Text = '>';
			TextSize = 14;
			Font = Enum.Font.GothamBold;
			ZIndex = 8;
			Parent = DropdownInner;
		});

		local DropdownArrowTween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

		local ItemClip = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			ClipsDescendants = true;
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -22, 1, 0);
			ZIndex = 7;
			Parent = DropdownInner;
		});

		local ItemList = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = '...';
			TextXAlignment = Enum.TextXAlignment.Left;
			TextTruncate = Enum.TextTruncate.AtEnd;
			ZIndex = 7;
			Parent = ItemClip;
		});

		EZ:OnHighlight(DropdownOuter, DropdownOuter,
			{ BorderColor3 = 'OutlineColor' },
			{ BorderColor3 = 'Black' }
		);

		if type(Info.Tooltip) == 'string' then
			EZ:AddToolTip(Info.Tooltip, DropdownOuter)
		end

		local Max_dropdown_items = 8;

		local ListOuter = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			ZIndex = 20;
			Visible = false;
			Parent = ScreenGui;
		});

		local function RecalculateListPosition()
			ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
		end;

		local function RecalculateListSize(YSize)
			ListOuter.Size = UDim2.fromOffset(
				DropdownOuter.AbsoluteSize.X + 0.5,
				YSize or math.clamp(#Dropdown.Values * 20, 0, Max_dropdown_items * 20) + 1
			);
		end;

		RecalculateListPosition();
		RecalculateListSize();

		DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

		local ListInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 21;
			Parent = ListOuter;
		});

		EZ:AddToRegistry(ListInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local Scrolling = EZ:Create('ScrollingFrame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			CanvasSize = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 21;
			Parent = ListInner;

			TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
			BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

			ScrollBarThickness = EZ.IsMobile and 15 or 3,
			ScrollBarImageColor3 = EZ.AccentColor,
		});

		EZ:AddToRegistry(Scrolling, {
			ScrollBarImageColor3 = 'AccentColor'
		})

		EZ:Create('UIListLayout', {
			Padding = UDim.new(0, 0);
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = Scrolling;
		});

		function Dropdown:Display()
			local Values = Dropdown.Values;
			local Str = '';

			if Info.Multi then
				for Idx, Value in next, Values do
					if Dropdown.Value[Value] then
						Str = Str .. Value .. ', ';
					end;
				end;

				Str = Str:sub(1, #Str - 2);
			else
				Str = Dropdown.Value or '';
			end;

			ItemList.Text = (Str == '' and '...' or Str);
		end;

		function Dropdown:GetActiveValues()
			if Info.Multi then
				local count = 0;

				for Value, Bool in next, Dropdown.Value do
					count += 1;
				end;

				return count;
			else
				return Dropdown.Value and 1 or 0;
			end;
		end;

		function Dropdown:BuildDropdownList()
			local Values = Dropdown.Values;
			local Buttons = {};

			for _, Element in next, Scrolling:GetChildren() do
				if not Element:IsA('UIListLayout') then
					Element:Destroy();
				end;
			end;

			local Count = 0;

			for Idx, Value in next, Values do
				local Table = {};

				Count = Count + 1;

				local Button = EZ:Create('Frame', {
					BackgroundColor3 = EZ.MainColor;
					BorderColor3 = EZ.OutlineColor;
					BorderMode = Enum.BorderMode.Middle;
					Size = UDim2.new(1, -1, 0, 20);
					ZIndex = 23;
					Active = true,
					Parent = Scrolling;
				});

				EZ:AddToRegistry(Button, {
					BackgroundColor3 = 'MainColor';
					BorderColor3 = 'OutlineColor';
				});

				local ButtonLabel = EZ:CreateLabel({
					Active = false;
					Size = UDim2.new(1, -6, 1, 0);
					Position = UDim2.new(0, 6, 0, 0);
					TextSize = 14;
					Text = Value;
					TextXAlignment = Enum.TextXAlignment.Left;
					ZIndex = 25;
					Parent = Button;
				});

				EZ:OnHighlight(Button, Button,
					{ BorderColor3 = 'OutlineColor', ZIndex = 24 },
					{ BorderColor3 = 'OutlineColor', ZIndex = 23 }
				);

				local Selected;

				if Info.Multi then
					Selected = Dropdown.Value[Value];
				else
					Selected = Dropdown.Value == Value;
				end;

				function Table:UpdateButton()
					if Info.Multi then
						Selected = Dropdown.Value[Value];
					else
						Selected = Dropdown.Value == Value;
					end;

					ButtonLabel.TextColor3 = Selected and EZ.AccentColor or EZ.FontColor;
					EZ.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
				end;

				ButtonLabel.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch and EZ:IsTap(Input) then

						local Try = not Selected;

						if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
						else
							if Info.Multi then
								Selected = Try;

								if Selected then
									Dropdown.Value[Value] = true;
								else
									Dropdown.Value[Value] = nil;
								end;
							else
								Selected = Try;

								if Selected then
									Dropdown.Value = Value;
								else
									Dropdown.Value = nil;
								end;

								for _, OtherButton in next, Buttons do
									OtherButton:UpdateButton();
								end;
							end;

							Table:UpdateButton();
							Dropdown:Display();

							EZ:SafeCallback(Dropdown.Callback, Dropdown.Value);
							EZ:SafeCallback(Dropdown.Changed, Dropdown.Value);

							EZ:AttemptSave();
						end;
					end;
				end);

				Table:UpdateButton();
				Dropdown:Display();

				Buttons[Button] = Table;
			end;

			Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

			Scrolling.Visible = false;
			Scrolling.Visible = true;

			RecalculateListSize(math.clamp(Count * 20, 0, Max_dropdown_items * 20) + 1);
		end;

		function Dropdown:SetValues(NewValues)
			if NewValues then
				Dropdown.Values = NewValues;
			end;

			Dropdown:BuildDropdownList();
		end;

		function Dropdown:OpenDropdown()

			if EZ.IsMobile then
				EZ.CanDrag = false;
			end;

			ListOuter.Visible = true;
			EZ.OpenedFrames[ListOuter] = true;
			TweenService:Create(DropdownArrow, DropdownArrowTween, { Rotation = 90 }):Play();

			RecalculateListSize();
		end;

		function Dropdown:CloseDropdown()
			if EZ.IsMobile then
				EZ.CanDrag = true;
			end;

			ListOuter.Visible = false;
			EZ.OpenedFrames[ListOuter] = nil;
			TweenService:Create(DropdownArrow, DropdownArrowTween, { Rotation = 0 }):Play();
		end;

		function Dropdown:OnChanged(Func)
			Dropdown.Changed = Func;
			Func(Dropdown.Value);
		end;

		function Dropdown:SetValue(Val)
			if Dropdown.Multi then
				local nTable = {};

				for Value, Bool in next, Val do
					if Dropdown.Illegal or table.find(Dropdown.Values, Value) then
						nTable[Value] = true
					end;
				end;

				Dropdown.Value = nTable;
			else
				if (not Val) then
					Dropdown.Value = nil;
				elseif Dropdown.Illegal or table.find(Dropdown.Values, Val) then
					Dropdown.Value = Val;
				end;
			end;

			Dropdown:BuildDropdownList();

			EZ:SafeCallback(Dropdown.Callback, Dropdown.Value);
			EZ:SafeCallback(Dropdown.Changed, Dropdown.Value);
			EZ:UpdateDependencyBoxes(Dropdown);
		end;

		DropdownOuter.InputBegan:Connect(function(Input)
			if EZ.IsDragging then
				return;
			end;

			if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame())
				or Input.UserInputType == Enum.UserInputType.Touch and EZ:IsTap(Input) then

				if ListOuter.Visible then
					Dropdown:CloseDropdown();
				else
					Dropdown:OpenDropdown();
				end;
			end;
		end);

		EZ:GiveSignal(InputService.InputBegan:Connect(function(Input)
			if EZ.IsDragging then
				return;
			end;

			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;
				local Pos = Input.UserInputType == Enum.UserInputType.Touch and Input.Position or Vector2.new(Mouse.X, Mouse.Y);

				if Pos.X < AbsPos.X or Pos.X > AbsPos.X + AbsSize.X
					or Pos.Y < (AbsPos.Y - 20 - 1) or Pos.Y > AbsPos.Y + AbsSize.Y then

					Dropdown:CloseDropdown();
				end;
			end;
		end));

		if EZ.FlagCopying then
			local ContextMenu = EZ:AddContextMenu(DropdownOuter);

			ContextMenu:AddOption('Copy Flag', function()
				pcall(setclipboard, Dropdown.Idx);
				task.wait();
				EZ:Notify('Copied flag to clipboard!', 2);
				ContextMenu:Hide();
			end);
		end;

		Dropdown:BuildDropdownList();
		Dropdown:Display();

		local Defaults = {}

		if type(Info.Default) == 'string' then
			local Idx = table.find(Dropdown.Values, Info.Default)
			if Idx then
				table.insert(Defaults, Idx)
			end
		elseif type(Info.Default) == 'table' then
			for _, Value in next, Info.Default do
				local Idx = table.find(Dropdown.Values, Value)
				if Idx then
					table.insert(Defaults, Idx)
				end
			end
		elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
			table.insert(Defaults, Info.Default)
		end

		if next(Defaults) then
			for i = 1, #Defaults do
				local Index = Defaults[i]
				if Info.Multi then
					Dropdown.Value[Dropdown.Values[Index]] = true
				else
					Dropdown.Value = Dropdown.Values[Index];
				end

				if (not Info.Multi) then break end
			end

			Dropdown:BuildDropdownList();
			Dropdown:Display();
		end

		Dropdown.Instances = {};
		table.insert(Dropdown.Instances, Groupbox:AddBlank(Info.BlankSize or 5));

		function Dropdown:Remove()
			for _, Instance in next, Dropdown.Instances do
				Instance:Destroy();
			end;

			Options[Idx] = nil;
			DropdownOuter:Destroy();
			ListOuter:Destroy();
			table.clear(Dropdown);
			Groupbox:Resize();
		end;

		Groupbox:Resize();

		Options[Idx] = Dropdown;

		return Dropdown;
	end;

	function Funcs:AddDependencyBox()
		local Depbox = {
			Dependencies = {};
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local Holder = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 0, 0);
			Visible = false;
			Parent = Container;
		});

		local Frame = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = true;
			Parent = Holder;
		});

		local Layout = EZ:Create('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = Frame;
		});

		function Depbox:Resize()
			Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
			Groupbox:Resize();
		end;

		Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			Depbox:Resize();
		end);

		Holder:GetPropertyChangedSignal('Visible'):Connect(function()
			Depbox:Resize();
		end);

		function Depbox:Update()
			local Visible = false;

			for _, Dependency in next, Depbox.Dependencies do
				if Dependency[1].Value == Dependency[2] then
					Visible = true;
					break;
				end;
			end;

			Holder.Visible = Visible;
			Depbox:Resize();
		end;

		function Depbox:SetupDependencies(Dependencies)
			for _, Dependency in next, Dependencies do
				assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
				assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
				assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');

				local Element = Dependency[1];
				Element.DependencyBoxes = Element.DependencyBoxes or {};
				table.insert(Element.DependencyBoxes, Depbox);
			end;

			Depbox.Dependencies = Dependencies;
			Depbox:Update();
		end;

		function Depbox:Remove()
			local Index = table.find(EZ.DependencyBoxes, Depbox);

			if Index then
				table.remove(EZ.DependencyBoxes, Index);
			end;

			for _, Dependency in next, Depbox.Dependencies do
				local Element = Dependency[1];
				local ElementIndex = table.find(Element.DependencyBoxes, Depbox);

				if ElementIndex then
					table.remove(Element.DependencyBoxes, ElementIndex);
				end;
			end;

			table.clear(Depbox);
			Holder:Destroy();
			Groupbox:Resize();
		end;

		Depbox.Container = Frame;

		setmetatable(Depbox, BaseGroupbox);

		table.insert(EZ.DependencyBoxes, Depbox);

		return Depbox;
	end;

	BaseGroupbox.__index = Funcs;
	BaseGroupbox.__namecall = function(Table, Key, ...)
		return Funcs[Key](...);
	end;
end;

do

	local NotificationOuter = EZ:Create('Frame', {
		BackgroundTransparency = 1;
		AnchorPoint = Vector2.new(0.5, 0);
		Position = UDim2.new(0.5, 0, 0.6, 0);
		Size = UDim2.new(0, 8192, 0, 2000);
		ClipsDescendants = true;
		ZIndex = 100;
		Parent = ScreenGui;
	});

	EZ.NotificationOuter = NotificationOuter;

	EZ.NotificationArea = EZ:Create('Frame', {
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 1);
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 100;
		Parent = NotificationOuter;
	});

	EZ.NotificationLayout = EZ:Create('UIListLayout', {
		Padding = UDim.new(0, 4);
		FillDirection = Enum.FillDirection.Vertical;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		VerticalAlignment = Enum.VerticalAlignment.Top;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = EZ.NotificationArea;
	});

	local WatermarkOuter = EZ:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 100, 0, -25);
		Size = UDim2.new(0, 213, 0, 20);
		ZIndex = 200;
		Visible = false;
		Parent = ScreenGui;
	});

	local WatermarkInner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = EZ.AccentColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 201;
		Parent = WatermarkOuter;
	});

	EZ:AddToRegistry(WatermarkInner, {
		BorderColor3 = 'AccentColor';
	});

	local InnerFrame = EZ:Create('Frame', {
		BackgroundColor3 = Color3.new(1, 1, 1);
		BorderSizePixel = 0;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 202;
		Parent = WatermarkInner;
	});

	local Gradient = EZ:Create('UIGradient', {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, EZ:GetDarkerColor(EZ.MainColor)),
			ColorSequenceKeypoint.new(1, EZ.MainColor),
		});
		Rotation = -90;
		Parent = InnerFrame;
	});

	EZ:AddToRegistry(Gradient, {
		Color = function()
			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, EZ:GetDarkerColor(EZ.MainColor)),
				ColorSequenceKeypoint.new(1, EZ.MainColor),
			});
		end
	});

	local WatermarkLabel = EZ:CreateLabel({
		Position = UDim2.new(0, 5, 0, 0);
		Size = UDim2.new(1, -4, 1, 0);
		TextSize = 14;
		TextXAlignment = Enum.TextXAlignment.Left;
		ZIndex = 203;
		Parent = InnerFrame;
	});

	EZ.Watermark = WatermarkOuter;
	EZ.WatermarkText = WatermarkLabel;
	EZ:MakeDraggable(EZ.Watermark);

	local KeybindOuter = EZ:Create('Frame', {
		AnchorPoint = Vector2.new(0, 0.5);
		BackgroundTransparency = 1;
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 10, 0.5, 0);
		Size = UDim2.new(0, 210, 0, 20);
		Visible = false;
		ZIndex = 100;
		Parent = ScreenGui;
	});

	local KeybindInner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = EZ.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 101;
		Parent = KeybindOuter;
	});

	EZ:AddToRegistry(KeybindInner, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	}, true);

	local ColorFrame = EZ:Create('Frame', {
		BackgroundColor3 = EZ.AccentColor;
		BorderSizePixel = 0;
		Size = UDim2.new(1, 0, 0, 2);
		ZIndex = 102;
		Parent = KeybindInner;
	});

	EZ:AddToRegistry(ColorFrame, {
		BackgroundColor3 = 'AccentColor';
	}, true);

	local KeybindLabel = EZ:CreateLabel({
		Size = UDim2.new(1, 0, 0, 20);
		Position = UDim2.fromOffset(5, 2),
		TextXAlignment = Enum.TextXAlignment.Left,

		Text = 'Keybinds';
		ZIndex = 104;
		Parent = KeybindInner;
	});

	local KeybindContainer = EZ:Create('Frame', {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 1, -20);
		Position = UDim2.new(0, 0, 0, 20);
		ZIndex = 1;
		Parent = KeybindInner;
	});

	EZ:Create('UIListLayout', {
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = KeybindContainer;
	});

	EZ:Create('UIPadding', {
		PaddingLeft = UDim.new(0, 5),
		Parent = KeybindContainer,
	})

	EZ.KeybindFrame = KeybindOuter;
	EZ.KeybindInner = KeybindInner;
	EZ.KeybindContainer = KeybindContainer;
	EZ:MakeDraggable(KeybindOuter);

	EZ:UpdateNotifications();
end;

function EZ:CreatePopout(Config)
	if type(Config.Title) ~= 'string' then
		Config.Title = 'No title';
	end;

	if typeof(Config.Position) ~= 'UDim2' then
		Config.Position = UDim2.fromOffset(175, 50);
	end;

	Config.Size = Config.Size or Vector2.new(200, 200);

	local PopoutGui = Instance.new('ScreenGui');
	ProtectGui(PopoutGui);
	PopoutGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	PopoutGui.Parent = CoreGui;
	PopoutGui.DisplayOrder = (Config.ZIndex or 0) + 998;

	if Config.Center then
		Config.AnchorPoint = Vector2.new(0.5, 0.5);
		Config.Position = UDim2.fromScale(0.5, 0.5);
	end;

	local Popout = {};

	local Outer = EZ:Create('Frame', {
		AnchorPoint = Config.AnchorPoint or Vector2.zero;
		BackgroundColor3 = Color3.new(0, 0, 0);
		BorderSizePixel = 0;
		Position = Config.Position;
		Size = UDim2.fromOffset(Config.Size.X, Config.Size.Y);
		Visible = Config.AutoShow or false;
		ZIndex = 1;
		Parent = PopoutGui;
	});

	if not Config.RemoveTopbar then
		EZ:MakeDraggableOutline(Outer, 25);
	end;

	local Inner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = EZ.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 1;
		Parent = Outer;
	});

	EZ:AddToRegistry(Inner, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	});

	if not Config.RemoveTopbar then
		EZ:CreateLabel({
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 0, 25);
			Text = Config.Title or '';
			TextXAlignment = Enum.TextXAlignment.Center;
			ZIndex = 1;
			Font = EZ.Font;
			Parent = Inner;
		});

		local VersionLabel = EZ:Create('TextLabel', {
			BackgroundTransparency = 1;
			Font = EZ.Font;
			TextColor3 = EZ.AccentColor;
			TextSize = 16;
			TextStrokeTransparency = 0;
			Position = UDim2.new(0, -8, 0, 0);
			Size = UDim2.new(1, 0, 0, 25);
			Text = Config.Game or '';
			RichText = true;
			TextXAlignment = Enum.TextXAlignment.Right;
			ZIndex = 1;
			Parent = Inner;
		});

		EZ:AddToRegistry(VersionLabel, { TextColor3 = 'AccentColor' });
	end;

	local TopOffset = Config.RemoveTopbar and 8 or 25;
	local HeightDelta = Config.RemoveTopbar and -16 or -33;

	local BodyOuter = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = EZ.OutlineColor;
		Position = UDim2.new(0, 8, 0, TopOffset);
		Size = UDim2.new(1, -16, 1, HeightDelta);
		ZIndex = 1;
		Parent = Inner;
	});

	EZ:AddToRegistry(BodyOuter, {
		BackgroundColor3 = 'BackgroundColor';
		BorderColor3 = 'OutlineColor';
	});

	local BodyInner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = Color3.new(0, 0, 0);
		BorderMode = Enum.BorderMode.Inset;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 1;
		Parent = BodyOuter;
	});

	EZ:AddToRegistry(BodyInner, { BackgroundColor3 = 'BackgroundColor' });

	local ContainerOuter = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = EZ.OutlineColor;
		Position = UDim2.new(0, 8, 0, 8);
		Size = UDim2.new(1, -16, 1, -16);
		ZIndex = 2;
		Visible = true;
		Parent = BodyInner;
	});

	local Container = EZ:Create('Frame', {
		BackgroundTransparency = 1;
		Parent = ContainerOuter;
		Size = UDim2.fromScale(1, 1);
		Position = UDim2.fromOffset(2, 2);
	});

	EZ:Create('UIListLayout', {
		Padding = UDim.new(0, 0);
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		HorizontalAlignment = Enum.HorizontalAlignment.Left;
		Parent = Container;
	});

	EZ:AddToRegistry(ContainerOuter, {
		BackgroundColor3 = 'BackgroundColor';
		BorderColor3 = 'OutlineColor';
	});

	Popout.Holder = Outer;
	Popout.Container = Container;
	Popout.ScreenGui = PopoutGui;

	function Popout:Resize()
		local Height = 0;

		for _, Element in next, Container:GetChildren() do
			if (not Element:IsA('UIListLayout')) and Element.Visible then
				Height = Height + Element.AbsoluteSize.Y;
			end;
		end;

		Outer.Size = UDim2.fromOffset(
			Config.Size.X,
			16 + Height + (Container.AbsolutePosition.Y - Outer.AbsolutePosition.Y)
		);
	end;

	function Popout:Toggle()
		Outer.Visible = not Outer.Visible;
	end;

	function Popout:SetVisible(Bool)
		Outer.Visible = Bool;
	end;

	function Popout:GetSize()
		return Container.AbsoluteSize;
	end;

	function Popout:Remove()
		PopoutGui:Destroy();
		table.clear(Popout);
	end;

	Container:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
		task.wait();
		Popout:Resize();
	end);

	Popout:Resize();

	setmetatable(Popout, BaseGroupbox);

	return Popout;
end

function EZ:CreateTargetHUD(Config)
	Config = Config or {};

	local Parent = Config.Parent;
	local Font = Config.Font;
	local UpColor = Config.UpColor or EZ.AccentColor;
	local DownColor = Config.DownColor or EZ.RiskColor;
	local Width = Config.Width or 528;
	local Height = Config.Height or 214;
	local Slot = 58;
	local Pad = 9;
	local Edge = 17;
	local RowGap = 12;
	local TextX = 92;
	local ValueW = 150;
	local Placeholders = Config.PlaceholderIcons or {
		'rbxassetid://17225649668';
		'rbxassetid://17225650488';
		'rbxassetid://17225650859';
		'rbxassetid://17225651405';
	};

	local HUD = {};

	local ScreenGui = Instance.new('ScreenGui');
	ScreenGui.Name = 'EZTargetHUD';
	ScreenGui.DisplayOrder = 999;
	ScreenGui.ResetOnSpawn = false;
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	ScreenGui.Parent = Parent;

	local function stroke(Target, Key, Thickness)
		local Line = Instance.new('UIStroke');
		Line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		Line.Color = EZ[Key or 'OutlineColor'];
		Line.Thickness = Thickness or 1;
		Line.Transparency = 0;
		Line.Parent = Target;
		EZ:AddToRegistry(Line, { Color = Key or 'OutlineColor'; });
		return Line;
	end

	local Root = EZ:Create('Frame', {
		Name = 'TargetHUD';
		Size = UDim2.fromOffset(Width, Height);
		Position = UDim2.new(0.5, 0, 0.5, 0);
		AnchorPoint = Vector2.new(0.5, 0);
		BackgroundColor3 = EZ.OutlineColor;
		BorderColor3 = Color3.new(0, 0, 0);
		BorderSizePixel = 1;
		BorderMode = Enum.BorderMode.Inset;
		ClipsDescendants = false;
		Visible = false;
		ZIndex = 120;
		Parent = ScreenGui;
	});

	local Panel = EZ:Create('Frame', {
		Size = UDim2.new(1, -2, 1, -2);
		Position = UDim2.new(0, 1, 0, 1);
		BackgroundColor3 = EZ.MainColor;
		BorderSizePixel = 0;
		ClipsDescendants = false;
		ZIndex = 121;
		Parent = Root;
	});

	EZ:AddToRegistry(Root, {
		BackgroundColor3 = 'OutlineColor';
	});

	EZ:AddToRegistry(Panel, {
		BackgroundColor3 = 'MainColor';
	});

	local Scale = Instance.new('UIScale');
	Scale.Scale = Config.Scale or 1;
	Scale.Parent = Root;

	local Body = Panel;

	for Index = 1, 2 do
		local Layer = EZ:Create('Frame', {
			BackgroundColor3 = EZ.OutlineColor;
			BorderColor3 = EZ.OutlineColor;
			BorderSizePixel = 1;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, -Pad * 2, 1, -Pad * 2);
			Position = UDim2.fromOffset(Pad, Pad);
			ClipsDescendants = false;
			ZIndex = 122 + Index;
			Parent = Body;
		});

		local Inner = EZ:Create('Frame', {
			Size = UDim2.new(1, -2, 1, -2);
			Position = UDim2.new(0, 1, 0, 1);
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = Color3.new(0, 0, 0);
			BorderSizePixel = 1;
			BorderMode = Enum.BorderMode.Inset;
			ClipsDescendants = false;
			ZIndex = 123 + Index;
			Parent = Layer;
		});

		EZ:AddToRegistry(Layer, {
			BackgroundColor3 = 'OutlineColor';
		});

		EZ:AddToRegistry(Inner, {
			BackgroundColor3 = 'MainColor';
		});

		Body = Inner;
	end

	local Top = math.max(0, math.floor((Body.AbsoluteSize.Y / Scale.Scale - Slot * 2 - RowGap) / 2));

	local ZSlot = 124;
	local ZText = 125;
	local Slots = {};
	local Icons = {};

	for Index = 1, 4 do
		local Column = Index % 2 == 0 and 1 or 0;
		local Row = Index < 3 and 0 or 1;

		local Holder = EZ:Create('Frame', {
			Size = UDim2.fromOffset(Slot, Slot);
			Position = UDim2.new(Column, Column == 1 and -(Edge + Slot) or Edge, 0, Top + Row * (Slot + RowGap));
			BackgroundColor3 = EZ.BackgroundColor;
			BorderSizePixel = 0;
			ClipsDescendants = true;
			ZIndex = ZSlot;
			Parent = Body;
		});

		stroke(Holder, 'OutlineColor');

		EZ:AddToRegistry(Holder, {
			BackgroundColor3 = 'BackgroundColor';
		});

		local Icon = EZ:Create('ImageLabel', {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.fromScale(0.5, 0.5);
			Size = UDim2.fromScale(1, 1);
			BackgroundTransparency = 1;
			ScaleType = Enum.ScaleType.Fit;
			Image = '';
			ZIndex = ZText;
			Parent = Holder;
		});

		Slots[Index] = Holder;
		Icons[Index] = Icon;
	end;

	local function dim()
		return EZ.FontColor:Lerp(EZ.BackgroundColor, 0.32);
	end

	local function label(Size, Position, TextSize, Text, Alignment, Color)
		return EZ:Create('TextLabel', {
			Size = Size;
			Position = Position;
			BackgroundTransparency = 1;
			Text = Text or '';
			TextSize = TextSize;
			FontFace = Font;
			TextColor3 = Color or EZ.FontColor;
			TextXAlignment = Alignment or Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Center;
			TextTruncate = Enum.TextTruncate.AtEnd;
			ZIndex = ZText;
			Parent = Body;
		});
	end

	local Name = label(UDim2.new(1, -TextX - TextX, 0, 22), UDim2.fromOffset(TextX, Edge + 5), 14);
	local Stats = label(UDim2.new(1, -TextX - TextX, 0, 18), UDim2.fromOffset(TextX, Edge + 25), 11, '', nil, dim());
	local HealthLabel = label(UDim2.fromOffset(ValueW, 16), UDim2.fromOffset(TextX, 88), 11, 'health', nil, dim());
	local HealthValue = label(UDim2.fromOffset(ValueW, 16), UDim2.new(1, -(TextX + ValueW), 0, 88), 11, '0 / 0', Enum.TextXAlignment.Right);
	local RatioLabel = label(UDim2.fromOffset(ValueW, 16), UDim2.fromOffset(TextX, 120), 11, 'damage ratio', nil, dim());
	local RatioValue = label(UDim2.fromOffset(ValueW, 16), UDim2.new(1, -(TextX + ValueW), 0, 120), 11, '', Enum.TextXAlignment.Right);

	Stats.RichText = true;
	RatioValue.RichText = true;

	for _, Item in next, { Stats, HealthLabel, RatioLabel } do
		EZ:AddToRegistry(Item, {
			TextColor3 = dim;
		});
	end;

	for _, Item in next, { Name, HealthValue, RatioValue } do
		EZ:AddToRegistry(Item, {
			TextColor3 = 'FontColor';
		});
	end;

	local function bar(Y)
		local Track = EZ:Create('Frame', {
			Size = UDim2.new(1, -TextX - TextX, 0, 2);
			Position = UDim2.fromOffset(TextX, Y);
			BackgroundColor3 = EZ.OutlineColor;
			BorderSizePixel = 0;
			ClipsDescendants = true;
			ZIndex = ZSlot;
			Parent = Body;
		});

		EZ:AddToRegistry(Track, {
			BackgroundColor3 = 'OutlineColor';
		});

		local Fill = EZ:Create('Frame', {
			Size = UDim2.fromScale(0, 1);
			BackgroundColor3 = EZ.AccentColor;
			BorderSizePixel = 0;
			ZIndex = ZText;
			Parent = Track;
		});

		EZ:AddToRegistry(Fill, {
			BackgroundColor3 = 'AccentColor';
		});

		return Track, Fill;
	end

	local HealthTrack, HealthFill = bar(108);
	local RatioTrack, RatioFill = bar(140);

	local Seam = EZ:Create('Frame', {
		AnchorPoint = Vector2.new(0, 0);
		Size = UDim2.fromOffset(2, 2);
		BackgroundColor3 = EZ.BackgroundColor;
		BorderSizePixel = 0;
		ZIndex = ZText;
		Parent = RatioTrack;
	});

	EZ:AddToRegistry(Seam, {
		BackgroundColor3 = 'BackgroundColor';
	});

	HUD.ScreenGui = ScreenGui;
	HUD.Root = Root;
	HUD.Body = Body;
	HUD.Scale = Scale;
	HUD.Slots = Slots;
	HUD.Icons = Icons;
	HUD.Placeholders = Placeholders;
	HUD.Name = Name;
	HUD.Stats = Stats;
	HUD.HealthLabel = HealthLabel;
	HUD.HealthValue = HealthValue;
	HUD.RatioLabel = RatioLabel;
	HUD.RatioValue = RatioValue;
	HUD.HealthTrack = HealthTrack;
	HUD.HealthFill = HealthFill;
	HUD.RatioTrack = RatioTrack;
	HUD.RatioFill = RatioFill;
	HUD.RatioSeam = Seam;
	HUD.UpColor = UpColor;
	HUD.DownColor = DownColor;

	local Labels = { Name, Stats, HealthLabel, HealthValue, RatioLabel, RatioValue };

function HUD:Apply(Data)
		local rank = Data.Rank or 'unranked';
		if type(rank) ~= 'string' then
			rank = rank.Name or rank.name or 'unranked';
		end;

		local accent = EZ.AccentColor:ToHex();

		local text = Data.Name or '';
		if Name.Text ~= text then
			Name.Text = text;
		end;

		text = ('level <font color="#%s">%s</font>   rank <font color="#%s">%s</font>   device <font color="#%s">%s</font>   streak <font color="#%s">%s</font>'):format(
			accent, tostring(Data.Level or 0),
			accent, rank:lower(),
			accent, tostring(Data.Device or '?'),
			accent, tostring(Data.Streak or 0)
		);

		if Stats.Text ~= text then
			Stats.Text = text;
		end;

		local Health = Data.Health or 0;
		local MaxHealth = Data.MaxHealth or 100;
		text = math.floor(Health) .. ' / ' .. math.floor(MaxHealth);

		if HealthValue.Text ~= text then
			HealthValue.Text = text;
		end;

		local Scale = UDim2.fromScale(math.clamp(Health / MaxHealth, 0, 1), 1);
		if HealthFill.Size ~= Scale then
			HealthFill.Size = Scale;
		end;

		local Given = Data.DamageGiven or 0;
		local Taken = Data.DamageTaken or 0;
		text = ('%d <font color="#%s">▲</font>  %d <font color="#%s">▼</font>'):format(
			math.floor(Given + 0.5), UpColor:ToHex(),
			math.floor(Taken + 0.5), DownColor:ToHex()
		);

		if RatioValue.Text ~= text then
			RatioValue.Text = text;
		end;

		local Total = Given + Taken;
		local Ratio = Total > 0 and Given / Total or 0.5;
		Ratio = math.clamp(Ratio, 0, 1);
		Scale = UDim2.fromScale(Ratio, 1);

		if RatioFill.Size ~= Scale then
			RatioFill.Size = Scale;
			Seam.Position = UDim2.fromScale(Ratio, 0);
		end;
local Items = Data.Items;
		local Muted = Data.Placeholder or not Items;
		local Tint = Muted and EZ.OutlineColor or Color3.new(1, 1, 1);
		local Size = Muted and UDim2.fromScale(0.85, 0.85) or UDim2.fromScale(1, 1);

		for Index = 1, 4 do
			local Image = Items and Items[Index] or '';
			local Icon = Icons[Index];

			if Icon.Image ~= Image or Icon.ImageColor3 ~= Tint then
				Icon.Image = Image;
				Icon.ImageColor3 = Tint;
				Icon.Size = Size;
			end;
		end;
	end;

	function HUD:SetVisible(Bool)
		Root.Visible = Bool;
	end;

	function HUD:SetScale(Amount)
		Scale.Scale = Amount;
	end;

	function HUD:SetOffset(X, Y)
		Root.Position = UDim2.new(0.5, X, 0.5, Y);
	end;

	function HUD:SetFont(NewFont)
		if not NewFont then return end;
		Font = NewFont;
		for _, Item in next, Labels do
			Item.FontFace = Font;
		end;
	end;

	function HUD:Remove()
		ScreenGui:Destroy();
		table.clear(HUD);
	end;

	return HUD;
end

function EZ:SetWatermarkVisibility(Bool)
	EZ.Watermark.Visible = Bool;
end;

function EZ:SetWatermark(Text)
	local X, Y = EZ:GetTextBounds(Text, EZ.Font, 14);
	EZ.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
	EZ:SetWatermarkVisibility(true)

	EZ.WatermarkText.Text = Text;
end;

local NotificationBarPosition = {
	Top    = UDim2.new(0, -1, 0, 0);
	Left   = UDim2.new(0, -1, 0, -1);
	Right  = UDim2.new(1, -2, 0, -1);
	Bottom = UDim2.new(0, -1, 1, -2);
};

local NotificationBarSize = {
	Top    = UDim2.new(1, 3, 0, 2);
	Left   = UDim2.new(0, 3, 1, 2);
	Right  = UDim2.new(0, 3, 1, 2);
	Bottom = UDim2.new(1, 3, 0, 2);
};

local function GetNotificationColors()
	local Override = EZ.NotificationStyle.OverrideColor;

	if Override then
		return Override();
	end;

	return EZ.MainColor, EZ.AccentColor, EZ.OutlineColor, EZ.FontColor;
end

local NotificationTemplate = (function()
	local Outer = EZ:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 100, 0, 10);
		ClipsDescendants = true;
		ZIndex = 100;
	});

	local Inner = EZ:Create('Frame', {
		Name = 'inner';
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 101;
		Parent = Outer;
	});

	local Body = EZ:Create('Frame', {
		Name = 'inner';
		BackgroundColor3 = Color3.new(1, 1, 1);
		BorderSizePixel = 0;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 102;
		Parent = Inner;
	});

	EZ:Create('UIGradient', {
		Rotation = -90;
		Parent = Body;
	});

	EZ:CreateLabel({
		Name = 'label';
		Position = UDim2.new(0, 4, 0, 0);
		Size = UDim2.new(1, -4, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Left;
		TextSize = 14;
		ZIndex = 103;
		Parent = Body;
	});

	EZ:Create('Frame', {
		Name = 'bar';
		BorderSizePixel = 0;
		ZIndex = 104;
		Parent = Outer;
	});

	return Outer;
end)();

function EZ:Notify(Text, Time)
	if getgenv().EZ_silent_mode then return end;

	local XSize, YSize = EZ:GetTextBounds(Text, EZ.Font, 14);

	YSize = YSize + 7

	local Style = EZ.NotificationStyle;
	local Transparency = Style.Transparency or 0;
	local MainColor, AccentColor, OutlineColor, FontColor = GetNotificationColors();

	local Width = XSize + 8 + 4;

	local NotifyOuter = NotificationTemplate:Clone();

	NotifyOuter.BackgroundColor3 = MainColor;
	NotifyOuter.BackgroundTransparency = Transparency;
	NotifyOuter.Size = UDim2.new(0, 0, 0, YSize);

	EZ.NotifyCounter = (EZ.NotifyCounter or 0) + 1;

	if Style.SortOrder == 'Text Length' then
		NotifyOuter.LayoutOrder = #Text;
	else
		NotifyOuter.LayoutOrder = -EZ.NotifyCounter;
	end;

	local NotifyInner = NotifyOuter.inner;
	NotifyInner.BackgroundColor3 = MainColor;
	NotifyInner.BorderColor3 = OutlineColor;
	NotifyInner.BackgroundTransparency = Transparency;

	local Body = NotifyInner.inner;
	Body.BackgroundTransparency = Transparency;

	Body.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, EZ:GetDarkerColor(MainColor));
		ColorSequenceKeypoint.new(1, MainColor);
	});

	local Label = Body.label;
	Label.Text = Text;
	Label.TextColor3 = FontColor;

	local BarSide = Style.BarSide or 'Bottom';

	local Bar = NotifyOuter.bar;
	Bar.BackgroundColor3 = AccentColor;
	Bar.Size = NotificationBarSize[BarSide] or NotificationBarSize.Bottom;
	Bar.Position = NotificationBarPosition[BarSide] or NotificationBarPosition.Bottom;

	NotifyOuter.Parent = EZ.NotificationArea;

	pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, Width, 0, YSize), 'Out', 'Quad', 0.4, true);

	task.spawn(function()
		wait(Time or 5);

		pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

		wait(0.4);

		NotifyOuter:Destroy();
	end);
end;

function EZ:CreateWindow(...)
	local Arguments = { ... }
	local Config = { AnchorPoint = Vector2.zero }

	if type(...) == 'table' then
		Config = ...;
	else
		Config.Title = Arguments[1]
		Config.AutoShow = Arguments[2] or false;
	end

	if getgenv().EZ_silent_mode then Config.AutoShow = false end

	if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
	if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 8 end
	if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end
	EZ.MenuFadeTime = Config.MenuFadeTime;

	EZ.Game = Config.Game or 'Global';
	EZ:EnsureFolders();

	if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
	if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 650) end

	if EZ.IsMobile then
		local Area = EZ.ScreenGui.AbsoluteSize;
		local w = math.max(EZ.MinSize.X, math.min(Config.Size.X.Offset, math.floor(Area.X - 40)));
		local h = math.max(EZ.MinSize.Y, math.floor(Area.Y - 40));
		Config.Size = UDim2.fromOffset(w, h);
		Config.Position = UDim2.fromOffset(math.floor((Area.X - w) / 2), 20);
		Config.Center = false;
	end

	if Config.Center then

		Config.AnchorPoint = Vector2.zero
		Config.Position = UDim2.new(0.5, -Config.Size.X.Offset / 2, 0.5, -Config.Size.Y.Offset / 2)
	end

	local Window = {
		Tabs = {};
	};

	local Outer = EZ:Create('Frame', {
		AnchorPoint = Config.AnchorPoint,
		BackgroundColor3 = Color3.new(0, 0, 0);
		BorderSizePixel = 0;
		Position = Config.Position,
		Size = Config.Size,
		Visible = false;
		ZIndex = 1;
		Parent = ScreenGui;
	});

	EZ.MainFrame = Outer;

	if Config.NoOutlineDrag then
		EZ:MakeDraggable(Outer, 25, true);
	else
		EZ:MakeDraggableOutline(Outer, 25, true);
	end;

	if Config.Resizable ~= false then
		EZ:MakeResizable(Outer, Config.MinSize);
	end;

	local Inner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = EZ.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Position = UDim2.new(0, 1, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 1;
		Parent = Outer;
	});

	EZ:AddToRegistry(Inner, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	});

	local WindowLabel = EZ:CreateLabel({
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(1, 0, 0, 25);
		Text = Config.Title or '';
		TextSize = 18;
		TextXAlignment = Enum.TextXAlignment.Center;
		ZIndex = 1;
		Parent = Inner;
	});

	local VersionLabel = EZ:Create('TextLabel', {
		BackgroundTransparency = 1;
		Font = EZ.Font;
		TextColor3 = EZ.AccentColor;
		TextSize = 16;
		TextStrokeTransparency = 0;
		Position = UDim2.new(0, -8, 0, 0);
		Size = UDim2.new(1, 0, 0, 25);
		Text = Config.Game or '';
		RichText = true;
		TextXAlignment = Enum.TextXAlignment.Right;
		ZIndex = 1;
		Parent = Inner;
	});

	EZ:AddToRegistry(VersionLabel, {
		TextColor3 = 'AccentColor';
	});

	local MainSectionOuter = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = EZ.OutlineColor;
		Position = UDim2.new(0, 8, 0, 25);
		Size = UDim2.new(1, -16, 1, -33);
		ZIndex = 1;
		Parent = Inner;
	});

	EZ:AddToRegistry(MainSectionOuter, {
		BackgroundColor3 = 'BackgroundColor';
		BorderColor3 = 'OutlineColor';
	});

	local MainSectionInner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.BackgroundColor;
		BorderColor3 = Color3.new(0, 0, 0);
		BorderMode = Enum.BorderMode.Inset;
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 1;
		Parent = MainSectionOuter;
	});

	EZ:AddToRegistry(MainSectionInner, {
		BackgroundColor3 = 'BackgroundColor';
	});

	local TabArea = EZ:Create('ScrollingFrame', {
		BackgroundTransparency = 1;
		BorderColor3 = EZ.OutlineColor;
		BorderSizePixel = 1;
		Position = UDim2.new(0, 0, 0, 4);
		Size = UDim2.new(1, -10, 0, 29);
		CanvasSize = UDim2.new();
		AutomaticCanvasSize = Enum.AutomaticSize.XY;
		ScrollBarThickness = 0;
		ScrollingDirection = Enum.ScrollingDirection.X;
		ZIndex = 1;
		Parent = MainSectionInner;
	});

	EZ:AddToRegistry(TabArea, {
		BorderColor3 = 'OutlineColor';
	});

	EZ:Create('UIPadding', {
		PaddingTop = UDim.new(0, 1);
		PaddingLeft = UDim.new(0, 8);
		PaddingRight = UDim.new(0, 8);
		Parent = TabArea;
	});

	local TabListLayout = EZ:Create('UIListLayout', {
		Padding = UDim.new(0, Config.TabPadding);
		FillDirection = Enum.FillDirection.Horizontal;
		VerticalAlignment = Enum.VerticalAlignment.Center;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = TabArea;
	});

	local TabContainer = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = EZ.OutlineColor;
		BorderSizePixel = 2;
		Position = UDim2.new(0, 8, 0, 38);
		Size = UDim2.new(1, -16, 1, -47);
		ZIndex = 1;
		Parent = MainSectionInner;
	});

	EZ:AddToRegistry(TabContainer, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	});

	local TabContainerInner = EZ:Create('Frame', {
		BackgroundColor3 = EZ.MainColor;
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 0, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 2;
		Parent = TabContainer;
	});

	EZ:AddToRegistry(TabContainerInner, {
		BackgroundColor3 = 'MainColor';
	});

	function Window:SetWindowTitle(Title)
		WindowLabel.Text = Title;
	end;

	function Window:AddTab(Name)

		if Window.Tabs[Name] then
			return Window.Tabs[Name];
		end;

		local Tab = {
			Groupboxes = {};
			Tabboxes = {};
		};

		local TabButtonWidth = EZ:GetTextBounds(Name, EZ.Font, 16);

		local TabButton = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderSizePixel = 2;
			Size = UDim2.new(0, TabButtonWidth + 8 + 4, 0.75, 0);
			ZIndex = 1;
			Parent = TabArea;
		});

		EZ:AddToRegistry(TabButton, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local TabButtonBorder = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			BorderColor3 = EZ.OutlineColor;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 2;
			Parent = TabButton;
		});

		EZ:Create('UIStroke', {
			Color = Color3.new(0, 0, 0);
			Parent = TabButtonBorder;
		});

		EZ:AddToRegistry(TabButtonBorder, {
			BorderColor3 = 'OutlineColor';
		});

		local TabAccent = EZ:Create('Frame', {
			BackgroundColor3 = EZ.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 0, 1);
			Visible = false;
			ZIndex = 104;
			Parent = TabButton;
		});

		EZ:AddToRegistry(TabAccent, {
			BackgroundColor3 = 'AccentColor';
		});

		local TabButtonLabel = EZ:CreateLabel({
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 1, -1);
			Text = Name;
			TextXAlignment = Enum.TextXAlignment.Center;
			ZIndex = 1;
			Parent = TabButton;
		});

		local TabFrame = EZ:Create('Frame', {
			Name = 'TabFrame',
			BackgroundTransparency = 1;
			BorderColor3 = EZ.OutlineColor;
			BorderSizePixel = 1;
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			ZIndex = 2;
			Parent = TabContainerInner;
		});

		EZ:AddToRegistry(TabFrame, {
			BorderColor3 = 'OutlineColor';
		});

		local WarningBox = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Position = UDim2.new(0, 7, 0, 7);
			Size = UDim2.new(1, -10, 0, 10);
			Visible = false;
			ZIndex = 3;
			Parent = TabFrame;
		});

		EZ:AddToRegistry(WarningBox, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local WarningBoxContainer = EZ:Create('Frame', {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 2, 0, 2);
			Size = UDim2.new(1, -4, 1, -4);
			ZIndex = 3;
			Parent = WarningBox;
		});

		EZ:Create('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = WarningBoxContainer;
		});

		local WarningBoxTitle = EZ:CreateLabel({
			Size = UDim2.new(1, -4, 0, 18);
			TextSize = 14;
			Text = '';
			TextXAlignment = Enum.TextXAlignment.Center;
			ZIndex = 4;
			Parent = WarningBoxContainer;
		});

		local WarningBoxText = EZ:CreateLabel({
			Size = UDim2.new(1, -4, 0, 15);
			TextSize = 14;
			Text = '';
			TextWrapped = true;
			RichText = true;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 4;
			Parent = WarningBoxContainer;
		});

		local LeftSide = EZ:Create('ScrollingFrame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
			Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
			CanvasSize = UDim2.new(0, 0, 0, 0);
			BottomImage = '';
			TopImage = '';
			ScrollBarThickness = 0;
			ZIndex = 2;
			Parent = TabFrame;
		});

		local RightSide = EZ:Create('ScrollingFrame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
			Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
			CanvasSize = UDim2.new(0, 0, 0, 0);
			BottomImage = '';
			TopImage = '';
			ScrollBarThickness = 0;
			ZIndex = 2;
			Parent = TabFrame;
		});

		EZ:Create('UIListLayout', {
			Padding = UDim.new(0, 8);
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Parent = LeftSide;
		});

		EZ:Create('UIListLayout', {
			Padding = UDim.new(0, 8);
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Parent = RightSide;
		});

		for _, Side in next, { LeftSide, RightSide } do
			Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
			end);
		end;

		if EZ.IsMobile then

			local LastScroll = { Left = tick(), Right = tick() };

			local function GuardScroll(Key)
				return function()
					EZ.CanDrag = false;

					local Stamp = tick();
					LastScroll[Key] = Stamp;

					task.wait(0.15);

					if LastScroll[Key] == Stamp then
						EZ.CanDrag = true;
					end;
				end;
			end;

			LeftSide:GetPropertyChangedSignal('CanvasPosition'):Connect(GuardScroll('Left'));
			RightSide:GetPropertyChangedSignal('CanvasPosition'):Connect(GuardScroll('Right'));
		end;

		function Tab:Resize()
			if WarningBox.Visible == true then
				local Height = 10;

				for _, Element in next, WarningBoxContainer:GetChildren() do
					if (not Element:IsA('UIListLayout')) and Element.Visible then
						Height = Height + Element.Size.Y.Offset;
					end;
				end;

				WarningBox.Size = UDim2.new(1, -10, 0, Height);

				Height = Height + 10;

				LeftSide.Position = UDim2.new(0, 7, 0, 7 + Height);
				LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Height);
				RightSide.Position = UDim2.new(0.5, 5, 0, 7 + Height);
				RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Height);
			else
				LeftSide.Position = UDim2.new(0, 7, 0, 7);
				LeftSide.Size = UDim2.new(0.5, -10, 1, -14);
				RightSide.Position = UDim2.new(0.5, 5, 0, 7);
				RightSide.Size = UDim2.new(0.5, -10, 1, -14);
			end;
		end;

		function Tab:UpdateWarningBox(Info)
			if typeof(Info.Visible) == 'boolean' then
				WarningBox.Visible = Info.Visible;
				Tab:Resize();
			end;

			if typeof(Info.Title) == 'string' then
				WarningBoxTitle.Text = Info.Title;
			end;

			if typeof(Info.Text) == 'string' then
				WarningBoxText.Text = Info.Text;

				local Y = select(2, EZ:GetTextBounds(
					Info.Text, EZ.Font, 14,
					Vector2.new(WarningBoxContainer.AbsoluteSize.X, math.huge)
				));

				WarningBoxText.Size = UDim2.new(1, -4, 0, Y);
				Tab:Resize();
			end;
		end;

		function Tab:GetSides()
			return { Left = LeftSide; Right = RightSide; };
		end;

		WarningBox:GetPropertyChangedSignal('Visible'):Connect(function()
			Tab:Resize();
		end);

		Tab:Resize();

		function Tab:ShowTab()
			for _, Tab in next, Window.Tabs do
				Tab:HideTab();
			end;

			TabButton.BackgroundColor3 = EZ.MainColor;
			EZ.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
			TabButtonLabel.TextColor3 = EZ.FontColor;
			TabAccent.Visible = true;
			TabFrame.Visible = true;

			EZ.ActiveTab = Name;

			Tab:Resize();
		end;

		function Tab:HideTab()
			TabButton.BackgroundColor3 = EZ.BackgroundColor;
			EZ.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
			TabButtonLabel.TextColor3 = EZ:GetDarkerColor(EZ.FontColor);
			TabAccent.Visible = false;
			TabFrame.Visible = false;
		end;

		function Tab:SetLayoutOrder(Position)
			TabButton.LayoutOrder = Position;
			TabListLayout:ApplyLayout();
		end;

		function Tab:Remove()
			Window.Tabs[Name] = nil;
			EZ.TotalTabs = math.max(EZ.TotalTabs - 1, 0);

			table.clear(Tab);

			TabFrame:Destroy();
			TabButton:Destroy();
		end;

		function Tab:AddGroupbox(Info)
			local Groupbox = {};

			local BoxOuter = EZ:Create('Frame', {
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = EZ.OutlineColor;
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.new(1, 0, 0, 507 + 2);
				ZIndex = 2;
				Parent = Info.Side == 1 and LeftSide or RightSide;
			});

			EZ:AddToRegistry(BoxOuter, {
				BackgroundColor3 = 'BackgroundColor';
				BorderColor3 = 'OutlineColor';
			});

			local BoxInner = EZ:Create('Frame', {
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = Color3.new(0, 0, 0);

				Size = UDim2.new(1, -2, 1, -2);
				Position = UDim2.new(0, 1, 0, 1);
				ZIndex = 4;
				Parent = BoxOuter;
			});

			EZ:AddToRegistry(BoxInner, {
				BackgroundColor3 = 'BackgroundColor';
			});

			local Highlight = EZ:Create('Frame', {
				BackgroundColor3 = EZ.AccentColor;
				BorderSizePixel = 0;
				Size = UDim2.new(1, 0, 0, 2);
				ZIndex = 5;
				Parent = BoxInner;
			});

			EZ:AddToRegistry(Highlight, {
				BackgroundColor3 = 'AccentColor';
			});

			local GroupboxLabel = EZ:CreateLabel({
				Size = UDim2.new(1, 0, 0, 18);
				Position = UDim2.new(0, 4, 0, 2);
				TextSize = 14;
				Text = Info.Name;
				TextXAlignment = Enum.TextXAlignment.Center;
				ZIndex = 5;
				Parent = BoxInner;
			});

			local Container = EZ:Create('Frame', {
				BackgroundTransparency = 1;
				Position = UDim2.new(0, 4, 0, 20);
				Size = UDim2.new(1, -4, 1, -20);
				ZIndex = 1;
				Parent = BoxInner;
			});

			EZ:Create('UIListLayout', {
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = Container;
			});

			function Groupbox:Resize()
				local Size = 0;

				for _, Element in next, Groupbox.Container:GetChildren() do
					if (not Element:IsA('UIListLayout')) and Element.Visible then
						Size = Size + Element.Size.Y.Offset;
					end;
				end;

				BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
			end;

			local Groupboxes = Tab.Groupboxes;
			function Groupbox:Remove()
				table.clear(self);
				BoxOuter:Destroy();
				Groupboxes[Info.Name] = nil;
			end;

			Groupbox.Container = Container;
			setmetatable(Groupbox, BaseGroupbox);

			Groupbox:AddBlank(3);
			Groupbox:Resize();

			Groupboxes[Info.Name] = Groupbox;

			return Groupbox;
		end;

		function Tab:AddLeftGroupbox(Name)
			return self:AddGroupbox({ Side = 1; Name = Name; });
		end;

		function Tab:AddRightGroupbox(Name)
			return self:AddGroupbox({ Side = 2; Name = Name; });
		end;

		function Tab:AddTabbox(Info)
			local Tabbox = {
				Tabs = {};
			};

			local BoxOuter = EZ:Create('Frame', {
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = EZ.OutlineColor;
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.new(1, 0, 0, 0);
				ZIndex = 2;
				Parent = Info.Side == 1 and LeftSide or RightSide;
			});

			EZ:AddToRegistry(BoxOuter, {
				BackgroundColor3 = 'BackgroundColor';
				BorderColor3 = 'OutlineColor';
			});

			local BoxInner = EZ:Create('Frame', {
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = Color3.new(0, 0, 0);

				Size = UDim2.new(1, -2, 1, -2);
				Position = UDim2.new(0, 1, 0, 1);
				ZIndex = 4;
				Parent = BoxOuter;
			});

			EZ:AddToRegistry(BoxInner, {
				BackgroundColor3 = 'BackgroundColor';
			});

			local TabboxButtons = EZ:Create('Frame', {
				BackgroundTransparency = 1;
				BorderColor3 = EZ.OutlineColor;
				BorderSizePixel = 1;
				Position = UDim2.new(0, 0, 0, 0);
				Size = UDim2.new(1, 0, 0, 18);
				ZIndex = 5;
				Parent = BoxInner;
			});

			EZ:AddToRegistry(TabboxButtons, {
				BorderColor3 = 'OutlineColor';
			});

			EZ:Create('UIListLayout', {
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = TabboxButtons;
			});

			local Tabboxes = Tab.Tabboxes;
			function Tabbox:Remove()
				BoxOuter:Destroy();
				table.clear(Tabbox);
				Tabboxes[Info.Name or ''] = nil;
			end;

			function Tabbox:AddTab(Name)
				local Tab = {};

				local Button = EZ:Create('Frame', {
					BackgroundColor3 = EZ.MainColor;
					BorderColor3 = Color3.new(0, 0, 0);
					Size = UDim2.new(0.5, 0, 1, 0);
					ZIndex = 6;
					Parent = TabboxButtons;
				});

				EZ:AddToRegistry(Button, {
					BackgroundColor3 = 'MainColor';
				});

				local ButtonLabel = EZ:CreateLabel({
					Size = UDim2.new(1, 0, 1, 0);
					TextSize = 14;
					Text = Name;
					TextXAlignment = Enum.TextXAlignment.Center;
					ZIndex = 7;
					Parent = Button;
				});

				local TabAccent = EZ:Create('Frame', {
					BackgroundColor3 = EZ.AccentColor;
					BorderSizePixel = 0;
					Position = UDim2.new(0, 0, 0, 0);
					Size = UDim2.new(1, 0, 0, 1);
					Visible = false;
					ZIndex = 10;
					Parent = Button;
				});

				EZ:AddToRegistry(TabAccent, {
					BackgroundColor3 = 'AccentColor';
				});

				local Block = EZ:Create('Frame', {
					BackgroundColor3 = EZ.BackgroundColor;
					BorderSizePixel = 0;
					Position = UDim2.new(0, 0, 1, 0);
					Size = UDim2.new(1, 0, 0, 1);
					Visible = false;
					ZIndex = 9;
					Parent = Button;
				});

				EZ:AddToRegistry(Block, {
					BackgroundColor3 = 'BackgroundColor';
				});

				local Container = EZ:Create('Frame', {
					BackgroundTransparency = 1;
					BorderColor3 = EZ.OutlineColor;
					BorderSizePixel = 1;
					Position = UDim2.new(0, 4, 0, 20);
					Size = UDim2.new(1, -4, 1, -20);
					ZIndex = 1;
					Visible = false;
					Parent = BoxInner;
				});

				EZ:AddToRegistry(Container, {
					BorderColor3 = 'OutlineColor';
				});

				EZ:Create('UIListLayout', {
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Parent = Container;
				});

				function Tab:Show()
					for _, Tab in next, Tabbox.Tabs do
						Tab:Hide();
					end;

					Container.Visible = true;
					Block.Visible = true;
					TabAccent.Visible = true;

					Button.BackgroundColor3 = EZ.BackgroundColor;
					EZ.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

					Tab:Resize();
				end;

				function Tab:Hide()
					Container.Visible = false;
					Block.Visible = false;
					TabAccent.Visible = false;

					Button.BackgroundColor3 = EZ.MainColor;
					EZ.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
				end;

				function Tab:Resize()
					local TabCount = 0;

					for _, Tab in next, Tabbox.Tabs do
						TabCount = TabCount + 1;
					end;

					for _, Button in next, TabboxButtons:GetChildren() do
						if not Button:IsA('UIListLayout') then
							Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
						end;
					end;

					if (not Container.Visible) then
						return;
					end;

					local Size = 0;

					for _, Element in next, Tab.Container:GetChildren() do
						if (not Element:IsA('UIListLayout')) and Element.Visible then
							Size = Size + Element.Size.Y.Offset;
						end;
					end;

					BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
				end;

				Button.InputBegan:Connect(function(Input)
					if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame())
						or Input.UserInputType == Enum.UserInputType.Touch and EZ:IsTap(Input) then
						Tab:Show();
						Tab:Resize();
					end;
				end);

				Tab.Container = Container;
				Tabbox.Tabs[Name] = Tab;

				setmetatable(Tab, BaseGroupbox);

				Tab:AddBlank(3);
				Tab:Resize();

				if #TabboxButtons:GetChildren() == 2 then
					Tab:Show();
				end;

				return Tab;
			end;

			Tabboxes[Info.Name or ''] = Tabbox;

			return Tabbox;
		end;

		function Tab:AddLeftTabbox(Name)
			return self:AddTabbox({ Name = Name, Side = 1; });
		end;

		function Tab:AddRightTabbox(Name)
			return self:AddTabbox({ Name = Name, Side = 2; });
		end;

		function Tab:Remove()
			table.clear(Tab);
			TabFrame:Destroy();
			TabButton:Destroy();
			Window.Tabs[Name] = nil;
		end;

		TabButton.InputBegan:Connect(function(Input)
			if EZ.IsDragging then
				return;
			end;

			if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not EZ:MouseIsOverOpenedFrame())
				or Input.UserInputType == Enum.UserInputType.Touch and EZ:IsTap(Input) then

				Tab:ShowTab();
			end;
		end);

		EZ.TotalTabs = EZ.TotalTabs + 1;

		if #TabContainerInner:GetChildren() == 1 then
			Tab:ShowTab();
		else
			Tab:HideTab();
		end;

		Window.Tabs[Name] = Tab;
		return Tab;
	end;

	local ModalElement = EZ:Create('TextButton', {
		BackgroundTransparency = 1;
		Size = UDim2.new(0, 0, 0, 0);
		Visible = true;
		Text = '';
		Modal = false;
		Parent = EZ:Create("ScreenGui", {
			Parent = CoreGui;
		});
	});

	local TransparencyCache = {};
	EZ.TransparencyCache = TransparencyCache;
	local Toggled = false;
	local Fading = false;

	function EZ:Toggle()
		if Fading then
			return;
		end;

		local FadeTime = EZ.MenuFadeTime;
		Fading = true;
		Toggled = (not Toggled);

		EZ.Visible = Toggled;
		EZ:FireEvent('VisibilityChanged', Toggled);

		ModalElement.Modal = Toggled;

		EZ:UpdateBackground('snap');

		for _, Element in next, Options do
			task.spawn(function()
				if Element.Type == 'Dropdown' then
					Element:CloseDropdown();
				elseif Element.Type == 'KeyPicker' then
					Element:SetModePickerVisibility(false);
				elseif Element.Type == 'ColorPicker' then
					Element:Hide();
				end;
			end);
		end;

		if Toggled and EZ.BlockInput then
			ContextActionService:BindAction(
				'Freeze',
				function()
					return Enum.ContextActionResult.Sink;
				end,
				false,
				table.unpack(Enum.PlayerActions:GetEnumItems())
			);
		else
			ContextActionService:UnbindAction('Freeze');
		end;

		if Toggled then

			Outer.Visible = true;
			local guiservice = GetService("GuiService");
			if not EZ.IsMobile then task.spawn(function()

				local State = InputService.MouseIconEnabled;

				local Cursor = Instance.new("ImageLabel", CursorGui);
				Cursor.Image = "http://www.roblox.com/asset/?id=4292970642";
				Cursor.BackgroundTransparency = 1;
				Cursor.ZIndex = 100;

				local CursorOutline = Instance.new("ImageLabel", CursorGui);
				CursorOutline.Image = "http://www.roblox.com/asset/?id=4292970642";
				CursorOutline.ImageColor3 = Color3.new();
				CursorOutline.BackgroundTransparency = 1;
				CursorOutline.ZIndex = 99;

				Cursor.Size, CursorOutline.Size = UDim2.fromOffset(17, 17),  UDim2.fromOffset(19, 19);
				Cursor.Rotation, CursorOutline.Rotation = -45, -45;

				local Shown = nil;

				while Toggled and ScreenGui.Parent do
					local Want = EZ.ShowCustomCursor == true;

					if Want ~= Shown then
						Shown = Want;
						InputService.MouseIconEnabled = not Want and State or false;
						Cursor.Visible, CursorOutline.Visible = Want, Want;
					end;

					if Want then
						InputService.MouseIconEnabled = false;

						local mPos = InputService:GetMouseLocation();
						local udim = UDim2.fromOffset(mPos.X, mPos.Y - guiservice:GetGuiInset().Y - 1);

						Cursor.ImageColor3 = EZ.AccentColor;
						Cursor.Position, CursorOutline.Position = udim, udim - UDim2.fromOffset(1, 1);
					end;

					RenderStepped:Wait();
				end;

				InputService.MouseIconEnabled = State;

				Cursor:Destroy();
				CursorOutline:Destroy();
			end); end;
		end;

		for _, Desc in next, Outer:GetDescendants() do
			local Properties = {};

			if Desc:IsA('ImageLabel') then
				table.insert(Properties, 'ImageTransparency');
				table.insert(Properties, 'BackgroundTransparency');
			elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
				table.insert(Properties, 'TextTransparency');
			elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
				table.insert(Properties, 'BackgroundTransparency');
			elseif Desc:IsA('UIStroke') then
				table.insert(Properties, 'Transparency');
			end;

			local Cache = TransparencyCache[Desc];

			if (not Cache) then
				Cache = {};
				TransparencyCache[Desc] = Cache;
			end;

			for _, Prop in next, Properties do
				if not Cache[Prop] then
					Cache[Prop] = Desc[Prop];
				end;

				if Cache[Prop] == 1 then
					continue;
				end;

				Desc[Prop] = Toggled and Cache[Prop] or 1;
			end;
		end;

		Outer.Visible = Toggled;
		EZ:UpdateBackground('finalize');

		Fading = false;
	end

	function EZ:SetVisible(Bool)
		if Bool ~= Toggled then
			EZ:Toggle();
		end;
	end;

	EZ:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
		if type(EZ.ToggleKeybind) == 'table' and EZ.ToggleKeybind.Type == 'KeyPicker' then
			if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == EZ.ToggleKeybind.Value then
				task.spawn(EZ.Toggle)
			end
		elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.Insert and (not Processed)) then
			task.spawn(EZ.Toggle)
		end
	end))

	if EZ.IsMobile then
		local Gui = EZ:Create('ScreenGui', {
			DisplayOrder = 1000;
			ResetOnSpawn = false;
		});
		ProtectGui(Gui);
		Gui.Parent = CoreGui;

		local Button = EZ:Create('Frame', {
			Active = true;
			BackgroundColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(20, 120);
			Size = UDim2.fromOffset(50, 50);
			Parent = Gui;
		});

		EZ:Create('UICorner', { CornerRadius = UDim.new(0, 12); Parent = Button });

		local Logo = EZ:Create('ImageLabel', {
			BackgroundTransparency = 1;
			Position = UDim2.fromOffset(0, 6);
			Size = UDim2.new(1, 0, 1, -12);
			Parent = Button;
		});

		task.spawn(function()
			local Path = EZ.Folder .. '/assets/logo.png';

			if not isfile(Path) then
				local Ok, Data = pcall(game.HttpGet, game, 'https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/LargeTransparentLogo.png');
				if not Ok then return end;

				ensurefolder(EZ.Folder);
				ensurefolder(EZ.Folder .. '/assets');
				writefile(Path, Data);
			end;

			Logo.Image = getcustomasset(Path);
		end);

		local Drag, Start, Origin, Moved;

		Button.InputBegan:Connect(function(Input)
			if Input.UserInputType ~= Enum.UserInputType.Touch or Drag then return end;

			Drag, Start, Origin, Moved = Input, Input.Position, Button.Position, false;
		end);

		EZ:GiveSignal(InputService.InputChanged:Connect(function(Input)
			if Input ~= Drag then return end;

			local D = Input.Position - Start;
			if not Moved and D.Magnitude < 8 then return end;

			Moved = true;
			Button.Position = UDim2.new(Origin.X.Scale, Origin.X.Offset + D.X, Origin.Y.Scale, Origin.Y.Offset + D.Y);
		end));

		EZ:GiveSignal(InputService.InputEnded:Connect(function(Input)
			if Input ~= Drag then return end;

			Drag = nil;
			if not Moved then EZ:Toggle() end;
		end));
	end;

	if Config.AutoShow then task.spawn(EZ.Toggle) end

	Window.Holder = Outer;

	return Window;
end;

EZ.Version = "v3.10"

--[[ Custom Library ]]

do
	local CustomLibrary = {};

	local function Box(Parent, Properties)
		local Outer = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			ZIndex = 2;
			Parent = Parent;
		});
		EZ:Create(Outer, Properties);
		EZ:AddToRegistry(Outer, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

		local Inner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(1, 1);
			Size = UDim2.new(1, -2, 1, -2);
			ZIndex = 3;
			Parent = Outer;
		});
		EZ:AddToRegistry(Inner, { BackgroundColor3 = 'BackgroundColor' });

		return Outer, Inner;
	end;

	function CustomLibrary:CreateWindow(Config)
		Config.Size = Config.Size or UDim2.fromOffset(550, 500);
		Config.MinSize = Config.MinSize or Vector2.new(400, 300);

		if EZ.IsMobile then
			local Area = EZ.ScreenGui.AbsoluteSize;
			local W = math.max(Config.MinSize.X, math.min(Config.Size.X.Offset, Area.X - 40));
			local H = math.max(Config.MinSize.Y, math.min(Config.Size.Y.Offset, Area.Y - 40));
			Config.Size = UDim2.fromOffset(W, H);
			Config.Position = UDim2.fromOffset((Area.X - W) // 2, 20);
		end;

		local Window = { Tabs = {} };

		local Gui = EZ:Create('ScreenGui', {
			ZIndexBehavior = Enum.ZIndexBehavior.Global;
			DisplayOrder = 998;
			ResetOnSpawn = false;
			Enabled = false;
		});
		ProtectGui(Gui);
		Gui.Parent = CoreGui;

		local Outer = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderSizePixel = 0;
			Position = Config.Position or (EZ.MainFrame and UDim2.fromOffset(EZ.MainFrame.AbsolutePosition.X + EZ.MainFrame.AbsoluteSize.X + 10, EZ.MainFrame.AbsolutePosition.Y)) or UDim2.new(0.5, -Config.Size.X.Offset / 2, 0.5, -Config.Size.Y.Offset / 2);
			Size = Config.Size;
			Active = true;
			ZIndex = 1;
			Parent = Gui;
		});

		local Drag, Moved, Ended;

		local function StopDrag()
			if Drag then
				Drag = nil;
				Moved:Disconnect();
				Ended:Disconnect();
			end;
		end;

		Outer.InputBegan:Connect(function(Input)
			local Type = Input.UserInputType;
			if Drag or (Type ~= Enum.UserInputType.MouseButton1 and Type ~= Enum.UserInputType.Touch) then return end;
			if Input.Position.Y - Outer.AbsolutePosition.Y > 25 then return end;

			local Start, Origin, IsTouch = Input.Position, Outer.Position, Type == Enum.UserInputType.Touch;
			Drag = Input;

			Moved = InputService.InputChanged:Connect(function(Changed)
				if Changed == Drag or (not IsTouch and Changed.UserInputType == Enum.UserInputType.MouseMovement) then
					local D = Changed.Position - Start;
					Outer.Position = UDim2.new(Origin.X.Scale, Origin.X.Offset + D.X, Origin.Y.Scale, Origin.Y.Offset + D.Y);
				end;
			end);

			Ended = InputService.InputEnded:Connect(function(EndInput)
				if EndInput == Drag or (not IsTouch and EndInput.UserInputType == Enum.UserInputType.MouseButton1) then
					StopDrag();
				end;
			end);
		end);

		EZ:MakeResizable(Outer, Config.MinSize);

		local Inner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Position = UDim2.fromOffset(1, 0);
			Size = UDim2.fromScale(1, 1);
			ZIndex = 1;
			Parent = Outer;
		});
		EZ:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

		local TitleLabel = EZ:CreateLabel({
			Size = UDim2.new(1, 0, 0, 25);
			Text = Config.Title or '';
			TextSize = 18;
			ZIndex = 1;
			Parent = Inner;
		});

		if Config.Game then
			local GameLabel = EZ:Create('TextLabel', {
				BackgroundTransparency = 1;
				Font = EZ.Font;
				TextColor3 = EZ.AccentColor;
				TextSize = 16;
				Position = UDim2.fromOffset(-8, 0);
				Size = UDim2.new(1, 0, 0, 25);
				Text = Config.Game;
				TextXAlignment = Enum.TextXAlignment.Right;
				ZIndex = 1;
				Parent = Inner;
			});
			EZ:ApplyTextStroke(GameLabel);
			EZ:AddToRegistry(GameLabel, { TextColor3 = 'AccentColor' });
		end;

		local MainOuter = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			Position = UDim2.fromOffset(8, 25);
			Size = UDim2.new(1, -16, 1, -33);
			ZIndex = 1;
			Parent = Inner;
		});
		EZ:AddToRegistry(MainOuter, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

		local Main = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = Color3.new(0, 0, 0);
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.fromScale(1, 1);
			ZIndex = 1;
			Parent = MainOuter;
		});
		EZ:AddToRegistry(Main, { BackgroundColor3 = 'BackgroundColor' });

		local TabArea = EZ:Create('ScrollingFrame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.fromOffset(0, 4);
			Size = UDim2.new(1, -10, 0, 29);
			CanvasSize = UDim2.new();
			AutomaticCanvasSize = Enum.AutomaticSize.X;
			ScrollBarThickness = 0;
			ScrollingDirection = Enum.ScrollingDirection.X;
			ZIndex = 1;
			Parent = Main;
		});
		EZ:Create('UIPadding', { PaddingTop = UDim.new(0, 1); PaddingLeft = UDim.new(0, 8); PaddingRight = UDim.new(0, 8); Parent = TabArea });
		EZ:Create('UIListLayout', {
			Padding = UDim.new(0, 8);
			FillDirection = Enum.FillDirection.Horizontal;
			VerticalAlignment = Enum.VerticalAlignment.Center;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = TabArea;
		});

		local TabContainer = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = EZ.OutlineColor;
			BorderSizePixel = 2;
			Position = UDim2.fromOffset(8, 38);
			Size = UDim2.new(1, -16, 1, -47);
			ZIndex = 1;
			Parent = Main;
		});
		EZ:AddToRegistry(TabContainer, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

		local TabContainerInner = EZ:Create('Frame', {
			BackgroundColor3 = EZ.MainColor;
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.fromScale(1, 1);
			ZIndex = 2;
			Parent = TabContainer;
		});
		EZ:AddToRegistry(TabContainerInner, { BackgroundColor3 = 'MainColor' });

		function Window:SetTitle(Title)
			TitleLabel.Text = Title;
		end;

		function Window:SetVisible(Bool)
			Gui.Enabled = Bool;
			if not Bool then StopDrag() end;
		end;

		function Window:Toggle()
			Window:SetVisible(not Gui.Enabled);
		end;

		function Window:Remove()
			StopDrag();
			Gui:Destroy();
			table.clear(Window);
		end;

		function Window:AddTab(Name)
			if Window.Tabs[Name] then return Window.Tabs[Name] end;

			local Tab = {};

			local Button = EZ:Create('TextButton', {
				AutoButtonColor = false;
				Text = '';
				BackgroundColor3 = EZ.BackgroundColor;
				BorderColor3 = EZ.OutlineColor;
				BorderSizePixel = 2;
				Size = UDim2.new(0, EZ:GetTextBounds(Name, EZ.Font, 16) + 12, 0.75, 0);
				ZIndex = 1;
				Parent = TabArea;
			});
			EZ:AddToRegistry(Button, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

			local ButtonBorder = EZ:Create('Frame', {
				BackgroundTransparency = 1;
				BorderColor3 = EZ.OutlineColor;
				Size = UDim2.fromScale(1, 1);
				ZIndex = 2;
				Parent = Button;
			});
			EZ:Create('UIStroke', { Color = Color3.new(0, 0, 0); Parent = ButtonBorder });
			EZ:AddToRegistry(ButtonBorder, { BorderColor3 = 'OutlineColor' });

			local Accent = EZ:Create('Frame', {
				BackgroundColor3 = EZ.AccentColor;
				BorderSizePixel = 0;
				Size = UDim2.new(1, 0, 0, 1);
				Visible = false;
				ZIndex = 104;
				Parent = Button;
			});
			EZ:AddToRegistry(Accent, { BackgroundColor3 = 'AccentColor' });

			local Label = EZ:CreateLabel({
				Size = UDim2.new(1, 0, 1, -1);
				Text = Name;
				ZIndex = 1;
				Parent = Button;
			});

			Tab.Frame = EZ:Create('Frame', {
				BackgroundTransparency = 1;
				Size = UDim2.fromScale(1, 1);
				Visible = false;
				ZIndex = 2;
				Parent = TabContainerInner;
			});

			function Tab:ShowTab()
				for _, Other in next, Window.Tabs do
					Other:HideTab();
				end;

				Button.BackgroundColor3 = EZ.MainColor;
				EZ.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
				Label.TextColor3 = EZ.FontColor;
				Accent.Visible = true;
				Tab.Frame.Visible = true;
			end;

			function Tab:HideTab()
				Button.BackgroundColor3 = EZ.BackgroundColor;
				EZ.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
				Label.TextColor3 = EZ:GetDarkerColor(EZ.FontColor);
				Accent.Visible = false;
				Tab.Frame.Visible = false;
			end;

			function Tab:AddSection(Info)
				local Section = {};
				local Top = Info.Name and 20 or 2;

				local Outer, Inner = Box(Tab.Frame, { Position = Info.Position; Size = Info.Size });
				Section.Holder = Outer;

				local Highlight = EZ:Create('Frame', {
					BackgroundColor3 = EZ.AccentColor;
					BorderSizePixel = 0;
					Size = UDim2.new(1, 0, 0, 1);
					ZIndex = 5;
					Parent = Inner;
				});
				EZ:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor' });

				if Info.Name then
					EZ:CreateLabel({
						Position = UDim2.fromOffset(0, 2);
						Size = UDim2.new(1, 0, 0, 18);
						TextSize = 14;
						Text = Info.Name;
						ZIndex = 5;
						Parent = Inner;
					});
				end;

				Section.Container = EZ:Create('Frame', {
					BackgroundTransparency = 1;
					Position = UDim2.fromOffset(4, Top);
					Size = UDim2.new(1, -8, 1, -Top - 4);
					ZIndex = 4;
					Parent = Inner;
				});

				function Section:AddGroup(GroupInfo)
					local Frame = EZ:Create('Frame', {
						BackgroundTransparency = 1;
						Position = GroupInfo and GroupInfo.Position or UDim2.new();
						Size = GroupInfo and GroupInfo.Size or UDim2.fromScale(1, 0);
						ZIndex = 4;
						Parent = Section.Container;
					});

					local Container = EZ:Create('Frame', {
						BackgroundTransparency = 1;
						Size = UDim2.fromScale(1, 1);
						ZIndex = 4;
						Parent = Frame;
					});
					EZ:Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder; Parent = Container });

					local Group = { Container = Container; Holder = Frame };

					function Group:Resize()
						if GroupInfo and GroupInfo.Size then return end;

						local Height = 0;
						for _, Element in next, Container:GetChildren() do
							if not Element:IsA('UIListLayout') and Element.Visible then
								Height += Element.Size.Y.Offset;
							end;
						end;
						Frame.Size = UDim2.new(1, 0, 0, Height);
					end;

					return setmetatable(Group, BaseGroupbox);
				end;

				function Section:AddPair(PairInfo)
					local Position = PairInfo.Position or UDim2.new();
					local Height = PairInfo.Height or 41;

					local Left = Section:AddGroup({
						Position = Position;
						Size = UDim2.new(0.5, -2, 0, Height);
					});
					local Right = Section:AddGroup({
						Position = UDim2.new(Position.X.Scale + 0.5, Position.X.Offset + 2, Position.Y.Scale, Position.Y.Offset);
						Size = UDim2.new(0.5, -2, 0, Height);
					});

					return Left, Right;
				end;

				function Section:AddSearch(SearchInfo)
					local Search = { Value = '' };

					local Outer = EZ:Create('Frame', {
						BackgroundColor3 = Color3.new(0, 0, 0);
						BorderColor3 = Color3.new(0, 0, 0);
						Position = SearchInfo.Position or UDim2.new();
						Size = SearchInfo.Size or UDim2.new(1, 0, 0, 20);
						ZIndex = 5;
						Parent = Section.Container;
					});

					local Inner = EZ:Create('Frame', {
						BackgroundColor3 = EZ.MainColor;
						BorderColor3 = EZ.OutlineColor;
						BorderMode = Enum.BorderMode.Inset;
						Size = UDim2.fromScale(1, 1);
						ZIndex = 6;
						Parent = Outer;
					});
					EZ:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

					EZ:OnHighlight(Outer, Outer, { BorderColor3 = 'OutlineColor' }, { BorderColor3 = 'Black' });

					EZ:Create('UIGradient', {
						Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212));
						Rotation = 90;
						Parent = Inner;
					});

					local Icon = EZ:Create('ImageLabel', {
						BackgroundTransparency = 1;
						Image = 'rbxthumb://type=Asset&id=2804603877&w=150&h=150';
						ImageColor3 = EZ.FontColor;
						AnchorPoint = Vector2.new(0, 0.5);
						Position = UDim2.new(0, 5, 0.5, 0);
						Size = UDim2.fromOffset(10, 10);
						ZIndex = 7;
						Parent = Inner;
					});
					EZ:AddToRegistry(Icon, { ImageColor3 = 'FontColor' });

					local Box = EZ:Create('TextBox', {
						BackgroundTransparency = 1;
						ClipsDescendants = true;
						Position = UDim2.fromOffset(20, 0);
						Size = UDim2.new(1, -24, 1, 0);
						Font = EZ.Font;
						PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
						PlaceholderText = SearchInfo.Placeholder or '';
						ClearTextOnFocus = false;
						Text = '';
						TextColor3 = EZ.FontColor;
						TextSize = 14;
						TextXAlignment = Enum.TextXAlignment.Left;
						ZIndex = 7;
						Parent = Inner;
					});
					EZ:ApplyTextStroke(Box);
					EZ:AddToRegistry(Box, { TextColor3 = 'FontColor' });

					Search.Holder = Outer;
					Search.Box = Box;

					function Search:SetValue(Text)
						Box.Text = Text;
					end;

					Box:GetPropertyChangedSignal('Text'):Connect(function()
						Search.Value = Box.Text;
						if SearchInfo.Callback then EZ:SafeCallback(SearchInfo.Callback, Search.Value) end;
					end);

					return Search;
				end;

				function Section:AddButtons(ButtonsInfo)
					local Row = EZ:Create('Frame', {
						BackgroundTransparency = 1;
						Position = ButtonsInfo.Position or UDim2.new();
						Size = ButtonsInfo.Size or UDim2.new(1, 0, 0, 20);
						ZIndex = 5;
						Parent = Section.Container;
					});
					EZ:Create('UIListLayout', {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 4);
						SortOrder = Enum.SortOrder.LayoutOrder;
						Parent = Row;
					});

					local Count = #ButtonsInfo.Buttons;
					local Width = UDim2.new(1 / Count, -4 * (Count - 1) / Count, 1, 0);

					for Index, Info in next, ButtonsInfo.Buttons do
						local Outer = EZ:Create('Frame', {
							BackgroundColor3 = Color3.new(0, 0, 0);
							BorderColor3 = Color3.new(0, 0, 0);
							LayoutOrder = Index;
							Size = Width;
							ZIndex = 5;
							Parent = Row;
						});

						local Inner = EZ:Create('TextButton', {
							AutoButtonColor = false;
							Text = '';
							BackgroundColor3 = EZ.MainColor;
							BorderColor3 = EZ.OutlineColor;
							BorderMode = Enum.BorderMode.Inset;
							Size = UDim2.fromScale(1, 1);
							ZIndex = 6;
							Parent = Outer;
						});
						EZ:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

						EZ:Create('UIGradient', {
							Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(212, 212, 212));
							Rotation = 90;
							Parent = Inner;
						});

						EZ:CreateLabel({
							Size = UDim2.fromScale(1, 1);
							Text = Info.Text;
							TextSize = 14;
							ZIndex = 7;
							Parent = Inner;
						});

						EZ:AddToRegistry(Outer, { BorderColor3 = 'Black' });
						EZ:OnHighlight(Outer, Outer, { BorderColor3 = 'OutlineColor' }, { BorderColor3 = 'Black' });

						Inner.Activated:Connect(function()
							EZ:SafeCallback(Info.Callback);
						end);
					end;

					return Row;
				end;

				function Section:AddGrid(GridInfo)
					local Grid = { Items = {} };
					local CellSize = GridInfo.CellSize or UDim2.fromOffset(80, 80);
					local TextHeight = GridInfo.TextHeight or 14;
					local VisualPosition = UDim2.fromOffset(3, 3);
					local VisualSize = UDim2.new(1, -6, 1, -TextHeight - 6);
					local ImageScale = GridInfo.ImageScale or 1;
					local ImagePosition = UDim2.new(0.5, 0, 0.5, -TextHeight / 2);
					local ImageSize = UDim2.new(ImageScale, -6 * ImageScale, ImageScale, (-TextHeight - 6) * ImageScale);
					local LabelPosition = UDim2.new(0, 2, 1, -TextHeight - 1);
					local LabelSize = UDim2.new(1, -4, 0, TextHeight);

					local function EdgeColor(Item)
						return Item == Grid.Selected and EZ.AccentColor or Item.Hovered and EZ.OutlineColor or EZ.Black;
					end;

					local Scroll = EZ:Create('ScrollingFrame', {
						BackgroundTransparency = 1;
						BorderSizePixel = 0;
						Position = GridInfo.Position or UDim2.new();
						Size = GridInfo.Size or UDim2.fromScale(1, 1);
						CanvasSize = UDim2.new();
						AutomaticCanvasSize = Enum.AutomaticSize.Y;
						ScrollingDirection = Enum.ScrollingDirection.Y;
						ScrollBarThickness = 0;
						BottomImage = '';
						TopImage = '';
						ZIndex = 4;
						Parent = Section.Container;
					});
					EZ:AddToRegistry(Scroll, { BorderColor3 = function()
						for _, Item in next, Grid.Items do
							Item.Button.BackgroundColor3 = EZ.MainColor;
							Item.Button.BorderColor3 = EZ.OutlineColor;
							Item.Edge.Color = EdgeColor(Item);
							Item.Label.TextColor3 = EZ.FontColor;
							if Item.Highlight == true then
								Item.Overlay.BackgroundColor3 = EZ.AccentColor;
								Item.OverlayBorder.Color = EZ.AccentColor;
							end;
						end;
						return EZ.OutlineColor;
					end });
					EZ:Create('UIPadding', { PaddingTop = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2); PaddingRight = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Scroll });
					local Layout = EZ:Create('UIGridLayout', {
						CellSize = CellSize;
						CellPadding = UDim2.fromOffset(4, 4);
						SortOrder = Enum.SortOrder.LayoutOrder;
						Parent = Scroll;
					});

					local MinWidth, Ratio = CellSize.X.Offset, CellSize.Y.Offset / CellSize.X.Offset;
					local LastWidth;

					local function Fit()
						local Width = Scroll.AbsoluteSize.X - 4;
						if Width == LastWidth or Width <= 0 then return end;
						LastWidth = Width;

						local Columns = math.max(1, (Width + 4) // (MinWidth + 4));
						local CellWidth = (Width - 4 * (Columns - 1)) // Columns;
						Layout.CellSize = UDim2.fromOffset(CellWidth, CellWidth * Ratio // 1);
					end;

					Scroll:GetPropertyChangedSignal('AbsoluteSize'):Connect(Fit);
					Fit();
					Grid.Holder = Scroll;

					function Grid:SetVisible(Bool)
						Scroll.Visible = Bool;
					end;

					function Grid:AddItem(Item)
						local Items = Grid.Items;
						local Index = #Items + 1;

						local Cell = Instance.new('TextButton');
						Cell.AutoButtonColor = false;
						Cell.Text = '';
						Cell.BackgroundColor3 = EZ.MainColor;
						Cell.BorderColor3 = EZ.OutlineColor;
						Cell.BorderMode = Enum.BorderMode.Inset;

						local Edge = Instance.new('UIStroke');
						Edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Edge.Color = EZ.Black;
						Edge.Parent = Cell;
						Cell.LayoutOrder = Index;
						Cell.ZIndex = 5;
						Cell.ClipsDescendants = true;

						local Visual = Item.Instance;
						if Visual then
							Visual.AnchorPoint = Vector2.zero;
							Visual.Position = VisualPosition;
							Visual.Size = VisualSize;
						else
							Visual = Instance.new('ImageLabel');
							Visual.BackgroundTransparency = 1;
							Visual.Image = Item.Image or '';
							Visual.ScaleType = Enum.ScaleType.Fit;
							Visual.AnchorPoint = Vector2.new(0.5, 0.5);
							Visual.Position = ImagePosition;
							local Scale = Item.ImageScale;
							Visual.Size = Scale and UDim2.new(Scale, -6 * Scale, Scale, (-TextHeight - 6) * Scale) or ImageSize;
						end;
						Visual.ZIndex = 6;
						Visual.Parent = Cell;

						local Label = Instance.new('TextLabel');
						Label.BackgroundTransparency = 1;
						Label.Font = EZ.Font;
						Label.TextColor3 = EZ.FontColor;
						Label.TextStrokeTransparency = 0;
						Label.Position = LabelPosition;
						Label.Size = LabelSize;
						Label.Text = Item.Text or '';
						Label.TextSize = 12;
						Label.TextTruncate = Enum.TextTruncate.AtEnd;
						Label.ZIndex = 8;
						Label.Parent = Cell;

						Item.Button = Cell;
						Item.Edge = Edge;
						Item.Visual = Visual;
						Item.Label = Label;
						Item.Search = Label.Text:lower();
						Items[Index] = Item;

						if Grid.Query then
							Cell.Visible = Item.Search:find(Grid.Query, 1, true) ~= nil;
						end;

						if not EZ.IsMobile then
							Cell.MouseEnter:Connect(function()
								Item.Hovered = true;
								Edge.Color = EdgeColor(Item);
							end);
							Cell.MouseLeave:Connect(function()
								Item.Hovered = nil;
								Edge.Color = EdgeColor(Item);
							end);
						end;

						Cell.Activated:Connect(function()
							Grid:Select(Item);
							if Item.Callback then EZ:SafeCallback(Item.Callback, Item) end;
							if GridInfo.Callback then EZ:SafeCallback(GridInfo.Callback, Item) end;
						end);

						Cell.Parent = Scroll;

						return Item;
					end;

					function Grid:Select(Item)
						local Old = Grid.Selected;
						Grid.Selected = Item;
						if Old then Old.Edge.Color = EdgeColor(Old) end;
						if Item then Item.Edge.Color = EdgeColor(Item) end;
					end;

					function Grid:SetState(Item, Dimmed, Highlight)
						Dimmed = Dimmed or false;
						if Item.Dimmed ~= Dimmed then
							Item.Dimmed = Dimmed;
							Item.Visual.ImageColor3 = Dimmed and Color3.fromRGB(60, 60, 60) or Color3.new(1, 1, 1);
							Item.Label.TextTransparency = Dimmed and 0.5 or 0;
						end;

						if Item.Highlight ~= Highlight then
							Item.Highlight = Highlight;
							Item.Edge.Enabled = not Highlight;
							local Overlay = Item.Overlay;
							if not Overlay then
								Overlay = Instance.new('Frame');
								Overlay.BorderSizePixel = 0;
								Overlay.Size = UDim2.fromScale(1, 1);
								Overlay.ZIndex = 7;

								local Gradient = Instance.new('UIGradient');
								Gradient.Rotation = 90;
								Gradient.Transparency = NumberSequence.new(0.85, 0.55);
								Gradient.Parent = Overlay;

								local Border = Instance.new('UIStroke');
								Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
								Border.Thickness = 1;
								Border.Parent = Overlay;

								Overlay.Parent = Item.Button;
								Item.Overlay = Overlay;
								Item.OverlayBorder = Border;
							end;
							if Highlight then
								local Color = Highlight == true and EZ.AccentColor or Highlight;
								Overlay.BackgroundColor3 = Color;
								Item.OverlayBorder.Color = Color;
							end;
							Overlay.Visible = Highlight ~= nil;
						end;
					end;

					function Grid:Filter(Query)
						Query = Query ~= '' and Query:lower() or nil;
						if Query == Grid.Query then return end;
						Grid.Query = Query;

						for _, Item in next, Grid.Items do
							Item.Button.Visible = not Query or Item.Search:find(Query, 1, true) ~= nil;
						end;
					end;

					function Grid:Clear()
						for _, Item in next, Grid.Items do
							Item.Button:Destroy();
						end;
						table.clear(Grid.Items);
						Grid.Selected = nil;
					end;

					return Grid;
				end;

				return Section;
			end;

			Button.Activated:Connect(Tab.ShowTab);

			Window.Tabs[Name] = Tab;
			if next(Window.Tabs, next(Window.Tabs)) == nil then Tab:ShowTab() else Tab:HideTab() end;

			return Tab;
		end;

		Window.Holder = Outer;

		return Window;
	end;

	EZ.CustomLibrary = CustomLibrary;
end

--[[ Save Manager ]]

local SaveManager = {};

do
	SaveManager.Ignore = {};
	SaveManager.Library = EZ;
	SaveManager.CommunityConfigs = SaveManager.CommunityConfigs or {};

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
		return EZ.Folder .. '/' .. EZ.Game:lower() .. '/configs';
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

	function SaveManager:GetCommunityConfigNames()
		local List = {};

		for Name in next, self.CommunityConfigs do
			table.insert(List, Name);
		end;

		table.sort(List);

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

		Section:AddDropdown('SaveManager_CommunityConfigList', { Text = 'Community Configs', Values = self:GetCommunityConfigNames(), AllowNull = true });
		Section:AddButton('Load', function()
			local Name = Options.SaveManager_CommunityConfigList.Value;

			if not Name then
				return self.Library:Notify('No community config selected', 2);
			end;

			local Success, Decoded = pcall(HttpService.JSONDecode, HttpService, self.CommunityConfigs[Name]);

			if not Success or type(Decoded) ~= 'table' or type(Decoded.objects) ~= 'table' then
				return self.Library:Notify(string.format('Invalid community config %q', Name), 3);
			end;

			local Loaded, Err = self:Load(Decoded);

			if not Loaded then
				return self.Library:Notify('Failed to load community config: ' .. tostring(Err), 3);
			end;

			self.Library:Notify(string.format('Loaded community config %q', Name));
		end);

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

		self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigCopyList', 'SaveManager_ConfigName', 'SaveManager_ConfigImport', 'SaveManager_CommunityConfigList' });
	end;
end;

EZ.SaveManager = SaveManager;

--[[ Community Configs ]]

EZ.SaveManager.CommunityConfigs = {
    ["[CLOSEST] Not So Hot"] = [[{"objects":[{"idx":"silentaim_showfov","type":"Toggle","value":true},{"idx":"ragebot_enabled","type":"Toggle","value":false},{"idx":"fly_enabled","type":"Toggle","value":false},{"idx":"esp_distance_override","type":"Toggle","value":false},{"idx":"world_skybox_enabled","type":"Toggle","value":true},{"idx":"ragebot_los_check","type":"Toggle","value":true},{"idx":"spoofers_me_status","type":"Toggle","value":false},{"idx":"esp_ammo_override","type":"Toggle","value":false},{"idx":"esp_box_glow","type":"Toggle","value":false},{"idx":"esp_name_animate","type":"Toggle","value":true},{"idx":"esp_skeleton_outline","type":"Toggle","value":true},{"idx":"gun_appearance","type":"Toggle","value":true},{"idx":"spoofers_other_winstreak","type":"Toggle","value":false},{"idx":"esp_healthbar_outline","type":"Toggle","value":false},{"idx":"ragebot_smart_oob_prebait","type":"Toggle","value":true},{"idx":"arm_chams_strip_textures","type":"Toggle","value":false},{"idx":"noclip_enabled","type":"Toggle","value":false},{"idx":"silentaim_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"world_cc_enabled","type":"Toggle","value":true},{"idx":"disable_game_hit_sound","type":"Toggle","value":true},{"idx":"ragebot_anti_aim","type":"Toggle","value":false},{"idx":"ammo_outline","type":"Toggle","value":false},{"idx":"esp_box_outline","type":"Toggle","value":true},{"idx":"damage_number_blocked_colors","type":"Toggle","value":true},{"idx":"esp_distance_animate","type":"Toggle","value":false},{"idx":"spoofers_me_influencer","type":"Toggle","value":false},{"idx":"world_esp_distance","type":"Toggle","value":false},{"idx":"auto_respawn","type":"Toggle","value":false},{"idx":"damage_number_shadow","type":"Toggle","value":true},{"idx":"auto_vote_map","type":"Toggle","value":false},{"idx":"esp_highlight","type":"Toggle","value":false},{"idx":"world_esp_name_override","type":"Toggle","value":false},{"idx":"custom_text","type":"Toggle","value":true},{"idx":"world_ambient_enabled","type":"Toggle","value":true},{"idx":"spoofers_other_elo","type":"Toggle","value":false},{"idx":"world_colorshift_bottom_enabled","type":"Toggle","value":true},{"idx":"jump_power_enabled","type":"Toggle","value":false},{"idx":"flickbot_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"viewmodel_offset","type":"Toggle","value":true},{"idx":"esp_weapon_override","type":"Toggle","value":false},{"idx":"aimbot_ignore_radius","type":"Toggle","value":false},{"idx":"arm_highlight","type":"Toggle","value":false},{"idx":"flickbot_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"world_esp_name_outline","type":"Toggle","value":true},{"idx":"silentaim_fov_outline","type":"Toggle","value":true},{"idx":"auto_queue","type":"Toggle","value":false},{"idx":"spoofers_other_team","type":"Toggle","value":false},{"idx":"flickbot_targeting_limit_distance","type":"Toggle","value":false},{"idx":"ragebot_default_evasion_spam","type":"Toggle","value":false},{"idx":"aimbot_fov_outline","type":"Toggle","value":true},{"idx":"esp_healthbar","type":"Toggle","value":true},{"idx":"spoofers_other_level","type":"Toggle","value":false},{"idx":"gun_appearance_transparency","type":"Toggle","value":false},{"idx":"world_expose_compensation_enabled","type":"Toggle","value":true},{"idx":"auto_execute","type":"Toggle","value":false},{"idx":"aimbot_fov_fill","type":"Toggle","value":true},{"idx":"world_sun_rays_enabled","type":"Toggle","value":true},{"idx":"esp_box_fill_moving","type":"Toggle","value":false},{"idx":"world_esp_name","type":"Toggle","value":false},{"idx":"aimbot_fov_moving","type":"Toggle","value":true},{"idx":"ragebot_medkit","type":"Toggle","value":false},{"idx":"world_colorshift_top_enabled","type":"Toggle","value":true},{"idx":"slide_speed_enabled","type":"Toggle","value":false},{"idx":"arm_chams","type":"Toggle","value":true},{"idx":"spoofers_me_level","type":"Toggle","value":false},{"idx":"silentaim_targeting_limit_distance","type":"Toggle","value":false},{"idx":"long_jump_enabled","type":"Toggle","value":false},{"idx":"targeting_ignore_protected","type":"Toggle","value":false},{"idx":"silentaim_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"esp_flags_staring","type":"Toggle","value":true},{"idx":"spoofers_me_team","type":"Toggle","value":false},{"idx":"world_fogstart_enabled","type":"Toggle","value":true},{"idx":"flickbot_shoot","type":"Toggle","value":true},{"idx":"aimbot_enabled","type":"Toggle","value":true},{"idx":"aimbot_override","type":"Toggle","value":false},{"idx":"silentaim_fov_moving","type":"Toggle","value":true},{"idx":"crosshair_hide_native","type":"Toggle","value":true},{"idx":"world_camera_fov_enabled","type":"Toggle","value":true},{"idx":"esp_flags_override","type":"Toggle","value":false},{"idx":"esp_limit_distance","type":"Toggle","value":false},{"idx":"NotificationForceColors","type":"Toggle","value":false},{"idx":"world_camera_blur_enabled","type":"Toggle","value":false},{"idx":"KeybindMenu","type":"Toggle","value":true},{"idx":"world_esp_name_animate","type":"Toggle","value":false},{"idx":"kill_sound_enabled","type":"Toggle","value":false},{"idx":"world_texture_packs_enabled","type":"Toggle","value":true},{"idx":"custom_text_outline","type":"Toggle","value":true},{"idx":"spoofers_me_employee","type":"Toggle","value":false},{"idx":"esp_include_team","type":"Toggle","value":true},{"idx":"silentaim_ignore_radius","type":"Toggle","value":true},{"idx":"esp_flags","type":"Toggle","value":false},{"idx":"auto_heal","type":"Toggle","value":false},{"idx":"auto_loadout","type":"Toggle","value":false},{"idx":"spoofers_me_winstreak","type":"Toggle","value":false},{"idx":"tripmine_team_trigger","type":"Toggle","value":false},{"idx":"third_person_enabled","type":"Toggle","value":false},{"idx":"esp_override_color","type":"Toggle","value":false},{"idx":"spoofers_other_status","type":"Toggle","value":false},{"idx":"tripmine_trigger","type":"Toggle","value":false},{"idx":"targeting_limit_distance","type":"Toggle","value":true},{"idx":"auto_ammo","type":"Toggle","value":false},{"idx":"auto_ban","type":"Toggle","value":false},{"idx":"esp_box_glow_moving","type":"Toggle","value":true},{"idx":"flickbot_override","type":"Toggle","value":false},{"idx":"mod_detector","type":"Toggle","value":false},{"idx":"item_chams_strip_textures","type":"Toggle","value":false},{"idx":"arcade_autofarm","type":"Toggle","value":false},{"idx":"custom_tracer_expand","type":"Toggle","value":true},{"idx":"infinite_double_jumps","type":"Toggle","value":false},{"idx":"item_highlight","type":"Toggle","value":false},{"idx":"animation_enabled","type":"Toggle","value":false},{"idx":"disable_game_tracers","type":"Toggle","value":true},{"idx":"esp_ammo_outline","type":"Toggle","value":true},{"idx":"silentaim_fov_fill","type":"Toggle","value":true},{"idx":"custom_tracers","type":"Toggle","value":true},{"idx":"kill_notifications","type":"Toggle","value":false},{"idx":"hit_notifications","type":"Toggle","value":false},{"idx":"esp_override","type":"Toggle","value":false},{"idx":"silentaim_targeting_full_360","type":"Toggle","value":false},{"idx":"damage_number_head_colors","type":"Toggle","value":true},{"idx":"damage_number_stack","type":"Toggle","value":true},{"idx":"disable_game_damage_numbers","type":"Toggle","value":true},{"idx":"damage_numbers","type":"Toggle","value":true},{"idx":"arm_appearance_transparency","type":"Toggle","value":false},{"idx":"item_chams","type":"Toggle","value":true},{"idx":"gun_appearance_material","type":"Toggle","value":true},{"idx":"aimbot_targeting_visible_only","type":"Toggle","value":true},{"idx":"ragebot_anti_knife","type":"Toggle","value":false},{"idx":"esp_flags_deflecting","type":"Toggle","value":true},{"idx":"weapon_always_backstab","type":"Toggle","value":false},{"idx":"ammo_indicator","type":"Toggle","value":false},{"idx":"crosshair_outline","type":"Toggle","value":true},{"idx":"aimbot_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"world_ambience_enabled","type":"Toggle","value":false},{"idx":"arm_appearance_material","type":"Toggle","value":false},{"idx":"world_global_shadows_enabled","type":"Toggle","value":true},{"idx":"arm_appearance_color","type":"Toggle","value":true},{"idx":"spoofers_other_influencer","type":"Toggle","value":false},{"idx":"esp_name","type":"Toggle","value":true},{"idx":"flickbot_targeting_visible_only","type":"Toggle","value":true},{"idx":"arm_appearance","type":"Toggle","value":false},{"idx":"gun_appearance_wireframe","type":"Toggle","value":true},{"idx":"world_fogend_enabled","type":"Toggle","value":true},{"idx":"gun_appearance_color","type":"Toggle","value":false},{"idx":"esp_box_moving","type":"Toggle","value":true},{"idx":"hit_effects_enabled","type":"Toggle","value":true},{"idx":"triggerbot_enabled","type":"Toggle","value":false},{"idx":"hit_sounds","type":"Toggle","value":true},{"idx":"ragebot_riot_shield","type":"Toggle","value":false},{"idx":"spoofers_me_elo","type":"Toggle","value":false},{"idx":"world_weather_enabled","type":"Toggle","value":true},{"idx":"auto_slide_enabled","type":"Toggle","value":false},{"idx":"double_jump_power_enabled","type":"Toggle","value":false},{"idx":"fake_pos","type":"Toggle","value":false},{"idx":"auto_strafe_enabled","type":"Toggle","value":false},{"idx":"world_bloom_enabled","type":"Toggle","value":true},{"idx":"custom_text_animate","type":"Toggle","value":true},{"idx":"silentaim_targeting_visible_only","type":"Toggle","value":true},{"idx":"targeting_visible_only","type":"Toggle","value":true},{"idx":"walk_speed_enabled","type":"Toggle","value":false},{"idx":"weapon_full_auto","type":"Toggle","value":true},{"idx":"world_weather_heavy_rain_lightning_enabled","type":"Toggle","value":true},{"idx":"esp_skeleton","type":"Toggle","value":false},{"idx":"esp_distance_outline","type":"Toggle","value":true},{"idx":"world_brightness_enabled","type":"Toggle","value":false},{"idx":"ragebot_anti_aim_underground","type":"Toggle","value":false},{"idx":"esp_flags_animate","type":"Toggle","value":false},{"idx":"ragebot_melee_evasion_spam","type":"Toggle","value":false},{"idx":"esp_override_material","type":"Toggle","value":false},{"idx":"silentaim_enabled","type":"Toggle","value":true},{"idx":"aimbot_showfov","type":"Toggle","value":true},{"idx":"world_atmosphere_enabled","type":"Toggle","value":true},{"idx":"esp_flags_health","type":"Toggle","value":true},{"idx":"auto_execute_silent","type":"Toggle","value":false},{"idx":"esp_ammo_animate","type":"Toggle","value":false},{"idx":"esp_name_outline","type":"Toggle","value":true},{"idx":"esp_weapon_animate","type":"Toggle","value":true},{"idx":"ragebot_anti_aim_random_angle","type":"Toggle","value":false},{"idx":"flickbot_enabled","type":"Toggle","value":false},{"idx":"ragebot_character_origin","type":"Toggle","value":false},{"idx":"esp_weapon_outline","type":"Toggle","value":true},{"idx":"esp_weapon","type":"Toggle","value":true},{"idx":"crosshair_dot","type":"Toggle","value":false},{"idx":"esp_name_override","type":"Toggle","value":false},{"idx":"esp_ammo","type":"Toggle","value":false},{"idx":"crosshair_enabled","type":"Toggle","value":true},{"idx":"spoofers_other_employee","type":"Toggle","value":false},{"idx":"esp_distance","type":"Toggle","value":false},{"idx":"aimbot_targeting_limit_distance","type":"Toggle","value":false},{"idx":"world_clocktime_enabled","type":"Toggle","value":true},{"idx":"esp_box_fill","type":"Toggle","value":true},{"idx":"silentaim_override","type":"Toggle","value":false},{"idx":"esp_box","type":"Toggle","value":true},{"idx":"world_camera_aspect_enabled","type":"Toggle","value":false},{"idx":"world_esp_icon","type":"Toggle","value":false},{"idx":"world_esp_distance_override","type":"Toggle","value":false},{"idx":"world_esp_distance_outline","type":"Toggle","value":true},{"idx":"weapon_no_spread","type":"Toggle","value":false},{"idx":"world_esp_distance_animate","type":"Toggle","value":false},{"idx":"world_fogcolor_enabled","type":"Toggle","value":true},{"idx":"world_esp_limit_distance","type":"Toggle","value":false},{"idx":"perf_quality","type":"Toggle","value":false},{"idx":"targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"aimbot_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"ragebot_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"triggerbot_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"crosshair_top_color","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"spoofers_other_target","type":"Dropdown"},{"idx":"spoofers_emotes","type":"Input","text":""},{"idx":"ammo_offset_x","type":"Slider","value":"0"},{"idx":"world_skybox_custom_file_up","type":"Dropdown"},{"idx":"damage_number_head_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_box_outline_color","type":"ColorPicker","transparency":0,"value":"26445a"},{"idx":"esp_box_fill_type","type":"Dropdown","value":"connected"},{"idx":"esp_weapon_rotation","type":"Slider","value":"0"},{"idx":"custom_tracer_you_color","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"aimbot_fov_rotation","type":"Slider","value":"0"},{"idx":"esp_distance_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_healthbar_spacing","type":"Slider","value":"3"},{"idx":"viewmodel_override_x","type":"Slider","value":"0"},{"idx":"world_esp_name_shimmer_speed","type":"Slider","value":"1"},{"idx":"loadout_melee","type":"Dropdown","value":"Battle Axe"},{"idx":"ragebot_weapon","type":"Dropdown","value":"primary"},{"idx":"arcade_max_deaths","type":"Slider","value":"5"},{"idx":"aimbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"disable_effects","type":"Dropdown","mutli":true,"value":{"scope overlay":true,"vignette":true}},{"idx":"world_weather_heavy_rain_height","type":"Slider","value":"130"},{"idx":"world_weather_snow_transparency","type":"Slider","value":"1"},{"idx":"silentaim_fov_position","type":"Dropdown"},{"idx":"esp_box_color_start","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_weapon_position","type":"Dropdown","value":"down"},{"idx":"esp_weapon_spacing","type":"Slider","value":"4"},{"idx":"ragebot_smart_oob_distance","type":"Slider","value":"3"},{"idx":"world_bloom_threshold","type":"Slider","value":"0.85"},{"idx":"world_skybox_custom_file_left","type":"Dropdown"},{"idx":"esp_override_material_value","type":"Dropdown","value":"ForceField"},{"idx":"ragebot_orbit_radius","type":"Slider","value":"10"},{"idx":"world_weather_heavy_rain_lightning_interval_min","type":"Slider","value":"6"},{"idx":"flickbot_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"custom_tracer_enemies_color","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"spoofers_other_winstreak_value","type":"Input","text":"0"},{"idx":"world_skybox_custom_id_front","type":"Input","text":""},{"idx":"ammo_below","type":"Slider","value":"100"},{"idx":"world_colorshift_top_color","type":"ColorPicker","transparency":0,"value":"cdeaff"},{"idx":"targeting_part_engine","type":"Dropdown","value":"closest to mouse"},{"idx":"world_esp_name_animation","type":"Dropdown","value":"moving rotation"},{"idx":"crosshair_position","type":"Dropdown"},{"idx":"crosshair_spread_min","type":"Slider","value":"4"},{"idx":"esp_distance_spin_speed","type":"Slider","value":"1"},{"idx":"gun_appearance_color_value","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"world_esp_distance_color_end","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"world_esp_name_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_ammo_spacing","type":"Slider","value":"4"},{"idx":"custom_tracer_style","type":"Dropdown","value":"Lightning"},{"idx":"hit_notifications_list","type":"Dropdown","mutli":true,"value":{"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}":true}},{"idx":"esp_distance_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_flags_deflecting_color_end","type":"ColorPicker","transparency":0,"value":"3c5aff"},{"idx":"world_weather_blizzard_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"ragebot_anti_aim_pitch","type":"Dropdown","value":"none"},{"idx":"silentaim_fov_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"79bae8"},{"idx":"world_skybox_selected","type":"Dropdown","value":"AestheticMountains"},{"idx":"arm_highlight_outline","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_melee_attempts","type":"Slider","value":"1"},{"idx":"world_bloom_intensity","type":"Slider","value":"0.7"},{"idx":"world_weather_heavy_rain_lightning_color_end","type":"ColorPicker","transparency":0,"value":"b4c8ff"},{"idx":"animation_pick","type":"Dropdown","value":"solar system"},{"idx":"triggerbot_targeting_forget_time","type":"Slider","value":"0.5"},{"idx":"hit_effects_color_2","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_flags_text_size","type":"Slider","value":"12"},{"idx":"world_esp_name_type","type":"Dropdown","value":"uppercase"},{"idx":"aimbot_fov_outline_color_start","type":"ColorPicker","transparency":0.3,"value":"7dc3f5"},{"idx":"esp_box_thickness","type":"Slider","value":"1"},{"idx":"arm_chams_transparency","type":"Slider","value":"0"},{"idx":"esp_box_fill_rotation_speed","type":"Slider","value":"1"},{"idx":"esp_skeleton_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"damage_number_color_end","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"crosshair_outline_thickness","type":"Slider","value":"1"},{"idx":"world_weather_color_end","type":"ColorPicker","transparency":0,"value":"94d2ff"},{"idx":"esp_ammo_ping_pong_speed","type":"Slider","value":"1"},{"idx":"hit_sound_pitch","type":"Slider","value":"1.15"},{"idx":"esp_name_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_ammo_position","type":"Dropdown","value":"down"},{"idx":"world_skybox_custom_id_back","type":"Input","text":""},{"idx":"custom_text_color_3","type":"ColorPicker","transparency":0,"value":"8ed0ff"},{"idx":"viewmodel_override_yaw","type":"Slider","value":"0"},{"idx":"world_esp_name_rotation","type":"Slider","value":"0"},{"idx":"esp_box_fill_rotation","type":"Slider","value":"90"},{"idx":"world_skybox_custom_id_right","type":"Input","text":""},{"idx":"item_highlight_fill","type":"ColorPicker","transparency":0.5,"value":"79b9e6"},{"idx":"esp_flags_prefix","type":"Dropdown","value":"full"},{"idx":"crosshair_spread_speed","type":"Slider","value":"0.5"},{"idx":"esp_skeleton_color_middle","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_skybox_custom_file_down","type":"Dropdown"},{"idx":"ammo_color_1","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"ragebot_adaptive_period","type":"Slider","value":"4"},{"idx":"world_weather_color_start","type":"ColorPicker","transparency":0,"value":"9cd6ff"},{"idx":"silentaim_fov_rotation","type":"Slider","value":"0"},{"idx":"animation_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"world_bloom_size","type":"Slider","value":"30"},{"idx":"flickbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"crosshair_bottom_color","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"aimbot_fov_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"79bae8"},{"idx":"esp_highlight_fill","type":"ColorPicker","transparency":0.75,"value":"a6daff"},{"idx":"viewmodel_override_roll","type":"Slider","value":"0"},{"idx":"crosshair_color_anim","type":"Dropdown","value":"pingpong"},{"idx":"long_jump_force","type":"Slider","value":"60"},{"idx":"esp_name_text_size","type":"Slider","value":"12"},{"idx":"world_ambience_custom_data","type":"Input","text":"[]"},{"idx":"world_esp_icon_size","type":"Slider","value":"100"},{"idx":"flickbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"world_weather_heavy_rain_width","type":"Slider","value":"0.05"},{"idx":"aimbot_fov_color_end","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"custom_tracer_spring_damper","type":"Slider","value":"0.7"},{"idx":"world_texture_packs_selected","type":"Dropdown","value":"minecraft"},{"idx":"ragebot_medkit_mode","type":"Dropdown","value":"quick heal"},{"idx":"ragebot_melee_mode","type":"Dropdown","value":"normal"},{"idx":"silentaim_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"world_ambience_selected","type":"Dropdown","value":"Windy Day"},{"idx":"ragebot_default_evade_time","type":"Slider","value":"0.1"},{"idx":"esp_distance_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_ammo_items","type":"Dropdown","mutli":true,"value":{"reserve":true,"ammo":true}},{"idx":"disable_anims","type":"Dropdown","mutli":true,"value":{"equip":true,"muzzle flash":true,"idle":true,"sway":true}},{"idx":"silentaim_fov_outline_color_end","type":"ColorPicker","transparency":0.3,"value":"7dc3f5"},{"idx":"esp_healthbar_slices","type":"Slider","value":"1"},{"idx":"kill_notifications_list","type":"Dropdown","mutli":true,"value":{"Killed {NAME}":true,"Fucked {NAME}":true,"Raped {NAME}":true,"Destroyed {NAME}":true}},{"idx":"world_esp_name_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_distance_animation","type":"Dropdown","value":"moving rotation"},{"idx":"world_weather_selected","type":"Dropdown","value":"Snow"},{"idx":"ammo_color_2","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"world_weather_snow_rate","type":"Slider","value":"0.8"},{"idx":"flickbot_curvature","type":"Slider","value":"12"},{"idx":"esp_ammo_spin_speed","type":"Slider","value":"1"},{"idx":"esp_distance_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_skybox_custom_file_front","type":"Dropdown"},{"idx":"world_esp_distance_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_esp_name_font","type":"Dropdown","value":"Tahoma"},{"idx":"ragebot_anti_aim_yaw","type":"Dropdown","value":"none"},{"idx":"silentaim_targeting_max_distance","type":"Slider","value":"150"},{"idx":"esp_name_shimmer_color","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"custom_tracer_teammates_color","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"aimbot_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"crosshair_outline_color","type":"ColorPicker","transparency":0,"value":"26445a"},{"idx":"esp_override_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_weather_rain_height","type":"Slider","value":"60"},{"idx":"world_weather_rain_length","type":"Slider","value":"4"},{"idx":"esp_ammo_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_adaptive_on","type":"Slider","value":"2"},{"idx":"world_weather_rain_rate","type":"Slider","value":"10"},{"idx":"crosshair_color_2","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"esp_distance_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_knife_speed","type":"Slider","value":"2.4"},{"idx":"ragebot_spiral_rate","type":"Slider","value":"0.5"},{"idx":"esp_flags_shimmer_speed","type":"Slider","value":"1"},{"idx":"flickbot_duration","type":"Slider","value":"110"},{"idx":"spoofers_unlocked","type":"Input","text":""},{"idx":"world_sun_rays_intensity","type":"Slider","value":"0.25"},{"idx":"custom_text_shimmer_speed","type":"Slider","value":"0.8"},{"idx":"esp_flags_rotation","type":"Slider","value":"0"},{"idx":"esp_box_glow_color_middle","type":"ColorPicker","transparency":0.85,"value":"bce3ff"},{"idx":"damage_number_blocked_color_middle","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"aimbot_targeting_forget_time","type":"Slider","value":"1"},{"idx":"world_explore_compensation","type":"Slider","value":"-0.8"},{"idx":"crosshair_thickness","type":"Slider","value":"2"},{"idx":"hit_sound_head","type":"Dropdown","value":"Sparkle"},{"idx":"kill_notifications_data","type":"Input","text":"{\"formats\":[\"Killed {NAME}\",\"Fucked {NAME}\",\"Destroyed {NAME}\",\"Raped {NAME}\"],\"selected\":{\"Killed {NAME}\":true,\"Fucked {NAME}\":true,\"Raped {NAME}\":true,\"Destroyed {NAME}\":true}}"},{"idx":"ragebot_shoot_frames","type":"Slider","value":"1"},{"idx":"world_esp_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_skeleton_color_start","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"esp_box_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_box_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"aimbot_smoothing","type":"Slider","value":"13"},{"idx":"world_atmosphere_glare","type":"Slider","value":"2"},{"idx":"viewmodel_override_z","type":"Slider","value":"-0.2"},{"idx":"world_esp_distance_ping_pong_speed","type":"Slider","value":"1"},{"idx":"world_weather_rain_transparency","type":"Slider","value":"0.6"},{"idx":"custom_tracer_width","type":"Slider","value":"0.05"},{"idx":"silentaim_fov_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"ragebot_random_range","type":"Slider","value":"0.5"},{"idx":"esp_flags_staring_color_end","type":"ColorPicker","transparency":0,"value":"c81e1e"},{"idx":"infinite_double_jumps_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"esp_healthbar_color_middle","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_weapon_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"ragebot_melee_attack_time","type":"Slider","value":"0.2"},{"idx":"world_esp_distance_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_flags_ping_pong_speed","type":"Slider","value":"1"},{"idx":"flickbot_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"world_atmosphere_haze","type":"Slider","value":"2.7"},{"idx":"ragebot_preset_name","type":"Input","text":""},{"idx":"targeting_max_distance","type":"Slider","value":"50"},{"idx":"world_esp_name_color_middle","type":"ColorPicker","transparency":0,"value":"d8efff"},{"idx":"aimbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"world_weather_heavy_rain_lightning_color_start","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_highlight_outline","type":"ColorPicker","transparency":0.4,"value":"d6eeff"},{"idx":"damage_number_rise","type":"Slider","value":"3"},{"idx":"silentaim_targeting_forget_time","type":"Slider","value":"1"},{"idx":"arm_appearance_color_value","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"world_weather_snow_size","type":"Slider","value":"1.1"},{"idx":"silentaim_fov_lerp","type":"Slider","value":"0.12"},{"idx":"esp_box_fill_color_start","type":"ColorPicker","transparency":0.86,"value":"a6daff"},{"idx":"ragebot_oob_position_offset","type":"Slider","value":"0"},{"idx":"esp_name_spin_speed","type":"Slider","value":"1"},{"idx":"aimbot_fov_color_middle","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"custom_tracer_glow","type":"Slider","value":"8"},{"idx":"world_fogend","type":"Slider","value":"515"},{"idx":"world_esp_distance_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"damage_number_out","type":"Dropdown","value":"drift"},{"idx":"world_fogstart","type":"Slider","value":"0"},{"idx":"esp_skeleton_thickness","type":"Slider","value":"1"},{"idx":"esp_flags_deflecting_color_middle","type":"ColorPicker","transparency":0,"value":"50a0ff"},{"idx":"spoofers_me_elo_value","type":"Input","text":"3600"},{"idx":"world_weather_rain_area","type":"Slider","value":"130"},{"idx":"world_esp_distance_color_start","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"flickbot_cooldown","type":"Slider","value":"250"},{"idx":"kill_notifications_format","type":"Input","text":""},{"idx":"world_texture_packs_replace","type":"Dropdown","mutli":true,"value":{"textures":true}},{"idx":"damage_number_in","type":"Dropdown","value":"pop"},{"idx":"esp_healthbar_lerp","type":"Slider","value":"0.15"},{"idx":"silentaim_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"world_clocktime","type":"Slider","value":"6.7"},{"idx":"esp_weapon_shimmer_speed","type":"Slider","value":"1"},{"idx":"world_weather_heavy_rain_thunder_volume","type":"Slider","value":"3"},{"idx":"targeting_part","type":"Dropdown","mutli":true,"value":{"Head":true}},{"idx":"world_weather_heavy_rain_speed","type":"Slider","value":"1"},{"idx":"world_weather_blizzard_rate","type":"Slider","value":"1"},{"idx":"targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"melee":true,"utility":true}},{"idx":"gun_appearance_material_type","type":"Dropdown","value":"Neon"},{"idx":"gun_appearance_transparency_value","type":"Slider","value":"26"},{"idx":"flickbot_settings","type":"Dropdown","mutli":true,"value":{"anti riot shield":true,"anti katana":true}},{"idx":"world_esp_icon_out_lerp","type":"Slider","value":"0.5"},{"idx":"esp_healthbar_type","type":"Dropdown","value":"gradient"},{"idx":"aimbot_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"animation_loop_start","type":"Slider","value":"0"},{"idx":"world_weather_heavy_rain_rate","type":"Slider","value":"35"},{"idx":"world_weather_blizzard_speed","type":"Slider","value":"1"},{"idx":"aimbot_fov_position","type":"Dropdown"},{"idx":"targeting_forget_time","type":"Slider","value":"1"},{"idx":"ban_weapons_second","type":"Dropdown","mutli":true,"value":[]},{"idx":"arm_chams_material","type":"Dropdown","value":"Original"},{"idx":"esp_ammo_animation","type":"Dropdown","value":"moving rotation"},{"idx":"world_esp_icon_mode","type":"Dropdown","value":"fixed"},{"idx":"long_jump_keybind","type":"KeyPicker","key":"...","mode":"Toggle"},{"idx":"ragebot_smart_oob_evade_time","type":"Slider","value":"2"},{"idx":"aimbot_fov_rotation_speed","type":"Slider","value":"0.3"},{"idx":"esp_flags_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_name_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"damage_number_blocked_color_end","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"hit_sound_custom_id_kill","type":"Input","text":""},{"idx":"aimbot_fov_fill_color_start","type":"ColorPicker","transparency":0.9,"value":"a6daff"},{"idx":"world_skybox_custom_id_left","type":"Input","text":""},{"idx":"damage_number_blocked_color_start","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"walk_speed_multiplier","type":"Slider","value":"3"},{"idx":"crosshair_length","type":"Slider","value":"20"},{"idx":"world_esp_icon_in_lerp","type":"Slider","value":"0.5"},{"idx":"custom_tracer_texture_length","type":"Slider","value":"4"},{"idx":"world_esp_name_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"damage_number_color_middle","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"spoofers_other_elo_value","type":"Input","text":"0"},{"idx":"esp_name_type","type":"Dropdown","value":"username"},{"idx":"animation_loop_end","type":"Slider","value":"100"},{"idx":"triggerbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"esp_distance_shimmer_speed","type":"Slider","value":"1"},{"idx":"crosshair_color_speed","type":"Slider","value":"0.5"},{"idx":"esp_flags_animation","type":"Dropdown","value":"moving rotation"},{"idx":"aimbot_curvature","type":"Slider","value":"31"},{"idx":"ammo_items","type":"Dropdown","mutli":true,"value":{"ammos":true,"max ammos":true}},{"idx":"custom_text_font","type":"Dropdown","value":"Monocraft"},{"idx":"world_esp_name_spacing","type":"Slider","value":"4"},{"idx":"custom_text_color_2","type":"ColorPicker","transparency":0,"value":"95d3ff"},{"idx":"silentaim_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"spoofers_locked","type":"Input","text":""},{"idx":"crosshair_dot_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_weather_snow_spread","type":"Slider","value":"1.2"},{"idx":"world_weather_snow_speed","type":"Slider","value":"0.5"},{"idx":"esp_weapon_animation","type":"Dropdown","value":"shimmer"},{"idx":"ammo_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"silentaim_fov_outline_color_middle","type":"ColorPicker","transparency":0.3,"value":"a6daff"},{"idx":"custom_text_offset_y","type":"Slider","value":"-5"},{"idx":"esp_weapon_shimmer_color","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"arm_appearance_color_mode","type":"Dropdown","value":"tint"},{"idx":"esp_weapon_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_weapon_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_box_glow_color_start","type":"ColorPicker","transparency":0.8,"value":"bce3ff"},{"idx":"custom_text_offset_x","type":"Slider","value":"0"},{"idx":"esp_name_rotation","type":"Slider","value":"90"},{"idx":"esp_text_size","type":"Slider","value":"12"},{"idx":"crosshair_left_color","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"hit_sound_custom_source_head","type":"Dropdown","value":"roblox asset id"},{"idx":"world_esp_name_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"weapon_grenade_options","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_camera_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_weather_heavy_rain_length","type":"Slider","value":"4"},{"idx":"arcade_min_players","type":"Slider","value":"4"},{"idx":"world_ambience_custom_source","type":"Dropdown","value":"roblox asset id"},{"idx":"long_jump_upward","type":"Slider","value":"20"},{"idx":"ban_weapons_first","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_brightness","type":"Slider","value":"2.4"},{"idx":"esp_healthbar_color_end","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"hit_sound_volume","type":"Slider","value":"0.8"},{"idx":"esp_max_distance","type":"Slider","value":"500"},{"idx":"damage_number_head_color_start","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_anti_aim_min_speed","type":"Slider","value":"10"},{"idx":"esp_ammo_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"custom_text_shimmer_color","type":"ColorPicker","transparency":0,"value":"acd8f9"},{"idx":"ragebot_oob_position","type":"Dropdown","value":"down"},{"idx":"ragebot_spiral_radius","type":"Slider","value":"10"},{"idx":"third_person_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"targeting_reaction_time","type":"Slider","value":"0"},{"idx":"esp_distance_spacing","type":"Slider","value":"3"},{"idx":"silentaim_fov_fill_color_start","type":"ColorPicker","transparency":0.9,"value":"a6daff"},{"idx":"esp_name_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"ragebot_shot_interval","type":"Slider","value":"70"},{"idx":"esp_box_glow_rotation","type":"Slider","value":"0"},{"idx":"kill_sound","type":"Dropdown","value":"Sparkle"},{"idx":"spoofers_me_level_value","type":"Input","text":"999"},{"idx":"esp_name_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"arm_appearance_color_tint","type":"Slider","value":"30"},{"idx":"esp_name_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_esp_max_distance","type":"Slider","value":"200"},{"idx":"ragebot_preset_list","type":"Dropdown","value":"Default"},{"idx":"world_weather_heavy_rain_area","type":"Slider","value":"400"},{"idx":"spoofers_weapons","type":"Input","text":""},{"idx":"world_skybox_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"kill_sound_pitch","type":"Slider","value":"0.9"},{"idx":"ragebot_resolver","type":"Dropdown","value":"switch if no reserve"},{"idx":"long_jump_mode","type":"Dropdown","value":"forward"},{"idx":"aimbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"ragebot_medkit_health","type":"Slider","value":"50"},{"idx":"damage_number_drift","type":"Slider","value":"3"},{"idx":"world_cc_brightness","type":"Slider","value":"0.02"},{"idx":"esp_ammo_font","type":"Dropdown","value":"Tahoma"},{"idx":"silentaim_fov","type":"Slider","value":"110"},{"idx":"hit_sound_custom_file_kill","type":"Dropdown"},{"idx":"world_weather_blizzard_spread","type":"Slider","value":"1"},{"idx":"esp_ammo_color_end","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"esp_ammo_text_size","type":"Slider","value":"12"},{"idx":"KeybindMenuMode","type":"Dropdown","value":"Toggled"},{"idx":"world_weather_heavy_rain_lightning_interval_max","type":"Slider","value":"15"},{"idx":"esp_box_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"79bae8"},{"idx":"world_weather_color_middle","type":"ColorPicker","transparency":0,"value":"a9dbff"},{"idx":"world_esp_name_text_size","type":"Slider","value":"13"},{"idx":"ragebot_evasion","type":"Dropdown","value":"random"},{"idx":"ragebot_flicker_glue","type":"Slider","value":"0.14"},{"idx":"vote_maps","type":"Dropdown","mutli":true,"value":[]},{"idx":"NotificationForcedText","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"NotificationForcedOutline","type":"ColorPicker","transparency":0,"value":"1f1f1f"},{"idx":"world_esp_icon_in_anim","type":"Dropdown","value":"scale"},{"idx":"world_texture_packs_time","type":"Dropdown","value":"day"},{"idx":"world_esp_distance_spin_speed","type":"Slider","value":"1"},{"idx":"world_ambient_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"silentaim_fov_rotation_speed","type":"Slider","value":"0.1"},{"idx":"esp_name_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_esp_distance_position","type":"Dropdown","value":"down"},{"idx":"animation_custom_id","type":"Input","text":""},{"idx":"world_atmosphere_glare_color","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"spoofers_other_status_value","type":"Dropdown","value":"Prime"},{"idx":"custom_tracer_lifetime","type":"Slider","value":"0.6"},{"idx":"item_chams_material","type":"Dropdown","value":"Neon"},{"idx":"KeybindMenuTransparency","type":"Slider","value":"100"},{"idx":"esp_healthbar_color_start","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"esp_fixed_width","type":"Slider","value":"100"},{"idx":"crosshair_gap","type":"Slider","value":"4"},{"idx":"jump_power_multiplier","type":"Slider","value":"1.5"},{"idx":"esp_weapon_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"esp_flags_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"MenuKeybind","type":"KeyPicker","key":"RightShift","mode":"Toggle"},{"idx":"kill_sound_volume","type":"Slider","value":"0.9"},{"idx":"hit_sound_custom_source_kill","type":"Dropdown","value":"roblox asset id"},{"idx":"crosshair_rotate_speed","type":"Slider","value":"90"},{"idx":"hit_sound_custom_file_head","type":"Dropdown"},{"idx":"hit_sound_custom_id_head","type":"Input","text":""},{"idx":"world_colorshift_bottom_color","type":"ColorPicker","transparency":0,"value":"439fe0"},{"idx":"hit_sound_custom_file_body","type":"Dropdown"},{"idx":"esp_distance_text_size","type":"Slider","value":"12"},{"idx":"hit_sound_custom_id_body","type":"Input","text":""},{"idx":"custom_text_size","type":"Slider","value":"11"},{"idx":"world_skybox_custom_source","type":"Dropdown","value":"roblox asset ids"},{"idx":"hit_sound_custom_source_body","type":"Dropdown","value":"roblox asset id"},{"idx":"hit_sound_body","type":"Dropdown","value":"Sparkle"},{"idx":"loadout_utility","type":"Dropdown","value":"Flashbang"},{"idx":"loadout_secondary","type":"Dropdown","value":"Daggers"},{"idx":"loadout_primary","type":"Dropdown","value":"Assault Rifle"},{"idx":"queue_mode","type":"Dropdown","value":"1v1"},{"idx":"world_camera_fov","type":"Slider","value":"90"},{"idx":"hit_effects_color_3","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"world_esp_icon_in_fade","type":"Slider","value":"0.2"},{"idx":"mod_actions","type":"Dropdown","mutli":true,"value":{"server hop":true,"notification":true}},{"idx":"world_skybox_custom_data","type":"Input","text":"[]"},{"idx":"webhook_events","type":"Dropdown","mutli":true,"value":[]},{"idx":"discord_webhook","type":"Input","text":""},{"idx":"crosshair_dot_size","type":"Slider","value":"2"},{"idx":"world_weather_heavy_rain_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"esp_flags_health_color_start","type":"ColorPicker","transparency":0,"value":"78ff78"},{"idx":"item_highlight_outline","type":"ColorPicker","transparency":0,"value":"79b9e6"},{"idx":"custom_tracer_fade","type":"Slider","value":"0.35"},{"idx":"custom_tracer_texture_speed","type":"Slider","value":"1"},{"idx":"world_esp_distance_rotation","type":"Slider","value":"0"},{"idx":"esp_name_spacing","type":"Slider","value":"6"},{"idx":"world_esp_distance_shimmer_speed","type":"Slider","value":"1"},{"idx":"esp_distance_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"damage_number_size","type":"Slider","value":"24"},{"idx":"damage_number_font","type":"Dropdown","value":"Burbank-Big-Condensed"},{"idx":"esp_box_rotation_speed","type":"Slider","value":"0.25"},{"idx":"damage_number_head_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"slide_speed_multiplier","type":"Slider","value":"10"},{"idx":"damage_number_color_start","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"ammo_size","type":"Slider","value":"11"},{"idx":"heal_below","type":"Slider","value":"100"},{"idx":"esp_distance_rotation","type":"Slider","value":"0"},{"idx":"hit_notifications_data","type":"Input","text":"{\"formats\":[\"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}\"],\"selected\":{\"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}\":true}}"},{"idx":"esp_healthbar_width","type":"Slider","value":"2"},{"idx":"hit_effects_color_1","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"hit_sound_custom_data","type":"Input","text":"[]"},{"idx":"triggerbot_targeting_reaction_offset","type":"Slider","value":"0"},{"idx":"world_weather_rain_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"gun_appearance_color_tint","type":"Slider","value":"32"},{"idx":"custom_text_ping_pong_speed","type":"Slider","value":"1"},{"idx":"custom_text_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_skeleton_color_end","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"third_person_distance","type":"Slider","value":"7.5"},{"idx":"custom_text_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"crosshair_spread_max","type":"Slider","value":"16"},{"idx":"world_esp_name_color_start","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"animation_speed","type":"Slider","value":"1"},{"idx":"custom_text_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_icon_out_anim","type":"Dropdown","value":"fade"},{"idx":"lua_saved","type":"Input","text":""},{"idx":"esp_font","type":"Dropdown","value":"Tahoma"},{"idx":"flickbot_targeting_max_distance","type":"Slider","value":"150"},{"idx":"aimbot_humanness","type":"Slider","value":"69"},{"idx":"world_skybox_custom_id_up","type":"Input","text":""},{"idx":"world_ambience_custom_id","type":"Input","text":""},{"idx":"silentaim_fov_outline_color_start","type":"ColorPicker","transparency":0.3,"value":"7dc3f5"},{"idx":"esp_box_fill_color_end","type":"ColorPicker","transparency":0.85,"value":"26445a"},{"idx":"fly_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"esp_name_shimmer_speed","type":"Slider","value":"0.7"},{"idx":"esp_distance_position","type":"Dropdown","value":"down"},{"idx":"custom_text_input","type":"Input","text":"ezzz"},{"idx":"noclip_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"auto_strafe_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"custom_text_color_1","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"ragebot_base_radius","type":"Slider","value":"100"},{"idx":"esp_flags_health_color_end","type":"ColorPicker","transparency":0,"value":"ff4646"},{"idx":"ammo_offset_y","type":"Slider","value":"0"},{"idx":"world_esp_distance_animation","type":"Dropdown","value":"moving rotation"},{"idx":"hit_effects_list","type":"Dropdown","mutli":true,"value":{"Electricity":true}},{"idx":"ammo_font","type":"Dropdown","value":"Minecraftia"},{"idx":"ammo_color_3","type":"ColorPicker","transparency":0,"value":"7dc3f5"},{"idx":"esp_weapon_color_end","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"world_camera_blur_intensity","type":"Slider","value":"0"},{"idx":"esp_ammo_color_middle","type":"ColorPicker","transparency":0,"value":"d8efff"},{"idx":"silentaim_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"world_weather_heavy_rain_transparency","type":"Slider","value":"0.65"},{"idx":"aimbot_fov_outline_color_end","type":"ColorPicker","transparency":0.3,"value":"7dc3f5"},{"idx":"custom_text_outline_color","type":"ColorPicker","transparency":0,"value":"152632"},{"idx":"world_skybox_custom_id_down","type":"Input","text":""},{"idx":"crosshair_color_1","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_highlight_pulse_speed","type":"Slider","value":"2"},{"idx":"long_jump_offset","type":"Slider","value":"8"},{"idx":"aimbot_fov_outline_color_middle","type":"ColorPicker","transparency":0.3,"value":"a6daff"},{"idx":"esp_ammo_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"crosshair_animate","type":"Dropdown","mutli":true,"value":{"rotate":true}},{"idx":"world_esp_distance_text_size","type":"Slider","value":"13"},{"idx":"ragebot_anti_aim_max_speed","type":"Slider","value":"20"},{"idx":"arcade_death_window","type":"Slider","value":"60"},{"idx":"crosshair_right_color","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"esp_ammo_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_box_glow_color_end","type":"ColorPicker","transparency":0.8,"value":"bce3ff"},{"idx":"esp_override_color_value","type":"ColorPicker","transparency":0,"value":"00dcff"},{"idx":"flickbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"randomize_items","type":"Dropdown","mutli":true,"value":{"skins":true,"wraps":true,"charms":true,"finishers":true}},{"idx":"arm_appearance_transparency_value","type":"Slider","value":"50"},{"idx":"esp_weapon_text_size","type":"Slider","value":"12"},{"idx":"arm_appearance_material_type","type":"Dropdown","value":"ForceField"},{"idx":"world_esp_name_color_end","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"ragebot_smart_oob_patience","type":"Slider","value":"3"},{"idx":"world_esp_distance_color_middle","type":"ColorPicker","transparency":0,"value":"d8efff"},{"idx":"world_weather_blizzard_size","type":"Slider","value":"1"},{"idx":"ragebot_default_attack_time","type":"Slider","value":"0.15"},{"idx":"world_atmosphere_offset","type":"Slider","value":"0.4"},{"idx":"esp_name_position","type":"Dropdown","value":"up"},{"idx":"gun_appearance_wireframe_width","type":"Slider","value":"0.0025"},{"idx":"gun_appearance_color_mode","type":"Dropdown","value":"tint"},{"idx":"spoofers_other_level_value","type":"Input","text":"0"},{"idx":"viewmodel_override_pitch","type":"Slider","value":"0"},{"idx":"NotificationForcedAccent","type":"ColorPicker","transparency":0,"value":"4777b6"},{"idx":"world_ambience_custom_file","type":"Dropdown"},{"idx":"aimbot_fov_fill_color_end","type":"ColorPicker","transparency":0.9,"value":"26445a"},{"idx":"silentaim_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"viewmodel_override_y","type":"Slider","value":"0"},{"idx":"ragebot_flicker_window","type":"Slider","value":"0.16"},{"idx":"arcade_mode","type":"Dropdown","value":"free for all"},{"idx":"world_esp_distance_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_flags_staring_color_middle","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"esp_ammo_shimmer_speed","type":"Slider","value":"1"},{"idx":"world_sun_rays_spread","type":"Slider","value":"1"},{"idx":"arm_chams_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_weather_blizzard_transparency","type":"Slider","value":"1"},{"idx":"item_chams_color","type":"ColorPicker","transparency":0,"value":"4db5ff"},{"idx":"world_weather_snow_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"triggerbot_targeting_max_distance","type":"Slider","value":"100"},{"idx":"esp_name_ping_pong_speed","type":"Slider","value":"1"},{"idx":"silentaim_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"spoofers_me_status_value","type":"Dropdown","value":"Prime"},{"idx":"ragebot_melee_evade_time","type":"Slider","value":"0.2"},{"idx":"world_weather_rain_width","type":"Slider","value":"0.04"},{"idx":"world_camera_aspect_x","type":"Slider","value":"1"},{"idx":"auto_slide_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"world_ambience_volume","type":"Slider","value":"0.25"},{"idx":"world_esp_distance_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_distance_color_start","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"spoofers_me_winstreak_value","type":"Input","text":"999"},{"idx":"esp_name_animation","type":"Dropdown","value":"shimmer"},{"idx":"spoofers_equipped","type":"Input","text":"{\"Crossbow\":{\"Skin\":{\"Name\":\"Crossbone\"}},\"Grenade Launcher\":{\"Skin\":{\"Name\":\"Skull Launcher\"}},\"Medkit\":{\"Skin\":{\"Name\":\"Medkitty\"}},\"Burst Rifle\":{\"Skin\":{\"Name\":\"Electro Rifle\"}},\"Spear\":{\"Skin\":{\"Name\":\"Thunderpike\"}},\"Flashbang\":{\"Skin\":{\"Name\":\"Sol\"}},\"Energy Pistols\":{\"Skin\":{\"Name\":\"Void Pistols\"}},\"Flamethrower\":{\"Skin\":{\"Name\":\"Lamethrower\"}},\"Paintball Gun\":{\"Skin\":{\"Name\":\"Boba Gun\"}},\"Fists\":{\"Skin\":{\"Name\":\"Pumpkin Claws\"}},\"RPG\":{\"Skin\":{\"Name\":\"Pencil Launcher\"}},\"Grappler\":{\"Skin\":{\"Name\":\"Arcade Claw\"}},\"Scythe\":{\"Skin\":{\"Name\":\"Cryo Scythe\"}},\"Slingshot\":{\"Skin\":{\"Name\":\"Goalpost\"}},\"Battle Axe\":{\"Skin\":{\"Name\":\"Nordic Axe\"}},\"Flare Gun\":{\"Skin\":{\"Name\":\"Pocket Volcano\"}},\"Molotov\":{\"Skin\":{\"Name\":\"Vexed Candle\"}},\"Spray\":{\"Skin\":{\"Name\":\"Campfire Spray\"}},\"Revolver\":{\"Wrap\":{\"Name\":\".dll\"},\"Skin\":{\"Name\":\"Keyvolver\"}},\"Wildcat\":{\"Skin\":{\"Name\":\"Plasma Wildcat\"}},\"Riot Shield\":{\"Skin\":{\"Name\":\"Energy Shield\"}},\"Assault Rifle\":{\"Skin\":{\"Name\":\"Drum Gun\"},\"Wrap\":\"none\"},\"Exogun\":{\"Skin\":{\"Name\":\"Wondergun\"}},\"Permafrost\":{\"Skin\":{\"Name\":\"Temporal Permafrost\"}},\"Bow\":{\"Skin\":{\"Name\":\"Raven Bow\"}},\"Shorty\":{\"Skin\":{\"Name\":\"Demon Shorty\"}},\"Daggers\":{\"Skin\":{\"Name\":\"Crystal Daggers\"}},\"Katana\":{\"Skin\":{\"Name\":\"Crystal Katana\"}},\"Knife\":{\"Wrap\":{\"Name\":\".dll\"},\"Skin\":{\"Name\":\"Keyrambit\"}},\"Chainsaw\":{\"Skin\":{\"Name\":\"Handsaws\"}},\"Warper\":{\"Skin\":{\"Name\":\"Electropunk Warper\"}},\"Sniper\":{\"Skin\":{\"Name\":\"Event Horizon\"}},\"Grenade\":{\"Skin\":{\"Name\":\"Water Balloon\"}},\"Freeze Ray\":{\"Skin\":{\"Name\":\"Temporal Ray\"}},\"Maul\":{\"Skin\":{\"Name\":\"Starforge Maul\"}},\"Handgun\":{\"Skin\":{\"Name\":\"Blaster\"}},\"Energy Rifle\":{\"Skin\":{\"Name\":\"Void Rifle\"}},\"Minigun\":{\"Skin\":{\"Name\":\"Shark Minigun\"}},\"Shotgun\":{\"Skin\":{\"Name\":\"Broomstick\"}},\"Trowel\":{\"Skin\":{\"Name\":\"Paintbrush\"}},\"Uzi\":{\"Skin\":{\"Name\":\"Demon Uzi\"}},\"Smoke Grenade\":{\"Skin\":{\"Name\":\"Hourglass\"}},\"Jump Pad\":{\"Skin\":{\"Name\":\"Spider Web\"}},\"Satchel\":{\"Skin\":{\"Name\":\"Bag o' Money\"}},\"Distortion\":{\"Skin\":{\"Name\":\"Plasma Distortion\"}},\"Subspace Tripmine\":{\"Skin\":{\"Name\":\"Spring\"}},\"War Horn\":{\"Skin\":{\"Name\":\"Air Horn\"}},\"Warpstone\":{\"Skin\":{\"Name\":\"Teleport Disc\"}}}"},{"idx":"ragebot_oob_hold","type":"Slider","value":"0.01"},{"idx":"ragebot_knife_radius","type":"Slider","value":"6"},{"idx":"world_esp_text_size","type":"Slider","value":"13"},{"idx":"world_cc_contrast","type":"Slider","value":"0.2"},{"idx":"double_jump_power","type":"Slider","value":"1.5"},{"idx":"world_skybox_custom_file_right","type":"Dropdown"},{"idx":"custom_tracer_players","type":"Dropdown","mutli":true,"value":{"enemies":true,"you":true}},{"idx":"esp_healthbar_position","type":"Dropdown","value":"left"},{"idx":"custom_tracer_spring_speed","type":"Slider","value":"18"},{"idx":"auto_strafe_speed","type":"Slider","value":"50"},{"idx":"aimbot_fov","type":"Slider","value":"230"},{"idx":"esp_flags_health_color_middle","type":"ColorPicker","transparency":0,"value":"8ccfff"},{"idx":"world_cc_saturation","type":"Slider","value":"0.5"},{"idx":"fly_speed","type":"Slider","value":"100"},{"idx":"ragebot_strafe","type":"Dropdown","value":"default"},{"idx":"ragebot_anti_aim_angle","type":"Dropdown","value":"none"},{"idx":"flickbot_humanness","type":"Slider","value":"30"},{"idx":"triggerbot_targeting_reaction_time","type":"Slider","value":"100"},{"idx":"world_esp_name_position","type":"Dropdown","value":"up"},{"idx":"esp_bound_mode","type":"Dropdown","value":"fixed"},{"idx":"triggerbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"esp_highlight_mode","type":"Dropdown","mutli":true,"value":{"thru walls":true,"pulse":true}},{"idx":"esp_flags_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_flags_font","type":"Dropdown","value":"Tahoma"},{"idx":"aimbot_fov_color_start","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"spoofers_injected","type":"Input","text":""},{"idx":"world_esp_items","type":"Dropdown","mutli":true,"value":{"flashbang":true,"flare":true,"satchel":true,"tripmine":true,"warpstone":true,"smoke":true,"molotov":true,"grenade":true}},{"idx":"esp_flags_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"triggerbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"melee":true,"utility":true}},{"idx":"esp_flags_deflecting_color_start","type":"ColorPicker","transparency":0,"value":"8cdcff"},{"idx":"world_atmosphere_density","type":"Slider","value":"0.36"},{"idx":"ragebot_orbit_speed","type":"Slider","value":"2.4"},{"idx":"ragebot_anti_aim_min_angle","type":"Slider","value":"30"},{"idx":"esp_ammo_color_start","type":"ColorPicker","transparency":0,"value":"b6e0ff"},{"idx":"ragebot_autoload_preset","type":"Input","text":"Default"},{"idx":"esp_flags_staring_color_start","type":"ColorPicker","transparency":0,"value":"ff8282"},{"idx":"triggerbot_targeting_shot_delay","type":"Slider","value":"0"},{"idx":"double_jump_power_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"ragebot_shooting","type":"Dropdown","value":"hitscan"},{"idx":"aimbot_targeting_max_distance","type":"Slider","value":"150"},{"idx":"spoofers_favourites","type":"Input","text":""},{"idx":"custom_text_rotation","type":"Slider","value":"0"},{"idx":"aimbot_keybind","type":"KeyPicker","key":"MB2","mode":"Toggle"},{"idx":"silentaim_fov_fill_color_end","type":"ColorPicker","transparency":0.9,"value":"26445a"},{"idx":"world_esp_name_spin_speed","type":"Slider","value":"1"},{"idx":"world_fogcolor_color","type":"ColorPicker","transparency":0,"value":"004678"},{"idx":"world_skybox_custom_file_back","type":"Dropdown"},{"idx":"world_weather_rain_speed","type":"Slider","value":"4.5"},{"idx":"esp_ammo_rotation","type":"Slider","value":"0"},{"idx":"world_cc_tint_color","type":"ColorPicker","transparency":0,"value":"fffbe0"},{"idx":"silentaim_fov_color_start","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"item_chams_transparency","type":"Slider","value":"0.69"},{"idx":"esp_weapon_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_weapon_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_icon_out_fade","type":"Slider","value":"0.2"},{"idx":"esp_weapon_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_name_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"esp_weapon_color_start","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"esp_distance_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"custom_text_animation","type":"Dropdown","value":"shimmer"},{"idx":"world_atmosphere_tint_color","type":"ColorPicker","transparency":0,"value":"cdeaff"},{"idx":"arm_highlight_fill","type":"ColorPicker","transparency":0.5,"value":"ffffff"},{"idx":"esp_distance_outline_color","type":"ColorPicker","transparency":0,"value":"26445a"},{"idx":"ragebot_presets_data","type":"Input","text":""},{"idx":"ragebot_anti_aim_max_angle","type":"Slider","value":"60"},{"idx":"hit_notifications_format","type":"Input","text":""},{"idx":"esp_box_rotation","type":"Slider","value":"0"},{"idx":"ragebot_smart_oob_release","type":"Slider","value":"0.5"},{"idx":"crosshair_color_3","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"aimbot_fov_lerp","type":"Slider","value":"0.12"},{"idx":"esp_name_color_start","type":"ColorPicker","transparency":0,"value":"a6daff"},{"idx":"ragebot_anti_aim_custom_angle","type":"Slider","value":"0"},{"idx":"esp_box_glow_rotation_speed","type":"Slider","value":"0.2"},{"idx":"damage_number_style","type":"Dropdown","value":"fortnite"},{"idx":"flickbot_shot_delay","type":"Slider","value":"40"},{"idx":"flickbot_targeting_forget_time","type":"Slider","value":"1"},{"idx":"ragebot_last_weapon","type":"Dropdown","value":"none"},{"idx":"silentaim_fov_color_middle","type":"ColorPicker","transparency":0,"value":"d6eeff"},{"idx":"flickbot_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"triggerbot_targeting_settings","type":"Dropdown","mutli":true,"value":{"anti riot shield":true,"anti katana":true}},{"idx":"world_camera_aspect_y","type":"Slider","value":"1.2"},{"idx":"ragebot_spiral_speed","type":"Slider","value":"2.4"},{"idx":"world_esp_distance_spacing","type":"Slider","value":"4"}]}]],
    ["[RAGE] The Hell"] = [[{"objects":[{"idx":"silentaim_showfov","type":"Toggle","value":true},{"idx":"ragebot_enabled","type":"Toggle","value":true},{"idx":"fly_enabled","type":"Toggle","value":false},{"idx":"esp_distance_override","type":"Toggle","value":false},{"idx":"world_skybox_enabled","type":"Toggle","value":true},{"idx":"ragebot_los_check","type":"Toggle","value":true},{"idx":"spoofers_me_status","type":"Toggle","value":false},{"idx":"esp_ammo_override","type":"Toggle","value":false},{"idx":"esp_box_glow","type":"Toggle","value":false},{"idx":"esp_name_animate","type":"Toggle","value":true},{"idx":"esp_skeleton_outline","type":"Toggle","value":true},{"idx":"gun_appearance","type":"Toggle","value":true},{"idx":"spoofers_other_winstreak","type":"Toggle","value":false},{"idx":"esp_healthbar_outline","type":"Toggle","value":false},{"idx":"ragebot_smart_oob_prebait","type":"Toggle","value":true},{"idx":"arm_chams_strip_textures","type":"Toggle","value":false},{"idx":"noclip_enabled","type":"Toggle","value":false},{"idx":"silentaim_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"world_cc_enabled","type":"Toggle","value":true},{"idx":"disable_game_hit_sound","type":"Toggle","value":true},{"idx":"ragebot_anti_aim","type":"Toggle","value":false},{"idx":"ammo_outline","type":"Toggle","value":true},{"idx":"esp_box_outline","type":"Toggle","value":true},{"idx":"damage_number_blocked_colors","type":"Toggle","value":true},{"idx":"esp_distance_animate","type":"Toggle","value":false},{"idx":"spoofers_me_influencer","type":"Toggle","value":false},{"idx":"world_esp_distance","type":"Toggle","value":false},{"idx":"auto_respawn","type":"Toggle","value":false},{"idx":"damage_number_shadow","type":"Toggle","value":true},{"idx":"auto_vote_map","type":"Toggle","value":false},{"idx":"esp_highlight","type":"Toggle","value":false},{"idx":"world_esp_name_override","type":"Toggle","value":false},{"idx":"custom_text","type":"Toggle","value":false},{"idx":"world_ambient_enabled","type":"Toggle","value":true},{"idx":"spoofers_other_elo","type":"Toggle","value":false},{"idx":"world_colorshift_bottom_enabled","type":"Toggle","value":true},{"idx":"jump_power_enabled","type":"Toggle","value":false},{"idx":"flickbot_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"viewmodel_offset","type":"Toggle","value":true},{"idx":"esp_weapon_override","type":"Toggle","value":false},{"idx":"aimbot_ignore_radius","type":"Toggle","value":false},{"idx":"arm_highlight","type":"Toggle","value":false},{"idx":"flickbot_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"world_esp_name_outline","type":"Toggle","value":true},{"idx":"silentaim_fov_outline","type":"Toggle","value":true},{"idx":"auto_queue","type":"Toggle","value":false},{"idx":"spoofers_other_team","type":"Toggle","value":false},{"idx":"flickbot_targeting_limit_distance","type":"Toggle","value":false},{"idx":"ragebot_default_evasion_spam","type":"Toggle","value":false},{"idx":"aimbot_fov_outline","type":"Toggle","value":true},{"idx":"esp_healthbar","type":"Toggle","value":true},{"idx":"spoofers_other_level","type":"Toggle","value":false},{"idx":"gun_appearance_transparency","type":"Toggle","value":false},{"idx":"world_expose_compensation_enabled","type":"Toggle","value":true},{"idx":"auto_execute","type":"Toggle","value":false},{"idx":"aimbot_fov_fill","type":"Toggle","value":true},{"idx":"world_sun_rays_enabled","type":"Toggle","value":true},{"idx":"esp_box_fill_moving","type":"Toggle","value":false},{"idx":"world_esp_name","type":"Toggle","value":false},{"idx":"aimbot_fov_moving","type":"Toggle","value":true},{"idx":"ragebot_medkit","type":"Toggle","value":false},{"idx":"world_colorshift_top_enabled","type":"Toggle","value":true},{"idx":"slide_speed_enabled","type":"Toggle","value":false},{"idx":"arm_chams","type":"Toggle","value":true},{"idx":"spoofers_me_level","type":"Toggle","value":false},{"idx":"silentaim_targeting_limit_distance","type":"Toggle","value":false},{"idx":"long_jump_enabled","type":"Toggle","value":false},{"idx":"targeting_ignore_protected","type":"Toggle","value":false},{"idx":"silentaim_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"esp_flags_staring","type":"Toggle","value":true},{"idx":"spoofers_me_team","type":"Toggle","value":false},{"idx":"world_fogstart_enabled","type":"Toggle","value":false},{"idx":"flickbot_shoot","type":"Toggle","value":true},{"idx":"aimbot_enabled","type":"Toggle","value":true},{"idx":"aimbot_override","type":"Toggle","value":false},{"idx":"silentaim_fov_moving","type":"Toggle","value":true},{"idx":"crosshair_hide_native","type":"Toggle","value":true},{"idx":"world_camera_fov_enabled","type":"Toggle","value":false},{"idx":"esp_flags_override","type":"Toggle","value":false},{"idx":"esp_limit_distance","type":"Toggle","value":false},{"idx":"NotificationForceColors","type":"Toggle","value":false},{"idx":"world_camera_blur_enabled","type":"Toggle","value":false},{"idx":"KeybindMenu","type":"Toggle","value":true},{"idx":"world_esp_name_animate","type":"Toggle","value":false},{"idx":"kill_sound_enabled","type":"Toggle","value":false},{"idx":"world_texture_packs_enabled","type":"Toggle","value":false},{"idx":"custom_text_outline","type":"Toggle","value":true},{"idx":"spoofers_me_employee","type":"Toggle","value":false},{"idx":"esp_include_team","type":"Toggle","value":true},{"idx":"silentaim_ignore_radius","type":"Toggle","value":false},{"idx":"esp_flags","type":"Toggle","value":false},{"idx":"auto_heal","type":"Toggle","value":false},{"idx":"auto_loadout","type":"Toggle","value":false},{"idx":"spoofers_me_winstreak","type":"Toggle","value":false},{"idx":"tripmine_team_trigger","type":"Toggle","value":false},{"idx":"third_person_enabled","type":"Toggle","value":false},{"idx":"esp_override_color","type":"Toggle","value":false},{"idx":"spoofers_other_status","type":"Toggle","value":false},{"idx":"tripmine_trigger","type":"Toggle","value":false},{"idx":"targeting_limit_distance","type":"Toggle","value":false},{"idx":"auto_ammo","type":"Toggle","value":false},{"idx":"auto_ban","type":"Toggle","value":false},{"idx":"esp_box_glow_moving","type":"Toggle","value":true},{"idx":"flickbot_override","type":"Toggle","value":false},{"idx":"mod_detector","type":"Toggle","value":false},{"idx":"item_chams_strip_textures","type":"Toggle","value":false},{"idx":"arcade_autofarm","type":"Toggle","value":false},{"idx":"custom_tracer_expand","type":"Toggle","value":true},{"idx":"infinite_double_jumps","type":"Toggle","value":false},{"idx":"item_highlight","type":"Toggle","value":false},{"idx":"animation_enabled","type":"Toggle","value":false},{"idx":"disable_game_tracers","type":"Toggle","value":true},{"idx":"esp_ammo_outline","type":"Toggle","value":true},{"idx":"silentaim_fov_fill","type":"Toggle","value":true},{"idx":"custom_tracers","type":"Toggle","value":true},{"idx":"kill_notifications","type":"Toggle","value":true},{"idx":"hit_notifications","type":"Toggle","value":false},{"idx":"esp_override","type":"Toggle","value":false},{"idx":"silentaim_targeting_full_360","type":"Toggle","value":false},{"idx":"damage_number_head_colors","type":"Toggle","value":true},{"idx":"damage_number_stack","type":"Toggle","value":true},{"idx":"disable_game_damage_numbers","type":"Toggle","value":true},{"idx":"damage_numbers","type":"Toggle","value":true},{"idx":"arm_appearance_transparency","type":"Toggle","value":false},{"idx":"item_chams","type":"Toggle","value":true},{"idx":"gun_appearance_material","type":"Toggle","value":true},{"idx":"aimbot_targeting_visible_only","type":"Toggle","value":true},{"idx":"ragebot_anti_knife","type":"Toggle","value":false},{"idx":"esp_flags_deflecting","type":"Toggle","value":true},{"idx":"weapon_always_backstab","type":"Toggle","value":false},{"idx":"ammo_indicator","type":"Toggle","value":true},{"idx":"crosshair_outline","type":"Toggle","value":true},{"idx":"aimbot_targeting_ignore_protected","type":"Toggle","value":false},{"idx":"world_ambience_enabled","type":"Toggle","value":true},{"idx":"arm_appearance_material","type":"Toggle","value":false},{"idx":"world_global_shadows_enabled","type":"Toggle","value":true},{"idx":"arm_appearance_color","type":"Toggle","value":true},{"idx":"spoofers_other_influencer","type":"Toggle","value":false},{"idx":"esp_name","type":"Toggle","value":true},{"idx":"flickbot_targeting_visible_only","type":"Toggle","value":true},{"idx":"arm_appearance","type":"Toggle","value":false},{"idx":"gun_appearance_wireframe","type":"Toggle","value":true},{"idx":"world_fogend_enabled","type":"Toggle","value":false},{"idx":"gun_appearance_color","type":"Toggle","value":false},{"idx":"esp_box_moving","type":"Toggle","value":true},{"idx":"hit_effects_enabled","type":"Toggle","value":true},{"idx":"triggerbot_enabled","type":"Toggle","value":false},{"idx":"hit_sounds","type":"Toggle","value":true},{"idx":"ragebot_riot_shield","type":"Toggle","value":false},{"idx":"spoofers_me_elo","type":"Toggle","value":false},{"idx":"world_weather_enabled","type":"Toggle","value":true},{"idx":"auto_slide_enabled","type":"Toggle","value":false},{"idx":"double_jump_power_enabled","type":"Toggle","value":false},{"idx":"fake_pos","type":"Toggle","value":false},{"idx":"auto_strafe_enabled","type":"Toggle","value":false},{"idx":"world_bloom_enabled","type":"Toggle","value":true},{"idx":"custom_text_animate","type":"Toggle","value":false},{"idx":"silentaim_targeting_visible_only","type":"Toggle","value":true},{"idx":"targeting_visible_only","type":"Toggle","value":true},{"idx":"walk_speed_enabled","type":"Toggle","value":false},{"idx":"weapon_full_auto","type":"Toggle","value":false},{"idx":"world_weather_heavy_rain_lightning_enabled","type":"Toggle","value":true},{"idx":"esp_skeleton","type":"Toggle","value":false},{"idx":"esp_distance_outline","type":"Toggle","value":true},{"idx":"world_brightness_enabled","type":"Toggle","value":false},{"idx":"ragebot_anti_aim_underground","type":"Toggle","value":false},{"idx":"esp_flags_animate","type":"Toggle","value":false},{"idx":"ragebot_melee_evasion_spam","type":"Toggle","value":false},{"idx":"esp_override_material","type":"Toggle","value":false},{"idx":"silentaim_enabled","type":"Toggle","value":true},{"idx":"aimbot_showfov","type":"Toggle","value":true},{"idx":"world_atmosphere_enabled","type":"Toggle","value":true},{"idx":"esp_flags_health","type":"Toggle","value":true},{"idx":"auto_execute_silent","type":"Toggle","value":false},{"idx":"esp_ammo_animate","type":"Toggle","value":false},{"idx":"esp_name_outline","type":"Toggle","value":true},{"idx":"esp_weapon_animate","type":"Toggle","value":true},{"idx":"ragebot_anti_aim_random_angle","type":"Toggle","value":false},{"idx":"flickbot_enabled","type":"Toggle","value":false},{"idx":"ragebot_character_origin","type":"Toggle","value":false},{"idx":"esp_weapon_outline","type":"Toggle","value":true},{"idx":"esp_weapon","type":"Toggle","value":true},{"idx":"crosshair_dot","type":"Toggle","value":false},{"idx":"esp_name_override","type":"Toggle","value":false},{"idx":"esp_ammo","type":"Toggle","value":false},{"idx":"crosshair_enabled","type":"Toggle","value":true},{"idx":"spoofers_other_employee","type":"Toggle","value":false},{"idx":"esp_distance","type":"Toggle","value":false},{"idx":"aimbot_targeting_limit_distance","type":"Toggle","value":false},{"idx":"world_clocktime_enabled","type":"Toggle","value":true},{"idx":"esp_box_fill","type":"Toggle","value":true},{"idx":"silentaim_override","type":"Toggle","value":false},{"idx":"esp_box","type":"Toggle","value":true},{"idx":"world_camera_aspect_enabled","type":"Toggle","value":false},{"idx":"world_esp_icon","type":"Toggle","value":false},{"idx":"world_esp_distance_override","type":"Toggle","value":false},{"idx":"world_esp_distance_outline","type":"Toggle","value":true},{"idx":"weapon_no_spread","type":"Toggle","value":false},{"idx":"world_esp_distance_animate","type":"Toggle","value":false},{"idx":"world_fogcolor_enabled","type":"Toggle","value":false},{"idx":"world_esp_limit_distance","type":"Toggle","value":false},{"idx":"perf_quality","type":"Toggle","value":false},{"idx":"targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"aimbot_targeting_disable_on_flash","type":"Toggle","value":false},{"idx":"ragebot_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"triggerbot_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"crosshair_top_color","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"spoofers_other_target","type":"Dropdown"},{"idx":"spoofers_emotes","type":"Input","text":""},{"idx":"ammo_offset_x","type":"Slider","value":"0"},{"idx":"world_skybox_custom_file_up","type":"Dropdown"},{"idx":"damage_number_head_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_box_outline_color","type":"ColorPicker","transparency":0,"value":"5a4a10"},{"idx":"esp_box_fill_type","type":"Dropdown","value":"connected"},{"idx":"esp_weapon_rotation","type":"Slider","value":"0"},{"idx":"custom_tracer_you_color","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"aimbot_fov_rotation","type":"Slider","value":"0"},{"idx":"esp_distance_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_healthbar_spacing","type":"Slider","value":"3"},{"idx":"viewmodel_override_x","type":"Slider","value":"0"},{"idx":"world_esp_name_shimmer_speed","type":"Slider","value":"1"},{"idx":"loadout_melee","type":"Dropdown","value":"Battle Axe"},{"idx":"ragebot_weapon","type":"Dropdown","value":"primary"},{"idx":"arcade_max_deaths","type":"Slider","value":"5"},{"idx":"aimbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"disable_effects","type":"Dropdown","mutli":true,"value":{"scope overlay":true,"vignette":true}},{"idx":"world_weather_heavy_rain_height","type":"Slider","value":"130"},{"idx":"world_weather_snow_transparency","type":"Slider","value":"1"},{"idx":"silentaim_fov_position","type":"Dropdown"},{"idx":"esp_box_color_start","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_weapon_position","type":"Dropdown","value":"down"},{"idx":"esp_weapon_spacing","type":"Slider","value":"4"},{"idx":"ragebot_smart_oob_distance","type":"Slider","value":"3"},{"idx":"world_bloom_threshold","type":"Slider","value":"0.85"},{"idx":"world_skybox_custom_file_left","type":"Dropdown"},{"idx":"esp_override_material_value","type":"Dropdown","value":"ForceField"},{"idx":"ragebot_orbit_radius","type":"Slider","value":"10"},{"idx":"world_weather_heavy_rain_lightning_interval_min","type":"Slider","value":"6"},{"idx":"flickbot_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"custom_tracer_enemies_color","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"spoofers_other_winstreak_value","type":"Input","text":"0"},{"idx":"world_skybox_custom_id_front","type":"Input","text":""},{"idx":"ammo_below","type":"Slider","value":"100"},{"idx":"world_colorshift_top_color","type":"ColorPicker","transparency":0,"value":"fff3b8"},{"idx":"targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"world_esp_name_animation","type":"Dropdown","value":"moving rotation"},{"idx":"crosshair_position","type":"Dropdown"},{"idx":"crosshair_spread_min","type":"Slider","value":"4"},{"idx":"esp_distance_spin_speed","type":"Slider","value":"1"},{"idx":"gun_appearance_color_value","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"world_esp_distance_color_end","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"world_esp_name_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_ammo_spacing","type":"Slider","value":"4"},{"idx":"custom_tracer_style","type":"Dropdown","value":"Lightning"},{"idx":"hit_notifications_list","type":"Dropdown","mutli":true,"value":{"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}":true}},{"idx":"esp_distance_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_flags_deflecting_color_end","type":"ColorPicker","transparency":0,"value":"3c5aff"},{"idx":"world_weather_blizzard_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"ragebot_anti_aim_pitch","type":"Dropdown","value":"none"},{"idx":"silentaim_fov_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"e8c64a"},{"idx":"world_skybox_selected","type":"Dropdown","value":"FlamingSunset"},{"idx":"arm_highlight_outline","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_melee_attempts","type":"Slider","value":"1"},{"idx":"world_bloom_intensity","type":"Slider","value":"0.7"},{"idx":"world_weather_heavy_rain_lightning_color_end","type":"ColorPicker","transparency":0,"value":"b4c8ff"},{"idx":"animation_pick","type":"Dropdown","value":"solar system"},{"idx":"triggerbot_targeting_forget_time","type":"Slider","value":"0.5"},{"idx":"hit_effects_color_2","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_flags_text_size","type":"Slider","value":"12"},{"idx":"world_esp_name_type","type":"Dropdown","value":"uppercase"},{"idx":"aimbot_fov_outline_color_start","type":"ColorPicker","transparency":0.3,"value":"f5d04a"},{"idx":"esp_box_thickness","type":"Slider","value":"1"},{"idx":"arm_chams_transparency","type":"Slider","value":"0"},{"idx":"esp_box_fill_rotation_speed","type":"Slider","value":"1"},{"idx":"esp_skeleton_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"damage_number_color_end","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"crosshair_outline_thickness","type":"Slider","value":"1"},{"idx":"world_weather_color_end","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"esp_ammo_ping_pong_speed","type":"Slider","value":"1"},{"idx":"hit_sound_pitch","type":"Slider","value":"1.15"},{"idx":"esp_name_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_ammo_position","type":"Dropdown","value":"down"},{"idx":"world_skybox_custom_id_back","type":"Input","text":""},{"idx":"custom_text_color_3","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"viewmodel_override_yaw","type":"Slider","value":"0"},{"idx":"world_esp_name_rotation","type":"Slider","value":"0"},{"idx":"esp_box_fill_rotation","type":"Slider","value":"90"},{"idx":"world_skybox_custom_id_right","type":"Input","text":""},{"idx":"item_highlight_fill","type":"ColorPicker","transparency":0.5,"value":"e6b84a"},{"idx":"esp_flags_prefix","type":"Dropdown","value":"full"},{"idx":"crosshair_spread_speed","type":"Slider","value":"0.5"},{"idx":"esp_skeleton_color_middle","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_skybox_custom_file_down","type":"Dropdown"},{"idx":"ammo_color_1","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"ragebot_adaptive_period","type":"Slider","value":"4"},{"idx":"world_weather_color_start","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"silentaim_fov_rotation","type":"Slider","value":"0"},{"idx":"animation_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"world_bloom_size","type":"Slider","value":"30"},{"idx":"flickbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"crosshair_bottom_color","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"aimbot_fov_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"e8c64a"},{"idx":"esp_highlight_fill","type":"ColorPicker","transparency":0.75,"value":"ffec80"},{"idx":"viewmodel_override_roll","type":"Slider","value":"0"},{"idx":"crosshair_color_anim","type":"Dropdown","value":"pingpong"},{"idx":"long_jump_force","type":"Slider","value":"60"},{"idx":"esp_name_text_size","type":"Slider","value":"12"},{"idx":"world_ambience_custom_data","type":"Input","text":"[]"},{"idx":"world_esp_icon_size","type":"Slider","value":"100"},{"idx":"flickbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"world_weather_heavy_rain_width","type":"Slider","value":"0.05"},{"idx":"aimbot_fov_color_end","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"custom_tracer_spring_damper","type":"Slider","value":"0.7"},{"idx":"world_texture_packs_selected","type":"Dropdown","value":"minecraft"},{"idx":"ragebot_medkit_mode","type":"Dropdown","value":"quick heal"},{"idx":"ragebot_melee_mode","type":"Dropdown","value":"normal"},{"idx":"silentaim_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"world_ambience_selected","type":"Dropdown","value":"Windy Day"},{"idx":"ragebot_default_evade_time","type":"Slider","value":"0.1"},{"idx":"esp_distance_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_ammo_items","type":"Dropdown","mutli":true,"value":{"reserve":true,"ammo":true}},{"idx":"disable_anims","type":"Dropdown","mutli":true,"value":{"muzzle flash":true,"sway":true,"equip":true,"idle":true,"aim":true}},{"idx":"silentaim_fov_outline_color_end","type":"ColorPicker","transparency":0.3,"value":"f5d04a"},{"idx":"esp_healthbar_slices","type":"Slider","value":"1"},{"idx":"kill_notifications_list","type":"Dropdown","mutli":true,"value":{"Killed {NAME}":true,"Fucked {NAME}":true,"Raped {NAME}":true,"Destroyed {NAME}":true}},{"idx":"world_esp_name_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_distance_animation","type":"Dropdown","value":"moving rotation"},{"idx":"world_weather_selected","type":"Dropdown","value":"Snow"},{"idx":"ammo_color_2","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"world_weather_snow_rate","type":"Slider","value":"0.6"},{"idx":"flickbot_curvature","type":"Slider","value":"12"},{"idx":"esp_ammo_spin_speed","type":"Slider","value":"1"},{"idx":"esp_distance_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_skybox_custom_file_front","type":"Dropdown"},{"idx":"world_esp_distance_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_esp_name_font","type":"Dropdown","value":"Tahoma"},{"idx":"ragebot_anti_aim_yaw","type":"Dropdown","value":"none"},{"idx":"silentaim_targeting_max_distance","type":"Slider","value":"150"},{"idx":"esp_name_shimmer_color","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"custom_tracer_teammates_color","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"aimbot_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"crosshair_outline_color","type":"ColorPicker","transparency":0,"value":"5a4a10"},{"idx":"esp_override_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_weather_rain_height","type":"Slider","value":"60"},{"idx":"world_weather_rain_length","type":"Slider","value":"4"},{"idx":"esp_ammo_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_adaptive_on","type":"Slider","value":"2"},{"idx":"world_weather_rain_rate","type":"Slider","value":"10"},{"idx":"crosshair_color_2","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"esp_distance_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_knife_speed","type":"Slider","value":"2.4"},{"idx":"ragebot_spiral_rate","type":"Slider","value":"0.5"},{"idx":"esp_flags_shimmer_speed","type":"Slider","value":"1"},{"idx":"flickbot_duration","type":"Slider","value":"110"},{"idx":"spoofers_unlocked","type":"Input","text":""},{"idx":"world_sun_rays_intensity","type":"Slider","value":"0.25"},{"idx":"custom_text_shimmer_speed","type":"Slider","value":"1"},{"idx":"esp_flags_rotation","type":"Slider","value":"0"},{"idx":"esp_box_glow_color_middle","type":"ColorPicker","transparency":0.85,"value":"fff3a0"},{"idx":"damage_number_blocked_color_middle","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"aimbot_targeting_forget_time","type":"Slider","value":"1"},{"idx":"world_explore_compensation","type":"Slider","value":"-0.8"},{"idx":"crosshair_thickness","type":"Slider","value":"2"},{"idx":"hit_sound_head","type":"Dropdown","value":"Sparkle"},{"idx":"kill_notifications_data","type":"Input","text":"{\"formats\":[\"Killed {NAME}\",\"Fucked {NAME}\",\"Destroyed {NAME}\",\"Raped {NAME}\"],\"selected\":{\"Killed {NAME}\":true,\"Fucked {NAME}\":true,\"Raped {NAME}\":true,\"Destroyed {NAME}\":true}}"},{"idx":"ragebot_shoot_frames","type":"Slider","value":"1"},{"idx":"world_esp_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_skeleton_color_start","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"esp_box_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_box_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"aimbot_smoothing","type":"Slider","value":"35"},{"idx":"world_atmosphere_glare","type":"Slider","value":"2"},{"idx":"viewmodel_override_z","type":"Slider","value":"-0.2"},{"idx":"world_esp_distance_ping_pong_speed","type":"Slider","value":"1"},{"idx":"world_weather_rain_transparency","type":"Slider","value":"0.6"},{"idx":"custom_tracer_width","type":"Slider","value":"0.05"},{"idx":"silentaim_fov_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"ragebot_random_range","type":"Slider","value":"0.5"},{"idx":"esp_flags_staring_color_end","type":"ColorPicker","transparency":0,"value":"c81e1e"},{"idx":"infinite_double_jumps_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"esp_healthbar_color_middle","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_weapon_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"ragebot_melee_attack_time","type":"Slider","value":"0.2"},{"idx":"world_esp_distance_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_flags_ping_pong_speed","type":"Slider","value":"1"},{"idx":"flickbot_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"world_atmosphere_haze","type":"Slider","value":"1.5"},{"idx":"ragebot_preset_name","type":"Input","text":""},{"idx":"targeting_max_distance","type":"Slider","value":"150"},{"idx":"world_esp_name_color_middle","type":"ColorPicker","transparency":0,"value":"e1c8ff"},{"idx":"aimbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"world_weather_heavy_rain_lightning_color_start","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_highlight_outline","type":"ColorPicker","transparency":0.4,"value":"fff8c4"},{"idx":"damage_number_rise","type":"Slider","value":"3"},{"idx":"silentaim_targeting_forget_time","type":"Slider","value":"1"},{"idx":"arm_appearance_color_value","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"world_weather_snow_size","type":"Slider","value":"0.5"},{"idx":"silentaim_fov_lerp","type":"Slider","value":"0.12"},{"idx":"esp_box_fill_color_start","type":"ColorPicker","transparency":0.86,"value":"ffe680"},{"idx":"ragebot_oob_position_offset","type":"Slider","value":"0"},{"idx":"esp_name_spin_speed","type":"Slider","value":"1"},{"idx":"aimbot_fov_color_middle","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"custom_tracer_glow","type":"Slider","value":"8"},{"idx":"world_fogend","type":"Slider","value":"2200"},{"idx":"world_esp_distance_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"damage_number_out","type":"Dropdown","value":"drift"},{"idx":"world_fogstart","type":"Slider","value":"150"},{"idx":"esp_skeleton_thickness","type":"Slider","value":"1"},{"idx":"esp_flags_deflecting_color_middle","type":"ColorPicker","transparency":0,"value":"50a0ff"},{"idx":"spoofers_me_elo_value","type":"Input","text":"3600"},{"idx":"world_weather_rain_area","type":"Slider","value":"130"},{"idx":"world_esp_distance_color_start","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"flickbot_cooldown","type":"Slider","value":"250"},{"idx":"kill_notifications_format","type":"Input","text":""},{"idx":"world_texture_packs_replace","type":"Dropdown","mutli":true,"value":{"textures":true}},{"idx":"damage_number_in","type":"Dropdown","value":"pop"},{"idx":"esp_healthbar_lerp","type":"Slider","value":"0.15"},{"idx":"silentaim_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"world_clocktime","type":"Slider","value":"6.7"},{"idx":"esp_weapon_shimmer_speed","type":"Slider","value":"1"},{"idx":"world_weather_heavy_rain_thunder_volume","type":"Slider","value":"3"},{"idx":"targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"world_weather_heavy_rain_speed","type":"Slider","value":"1"},{"idx":"world_weather_blizzard_rate","type":"Slider","value":"1"},{"idx":"targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"gun_appearance_material_type","type":"Dropdown","value":"Neon"},{"idx":"gun_appearance_transparency_value","type":"Slider","value":"50"},{"idx":"flickbot_settings","type":"Dropdown","mutli":true,"value":{"anti riot shield":true,"anti katana":true}},{"idx":"world_esp_icon_out_lerp","type":"Slider","value":"0.5"},{"idx":"esp_healthbar_type","type":"Dropdown","value":"gradient"},{"idx":"aimbot_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"animation_loop_start","type":"Slider","value":"0"},{"idx":"world_weather_heavy_rain_rate","type":"Slider","value":"35"},{"idx":"world_weather_blizzard_speed","type":"Slider","value":"1"},{"idx":"aimbot_fov_position","type":"Dropdown"},{"idx":"targeting_forget_time","type":"Slider","value":"1"},{"idx":"ban_weapons_second","type":"Dropdown","mutli":true,"value":[]},{"idx":"arm_chams_material","type":"Dropdown","value":"Original"},{"idx":"esp_ammo_animation","type":"Dropdown","value":"moving rotation"},{"idx":"world_esp_icon_mode","type":"Dropdown","value":"fixed"},{"idx":"long_jump_keybind","type":"KeyPicker","key":"...","mode":"Toggle"},{"idx":"ragebot_smart_oob_evade_time","type":"Slider","value":"2"},{"idx":"aimbot_fov_rotation_speed","type":"Slider","value":"0.3"},{"idx":"esp_flags_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_name_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"damage_number_blocked_color_end","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"hit_sound_custom_id_kill","type":"Input","text":""},{"idx":"aimbot_fov_fill_color_start","type":"ColorPicker","transparency":0.9,"value":"ffe680"},{"idx":"world_skybox_custom_id_left","type":"Input","text":""},{"idx":"damage_number_blocked_color_start","type":"ColorPicker","transparency":0,"value":"999999"},{"idx":"walk_speed_multiplier","type":"Slider","value":"3"},{"idx":"crosshair_length","type":"Slider","value":"20"},{"idx":"world_esp_icon_in_lerp","type":"Slider","value":"0.5"},{"idx":"custom_tracer_texture_length","type":"Slider","value":"4"},{"idx":"world_esp_name_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"damage_number_color_middle","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"spoofers_other_elo_value","type":"Input","text":"0"},{"idx":"esp_name_type","type":"Dropdown","value":"username"},{"idx":"animation_loop_end","type":"Slider","value":"100"},{"idx":"triggerbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"esp_distance_shimmer_speed","type":"Slider","value":"1"},{"idx":"crosshair_color_speed","type":"Slider","value":"0.5"},{"idx":"esp_flags_animation","type":"Dropdown","value":"moving rotation"},{"idx":"aimbot_curvature","type":"Slider","value":"12"},{"idx":"ammo_items","type":"Dropdown","mutli":true,"value":{"ammos":true,"max ammos":true}},{"idx":"custom_text_font","type":"Dropdown","value":"Monocraft"},{"idx":"world_esp_name_spacing","type":"Slider","value":"4"},{"idx":"custom_text_color_2","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"silentaim_targeting_reaction_time","type":"Slider","value":"0"},{"idx":"spoofers_locked","type":"Input","text":""},{"idx":"crosshair_dot_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_weather_snow_spread","type":"Slider","value":"1.2"},{"idx":"world_weather_snow_speed","type":"Slider","value":"0.5"},{"idx":"esp_weapon_animation","type":"Dropdown","value":"shimmer"},{"idx":"ammo_outline_color","type":"ColorPicker","transparency":0,"value":"5a4a10"},{"idx":"silentaim_fov_outline_color_middle","type":"ColorPicker","transparency":0.3,"value":"ffec80"},{"idx":"custom_text_offset_y","type":"Slider","value":"20"},{"idx":"esp_weapon_shimmer_color","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"arm_appearance_color_mode","type":"Dropdown","value":"tint"},{"idx":"esp_weapon_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_weapon_ping_pong_speed","type":"Slider","value":"1"},{"idx":"esp_box_glow_color_start","type":"ColorPicker","transparency":0.8,"value":"fff3a0"},{"idx":"custom_text_offset_x","type":"Slider","value":"0"},{"idx":"esp_name_rotation","type":"Slider","value":"90"},{"idx":"esp_text_size","type":"Slider","value":"12"},{"idx":"crosshair_left_color","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"hit_sound_custom_source_head","type":"Dropdown","value":"roblox asset id"},{"idx":"world_esp_name_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"weapon_grenade_options","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_camera_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_weather_heavy_rain_length","type":"Slider","value":"4"},{"idx":"arcade_min_players","type":"Slider","value":"4"},{"idx":"world_ambience_custom_source","type":"Dropdown","value":"roblox asset id"},{"idx":"long_jump_upward","type":"Slider","value":"20"},{"idx":"ban_weapons_first","type":"Dropdown","mutli":true,"value":[]},{"idx":"world_brightness","type":"Slider","value":"2.4"},{"idx":"esp_healthbar_color_end","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"hit_sound_volume","type":"Slider","value":"0.8"},{"idx":"esp_max_distance","type":"Slider","value":"500"},{"idx":"damage_number_head_color_start","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_anti_aim_min_speed","type":"Slider","value":"10"},{"idx":"esp_ammo_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"custom_text_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_oob_position","type":"Dropdown","value":"down"},{"idx":"ragebot_spiral_radius","type":"Slider","value":"10"},{"idx":"third_person_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"targeting_reaction_time","type":"Slider","value":"0"},{"idx":"esp_distance_spacing","type":"Slider","value":"3"},{"idx":"silentaim_fov_fill_color_start","type":"ColorPicker","transparency":0.9,"value":"ffe680"},{"idx":"esp_name_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"ragebot_shot_interval","type":"Slider","value":"70"},{"idx":"esp_box_glow_rotation","type":"Slider","value":"0"},{"idx":"kill_sound","type":"Dropdown","value":"Sparkle"},{"idx":"spoofers_me_level_value","type":"Input","text":"999"},{"idx":"esp_name_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"arm_appearance_color_tint","type":"Slider","value":"30"},{"idx":"esp_name_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_esp_max_distance","type":"Slider","value":"200"},{"idx":"ragebot_preset_list","type":"Dropdown","value":"Default"},{"idx":"world_weather_heavy_rain_area","type":"Slider","value":"400"},{"idx":"spoofers_weapons","type":"Input","text":""},{"idx":"world_skybox_disable","type":"Dropdown","mutli":true,"value":[]},{"idx":"kill_sound_pitch","type":"Slider","value":"0.9"},{"idx":"ragebot_resolver","type":"Dropdown","value":"switch if no reserve"},{"idx":"long_jump_mode","type":"Dropdown","value":"forward"},{"idx":"aimbot_targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"ragebot_medkit_health","type":"Slider","value":"50"},{"idx":"damage_number_drift","type":"Slider","value":"3"},{"idx":"world_cc_brightness","type":"Slider","value":"0.02"},{"idx":"esp_ammo_font","type":"Dropdown","value":"Tahoma"},{"idx":"silentaim_fov","type":"Slider","value":"110"},{"idx":"hit_sound_custom_file_kill","type":"Dropdown"},{"idx":"world_weather_blizzard_spread","type":"Slider","value":"1"},{"idx":"esp_ammo_color_end","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"esp_ammo_text_size","type":"Slider","value":"12"},{"idx":"KeybindMenuMode","type":"Dropdown","value":"Toggled"},{"idx":"world_weather_heavy_rain_lightning_interval_max","type":"Slider","value":"15"},{"idx":"esp_box_fill_color_middle","type":"ColorPicker","transparency":0.9,"value":"e8c64a"},{"idx":"world_weather_color_middle","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"world_esp_name_text_size","type":"Slider","value":"13"},{"idx":"ragebot_evasion","type":"Dropdown","value":"random"},{"idx":"ragebot_flicker_glue","type":"Slider","value":"0.14"},{"idx":"vote_maps","type":"Dropdown","mutli":true,"value":[]},{"idx":"NotificationForcedText","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"NotificationForcedOutline","type":"ColorPicker","transparency":0,"value":"1f1f1f"},{"idx":"world_esp_icon_in_anim","type":"Dropdown","value":"scale"},{"idx":"world_texture_packs_time","type":"Dropdown","value":"day"},{"idx":"world_esp_distance_spin_speed","type":"Slider","value":"1"},{"idx":"world_ambient_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"silentaim_fov_rotation_speed","type":"Slider","value":"0.1"},{"idx":"esp_name_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_esp_distance_position","type":"Dropdown","value":"down"},{"idx":"animation_custom_id","type":"Input","text":""},{"idx":"world_atmosphere_glare_color","type":"ColorPicker","transparency":0,"value":"ffe680"},{"idx":"spoofers_other_status_value","type":"Dropdown","value":"Prime"},{"idx":"custom_tracer_lifetime","type":"Slider","value":"0.6"},{"idx":"item_chams_material","type":"Dropdown","value":"Neon"},{"idx":"KeybindMenuTransparency","type":"Slider","value":"100"},{"idx":"esp_healthbar_color_start","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"esp_fixed_width","type":"Slider","value":"100"},{"idx":"crosshair_gap","type":"Slider","value":"4"},{"idx":"jump_power_multiplier","type":"Slider","value":"1.5"},{"idx":"esp_weapon_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"esp_flags_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"MenuKeybind","type":"KeyPicker","key":"RightShift","mode":"Toggle"},{"idx":"kill_sound_volume","type":"Slider","value":"0.9"},{"idx":"hit_sound_custom_source_kill","type":"Dropdown","value":"roblox asset id"},{"idx":"crosshair_rotate_speed","type":"Slider","value":"90"},{"idx":"hit_sound_custom_file_head","type":"Dropdown"},{"idx":"hit_sound_custom_id_head","type":"Input","text":""},{"idx":"world_colorshift_bottom_color","type":"ColorPicker","transparency":0,"value":"e0ac00"},{"idx":"hit_sound_custom_file_body","type":"Dropdown"},{"idx":"esp_distance_text_size","type":"Slider","value":"12"},{"idx":"hit_sound_custom_id_body","type":"Input","text":""},{"idx":"custom_text_size","type":"Slider","value":"11"},{"idx":"world_skybox_custom_source","type":"Dropdown","value":"roblox asset ids"},{"idx":"hit_sound_custom_source_body","type":"Dropdown","value":"roblox asset id"},{"idx":"hit_sound_body","type":"Dropdown","value":"Sparkle"},{"idx":"loadout_utility","type":"Dropdown","value":"Flashbang"},{"idx":"loadout_secondary","type":"Dropdown","value":"Daggers"},{"idx":"loadout_primary","type":"Dropdown","value":"Assault Rifle"},{"idx":"queue_mode","type":"Dropdown","value":"1v1"},{"idx":"world_camera_fov","type":"Slider","value":"90"},{"idx":"hit_effects_color_3","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"world_esp_icon_in_fade","type":"Slider","value":"0.2"},{"idx":"mod_actions","type":"Dropdown","mutli":true,"value":{"server hop":true,"notification":true}},{"idx":"world_skybox_custom_data","type":"Input","text":"[]"},{"idx":"webhook_events","type":"Dropdown","mutli":true,"value":[]},{"idx":"discord_webhook","type":"Input","text":""},{"idx":"crosshair_dot_size","type":"Slider","value":"2"},{"idx":"world_weather_heavy_rain_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"esp_flags_health_color_start","type":"ColorPicker","transparency":0,"value":"78ff78"},{"idx":"item_highlight_outline","type":"ColorPicker","transparency":0,"value":"e6b84a"},{"idx":"custom_tracer_fade","type":"Slider","value":"0.35"},{"idx":"custom_tracer_texture_speed","type":"Slider","value":"1"},{"idx":"world_esp_distance_rotation","type":"Slider","value":"0"},{"idx":"esp_name_spacing","type":"Slider","value":"6"},{"idx":"world_esp_distance_shimmer_speed","type":"Slider","value":"1"},{"idx":"esp_distance_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"damage_number_size","type":"Slider","value":"24"},{"idx":"damage_number_font","type":"Dropdown","value":"Burbank-Big-Condensed"},{"idx":"esp_box_rotation_speed","type":"Slider","value":"0.25"},{"idx":"damage_number_head_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"slide_speed_multiplier","type":"Slider","value":"10"},{"idx":"damage_number_color_start","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"ammo_size","type":"Slider","value":"11"},{"idx":"heal_below","type":"Slider","value":"100"},{"idx":"esp_distance_rotation","type":"Slider","value":"0"},{"idx":"hit_notifications_data","type":"Input","text":"{\"formats\":[\"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}\"],\"selected\":{\"Hitted {DMG} Damage on {NAME}'s {PART} using {WEAPON}\":true}}"},{"idx":"esp_healthbar_width","type":"Slider","value":"2"},{"idx":"hit_effects_color_1","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"hit_sound_custom_data","type":"Input","text":"[]"},{"idx":"triggerbot_targeting_reaction_offset","type":"Slider","value":"0"},{"idx":"world_weather_rain_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"gun_appearance_color_tint","type":"Slider","value":"32"},{"idx":"custom_text_ping_pong_speed","type":"Slider","value":"1"},{"idx":"custom_text_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_skeleton_color_end","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"third_person_distance","type":"Slider","value":"7.5"},{"idx":"custom_text_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"crosshair_spread_max","type":"Slider","value":"16"},{"idx":"world_esp_name_color_start","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"animation_speed","type":"Slider","value":"1"},{"idx":"custom_text_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_icon_out_anim","type":"Dropdown","value":"fade"},{"idx":"lua_saved","type":"Input","text":""},{"idx":"esp_font","type":"Dropdown","value":"Tahoma"},{"idx":"flickbot_targeting_max_distance","type":"Slider","value":"150"},{"idx":"aimbot_humanness","type":"Slider","value":"30"},{"idx":"world_skybox_custom_id_up","type":"Input","text":""},{"idx":"world_ambience_custom_id","type":"Input","text":""},{"idx":"silentaim_fov_outline_color_start","type":"ColorPicker","transparency":0.3,"value":"f5d04a"},{"idx":"esp_box_fill_color_end","type":"ColorPicker","transparency":0.85,"value":"5a4a10"},{"idx":"fly_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"esp_name_shimmer_speed","type":"Slider","value":"0.7"},{"idx":"esp_distance_position","type":"Dropdown","value":"down"},{"idx":"custom_text_input","type":"Input","text":"Elite Zone"},{"idx":"noclip_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"auto_strafe_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"custom_text_color_1","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"ragebot_base_radius","type":"Slider","value":"100"},{"idx":"esp_flags_health_color_end","type":"ColorPicker","transparency":0,"value":"ff4646"},{"idx":"ammo_offset_y","type":"Slider","value":"0"},{"idx":"world_esp_distance_animation","type":"Dropdown","value":"moving rotation"},{"idx":"hit_effects_list","type":"Dropdown","mutli":true,"value":{"Stars":true,"Aura":true}},{"idx":"ammo_font","type":"Dropdown","value":"Monocraft"},{"idx":"ammo_color_3","type":"ColorPicker","transparency":0,"value":"f5d04a"},{"idx":"esp_weapon_color_end","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"world_camera_blur_intensity","type":"Slider","value":"24"},{"idx":"esp_ammo_color_middle","type":"ColorPicker","transparency":0,"value":"e1c8ff"},{"idx":"silentaim_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"world_weather_heavy_rain_transparency","type":"Slider","value":"0.65"},{"idx":"aimbot_fov_outline_color_end","type":"ColorPicker","transparency":0.3,"value":"f5d04a"},{"idx":"custom_text_outline_color","type":"ColorPicker","transparency":0,"value":"000000"},{"idx":"world_skybox_custom_id_down","type":"Input","text":""},{"idx":"crosshair_color_1","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_highlight_pulse_speed","type":"Slider","value":"2"},{"idx":"long_jump_offset","type":"Slider","value":"8"},{"idx":"aimbot_fov_outline_color_middle","type":"ColorPicker","transparency":0.3,"value":"ffec80"},{"idx":"esp_ammo_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"crosshair_animate","type":"Dropdown","mutli":true,"value":{"rotate":true}},{"idx":"world_esp_distance_text_size","type":"Slider","value":"13"},{"idx":"ragebot_anti_aim_max_speed","type":"Slider","value":"20"},{"idx":"arcade_death_window","type":"Slider","value":"60"},{"idx":"crosshair_right_color","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"esp_ammo_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_box_glow_color_end","type":"ColorPicker","transparency":0.8,"value":"fff3a0"},{"idx":"esp_override_color_value","type":"ColorPicker","transparency":0,"value":"00dcff"},{"idx":"flickbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"randomize_items","type":"Dropdown","mutli":true,"value":{"skins":true,"wraps":true,"charms":true,"finishers":true}},{"idx":"arm_appearance_transparency_value","type":"Slider","value":"50"},{"idx":"esp_weapon_text_size","type":"Slider","value":"12"},{"idx":"arm_appearance_material_type","type":"Dropdown","value":"ForceField"},{"idx":"world_esp_name_color_end","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"ragebot_smart_oob_patience","type":"Slider","value":"3"},{"idx":"world_esp_distance_color_middle","type":"ColorPicker","transparency":0,"value":"e1c8ff"},{"idx":"world_weather_blizzard_size","type":"Slider","value":"1"},{"idx":"ragebot_default_attack_time","type":"Slider","value":"0.15"},{"idx":"world_atmosphere_offset","type":"Slider","value":"0.4"},{"idx":"esp_name_position","type":"Dropdown","value":"up"},{"idx":"gun_appearance_wireframe_width","type":"Slider","value":"0.0025"},{"idx":"gun_appearance_color_mode","type":"Dropdown","value":"tint"},{"idx":"spoofers_other_level_value","type":"Input","text":"0"},{"idx":"viewmodel_override_pitch","type":"Slider","value":"0"},{"idx":"NotificationForcedAccent","type":"ColorPicker","transparency":0,"value":"4777b6"},{"idx":"world_ambience_custom_file","type":"Dropdown"},{"idx":"aimbot_fov_fill_color_end","type":"ColorPicker","transparency":0.9,"value":"5a4a10"},{"idx":"silentaim_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"viewmodel_override_y","type":"Slider","value":"0"},{"idx":"ragebot_flicker_window","type":"Slider","value":"0.16"},{"idx":"arcade_mode","type":"Dropdown","value":"free for all"},{"idx":"world_esp_distance_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"esp_flags_staring_color_middle","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"targeting_sniper_part","type":"Dropdown","mutli":true,"value":{"HitboxHeadSmall":true,"HitboxBodySmall":true}},{"idx":"esp_ammo_shimmer_speed","type":"Slider","value":"1"},{"idx":"world_sun_rays_spread","type":"Slider","value":"1"},{"idx":"arm_chams_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"world_weather_blizzard_transparency","type":"Slider","value":"1"},{"idx":"item_chams_color","type":"ColorPicker","transparency":0,"value":"ffb400"},{"idx":"world_weather_snow_gradient_type","type":"Dropdown","value":"each particles randomly pick"},{"idx":"triggerbot_targeting_max_distance","type":"Slider","value":"100"},{"idx":"esp_name_ping_pong_speed","type":"Slider","value":"1"},{"idx":"silentaim_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"utility":true}},{"idx":"spoofers_me_status_value","type":"Dropdown","value":"Prime"},{"idx":"ragebot_melee_evade_time","type":"Slider","value":"0.2"},{"idx":"world_weather_rain_width","type":"Slider","value":"0.04"},{"idx":"world_camera_aspect_x","type":"Slider","value":"1"},{"idx":"auto_slide_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"world_ambience_volume","type":"Slider","value":"0.25"},{"idx":"world_esp_distance_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_distance_color_start","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"spoofers_me_winstreak_value","type":"Input","text":"999"},{"idx":"esp_name_animation","type":"Dropdown","value":"shimmer"},{"idx":"spoofers_equipped","type":"Input","text":"{\"Crossbow\":{\"Skin\":{\"Name\":\"Crossbone\"}},\"Grenade Launcher\":{\"Skin\":{\"Name\":\"Skull Launcher\"}},\"Medkit\":{\"Skin\":{\"Name\":\"Medkitty\"}},\"Burst Rifle\":{\"Skin\":{\"Name\":\"Electro Rifle\"}},\"Spear\":{\"Skin\":{\"Name\":\"Thunderpike\"}},\"Flashbang\":{\"Skin\":{\"Name\":\"Sol\"}},\"Energy Pistols\":{\"Skin\":{\"Name\":\"Void Pistols\"}},\"Flamethrower\":{\"Skin\":{\"Name\":\"Lamethrower\"}},\"Paintball Gun\":{\"Skin\":{\"Name\":\"Boba Gun\"}},\"Fists\":{\"Skin\":{\"Name\":\"Pumpkin Claws\"}},\"RPG\":{\"Skin\":{\"Name\":\"Pencil Launcher\"}},\"Grappler\":{\"Skin\":{\"Name\":\"Arcade Claw\"}},\"Scythe\":{\"Skin\":{\"Name\":\"Cryo Scythe\"}},\"Slingshot\":{\"Skin\":{\"Name\":\"Goalpost\"}},\"Battle Axe\":{\"Skin\":{\"Name\":\"Nordic Axe\"}},\"Flare Gun\":{\"Skin\":{\"Name\":\"Pocket Volcano\"}},\"Molotov\":{\"Skin\":{\"Name\":\"Vexed Candle\"}},\"Spray\":{\"Skin\":{\"Name\":\"Campfire Spray\"}},\"Warpstone\":{\"Skin\":{\"Name\":\"Teleport Disc\"}},\"Wildcat\":{\"Skin\":{\"Name\":\"Plasma Wildcat\"}},\"Riot Shield\":{\"Skin\":{\"Name\":\"Energy Shield\"}},\"Assault Rifle\":{\"Wrap\":\"none\",\"Skin\":{\"Name\":\"Drum Gun\"}},\"Exogun\":{\"Skin\":{\"Name\":\"Wondergun\"}},\"War Horn\":{\"Skin\":{\"Name\":\"Air Horn\"}},\"Subspace Tripmine\":{\"Skin\":{\"Name\":\"Glorious Subspace Tripmine\"}},\"Shorty\":{\"Skin\":{\"Name\":\"Demon Shorty\"}},\"Distortion\":{\"Skin\":{\"Name\":\"Plasma Distortion\"}},\"Satchel\":{\"Skin\":{\"Name\":\"Bag o' Money\"}},\"Knife\":{\"Skin\":{\"Name\":\"Keyrambit\"}},\"Chainsaw\":{\"Skin\":{\"Name\":\"Handsaws\"}},\"Warper\":{\"Skin\":{\"Name\":\"Electropunk Warper\"}},\"Jump Pad\":{\"Skin\":{\"Name\":\"Spider Web\"}},\"Grenade\":{\"Skin\":{\"Name\":\"Water Balloon\"}},\"Freeze Ray\":{\"Skin\":{\"Name\":\"Temporal Ray\"}},\"Trowel\":{\"Skin\":{\"Name\":\"Paintbrush\"}},\"Handgun\":{\"Skin\":{\"Name\":\"Blaster\"}},\"Energy Rifle\":{\"Skin\":{\"Name\":\"Void Rifle\"}},\"Minigun\":{\"Skin\":{\"Name\":\"Shark Minigun\"}},\"Shotgun\":{\"Skin\":{\"Name\":\"Broomstick\"}},\"Maul\":{\"Skin\":{\"Name\":\"Starforge Maul\"}},\"Uzi\":{\"Skin\":{\"Name\":\"Demon Uzi\"}},\"Smoke Grenade\":{\"Skin\":{\"Name\":\"Hourglass\"}},\"Sniper\":{\"Skin\":{\"Name\":\"Event Horizon\"}},\"Katana\":{\"Skin\":{\"Name\":\"Crystal Katana\"}},\"Daggers\":{\"Skin\":{\"Name\":\"Crystal Daggers\"}},\"Bow\":{\"Skin\":{\"Name\":\"Raven Bow\"}},\"Permafrost\":{\"Skin\":{\"Name\":\"Temporal Permafrost\"}},\"Revolver\":{\"Skin\":{\"Name\":\"Keyvolver\"}}}"},{"idx":"ragebot_oob_hold","type":"Slider","value":"0.01"},{"idx":"ragebot_knife_radius","type":"Slider","value":"6"},{"idx":"world_esp_text_size","type":"Slider","value":"13"},{"idx":"world_cc_contrast","type":"Slider","value":"0.2"},{"idx":"double_jump_power","type":"Slider","value":"1.5"},{"idx":"world_skybox_custom_file_right","type":"Dropdown"},{"idx":"custom_tracer_players","type":"Dropdown","mutli":true,"value":{"teammates":true,"enemies":true,"you":true}},{"idx":"esp_healthbar_position","type":"Dropdown","value":"left"},{"idx":"custom_tracer_spring_speed","type":"Slider","value":"18"},{"idx":"auto_strafe_speed","type":"Slider","value":"50"},{"idx":"aimbot_fov","type":"Slider","value":"230"},{"idx":"esp_flags_health_color_middle","type":"ColorPicker","transparency":0,"value":"ffe65a"},{"idx":"world_cc_saturation","type":"Slider","value":"0.5"},{"idx":"fly_speed","type":"Slider","value":"100"},{"idx":"ragebot_strafe","type":"Dropdown","value":"default"},{"idx":"ragebot_anti_aim_angle","type":"Dropdown","value":"none"},{"idx":"flickbot_humanness","type":"Slider","value":"30"},{"idx":"triggerbot_targeting_reaction_time","type":"Slider","value":"100"},{"idx":"world_esp_name_position","type":"Dropdown","value":"up"},{"idx":"esp_bound_mode","type":"Dropdown","value":"fixed"},{"idx":"triggerbot_targeting_part","type":"Dropdown","mutli":true,"value":{"HitboxBody":true,"HitboxHead":true}},{"idx":"esp_highlight_mode","type":"Dropdown","mutli":true,"value":{"thru walls":true,"pulse":true}},{"idx":"esp_flags_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_flags_font","type":"Dropdown","value":"Tahoma"},{"idx":"aimbot_fov_color_start","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"spoofers_injected","type":"Input","text":""},{"idx":"world_esp_items","type":"Dropdown","mutli":true,"value":{"flashbang":true,"flare":true,"satchel":true,"tripmine":true,"warpstone":true,"smoke":true,"molotov":true,"grenade":true}},{"idx":"esp_flags_shimmer_color","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"triggerbot_targeting_ignore_if","type":"Dropdown","mutli":true,"value":{"melee":true,"utility":true}},{"idx":"esp_flags_deflecting_color_start","type":"ColorPicker","transparency":0,"value":"8cdcff"},{"idx":"world_atmosphere_density","type":"Slider","value":"0.3"},{"idx":"ragebot_orbit_speed","type":"Slider","value":"2.4"},{"idx":"ragebot_anti_aim_min_angle","type":"Slider","value":"30"},{"idx":"esp_ammo_color_start","type":"ColorPicker","transparency":0,"value":"be96ff"},{"idx":"ragebot_autoload_preset","type":"Input","text":"Default"},{"idx":"esp_flags_staring_color_start","type":"ColorPicker","transparency":0,"value":"ff8282"},{"idx":"triggerbot_targeting_shot_delay","type":"Slider","value":"0"},{"idx":"double_jump_power_keybind","type":"KeyPicker","key":"...","mode":"Always"},{"idx":"ragebot_shooting","type":"Dropdown","value":"hitscan"},{"idx":"aimbot_targeting_max_distance","type":"Slider","value":"150"},{"idx":"spoofers_favourites","type":"Input","text":""},{"idx":"custom_text_rotation","type":"Slider","value":"0"},{"idx":"aimbot_keybind","type":"KeyPicker","key":"...","mode":"Hold"},{"idx":"silentaim_fov_fill_color_end","type":"ColorPicker","transparency":0.9,"value":"5a4a10"},{"idx":"world_esp_name_spin_speed","type":"Slider","value":"1"},{"idx":"world_fogcolor_color","type":"ColorPicker","transparency":0,"value":"fff0a0"},{"idx":"world_skybox_custom_file_back","type":"Dropdown"},{"idx":"world_weather_rain_speed","type":"Slider","value":"4.5"},{"idx":"esp_ammo_rotation","type":"Slider","value":"0"},{"idx":"world_cc_tint_color","type":"ColorPicker","transparency":0,"value":"fffbe0"},{"idx":"silentaim_fov_color_start","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"item_chams_transparency","type":"Slider","value":"0.69"},{"idx":"esp_weapon_ping_pong_main","type":"ColorPicker","transparency":0,"value":"ffffff"},{"idx":"esp_weapon_spin_speed","type":"Slider","value":"1"},{"idx":"world_esp_icon_out_fade","type":"Slider","value":"0.2"},{"idx":"esp_weapon_font","type":"Dropdown","value":"Tahoma"},{"idx":"esp_name_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"esp_weapon_color_start","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"esp_distance_ping_pong_background","type":"ColorPicker","transparency":0,"value":"ff5050"},{"idx":"custom_text_animation","type":"Dropdown","value":"moving rotation"},{"idx":"world_atmosphere_tint_color","type":"ColorPicker","transparency":0,"value":"fff4b8"},{"idx":"arm_highlight_fill","type":"ColorPicker","transparency":0.5,"value":"ffffff"},{"idx":"esp_distance_outline_color","type":"ColorPicker","transparency":0,"value":"5a4a10"},{"idx":"ragebot_presets_data","type":"Input","text":""},{"idx":"ragebot_anti_aim_max_angle","type":"Slider","value":"60"},{"idx":"hit_notifications_format","type":"Input","text":""},{"idx":"esp_box_rotation","type":"Slider","value":"0"},{"idx":"ragebot_smart_oob_release","type":"Slider","value":"0.5"},{"idx":"crosshair_color_3","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"aimbot_fov_lerp","type":"Slider","value":"0.12"},{"idx":"esp_name_color_start","type":"ColorPicker","transparency":0,"value":"ffec80"},{"idx":"ragebot_anti_aim_custom_angle","type":"Slider","value":"0"},{"idx":"esp_box_glow_rotation_speed","type":"Slider","value":"0.2"},{"idx":"damage_number_style","type":"Dropdown","value":"fortnite"},{"idx":"flickbot_shot_delay","type":"Slider","value":"40"},{"idx":"flickbot_targeting_forget_time","type":"Slider","value":"1"},{"idx":"ragebot_last_weapon","type":"Dropdown","value":"none"},{"idx":"silentaim_fov_color_middle","type":"ColorPicker","transparency":0,"value":"fff8c4"},{"idx":"flickbot_targeting_part_engine","type":"Dropdown","value":"closest to character"},{"idx":"triggerbot_targeting_settings","type":"Dropdown","mutli":true,"value":{"anti riot shield":true,"anti katana":true}},{"idx":"world_camera_aspect_y","type":"Slider","value":"1"},{"idx":"ragebot_spiral_speed","type":"Slider","value":"2.4"},{"idx":"world_esp_distance_spacing","type":"Slider","value":"4"}]}]],
}

--[[ Theme Manager ]]

local ThemeManager = {};

do
	ThemeManager.Library = EZ;
	ThemeManager.DefaultTheme = 'Default';

	local NonColorDefaults = {
		Background_Color = '000000';
		Background_Transparency = 0.7;
		Background_Blur = EZ.IsMobile and 0 or 15;
		Background_Contrast = 0;
		Background_Saturation = 0;
		Background_Brightness = 0;

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

		local Path = self.Library.Folder .. '/themes/' .. File;

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

		writefile(self.Library.Folder .. '/themes/' .. File, HttpService:JSONEncode(Data));
	end;

	function ThemeManager:Delete(File)
		if not File then
			return false, 'no theme file is selected';
		end;

		if not File:find('%.json$') then
			File = File .. '.json';
		end;

		local Path = self.Library.Folder .. '/themes/' .. File;

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
		local Files = listfiles(self.Library.Folder .. '/themes');
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
		if not self.Library.IsMobile then
			self:BuildMenuTab(MenuBox:AddTab('Menu'));
		end;
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

			if isfile(self.Library.Folder .. '/themes/' .. Display .. '.json') then
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

return EZ
