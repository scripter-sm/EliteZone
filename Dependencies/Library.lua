getgenv().Library = (function()
local Services = setmetatable({}, {
    __index = function(self, k)
        local ok, res = pcall(game.GetService, game, k)
        if ok and res then rawset(self, k, res) return res end
        return nil
    end
})

local Drawing = (typeof(Drawing) == 'table' and Drawing) or DrawingLib

local ScreenGui  = Instance.new('ScreenGui')
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = ""
ScreenGui.Parent = Services.CoreGui

local IsTouch  = Services.UserInputService.TouchEnabled

local Camera       = workspace.CurrentCamera
local ScreenWidth  = Camera.ViewportSize.X
local ScreenHeight = Camera.ViewportSize.Y

local function S(v)
    return v
end

local Toggles = {}
local Options = {}

local Library = {
    Registry                = {};
    RegistryMap             = {};
    HudRegistry             = {};
    FontColor               = Color3.fromRGB(255, 255, 255);
    MainColor               = Color3.fromRGB(24,  24,  24 );
    BackgroundColor         = Color3.fromRGB(20,  20,  20 );
    AccentColor             = Color3.fromRGB(133, 133, 134);
    OutlineColor            = Color3.fromRGB(31,  31,  31 );
    RiskColor               = Color3.fromRGB(255, 50,  50 );
    Black                   = Color3.new(0, 0, 0);
    Font                    = Enum.Font.Code;
    CustomFontFace          = nil;
    OpenedFrames            = {};
    DependencyBoxes         = {};
    Signals                 = {};
    ThemeScales             = {};
    UIScaleValue            = 1.0;
    ScreenGui               = ScreenGui;
    IsMobile                = false;
    Scale                   = SCALE;
    VisibilityCallbacks     = {};
    IconSizeCallbacks       = {};
    TabResizeCallbacks      = {};
    UseDrawingCursor        = true;
    TextCaseMode            = "none";
    IconSize                = 20;
}

Library.Toggles = Toggles
Library.Options = Options

do
    local LastYield = os.clock()
    function Library:BuildTick()
        if not Library.StreamedBuild then return end
        if os.clock() - LastYield >= 0.006 then
            task.wait()
            LastYield = os.clock()
        end
    end
end

function Library:RegisterVisibilityCallback(fn) table.insert(self.VisibilityCallbacks, fn) end
function Library:RegisterIconSizeCallback(fn) table.insert(self.IconSizeCallbacks, fn) end

Library.CurrentRainbowHue   = 0
Library.CurrentRainbowColor = Color3.fromHSV(0, 0.8, 1)

local function GetPlayersString()
    local t = {}
    for _, p in ipairs(Services.Players:GetPlayers()) do t[#t+1] = p.Name end
    table.sort(t)
    return t
end

local function GetTeamsString()
    local t = {}
    for _, tm in ipairs(Services.Teams:GetTeams()) do t[#t+1] = tm.Name end
    table.sort(t)
    return t
end

Library.TranslateTexts = Library.TranslateTexts or setmetatable({}, { __mode = "k" })
Library.TranslateProps = Library.TranslateProps or setmetatable({}, { __mode = "k" })
Library.TranslateCallbacks = Library.TranslateCallbacks or {}
Library.TextBaseSizes = Library.TextBaseSizes or setmetatable({}, { __mode = "k" })

local function isTextObject(inst)
    return typeof(inst) == "Instance"
        and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox"))
end

local function fontScale(font)
    if font == Enum.Font.Code then return 0.9 end
    if font == Enum.Font.RobotoMono then return 0.92 end
    if font == Enum.Font.GothamBold then return 0.95 end
    if font == Enum.Font.SciFi then return 0.84 end
    if font == Enum.Font.Arcade then return 0.78 end
    if font == Enum.Font.FredokaOne then return 0.86 end
    if font == Enum.Font.Cartoon then return 0.88 end
    return 1
end

function Library:RememberTextSize(inst, size)
    if isTextObject(inst) and type(size) == "number" then
        self.TextBaseSizes[inst] = size
    end
end

function Library:ApplyTextMetrics(inst)
    if not isTextObject(inst) then return end
    local base = self.TextBaseSizes[inst]
    if type(base) ~= "number" then
        base = inst.TextSize
        if type(base) ~= "number" then return end
        self.TextBaseSizes[inst] = base
    end
    local newSize = math.max(8, math.floor(base * fontScale(inst.Font) + 0.5))
    if inst.TextSize ~= newSize then
        inst.TextSize = newSize
    end
end

function Library:NormalizeText(raw)
    return tostring(raw or "")
end

function Library:TranslateString(s)
    return s
end

function Library:SetTRText(lbl, raw)
    if not lbl or type(raw) ~= "string" then
        if lbl and raw == nil then
            raw = ""
        end
    end
    lbl.Text = self:NormalizeText(raw)
end

function Library:SetTRProperty(inst, prop, raw)
    if not inst or type(prop) ~= "string" then return end
    raw = tostring(raw or "")
    inst[prop] = raw
end

function Library:RegisterTRCallback(fn)
end

function Library:TranslateAll()
end

function Library:SetLang(lang)
end

function Library:SafeCallback(f, ...)
    if not f then return end
    if not Library.NotifyOnError then return f(...) end
    local ok, err = pcall(f, ...)
    if not ok then
        local _, i = err:find(':%d+: ')
        Library:Notify(i and err:sub(i+1) or err, 3)
    end
end

function Library:AttemptSave()
    if Library.SaveManager then Library.SaveManager:Save() end
end

function Library:Create(Class, Props)
    local inst = type(Class) == 'string' and Instance.new(Class) or Class
    for k, v in next, Props do
        pcall(function()
            inst[k] = v
        end)
    end
    if isTextObject(inst) then
        if type(Props.Text) == "string" then
            inst.Text = self:NormalizeText(self:TranslateString(Props.Text))
        end
        if type(Props.PlaceholderText) == "string" then
            inst.PlaceholderText = self:NormalizeText(self:TranslateString(Props.PlaceholderText))
        end
    end
    if isTextObject(inst) then
        Library:RememberTextSize(inst, inst.TextSize)
        Library:ApplyTextMetrics(inst)
    end
    return inst
end

function Library:CreateLabel(Props, IsHud)
    local inst = Library:Create('TextLabel', {
        BackgroundTransparency  = 1;
        Font                    = Library.Font;
        TextColor3              = Library.FontColor;
        TextSize                = S(Props.TextSize or 16);
        TextStrokeTransparency  = 0;
    })
    Library:AddToRegistry(inst, { TextColor3 = 'FontColor'; Font = 'Font' }, IsHud)
    local p2 = {}
    for k, v in next, Props do p2[k] = v end
    if p2.TextSize then p2.TextSize = S(p2.TextSize) end
    local lbl = Library:Create(inst, p2)
    if Library.CustomFontFace then
        pcall(function() lbl.FontFace = Library.CustomFontFace end)
    end
    if type(Props.Text) == "string" then
        Library:SetTRText(lbl, Props.Text)
    end
    return lbl
end

function Library:CursorPos()
    local loc = Services.UserInputService:GetMouseLocation()
    return loc.X, loc.Y
end

function Library:IsPointerInput(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

function Library:MouseIsOverOpenedFrame()
    local px, py = Library:CursorPos()
    for Frame in next, Library.OpenedFrames do
        local ap, as = Frame.AbsolutePosition, Frame.AbsoluteSize
        if px >= ap.X and px <= ap.X + as.X and py >= ap.Y and py <= ap.Y + as.Y then
            return true
        end
    end
    return false
end

function Library:HasOpenedFrames()
    for f in next, Library.OpenedFrames do
        return true
    end
    return false
end

function Library:IsMouseOverFrame(Frame)
    local px, py = Library:CursorPos()
    local ap, as = Frame.AbsolutePosition, Frame.AbsoluteSize
    return px >= ap.X and px <= ap.X + as.X and py >= ap.Y and py <= ap.Y + as.Y
end

do
    local Pending = false
    function Library:UpdateDependencyBoxes()
        if Pending then return end
        Pending = true
        task.defer(function()
            Pending = false
            pcall(function()
                for _, db in next, Library.DependencyBoxes do db:Update() end
            end)
        end)
    end
end

function Library:MapValue(v, a0, a1, b0, b1)
    local t = (v - a0) / (a1 - a0)
    return b0 + t * (b1 - b0)
end

function Library:GetTextBounds(Text, Font, Size, Res)
    local ok, b = pcall(Services.TextService.GetTextSize, Services.TextService, Text, Size, Font, Res or Vector2.new(1920, 1080))
    if not ok or not b then
        local ok2, b2 = pcall(Services.TextService.GetTextSize, Services.TextService, Text, Size, Enum.Font.Code, Res or Vector2.new(1920, 1080))
        b = ok2 and b2 or Vector2.new(200, Size)
    end
    return b.X, b.Y
end

function Library:GetDarkerColor(color)
    local hue, saturation, brightness = Color3.toHSV(color)
    return Color3.fromHSV(hue, saturation, brightness / 1.5)
end

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

function Library:AddToRegistry(inst, props, isHud)
    local data = { Instance = inst; Properties = props }
    table.insert(Library.Registry, data)
    Library.RegistryMap[inst] = data
    if isHud then table.insert(Library.HudRegistry, data) end
end

function Library:RemoveFromRegistry(inst)
    local data = Library.RegistryMap[inst]
    if not data then return end
    for i = #Library.Registry, 1, -1 do
        if Library.Registry[i] == data then table.remove(Library.Registry, i) end
    end
    for i = #Library.HudRegistry, 1, -1 do
        if Library.HudRegistry[i] == data then table.remove(Library.HudRegistry, i) end
    end
    Library.RegistryMap[inst] = nil
end

function Library:UpdateColorsUsingRegistry()
    for _, obj in next, Library.Registry do
        for prop, idx in next, obj.Properties do
            local val
            if type(idx) == 'string' then
                val = Library[idx]
            elseif type(idx) == 'function' then
                val = idx()
            end
            if obj.Instance[prop] ~= val then
                obj.Instance[prop] = val
            end
        end
        Library:ApplyTextMetrics(obj.Instance)
    end
    if Library.CustomFontFace then
        for _, obj in next, Library.Registry do
            if obj.Properties['Font'] then
                pcall(function() obj.Instance.FontFace = Library.CustomFontFace end)
            end
        end
    end
    for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
end

function Library:GiveSignal(sig)
    table.insert(Library.Signals, sig)
end

function Library:Unload()
    for i = #Library.Signals, 1, -1 do
        table.remove(Library.Signals, i):Disconnect()
    end
    if Library.OnUnload then Library.OnUnload() end
    ScreenGui:Destroy()
end

function Library:OnUnload(cb)
    Library.OnUnload = cb
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(inst)
    if Library.RegistryMap[inst] then Library:RemoveFromRegistry(inst) end
end))

function Library:MakeDraggable(Frame, DragHandleOrCutoff)
    local DragHandle = (typeof(DragHandleOrCutoff) == 'Instance' and DragHandleOrCutoff) or Frame
    local Cutoff = (type(DragHandleOrCutoff) == 'number' and DragHandleOrCutoff)


    DragHandle.InputBegan:Connect(function(Input)
        if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then
            if Cutoff then
                local MouseY = Input.Position.Y - Frame.AbsolutePosition.Y
                if MouseY > Cutoff then return end
            end

            local dragging    = true
            local dragStart   = Input.Position
            local startAbsPos = Frame.AbsolutePosition
            local frameSize   = Frame.AbsoluteSize
            local dragInput   = Input
            local pAbs        = Frame.Parent.AbsolutePosition

            local drawOff = Vector2.new(Input.Position.X, Input.Position.Y) - Services.UserInputService:GetMouseLocation()
            local gx = startAbsPos.X - drawOff.X
            local gy = startAbsPos.Y - drawOff.Y
            local gw = frameSize.X
            local gh = frameSize.Y

            local GhostFill = Drawing.new("Square")
            GhostFill.Filled       = true
            GhostFill.Thickness    = 0
            GhostFill.Transparency = 0.35
            GhostFill.Visible      = false

            local GhostBorder = Drawing.new("Square")
            GhostBorder.Filled       = false
            GhostBorder.Thickness    = 1
            GhostBorder.Transparency = 1
            GhostBorder.Visible      = false

            local function applyGhost(dx, dy)
                local ac = Library.AccentColor
                GhostFill.Color    = ac
                GhostBorder.Color  = ac
                GhostFill.Position   = Vector2.new(gx + dx, gy + dy)
                GhostFill.Size       = Vector2.new(gw, gh)
                GhostBorder.Position = Vector2.new(gx + dx, gy + dy)
                GhostBorder.Size     = Vector2.new(gw, gh)
            end

            applyGhost(0, 0)
            GhostFill.Visible   = true
            GhostBorder.Visible = true

            local moveConn = Services.UserInputService.InputChanged:Connect(function(mInput)
                if mInput.UserInputType == Enum.UserInputType.MouseMovement or mInput.UserInputType == Enum.UserInputType.Touch then
                    dragInput = mInput
                end
            end)

            local rsConn
            rsConn = Services.RunService.RenderStepped:Connect(function()
                if not dragging then
                    rsConn:Disconnect()
                    return
                end
                local delta = dragInput.Position - dragStart
                applyGhost(delta.X, delta.Y)
            end)

            local endConn
            endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
                if Library:IsPointerInput(eInput) then
                    dragging = false
                    GhostFill.Visible   = false
                    GhostBorder.Visible = false
                    moveConn:Disconnect()
                    endConn:Disconnect()
                    local delta = dragInput.Position - dragStart
                    Frame.Position = UDim2.fromOffset(
                        startAbsPos.X + delta.X - pAbs.X,
                        startAbsPos.Y + delta.Y - pAbs.Y
                    )
                    GhostFill:Remove()
                    GhostBorder:Remove()
                end
            end)
        end
    end)
end

function Library:MakeDraggableDirect(Frame, DragHandleOrCutoff)
    local DragHandle = (typeof(DragHandleOrCutoff) == 'Instance' and DragHandleOrCutoff) or Frame
    local Cutoff = (type(DragHandleOrCutoff) == 'number' and DragHandleOrCutoff)

    DragHandle.InputBegan:Connect(function(Input)
        if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then
            if Cutoff then
                local MouseY = Input.Position.Y - Frame.AbsolutePosition.Y
                if MouseY > Cutoff then return end
            end

            local dragging  = true
            local dragStart = Input.Position
            local startPos  = Frame.AbsolutePosition
            local dragInput = Input
            local pAbs      = Frame.Parent.AbsolutePosition

            local moveConn = Services.UserInputService.InputChanged:Connect(function(mInput)
                if mInput.UserInputType == Enum.UserInputType.MouseMovement
                    or mInput.UserInputType == Enum.UserInputType.Touch then
                    dragInput = mInput
                end
            end)

            local rsConn
            rsConn = Services.RunService.RenderStepped:Connect(function()
                if not dragging then rsConn:Disconnect() return end
                local delta = dragInput.Position - dragStart
                Frame.Position = UDim2.fromOffset(
                    startPos.X + delta.X - pAbs.X,
                    startPos.Y + delta.Y - pAbs.Y
                )
            end)

            local endConn
            endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
                if Library:IsPointerInput(eInput) then
                    dragging = false
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)
end

function Library:AddToolTip(InfoStr, HoverInstance)
    local tip = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        AutomaticSize     = Enum.AutomaticSize.XY;
        Size              = UDim2.fromOffset(0, 0);
        ZIndex            = 100;
        Visible           = false;
        Parent            = ScreenGui;
    })
    Library:Create('UIPadding', {
        PaddingLeft    = UDim.new(0, S(4));
        PaddingRight   = UDim.new(0, S(4));
        PaddingTop     = UDim.new(0, S(3));
        PaddingBottom  = UDim.new(0, S(3));
        Parent         = tip;
    })
    local TooltipScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = tip })
    table.insert(Library.ThemeScales, TooltipScale)
    local TooltipLabel = Library:Create('TextLabel', {
        AutomaticSize           = Enum.AutomaticSize.XY;
        BackgroundTransparency  = 1;
        Font                    = Library.Font;
        Size                    = UDim2.fromOffset(0, 0);
        TextColor3              = Library.FontColor;
        TextSize                = S(14);
        TextWrapped             = false;
        TextXAlignment          = Enum.TextXAlignment.Left;
        ZIndex                  = 101;
        Parent                  = tip;
    })
    Library:SetTRText(TooltipLabel, InfoStr)
    Library:AddToRegistry(tip,    { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
    Library:AddToRegistry(TooltipLabel, { TextColor3 = 'FontColor'; Font = 'Font' })

    local hovering = false
    HoverInstance.MouseEnter:Connect(function()
        hovering = true
        tip.Visible = true
        while hovering do
            local scale = Library.UIScaleValue or 1.0
            local loc = Services.UserInputService:GetMouseLocation()
            tip.Position = UDim2.fromOffset((loc.X + 15) / scale, (loc.Y + 10) / scale)
            Services.RunService.Heartbeat:Wait()
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        hovering   = false
        tip.Visible = false
    end)
end

function Library:OnHighlight(HoverInst, TargetInst, OnProps, OffProps)
    if not HoverInst or not TargetInst then return end

    local function apply(props)
        local reg = Library.RegistryMap[TargetInst]
        for prop, idx in next, props do
            TargetInst[prop] = Library[idx] or idx
            if reg and reg.Properties[prop] then reg.Properties[prop] = idx end
        end
    end

    local function hook(signal, fn)
        if signal and signal.Connect then
            signal:Connect(fn)
            return true
        end
        return false
    end

    local enter = HoverInst.MouseEnter
    local leave = HoverInst.MouseLeave

    if enter and leave then
        hook(enter, function() apply(OnProps) end)
        hook(leave, function() apply(OffProps) end)
    else
        hook(HoverInst.InputBegan, function(i)
            if Library:IsPointerInput(i) then apply(OnProps) end
        end)
        hook(HoverInst.InputEnded, function(i)
            if Library:IsPointerInput(i) then apply(OffProps) end
        end)
    end
end

local function HandleDrag(Frame, onMove, onEnd, IgnoreOpenedFrames)
    local dragging = false
    local dragInput = nil

    Frame.InputBegan:Connect(function(Input)
        if not Library:IsPointerInput(Input) then return end
        if not IgnoreOpenedFrames and Library:HasOpenedFrames() then return end
        dragging = true
        onMove(Input.Position.X, Input.Position.Y)
    end)

    Frame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            dragInput = Input
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(Input)
        if dragging and Input == dragInput then
            onMove(Input.Position.X, Input.Position.Y)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(Input)
        if Library:IsPointerInput(Input) and dragging then
            dragging = false
            dragInput = nil
            if onEnd then onEnd() end
        end
    end)
end

do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, 0, 0.575, 0);
        Size                    = UDim2.new(1, 0, 0.5, 0);
        ZIndex                  = 100;
        Parent                  = ScreenGui;
    })
    Library:Create('UIListLayout', {
        Padding        = UDim.new(0, S(4));
        FillDirection  = Enum.FillDirection.Vertical;
        SortOrder      = Enum.SortOrder.LayoutOrder;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
        Parent         = Library.NotificationArea;
    })

    Library.KillNotificationArea = Library:Create('Frame', {
        BackgroundTransparency  = 1;
        AnchorPoint             = Vector2.new(0.5, 1);
        Position                = UDim2.new(0.5, 0, 0.98, 0);
        Size                    = UDim2.new(0, S(420), 0, S(180));
        ZIndex                  = 100;
        Parent                  = ScreenGui;
    })
    Library:Create('UIListLayout', {
        Padding              = UDim.new(0, S(4));
        FillDirection        = Enum.FillDirection.Vertical;
        HorizontalAlignment  = Enum.HorizontalAlignment.Center;
        VerticalAlignment    = Enum.VerticalAlignment.Bottom;
        SortOrder            = Enum.SortOrder.LayoutOrder;
        Parent               = Library.KillNotificationArea;
    })

    local WindowMoverOuter = Library:Create('Frame', {
        BorderColor3  = Color3.new(0,0,0);
        Position      = UDim2.fromOffset(S(1000), -S(25));
        Size          = UDim2.fromOffset(S(213), S(20));
        ZIndex        = 200;
        Visible       = false;
        Parent        = ScreenGui;
    })
    local WindowMoverInner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.AccentColor;
        BorderMode        = Enum.BorderMode.Inset;
        Size              = UDim2.new(1,0,1,0);
        ZIndex            = 201;
        Parent            = WindowMoverOuter;
    })
    Library:AddToRegistry(WindowMoverInner, { BorderColor3 = 'AccentColor' })
    local WindowMoverGradientFrame = Library:Create('Frame', {
        BackgroundColor3  = Color3.new(1,1,1);
        BorderSizePixel   = 0;
        Position          = UDim2.new(0,1,0,1);
        Size              = UDim2.new(1,-2,1,-2);
        ZIndex            = 202;
        Parent            = WindowMoverInner;
    })
    local WindowMoverGradient = Library:Create('UIGradient', {
        Color     = ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) });
        Rotation  = -90;
        Parent    = WindowMoverGradientFrame;
    })
    Library:AddToRegistry(WindowMoverGradient, { Color = function() return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }) end })
    local WindowMoverLabel = Library:CreateLabel({
        Position        = UDim2.new(0, S(5), 0, 0);
        Size            = UDim2.new(1, -S(4), 1, 0);
        TextSize        = S(14);
        TextXAlignment  = Enum.TextXAlignment.Left;
        ZIndex          = 203;
        Parent          = WindowMoverGradientFrame;
    })
    Library.Watermark     = WindowMoverOuter
    Library.WatermarkText = WindowMoverLabel
    Library:MakeDraggable(WindowMoverOuter)

    if not IsTouch then
        local KeybindOuter = Library:Create('Frame', {
            AnchorPoint   = Vector2.new(0, 0.5);
            BorderColor3  = Color3.new(0,0,0);
            Position      = UDim2.new(0, S(10), 0.5, 0);
            Size          = UDim2.fromOffset(S(210), S(20));
            Visible       = false;
            ZIndex        = 100;
            Parent        = ScreenGui;
        })
        local KeybindInner = Library:Create('Frame', {
            BackgroundColor3  = Library.MainColor;
            BorderColor3      = Library.OutlineColor;
            BorderMode        = Enum.BorderMode.Inset;
            Size              = UDim2.new(1,0,1,0);
            ZIndex            = 101;
            Parent            = KeybindOuter;
        })
        Library:AddToRegistry(KeybindInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' }, true)

        local KeybindGradient = Library:Create('UIGradient', {
            Color     = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) });
            Rotation  = 90;
            Parent    = KeybindInner;
        })

        local KeybindTopLine = Library:Create('Frame', {
            BackgroundColor3  = Library.AccentColor;
            BorderSizePixel   = 0;
            Size              = UDim2.new(1,0,0,2);
            ZIndex            = 102;
            Parent            = KeybindInner;
        })
        Library:AddToRegistry(KeybindTopLine, { BackgroundColor3 = 'AccentColor' }, true)

        Library:CreateLabel({
            Size            = UDim2.new(1,0,0,S(20));
            Position        = UDim2.fromOffset(0, S(2));
            TextXAlignment  = Enum.TextXAlignment.Center;
            Text            = 'Keybinds';
            Font            = Enum.Font.GothamBold;
            ZIndex          = 104;
            Parent          = KeybindInner;
        })
        local KeybindContainer = Library:Create('Frame', {
            BackgroundTransparency  = 1;
            Position                = UDim2.new(0,0,0,S(22));
            Size                    = UDim2.new(1,0,1,-S(22));
            ZIndex                  = 1;
            Parent                  = KeybindInner;
        })
        Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Vertical; SortOrder = Enum.SortOrder.LayoutOrder; Parent = KeybindContainer })
        Library:Create('UIPadding',    { PaddingLeft = UDim.new(0, S(5)); Parent = KeybindContainer })
        Library.KeybindFrame     = KeybindOuter
        Library.KeybindContainer = KeybindContainer
        Library:MakeDraggableDirect(KeybindOuter)
    else
        local stub = Instance.new('Frame')
        stub.Visible = false
        Library.KeybindFrame     = stub
        Library.KeybindContainer = stub
    end
end

function Library:SetWatermarkVisibility(b)  Library.Watermark.Visible = b end
function Library:SetKeybindVisibility(b)
    Library.KeybindFrame.Visible = b
end
function Library:SaveThemeDefaults()
end
function Library:GetMainWindowSize()
    if self.MainWindow and type(self.MainWindow.GetWindowSize) == 'function' then
        return self.MainWindow:GetWindowSize()
    end
    return self.MainWindowSize
end
function Library:SetMainWindowSize(w, h, skipSave)
    self.MainWindowSize = { w = tonumber(w), h = tonumber(h) }
    if self.MainWindow and type(self.MainWindow.SetWindowSize) == 'function' then
        pcall(self.MainWindow.SetWindowSize, self.MainWindow, w, h, true)
    end
    if not skipSave then
        self:SaveThemeDefaults()
    end
end
function Library:SetUIScale(scale, skipSave)
    local clampedScale = math.clamp(tonumber(scale) or 1.0, 0.5, 1.5)
    self.UIScaleValue = clampedScale
    if self.OuterScale then
        self.OuterScale.Scale = clampedScale
    end
    if self.ThemeScales then
        for _, sc in ipairs(self.ThemeScales) do
            if sc and sc.Parent then
                sc.Scale = clampedScale
            end
        end
    end
    if not skipSave then
        self:SaveThemeDefaults()
    end
end
    function Library:ResetMainWindowSize()
        if self.MainWindow and type(self.MainWindow.ResetWindowSize) == 'function' then
            pcall(self.MainWindow.ResetWindowSize, self.MainWindow)
        end
    end
    function Library:ResetMainWindowPosition(skipSave)
        if self.MainWindow and type(self.MainWindow.ResetWindowPosition) == 'function' then
            pcall(self.MainWindow.ResetWindowPosition, self.MainWindow)
        end
        if not skipSave then
            self:SaveThemeDefaults()
        end
    end

function Library:SetIconSize(size)
    local n = math.clamp(math.floor(tonumber(size) or self.IconSize or 20), 12, 32)
    self.IconSize = n
    if self.MainWindow and type(self.MainWindow.SetIconSize) == 'function' then
        pcall(self.MainWindow.SetIconSize, self.MainWindow, n)
    end
    for _, cb in ipairs(self.IconSizeCallbacks) do pcall(cb, n) end
    return n
end
function Library:BindResizeHandle(inst, getSize, setSize, onFinish)
    if not inst then return end
    inst.Active = true

    local resizing   = false
    local startX, startY = 0, 0
    local startW, startH = 0, 0
    local dragInput  = nil

    inst.InputBegan:Connect(function(Input)
        if not Library:IsPointerInput(Input) then return end
        resizing = true
        dragInput = Input
        startX = Input.Position.X
        startY = Input.Position.Y
        if type(getSize) == 'function' then
            startW, startH = getSize()
        end
    end)

    inst.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch then
            dragInput = Input
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(Input)
        if not resizing then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragInput = Input
        local dX = Input.Position.X - startX
        local dY = Input.Position.Y - startY
        if type(setSize) == 'function' then
            setSize(startW + dX, startH + dY)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(Input)
        if not resizing or not Library:IsPointerInput(Input) then return end
        resizing = false
        dragInput = nil
        if type(onFinish) == 'function' then
            onFinish()
        else
            Library:SaveThemeDefaults()
        end
    end)
end
function Library:BindResizeHandleGhost(clipInst, circleInst, getSize, setSize, onFinish)
    if not clipInst then return end
    clipInst.Active = true
    local defaultTrans = circleInst.BackgroundTransparency

    clipInst.InputBegan:Connect(function(Input)
        if not Library:IsPointerInput(Input) then return end

        circleInst.BackgroundTransparency = 1

        local startX = Input.Position.X
        local startY = Input.Position.Y
        local startW, startH = 0, 0
        if type(getSize) == 'function' then
            startW, startH = getSize()
        end

        local minW = 460
        local minH = 420

        local drawOff = Vector2.new(Input.Position.X, Input.Position.Y) - Services.UserInputService:GetMouseLocation()
        local parentAbs = (clipInst.Parent and clipInst.Parent.AbsolutePosition) or Vector2.new(0, 0)
        local gx = parentAbs.X - drawOff.X
        local gy = parentAbs.Y - drawOff.Y

        local GhostFill = Drawing.new("Square")
        GhostFill.Filled       = true
        GhostFill.Thickness    = 0
        GhostFill.Transparency = 0.35
        GhostFill.Color        = Library.AccentColor
        GhostFill.Position     = Vector2.new(gx, gy)
        GhostFill.Size         = Vector2.new(startW, startH)
        GhostFill.Visible      = true

        local GhostBorder = Drawing.new("Square")
        GhostBorder.Filled       = false
        GhostBorder.Thickness    = 1
        GhostBorder.Transparency = 1
        GhostBorder.Color        = Library.AccentColor
        GhostBorder.Position     = Vector2.new(gx, gy)
        GhostBorder.Size         = Vector2.new(startW, startH)
        GhostBorder.Visible      = true

        local dragging = true
        local dragInput = Input

        local moveConn = Services.UserInputService.InputChanged:Connect(function(mInput)
            if mInput.UserInputType == Enum.UserInputType.MouseMovement
                or mInput.UserInputType == Enum.UserInputType.Touch then
                dragInput = mInput
            end
        end)

        local rsConn
        rsConn = Services.RunService.RenderStepped:Connect(function()
            if not dragging then rsConn:Disconnect() return end
            local dx = dragInput.Position.X - startX
            local dy = dragInput.Position.Y - startY
            local nw = math.max(startW + dx, minW)
            local nh = math.max(startH + dy, minH)
            GhostFill.Color   = Library.AccentColor
            GhostBorder.Color = Library.AccentColor
            GhostFill.Size    = Vector2.new(nw, nh)
            GhostBorder.Size  = Vector2.new(nw, nh)
        end)

        local endConn
        endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
            if not Library:IsPointerInput(eInput) then return end
            dragging = false
            moveConn:Disconnect()
            endConn:Disconnect()

            local dx = dragInput.Position.X - startX
            local dy = dragInput.Position.Y - startY
            GhostFill:Remove()
            GhostBorder:Remove()

            if type(setSize) == 'function' then
                setSize(startW + dx, startH + dy)
            end

            circleInst.BackgroundTransparency = defaultTrans

            if type(onFinish) == 'function' then
                onFinish()
            else
                Library:SaveThemeDefaults()
            end
        end)
    end)
end

function Library:SetWatermark(Text)
    local textWidth = Library:GetTextBounds(Text, Library.Font, S(14))
    Library.Watermark.Size = UDim2.fromOffset(textWidth + S(15), S(20))
    Library.WatermarkText.Text = Text
    Library:SetWatermarkVisibility(true)
end

function Library:Notify(Text, Time)
    if not Text or Text == "" then return end
    local xw = Library:GetTextBounds(Text, Library.Font, S(14)) or 200
    local H   = S(22)
    local Outer = Library:Create('Frame', {
					AnchorPoint = Vector2.new(0.5, 0);
        BorderColor3      = Color3.new(0,0,0);
        Size              = UDim2.fromOffset(0, H);
        ClipsDescendants  = true;
        ZIndex            = 100;
        Parent            = Library.NotificationArea;
    })
    local Inner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        BorderMode        = Enum.BorderMode.Inset;
        Size              = UDim2.new(1,0,1,0);
        ZIndex            = 101;
        Parent            = Outer;
    })
    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' }, true)
    local GradientFrame = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderSizePixel = 0; Position = UDim2.new(0,1,0,1); Size = UDim2.new(1,-2,1,-2); ZIndex = 102; Parent = Inner })
    local G  = Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }); Rotation = -90; Parent = GradientFrame })
    Library:AddToRegistry(G, { Color = function() return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }) end })
    Library:CreateLabel({ PreserveCase = true; Position = UDim2.new(0, S(8), 0, 0); Size = UDim2.new(1, -S(8), 1, 0); Text = Text; TextXAlignment = Enum.TextXAlignment.Left; TextSize = S(13); ZIndex = 103; Parent = GradientFrame })
    Library:Create('Frame', { BackgroundColor3 = Library.AccentColor; BorderSizePixel = 0; Position = UDim2.new(0,-1,0,-1); Size = UDim2.new(0, S(3), 1, 2); ZIndex = 104; Parent = Outer })
    Library:AddToRegistry(Outer:GetChildren()[#Outer:GetChildren()], { BackgroundColor3 = 'AccentColor' }, true)
    pcall(Outer.TweenSize, Outer, UDim2.fromOffset(xw + S(16), H), 'Out', 'Quad', 0.35, true)
    task.spawn(function()
        task.wait(Time or 5)
        pcall(Outer.TweenSize, Outer, UDim2.fromOffset(0, H), 'Out', 'Quad', 0.35, true)
        task.wait(0.4)
        Outer:Destroy()
    end)
end

function Library:KillNotify(Text, Time)
    if not Text or Text == "" then return end
    local xw = Library:GetTextBounds(Text, Library.Font, S(14)) or 200
    local H   = S(22)
    local Outer = Library:Create('Frame', {
        BorderColor3      = Color3.new(0,0,0);
        Size              = UDim2.fromOffset(0, H);
        ClipsDescendants  = true;
        ZIndex            = 100;
        Parent            = Library.KillNotificationArea or Library.NotificationArea;
    })
    local Inner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        BorderMode        = Enum.BorderMode.Inset;
        Size              = UDim2.new(1,0,1,0);
        ZIndex            = 101;
        Parent            = Outer;
    })
    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' }, true)
    local GradientFrame = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderSizePixel = 0; Position = UDim2.new(0,1,0,1); Size = UDim2.new(1,-2,1,-2); ZIndex = 102; Parent = Inner })
    Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }); Rotation = -90; Parent = GradientFrame })
    Library:CreateLabel({ PreserveCase = true; Position = UDim2.new(0, S(8), 0, 0); Size = UDim2.new(1, -S(8), 1, 0); Text = Text; TextXAlignment = Enum.TextXAlignment.Left; TextSize = S(13); ZIndex = 103; Parent = GradientFrame })
    Library:Create('Frame', { BackgroundColor3 = Color3.fromRGB(220, 50, 50); BorderSizePixel = 0; Position = UDim2.new(0,-1,0,-1); Size = UDim2.new(0, S(3), 1, 2); ZIndex = 104; Parent = Outer })
    pcall(Outer.TweenSize, Outer, UDim2.fromOffset(xw + S(16), H), 'Out', 'Quad', 0.35, true)
    task.spawn(function()
        task.wait(Time or 5)
        pcall(Outer.TweenSize, Outer, UDim2.fromOffset(0, H), 'Out', 'Quad', 0.35, true)
        task.wait(0.4)
        Outer:Destroy()
    end)
end

function Library:SetAccentColor(Color)
    Library.AccentColor     = Color
    Library.AccentColorDark = Library:GetDarkerColor(Color)
    Library:UpdateColorsUsingRegistry()
end

local BaseAddons  = {}
local BaseGroupbox = {}

do
    local Funcs = {}

    function Funcs:AddColorPicker(Idx, Info)
        Library:BuildTick()
        assert(Info.Default, 'AddColorPicker: Missing default value.')
        local TextLabelRef = self.TextLabel

        local ColorPickerInfo = {
            Value         = Info.Default;
            Transparency  = Info.Transparency or 0;
            Type          = 'ColorPicker';
            Title         = tostring(Info.Title or 'Color picker');
            Callback      = Info.Callback or function() end;
        }

        local function RGB2HSV(c) local h,s,v = Color3.toHSV(c); ColorPickerInfo.Hue = h; ColorPickerInfo.Sat = s; ColorPickerInfo.Vib = v end
        RGB2HSV(ColorPickerInfo.Value)

        local DisplayWidth, DispH = S(28), S(14)
        local Swatch = Library:Create('Frame', {
            BackgroundColor3  = ColorPickerInfo.Value;
            BorderColor3      = Library:GetDarkerColor(ColorPickerInfo.Value);
            BorderMode        = Enum.BorderMode.Inset;
            Size              = UDim2.fromOffset(DisplayWidth, DispH);
            ZIndex            = 15;
            Parent            = TextLabelRef;
        })
        if Info.Transparency then
            Library:Create('ImageLabel', { BorderSizePixel = 0; Size = UDim2.new(0, DisplayWidth-1, 0, DispH-1); ZIndex = 14; Image = 'rbxassetid://126479907072494'; Parent = Swatch })
        end

        local pickerW = S(230)
        local pickerH = Info.Transparency and S(271) or S(253)
        local mapSz   = S(200)

        local Blocker = Library:Create('Frame', { Name='ColorBlocker'; Active=true; BackgroundTransparency=1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(1,1); Visible=false; ZIndex=205; Parent=ScreenGui })
        local PickerFrameOuter = Library:Create('Frame', { Name = 'Color'; Active = true; BackgroundColor3 = Color3.new(1,1,1); BorderColor3 = Color3.new(0,0,0); Size = UDim2.fromOffset(pickerW, pickerH); Visible = false; ZIndex = 15; Parent = ScreenGui })
        local PickerFrameScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = PickerFrameOuter })
        table.insert(Library.ThemeScales, PickerFrameScale)
        local PickerFrameInner = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 16; Parent = PickerFrameOuter })
        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })

        local function UpdatePickerPos()
            local sap = Swatch.AbsolutePosition
            PickerFrameOuter.Position = UDim2.fromOffset(sap.X, sap.Y + Swatch.AbsoluteSize.Y + 1)
        end
        -- Measure where it actually landed and pin it under the swatch (UIScale-proof).
        local pickerCorrecting = false
        local function StartPickerCorrecting()
            if pickerCorrecting then return end
            pickerCorrecting = true
            task.spawn(function()
                while PickerFrameOuter.Visible do
                    local sap, sas = Swatch.AbsolutePosition, Swatch.AbsoluteSize
                    local cur = PickerFrameOuter.AbsolutePosition
                    local ex  = sap.X - cur.X
                    local ey  = (sap.Y + sas.Y + 1) - cur.Y
                    if math.abs(ex) > 0.5 or math.abs(ey) > 0.5 then
                        PickerFrameOuter.Position = UDim2.fromOffset(
                            PickerFrameOuter.Position.X.Offset + ex,
                            PickerFrameOuter.Position.Y.Offset + ey
                        )
                    end
                    Services.RunService.Heartbeat:Wait()
                end
                pickerCorrecting = false
            end)
        end
        Swatch:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdatePickerPos)
        UpdatePickerPos()

        local AccentBar = Library:Create('Frame', { BackgroundColor3 = Library.AccentColor; BorderSizePixel = 0; Size = UDim2.new(1,0,0,2); ZIndex = 17; Parent = PickerFrameInner })
        Library:AddToRegistry(AccentBar, { BackgroundColor3 = 'AccentColor' })

        Library:CreateLabel({ Size = UDim2.new(1,0,0,S(14)); Position = UDim2.fromOffset(S(5), S(4)); TextSize = S(13); Text = ColorPickerInfo.Title; TextXAlignment = Enum.TextXAlignment.Left; TextWrapped = false; ZIndex = 17; Parent = PickerFrameInner })

        local SatValOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, S(4), 0, S(24)); Size = UDim2.fromOffset(mapSz, mapSz); ZIndex = 17; Parent = PickerFrameInner })
        local SatValInner = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = SatValOuter })
        local SatValMap   = Library:Create('ImageLabel', { BorderSizePixel = 0; Size = UDim2.new(1,0,1,0); ZIndex = 18; Image = 'rbxassetid://4155801252'; Parent = SatValInner })
        Library:AddToRegistry(SatValInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })

        local CursorOuter = Library:Create('ImageLabel', { AnchorPoint = Vector2.new(0.5,0.5); Size = UDim2.fromOffset(S(6),S(6)); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ImageColor3=Color3.new(0,0,0); ZIndex=19; Parent=SatValMap })
        Library:Create('ImageLabel', { Size=UDim2.fromOffset(S(4),S(4)); Position=UDim2.fromOffset(1,1); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ZIndex=20; Parent=CursorOuter })

        local HueOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, S(208), 0, S(24)); Size = UDim2.fromOffset(S(15), mapSz); ZIndex = 17; Parent = PickerFrameInner })
        local HueInner = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderSizePixel = 0; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = HueOuter })
        local hueSKP  = {}
        for i = 0, 1, 0.1 do table.insert(hueSKP, ColorSequenceKeypoint.new(math.min(i,1), Color3.fromHSV(i,1,1))) end
        Library:Create('UIGradient', { Color = ColorSequence.new(hueSKP); Rotation = 90; Parent = HueInner })

        local HexInputOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, S(4), 0, S(228)); Size = UDim2.new(0.5, -S(6), 0, S(20)); ZIndex = 18; Parent = PickerFrameInner })
        local HexInputInner = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = HexInputOuter })
        Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) }); Rotation = 90; Parent = HexInputInner })
        local HexInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,0); Size=UDim2.new(1,-S(4),1,0); Font=Library.Font; PlaceholderText='Hex'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='#FFFFFF'; TextColor3=Library.FontColor; TextSize=S(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=HexInputInner })
        Library:AddToRegistry(HexInputInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
        Library:AddToRegistry(HexInputBox,   { TextColor3 = 'FontColor' })

        local RgbInputOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0.5, S(2), 0, S(228)); Size = UDim2.new(0.5, -S(6), 0, S(20)); ZIndex = 18; Parent = PickerFrameInner })
        local RgbInputInner = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = RgbInputOuter })
        Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) }); Rotation = 90; Parent = RgbInputInner })
        local RgbInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,0); Size=UDim2.new(1,-S(4),1,0); Font=Library.Font; PlaceholderText='R,G,B'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='255,255,255'; TextColor3=Library.FontColor; TextSize=S(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=RgbInputInner })
        Library:AddToRegistry(RgbInputInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
        Library:AddToRegistry(RgbInputBox,   { TextColor3 = 'FontColor' })

        local TransparencyInner
        if Info.Transparency then
            local TransparencyOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.fromOffset(S(4), S(251)); Size = UDim2.new(1, -S(8), 0, S(14)); ZIndex = 19; Parent = PickerFrameInner })
            TransparencyInner = Library:Create('Frame', { BackgroundColor3 = ColorPickerInfo.Value; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 19; Parent = TransparencyOuter })
            Library:AddToRegistry(TransparencyInner, { BorderColor3 = 'OutlineColor' })
            Library:Create('ImageLabel', { BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Image='rbxassetid://12978095818'; ZIndex=20; Parent=TransparencyInner })
        end

        function ColorPickerInfo:Display()
            ColorPickerInfo.Value = Color3.fromHSV(ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib)
            SatValMap.BackgroundColor3 = Color3.fromHSV(ColorPickerInfo.Hue, 1, 1)
            Swatch.BackgroundColor3 = ColorPickerInfo.Value
            Swatch.BackgroundTransparency = ColorPickerInfo.Transparency
            Swatch.BorderColor3 = Library:GetDarkerColor(ColorPickerInfo.Value)
            if TransparencyInner then TransparencyInner.BackgroundColor3 = ColorPickerInfo.Value end
            CursorOuter.Position = UDim2.new(ColorPickerInfo.Sat, 0, 1 - ColorPickerInfo.Vib, 0)
            HexInputBox.Text = '#'..ColorPickerInfo.Value:ToHex()
            RgbInputBox.Text = math.floor(ColorPickerInfo.Value.R*255)..','..math.floor(ColorPickerInfo.Value.G*255)..','..math.floor(ColorPickerInfo.Value.B*255)
            Library:SafeCallback(ColorPickerInfo.Callback, ColorPickerInfo.Value)
            Library:SafeCallback(ColorPickerInfo.Changed,  ColorPickerInfo.Value)
        end

        function ColorPickerInfo:Show()
            for f in next, Library.OpenedFrames do if f.Name == 'Color' or f.Name == 'ColorBlocker' then f.Visible = false; Library.OpenedFrames[f] = nil end end
            UpdatePickerPos()
            Blocker.Visible = true
            PickerFrameOuter.Visible = true
            StartPickerCorrecting()
            Library.OpenedFrames[PickerFrameOuter] = true
            Library.OpenedFrames[Blocker] = true
        end
        function ColorPickerInfo:Hide()
            Blocker.Visible = false
            PickerFrameOuter.Visible = false
            Library.OpenedFrames[PickerFrameOuter] = nil
            Library.OpenedFrames[Blocker] = nil
        end
        function ColorPickerInfo:SetValue(hsv, trans)
            ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib = hsv[1], hsv[2], hsv[3]
            ColorPickerInfo.Transparency = trans or 0
            ColorPickerInfo:Display()
        end
        function ColorPickerInfo:SetValueRGB(c, trans)
            ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib = Color3.toHSV(c)
            ColorPickerInfo.Transparency = trans or 0
            ColorPickerInfo:Display()
        end
        function ColorPickerInfo:OnChanged(fn) ColorPickerInfo.Changed = fn; fn(ColorPickerInfo.Value) end

        local function markInner()
            ColorPickerInfo.suppressClose = true
        end
        PickerFrameInner.InputBegan:Connect(function(Input)
            if Library:IsPointerInput(Input) then markInner() end
        end)

        HandleDrag(SatValMap, function(x,y)
            markInner()
            local ap, as = SatValMap.AbsolutePosition, SatValMap.AbsoluteSize
            ColorPickerInfo.Sat = math.clamp((x - ap.X) / as.X, 0, 1)
            ColorPickerInfo.Vib = 1 - math.clamp((y - ap.Y) / as.Y, 0, 1)
            ColorPickerInfo:Display()
        end, function() Library:AttemptSave() end, true)

        HandleDrag(HueInner, function(x,y)
            markInner()
            local ap, as = HueInner.AbsolutePosition, HueInner.AbsoluteSize
            ColorPickerInfo.Hue = math.clamp((y - ap.Y) / as.Y, 0, 1)
            ColorPickerInfo:Display()
        end, function() Library:AttemptSave() end, true)

        if TransparencyInner then
            HandleDrag(TransparencyInner, function(x,y)
                markInner()
                local ap, as = TransparencyInner.AbsolutePosition, TransparencyInner.AbsoluteSize
                ColorPickerInfo.Transparency = 1 - math.clamp((x - ap.X) / as.X, 0, 1)
                ColorPickerInfo:Display()
            end, function() Library:AttemptSave() end, true)
        end

        HexInputBox.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        RgbInputBox.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        HexInputInner.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        RgbInputInner.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        Blocker.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            task.defer(function()
                if ColorPickerInfo.suppressClose then
                    ColorPickerInfo.suppressClose = false
                    return
                end
                ColorPickerInfo:Hide()
            end)
        end)

        HexInputBox.FocusLost:Connect(function(enter)
            if enter then
                local ok, c = pcall(Color3.fromHex, HexInputBox.Text)
                if ok then ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib = Color3.toHSV(c) end
            end
            ColorPickerInfo:Display()
        end)
        RgbInputBox.FocusLost:Connect(function(enter)
            if enter then
                local r,g,b = RgbInputBox.Text:match('(%d+),(%d+),(%d+)')
                if r then ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib = Color3.toHSV(Color3.fromRGB(r,g,b)) end
            end
            ColorPickerInfo:Display()
        end)

        Swatch.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then return end
            if PickerFrameOuter.Visible then ColorPickerInfo:Hide() else ColorPickerInfo:Show() end
        end)

        Library:GiveSignal(Services.UserInputService.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if ColorPickerInfo.suppressClose then
                ColorPickerInfo.suppressClose = false
                return
            end
            local loc = Services.UserInputService:GetMouseLocation()
            local px = loc.X
            local py = loc.Y
            local ap, as = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize
            if px < ap.X or px > ap.X+as.X or py < ap.Y-DispH-2 or py > ap.Y+as.Y then
                ColorPickerInfo:Hide()
            end
        end))

        ColorPickerInfo:Display()
        ColorPickerInfo.DisplayFrame = Swatch
        if self.Addons then table.insert(self.Addons, ColorPickerInfo) end
        PickerFrameOuter.Active = true
        PickerFrameInner.Active = true
        for _, d in ipairs(PickerFrameOuter:GetDescendants()) do
            if d:IsA('GuiObject') then d.ZIndex = d.ZIndex + 200 end
        end
        PickerFrameOuter.ZIndex = PickerFrameOuter.ZIndex + 200
        Options[Idx] = ColorPickerInfo
        return self
    end

    function Funcs:AddGradientColorPicker(Idx, Info)
        assert(type(Info.Defaults) == 'table' and Info.Defaults[1] and Info.Defaults[2] and Info.Defaults[3],
            'AddGradientColorPicker: Defaults must be a table of 3 Color3 values.')
        local TextLabelRef = self.TextLabel

        local STOP_NAMES = { "start", "middle", "end" }

        local GradColorPickerInfo = {
            Values          = { Info.Defaults[1], Info.Defaults[2], Info.Defaults[3] };
            Transparencies  = { Info.Transparency or 0, Info.Transparency or 0, Info.Transparency or 0 };
            ActiveStop      = 1;
            Type            = 'GradientColorPicker';
            Title           = tostring(Info.Title or 'Gradient');
            Callback        = Info.Callback or function() end;
            Hue             = 0; Sat = 0; Vib = 1;
        }
        GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib = Color3.toHSV(GradColorPickerInfo.Values[1])

        local swW, swH = S(60), S(14)
        local Swatch = Library:Create('Frame', {
            BackgroundColor3  = Color3.new(1,1,1);
            BorderColor3      = Color3.new(0,0,0);
            BorderMode        = Enum.BorderMode.Inset;
            Size              = UDim2.fromOffset(swW, swH);
            ZIndex            = 15;
            Active            = true;
            Parent            = TextLabelRef;
        })
        Library:Create('ImageLabel', { BorderSizePixel=0; Size=UDim2.new(0,swW-1,0,swH-1); ZIndex=14; Image='rbxassetid://12977615774'; Parent=Swatch })
        local SwatchGrad = Library:Create('UIGradient', { Parent=Swatch })

        local pickerW = S(230)
        local mapSz   = S(200)
        -- vertical layout anchors (top -> bottom): preview bar, stop tabs, map+hue, inputs, transparency
        local prevY   = S(22)
        local tabsY   = S(44)
        local mapY    = S(70)
        local inputsY = mapY + mapSz + S(6)
        local transY  = inputsY + S(23)
        local pickerH = (Info.Transparency ~= nil) and (transY + S(18)) or (inputsY + S(24))

        local Blocker = Library:Create('Frame', { Name='GradColorBlocker'; Active=true; BackgroundTransparency=1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(1,1); Visible=false; ZIndex=205; Parent=ScreenGui })

        local PickerFrameOuter = Library:Create('Frame', { Name='GradColor'; Active=true; BackgroundColor3=Color3.new(1,1,1); BorderColor3=Color3.new(0,0,0); Size=UDim2.fromOffset(pickerW, pickerH); Visible=false; ZIndex=15; Parent=ScreenGui })
        local PickerFrameScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = PickerFrameOuter })
        table.insert(Library.ThemeScales, PickerFrameScale)
        local PickerFrameInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=16; Parent=PickerFrameOuter })
        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })

        local function UpdatePickerPos()
            local sap = Swatch.AbsolutePosition
            PickerFrameOuter.Position = UDim2.fromOffset(sap.X, sap.Y + Swatch.AbsoluteSize.Y + 1)
        end
        -- Bulletproof: measure where the picker actually rendered and nudge until its top-left
        -- sits exactly under the swatch (the UIScale otherwise shifts it off, worse when tall).
        local pickerCorrecting = false
        local function StartPickerCorrecting()
            if pickerCorrecting then return end
            pickerCorrecting = true
            task.spawn(function()
                while PickerFrameOuter.Visible do
                    local sap, sas = Swatch.AbsolutePosition, Swatch.AbsoluteSize
                    local cur = PickerFrameOuter.AbsolutePosition
                    local ex  = sap.X - cur.X
                    local ey  = (sap.Y + sas.Y + 1) - cur.Y
                    if math.abs(ex) > 0.5 or math.abs(ey) > 0.5 then
                        PickerFrameOuter.Position = UDim2.fromOffset(
                            PickerFrameOuter.Position.X.Offset + ex,
                            PickerFrameOuter.Position.Y.Offset + ey
                        )
                    end
                    Services.RunService.Heartbeat:Wait()
                end
                pickerCorrecting = false
            end)
        end
        Swatch:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdatePickerPos)
        UpdatePickerPos()

        local AccentBar = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Size=UDim2.new(1,0,0,2); ZIndex=17; Parent=PickerFrameInner })
        Library:AddToRegistry(AccentBar, { BackgroundColor3='AccentColor' })

        local TitleLabel = Library:CreateLabel({ Size=UDim2.new(1,0,0,S(14)); Position=UDim2.fromOffset(S(5),S(4)); TextSize=S(13); Text=GradColorPickerInfo.Title..' (start)'; TextXAlignment=Enum.TextXAlignment.Left; TextWrapped=false; ZIndex=17; Parent=PickerFrameInner })

        -- Live gradient preview bar (checkerboard shows through transparent stops).
        local PreviewOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset(S(4),prevY); Size=UDim2.new(1,-S(8),0,S(18)); ZIndex=17; Parent=PickerFrameInner })
        local PreviewInner = Library:Create('Frame', { BackgroundColor3=Library.OutlineColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; BorderSizePixel=1; Size=UDim2.new(1,0,1,0); ZIndex=17; Parent=PreviewOuter })
        Library:AddToRegistry(PreviewInner, { BackgroundColor3='OutlineColor'; BorderColor3='OutlineColor' })
        Library:Create('ImageLabel', { BackgroundTransparency=1; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://12977615774'; Parent=PreviewInner })
        local PreviewFill = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=PreviewInner })
        local PreviewGrad = Library:Create('UIGradient', { Parent=PreviewFill })

        -- Horizontal stop selector: start | middle | end. Active stop = accent border + text.
        local STOP_TAB_NAMES = { 'Start', 'Middle', 'End' }
        local tabGap   = S(3)
        local tabW     = math.floor((pickerW - S(8) - tabGap * 2) / 3)
        local stopFrames = {}
        for i = 1, 3 do
            local tabX = S(4) + (i - 1) * (tabW + tabGap)
            local tabOuter = Library:Create('Frame', { Active=true; BackgroundColor3=Library.MainColor; BorderColor3=(i==1) and Library.AccentColor or Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; BorderSizePixel=1; Position=UDim2.fromOffset(tabX,tabsY); Size=UDim2.fromOffset(tabW,S(20)); ZIndex=17; Parent=PickerFrameInner })
            Library:AddToRegistry(tabOuter, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
            local chipOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Position=UDim2.fromOffset(S(3),S(3)); Size=UDim2.fromOffset(S(12),S(12)); ZIndex=18; Parent=tabOuter })
            Library:Create('ImageLabel', { BackgroundTransparency=1; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://12977615774'; Parent=chipOuter })
            local chip = Library:Create('Frame', { Active=true; BackgroundColor3=GradColorPickerInfo.Values[i]; BackgroundTransparency=GradColorPickerInfo.Transparencies[i]; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=chipOuter })
            local nameLbl = Library:CreateLabel({ PreserveCase=true; BackgroundTransparency=1; Position=UDim2.fromOffset(S(19),0); Size=UDim2.new(1,-S(21),1,0); TextSize=S(11); Text=STOP_TAB_NAMES[i]; TextXAlignment=Enum.TextXAlignment.Left; ZIndex=18; Parent=tabOuter })
            stopFrames[i] = { frame = chip, outer = tabOuter, label = nameLbl }
            local idx = i
            tabOuter.MouseEnter:Connect(function() tabOuter.BorderColor3 = Library.AccentColor end)
            tabOuter.MouseLeave:Connect(function() tabOuter.BorderColor3 = (GradColorPickerInfo.ActiveStop == idx) and Library.AccentColor or Library.OutlineColor end)
        end

        local SatValOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset(S(4),mapY); Size=UDim2.fromOffset(mapSz,mapSz); ZIndex=17; Parent=PickerFrameInner })
        local SatValInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=SatValOuter })
        local SatValMap   = Library:Create('ImageLabel', { BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://4155801252'; Parent=SatValInner })
        Library:AddToRegistry(SatValInner, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })

        local CursorOuter = Library:Create('ImageLabel', { AnchorPoint=Vector2.new(0.5,0.5); Size=UDim2.fromOffset(S(6),S(6)); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ImageColor3=Color3.new(0,0,0); ZIndex=19; Parent=SatValMap })
        Library:Create('ImageLabel', { Size=UDim2.fromOffset(S(4),S(4)); Position=UDim2.fromOffset(1,1); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ZIndex=20; Parent=CursorOuter })

        local HueOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset(S(208),mapY); Size=UDim2.fromOffset(S(15),mapSz); ZIndex=17; Parent=PickerFrameInner })
        local HueInner = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=HueOuter })
        local hueSKP  = {}
        for i = 0, 1, 0.1 do table.insert(hueSKP, ColorSequenceKeypoint.new(math.min(i,1), Color3.fromHSV(i,1,1))) end
        Library:Create('UIGradient', { Color=ColorSequence.new(hueSKP); Rotation=90; Parent=HueInner })

        local HexInputOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0,S(4),0,inputsY); Size=UDim2.new(0.5,-S(6),0,S(20)); ZIndex=18; Parent=PickerFrameInner })
        local HexInputInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=HexInputOuter })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=HexInputInner })
        local HexInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,0); Size=UDim2.new(1,-S(4),1,0); Font=Library.Font; PlaceholderText='Hex'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='#FFFFFF'; TextColor3=Library.FontColor; TextSize=S(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=HexInputInner })
        Library:AddToRegistry(HexInputInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:AddToRegistry(HexInputBox,   { TextColor3='FontColor' })

        local RgbInputOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0.5,S(2),0,inputsY); Size=UDim2.new(0.5,-S(6),0,S(20)); ZIndex=18; Parent=PickerFrameInner })
        local RgbInputInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=RgbInputOuter })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=RgbInputInner })
        local RgbInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,0); Size=UDim2.new(1,-S(4),1,0); Font=Library.Font; PlaceholderText='R,G,B'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='255,255,255'; TextColor3=Library.FontColor; TextSize=S(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=RgbInputInner })
        Library:AddToRegistry(RgbInputInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:AddToRegistry(RgbInputBox,   { TextColor3='FontColor' })

        local TransparencyInner
        if Info.Transparency ~= nil then
            local TransparencyOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0,S(4),0,transY); Size=UDim2.new(1,-S(8),0,S(14)); ZIndex=19; Parent=PickerFrameInner })
            TransparencyInner = Library:Create('Frame', { BackgroundColor3=GradColorPickerInfo.Values[1]; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=TransparencyOuter })
            Library:AddToRegistry(TransparencyInner, { BorderColor3='OutlineColor' })
            Library:Create('ImageLabel', { BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Image='rbxassetid://12978095818'; ZIndex=20; Parent=TransparencyInner })
        end

        local function RefreshStopSwatches()
            for i = 1, 3 do
                local sf     = stopFrames[i]
                local active = (i == GradColorPickerInfo.ActiveStop)
                sf.frame.BackgroundColor3       = GradColorPickerInfo.Values[i]
                sf.frame.BackgroundTransparency = GradColorPickerInfo.Transparencies[i]
                sf.outer.BorderColor3           = active and Library.AccentColor or Library.OutlineColor
                if sf.label then sf.label.TextColor3 = active and Library.AccentColor or Library.FontColor end
            end
        end

        local function RefreshSwatch()
            local cseq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   GradColorPickerInfo.Values[1]),
                ColorSequenceKeypoint.new(0.5, GradColorPickerInfo.Values[2]),
                ColorSequenceKeypoint.new(1,   GradColorPickerInfo.Values[3]),
            })
            local tseq = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   GradColorPickerInfo.Transparencies[1]),
                NumberSequenceKeypoint.new(0.5, GradColorPickerInfo.Transparencies[2]),
                NumberSequenceKeypoint.new(1,   GradColorPickerInfo.Transparencies[3]),
            })
            SwatchGrad.Color        = cseq
            SwatchGrad.Transparency = tseq
            PreviewGrad.Color       = cseq
            PreviewGrad.Transparency = tseq
        end

        function GradColorPickerInfo:Display()
            local col = Color3.fromHSV(GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib)
            GradColorPickerInfo.Values[GradColorPickerInfo.ActiveStop] = col
            SatValMap.BackgroundColor3 = Color3.fromHSV(GradColorPickerInfo.Hue, 1, 1)
            CursorOuter.Position = UDim2.new(GradColorPickerInfo.Sat, 0, 1 - GradColorPickerInfo.Vib, 0)
            HexInputBox.Text = '#'..col:ToHex()
            RgbInputBox.Text = math.floor(col.R*255)..','..math.floor(col.G*255)..','..math.floor(col.B*255)
            if TransparencyInner then TransparencyInner.BackgroundColor3 = col end
            RefreshStopSwatches()
            RefreshSwatch()
            Library:SafeCallback(GradColorPickerInfo.Callback, GradColorPickerInfo.Values, GradColorPickerInfo.Transparencies)
            Library:SafeCallback(GradColorPickerInfo.Changed,  GradColorPickerInfo.Values, GradColorPickerInfo.Transparencies)
        end

        function GradColorPickerInfo:SetStop(i)
            GradColorPickerInfo.ActiveStop = i
            GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib = Color3.toHSV(GradColorPickerInfo.Values[i])
            TitleLabel.Text = GradColorPickerInfo.Title..' ('..STOP_NAMES[i]..')'
            GradColorPickerInfo:Display()
        end

        function GradColorPickerInfo:Show()
            for f in next, Library.OpenedFrames do
                if f.Name == 'GradColor' or f.Name == 'GradColorBlocker' then f.Visible = false; Library.OpenedFrames[f] = nil end
            end
            UpdatePickerPos()
            Blocker.Visible = true
            PickerFrameOuter.Visible = true
            StartPickerCorrecting()
            Library.OpenedFrames[PickerFrameOuter] = true
            Library.OpenedFrames[Blocker] = true
        end
        function GradColorPickerInfo:Hide()
            Blocker.Visible = false
            PickerFrameOuter.Visible = false
            Library.OpenedFrames[PickerFrameOuter] = nil
            Library.OpenedFrames[Blocker] = nil
        end
        function GradColorPickerInfo:SetValues(vals, transes)
            for i = 1, 3 do
                if vals[i] then GradColorPickerInfo.Values[i] = vals[i] end
                if transes and transes[i] then GradColorPickerInfo.Transparencies[i] = transes[i] end
            end
            GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib = Color3.toHSV(GradColorPickerInfo.Values[GradColorPickerInfo.ActiveStop])
            GradColorPickerInfo:Display()
        end
        function GradColorPickerInfo:OnChanged(fn)
            GradColorPickerInfo.Changed = fn
            fn(GradColorPickerInfo.Values, GradColorPickerInfo.Transparencies)
        end

        local function markInner()
            GradColorPickerInfo.suppressClose = true
        end
        PickerFrameInner.InputBegan:Connect(function(Input)
            if Library:IsPointerInput(Input) then markInner() end
        end)

        HandleDrag(SatValMap, function(x,y)
            markInner()
            local ap, as = SatValMap.AbsolutePosition, SatValMap.AbsoluteSize
            GradColorPickerInfo.Sat = math.clamp((x - ap.X) / as.X, 0, 1)
            GradColorPickerInfo.Vib = 1 - math.clamp((y - ap.Y) / as.Y, 0, 1)
            GradColorPickerInfo:Display()
        end, function() Library:AttemptSave() end, true)

        HandleDrag(HueInner, function(x,y)
            markInner()
            local ap, as = HueInner.AbsolutePosition, HueInner.AbsoluteSize
            GradColorPickerInfo.Hue = math.clamp((y - ap.Y) / as.Y, 0, 1)
            GradColorPickerInfo:Display()
        end, function() Library:AttemptSave() end, true)

        if TransparencyInner then
            HandleDrag(TransparencyInner, function(x,y)
                markInner()
                local ap, as = TransparencyInner.AbsolutePosition, TransparencyInner.AbsoluteSize
                GradColorPickerInfo.Transparencies[GradColorPickerInfo.ActiveStop] = 1 - math.clamp((x - ap.X) / as.X, 0, 1)
                GradColorPickerInfo:Display()
            end, function() Library:AttemptSave() end, true)
        end

        HexInputBox.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        RgbInputBox.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)

        HexInputBox.FocusLost:Connect(function(enter)
            if enter then
                local ok, c = pcall(Color3.fromHex, HexInputBox.Text)
                if ok then GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib = Color3.toHSV(c) end
            end
            GradColorPickerInfo:Display()
        end)

        RgbInputBox.FocusLost:Connect(function(enter)
            if enter then
                local r,g,b = RgbInputBox.Text:match('(%d+),(%d+),(%d+)')
                if r then GradColorPickerInfo.Hue, GradColorPickerInfo.Sat, GradColorPickerInfo.Vib = Color3.toHSV(Color3.fromRGB(r,g,b)) end
            end
            GradColorPickerInfo:Display()
        end)

        for i = 1, 3 do
            local handler = function(Input)
                if not Library:IsPointerInput(Input) then return end
                markInner()
                if Input.UserInputType ~= Enum.UserInputType.MouseButton2 then
                    GradColorPickerInfo:SetStop(i)
                end
            end
            stopFrames[i].frame.InputBegan:Connect(handler)
            stopFrames[i].outer.InputBegan:Connect(handler)
        end

        HexInputInner.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)
        RgbInputInner.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) then markInner() end end)

        Blocker.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            task.defer(function()
                if GradColorPickerInfo.suppressClose then
                    GradColorPickerInfo.suppressClose = false
                    return
                end
                GradColorPickerInfo:Hide()
            end)
        end)

        Swatch.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then return end
            if PickerFrameOuter.Visible then GradColorPickerInfo:Hide() else GradColorPickerInfo:Show() end
        end)

        PickerFrameOuter.Active = true
        PickerFrameInner.Active = true
        for _, d in ipairs(PickerFrameOuter:GetDescendants()) do
            if d:IsA('GuiObject') then d.ZIndex = d.ZIndex + 200 end
        end
        PickerFrameOuter.ZIndex = PickerFrameOuter.ZIndex + 200

        GradColorPickerInfo:Display()
        GradColorPickerInfo.DisplayFrame = Swatch
        if self.Addons then table.insert(self.Addons, GradColorPickerInfo) end
        Options[Idx] = GradColorPickerInfo
        return self
    end

    local function fmtKey(k)
        local short = { RightShift="RShift", LeftShift="LShift", RightControl="RCtrl", LeftControl="LCtrl" }
        return short[k] or k
    end

    function Funcs:AddKeyPicker(Idx, Info)
        Library:BuildTick()
        local ParentObj = self
        local TextLabelRef        = self.TextLabel
        assert(Info.Default, 'AddKeyPicker: Missing default value.')

        local KeybindInfo = {
            Value            = Info.Default;
            Toggled          = false;
            Mode             = Info.Mode or 'Toggle';
            Type             = 'KeyPicker';
            Callback         = Info.Callback       or function() end;
            ChangedCallback  = Info.ChangedCallback or function() end;
            SyncToggleState  = Info.SyncToggleState or false;
        }
        if KeybindInfo.SyncToggleState then Info.Modes = { 'Toggle' }; Info.Mode = 'Toggle' end

        local KeyPickOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Size = UDim2.fromOffset(S(44), S(15)); ZIndex = 15; Active = true; Parent = TextLabelRef })
        local KeyPickInner  = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 16; Parent = KeyPickOuter })
        Library:AddToRegistry(KeyPickInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })
        local DisplayLabel = Library:CreateLabel({ Size = UDim2.new(1,0,1,0); TextSize = S(12); Text = fmtKey(Info.Default); TextScaled = true; ZIndex = 17; Parent = KeyPickInner })

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' }
        local ModeOuter = Library:Create('Frame', {
            Active        = true;
            BorderColor3  = Color3.new(0,0,0);
            Size          = UDim2.fromOffset(S(60), #Modes * S(15) + S(4));
            Visible       = false;
            ZIndex        = 14;
            Parent        = ScreenGui;
        })
        local ModeOuterScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = ModeOuter })
        table.insert(Library.ThemeScales, ModeOuterScale)
        local ModeInner = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 15; Parent = ModeOuter })
        Library:AddToRegistry(ModeInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })
        Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Vertical; SortOrder = Enum.SortOrder.LayoutOrder; Parent = ModeInner })

        local function UpdateModePos()
            local scale = Library.UIScaleValue or 1.0
            ModeOuter.Position = UDim2.fromOffset((TextLabelRef.AbsolutePosition.X + TextLabelRef.AbsoluteSize.X + S(4)) / scale, (TextLabelRef.AbsolutePosition.Y + 1) / scale)
        end
        TextLabelRef:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdateModePos)
        UpdateModePos()

        local HudBindLabel = Library:CreateLabel({ TextXAlignment = Enum.TextXAlignment.Left; Size = UDim2.new(1,0,0,S(18)); TextSize = S(12); Visible = false; ZIndex = 110; Parent = Library.KeybindContainer }, true)

        local ModeButtonList = {}
        for _, mode in ipairs(Modes) do
            local btn = {}
            local lbl = Library:CreateLabel({ Active = false; Size = UDim2.new(1,0,0,S(15)); TextSize = S(12); Text = mode; ZIndex = 16; Parent = ModeInner })
            function btn:Select()
                for _, b in next, ModeButtonList do b:Deselect() end
                KeybindInfo.Mode = mode
                lbl.TextColor3 = Library.AccentColor
                Library.RegistryMap[lbl].Properties.TextColor3 = 'AccentColor'
                ModeOuter.Visible = false
            end
            function btn:Deselect()
                lbl.TextColor3 = Library.FontColor
                Library.RegistryMap[lbl].Properties.TextColor3 = 'FontColor'
            end
            lbl.InputBegan:Connect(function(Input)
                if Library:IsPointerInput(Input) then btn:Select(); Library:AttemptSave() end
            end)
            if mode == KeybindInfo.Mode then btn:Select() end
            ModeButtonList[mode] = btn
        end

        function KeybindInfo:Update()
            if Info.NoUI then return end
            local state = KeybindInfo:GetState()
            local showInList = false
            if ParentObj.Type == 'Toggle' then
                showInList = ParentObj.Value
            else
                showInList = state
            end

            HudBindLabel.Text    = string.format('[%s] %s', fmtKey(KeybindInfo.Value), Library:TranslateString(Info.Text or ''))
            HudBindLabel.Visible = showInList
            HudBindLabel.TextColor3 = state and Library.AccentColor or Library.FontColor
            Library.RegistryMap[HudBindLabel].Properties.TextColor3 = state and 'AccentColor' or 'FontColor'
            
            local ys, xs = 0, 0
            for _, ch in ipairs(Library.KeybindContainer:GetChildren()) do
                if ch:IsA('TextLabel') and ch.Visible then
                    ys = ys + S(18)
                    xs = math.max(xs, ch.TextBounds.X)
                end
            end
            Library.KeybindFrame.Size = UDim2.fromOffset(math.max(xs + S(16), S(210)), ys + S(26))
        end

        function KeybindInfo:GetState()
            if KeybindInfo.Mode == 'Always' then
                return ParentObj.Type == 'Toggle' and ParentObj.Value or true
            end
            if KeybindInfo.Mode == 'Hold' then
                if KeybindInfo.Value == 'None' then return false end
                local down
                if KeybindInfo.Value == 'MB1' then down = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                elseif KeybindInfo.Value == 'MB2' then down = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                else down = KeybindInfo.Value ~= nil and Enum.KeyCode[KeybindInfo.Value] and Services.UserInputService:IsKeyDown(Enum.KeyCode[KeybindInfo.Value]) or false end
                return ParentObj.Type == 'Toggle' and ParentObj.Value and down or down
            end
            return ParentObj.Type == 'Toggle' and ParentObj.Value and KeybindInfo.Toggled or KeybindInfo.Toggled
        end

        function KeybindInfo:SetValue(data)
            DisplayLabel.Text = fmtKey(data[1]); KeybindInfo.Value = data[1]
            if ModeButtonList[data[2]] then ModeButtonList[data[2]]:Select() end
            KeybindInfo:Update()
        end
        function KeybindInfo:OnClick(fn)    KeybindInfo.Clicked = fn end
        function KeybindInfo:OnChanged(fn)  KeybindInfo.Changed = fn; fn(KeybindInfo.Value) end
        if ParentObj.Addons then table.insert(ParentObj.Addons, KeybindInfo) end

        function KeybindInfo:DoClick()
            if ParentObj.Type == 'Toggle' and KeybindInfo.SyncToggleState then ParentObj:SetValue(not ParentObj.Value) end
            Library:SafeCallback(KeybindInfo.Callback, KeybindInfo.Toggled)
            Library:SafeCallback(KeybindInfo.Clicked,  KeybindInfo.Toggled)
        end

        local Picking = false
        KeyPickOuter.InputBegan:Connect(function(Input)
            if Library:HasOpenedFrames() then return end
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                ModeOuter.Visible = true; return
            end
            if not Library:IsPointerInput(Input) then return end
            Picking = true; DisplayLabel.Text = ''
            local dots = ''
            local dotTask = task.spawn(function()
                while Picking do
                    dots = #dots >= 3 and '' or dots..'.'
                    DisplayLabel.Text = dots
                    task.wait(0.3)
                end
            end)
            task.wait(0.15)
            local ev
            ev = Services.UserInputService.InputBegan:Connect(function(In)
                local key
                if In.UserInputType == Enum.UserInputType.Keyboard    then key = In.KeyCode.Name
                elseif In.UserInputType == Enum.UserInputType.MouseButton1 then key = 'MB1'
                elseif In.UserInputType == Enum.UserInputType.MouseButton2 then key = 'MB2' end
                if not key then return end
                Picking = false; task.cancel(dotTask)
                DisplayLabel.Text = fmtKey(key); KeybindInfo.Value = key
                Library:SafeCallback(KeybindInfo.ChangedCallback, In.KeyCode or In.UserInputType)
                Library:SafeCallback(KeybindInfo.Changed,         In.KeyCode or In.UserInputType)
                Library:AttemptSave()
                ev:Disconnect()
            end)
        end)

        Library:GiveSignal(Services.UserInputService.InputBegan:Connect(function(Input)
            if not Picking then
                if KeybindInfo.Mode == 'Toggle' then
                    local k = KeybindInfo.Value
                    if k == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1 then KeybindInfo.Toggled = not KeybindInfo.Toggled; KeybindInfo:DoClick()
                    elseif k == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then KeybindInfo.Toggled = not KeybindInfo.Toggled; KeybindInfo:DoClick()
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == k then KeybindInfo.Toggled = not KeybindInfo.Toggled; KeybindInfo:DoClick() end
                end
                KeybindInfo:Update()
            end
            if Library:IsPointerInput(Input) then
                local loc = Services.UserInputService:GetMouseLocation()
                local px = loc.X
                local py = loc.Y
                local ap, as = ModeOuter.AbsolutePosition, ModeOuter.AbsoluteSize
                if px < ap.X or px > ap.X+as.X or py < ap.Y-S(20)-1 or py > ap.Y+as.Y then
                    ModeOuter.Visible = false
                end
            end
        end))
        Library:GiveSignal(Services.UserInputService.InputEnded:Connect(function() if not Picking then KeybindInfo:Update() end end))
        KeybindInfo:Update()
        Library:RegisterTRCallback(function()
            if HudBindLabel and HudBindLabel.Parent then
                KeybindInfo:Update()
            end
        end)
        Options[Idx] = KeybindInfo
        return self
    end

    BaseAddons.__index = Funcs
end

do
    local Funcs = {}

    function Funcs:AddBlank(sz)
        Library:Create('Frame', { BackgroundTransparency=1; Size=UDim2.new(1,0,0,S(sz)); ZIndex=1; Parent=self.Container })
    end

    function Funcs:AddLabel(Text, DoesWrap)
        Library:BuildTick()
        local Label = {}
        local Groupbox    = self
        local TextLabelRef    = Library:CreateLabel({
            Size            = UDim2.new(1, -S(4), 0, S(15));
            TextSize        = S(14);
            Text            = Text;
            TextWrapped     = DoesWrap or false;
            RichText        = true;
            TextXAlignment  = Enum.TextXAlignment.Left;
            ZIndex          = 5;
            Parent          = Groupbox.Container;
        })
        if DoesWrap then
            local _, y = Library:GetTextBounds(Text, Library.Font, S(14), Vector2.new(TextLabelRef.AbsoluteSize.X, math.huge))
            TextLabelRef.Size = UDim2.new(1, -S(4), 0, y)
        else
            Library:Create('UIListLayout', { Padding=UDim.new(0,S(4)); FillDirection=Enum.FillDirection.Horizontal; HorizontalAlignment=Enum.HorizontalAlignment.Right; SortOrder=Enum.SortOrder.LayoutOrder; Parent=TextLabelRef })
        end
        Label.TextLabel = TextLabelRef
        Label.Container = Groupbox.Container
        function Label:SetText(t)
            Library:SetTRText(TextLabelRef, tostring(t or ""))
            if DoesWrap then
                local _, y = Library:GetTextBounds(TextLabelRef.Text, Library.Font, S(14), Vector2.new(TextLabelRef.AbsoluteSize.X, math.huge))
                TextLabelRef.Size = UDim2.new(1, -S(4), 0, y)
            end
            Groupbox:Resize()
        end
        if not DoesWrap then setmetatable(Label, BaseAddons) end
        Groupbox:AddBlank(5); Groupbox:Resize()
        return Label
    end

    function Funcs:AddDynamicList(Info)
        local Groupbox       = self
        local ROW_H    = S(20)
        local entries  = {}
        local onChange  = Info and Info.OnChanged or function() end
        local textOnly  = Info and Info.TextOnly or false

        local Wrap = Library:Create('Frame', {
            BackgroundTransparency  = 1;
            Size                    = UDim2.new(1, -S(4), 0, 0);
            ZIndex                  = 1;
            Parent                  = Groupbox.Container;
        })
        local WrapLayout = Library:Create('UIListLayout', {
            FillDirection  = Enum.FillDirection.Vertical;
            SortOrder      = Enum.SortOrder.LayoutOrder;
            Parent         = Wrap;
        })

        local function resizeWrap()
            local h = 0
            for _, c in ipairs(Wrap:GetChildren()) do
                if not c:IsA('UIListLayout') and c.Visible then h = h + c.AbsoluteSize.Y end
            end
            Wrap.Size = UDim2.new(1, -S(4), 0, h)
            Groupbox:Resize()
        end

        local function fireChanged()
            local out = {}
            if textOnly then
                for _, e in ipairs(entries) do
                    if e.textVal ~= "" then out[#out+1] = e.textVal end
                end
            else
                for _, e in ipairs(entries) do
                    local txt = e.textVal
                    local pct = tonumber(e.chanceVal) or 0
                    if txt ~= "" and pct > 0 then
                        out[#out+1] = { text = txt, chance = pct }
                    end
                end
            end
            Library:SafeCallback(onChange, out)
        end

        local function makeRow(defaultText, defaultChance)
            local entry = { textVal = defaultText or "", chanceVal = tostring(defaultChance or 50) }

            local Row = Library:Create('Frame', {
                BackgroundTransparency  = 1;
                Size                    = UDim2.new(1, 0, 0, ROW_H);
                ZIndex                  = 5;
                Parent                  = Wrap;
            })
            Library:Create('UIListLayout', {
                FillDirection      = Enum.FillDirection.Horizontal;
                VerticalAlignment  = Enum.VerticalAlignment.Center;
                SortOrder          = Enum.SortOrder.LayoutOrder;
                Parent             = Row;
            })

            local txtW = textOnly and math.floor(Wrap.AbsoluteSize.X * 0.84) or math.floor(Wrap.AbsoluteSize.X * 0.58)
            local pctW = math.floor(Wrap.AbsoluteSize.X * 0.22)
            local btnW = math.floor(Wrap.AbsoluteSize.X * 0.16)

            local function makeBox(w, defText)
                local Outer = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(0,w,1,0); ZIndex=5; Parent=Row })
                local Inner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=Outer })
                Library:AddToRegistry(Inner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
                Library:OnHighlight(Outer, Outer, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
                Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=Inner })
                local Clip = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,S(3),0,0); Size=UDim2.new(1,-S(3),1,0); ZIndex=7; Parent=Inner })
                local Box = Library:Create('TextBox', {
                    BackgroundTransparency  = 1; Size=UDim2.new(1,0,1,0);
                    Font                    = Library.Font; Text=defText or ""; TextColor3=Library.FontColor;
                    TextSize                = S(13); TextStrokeTransparency=0; TextXAlignment=Enum.TextXAlignment.Left;
                    PlaceholderColor3       = Color3.fromRGB(150,150,150); ZIndex=7; Parent=Clip;
                })
                Library:AddToRegistry(Box, { TextColor3='FontColor' })
                return Box
            end

            local TxtBox = makeBox(txtW, entry.textVal)
            local PercentBox = not textOnly and makeBox(pctW, entry.chanceVal) or nil

            local ButtonOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(0,btnW,1,0); ZIndex=5; Parent=Row })
            local ButtonInner  = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=ButtonOuter })
            Library:AddToRegistry(ButtonInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
            Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=ButtonInner })
            Library:CreateLabel({ Size=UDim2.new(1,0,1,0); Text="-"; TextSize=S(14); ZIndex=7; Parent=ButtonInner })
            Library:OnHighlight(ButtonOuter, ButtonOuter, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })

            TxtBox:GetPropertyChangedSignal('Text'):Connect(function()
                entry.textVal = TxtBox.Text; fireChanged()
            end)
            if PercentBox then
                PercentBox:GetPropertyChangedSignal('Text'):Connect(function()
                    local n = tonumber(PercentBox.Text)
                    if n then entry.chanceVal = tostring(math.clamp(math.floor(n), 0, 100)) end
                    fireChanged()
                end)
                PercentBox.FocusLost:Connect(function()
                    local n = tonumber(PercentBox.Text) or 0
                    n = math.clamp(math.floor(n), 0, 100)
                    PercentBox.Text = tostring(n)
                    entry.chanceVal = tostring(n)
                end)
            end

            ButtonOuter.InputBegan:Connect(function(inp)
                if not Library:IsPointerInput(inp) or Library:MouseIsOverOpenedFrame() then return end
                for i, e in ipairs(entries) do
                    if e == entry then table.remove(entries, i); break end
                end
                Row:Destroy()
                resizeWrap(); fireChanged()
            end)

            entries[#entries+1] = entry
            resizeWrap()
            return entry
        end

        local AddButtonRow = Library:Create('Frame', {
            BorderColor3  = Color3.new(0,0,0);
            Size          = UDim2.new(1, 0, 0, ROW_H);
            ZIndex        = 5;
            Parent        = Groupbox.Container;
        })
        local AddButtonInner = Library:Create('Frame', {
            BackgroundColor3  = Library.MainColor;
            BorderColor3      = Library.OutlineColor;
            BorderMode        = Enum.BorderMode.Inset;
            Size              = UDim2.new(1,0,1,0); ZIndex=6; Parent=AddButtonRow
        })
        Library:AddToRegistry(AddButtonInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=AddButtonInner })
        Library:CreateLabel({ Size=UDim2.new(1,0,1,0); Text="+ add fact"; TextSize=S(13); ZIndex=7; Parent=AddButtonInner })
        Library:OnHighlight(AddButtonRow, AddButtonRow, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        AddButtonRow.InputBegan:Connect(function(inp)
            if not Library:IsPointerInput(inp) or Library:MouseIsOverOpenedFrame() then return end
            makeRow("", 50)
            fireChanged()
        end)

        local DropdownList = { TextOnly = textOnly }
        function DropdownList:GetEntries() return entries end
        function DropdownList:AddEntry(txt, pct) makeRow(txt, textOnly and nil or pct); fireChanged() end
        function DropdownList:SetEntries(list)
            for _, c in ipairs(Wrap:GetChildren()) do
                if not c:IsA('UIListLayout') then c:Destroy() end
            end
            table.clear(entries)
            for _, v in ipairs(list) do
                if textOnly then makeRow(tostring(v))
                else makeRow(v.text or "", v.chance or 50) end
            end
            fireChanged()
        end
        Groupbox:AddBlank(3); Groupbox:Resize()
        return DropdownList
    end

    function Funcs:AddDivider() end

    function Funcs:AddButton(...)
        Library:BuildTick()
        local Button = {}
        local args = { ... }
        local info = type(args[1]) == 'table' and args[1] or { Text=args[1]; Func=args[2] }
        Button.Text = info.Text; Button.Func = info.Func; Button.DoubleClick = info.DoubleClick; Button.Tooltip = info.Tooltip
        assert(type(Button.Func) == 'function', 'AddButton: `Func` callback is missing.')

        local Groupbox = self

        local function MakeBtn(b)
            local o = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size = UDim2.new(1,-S(4),0,S(20)); ZIndex=5 })
            local i = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex=6; Parent=o })
            local l = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(14); Text=b.Text; ZIndex=6; Parent=i })
            Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=i })
            Library:AddToRegistry(o, { BorderColor3='Black' })
            Library:AddToRegistry(i, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
            Library:OnHighlight(o, o, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
            return o, i, l
        end

        local function InitBtnEvents(b)
            local function valid(Input) return Library:IsPointerInput(Input) and not Library:HasOpenedFrames() end
            b.Outer.InputBegan:Connect(function(Input)
                if not valid(Input) or b.Locked then return end
                if b.DoubleClick then
                    b.Label.TextColor3 = Library.AccentColor
                    Library:SetTRText(b.Label, 'Are you sure?')
                    b.Locked = true
                    local clicked = false
                    local c = b.Outer.InputBegan:Connect(function(In) if valid(In) then clicked = true end end)
                    task.wait(0.5); c:Disconnect()
                    b.Label.TextColor3 = Library.FontColor
                    Library:SetTRText(b.Label, b.Text)
                    task.defer(rawset, b, 'Locked', false)
                    if clicked then Library:SafeCallback(b.Func) end
                    return
                end
                Library:SafeCallback(b.Func)
            end)
        end

        Button.Outer, Button.Inner, Button.Label = MakeBtn(Button)
        Button.Outer.Parent = Groupbox.Container
        InitBtnEvents(Button)

        function Button:AddTooltip(t) if type(t)=='string' then Library:AddToolTip(t, self.Outer) end; return self end
        function Button:AddButton(...)
            local args2 = { ... }
            local info2 = type(args2[1])=='table' and args2[1] or { Text=args2[1]; Func=args2[2] }
            local Sub = { Text=info2.Text; Func=info2.Func; DoubleClick=info2.DoubleClick; Tooltip=info2.Tooltip }
            assert(type(Sub.Func)=='function', 'AddButton sub: missing Func')
            self.Outer.Size = UDim2.new(0.5, -S(3), 0, S(20))
            Sub.Outer, Sub.Inner, Sub.Label = MakeBtn(Sub)
            Sub.Outer.Position = UDim2.new(1, S(3), 0, 0)
            Sub.Outer.Size = UDim2.new(1, -S(2), 1, 0)
            Sub.Outer.Parent = self.Outer
            InitBtnEvents(Sub)
            function Sub:AddTooltip(t) if type(t)=='string' then Library:AddToolTip(t,self.Outer) end; return Sub end
            if type(Sub.Tooltip)=='string' then Sub:AddTooltip(Sub.Tooltip) end
            return Sub
        end
        if type(Button.Tooltip)=='string' then Button:AddTooltip(Button.Tooltip) end
        Groupbox:AddBlank(5); Groupbox:Resize()
        return Button
    end

    function Funcs:AddInput(Idx, Info)
        Library:BuildTick()
        assert(Info.Text, 'AddInput: Missing `Text`.')
        local Textbox = { Value=Info.Default or ''; Numeric=Info.Numeric; Finished=Info.Finished; Type='Input'; Callback=Info.Callback or function() end }
        local Groupbox = self
        Library:CreateLabel({ Size=UDim2.new(1,0,0,S(15)); TextSize=S(14); Text=Info.Text; TextXAlignment=Enum.TextXAlignment.Left; ZIndex=5; Parent=Groupbox.Container })
        Groupbox:AddBlank(1)
        local BoxHeight = S(20)
        local Outer = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-S(4),0,BoxHeight); ZIndex=5; Parent=Groupbox.Container })
        local Inner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=Outer })
        Library:AddToRegistry(Inner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:OnHighlight(Outer, Outer, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=Inner })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, Outer) end
        local Clip = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,S(5),0,0); Size=UDim2.new(1,-S(5),1,0); ZIndex=7; Parent=Inner })
        local Box  = Library:Create('TextBox', {
            BackgroundTransparency  = 1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(5,1);
            Font                    = Library.Font; PlaceholderColor3=Color3.fromRGB(190,190,190); PlaceholderText=Info.Placeholder or '';
            Text                    = Info.Default or ''; TextColor3=Library.FontColor; TextSize=S(14); TextStrokeTransparency=0;
            TextXAlignment          = Enum.TextXAlignment.Left; ZIndex=7; Parent=Clip; ClearTextOnFocus=false;
        })
        Library:AddToRegistry(Box, { TextColor3='FontColor' })
        if type(Info.Placeholder) == 'string' and Info.Placeholder ~= '' then
            Library:SetTRProperty(Box, 'PlaceholderText', Info.Placeholder)
        end

        function Textbox:SetValue(t)
            if Info.MaxLength and #t > Info.MaxLength then t = t:sub(1, Info.MaxLength) end
            if Textbox.Numeric and not tonumber(t) and #t > 0 then t = Textbox.Value end
            Textbox.Value = t; Box.Text = t
            Library:SafeCallback(Textbox.Callback, t)
            Library:SafeCallback(Textbox.Changed,  t)
        end
        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter) if enter then Textbox:SetValue(Box.Text); Library:AttemptSave() end end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function() Textbox:SetValue(Box.Text); Library:AttemptSave() end)
        end

        local function UpdateScroll()
            local pad = 2; local rev = Clip.AbsoluteSize.X
            if not Box:IsFocused() or Box.TextBounds.X <= rev - 2*pad then
                Box.Position = UDim2.fromOffset(pad, 0)
            else
                local cur = Box.CursorPosition
                if cur ~= -1 then
                    local w = Services.TextService:GetTextSize(Box.Text:sub(1,cur-1), Box.TextSize, Box.Font, Vector2.new(math.huge,math.huge)).X
                    local cp = Box.Position.X.Offset + w
                    if cp < pad then Box.Position = UDim2.fromOffset(pad-w, 0)
                    elseif cp > rev-pad-1 then Box.Position = UDim2.fromOffset(rev-w-pad-1, 0) end
                end
            end
        end
        Box:GetPropertyChangedSignal('Text'):Connect(UpdateScroll)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(UpdateScroll)
        Box.FocusLost:Connect(UpdateScroll); Box.Focused:Connect(UpdateScroll)
        task.spawn(UpdateScroll)

        function Textbox:OnChanged(fn) Textbox.Changed = fn; fn(Textbox.Value) end
        Groupbox:AddBlank(5); Groupbox:Resize()
        Options[Idx] = Textbox
        return Textbox
    end

    function Funcs:AddToggle(Idx, Info)
        Library:BuildTick()
        assert(Info.Text, 'AddToggle: Missing `Text`.')
        local Toggle = { Value=Info.Default or false; Type='Toggle'; Callback=Info.Callback or function() end; Addons={}; Risky=Info.Risky }
        local Groupbox = self
        local boxSz = S(13)
        local TOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.fromOffset(boxSz,boxSz); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(TOuter, { BorderColor3='Black' })
        local TInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=TOuter })
        Library:AddToRegistry(TInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        local TLabel = Library:CreateLabel({ Size=UDim2.new(0,S(245),1,0); Position=UDim2.new(1,S(6),0,0); TextSize=S(14); Text=Info.Text; TextXAlignment=Enum.TextXAlignment.Left; ZIndex=6; Parent=TInner })
        Library:Create('UIListLayout', { Padding=UDim.new(0,S(4)); FillDirection=Enum.FillDirection.Horizontal; HorizontalAlignment=Enum.HorizontalAlignment.Right; SortOrder=Enum.SortOrder.LayoutOrder; Parent=TLabel })
        local function syncTLW()
            local cw = Groupbox.Container.AbsoluteSize.X
            if cw > 0 then TLabel.Size = UDim2.new(0, math.max(0, cw - S(4) - boxSz - S(6)), 1, 0) end
        end
        Groupbox.Container:GetPropertyChangedSignal('AbsoluteSize'):Connect(syncTLW)
        task.defer(syncTLW)
        local HitW = S(155)
        local HitRegion = Library:Create('Frame', { BackgroundTransparency=1; Size=UDim2.fromOffset(HitW,boxSz); ZIndex=8; Parent=TOuter })
        Library:OnHighlight(HitRegion, TOuter, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, HitRegion) end

        function Toggle:Display()
            TInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor
            TInner.BorderColor3     = Toggle.Value and Library.AccentColorDark or Library.OutlineColor
            Library.RegistryMap[TInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor'
            Library.RegistryMap[TInner].Properties.BorderColor3     = Toggle.Value and 'AccentColorDark' or 'OutlineColor'
        end
        function Toggle:UpdateColors() Toggle:Display() end
        function Toggle:OnChanged(fn)  Toggle.Changed = fn; fn(Toggle.Value) end
        function Toggle:SetValue(b)
            b = not not b; Toggle.Value = b; Toggle:Display()
            for _, addon in next, Toggle.Addons do
                if addon.Type == 'KeyPicker' and addon.SyncToggleState then addon.Toggled = b; addon:Update() end
            end
            Library:SafeCallback(Toggle.Callback, b)
            Library:SafeCallback(Toggle.Changed,  b)
            Library:UpdateDependencyBoxes()
        end

        HitRegion.InputBegan:Connect(function(Input)
            if Library:IsPointerInput(Input) and not Library:HasOpenedFrames() then
                local loc = Services.UserInputService:GetMouseLocation()
                local px = loc.X
                local py = loc.Y
                for _, addon in next, Toggle.Addons do
                    local frame = addon.DisplayFrame
                    if frame and frame.Parent then
                        local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
                        if px >= ap.X and px <= ap.X + as.X and py >= ap.Y and py <= ap.Y + as.Y then
                            return
                        end
                    end
                end
                Toggle:SetValue(not Toggle.Value); Library:AttemptSave()
            end
        end)

        if Toggle.Risky then
            Library:RemoveFromRegistry(TLabel)
            TLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(TLabel, { TextColor3='RiskColor' })
        end
        Toggle:Display()
        Groupbox:AddBlank(Info.BlankSize or 7); Groupbox:Resize()
        Toggle.TextLabel = TLabel; Toggle.Container = Groupbox.Container
        setmetatable(Toggle, BaseAddons)
        Toggles[Idx] = Toggle
        Library:UpdateDependencyBoxes()
        return Toggle
    end

    function Funcs:AddSlider(Idx, Info)
        Library:BuildTick()
        assert(Info.Default ~= nil, 'AddSlider: Missing default.')
        assert(Info.Text,           'AddSlider: Missing text.')
        assert(Info.Min ~= nil,     'AddSlider: Missing min.')
        assert(Info.Max ~= nil,     'AddSlider: Missing max.')
        assert(Info.Rounding ~= nil,'AddSlider: Missing rounding.')
        local Slider = { Value=Info.Default; Min=Info.Min; Max=Info.Max; Rounding=Info.Rounding; MaxSize=S(232); Type='Slider'; Callback=Info.Callback or function() end }
        local Groupbox = self
        local slH = S(13)
        local SOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-S(4),0,slH); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(SOuter, { BorderColor3='Black' })
        local SInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=SOuter })
        Library:AddToRegistry(SInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        SInner:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            local w = SInner.AbsoluteSize.X
            if w > 0 then Slider.MaxSize = w; Slider:Display() end
        end)
        local Fill = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderColor3=Library.AccentColorDark; Size=UDim2.new(0,0,1,0); ZIndex=7; Parent=SInner })
        Library:AddToRegistry(Fill, { BackgroundColor3='AccentColor'; BorderColor3='AccentColorDark' })
        local HideBR = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(1,0,0,0); Size=UDim2.new(0,1,1,0); ZIndex=8; Parent=Fill })
        Library:AddToRegistry(HideBR, { BackgroundColor3='AccentColor' })
        local DropdownLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(13); Text=''; ZIndex=9; Parent=SInner })
        Library:OnHighlight(SOuter, SOuter, { BorderColor3='AccentColor' }, { BorderColor3='Black' })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, SOuter) end

        local function Round(v)
            if Slider.Rounding == 0 then return math.floor(v) end
            return tonumber(string.format('%.'..Slider.Rounding..'f', v))
        end
        function Slider:GetValueFromX(x)
            return Round(Library:MapValue(math.clamp(x,0,Slider.MaxSize), 0, Slider.MaxSize, Slider.Min, Slider.Max))
        end
        local CurX, TargetX, LerpConn = 0, 0, nil
        local function StopLerp() if LerpConn then LerpConn:Disconnect(); LerpConn = nil end end
        local function ApplyFill(px)
            px = math.floor(px + 0.5)
            Fill.Size = UDim2.new(0, px, 1, 0)
            HideBR.Visible = not (px >= Slider.MaxSize or px <= 0)
        end
        local function StartLerp()
            if LerpConn then return end
            LerpConn = Services.RunService.RenderStepped:Connect(function(dt)
                CurX = CurX + (TargetX - CurX) * math.clamp(dt * 12, 0, 1)
                if math.abs(TargetX - CurX) <= 0.5 then CurX = TargetX; ApplyFill(CurX); StopLerp(); return end
                ApplyFill(CurX)
            end)
        end
        function Slider:Display()
            local suf = Info.Suffix or ''
            DropdownLabel.Text = Library:TranslateString(Info.Text)..': '..Slider.Value..suf
            TargetX = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize))
            StartLerp()
        end
        function Slider:UpdateColors()
            Fill.BackgroundColor3  = Library.AccentColor
            Fill.BorderColor3      = Library.AccentColorDark
        end
        function Slider:OnChanged(fn) Slider.Changed = fn; fn(Slider.Value) end
        function Slider:SetValue(n)
            n = math.clamp(tonumber(n) or Slider.Min, Slider.Min, Slider.Max)
            Slider.Value = n; Slider:Display()
            Library:SafeCallback(Slider.Callback, n)
            Library:SafeCallback(Slider.Changed,  n)
        end

        HandleDrag(SInner, function(x,y)
            local ap = Fill.AbsolutePosition
            local w = SInner.AbsoluteSize.X
            if w > 0 then Slider.MaxSize = w end
            local nx = math.clamp(x - ap.X, 0, Slider.MaxSize)
            local nv = Slider:GetValueFromX(nx)
            if nv ~= Slider.Value then
                Slider.Value = nv; Slider:Display()
                Library:SafeCallback(Slider.Callback, nv)
                Library:SafeCallback(Slider.Changed,  nv)
            end
        end, function() Library:AttemptSave() end)

        Slider:Display()
        Library:RegisterTRCallback(function()
            if DropdownLabel and DropdownLabel.Parent then
                Slider:Display()
            end
        end)
        Groupbox:AddBlank(Info.BlankSize or 6); Groupbox:Resize()
        Options[Idx] = Slider
        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        Library:BuildTick()
        if Info.SpecialType == 'Player' then Info.Values = GetPlayersString(); Info.AllowNull = true
        elseif Info.SpecialType == 'Team' then Info.Values = GetTeamsString(); Info.AllowNull = true end
        assert(Info.Values, 'AddDropdown: Missing Values.')
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default or AllowNull.')
        if not Info.Text then Info.Compact = true end

        local DropdownData = { Values=Info.Values; Value=Info.Multi and {}; Multi=Info.Multi; Type='Dropdown'; SpecialType=Info.SpecialType; Callback=Info.Callback or function() end }
        local Groupbox = self
        local RelOff = 0

        if not Info.Compact then
            Library:CreateLabel({ PreserveCase = true; Size=UDim2.new(1,0,0,S(10)); TextSize=S(14); Text=Info.Text; TextXAlignment=Enum.TextXAlignment.Left; TextYAlignment=Enum.TextYAlignment.Bottom; ZIndex=5; Parent=Groupbox.Container })
            Groupbox:AddBlank(3)
        end
        for _, el in ipairs(Groupbox.Container:GetChildren()) do
            if not el:IsA('UIListLayout') then RelOff = RelOff + el.Size.Y.Offset end
        end

        local ddH = S(20)
        local DropdownOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-S(4),0,ddH); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(DropdownOuter, { BorderColor3='Black' })
        local DropdownInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=DropdownOuter })
        Library:AddToRegistry(DropdownInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=DropdownInner })
        local Arrow = Library:CreateLabel({ PreserveCase=true; AnchorPoint=Vector2.new(0.5,0.5); BackgroundTransparency=1; Position=UDim2.new(1,-S(11),0.5,0); Size=UDim2.fromOffset(S(14),S(14)); Text='>'; TextSize=S(14); Font=Enum.Font.GothamBold; ZIndex=8; Parent=DropdownInner })
        local ItemClip  = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,S(4),0,0); Size=UDim2.new(1,-S(22),1,0); ZIndex=8; Parent=DropdownInner })
        local ItemLabel = Library:CreateLabel({ PreserveCase=true; Size=UDim2.new(1,0,1,0); TextSize=S(13); Text=''; TextXAlignment=Enum.TextXAlignment.Left; TextTruncate=Enum.TextTruncate.AtEnd; ZIndex=8; Parent=ItemClip })
        Library:OnHighlight(DropdownOuter, DropdownOuter, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, DropdownOuter) end

        local MAX = 8
        local itemH = S(20)
        -- Full-screen blocker behind the open list: sinks every click that isn't on the list
        -- itself, so a click can never fall through to a dropdown (or anything) behind it.
        local Blocker = Library:Create('Frame', { Name='DropdownBlocker'; Active=true; BackgroundTransparency=1; Position=UDim2.fromScale(0,0); Size=UDim2.fromScale(1,1); ZIndex=19; Visible=false; Parent=ScreenGui })
        local ListOuter = Library:Create('Frame', { Active=true; BorderColor3=Color3.new(0,0,0); Size=UDim2.fromOffset(200, MAX*itemH+2); ZIndex=20; Visible=false; Parent=ScreenGui })
        local ListOuterScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = ListOuter })
        table.insert(Library.ThemeScales, ListOuterScale)
        local ListInner  = Library:Create('Frame', { Active=true; BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=21; Parent=ListOuter })
        Library:AddToRegistry(ListInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        local Scroll = Library:Create('ScrollingFrame', {
            BackgroundTransparency  = 1; BorderSizePixel=0; CanvasSize=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,1,0); ZIndex=21; Parent=ListInner;
            TopImage                = 'rbxasset://textures/ui/Scroll/scroll-middle.png'; BottomImage='rbxasset://textures/ui/Scroll/scroll-middle.png';
            ScrollBarThickness      = 3; ScrollBarImageColor3=Library.AccentColor;
            ScrollingDirection      = Enum.ScrollingDirection.Y; ElasticBehavior=Enum.ElasticBehavior.Never;
        })
        Library:AddToRegistry(Scroll, { ScrollBarImageColor3='AccentColor' })
        Library:Create('UIListLayout', { Padding=UDim.new(0,0); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=Scroll })

        -- Best-effort initial guess (so the first frame isn't wildly off). The corrective
        -- loop below then pins the list exactly, regardless of how the UIScale behaves.
        local function UpdateListPos()
            if not DropdownOuter.Parent then return end
            local scale = Library.UIScaleValue or 1.0
            local ap  = DropdownOuter.AbsolutePosition
            local asz = DropdownOuter.AbsoluteSize
            ListOuter.Size     = UDim2.fromOffset(asz.X / scale, ListOuter.Size.Y.Offset)
            ListOuter.Position = UDim2.fromOffset(ap.X, ap.Y + asz.Y + 1)
        end

        -- Bulletproof placement: AbsolutePosition is the REAL rendered top-left. Whatever the
        -- UIScale does to position/size/pivot, we read where the list actually landed and nudge
        -- its offset until its top-left sits exactly at the dropdown's bottom-left. Runs only
        -- while the list is open and goes idle once it converges (error < 0.5px).
        local correcting = false
        local function StartCorrecting()
            if correcting then return end
            correcting = true
            task.spawn(function()
                while ListOuter.Visible and DropdownOuter.Parent do
                    local scale = Library.UIScaleValue or 1.0
                    local ap    = DropdownOuter.AbsolutePosition
                    local asz   = DropdownOuter.AbsoluteSize
                    local wantW = asz.X / scale
                    if math.abs(ListOuter.Size.X.Offset - wantW) > 0.5 then
                        ListOuter.Size = UDim2.fromOffset(wantW, ListOuter.Size.Y.Offset)
                    end
                    local cur = ListOuter.AbsolutePosition
                    local ex  = ap.X - cur.X
                    local ey  = (ap.Y + asz.Y + 1) - cur.Y
                    if math.abs(ex) > 0.5 or math.abs(ey) > 0.5 then
                        ListOuter.Position = UDim2.fromOffset(
                            ListOuter.Position.X.Offset + ex,
                            ListOuter.Position.Y.Offset + ey
                        )
                    end
                    Services.RunService.Heartbeat:Wait()
                end
                correcting = false
            end)
        end
        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdateListPos)
        DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(UpdateListPos)
        UpdateListPos()

        function DropdownData:Display()
            local s = ''
            if Info.Multi then
                for _, v in ipairs(DropdownData.Values) do
                    if DropdownData.Value[v] then s = s..Library:TranslateString(v)..', ' end
                end
                s = s:sub(1,-3)
            else
                s = DropdownData.Value and Library:TranslateString(DropdownData.Value) or ''
            end
            if #s > 30 then s = s:sub(1, 30) .. '...' end
            if s == '' then s = '...' end
            if ItemLabel and ItemLabel.Parent then ItemLabel.Text = s end
        end

        function DropdownData:GetActiveValues()
            if Info.Multi then local t={} for v in next,DropdownData.Value do t[#t+1]=v end; return t
            else return DropdownData.Value and 1 or 0 end
        end

        local Buttons = {}
        function DropdownData:SetValues()
            for _, ch in ipairs(Scroll:GetChildren()) do if not ch:IsA('UIListLayout') then ch:Destroy() end end
            Buttons = {}
            local count = 0
            for _, val in ipairs(DropdownData.Values) do
                count = count + 1
                local SliderBackFrame = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Middle; Size=UDim2.new(1,-1,0,itemH); ZIndex=23; Active=true; Parent=Scroll })
                Library:AddToRegistry(SliderBackFrame, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
                local SliderBarSelected = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BackgroundTransparency=0.75; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); Visible=false; ZIndex=24; Parent=SliderBackFrame })
                local SliderBarLabel = Library:CreateLabel({ PreserveCase = true; Active=false; Size=UDim2.new(1,-S(6),1,0); Position=UDim2.new(0,S(6),0,0); TextSize=S(13); Text=val; TextXAlignment=Enum.TextXAlignment.Left; ZIndex=25; Parent=SliderBackFrame })
                local selected = Info.Multi and DropdownData.Value[val] or (DropdownData.Value == val)
                local function UpdateBtn()
                    selected = Info.Multi and (DropdownData.Value[val] ~= nil) or (DropdownData.Value == val)
                    SliderBarSelected.Visible = false
                    SliderBarLabel.TextColor3 = selected and Library.AccentColor or Library.FontColor
                    Library.RegistryMap[SliderBarLabel].Properties.TextColor3 = selected and 'AccentColor' or 'FontColor'
                end
                if SliderBackFrame and SliderBackFrame.InputBegan then
                    SliderBackFrame.InputBegan:Connect(function(Input)
                        if not Library:IsPointerInput(Input) then return end
                        local want = not selected
                        if DropdownData:GetActiveValues() == 1 and not want and not Info.AllowNull then return end
                        if Info.Multi then
                            DropdownData.Value[val] = want or nil
                        else
                            DropdownData.Value = want and val or nil
                            for _, b in ipairs(Buttons) do b() end
                        end
                        UpdateBtn(); DropdownData:Display()
                        Library:SafeCallback(DropdownData.Callback, DropdownData.Value)
                        Library:SafeCallback(DropdownData.Changed,  DropdownData.Value)
                        Library:AttemptSave()
                    end)
                end
                UpdateBtn(); DropdownData:Display()
                table.insert(Buttons, UpdateBtn)
            end
            local y = math.clamp(count * itemH, 0, MAX * itemH) + 1
            ListOuter.Size = UDim2.fromOffset(ListOuter.Size.X.Offset, y)
            Scroll.CanvasSize = UDim2.new(0, 0, 0, count * itemH + 1)
            UpdateListPos()
        end

        function DropdownData:OpenDropdown()  UpdateListPos(); Blocker.Visible = true; ListOuter.Visible = true;  Library.OpenedFrames[ListOuter] = true;  Arrow.Rotation = 90; StartCorrecting() end
        function DropdownData:CloseDropdown() Blocker.Visible = false; ListOuter.Visible = false; Library.OpenedFrames[ListOuter] = nil;   Arrow.Rotation = 0  end
        function DropdownData:OnChanged(fn)   DropdownData.Changed = fn; fn(DropdownData.Value) end
        function DropdownData:SetValue(val)
            if DropdownData.Multi then
                local t = {}
                for v in next, val do if table.find(DropdownData.Values, v) then t[v] = true end end
                DropdownData.Value = t
            else
                DropdownData.Value = table.find(DropdownData.Values, val) and val or nil
            end
            DropdownData:SetValues()
            DropdownData:Display()
            Library:SafeCallback(DropdownData.Callback, DropdownData.Value)
            Library:SafeCallback(DropdownData.Changed,  DropdownData.Value)
        end

        -- Header click toggles the dropdown. When already open, clicking the header again closes
        -- it. The MouseIsOverOpenedFrame guard only gates OPENING so a click that lands on this
        -- header THROUGH another dropdown's open list (Roblox fires InputBegan on every overlapping
        -- object, not just the top one) can't open this dropdown.
        DropdownOuter.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if ListOuter.Visible then DropdownData:CloseDropdown(); return end
            if Library:MouseIsOverOpenedFrame() then return end
            DropdownData:OpenDropdown()
        end)
        -- The Blocker also receives clicks that land on the list (InputBegan isn't sunk between
        -- GUI objects), so only close when the click is genuinely OUTSIDE the list. Clicks on the
        -- header itself are left to the header handler above so it can toggle the list closed —
        -- otherwise the Blocker would close it and the header would immediately reopen it.
        Blocker.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if Library:IsMouseOverFrame(ListOuter) then return end
            if Library:IsMouseOverFrame(DropdownOuter) then return end
            DropdownData:CloseDropdown()
        end)

        DropdownData:SetValues()

        local defaults = {}
        if type(Info.Default) == 'string' then
            local i = table.find(DropdownData.Values, Info.Default); if i then defaults[#defaults+1] = i end
        elseif type(Info.Default) == 'table' then
            for _, v in ipairs(Info.Default) do local i = table.find(DropdownData.Values, v); if i then defaults[#defaults+1] = i end end
        elseif type(Info.Default) == 'number' and DropdownData.Values[Info.Default] then
            defaults[#defaults+1] = Info.Default
        end
        for _, i in ipairs(defaults) do
            if Info.Multi then DropdownData.Value[DropdownData.Values[i]] = true else DropdownData.Value = DropdownData.Values[i]; break end
        end
        if #defaults > 0 then DropdownData:SetValues() end
        DropdownData:Display()
        Library:RegisterTRCallback(function()
            if ItemLabel and ItemLabel.Parent then
                DropdownData:Display()
            end
        end)
        Groupbox:AddBlank(Info.BlankSize or 5); Groupbox:Resize()
        Options[Idx] = DropdownData
        return DropdownData
    end

    function Funcs:AddDependencyBox()
        Library:BuildTick()
        local Depbox = { Dependencies = {} }
        local Groupbox = self
        local Holder = Library:Create('Frame', { BackgroundTransparency=1; Size=UDim2.new(1,0,0,0); Visible=false; Parent=Groupbox.Container })
        local Inner  = Library:Create('Frame', { BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Parent=Holder })
        local Layout = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=Inner })

        function Depbox:Resize()
            Holder.Size = UDim2.new(1,0,0, Layout.AbsoluteContentSize.Y)
            Groupbox:Resize()
        end
        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() Depbox:Resize() end)
        Holder:GetPropertyChangedSignal('Visible'):Connect(function() Depbox:Resize() end)

        function Depbox:Update()
            for _, dep in ipairs(Depbox.Dependencies) do
                if dep[1].Type == 'Toggle' and dep[1].Value ~= dep[2] then
                    Holder.Visible = false; Depbox:Resize(); return
                end
            end
            Holder.Visible = true; Depbox:Resize()
        end
        function Depbox:SetupDependencies(deps)
            Depbox.Dependencies = deps; Depbox:Update()
        end
        Depbox.Container = Inner
        setmetatable(Depbox, BaseGroupbox)
        table.insert(Library.DependencyBoxes, Depbox)
        return Depbox
    end



    function Funcs:AddInlineTabs(tabNames)
        local Groupbox = self
        local result = {}
        local tabObjects = {}

        local btnRow = Library:Create('Frame', {
            BackgroundTransparency  = 1;
            Size                    = UDim2.new(1, 0, 0, S(18));
            ZIndex                  = 5;
            Parent                  = Groupbox.Container;
        })
        Library:Create('UIListLayout', {
            FillDirection  = Enum.FillDirection.Horizontal;
            SortOrder      = Enum.SortOrder.LayoutOrder;
            Padding        = UDim.new(0, 0);
            Parent         = btnRow;
        })

        local count = #tabNames
        for i, name in ipairs(tabNames) do
            local Button = Library:Create('Frame', {
                BackgroundColor3  = Library.BackgroundColor;
                BorderColor3      = Color3.new(0, 0, 0);
                Size              = UDim2.new(1 / count, 0, 1, 0);
                ZIndex            = 6;
                Parent            = btnRow;
            })
            Library:AddToRegistry(Button, { BackgroundColor3 = 'BackgroundColor' })
            Library:CreateLabel({
                Size      = UDim2.new(1, 0, 1, 0);
                TextSize  = S(12);
                Text      = name;
                ZIndex    = 7;
                Parent    = Button;
            })
            local Underline = Library:Create('Frame', {
                BackgroundColor3  = Library.AccentColor;
                BorderSizePixel   = 0;
                Position          = UDim2.new(0, 0, 0, 0);
                Size              = UDim2.new(1, 0, 0, 1);
                Visible           = false;
                ZIndex            = 8;
                Parent            = Button;
            })
            Library:AddToRegistry(Underline, { BackgroundColor3 = 'AccentColor' })

            local ContentFrame = Library:Create('Frame', {
                BackgroundTransparency  = 1;
                Size                    = UDim2.new(1, 0, 0, 0);
                ZIndex                  = 1;
                Visible                 = false;
                Parent                  = Groupbox.Container;
            })
            local ll = Library:Create('UIListLayout', {
                FillDirection  = Enum.FillDirection.Vertical;
                SortOrder      = Enum.SortOrder.LayoutOrder;
                Parent         = ContentFrame;
            })
            ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                if ContentFrame.Visible then
                    ContentFrame.Size = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)
                    Groupbox:Resize()
                end
            end)

            local TBTab = { Container = ContentFrame, Name = name }
            function TBTab:InlineHide()
                ContentFrame.Visible    = false
                Underline.Visible = false
                ContentFrame.Size       = UDim2.new(1, 0, 0, 0)
            end
            function TBTab:Show()
                for _, t in next, tabObjects do t:InlineHide() end
                ContentFrame.Visible      = true
                Underline.Visible = true
                ContentFrame.Size         = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)
                Groupbox:Resize()
            end
            function TBTab:Resize()
                if ContentFrame.Visible then
                    ContentFrame.Size = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)
                    Groupbox:Resize()
                end
            end

            Button.InputBegan:Connect(function(Input)
                if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then
                    TBTab:Show()
                end
            end)

            setmetatable(TBTab, BaseGroupbox)
            tabObjects[i] = TBTab
            result[name]  = TBTab
        end

        Groupbox.InlineTabs = tabObjects

        if tabObjects[1] then tabObjects[1]:Show() end
        Groupbox:AddBlank(2)
        Groupbox:Resize()
        return result
    end

    BaseGroupbox.__index = Funcs
end

function Library:CreateWindow(...)
    local args   = { ... }
    local Config = type(args[1]) == 'table' and args[1] or { Title=args[1]; AutoShow=args[2] }
    if type(Config.Title) ~= 'string' then Config.Title = 'Window' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 8 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end
	if type(Config.GameName) ~= 'string' then Config.GameName = "Rivals" end

    local WinW, WinH
    do
        WinW = IsTouch and 380 or 780; WinH = IsTouch and 320 or 680
        if Config.Center then
            Config.AnchorPoint = Vector2.zero
            Config.Position    = UDim2.new(0.5, -math.floor(WinW / 2), 0.5, -math.floor(WinH / 2))
        else
            Config.AnchorPoint = Config.AnchorPoint or Vector2.zero
            if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
        end
        if typeof(Config.Size) == 'UDim2' then
            WinW = Config.Size.X.Offset; WinH = Config.Size.Y.Offset
        end
    end

    local Window = { Tabs = {} }
    Library.MainWindow = Window
    local defaultPosition = Config.Position

    local Outer = Library:Create('Frame', {
        AnchorPoint             = Config.AnchorPoint;
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Position                = Config.Position;
        Size                    = UDim2.fromOffset(WinW, WinH);
        Visible                 = false;
        ZIndex                  = 1;
        Parent                  = ScreenGui;
    })
    Library:MakeDraggable(Outer, S(25))

    local OuterScale = Library:Create('UIScale', {
        Scale   = Library.UIScaleValue or 1;
        Parent  = Outer;
    })
    Library.OuterScale = OuterScale

    local Inner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderSizePixel   = 0;
        Position          = UDim2.new(0,1,0,1);
        Size              = UDim2.new(1,-2,1,-2);
        ZIndex            = 1;
        Parent            = Outer;
    })
    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor' })

    local GameNameLabel = Library:CreateLabel({
        Position                = UDim2.new(1, -S(7), 0, 0);
        Size                    = UDim2.new(0, 0, 0, S(25));
        AnchorPoint             = Vector2.new(1, 0);
        Text                    = Config.GameName;
        TextColor3              = Library.AccentColor;
        TextStrokeTransparency  = 0.5;
        PreserveCase            = true;
        TextXAlignment          = Enum.TextXAlignment.Right;
        ZIndex                  = 1;
        Parent                  = Inner;
    })
    Library:AddToRegistry(GameNameLabel, { TextColor3 = 'AccentColor', Font = 'Font' })

    local TitleLabel = Library:CreateLabel({
        Position        = UDim2.new(0,0,0,0);
        Size            = UDim2.new(1,0,0,S(25));
        Text            = Config.Title;
        PreserveCase    = true;
        TextXAlignment  = Enum.TextXAlignment.Center;
        ZIndex          = 1;
        Parent          = Inner;
    })

    local function applyHandleSize(_size)
    end
    function Window:SetIconSize(size)
        applyHandleSize(size)
    end
    function Window:GetWindowSize()
        return { w = Outer.Size.X.Offset, h = Outer.Size.Y.Offset }
    end
    function Window:SetWindowSize(w, h, skipSave)
        local minW = 460
        local minH = 420
        local nw = math.max(math.floor(tonumber(w) or Outer.Size.X.Offset), minW)
        local nh = math.max(math.floor(tonumber(h) or Outer.Size.Y.Offset), minH)
        Outer.Size = UDim2.fromOffset(nw, nh)
        Library.MainWindowSize = { w = nw, h = nh }
        applyHandleSize(Library.IconSize)
        for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
        if not skipSave then
            Library:SaveThemeDefaults()
        end
    end
    function Window:ResetWindowPosition()
        Outer.Position = defaultPosition
    end
    function Window:ResetWindowSize()
        self:SetWindowSize(WinW, WinH, true)
    end
    do
        local scClip = Library:Create('Frame', {
            Active                  = true;
            AnchorPoint             = Vector2.new(1, 1);
            BackgroundTransparency  = 1;
            ClipsDescendants        = true;
            Position                = UDim2.new(1, 0, 1, 0);
            Size                    = UDim2.fromOffset(S(22), S(22));
            ZIndex                  = 300;
            Parent                  = Inner;
        })
        local scCircle = Library:Create('Frame', {
            AnchorPoint             = Vector2.new(0, 0);
            BackgroundColor3        = Library.AccentColor;
            BackgroundTransparency  = 0.4;
            BorderSizePixel         = 0;
            Position                = UDim2.fromOffset(0, 0);
            Size                    = UDim2.fromOffset(S(44), S(44));
            ZIndex                  = 301;
            Parent                  = scClip;
        })
        Library:AddToRegistry(scCircle, { BackgroundColor3 = 'AccentColor' })
        Library:Create('UICorner', { CornerRadius = UDim.new(1, 0); Parent = scCircle })
        Window.ResizeHandle = scClip

        scClip.MouseEnter:Connect(function()
            scCircle.BackgroundTransparency = 0.65
        end)
        scClip.MouseLeave:Connect(function()
            scCircle.BackgroundTransparency = 0.4
        end)

        Library:BindResizeHandleGhost(scClip, scCircle, function()
            return Outer.Size.X.Offset, Outer.Size.Y.Offset
        end, function(w, h)
            Window:SetWindowSize(w, h, true)
        end, function()
            Library:SaveThemeDefaults()
        end)
    end

    local ModalScrollOuter = Library:Create('Frame', {
        BackgroundColor3  = Library.BackgroundColor;
        BorderColor3      = Library.OutlineColor;
        Position          = UDim2.new(0,S(8),0,S(25));
        Size              = UDim2.new(1,-S(16),1,-S(33));
        ZIndex            = 1;
        Parent            = Inner;
    })
    Library:AddToRegistry(ModalScrollOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
    local ModalScrollInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=1; Parent=ModalScrollOuter })
    Library:AddToRegistry(ModalScrollInner, { BackgroundColor3='BackgroundColor' })

    local tabBarH    = S(22)
    local tabConY    = S(38)
    local tabConH    = -S(46)
    local TAB_OUTER  = S(4)
    local TabArea = Library:Create('ScrollingFrame', {
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Position                = UDim2.new(0,S(8),0,S(8));
        Size                    = UDim2.new(1,-S(16),0,tabBarH);
        CanvasSize              = UDim2.new(0,0,0,0);
        ScrollBarThickness      = 0;
        ScrollingDirection      = Enum.ScrollingDirection.X;
        ZIndex                  = 1;
        Parent                  = ModalScrollInner;
    })
    Library:Create('UIPadding', {
        PaddingTop     = UDim.new(0, S(3));
        PaddingBottom  = UDim.new(0, S(3));
        PaddingLeft    = UDim.new(0, TAB_OUTER);
        PaddingRight   = UDim.new(0, TAB_OUTER);
        Parent         = TabArea;
    })
    local TabLayout = Library:Create('UIListLayout', {
        Padding        = UDim.new(0, Config.TabPadding);
        FillDirection  = Enum.FillDirection.Horizontal;
        SortOrder      = Enum.SortOrder.LayoutOrder;
        Parent         = TabArea;
    })

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        Position          = UDim2.new(0,S(8),0,tabConY);
        Size              = UDim2.new(1,-S(16),1,tabConH);
        ZIndex            = 2;
        Parent            = ModalScrollInner;
    })
    Library:AddToRegistry(TabContainer, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })

    local SearchBtn = Library:Create('ImageButton', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, S(8), 0, S(4));
        Size                    = UDim2.fromOffset(S(18), S(18));
        Image                   = "rbxassetid://118685771787843";
        ImageColor3             = Library.FontColor;
        ZIndex                  = 5;
        Parent                  = Inner;
    })
    
    local SearchModal = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        Position          = UDim2.new(0, S(8), 0, S(25));
        Size              = UDim2.new(1, -S(16), 1, -S(33));
        Visible           = false;
        ZIndex            = 50;
        Parent            = Inner;
    })
    
    local SearchBackBtn = Library:Create('TextButton', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, S(4), 0, S(4));
        Size                    = UDim2.fromOffset(S(20), S(20));
        Text                    = "<";
        Font                    = Enum.Font.GothamBold;
        TextSize                = S(16);
        TextColor3              = Library.FontColor;
        ZIndex                  = 52;
        Parent                  = SearchModal;
    })

    local SearchInput = Library:Create('TextBox', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, S(30), 0, S(4));
        Size                    = UDim2.new(1, -S(38), 0, S(20));
        Font                    = Library.Font;
        TextSize                = S(14);
        PlaceholderText         = "Search features...";
        Text                    = "";
        TextColor3              = Library.FontColor;
        TextXAlignment          = Enum.TextXAlignment.Left;
        ClearTextOnFocus        = false;
        ZIndex                  = 51;
        Parent                  = SearchModal;
    })
    
    Library:Create('Frame', {
        BackgroundColor3  = Library.OutlineColor;
        BorderSizePixel   = 0;
        Position          = UDim2.new(0, S(8), 0, S(28));
        Size              = UDim2.new(1, -S(16), 0, 1);
        ZIndex            = 51;
        Parent            = SearchModal;
    })
    
    local SearchResults = Library:Create('ScrollingFrame', {
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Position                = UDim2.new(0, S(8), 0, S(32));
        Size                    = UDim2.new(1, -S(16), 1, -S(40));
        CanvasSize              = UDim2.new(0,0,0,0);
        ScrollBarThickness      = S(4);
        ScrollBarImageColor3    = Library.AccentColor;
        ZIndex                  = 51;
        Parent                  = SearchModal;
    })
    
    local SearchLayout = Library:Create('UIListLayout', {
        Padding    = UDim.new(0, S(4));
        SortOrder  = Enum.SortOrder.LayoutOrder;
        Parent     = SearchResults;
    })
    
    SearchLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        SearchResults.CanvasSize = UDim2.fromOffset(0, SearchLayout.AbsoluteContentSize.Y)
    end)
    
    local function CloseSearch()
        SearchModal.Visible = false
        SearchInput.Text = ""
    end
    
    SearchBackBtn.MouseButton1Click:Connect(CloseSearch)
    
    SearchBtn.MouseButton1Click:Connect(function()
        SearchModal.Visible = not SearchModal.Visible
        if SearchModal.Visible then
            SearchInput:CaptureFocus()
        end
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        for _, c in ipairs(SearchResults:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local searchQuery = SearchInput.Text:lower()
        if searchQuery == "" then return end

        local matches = {}
        local function scan(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local childText = child.Text:lower()
                    if childText ~= "" and childText ~= "..." and childText:find(searchQuery, 1, true) then
                        table.insert(matches, { Text = child.Text, GUI = child.Parent, Location = Library:GetLocation(child.Parent) })
                    end
                end
                scan(child)
            end
        end
        scan(TabContainer)
        
        for i, m in ipairs(matches) do
            if i > 50 then break end
            local btn = Library:Create('TextButton', {
                BackgroundColor3  = Library.BackgroundColor;
                BorderColor3      = Library.OutlineColor;
                Size              = UDim2.new(1, -S(8), 0, S(24));
                Text              = "  " .. m.Text;
                Font              = Library.Font;
                TextSize          = S(14);
                TextColor3        = Library.FontColor;
                TextXAlignment    = Enum.TextXAlignment.Left;
                ZIndex            = 52;
                Parent            = SearchResults;
            })
            
            local locLabel = Library:CreateLabel({
                Size            = UDim2.new(1, -S(10), 1, 0);
                Text            = m.Location;
                TextColor3      = Library.AccentColor;
                TextXAlignment  = Enum.TextXAlignment.Right;
                ZIndex          = 53;
                Parent          = btn;
            })
            Library:AddToRegistry(locLabel, { TextColor3 = 'AccentColor' })
            btn.MouseButton1Click:Connect(function()
                CloseSearch()
                Library:RevealElement(m.GUI)
            end)
        end
    end)

    function Library:GetLocation(elementGUI)
        local curr = elementGUI
        while curr and curr ~= game do
            for tabName, tab in pairs(Library.MainWindow.Tabs) do
                if tab.TabFrame == curr then return tabName end
                
                if tab.Groupboxes then
                    for _, gb in pairs(tab.Groupboxes) do
                        if gb.InlineTabs then
                            for _, itab in pairs(gb.InlineTabs) do
                                if itab.Container == curr then return itab.Name end
                            end
                        end
                    end
                end

                if tab.Tabboxes then
                    for tboxName, tbox in pairs(tab.Tabboxes) do
                        for tbName, tb in pairs(tbox.Tabs) do
                            if tb.Container == curr then return tbName end
                        end
                    end
                end

                if tab.SubTabSystem then
                    for stabName, stab in pairs(tab.SubTabSystem.Tabs) do
                        if stab.LeftContainer == curr or stab.RightContainer == curr then return stabName end
                        
                        if stab.Groupboxes then
                            for _, gb in pairs(stab.Groupboxes) do
                                if gb.InlineTabs then
                                    for _, itab in pairs(gb.InlineTabs) do
                                        if itab.Container == curr then return itab.Name end
                                    end
                                end
                            end
                        end

                        if stab.Tabboxes then
                            for _, tbox in pairs(stab.Tabboxes) do
                                for _, tb in pairs(tbox.Tabs) do
                                    if tb.Container == curr then return tbName end
                                end
                            end
                        end
                    end
                end
            end
            curr = curr.Parent
        end
        return ""
    end

    local sideH = WinH - S(95)

    function Library:RevealElement(elementGUI)
        local function scrollTo(gui)
            task.wait(0.05)
            local sf = gui:FindFirstAncestorWhichIsA("ScrollingFrame")
            if sf then
                local y = gui.AbsolutePosition.Y - sf.AbsolutePosition.Y + sf.CanvasPosition.Y
                sf.CanvasPosition = Vector2.new(0, math.max(0, y - S(10)))
            end
        end

        local curr = elementGUI
        while curr and curr ~= game do
            for _, tab in pairs(Library.MainWindow.Tabs) do
                if tab.TabFrame == curr then
                    tab:ShowTab()
                    scrollTo(elementGUI)
                    return
                end

                if tab.Groupboxes then
                    for _, gb in pairs(tab.Groupboxes) do
                        if gb.InlineTabs then
                            for _, itab in pairs(gb.InlineTabs) do
                                if itab.Container == curr then
                                    tab:ShowTab()
                                    itab:Show()
                                    scrollTo(elementGUI)
                                    return
                                end
                            end
                        end
                    end
                end

                if tab.Tabboxes then
                    for _, tbox in pairs(tab.Tabboxes) do
                        for _, tb in pairs(tbox.Tabs) do
                            if tb.Container == curr then
                                tab:ShowTab()
                                tb:Show()
                                scrollTo(elementGUI)
                                return
                            end
                        end
                    end
                end

                if tab.SubTabSystem then
                    for _, stab in pairs(tab.SubTabSystem.Tabs) do
                        if stab.LeftContainer == curr or stab.RightContainer == curr then
                            tab:ShowTab()
                            stab:ShowTab()
                            scrollTo(elementGUI)
                            return
                        end

                        if stab.Groupboxes then
                            for _, gb in pairs(stab.Groupboxes) do
                                if gb.InlineTabs then
                                    for _, itab in pairs(gb.InlineTabs) do
                                        if itab.Container == curr then
                                            tab:ShowTab()
                                            stab:ShowTab()
                                            itab:Show()
                                            scrollTo(elementGUI)
                                            return
                                        end
                                    end
                                end
                            end
                        end

                        if stab.Tabboxes then
                            for _, tbox in pairs(stab.Tabboxes) do
                                for _, tb in pairs(tbox.Tabs) do
                                    if tb.Container == curr then
                                        tab:ShowTab()
                                        stab:ShowTab()
                                        tb:Show()
                                        scrollTo(elementGUI)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
            curr = curr.Parent
        end
    end

    function Window:SetWindowTitle(t) Library:SetTRText(TitleLabel, t) end

    function Window:AddTab(Name)
        Library:BuildTick()
        local Tab = { Groupboxes={}; Tabboxes={} }
        local tabDisplayName = tostring(Name or "")

        local tabFontSz = S(13)
        local tbW = Library:GetTextBounds(tabDisplayName, Library.Font, tabFontSz) + S(18)
        local TBtn = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; Size=UDim2.new(0,tbW,1,0); ZIndex=1; Parent=TabArea })
        Library:AddToRegistry(TBtn, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
        local TBtnLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,-1); TextSize=tabFontSz; Text=tabDisplayName; PreserveCase=true; ZIndex=3; Parent=TBtn })
        local TInline = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); Visible=false; ZIndex=6; Parent=TBtn })
        Library:RemoveFromRegistry(TBtnLabel)
        TBtnLabel.TextColor3 = Color3.fromRGB(110,110,110)
        Tab.Button = TBtn
        Tab.NaturalW = tbW
        Window.__tabSeq = (Window.__tabSeq or 0) + 1
        Tab.Seq = Window.__tabSeq
        table.insert(Library.TabResizeCallbacks, function()
            if not TBtn.Parent then return end
            local total, sumW, cumBefore = 0, 0, 0
            for _, t in next, Window.Tabs do
                total = total + 1
                sumW  = sumW + (t.NaturalW or 0)
                if (t.Seq or 0) < (Tab.Seq or 0) then cumBefore = cumBefore + (t.NaturalW or 0) end
            end
            if total > 0 and sumW > 0 then
                local curW     = Outer.Size.X.Offset
                local ratio    = math.clamp(curW / WinW, 0.4, 1.0)
                local padding  = math.max(2, math.floor((Config.TabPadding or 8) * ratio))
                local tabAreaW = TabArea.AbsoluteSize.X - 2 * TAB_OUTER
                if tabAreaW <= 0 then tabAreaW = curW - 34 end
                local availW   = tabAreaW - (total - 1) * padding
                local left     = math.floor(cumBefore / sumW * availW)
                local right    = math.floor((cumBefore + tbW) / sumW * availW)
                local myW      = math.max(10, right - left)
                TBtn.Size          = UDim2.new(0, myW, 1, 0)
                TBtnLabel.TextSize = tabFontSz
                TabLayout.Padding  = UDim.new(0, padding)
            end
        end)
        local TUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); Visible=false; ZIndex=3; Parent=TBtn })
        Library:AddToRegistry(TUnder, { BackgroundColor3='AccentColor' })

        local TFrame = Library:Create('Frame', { Name='TabFrame'; BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Visible=false; ZIndex=2; Parent=TabContainer })
        Tab.TabFrame = TFrame

        local function MakeSide(parent, xScale, xOffset)
            local sf = Library:Create('ScrollingFrame', {
                BackgroundTransparency  = 1;
                BorderSizePixel         = 0;
                Position                = UDim2.new(xScale, xOffset, 0, S(7));
                Size                    = UDim2.new(0.5, -S(14), 1, -S(7));
                CanvasSize              = UDim2.new(0,0,0,0);
                BottomImage             = '';
                TopImage                = '';
                ScrollBarThickness      = 0;
                ScrollBarImageColor3    = Library.AccentColor;
                ScrollingDirection      = Enum.ScrollingDirection.Y;
                ElasticBehavior         = Enum.ElasticBehavior.Never;
                ZIndex                  = 2;
                Parent                  = parent;
            })
            Library:AddToRegistry(sf, { ScrollBarImageColor3='AccentColor' })
            local ll = Library:Create('UIListLayout', { Padding=UDim.new(0,S(10)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; HorizontalAlignment=Enum.HorizontalAlignment.Center; Parent=sf })
            ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                sf.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + S(8))
            end)
            return sf
        end
        local LeftSide, RightSide
        LeftSide  = MakeSide(TFrame, 0,   S(7))
        RightSide = MakeSide(TFrame, 0.5, S(7))

        function Tab:ShowTab()
            for _, t in next, Window.Tabs do t:HideTab() end
            TUnder.Visible = true; TFrame.Visible = true
            TBtnLabel.TextColor3 = Color3.new(1,1,1)
            TBtn.BackgroundColor3 = Library.MainColor
            if Library.RegistryMap[TBtn] then Library.RegistryMap[TBtn].Properties.BackgroundColor3 = 'MainColor' end
            TInline.Visible = true
        end
        function Tab:HideTab()
            TUnder.Visible = false; TFrame.Visible = false
            TBtnLabel.TextColor3 = Color3.fromRGB(110,110,110)
            TBtn.BackgroundColor3 = Library.BackgroundColor
            if Library.RegistryMap[TBtn] then Library.RegistryMap[TBtn].Properties.BackgroundColor3 = 'BackgroundColor' end
            TInline.Visible = false
        end
        function Tab:SetLayoutOrder(p) TBtn.LayoutOrder = p; TabLayout:ApplyLayout() end

        function Tab:AddGroupbox(Info2)
            Library:BuildTick()
            local Groupbox = {}
            local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,S(40)); ZIndex=2; Parent=Info2.Side==1 and LeftSide or RightSide })
            Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
            local SliderBarInner  = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
            Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
            local btnRow = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,S(19)); ZIndex=5; Parent=SliderBarInner })
            local Button = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=btnRow })
            Library:AddToRegistry(Button, { BackgroundColor3='BackgroundColor' })
            local GroupboxUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=Button })
            Library:AddToRegistry(GroupboxUnder, { BackgroundColor3='AccentColor' })
            Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(12); Text=Info2.Name; PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=Button })
            local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,S(20)); Size=UDim2.new(1,-S(8),0,0); ZIndex=1; Parent=SliderBarInner })
            local linkedList = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,S(2)); Parent=ContentFrame })

            function Groupbox:Resize()
                local sz = linkedList.AbsoluteContentSize.Y
                SliderBarOuter.Size = UDim2.new(1,0,0, S(20) + sz + 4)
            end
            linkedList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() Groupbox:Resize() end)
            Groupbox.Container = ContentFrame
            setmetatable(Groupbox, BaseGroupbox)
            Groupbox:AddBlank(6); Groupbox:Resize()
            Tab.Groupboxes[Info2.Name] = Groupbox
            return Groupbox
        end
        function Tab:AddLeftGroupbox(n)  return Tab:AddGroupbox({ Side=1; Name=n }) end
        function Tab:AddRightGroupbox(n) return Tab:AddGroupbox({ Side=2; Name=n }) end

        function Tab:AddTabbox(Info2)
            Library:BuildTick()
            local Tabbox = { Tabs={} }
            local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,0); ZIndex=2; Parent=Info2.Side==1 and LeftSide or RightSide })
            Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
            local SliderBarInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
            Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
            local TabBtns = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,S(19)); ZIndex=5; Parent=SliderBarInner })
            Library:AddToRegistry(TabBtns, { BorderColor3='OutlineColor' })
            Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Horizontal; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,0); Parent=TabBtns })

            function Tabbox:AddTab(TabName)
                Library:BuildTick()
                local TBTab = {}
                local ButtonCount = 0
                for _ in next, Tabbox.Tabs do ButtonCount = ButtonCount + 1 end
                ButtonCount = ButtonCount + 1

                local Button = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Size=UDim2.new(1/ButtonCount,0,1,0); ZIndex=6; Parent=TabBtns })
                Library:AddToRegistry(Button, {
                    BackgroundColor3  = function() return TBTab.selected and Library.BackgroundColor or Library.MainColor end;
                    BorderColor3      = function() return Library.OutlineColor end;
                })
                local ButtonLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(13); Text=TabName; ZIndex=7; Parent=Button })
                local UpperLine = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button })
                Library:AddToRegistry(UpperLine, { BackgroundColor3='AccentColor' })

                local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,S(20)); Size=UDim2.new(1,-S(8),1,-S(20)); ZIndex=1; Visible=false; Parent=SliderBarInner })
                Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=ContentFrame })

                TBTab.selected = false

                function TBTab:Show()
                    for _, t in next, Tabbox.Tabs do t:Hide() end
                    TBTab.selected = true
                    ContentFrame.Visible = true
                    Button.BackgroundColor3 = Library.BackgroundColor
                    Button.BorderSizePixel = 0
                    UpperLine.Visible = true
                    TBTab:Resize()
                end
                function TBTab:Hide()
                    TBTab.selected = false
                    ContentFrame.Visible = false
                    Button.BackgroundColor3 = Library.MainColor
                    Button.BorderSizePixel = 1
                    Button.BorderColor3 = Library.OutlineColor
                    UpperLine.Visible = false
                end
                function TBTab:Resize()
                    local n = 0
                    for _ in next, Tabbox.Tabs do n = n+1 end
                    for _, ch in ipairs(TabBtns:GetChildren()) do
                        if not ch:IsA('UIListLayout') then ch.Size = UDim2.new(1/n,0,1,0) end
                    end
                    if not ContentFrame.Visible then return end
                    local sz = 0
                    for _, el in ipairs(TBTab.Container:GetChildren()) do
                        if not el:IsA('UIListLayout') and el.Visible then sz = sz + el.Size.Y.Offset end
                    end
                    SliderBarOuter.Size = UDim2.new(1,0,0, S(20) + sz + 4)
                end

                Button.InputBegan:Connect(function(Input)
                    if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then
                        TBTab:Show()
                    end
                end)

                TBTab.Container = ContentFrame
                Tabbox.Tabs[TabName] = TBTab
                setmetatable(TBTab, BaseGroupbox)
                TBTab:AddBlank(3)
                TBTab:Resize()
                if ButtonCount == 1 then TBTab:Show() end
                return TBTab
            end

            Tab.Tabboxes[Info2.Name or ''] = Tabbox
            return Tabbox
        end
        function Tab:AddLeftTabbox(n)  return Tab:AddTabbox({ Name=n; Side=1 }) end
        function Tab:AddRightTabbox(n) return Tab:AddTabbox({ Name=n; Side=2 }) end

        function Tab:AddTitledTabbox(Info2)
            local Tabbox = { Tabs={} }
            local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,0); ZIndex=2; Parent=Info2.Side==1 and LeftSide or RightSide })
            Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
            local SliderBarInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
            Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })

            local TitleRow = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,S(19)); ZIndex=6; Parent=SliderBarInner })
            Library:AddToRegistry(TitleRow, { BackgroundColor3='BackgroundColor' })
            local TitleUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,1,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=TitleRow })
            Library:AddToRegistry(TitleUnder, { BackgroundColor3='AccentColor' })
            Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(12); Text=Info2.Name or ''; PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=TitleRow })

            local TabBtns = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,S(20)); Size=UDim2.new(1,0,0,S(19)); ZIndex=5; Parent=SliderBarInner })
            Library:AddToRegistry(TabBtns, { BorderColor3='OutlineColor' })
            Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Horizontal; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,0); Parent=TabBtns })

            function Tabbox:AddTab(TabName)
                Library:BuildTick()
                local TBTab = {}
                local ButtonCount = 0
                for _ in next, Tabbox.Tabs do ButtonCount = ButtonCount + 1 end
                ButtonCount = ButtonCount + 1

                local Button = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Size=UDim2.new(1/ButtonCount,0,1,0); ZIndex=6; Parent=TabBtns })
                Library:AddToRegistry(Button, {
                    BackgroundColor3  = function() return TBTab.selected and Library.BackgroundColor or Library.MainColor end;
                    BorderColor3      = function() return Library.OutlineColor end;
                })
                Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(13); Text=TabName; ZIndex=7; Parent=Button })
                local UpperLine = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button })
                Library:AddToRegistry(UpperLine, { BackgroundColor3='AccentColor' })

                local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,S(40)); Size=UDim2.new(1,-S(8),1,-S(40)); ZIndex=1; Visible=false; Parent=SliderBarInner })
                Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=ContentFrame })

                TBTab.selected = false

                function TBTab:Show()
                    for _, t in next, Tabbox.Tabs do t:Hide() end
                    TBTab.selected = true
                    ContentFrame.Visible = true
                    Button.BackgroundColor3 = Library.BackgroundColor
                    Button.BorderSizePixel = 0
                    UpperLine.Visible = true
                    TBTab:Resize()
                end
                function TBTab:Hide()
                    TBTab.selected = false
                    ContentFrame.Visible = false
                    Button.BackgroundColor3 = Library.MainColor
                    Button.BorderSizePixel = 1
                    Button.BorderColor3 = Library.OutlineColor
                    UpperLine.Visible = false
                end
                function TBTab:Resize()
                    local n = 0
                    for _ in next, Tabbox.Tabs do n = n+1 end
                    for _, ch in ipairs(TabBtns:GetChildren()) do
                        if not ch:IsA('UIListLayout') then ch.Size = UDim2.new(1/n,0,1,0) end
                    end
                    if not ContentFrame.Visible then return end
                    local sz = 0
                    for _, el in ipairs(TBTab.Container:GetChildren()) do
                        if not el:IsA('UIListLayout') and el.Visible then sz = sz + el.Size.Y.Offset end
                    end
                    SliderBarOuter.Size = UDim2.new(1,0,0, S(40) + sz + 4)
                end

                Button.InputBegan:Connect(function(Input)
                    if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then
                        TBTab:Show()
                    end
                end)

                TBTab.Container = ContentFrame
                Tabbox.Tabs[TabName] = TBTab
                setmetatable(TBTab, BaseGroupbox)
                TBTab:AddBlank(3)
                TBTab:Resize()
                if ButtonCount == 1 then TBTab:Show() end
                return TBTab
            end

            Tab.Tabboxes[Info2.Name or ''] = Tabbox
            return Tabbox
        end
        function Tab:AddLeftTitledTabbox(n)  return Tab:AddTitledTabbox({ Name=n; Side=1 }) end
        function Tab:AddRightTitledTabbox(n) return Tab:AddTitledTabbox({ Name=n; Side=2 }) end

        function Tab:AddSubTabs()
            local SubTabSystem = { Tabs={} }

            local SubArea = Library:Create('ScrollingFrame', {
                BackgroundTransparency  = 1;
                BorderSizePixel         = 0;
                Size                    = UDim2.new(1,0,0,S(28));
                CanvasSize              = UDim2.new(0,0,0,0);
                ScrollBarThickness      = 0;
                ScrollingDirection      = Enum.ScrollingDirection.X;
                ZIndex                  = 3;
                Parent                  = TFrame;
            })
            Library:Create('UIPadding', {
                PaddingTop     = UDim.new(0, S(4));
                PaddingBottom  = UDim.new(0, S(4));
                PaddingLeft    = UDim.new(0, S(8));
                PaddingRight   = UDim.new(0, S(8));
                Parent         = SubArea;
            })
            local SubLayout = Library:Create('UIListLayout', {
                FillDirection       = Enum.FillDirection.Horizontal;
                SortOrder           = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding             = UDim.new(0, S(6));
                Parent              = SubArea;
            })

            local function MakeSubSide(xScale, xOffset)
                local sf = Library:Create('ScrollingFrame', {
                    BackgroundTransparency  = 1;
                    BorderSizePixel         = 0;
                    Position                = UDim2.new(xScale, xOffset, 0, S(30));
                    Size                    = UDim2.new(0.5, -S(14), 1, -S(30));
                    CanvasSize              = UDim2.new(0,0,0,0);
                    BottomImage             = '';
                    TopImage                = '';
                    ScrollBarThickness      = 2;
                    ScrollBarImageColor3    = Library.AccentColor;
                    ScrollingDirection      = Enum.ScrollingDirection.Y;
                    ElasticBehavior         = Enum.ElasticBehavior.Never;
                    ZIndex                  = 2;
                    Visible                 = false;
                    Parent                  = TFrame;
                })
                Library:AddToRegistry(sf, { ScrollBarImageColor3='AccentColor' })
                local ll = Library:Create('UIListLayout', { Padding=UDim.new(0,S(8)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; HorizontalAlignment=Enum.HorizontalAlignment.Center; Parent=sf })
                ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    sf.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + S(8))
                end)
                return sf
            end

            LeftSide.Visible  = false
            RightSide.Visible = false

            function SubTabSystem:AddTab(SubName)
                Library:BuildTick()
                local ST = { Groupboxes={}; Tabboxes={} }
                local subDisplayName = tostring(SubName or "")

                local stFontSz = S(13)
                local stW = Library:GetTextBounds(subDisplayName, Library.Font, stFontSz) + S(18)
                local STBtn = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Size=UDim2.new(0,stW,1,0); ZIndex=4; Parent=SubArea })
                Library:AddToRegistry(STBtn, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
                local STBtnLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,-1); TextSize=stFontSz; Text=subDisplayName; PreserveCase=true; ZIndex=5; Parent=STBtn })
                Library:RemoveFromRegistry(STBtnLabel)
                STBtnLabel.TextColor3 = Color3.fromRGB(110,110,110)
                local STInline = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); Visible=false; ZIndex=6; Parent=STBtn })
                local STUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); Visible=false; ZIndex=5; Parent=STBtn })
                Library:AddToRegistry(STUnder, { BackgroundColor3='AccentColor' })

                local STLeft  = MakeSubSide(0,   S(7))
                local STRight = MakeSubSide(0.5, S(7))

                ST.LeftContainer = STLeft
                ST.RightContainer = STRight

                function ST:ShowTab()
                    for _, t in next, SubTabSystem.Tabs do t:HideTab() end
                    STUnder.Visible = true
                    STInline.Visible = true
                    STBtnLabel.TextColor3 = Color3.new(1,1,1)
                    STBtn.BackgroundColor3 = Library.MainColor
                    if Library.RegistryMap[STBtn] then Library.RegistryMap[STBtn].Properties.BackgroundColor3 = 'MainColor' end
                    STLeft.Visible  = true
                    STRight.Visible = true
                end
                function ST:HideTab()
                    STUnder.Visible = false
                    STInline.Visible = false
                    STBtnLabel.TextColor3 = Color3.fromRGB(110,110,110)
                    STBtn.BackgroundColor3 = Library.BackgroundColor
                    if Library.RegistryMap[STBtn] then Library.RegistryMap[STBtn].Properties.BackgroundColor3 = 'BackgroundColor' end
                    STLeft.Visible  = false
                    STRight.Visible = false
                end

                function ST:AddGroupbox(Info3)
                    Library:BuildTick()
                    local Groupbox = {}
                    local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,S(40)); ZIndex=2; Parent=Info3.Side==1 and STLeft or STRight })
                    Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
                    local SliderBarInner  = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
                    Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
                    local btnRow = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,S(19)); ZIndex=5; Parent=SliderBarInner })
                    local Button = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=btnRow })
                    Library:AddToRegistry(Button, { BackgroundColor3='BackgroundColor' })
                    local GroupboxUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=Button })
                    Library:AddToRegistry(GroupboxUnder, { BackgroundColor3='AccentColor' })
                    Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(12); Text=Info3.Name; PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=Button })
                    local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,S(20)); Size=UDim2.new(1,-S(8),0,0); ZIndex=1; Parent=SliderBarInner })
                    local linkedList = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,S(2)); Parent=ContentFrame })
                    function Groupbox:Resize()
                        local sz = linkedList.AbsoluteContentSize.Y
                        SliderBarOuter.Size = UDim2.new(1,0,0, S(20) + sz + 4)
                    end
                    linkedList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() Groupbox:Resize() end)
                    Groupbox.Container = ContentFrame
                    setmetatable(Groupbox, BaseGroupbox)
                    Groupbox:AddBlank(6); Groupbox:Resize()
                    ST.Groupboxes[Info3.Name] = Groupbox
                    return Groupbox
                end
                function ST:AddLeftGroupbox(n)  return ST:AddGroupbox({ Side=1; Name=n }) end
                function ST:AddRightGroupbox(n) return ST:AddGroupbox({ Side=2; Name=n }) end

                function ST:AddTabbox(Info3)
                    Library:BuildTick()
                    local Tabbox2 = { Tabs={} }
                    local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,0); ZIndex=2; Parent=Info3.Side==1 and STLeft or STRight })
                    Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
                    local SliderBarInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
                    Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
                    local TabBtns2 = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,S(19)); ZIndex=5; Parent=SliderBarInner })
                    Library:AddToRegistry(TabBtns2, { BorderColor3='OutlineColor' })
                    Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Horizontal; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,0); Parent=TabBtns2 })

                    function Tabbox2:AddTab(TN)
                        Library:BuildTick()
                        local TBTab2 = {}
                        local nc = 0; for _ in next, Tabbox2.Tabs do nc=nc+1 end; nc=nc+1
                        local Button2 = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Size=UDim2.new(1/nc,0,1,0); ZIndex=6; Parent=TabBtns2 })
                        Library:AddToRegistry(Button2, {
                            BackgroundColor3  = function() return TBTab2.selected and Library.BackgroundColor or Library.MainColor end;
                            BorderColor3      = function() return Library.OutlineColor end;
                        })
                        Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=S(13); Text=TN; ZIndex=7; Parent=Button2 })
                        local UpperLine2 = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button2 })
                        Library:AddToRegistry(UpperLine2, { BackgroundColor3='AccentColor' })
                        local ContentFrame2 = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,S(4),0,S(20)); Size=UDim2.new(1,-S(8),0,0); ZIndex=1; Visible=false; Parent=SliderBarInner })
                        local LL2 = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=ContentFrame2 })
                        TBTab2.selected = false
                        function TBTab2:Show()
                            for _, t in next, Tabbox2.Tabs do t:Hide() end
                            TBTab2.selected = true
                            ContentFrame2.Visible = true
                            Button2.BackgroundColor3 = Library.BackgroundColor
                            Button2.BorderSizePixel = 0
                            UpperLine2.Visible = true
                            TBTab2:Resize()
                        end
                        function TBTab2:Hide() TBTab2.selected=false; ContentFrame2.Visible=false; Button2.BackgroundColor3=Library.MainColor; Button2.BorderSizePixel=1; Button2.BorderColor3=Library.OutlineColor; UpperLine2.Visible=false end
                        function TBTab2:Resize()
                            local n=0; for _ in next,Tabbox2.Tabs do n=n+1 end
                            for _, ch in ipairs(TabBtns2:GetChildren()) do if not ch:IsA('UIListLayout') then ch.Size=UDim2.new(1/n,0,1,0) end end
                            if not ContentFrame2.Visible then return end
                            SliderBarOuter.Size = UDim2.new(1,0,0, S(20)+LL2.AbsoluteContentSize.Y+4)
                        end
                        LL2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() if ContentFrame2.Visible then TBTab2:Resize() end end)
                        Button2.InputBegan:Connect(function(Input) if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then TBTab2:Show() end end)
                        TBTab2.Container = ContentFrame2
                        Tabbox2.Tabs[TN] = TBTab2
                        setmetatable(TBTab2, BaseGroupbox)
                        TBTab2:AddBlank(3); TBTab2:Resize()
                        if nc==1 then TBTab2:Show() end
                        return TBTab2
                    end
                    ST.Tabboxes[Info3.Name or ''] = Tabbox2
                    return Tabbox2
                end
                function ST:AddLeftTabbox(n)  return ST:AddTabbox({ Name=n; Side=1 }) end
                function ST:AddRightTabbox(n) return ST:AddTabbox({ Name=n; Side=2 }) end

                STBtn.InputBegan:Connect(function(Input)
                    if Library:IsPointerInput(Input) then ST:ShowTab() end
                end)

                SubTabSystem.Tabs[SubName] = ST
                local count = 0; for _ in next, SubTabSystem.Tabs do count=count+1 end
                if count == 1 then ST:ShowTab() end
                
                for _, cb in ipairs(Library.TabResizeCallbacks) do pcall(cb) end
                return ST
            end

            Tab.SubTabSystem = SubTabSystem
            return SubTabSystem
        end

        TBtn.InputBegan:Connect(function(Input)
            if Library:IsPointerInput(Input) then Tab:ShowTab() end
        end)
        local cnt = 0; for _ in next, Window.Tabs do cnt=cnt+1 end
        if cnt == 0 then Tab:ShowTab() end
        Window.Tabs[Name] = Tab

        for _, cb in ipairs(Library.TabResizeCallbacks) do pcall(cb) end
        return Tab
    end

    local Modal = Library:Create('TextButton', { BackgroundTransparency=1; Size=UDim2.new(0,0,0,0); Text=''; Modal=false; Parent=ScreenGui })

    local INPUT_SINK_ACTION = "EZ_MenuInputSink"
    local function setInputSink(active)
        local ContextActionService = Services.ContextActionService
        if active then
            ContextActionService:BindActionAtPriority(
                INPUT_SINK_ACTION,
                function() return Enum.ContextActionResult.Sink end,
                false,
                Enum.ContextActionPriority.High.Value,
                Enum.UserInputType.MouseButton1,
                Enum.UserInputType.MouseButton2
            )
        else
            pcall(function() ContextActionService:UnbindAction(INPUT_SINK_ACTION) end)
        end
    end
    local cursorLoopActive = false

    local function tweenObject(obj, info, props)
        local tw = Services.TweenService:Create(obj, info, props)
        tw:Play()
        return tw
    end



    local OFFSCREEN_POS = UDim2.fromOffset(-99999, -99999)
    local tabsInitialized = false
    local function applyWindowVisibility(isVisible)
        if isVisible then
            Outer.Visible = true
            if Library.MenuRestPos then
                Outer.Position = Library.MenuRestPos
                Library.MenuRestPos = nil
            end
            if not tabsInitialized then
                tabsInitialized = true
                task.defer(function()
                    for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
                end)
            end
        else
            if Library.MenuShown ~= false and Outer.Position ~= OFFSCREEN_POS then
                Library.MenuRestPos = Outer.Position
            end
            Outer.Position = OFFSCREEN_POS
            Outer.Visible = false
        end
        Library.MenuShown = isVisible

        Modal.Modal   = isVisible
        setInputSink(isVisible)
        for _, cb in ipairs(Library.VisibilityCallbacks) do pcall(cb, isVisible) end

        OuterScale.Scale = Library.UIScaleValue or 1

        do
            if isVisible then
                if not Library.cursorLoopActive then
                    Library.cursorLoopActive = true
                    Library.savedMouseIcon = Services.UserInputService.MouseIconEnabled

                    task.spawn(function()
                        local Cursor = Instance.new("ImageLabel", ScreenGui)
                        Cursor.Image = "http://www.roblox.com/asset/?id=4292970642"
                        Cursor.BackgroundTransparency = 1
                        Cursor.ZIndex = 100000

                        local CursorOutline = Instance.new("ImageLabel", ScreenGui)
                        CursorOutline.Image = "http://www.roblox.com/asset/?id=4292970642"
                        CursorOutline.ImageColor3 = Color3.new()
                        CursorOutline.BackgroundTransparency = 1
                        CursorOutline.ZIndex = 99999

                        Cursor.Size, CursorOutline.Size = UDim2.fromOffset(17, 17), UDim2.fromOffset(19, 19)
                        Cursor.Rotation, CursorOutline.Rotation = -45, -45

                        while Library.MenuShown and ScreenGui.Parent do
                            Services.UserInputService.MouseIconEnabled = false

                            local mPos = Services.UserInputService:GetMouseLocation()
                            local udim = UDim2.fromOffset(mPos.X, mPos.Y)

                            Cursor.ImageColor3 = Library.AccentColor
                            Cursor.Position, CursorOutline.Position = udim, udim - UDim2.fromOffset(1, 1)

                            Services.RunService.RenderStepped:Wait()
                        end

                        Services.UserInputService.MouseIconEnabled = Library.savedMouseIcon

                        Cursor:Destroy()
                        CursorOutline:Destroy()
                        Library.cursorLoopActive = false
                    end)
                end
            end
        end
    end

    function Library.Toggle()
        applyWindowVisibility(not Library.MenuShown)
    end

    function Library:SetIconSize(size)
        self.IconSize = size
        for _, cb in ipairs(self.IconSizeCallbacks) do pcall(cb, size) end
    end

    if IsTouch then
        local vp0   = workspace.CurrentCamera.ViewportSize
        local btnSz = S(36)
        local initX = math.floor(vp0.X / 2 - btnSz / 2)
        local initY = S(12)

        local mobLogo = Library:Create('ImageButton', {
            BackgroundColor3  = Color3.fromRGB(20, 20, 20);
            BorderSizePixel   = 0;
            Position          = UDim2.fromOffset(initX, initY);
            Size              = UDim2.fromOffset(btnSz, btnSz);
            Image             = 'rbxassetid://126479907072494';
            ScaleType         = Enum.ScaleType.Fit;
            ZIndex            = 260;
            Parent            = ScreenGui;
        })
        Library:Create('UICorner', { CornerRadius = UDim.new(0, S(8)); Parent = mobLogo })

        local mobScale = Instance.new('UIScale')
        mobScale.Scale  = 1
        mobScale.Parent = mobLogo

        local TS = cloneref(game:GetService('TweenService'))
        local function tweenMobScale(target, style)
            TS:Create(mobScale,
                TweenInfo.new(0.13, style or Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Scale = target }
            ):Play()
        end

        local dragging    = false
        local movedLogo   = false
        local activeTouch = nil
        local dragStartX, dragStartY = 0, 0
        local frameStartX, frameStartY = 0, 0

        mobLogo.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch
                and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if dragging then return end
            dragging    = true
            movedLogo   = false
            activeTouch = inp
            dragStartX  = inp.Position.X
            dragStartY  = inp.Position.Y
            frameStartX = mobLogo.AbsolutePosition.X
            frameStartY = mobLogo.AbsolutePosition.Y
            tweenMobScale(0.88, Enum.EasingStyle.Quad)
        end)

        Library:GiveSignal(Services.UserInputService.InputChanged:Connect(function(inp)
            if not dragging or inp ~= activeTouch then return end
            if inp.UserInputType ~= Enum.UserInputType.Touch
                and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local dx = inp.Position.X - dragStartX
            local dy = inp.Position.Y - dragStartY
            if not movedLogo and (math.abs(dx) > 5 or math.abs(dy) > 5) then
                movedLogo = true
                tweenMobScale(1.0, Enum.EasingStyle.Quad)
            end
            if movedLogo then
                local vp  = workspace.CurrentCamera.ViewportSize
                local abs = mobLogo.AbsoluteSize
                mobLogo.Position = UDim2.fromOffset(
                    math.clamp(frameStartX + dx, 0, math.max(0, vp.X - abs.X)),
                    math.clamp(frameStartY + dy, 0, math.max(0, vp.Y - abs.Y))
                )
            end
        end))

        Library:GiveSignal(Services.UserInputService.InputEnded:Connect(function(inp)
            if not dragging or inp ~= activeTouch then return end
            if inp.UserInputType ~= Enum.UserInputType.Touch
                and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            dragging    = false
            activeTouch = nil
            tweenMobScale(1.0)
            if not movedLogo then
                task.spawn(Library.Toggle)
            end
        end))
    end

    Library:GiveSignal(Services.UserInputService.InputBegan:Connect(function(Input, Processed)
        if IsTouch then return end
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl
            or (Input.KeyCode == Enum.KeyCode.RightShift and not Processed) then
            task.spawn(Library.Toggle)
        end
    end))

    if Config.AutoShow then task.spawn(Library.Toggle) end
    Window.Holder = Outer
    Library.MainWindow = Window
    Library.MainWindowSize = { w = Outer.Size.X.Offset, h = Outer.Size.Y.Offset }
    task.defer(function()
        for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
    end)
    return Window
end

local function OnPlayerChange()
    local list = GetPlayersString()
    for _, v in next, Options do
        if v.Type == 'Dropdown' and v.SpecialType == 'Player' then
            v.Values = list; v:SetValues()
        end
    end
end
Services.Players.PlayerAdded:Connect(OnPlayerChange)
Services.Players.PlayerRemoving:Connect(OnPlayerChange)
task.spawn(OnPlayerChange)



function Library:CreateFloatingPanel(config)
    local w = config.Width or 860
    local h = config.Height or 520
    local outer = Library:Create("Frame", {
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = config.Position or UDim2.fromScale(0.5, 0.5),
        Size              = UDim2.fromOffset(w, h),
        BackgroundColor3  = Library.MainColor,
        BorderColor3      = Library.OutlineColor,
        Visible           = false,
        ZIndex            = 100,
        Parent            = Library.ScreenGui,
    })
    Library:AddToRegistry(outer, {BackgroundColor3="MainColor", BorderColor3="OutlineColor"})
    Library:MakeDraggable(outer, S(22))
    local titleBar = Library:Create("Frame", {
        Size              = UDim2.new(1, 0, 0, S(22)),
        BackgroundColor3  = Library.AccentColor,
        BorderSizePixel   = 0,
        ZIndex            = 101,
        Parent            = outer,
    })
    Library:AddToRegistry(titleBar, {BackgroundColor3="AccentColor"})
    Library:CreateLabel({
        Position        = UDim2.new(0, S(5), 0, 0),
        Size            = UDim2.new(1, -S(26), 1, 0),
        Text            = config.Title or "panel",
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextSize        = S(14),
        PreserveCase    = true,
        ZIndex          = 102,
        Parent          = titleBar,
    })
    local closeBtn = Library:Create("TextButton", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, -S(3), 0.5, 0),
        Size              = UDim2.new(0, S(18), 0, S(18)),
        BackgroundColor3  = Library.RiskColor,
        BorderSizePixel   = 0,
        Text              = "x",
        TextColor3        = Library.FontColor,
        TextSize          = S(12),
        Font              = Library.Font,
        ZIndex            = 102,
        Parent            = titleBar,
    })
    Library:AddToRegistry(closeBtn, {BackgroundColor3="RiskColor", TextColor3="FontColor"})
    closeBtn.MouseButton1Click:Connect(function()
        outer.Visible = false
        if config.OnClose then config.OnClose() end
    end)
    local content = Library:Create("Frame", {
        Position                = UDim2.new(0, 0, 0, S(22)),
        Size                    = UDim2.new(1, 0, 1, -S(22)),
        BackgroundTransparency  = 1,
        ZIndex                  = 101,
        Parent                  = outer,
    })
    local panel = {Frame = outer, Content = content}
    function panel:Show() outer.Visible = true end
    function panel:Hide() outer.Visible = false end
    function panel:Toggle() outer.Visible = not outer.Visible end
    function panel:Destroy() outer:Destroy() end
    return panel
end

function Library:CreatePrompt(config)
    local outer = Library:Create("TextButton", {
        Size                    = UDim2.fromScale(1, 1),
        BackgroundColor3        = Color3.new(0, 0, 0),
        BackgroundTransparency  = 0.5,
        AutoButtonColor         = false,
        Text                    = "",
        ZIndex                  = 2000,
        Parent                  = Library.ScreenGui,
    })
    outer.MouseButton1Click:Connect(function()
        local mouse = game:GetService("UserInputService"):GetMouseLocation()
        local pos  = inner.AbsolutePosition
        local size = inner.AbsoluteSize
        if mouse.X < pos.X or mouse.X > pos.X + size.X
        or mouse.Y < pos.Y or mouse.Y > pos.Y + size.Y then
            outer:Destroy()
        end
    end)

    local isConfirm = config.Mode == "Confirm"
    local w = isConfirm and S(300) or S(400)
    local h = isConfirm and S(120) or S(350)

    local inner = Library:Create("TextButton", {
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.fromScale(0.5, 0.5),
        Size              = UDim2.fromOffset(w, h),
        BackgroundColor3  = Library.BackgroundColor,
        BorderColor3      = Library.OutlineColor,
        AutoButtonColor   = false,
        Text              = "",
        Active            = true,
        ZIndex            = 2001,
        Parent            = outer,
    })
    local innerScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = inner })
    table.insert(Library.ThemeScales, innerScale)
    Library:AddToRegistry(inner, {BackgroundColor3="BackgroundColor", BorderColor3="OutlineColor"})
    local titleBar = Library:Create("Frame", {
        Size              = UDim2.new(1, 0, 0, S(22)),
        BackgroundColor3  = Library.MainColor,
        BorderSizePixel   = 0,
        ZIndex            = 2002,
        Parent            = inner,
    })
    Library:AddToRegistry(titleBar, {BackgroundColor3="MainColor"})
    Library:CreateLabel({
        Position        = UDim2.new(0, S(5), 0, 0),
        Size            = UDim2.new(1, -S(26), 1, 0),
        Text            = config.Title or "Prompt",
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextSize        = S(14),
        ZIndex          = 2003,
        Parent          = titleBar,
    })

    if isConfirm then
        Library:CreateLabel({
            Position        = UDim2.fromOffset(S(10), S(30)),
            Size            = UDim2.new(1, -S(20), 1, -S(70)),
            Text            = config.Text or "Are you sure?",
            TextXAlignment  = Enum.TextXAlignment.Center,
            TextYAlignment  = Enum.TextYAlignment.Center,
            TextSize        = S(14),
            TextWrapped     = true,
            ZIndex          = 2002,
            Parent          = inner,
        })

        local confirmBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0, S(10), 1, -S(30)),
            Size              = UDim2.new(0.5, -S(15), 0, S(20)),
            BackgroundColor3  = Library.RiskColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = S(14),
            Font              = Enum.Font.Code,
            Text              = "Confirm",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(confirmBtn, {BackgroundColor3="RiskColor", BorderColor3="OutlineColor", TextColor3="FontColor"})
        
        local cancelBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0.5, S(5), 1, -S(30)),
            Size              = UDim2.new(0.5, -S(15), 0, S(20)),
            BackgroundColor3  = Library.MainColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = S(14),
            Font              = Enum.Font.Code,
            Text              = "Cancel",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(cancelBtn, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor"})

        confirmBtn.MouseButton1Click:Connect(function()
            if config.Callback then config.Callback() end
            outer:Destroy()
        end)
        cancelBtn.MouseButton1Click:Connect(function()
            outer:Destroy()
        end)
    else
        local textBox = Library:Create("TextBox", {
            Position          = UDim2.fromOffset(S(10), S(30)),
            Size              = UDim2.new(1, -S(20), 1, config.Mode == "Import" and -S(100) or -S(70)),
            BackgroundColor3  = Library.MainColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = S(14),
            Font              = Enum.Font.Code,
            TextXAlignment    = Enum.TextXAlignment.Left,
            TextYAlignment    = Enum.TextYAlignment.Top,
            ClearTextOnFocus  = false,
            TextWrapped       = true,
            MultiLine         = true,
            Text              = config.Text or "",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(textBox, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor"})
        
        local nameInput
        if config.Mode == "Import" then
            nameInput = Library:Create("TextBox", {
                Position          = UDim2.new(0, S(10), 1, -S(60)),
                Size              = UDim2.new(1, -S(20), 0, S(20)),
                BackgroundColor3  = Library.MainColor,
                BorderColor3      = Library.OutlineColor,
                TextColor3        = Library.FontColor,
                PlaceholderText   = "Enter Name...",
                Text              = "",
                TextSize          = S(14),
                Font              = Enum.Font.Code,
                ZIndex            = 2002,
                Parent            = inner,
            })
            Library:AddToRegistry(nameInput, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor"})
        end
        
        local actionBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0, S(10), 1, -S(30)),
            Size              = UDim2.new(1, -S(20), 0, S(20)),
            BackgroundColor3  = Library.AccentColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = S(14),
            Font              = Enum.Font.Code,
            Text              = config.Mode == "Export" and "Copy to Clipboard" or "Import & Save",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(actionBtn, {BackgroundColor3="AccentColor", BorderColor3="OutlineColor", TextColor3="FontColor"})
        
        actionBtn.MouseButton1Click:Connect(function()
            if config.Mode == "Export" then
                if setclipboard then
                    setclipboard(textBox.Text)
                    Library:Notify("Copied to clipboard!", 2)
                else
                    Library:Notify("Executor does not support setclipboard!", 3)
                end
            else
                if config.Callback then
                    config.Callback(textBox.Text, nameInput and nameInput.Text or "")
                    outer:Destroy()
                end
            end
        end)
    end
end


--[[ ThemeManager ]]

local ThemeManager = {} do
	ThemeManager.Folder = 'Elite Zone/Rivals'

	ThemeManager.Library = nil
ThemeManager.ColorFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
ThemeManager.FontMap = {
    SourceSans   = Enum.Font.SourceSans,
    Code         = Enum.Font.Code,
    Gotham       = Enum.Font.Gotham,
    GothamBold   = Enum.Font.GothamBold,
    RobotoMono   = Enum.Font.RobotoMono,
    SciFi        = Enum.Font.SciFi,
    Arcade       = Enum.Font.Arcade,
    Fredoka      = Enum.Font.FredokaOne,
    Cartoon      = Enum.Font.Cartoon,
    ProggyClean  = 'custom',
}
ThemeManager.BuiltInThemes = {
    ['Default']      = { 1,  Services.HttpService:JSONDecode('{"MainColor":"181818","AccentColor":"858586","OutlineColor":"1f1f1f","BackgroundColor":"141414","FontColor":"ffffff"}') },
    ['UE']           = { 2,  Services.HttpService:JSONDecode('{"MainColor":"181818","AccentColor":"4777b6","OutlineColor":"1f1f1f","BackgroundColor":"141414","FontColor":"ffffff"}') },
    ['BBot']         = { 3,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
    ['Fatality']     = { 4,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
    ['Jester']       = { 5,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
    ['Mint']         = { 6,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
    ['Tokyo Night']  = { 7,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
    ['Ubuntu']       = { 8,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
    ['Quartz']       = { 9,  Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
    ['Crimson']      = { 10, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1f1515","AccentColor":"cc2222","BackgroundColor":"160e0e","OutlineColor":"3a1f1f"}') },
    ['Cyberpunk']    = { 11, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"0d0d1a","AccentColor":"00ffe0","BackgroundColor":"080810","OutlineColor":"1a1a33"}') },
    ['Caramel']      = { 12, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2b1f10","AccentColor":"d4822a","BackgroundColor":"1c1208","OutlineColor":"3d2b12"}') },
    ['Ocean']        = { 13, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"0d1b2a","AccentColor":"1e90ff","BackgroundColor":"080f18","OutlineColor":"1a3a5c"}') },
    ['Lavender']     = { 14, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"22203a","AccentColor":"b48ef0","BackgroundColor":"19172d","OutlineColor":"35305a"}') },
    ['Matrix']       = { 15, Services.HttpService:JSONDecode('{"FontColor":"00ff41","MainColor":"0d1a0d","AccentColor":"00cc33","BackgroundColor":"080f08","OutlineColor":"0f2b0f"}') },
    ['Rose Gold']    = { 16, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2a1a1f","AccentColor":"e8a0b0","BackgroundColor":"1e1015","OutlineColor":"3d2030"}') },
    ['Midnight Gold']= { 17, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"12162b","AccentColor":"c9a84c","BackgroundColor":"0c0f1e","OutlineColor":"1e2440"}') },
    ['Rust']         = { 18, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1510","AccentColor":"c0521a","BackgroundColor":"140e08","OutlineColor":"3b2010"}') },
    ['Slate']        = { 19, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e2a2a","AccentColor":"4db8b8","BackgroundColor":"141f1f","OutlineColor":"2a3d3d"}') },
    ['Dracula']      = { 20, Services.HttpService:JSONDecode('{"FontColor":"f8f8f2","MainColor":"282a36","AccentColor":"bd93f9","BackgroundColor":"1e1f29","OutlineColor":"44475a"}') },
    ['Synthwave']    = { 21, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1a0a2e","AccentColor":"ff2d78","BackgroundColor":"110720","OutlineColor":"2d1050"}') },
    ['Forest']       = { 22, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1a2215","AccentColor":"5a9e3a","BackgroundColor":"111a0d","OutlineColor":"2a3d1e"}') },
    ['Arctic']       = { 23, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1a2535","AccentColor":"a8d8f0","BackgroundColor":"111c2a","OutlineColor":"253545"}') },
    ['Charcoal']     = { 24, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2e2e2e","AccentColor":"aaaaaa","BackgroundColor":"222222","OutlineColor":"444444"}') },
    ['One Dark']     = { 25, Services.HttpService:JSONDecode('{"FontColor":"abb2bf","MainColor":"282c34","AccentColor":"61afef","BackgroundColor":"21252b","OutlineColor":"3e4451"}') },
    ['Nord']         = { 26, Services.HttpService:JSONDecode('{"FontColor":"d8dee9","MainColor":"2e3440","AccentColor":"88c0d0","BackgroundColor":"242933","OutlineColor":"3b4252"}') },
    ['Gruvbox']      = { 27, Services.HttpService:JSONDecode('{"FontColor":"ebdbb2","MainColor":"282828","AccentColor":"fe8019","BackgroundColor":"1d2021","OutlineColor":"3c3836"}') },
    ['Ayu Mirage']   = { 28, Services.HttpService:JSONDecode('{"FontColor":"cccac2","MainColor":"1f2430","AccentColor":"ffcc66","BackgroundColor":"171b24","OutlineColor":"242936"}') },
    ['Material Ocean']={ 29, Services.HttpService:JSONDecode('{"FontColor":"8f93a2","MainColor":"0f111a","AccentColor":"80cbc4","BackgroundColor":"090b10","OutlineColor":"1a1c25"}') },
    ['Deep Sea']     = { 30, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"001220","AccentColor":"0077b6","BackgroundColor":"000b14","OutlineColor":"002a45"}') },
    ['Vampire']      = { 31, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1a0000","AccentColor":"e60000","BackgroundColor":"0d0000","OutlineColor":"330000"}') },
    ['Obsidian']     = { 32, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"0a0a0a","AccentColor":"00ff88","BackgroundColor":"050505","OutlineColor":"1a1a1a"}') },
}
	local function getFontName(font)
		for name, enum in next, ThemeManager.FontMap do
			if enum == font then
				return name
			end
		end
		return 'Code'
	end

	function ThemeManager:GetAutoloadFile()
		return self.Folder .. '/Themes/autoload.txt'
	end

	function ThemeManager:NormalizeThemeData(data)
		if type(data) ~= 'table' then
			return nil
		end

		local colors = type(data.colors) == 'table' and data.colors or data
		local out = { colors = {} }
		for _, field in next, self.ColorFields do
			local value = colors[field]
			if type(value) == 'string' and value ~= '' then
				out.colors[field] = value
			end
		end

		local font = data.font or data.Font
		if type(font) == 'string' and font ~= '' then
			out.font = font
		end

		local iconSize = data.iconSize or data.IconSize
		if type(iconSize) == 'number' then
			out.iconSize = iconSize
		end

		local uiScale = data.uiScale or data.UiScale
		if type(uiScale) == 'number' then
			out.uiScale = uiScale
		end

		if type(data.mainWindowSize) == 'table' then
			local w = tonumber(data.mainWindowSize.w)
			local h = tonumber(data.mainWindowSize.h)
			if w and h then
				out.mainWindowSize = { w = w, h = h }
			end
		end


		return out
	end

	function ThemeManager:GetThemeState(theme, isCustom)
		local state = {
			theme     = theme or self.CurrentThemeName or (Options and Options.ThemeManager_ThemeList and Options.ThemeManager_ThemeList.Value) or 'Default',
			custom    = type(isCustom) == 'boolean' and isCustom or self.CurrentThemeCustom == true,
			font      = Options and Options.ThemeManager_Font and Options.ThemeManager_Font.Value or getFontName(self.Library and self.Library.Font),
			iconSize  = tonumber(Options and Options.ThemeManager_IconSize and Options.ThemeManager_IconSize.Value) or tonumber(self.Library and self.Library.IconSize) or 20,
			uiScale   = tonumber(Options and Options.ThemeManager_UIScale and Options.ThemeManager_UIScale.Value) or tonumber(self.Library and self.Library.UIScaleValue) or 1.0,
			colors    = {},
		}
		if self.Library and type(self.Library.GetMainWindowSize) == 'function' then
			state.mainWindowSize = self.Library:GetMainWindowSize()
		end
		for _, field in next, self.ColorFields do
			local value = Options and Options[field] and Options[field].Value or (self.Library and self.Library[field])
			if typeof(value) == 'Color3' then
				state.colors[field] = value:ToHex()
			end
		end

		return state
	end

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local builtInTheme = self.BuiltInThemes[theme]
		local isBuiltIn = builtInTheme ~= nil and customThemeData == nil
		local data = self:NormalizeThemeData(customThemeData or (builtInTheme and builtInTheme[2]))

		if not data then return end

		self.CurrentThemeName = theme
		self.CurrentThemeCustom = not isBuiltIn
		self.ApplyingTheme = true

		if not isBuiltIn and data.mainWindowSize and self.Library and type(self.Library.SetMainWindowSize) == 'function' then
			local sw = tonumber(data.mainWindowSize.w)
			local sh = tonumber(data.mainWindowSize.h)
			if sw and sh then
				self.Library:SetMainWindowSize(sw, sh, true)
			end
		end

		for idx, col in next, data.colors do
			local parsed = Color3.fromHex(col)
			self.Library[idx] = parsed
			if Options[idx] then
				Options[idx]:SetValueRGB(parsed)
			end
		end

		if isBuiltIn then
			if Options.ThemeManager_Font then
				Options.ThemeManager_Font:SetValue('code')
				Options.ThemeManager_Font:Display()
			end
		else
			if Options.ThemeManager_Font then
				local wantFont = string.lower(tostring(data.font or 'code'))
				Options.ThemeManager_Font:SetValue(wantFont)
				Options.ThemeManager_Font:Display()
			end
			if data.iconSize and Options.ThemeManager_IconSize then
				Options.ThemeManager_IconSize:SetValue(data.iconSize)
			end
			if data.uiScale and Options.ThemeManager_UIScale then
				Options.ThemeManager_UIScale:SetValue(data.uiScale)
			end
		end

		self.ApplyingTheme = nil
		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		for _, field in next, self.ColorFields do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		if Options and Options.ThemeManager_Font then
			local fontName = Options.ThemeManager_Font.Value
			local fs       = self.Library.FontSystem
			local lname    = string.lower(tostring(fontName or ''))
			lname = (fs and fs.Aliases and fs.Aliases[lname]) or lname
			local builtinEnum = fs and fs.Builtin and fs.Builtin[lname]
			if builtinEnum then
				self.Library.Font          = builtinEnum
				self.Library.CustomFontFace = nil
			else
				local resolved = fs and fs.Resolve(fontName)
				self.Library.Font          = Enum.Font.Code
				self.Library.CustomFontFace = resolved
			end
		end

		if self.Library and type(self.Library.SetIconSize) == 'function' then
			self.Library:SetIconSize(Options and Options.ThemeManager_IconSize and Options.ThemeManager_IconSize.Value or self.Library.IconSize)
		end

		if self.Library and type(self.Library.SetUIScale) == 'function' then
			self.Library:SetUIScale(Options and Options.ThemeManager_UIScale and Options.ThemeManager_UIScale.Value or self.Library.UIScaleValue, true)
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()
		self.LoadingDefault = true

		local theme = self:ReadAutoloadName()
		if not (self.BuiltInThemes[theme] or self:GetCustomTheme(theme)) then
			theme = 'Default'
		end

		self:ApplyTheme(theme)

		if self.BuiltInThemes[theme] then
			if Options.ThemeManager_BuiltInThemeList then Options.ThemeManager_BuiltInThemeList:SetValue(theme) end
		else
			if Options.ThemeManager_CustomThemeList then Options.ThemeManager_CustomThemeList:SetValue(theme) end
		end

		self.LoadingDefault = nil
	end

	function ThemeManager:SaveDefault(theme, isCustom)
		local name = (type(theme) == 'string' and theme ~= '') and theme or self.CurrentThemeName or 'Default'
		self.CurrentThemeName = name
		self.CurrentThemeCustom = not self.BuiltInThemes[name]
		if not writefile then return end
		writefile(self:GetAutoloadFile(), name)
	end

	function ThemeManager:BuildThemeSections(gb, includeColorPickers)
		local function refreshAutoloadLabel(name)
			if ThemeManager.AutoloadLabel1 then ThemeManager.AutoloadLabel1:SetText('Autoload: ' .. name) end
			if ThemeManager.AutoloadLabel2 then ThemeManager.AutoloadLabel2:SetText('Autoload: ' .. name) end
		end

		if includeColorPickers then
			gb:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor })
			gb:AddLabel('Main color'):AddColorPicker('MainColor', { Default = self.Library.MainColor })
			gb:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor })
			gb:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor })
			gb:AddLabel('Font color'):AddColorPicker('FontColor', { Default = self.Library.FontColor })
			gb:AddDivider()
		end

		gb:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = Library.FontSystem.AllNames(), Default = 'code' })
		if self.Library and self.Library.IsMobile then
			gb:AddSlider('ThemeManager_IconSize', { Text = 'Icon Size', Default = self.Library.IconSize or 20, Min = 12, Max = 32, Rounding = 0 })
		end
		gb:AddDivider()

		gb:AddDropdown('ThemeManager_BuiltInThemeList', {
			Text     = 'Pre-Made Themes',
			Values   = self:GetBuiltInThemeNames(),
			Default  = 1,
		})
		gb:AddButton('Load', function()
			local val = Options.ThemeManager_BuiltInThemeList.Value
			if val and val ~= '' then self:ApplyTheme(val) end
		end):AddButton('Set as Autoload', function()
			local val = Options.ThemeManager_BuiltInThemeList.Value
			if val and val ~= '' then
				self:SaveDefault(val, false)
				refreshAutoloadLabel(val)
			end
		end)

		gb:AddDivider()
		gb:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom Theme Name' })
		gb:AddDropdown('ThemeManager_CustomThemeList', {
			Text     = 'Custom Themes',
			Values   = self:ReloadCustomThemes(),
			Default  = 1,
		})
		gb:AddDivider()
		gb:AddButton('Save', function()
			local n = Options.ThemeManager_CustomThemeName.Value
			self:SaveCustomTheme(n)
			local list = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList.Values = list
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(n)
		end):AddButton('Load', function()
			local val = Options.ThemeManager_CustomThemeList.Value
			if val and val ~= '' then self:ApplyTheme(val) end
		end)
		gb:AddButton('Overwrite', function()
			local name = Options.ThemeManager_CustomThemeList.Value
			if not name or name == '' then return self.Library:Notify('No theme selected.', 2) end
			self:SaveCustomTheme(name)
		end):AddButton('Delete', function()
			local name = Options.ThemeManager_CustomThemeList.Value
			if not name or name == '' then return self.Library:Notify('No theme selected.', 2) end
			local path = self.Folder .. '/Themes/' .. name .. '.json'
			if not isfile(path) then return warn('[Elite Zone] Theme file not found.', 2) end
			delfile(path)
			local list = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList.Values = list
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		gb:AddButton('Refresh', function()
			local list = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList.Values = list
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Set as Autoload', function()
			local val = Options.ThemeManager_CustomThemeList.Value
			if val and val ~= '' then
				self:SaveDefault(val, true)
				refreshAutoloadLabel(val)
			end
		end)
		gb:AddButton('Export', function()
			local ok, encoded = self:GetThemeJSON()
			if not ok then return self.Library:Notify('Invalid Theme.', 3) end
			self.Library:CreatePrompt({ Title = 'Export Theme', Mode = 'Export', Text = encoded })
		end):AddButton('Import', function()
			self.Library:CreatePrompt({
				Title     = 'Import Theme',
				Mode      = 'Import',
				Callback  = function(text, name)
					if name:gsub(' ', '') == '' then
						return self.Library:Notify('Name cannot be empty', 2)
					end
					local ok = pcall(Services.HttpService.JSONDecode, Services.HttpService, text)
					if not ok then return self.Library:Notify('Invalid Theme.', 2) end
					writefile(self.Folder .. '/Themes/' .. name .. '.json', text)
					local list = self:ReloadCustomThemes()
					Options.ThemeManager_CustomThemeList.Values = list
					Options.ThemeManager_CustomThemeList:SetValues()
					Options.ThemeManager_CustomThemeList:SetValue(name)
					self:ApplyTheme(name)
				end,
			})
		end)
	end

	function ThemeManager:ReadAutoloadName()
		local file = self.Folder .. '/Themes/autoload.txt'
		if isfile and isfile(file) then
			local name = readfile(file):match('^%s*(.-)%s*$')
			if type(name) == 'string' and name ~= '' then return name end
		end
		return 'Default'
	end

	function ThemeManager:RegisterSharedCallbacks(gb)
		local function UpdateTheme() self:ThemeUpdate() end
		if Options.ThemeManager_Font then Options.ThemeManager_Font:OnChanged(UpdateTheme) end
		if Options.ThemeManager_IconSize then Options.ThemeManager_IconSize:OnChanged(UpdateTheme) end
		for _, f in ipairs({
			'BackgroundColor','MainColor','AccentColor','OutlineColor','FontColor',
		}) do
			if Options[f] then Options[f]:OnChanged(UpdateTheme) end
		end
	end

	function ThemeManager:CreateThemeManager(groupbox)
		self:BuildThemeSections(groupbox, true)
		ThemeManager.AutoloadLabel1 = groupbox:AddLabel('Autoload: ' .. self:ReadAutoloadName(), true)
		self:RegisterSharedCallbacks(groupbox)
		ThemeManager:LoadDefault()
	end

	function ThemeManager:ApplyToTabs(normalTab, settingsGroupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')

		normalTab:AddLabel('background'):AddColorPicker('BackgroundColor', { Title = 'background', Default = self.Library.BackgroundColor })
		normalTab:AddLabel('main color'):AddColorPicker('MainColor', { Title = 'main color', Default = self.Library.MainColor })
		normalTab:AddLabel('accent'):AddColorPicker('AccentColor', { Title = 'accent', Default = self.Library.AccentColor })
		normalTab:AddLabel('outline'):AddColorPicker('OutlineColor', { Title = 'outline', Default = self.Library.OutlineColor })
		normalTab:AddLabel('font color'):AddColorPicker('FontColor', { Title = 'font color', Default = self.Library.FontColor })


		self:BuildThemeSections(settingsGroupbox, false)

		settingsGroupbox:AddDivider()
		ThemeManager.AutoloadLabel2 = settingsGroupbox:AddLabel('Autoload: ' .. self:ReadAutoloadName(), true)

		self:RegisterSharedCallbacks(settingsGroupbox)
		ThemeManager:LoadDefault()
	end

	function ThemeManager:GetCustomTheme(file)
		if file == '__default' then
			return nil
		end
		local path = self.Folder .. '/Themes/' .. file .. '.json'
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, data)

		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:GetThemeJSON()
		local theme = {
			font      = Options.ThemeManager_Font and Options.ThemeManager_Font.Value or getFontName(self.Library.Font),
			iconSize  = tonumber(Options.ThemeManager_IconSize and Options.ThemeManager_IconSize.Value) or self.Library.IconSize or 20,
			uiScale   = tonumber(Options.ThemeManager_UIScale and Options.ThemeManager_UIScale.Value) or self.Library.UIScaleValue or 1.0,
			colors    = {},
		}
		if self.Library and type(self.Library.GetMainWindowSize) == 'function' then
			theme.mainWindowSize = self.Library:GetMainWindowSize()
		end

		for _, field in next, self.ColorFields do
			theme.colors[field] = Options[field].Value:ToHex()
		end

		local ok, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, theme)
        if not ok then warn('[Elite Zone] Failed to encode data.') return false end
        return true, encoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if type(file) ~= 'string' or file:gsub(' ', '') == '' or file == '__default' then
			return self.Library:Notify('Name cannot be empty.', 3)
		end

		local ok, encoded = self:GetThemeJSON()
		if not ok then return warn('[Elite Zone] Failed to encode data.') end

		writefile(self.Folder .. '/Themes/' .. file .. '.json', encoded)
	end

	function ThemeManager:ReloadCustomThemes()
		local folder = self.Folder .. '/Themes'
		if not isfolder(folder) then return {} end
		local list = listfiles(folder)
		local out = {}
		for _, file in ipairs(list) do
			if type(file) == 'string' and file:sub(-5) == '.json' then
				local name = file:match"([^/\\]+)%.json$"
				if name and name ~= '' and name ~= '__default' then table.insert(out, name) end
			end
		end
		table.sort(out)
		return out
	end

	function ThemeManager:GetBuiltInThemeNames()
		local sorted = {}
		for name in next, self.BuiltInThemes do table.insert(sorted, name) end
		table.sort(sorted, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)
		return sorted
	end

	function ThemeManager:GetAllThemes()
		local out = {}
		for _, name in ipairs(self:GetBuiltInThemeNames()) do table.insert(out, name) end
		local custom = self:ReloadCustomThemes()
		for _, name in ipairs(custom) do
			if not self.BuiltInThemes[name] then
				table.insert(out, name)
			end
		end
		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
		if lib then
			lib.ThemeManager = self
		end
	end

	function ThemeManager:PreApply(library, folder)
		if library then self.Library = library end
		if folder  then self.Folder  = folder  end
		if not self.Library then return end

		self:BuildFolderTree()

		local theme = self:ReadAutoloadName()
		if not (self.BuiltInThemes[theme] or self:GetCustomTheme(theme)) then
			theme = 'Default'
		end

		local customData = self:GetCustomTheme(theme)
		local builtIn    = self.BuiltInThemes[theme]
		local data       = self:NormalizeThemeData(customData or (builtIn and builtIn[2]))
		if not data then return end

		for idx, col in next, data.colors do
			local ok, parsed = pcall(Color3.fromHex, col)
			if ok then self.Library[idx] = parsed end
		end
		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
		self.CurrentThemeName = theme
		self.CurrentThemeCustom = not self.BuiltInThemes[theme]
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/Themes')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end

	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Theme')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end


--[[ SaveManager ]]

local SaveManager = {} do

SaveManager.Folder = 'Elite Zone/Rivals'
SaveManager.Ignore = {}
SaveManager.DynamicLists = {}
SaveManager.CustomData   = {}
SaveManager.SaveHooks    = {}
SaveManager.LoadHooks    = {}

function SaveManager.RegisterDynamicList(self, key, dl)
    self.DynamicLists[key] = dl
end

function SaveManager.RegisterCustomData(self, key, saveFn, loadFn)
    self.CustomData[key] = { save = saveFn, load = loadFn }
end

function SaveManager.RegisterSaveHook(self, fn) table.insert(self.SaveHooks, fn) end
function SaveManager.RegisterLoadHook(self, fn) table.insert(self.LoadHooks, fn) end

SaveManager.Parser = {
    Toggle = {
        Save = function(idx, object)
            return { type = 'Toggle', idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if Toggles[idx] then Toggles[idx]:SetValue(data.value) end
        end,
    },
    Slider = {
        Save = function(idx, object)
            return { type = 'Slider', idx = idx, value = tostring(object.Value) }
        end,
        Load = function(idx, data)
            if Options[idx] then Options[idx]:SetValue(data.value) end
        end,
    },
    Dropdown = {
        Save = function(idx, object)
            return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
        end,
        Load = function(idx, data)
            if Options[idx] then Options[idx]:SetValue(data.value) end
        end,
    },
    ColorPicker = {
        Save = function(idx, object)
            return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
        end,
        Load = function(idx, data)
            if Options[idx] then Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency) end
        end,
    },
    KeyPicker = {
        Save = function(idx, object)
            return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
        end,
        Load = function(idx, data)
            if Options[idx] then Options[idx]:SetValue{ data.key, data.mode } end
        end,
    },
    Input = {
        Save = function(idx, object)
            return { type = 'Input', idx = idx, text = object.Value }
        end,
        Load = function(idx, data)
            if Options[idx] and type(data.text) == 'string' then Options[idx]:SetValue(data.text) end
        end,
    },
    GradientColorPicker = {
        Save = function(idx, object)
            local vals, transes = {}, {}
            for i = 1, 3 do
                vals[i]   = object.Values[i]:ToHex()
                transes[i] = object.Transparencies[i]
            end
            return { type = 'GradientColorPicker', idx = idx, values = vals, transparencies = transes }
        end,
        Load = function(idx, data)
            if not Options[idx] then return end
            if type(data.values) ~= 'table' or #data.values ~= 3 then return end
            local vals, transes = {}, {}
            for i = 1, 3 do
                vals[i]   = Color3.fromHex(data.values[i])
                transes[i] = tonumber(data.transparencies and data.transparencies[i]) or 0
            end
            Options[idx]:SetValues(vals, transes)
        end,
    },
}

function SaveManager.BuildFolderTree(self)
    if not isfolder then return end
    local paths = {}
    for _, path in ipairs(paths) do
        if not isfolder(path) then makefolder(path) end
    end
end

function SaveManager.SetIgnoreIndexes(self, list)
    for _, key in next, list do self.Ignore[key] = true end
end

function SaveManager.IgnoreThemeSettings(self)
    self:SetIgnoreIndexes{
        'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor',
        'ThemeManager_Font', 'ThemeManager_IconSize', 'ThemeManager_UIScale',
        'ThemeManager_ThemeList', 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
        'MenuBind',
        'SaveManager_ConfigList', 'SaveManager_ConfigName',
    }
end

function SaveManager.SetFolder(self, folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function SaveManager.SetLibrary(self, library)
    self.Library = library
end



function SaveManager.GetConfigJSON(self)
    local data = { objects = {} }

    for idx, toggle in next, Toggles do
        if self.Ignore[idx] then continue end
        local ok, entry = pcall(self.Parser.Toggle.Save, idx, toggle)
        if ok then table.insert(data.objects, entry) end
    end

    for idx, option in next, Options do
        if self.Ignore[idx] then continue end
        if not self.Parser[option.Type] then continue end
        local ok, entry = pcall(self.Parser[option.Type].Save, idx, option)
        if ok then table.insert(data.objects, entry) end
    end

    local dlData = {}
    for key, dl in next, self.DynamicLists do
        local entries = dl:GetEntries()
        local out = {}
        local isTextOnly = dl.TextOnly
        for _, e in ipairs(entries) do
            if type(e) == "table" and e.textVal ~= nil then
                out[#out+1] = isTextOnly and e.textVal or {text=e.textVal, chance=tonumber(e.chanceVal) or 50}
            else
                out[#out+1] = tostring(e)
            end
        end
        dlData[key] = out
    end
    data.dynamicLists = dlData

    local cdData = {}
    for key, cd in next, self.CustomData do
        local ok, val = pcall(cd.save)
        if ok then cdData[key] = val end
    end
    data.customData = cdData

    for _, h in ipairs(self.SaveHooks) do pcall(h, data) end

    local ok, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, data)
    if not ok then warn('[Elite Zone] Failed to encode data.') return false end
    return true, encoded
end

function SaveManager.Save(self, name)
    if not writefile then warn('[Elite Zone] Unsupported Executor.') return false end
    if not name or name:gsub(' ', '') == '' then self.Library:Notify('Name cannot be empty.', 2) return false end

    local ok, encoded = self:GetConfigJSON()
    if not ok then return false end

    writefile('Elite Zone/Rivals/Settings/' .. name .. '.json', encoded)
    return true
end

function SaveManager.LoadConfigJSON(self, jsonString)
    local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, jsonString)
    if not ok then warn('[Elite Zone] Failed to decode data.') return false end

    local toggles = {}
    for _, option in next, decoded.objects do
        if self.Parser[option.type] then
            if option.type == 'Toggle' then
                toggles[#toggles + 1] = option
            else
                pcall(self.Parser[option.type].Load, option.idx, option)
            end
        end
    end

    if decoded.dynamicLists then
        for key, entries in next, decoded.dynamicLists do
            local dl = self.DynamicLists[key]
            if dl and type(entries) == "table" then
                pcall(function() dl:SetEntries(entries) end)
            end
        end
    end

    if decoded.customData then
        for key, val in next, decoded.customData do
            local cd = self.CustomData[key]
            if cd then
                pcall(cd.load, val)
            end
        end
    end

    task.spawn(function()
        local BATCH = 3
        for i = 1, #toggles do
            local option = toggles[i]
            pcall(self.Parser[option.type].Load, option.idx, option)
            if i % BATCH == 0 then task.wait() end
        end
    end)

    for _, h in ipairs(self.LoadHooks) do pcall(h, decoded) end

    return true
end

function SaveManager.Load(self, name)
    if not readfile then warn('[Elite Zone] Unsupported Executor.') return false end
    if not name then self.Library:Notify('Name cannot be empty.', 2) return false end

    local file = 'Elite Zone/Rivals/Settings/' .. name .. '.json'
    if not isfile(file) then warn('[Elite Zone] File not found.') return false end

    return self:LoadConfigJSON(readfile(file))
end

function SaveManager.RefreshConfigList(self)
    local folder = 'Elite Zone/Rivals/Settings'
    if not isfolder(folder) then return {} end
    local list = listfiles(folder)
    local out = {}
    for _, file in ipairs(list) do
        if type(file) == 'string' and file:sub(-5) == '.json' then
            local name = file:match"([^/\\]+)%.json$"
            if name and name ~= '' then table.insert(out, name) end
        end
    end
    return out
end

function SaveManager.LoadAutoloadConfig(self)
    local autoloadFile = 'Elite Zone/Rivals/Settings/autoload.txt'
    if isfile(autoloadFile) then
        local name = readfile(autoloadFile)
        local ok, err = self:Load(name)
        if not ok then
            if self.Library then warn('[Elite Zone] Autoload failed: ' .. err) end
            return
        end
    end
end

function SaveManager.BuildConfigSection(self, tabOrGroupbox)
    assert(self.Library, 'SaveManager: call SetLibrary before BuildConfigSection')

    local section
    if type(tabOrGroupbox.AddLeftGroupbox) == 'function' then
        section = tabOrGroupbox:AddLeftGroupbox('Gameplay Configs')
    elseif type(tabOrGroupbox.AddInput) == 'function' then
        section = tabOrGroupbox
    else
        error'BuildConfigSection: expected a Tab or Groupbox'
    end

    section:AddInput('SaveManager_ConfigName', { Text = 'Config Name' })
    section:AddDropdown('SaveManager_ConfigList', { Text = 'Configs', Values = self:RefreshConfigList(), AllowNull = true })
    section:AddDivider()

    section:AddButton('Save Config', function()
        local name = Options.SaveManager_ConfigName.Value
        if name:gsub(' ', '') == '' then return self.Library:Notify('Name cannot be empty.', 2) end
        local ok, err = self:Save(name)
        if not ok then return warn('[Elite Zone] Failed to save config.') end
        Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
        Options.SaveManager_ConfigList:SetValues()
        Options.SaveManager_ConfigList:SetValue(nil)
    end):AddButton('Load Config', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        local ok, err = self:Load(name)
        if not ok then return warn('[Elite Zone] Failed to load config') end
    end)

    section:AddButton('Overwrite', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        local ok, err = self:Save(name)
        if not ok then return warn('[Elite Zone] Failed to save config') end
    end):AddButton('Delete', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        self.Library:CreatePrompt({
            Title = "Delete Config",
            Mode = "Confirm",
            Text = 'Are you sure you want to delete "' .. name .. '"?',
            Callback = function()
                local path = 'Elite Zone/Rivals/Settings/' .. name .. '.json'
                if isfile(path) then
                    delfile(path)
                    Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
                    Options.SaveManager_ConfigList:SetValues()
                    Options.SaveManager_ConfigList:SetValue(nil)
                end
            end
        })
    end)

    section:AddButton('Refresh List', function()
        Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
        Options.SaveManager_ConfigList:SetValues()
        Options.SaveManager_ConfigList:SetValue(nil)
    end):AddButton('Set as autoload', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        writefile('Elite Zone/Rivals/Settings/autoload.txt', name)
        if SaveManager.AutoloadLabel then SaveManager.AutoloadLabel:SetText('Autoload: ' .. name) end
    end)

    section:AddDivider()

    section:AddButton('Export Config', function()
        local ok, encoded = self:GetConfigJSON()
        if not ok then return warn('[Elite Zone] Failed to encode config') end
        self.Library:CreatePrompt({
            Title = "Export Config",
            Mode = "Export",
            Text = encoded,
        })
    end)

    section:AddButton('Import Config', function()
        self.Library:CreatePrompt({
            Title = "Import Config",
            Mode = "Import",
            Callback = function(text, name)
                if name:gsub(' ', '') == '' then
                    return self.Library:Notify('Name cannot be empty.', 2)
                end
                local ok, err = self:LoadConfigJSON(text)
                if not ok then
                    return warn('[Elite Zone] Failed to load config')
                end
                self:Save(name)
                Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
                Options.SaveManager_ConfigList:SetValues()
                Options.SaveManager_ConfigList:SetValue(nil)
            end
        })
    end)

    local autoName = '__autosave'
    if isfile and isfile'Elite Zone/Rivals/Settings/autoload.txt' then
        autoName = readfile'Elite Zone/Rivals/Settings/autoload.txt'
    end
    SaveManager.AutoloadLabel = section:AddLabel('Autoload: ' .. autoName, true)

    self:SetIgnoreIndexes{ 'SaveManager_ConfigList', 'SaveManager_ConfigName' }
end

SaveManager:BuildFolderTree()
end

getgenv().EZLibrary = Library
getgenv().EZThemeManager = ThemeManager
getgenv().EZSaveManager = SaveManager

return {
    Library      = Library;
    ThemeManager = ThemeManager;
    SaveManager  = SaveManager;
}
end)()
