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
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Name = "ScreenGUI"
ScreenGui.Parent = (gethui and gethui()) or Services.CoreGui

local IsTouch  = (rawget(_G, "mobiledebug") == true) or (Services.UserInputService.TouchEnabled and not Services.UserInputService.MouseEnabled)

local Camera       = workspace.CurrentCamera
local ScreenWidth  = Camera.ViewportSize.X
local ScreenHeight = Camera.ViewportSize.Y

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
    ActiveDropdownList      = nil;
    DropdownRegistry        = {};
    SliderRegistry          = {};
    KeybindRegistry         = {};
    KeybindListMode         = 'Enabled';
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

Library.CaseSettings = {
    Tabs          = "Capitalized",
    SubTabs       = "Capitalized",
    Groupboxes    = "Capitalized",
    Toggles       = "Capitalized",
    Buttons       = "Capitalized",
    Sliders       = "Capitalized",
    Dropdowns     = "Capitalized",
    DropdownItems = "Capitalized",
    Labels        = "Capitalized",
    Inputs        = "Capitalized",
    Keybinds      = "Capitalized",
    Tooltip       = "Lowercase",
}
Library.TextRegistry = {}

function Library:ApplyCase(text, category, forceMode)
    local s = tostring(text or "")
    local mode = forceMode or (Library.CaseSettings and Library.CaseSettings[category]) or "Capitalized"
    if mode == "Original" then
        return s
    elseif mode == "Uppercase" then
        return s:upper()
    elseif mode == "Lowercase" then
        return s:lower()
    else
        return (s:gsub("(%a)([%w]*)", function(a, b) return a:upper() .. b end))
    end
end

function Library:TrackLabel(lbl, originalText, category, prop, forceMode)
    if not lbl then return end
    Library.TextRegistry[#Library.TextRegistry + 1] = { lbl = lbl, text = originalText, cat = category, prop = prop or "Text", forceMode = forceMode }
end

function Library:ForceCase(Root, Mode)
    if not Root then return end
    local function Matches(inst)
        return inst == Root or inst:IsDescendantOf(Root)
    end
    for _, e in ipairs(Library.TextRegistry) do
        if e.lbl and e.lbl.Parent and Matches(e.lbl) then
            e.forceMode = Mode
        end
    end
    for _, s in ipairs(Library.SliderRegistry or {}) do
        if s.Outer and s.Outer.Parent and Matches(s.Outer) then
            s.Info.CaseOverride = Mode
        end
    end
    for _, dd in ipairs(Library.DropdownRegistry or {}) do
        if dd.Outer and dd.Outer.Parent and Matches(dd.Outer) then
            dd.CaseOverride = Mode
        end
    end
    Library:RefreshTextRegistry()
end

function Library:RefreshTextRegistry()
    for _, e in ipairs(Library.TextRegistry) do
        if e.lbl and e.lbl.Parent then
            e.lbl[e.prop] = Library:ApplyCase(e.text, e.cat, e.forceMode)
        end
    end
    for _, dd in ipairs(Library.DropdownRegistry or {}) do
        if dd.ItemLabels then
            for _, entry in ipairs(dd.ItemLabels) do
                if entry.lbl and entry.lbl.Parent then
                    entry.lbl.Text = Library:ApplyCase(entry.val, "DropdownItems", dd.CaseOverride)
                end
            end
        end
        if dd.Display then pcall(dd.Display, dd) end
    end
    for _, s in ipairs(Library.SliderRegistry or {}) do
        if s.Display then pcall(s.Display, s) end
    end
    for _, k in ipairs(Library.KeybindRegistry or {}) do
        if k.Update then pcall(k.Update, k) end
    end
end

function Library:SetText(Element, NewText)
    if not Element or NewText == nil then return false end
    NewText = tostring(NewText)

    if Element.Info and Element.Info.Text ~= nil and Element.Display then
        Element.Info.Text = NewText
        pcall(Element.Display, Element)
        return true
    end

    local Label = Element.TextLabel or Element.TitleLabel
    if not Label then return false end

    for _, entry in ipairs(Library.TextRegistry) do
        if entry.lbl == Label then
            entry.text = NewText
            entry.lbl[entry.prop] = Library:ApplyCase(NewText, entry.cat)
            return true
        end
    end

    local ok = pcall(function() Label.Text = NewText end)
    return ok
end

function Library:RemoveElement(Element)
    if not Element then return false end

    for _, part in ipairs(Element.DestroyParts or {}) do
        if part then pcall(function() part:Destroy() end) end
    end
    if Element.Outer then pcall(function() Element.Outer:Destroy() end) end

    for idx, el in pairs(Toggles) do if el == Element then Toggles[idx] = nil end end
    for idx, el in pairs(Options) do if el == Element then Options[idx] = nil end end

    local function Pull(list)
        if not list then return end
        for i = #list, 1, -1 do if list[i] == Element then table.remove(list, i) end end
    end
    Pull(Library.SliderRegistry)
    Pull(Library.DropdownRegistry)
    Pull(Library.KeybindRegistry)
    Pull(Library.DependencyBoxes)

    for i = #Library.TextRegistry, 1, -1 do
        local entry = Library.TextRegistry[i]
        if entry.lbl == Element.TextLabel or entry.lbl == Element.TitleLabel then
            table.remove(Library.TextRegistry, i)
        end
    end

    return true
end

function Library:SafeCallback(f, ...)
    if not f then return end
    if not Library.NotifyOnError then return f(...) end
    pcall(f, ...)
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
            inst.Text = self:NormalizeText(Props.Text)
        end
        if type(Props.PlaceholderText) == "string" then
            inst.PlaceholderText = self:NormalizeText(Props.PlaceholderText)
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
        TextSize                = (Props.TextSize or 16);
        TextStrokeTransparency  = 0;
    })
    Library:AddToRegistry(inst, { TextColor3 = 'FontColor'; Font = 'Font' }, IsHud)
    local p2 = {}
    for k, v in next, Props do p2[k] = v end
    if p2.TextSize then p2.TextSize = (p2.TextSize) end
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

function Library:IsPositionOverFrame(px, py, Frame)
    local ap, as = Frame.AbsolutePosition, Frame.AbsoluteSize
    return px >= ap.X and px <= ap.X + as.X and py >= ap.Y and py <= ap.Y + as.Y
end

function Library:IsPointerOverSwatchOrFrame(px, py, Swatch, Frame, buffer)
    if Library:IsPositionOverFrame(px, py, Frame) then return true end
    local ap, as = Swatch.AbsolutePosition, Swatch.AbsoluteSize
    buffer = buffer or 0
    return px >= ap.X - buffer and px <= ap.X + as.X + buffer and py >= ap.Y - buffer and py <= ap.Y + as.Y + buffer
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

local function SwapRemoveIndexed(list, data, indexField)
    local i = data[indexField]
    if not i then return end
    local lastIdx  = #list
    local lastItem = list[lastIdx]
    list[i] = lastItem
    if lastItem then lastItem[indexField] = i end
    list[lastIdx] = nil
    data[indexField] = nil
end

function Library:AddToRegistry(inst, props, isHud)
    local data = { Instance = inst; Properties = props }
    data.Index = #Library.Registry + 1
    Library.Registry[data.Index] = data
    Library.RegistryMap[inst] = data
    if isHud then
        data.HudIndex = #Library.HudRegistry + 1
        Library.HudRegistry[data.HudIndex] = data
    end
end

function Library:RemoveFromRegistry(inst)
    local data = Library.RegistryMap[inst]
    if not data then return end
    SwapRemoveIndexed(Library.Registry, data, "Index")
    SwapRemoveIndexed(Library.HudRegistry, data, "HudIndex")
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
    Library.DropdownRegistry = {}
    Library.SliderRegistry = {}
    Library.KeybindRegistry = {}
    if Library.OnUnload then Library.OnUnload() end
    if not IsTouch then
        local ezBlur = Services.Lighting:FindFirstChild("Blur")
        if ezBlur then ezBlur:Destroy() end
    end
    ScreenGui:Destroy()
end

function Library:OnUnload(cb)
    Library.OnUnload = cb
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(inst)
    if Library.RegistryMap[inst] then Library:RemoveFromRegistry(inst) end
end))

function Library:CreateGhostOverlay(x, y, w, h)
    local Fill = Drawing.new("Square")
    Fill.Filled       = true
    Fill.Thickness    = 0
    Fill.Transparency = 0.35
    Fill.Color        = Library.AccentColor
    Fill.Position     = Vector2.new(x, y)
    Fill.Size         = Vector2.new(w, h)
    Fill.Visible      = true

    local Border = Instance.new("Frame")
    Border.Name                   = "GhostBorder"
    Border.Active                 = false
    Border.BackgroundTransparency = 1
    Border.Position               = UDim2.fromOffset(x, y)
    Border.Size                   = UDim2.fromOffset(w, h)
    Border.ZIndex                 = 2147483647
    Border.Parent                 = Library.ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness       = 1
    Stroke.Color           = Library.AccentColor
    Stroke.Transparency    = 0
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.LineJoinMode    = Enum.LineJoinMode.Miter
    Stroke.Parent          = Border

    local function Update(nx, ny, nw, nh)
        Fill.Color     = Library.AccentColor
        Fill.Position   = Vector2.new(nx, ny)
        Fill.Size       = Vector2.new(nw, nh)
        Stroke.Color    = Library.AccentColor
        Border.Position = UDim2.fromOffset(nx, ny)
        Border.Size     = UDim2.fromOffset(nw, nh)
    end

    local function Remove()
        Fill:Remove()
        Border:Destroy()
    end

    return Update, Remove
end

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

            local UpdateGhost, RemoveGhost = Library:CreateGhostOverlay(gx, gy, gw, gh)

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
                UpdateGhost(gx + delta.X, gy + delta.Y, gw, gh)
            end)

            local endConn
            endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
                if Library:IsPointerInput(eInput) then
                    dragging = false
                    moveConn:Disconnect()
                    endConn:Disconnect()
                    local delta = dragInput.Position - dragStart
                    Frame.Position = UDim2.fromOffset(
                        startAbsPos.X + delta.X - pAbs.X,
                        startAbsPos.Y + delta.Y - pAbs.Y
                    )
                    RemoveGhost()
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
        PaddingLeft    = UDim.new(0, (6));
        PaddingRight   = UDim.new(0, (6));
        PaddingTop     = UDim.new(0, (4));
        PaddingBottom  = UDim.new(0, (4));
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
        TextSize                = (13);
        TextWrapped             = false;
        TextXAlignment          = Enum.TextXAlignment.Left;
        ZIndex                  = 101;
        Parent                  = tip;
    })
    Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 2); PaddingRight = UDim.new(0, 2); Parent = TooltipLabel })
    Library:SetTRText(TooltipLabel, Library:ApplyCase(InfoStr, "Tooltip"))
    Library:TrackLabel(TooltipLabel, InfoStr, "Tooltip")
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

Library.NotifyConfig = {
    ClipDescendants  = false;
    MaxHeight        = (200);
    PosX             = 50;
    PosY             = 60;
    Transparency     = 60;
    Alignment        = "Center";
    BarSide          = "Bottom";
    SortOrder        = "Time";
}
Library.NotifyCounter = 0

function Library:ConfigureNotifications(Cfg)
    local C = Library.NotifyConfig
    for k, v in next, Cfg do C[k] = v end

    local AnchorX = C.Alignment == "Left" and 0 or (C.Alignment == "Right" and 1 or 0.5)
    local AnchorY = C.BarSide == "Top" and 0 or 1
    local VAlign  = C.BarSide == "Top" and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
    local HAlign  = C.Alignment == "Left" and Enum.HorizontalAlignment.Left or (C.Alignment == "Right" and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center)

    Library.NotificationArea.AnchorPoint        = Vector2.new(AnchorX, AnchorY)
    Library.NotificationArea.Position           = UDim2.new(C.PosX / 100, 0, C.PosY / 100, 0)
    Library.NotificationArea.ClipsDescendants   = C.ClipDescendants
    Library.NotificationArea.AutomaticSize      = Enum.AutomaticSize.XY

    local SizeConstraint = Library.NotificationArea:FindFirstChildOfClass('UISizeConstraint')
    if C.ClipDescendants then
        if not SizeConstraint then
            SizeConstraint = Library:Create('UISizeConstraint', { Parent = Library.NotificationArea })
        end
        SizeConstraint.MaxSize = Vector2.new(math.huge, C.MaxHeight)
    elseif SizeConstraint then
        SizeConstraint:Destroy()
    end

    local Layout = Library.NotificationArea:FindFirstChildOfClass('UIListLayout')
    if Layout then
        Layout.VerticalAlignment    = VAlign
        Layout.HorizontalAlignment  = HAlign
    end
end

do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, 0, 0, (40));
        Size                    = UDim2.new(0, (320), 1, -(50));
        ZIndex                  = 100;
        Parent                  = ScreenGui;
    })
    Library:Create('UIListLayout', {
        Padding        = UDim.new(0, (4));
        FillDirection  = Enum.FillDirection.Vertical;
        SortOrder      = Enum.SortOrder.LayoutOrder;
        Parent         = Library.NotificationArea;
    })
    Library:ConfigureNotifications({})

    local WindowMoverOuter = Library:Create('Frame', {
        BorderColor3  = Color3.new(0,0,0);
        Position      = UDim2.fromOffset((1000), -(25));
        Size          = UDim2.fromOffset((213), (20));
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
        Position        = UDim2.new(0, (5), 0, 0);
        Size            = UDim2.new(1, -(4), 1, 0);
        TextSize        = (14);
        TextXAlignment  = Enum.TextXAlignment.Left;
        ZIndex          = 203;
        Parent          = WindowMoverGradientFrame;
    })
    Library.Watermark     = WindowMoverOuter
    Library.WatermarkText = WindowMoverLabel
    Library:MakeDraggable(WindowMoverOuter)

    if not IsTouch then
        local KeybindOuter = Library:Create('Frame', {
            AnchorPoint            = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            BorderColor3           = Color3.new(0,0,0);
            Position               = UDim2.new(0, (10), 0.5, 0);
            Size                   = UDim2.fromOffset((210), (20));
            Visible                = false;
            ZIndex                 = 100;
            Parent                 = ScreenGui;
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
            Size            = UDim2.new(1,0,0,(20));
            Position        = UDim2.fromOffset(0, (2));
            TextXAlignment  = Enum.TextXAlignment.Center;
            Text            = 'Keybinds';
            Font            = Enum.Font.GothamBold;
            ZIndex          = 104;
            Parent          = KeybindInner;
        })
        local KeybindContainer = Library:Create('Frame', {
            BackgroundTransparency  = 1;
            Position                = UDim2.new(0,0,0,(22));
            Size                    = UDim2.new(1,0,1,-(22));
            ZIndex                  = 1;
            Parent                  = KeybindInner;
        })
        Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Vertical; SortOrder = Enum.SortOrder.LayoutOrder; Parent = KeybindContainer })
        Library:Create('UIPadding',    { PaddingLeft = UDim.new(0, (5)); Parent = KeybindContainer })
        Library.KeybindFrame     = KeybindOuter
        Library.KeybindContainer = KeybindContainer
        Library.KeybindInner     = KeybindInner
        Library:MakeDraggableDirect(KeybindOuter)
    else
        local stub = Instance.new('Frame')
        stub.Visible = false
        Library.KeybindFrame     = stub
        Library.KeybindContainer = stub
    end
end

function Library:SetWatermarkVisibility(b)  Library.Watermark.Visible = b end
function Library:SetKeybindTransparency(t)
    if Library.KeybindInner then Library.KeybindInner.BackgroundTransparency = t end
end

function Library:SetKeybindVisibility(b)
    Library.KeybindFrame.Visible = b
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

        local UpdateGhost, RemoveGhost = Library:CreateGhostOverlay(gx, gy, startW, startH)

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
            UpdateGhost(gx, gy, nw, nh)
        end)

        local endConn
        endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
            if not Library:IsPointerInput(eInput) then return end
            dragging = false
            moveConn:Disconnect()
            endConn:Disconnect()

            local dx = dragInput.Position.X - startX
            local dy = dragInput.Position.Y - startY
            RemoveGhost()

            if type(setSize) == 'function' then
                setSize(startW + dx, startH + dy)
            end

            circleInst.BackgroundTransparency = defaultTrans

            if type(onFinish) == 'function' then
                onFinish()
            end
        end)
    end)
end

function Library:SetWatermark(Text)
    local textWidth = Library:GetTextBounds(Text, Library.Font, (14))
    Library.Watermark.Size = UDim2.fromOffset(textWidth + (15), (20))
    Library.WatermarkText.Text = Text
    Library:SetWatermarkVisibility(true)
end

Library.NotifyQueue       = {}
Library.ActiveNotifyCount = 0

function Library:Notify(Text, Time)
    if not Text or Text == "" then return end
    table.insert(Library.NotifyQueue, { Text = Text, Time = Time })
    Library:ProcessNotifyQueue()
end

function Library:ProcessNotifyQueue()
    local C = Library.NotifyConfig
    local ItemHeight = (22) + (4)
    while #Library.NotifyQueue > 0 do
        if C.ClipDescendants and (Library.ActiveNotifyCount + 1) * ItemHeight > C.MaxHeight then break end
        local Item = table.remove(Library.NotifyQueue, 1)
        Library:SpawnNotify(Item.Text, Item.Time)
    end
end

function Library:SpawnNotify(Text, Time)
    local xw = (Library:GetTextBounds(Text, Library.CustomFontFace or Library.Font, (13)) or 200) * fontScale(Library.Font)
    local H   = (22)
    local NotifyTransparency = (Library.NotifyConfig.Transparency or 0) / 100
    Library.NotifyCounter = Library.NotifyCounter + 1
    local Outer = Library:Create('Frame', {
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Size                    = UDim2.fromOffset(0, H);
        ClipsDescendants        = true;
        LayoutOrder             = Library.NotifyConfig.SortOrder == "Text Length" and #Text or Library.NotifyCounter;
        ZIndex                  = 100;
        Parent                  = Library.NotificationArea;
    })
    local Inner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BackgroundTransparency = NotifyTransparency;
        BorderSizePixel   = 0;
        Size              = UDim2.new(1,0,1,0);
        ZIndex            = 101;
        Parent            = Outer;
    })
    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor' })
    local InnerStroke = Library:Create('UIStroke', {
        Color       = Library.OutlineColor;
        Transparency = NotifyTransparency;
        Thickness   = 1;
        Parent      = Inner;
    })
    Library:AddToRegistry(InnerStroke, { Color = 'OutlineColor' })
    local GradientFrame = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BackgroundTransparency = NotifyTransparency; BorderSizePixel = 0; Position = UDim2.new(0,1,0,1); Size = UDim2.new(1,-2,1,-2); ZIndex = 102; Parent = Inner })
    Library:AddToRegistry(GradientFrame, { BackgroundColor3 = 'MainColor' })
    local G  = Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }); Rotation = -90; Parent = GradientFrame })
    Library:AddToRegistry(G, { Color = function() return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)), ColorSequenceKeypoint.new(1, Library.MainColor) }) end })
    Library:CreateLabel({ PreserveCase = true; Position = UDim2.new(0, (8), 0, 0); Size = UDim2.new(1, -(8), 1, 0); Text = Text; TextXAlignment = Enum.TextXAlignment.Left; TextSize = (13); ZIndex = 103; Parent = GradientFrame })
    local BarOnTop = Library.NotifyConfig.BarSide == "Top"
    Library:Create('Frame', {
        BackgroundColor3  = Library.AccentColor;
        BorderSizePixel   = 0;
        Position          = BarOnTop and UDim2.new(0,-1,0,-1) or UDim2.new(0,-1,1,-2);
        Size              = UDim2.new(1, 2, 0, (3));
        ZIndex            = 104;
        Parent            = Outer;
    })
    Library:AddToRegistry(Outer:GetChildren()[#Outer:GetChildren()], { BackgroundColor3 = 'AccentColor' }, true)
    pcall(Outer.TweenSize, Outer, UDim2.fromOffset(xw + (16), H), 'Out', 'Quad', 0.35, true)
    Library.ActiveNotifyCount = Library.ActiveNotifyCount + 1
    task.spawn(function()
        task.wait(Time or 5)
        pcall(Outer.TweenSize, Outer, UDim2.fromOffset(0, H), 'Out', 'Quad', 0.35, true)
        task.wait(0.4)
        Outer:Destroy()
        Library.ActiveNotifyCount = Library.ActiveNotifyCount - 1
        Library:ProcessNotifyQueue()
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

        local DisplayWidth, DispH = (28), (14)
        local Swatch = Library:Create('Frame', {
            BackgroundColor3  = ColorPickerInfo.Value;
            BorderColor3      = Library:GetDarkerColor(ColorPickerInfo.Value);
            BorderMode        = Enum.BorderMode.Inset;
            Size              = UDim2.fromOffset(DisplayWidth, DispH);
            ZIndex            = 15;
            Parent            = TextLabelRef;
        })
        if Info.Transparency then
            Library:Create('ImageLabel', { BorderSizePixel = 0; Size = UDim2.new(0, DisplayWidth-1, 0, DispH-1); ZIndex = 14; Image = 'rbxassetid://12977615774'; Parent = Swatch })
        end

        local pickerW = (230)
        local pickerH = Info.Transparency and (271) or (253)
        local mapSz   = (200)

        local Blocker = Library:Create('Frame', { Name='ColorBlocker'; Active=true; BackgroundTransparency=1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(1,1); Visible=false; ZIndex=350; Parent=ScreenGui })
        local PickerFrameOuter = Library:Create('Frame', { Name = 'Color'; Active = true; BackgroundColor3 = Color3.new(1,1,1); BorderColor3 = Color3.new(0,0,0); Size = UDim2.fromOffset(pickerW, pickerH); Visible = false; ZIndex = 15; Parent = ScreenGui })
        local PickerFrameScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = PickerFrameOuter })
        table.insert(Library.ThemeScales, PickerFrameScale)
        local PickerFrameInner = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 16; Parent = PickerFrameOuter })
        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })

        local function UpdatePickerPos()
            local sap = Swatch.AbsolutePosition
            PickerFrameOuter.Position = UDim2.fromOffset(sap.X, sap.Y + Swatch.AbsoluteSize.Y + 1)
        end

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

        Library:CreateLabel({ Size = UDim2.new(1,0,0,(14)); Position = UDim2.fromOffset((5), (4)); TextSize = (13); Text = ColorPickerInfo.Title; TextXAlignment = Enum.TextXAlignment.Left; TextWrapped = false; ZIndex = 17; Parent = PickerFrameInner })

        local SatValOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, (4), 0, (24)); Size = UDim2.fromOffset(mapSz, mapSz); ZIndex = 17; Parent = PickerFrameInner })
        local SatValInner = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = SatValOuter })
        local SatValMap   = Library:Create('ImageLabel', { BorderSizePixel = 0; Size = UDim2.new(1,0,1,0); ZIndex = 18; Image = 'rbxassetid://4155801252'; Parent = SatValInner })
        Library:AddToRegistry(SatValInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })

        local CursorOuter = Library:Create('ImageLabel', { AnchorPoint = Vector2.new(0.5,0.5); Size = UDim2.fromOffset((6),(6)); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ImageColor3=Color3.new(0,0,0); ZIndex=19; Parent=SatValMap })
        Library:Create('ImageLabel', { Size=UDim2.fromOffset((4),(4)); Position=UDim2.fromOffset(1,1); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ZIndex=20; Parent=CursorOuter })

        local HueOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, (208), 0, (24)); Size = UDim2.fromOffset((15), mapSz); ZIndex = 17; Parent = PickerFrameInner })
        local HueInner = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderSizePixel = 0; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = HueOuter })
        local hueSKP  = {}
        for i = 0, 1, 0.1 do table.insert(hueSKP, ColorSequenceKeypoint.new(math.min(i,1), Color3.fromHSV(i,1,1))) end
        Library:Create('UIGradient', { Color = ColorSequence.new(hueSKP); Rotation = 90; Parent = HueInner })
        local HueCursor = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderColor3 = Color3.new(0,0,0); AnchorPoint = Vector2.new(0,0.5); Size = UDim2.new(1,0,0,1); ZIndex = 19; Parent = HueInner })

        local HexInputOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0, (4), 0, (228)); Size = UDim2.new(0.5, -(6), 0, (20)); ZIndex = 18; Parent = PickerFrameInner })
        local HexInputInner = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = HexInputOuter })
        Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) }); Rotation = 90; Parent = HexInputInner })
        local HexInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,0); Size=UDim2.new(1,-(4),1,0); Font=Library.Font; PlaceholderText='Hex'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='#FFFFFF'; TextColor3=Library.FontColor; TextSize=(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=HexInputInner })
        Library:AddToRegistry(HexInputInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
        Library:AddToRegistry(HexInputBox,   { TextColor3 = 'FontColor' })

        local RgbInputOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.new(0.5, (2), 0, (228)); Size = UDim2.new(0.5, -(6), 0, (20)); ZIndex = 18; Parent = PickerFrameInner })
        local RgbInputInner = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 18; Parent = RgbInputOuter })
        Library:Create('UIGradient', { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) }); Rotation = 90; Parent = RgbInputInner })
        local RgbInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,0); Size=UDim2.new(1,-(4),1,0); Font=Library.Font; PlaceholderText='R,G,B'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='255,255,255'; TextColor3=Library.FontColor; TextSize=(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=RgbInputInner })
        Library:AddToRegistry(RgbInputInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
        Library:AddToRegistry(RgbInputBox,   { TextColor3 = 'FontColor' })

        local TransparencyInner, TransparencyCursor
        if Info.Transparency then
            local TransparencyOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Position = UDim2.fromOffset((4), (251)); Size = UDim2.new(1, -(8), 0, (14)); ZIndex = 19; Parent = PickerFrameInner })
            TransparencyInner = Library:Create('Frame', { BackgroundColor3 = ColorPickerInfo.Value; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 19; Parent = TransparencyOuter })
            Library:AddToRegistry(TransparencyInner, { BorderColor3 = 'OutlineColor' })
            Library:Create('ImageLabel', { BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Image='rbxassetid://12978095818'; ZIndex=20; Parent=TransparencyInner })
            TransparencyCursor = Library:Create('Frame', { BackgroundColor3 = Color3.new(1,1,1); BorderColor3 = Color3.new(0,0,0); AnchorPoint = Vector2.new(0.5,0); Size = UDim2.new(0,1,1,0); ZIndex = 21; Parent = TransparencyInner })
        end

        function ColorPickerInfo:Display()
            ColorPickerInfo.Value = Color3.fromHSV(ColorPickerInfo.Hue, ColorPickerInfo.Sat, ColorPickerInfo.Vib)
            SatValMap.BackgroundColor3 = Color3.fromHSV(ColorPickerInfo.Hue, 1, 1)
            Swatch.BackgroundColor3 = ColorPickerInfo.Value
            Swatch.BackgroundTransparency = ColorPickerInfo.Transparency
            Swatch.BorderColor3 = Library:GetDarkerColor(ColorPickerInfo.Value)
            if TransparencyInner then
                TransparencyInner.BackgroundColor3 = ColorPickerInfo.Value
                TransparencyCursor.Position = UDim2.new(1 - ColorPickerInfo.Transparency, 0, 0, 0)
            end
            CursorOuter.Position = UDim2.new(ColorPickerInfo.Sat, 0, 1 - ColorPickerInfo.Vib, 0)
            HueCursor.Position = UDim2.new(0, 0, ColorPickerInfo.Hue, 0)
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
            if Library:IsPointerOverSwatchOrFrame(Input.Position.X, Input.Position.Y, Swatch, PickerFrameOuter, DispH) then return end
            local px, py = Input.Position.X, Input.Position.Y
            task.defer(function()
                if ColorPickerInfo.suppressClose then
                    ColorPickerInfo.suppressClose = false
                    return
                end
                if Library:IsPositionOverFrame(px, py, PickerFrameOuter) then return end
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
            if not PickerFrameOuter.Visible and Library:MouseIsOverOpenedFrame() then return end
            if PickerFrameOuter.Visible then ColorPickerInfo:Hide() else ColorPickerInfo:Show() end
        end)

        Library:GiveSignal(Services.UserInputService.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            local px, py = Input.Position.X, Input.Position.Y
            task.defer(function()
                if ColorPickerInfo.suppressClose then
                    ColorPickerInfo.suppressClose = false
                    return
                end
                local ap, as = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize
                if px < ap.X or px > ap.X+as.X or py < ap.Y-DispH-2 or py > ap.Y+as.Y then
                    ColorPickerInfo:Hide()
                end
            end)
        end))

        ColorPickerInfo:Display()
        ColorPickerInfo.DisplayFrame = Swatch
        if self.Addons then table.insert(self.Addons, ColorPickerInfo) end
        PickerFrameOuter.Active = true
        PickerFrameInner.Active = true
        for _, d in ipairs(PickerFrameOuter:GetDescendants()) do
            if d:IsA('GuiObject') then d.ZIndex = d.ZIndex + 400 end
        end
        PickerFrameOuter.ZIndex = PickerFrameOuter.ZIndex + 400
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

        local swW, swH = (60), (14)
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

        local pickerW = (230)
        local mapSz   = (200)

        local prevY   = (22)
        local tabsY   = (44)
        local mapY    = (70)
        local inputsY = mapY + mapSz + (6)
        local transY  = inputsY + (23)
        local pickerH = (Info.Transparency ~= nil) and (transY + (18)) or (inputsY + (24))

        local Blocker = Library:Create('Frame', { Name='GradColorBlocker'; Active=true; BackgroundTransparency=1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(1,1); Visible=false; ZIndex=350; Parent=ScreenGui })

        local PickerFrameOuter = Library:Create('Frame', { Name='GradColor'; Active=true; BackgroundColor3=Color3.new(1,1,1); BorderColor3=Color3.new(0,0,0); Size=UDim2.fromOffset(pickerW, pickerH); Visible=false; ZIndex=15; Parent=ScreenGui })
        local PickerFrameScale = Library:Create('UIScale', { Scale = Library.UIScaleValue or 1.0; Parent = PickerFrameOuter })
        table.insert(Library.ThemeScales, PickerFrameScale)
        local PickerFrameInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=16; Parent=PickerFrameOuter })
        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })

        local function UpdatePickerPos()
            local sap = Swatch.AbsolutePosition
            PickerFrameOuter.Position = UDim2.fromOffset(sap.X, sap.Y + Swatch.AbsoluteSize.Y + 1)
        end

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

        local TitleLabel = Library:CreateLabel({ Size=UDim2.new(1,0,0,(14)); Position=UDim2.fromOffset((5),(4)); TextSize=(13); Text=GradColorPickerInfo.Title..' (start)'; TextXAlignment=Enum.TextXAlignment.Left; TextWrapped=false; ZIndex=17; Parent=PickerFrameInner })

        local PreviewOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset((4),prevY); Size=UDim2.new(1,-(8),0,(18)); ZIndex=17; Parent=PickerFrameInner })
        local PreviewInner = Library:Create('Frame', { BackgroundColor3=Library.OutlineColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; BorderSizePixel=1; Size=UDim2.new(1,0,1,0); ZIndex=17; Parent=PreviewOuter })
        Library:AddToRegistry(PreviewInner, { BackgroundColor3='OutlineColor'; BorderColor3='OutlineColor' })
        Library:Create('ImageLabel', { BackgroundTransparency=1; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://12977615774'; Parent=PreviewInner })
        local PreviewFill = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=PreviewInner })
        local PreviewGrad = Library:Create('UIGradient', { Parent=PreviewFill })

        local STOP_TAB_NAMES = { 'Start', 'Middle', 'End' }
        local tabGap   = (3)
        local tabW     = math.floor((pickerW - (8) - tabGap * 2) / 3)
        local stopFrames = {}
        for i = 1, 3 do
            local tabX = (4) + (i - 1) * (tabW + tabGap)
            local tabOuter = Library:Create('Frame', { Active=true; BackgroundColor3=Library.MainColor; BorderColor3=(i==1) and Library.AccentColor or Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; BorderSizePixel=1; Position=UDim2.fromOffset(tabX,tabsY); Size=UDim2.fromOffset(tabW,(20)); ZIndex=17; Parent=PickerFrameInner })
            Library:AddToRegistry(tabOuter, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
            local chipOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Position=UDim2.fromOffset((3),(3)); Size=UDim2.fromOffset((12),(12)); ZIndex=18; Parent=tabOuter })
            Library:Create('ImageLabel', { BackgroundTransparency=1; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://12977615774'; Parent=chipOuter })
            local chip = Library:Create('Frame', { Active=true; BackgroundColor3=GradColorPickerInfo.Values[i]; BackgroundTransparency=GradColorPickerInfo.Transparencies[i]; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=chipOuter })
            local nameLbl = Library:CreateLabel({ PreserveCase=true; BackgroundTransparency=1; Position=UDim2.fromOffset((19),0); Size=UDim2.new(1,-(21),1,0); TextSize=(11); Text=STOP_TAB_NAMES[i]; TextXAlignment=Enum.TextXAlignment.Left; ZIndex=18; Parent=tabOuter })
            stopFrames[i] = { frame = chip, outer = tabOuter, label = nameLbl }
            local idx = i
            tabOuter.MouseEnter:Connect(function() tabOuter.BorderColor3 = Library.AccentColor end)
            tabOuter.MouseLeave:Connect(function() tabOuter.BorderColor3 = (GradColorPickerInfo.ActiveStop == idx) and Library.AccentColor or Library.OutlineColor end)
        end

        local SatValOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset((4),mapY); Size=UDim2.fromOffset(mapSz,mapSz); ZIndex=17; Parent=PickerFrameInner })
        local SatValInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=SatValOuter })
        local SatValMap   = Library:Create('ImageLabel', { BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Image='rbxassetid://4155801252'; Parent=SatValInner })
        Library:AddToRegistry(SatValInner, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })

        local CursorOuter = Library:Create('ImageLabel', { AnchorPoint=Vector2.new(0.5,0.5); Size=UDim2.fromOffset((6),(6)); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ImageColor3=Color3.new(0,0,0); ZIndex=19; Parent=SatValMap })
        Library:Create('ImageLabel', { Size=UDim2.fromOffset((4),(4)); Position=UDim2.fromOffset(1,1); BackgroundTransparency=1; Image='rbxassetid://9619665977'; ZIndex=20; Parent=CursorOuter })

        local HueOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.fromOffset((208),mapY); Size=UDim2.fromOffset((15),mapSz); ZIndex=17; Parent=PickerFrameInner })
        local HueInner = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=HueOuter })
        local hueSKP  = {}
        for i = 0, 1, 0.1 do table.insert(hueSKP, ColorSequenceKeypoint.new(math.min(i,1), Color3.fromHSV(i,1,1))) end
        Library:Create('UIGradient', { Color=ColorSequence.new(hueSKP); Rotation=90; Parent=HueInner })
        local HueCursor = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderColor3=Color3.new(0,0,0); AnchorPoint=Vector2.new(0,0.5); Size=UDim2.new(1,0,0,1); ZIndex=19; Parent=HueInner })

        local HexInputOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0,(4),0,inputsY); Size=UDim2.new(0.5,-(6),0,(20)); ZIndex=18; Parent=PickerFrameInner })
        local HexInputInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=HexInputOuter })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=HexInputInner })
        local HexInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,0); Size=UDim2.new(1,-(4),1,0); Font=Library.Font; PlaceholderText='Hex'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='#FFFFFF'; TextColor3=Library.FontColor; TextSize=(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=HexInputInner })
        Library:AddToRegistry(HexInputInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:AddToRegistry(HexInputBox,   { TextColor3='FontColor' })

        local RgbInputOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0.5,(2),0,inputsY); Size=UDim2.new(0.5,-(6),0,(20)); ZIndex=18; Parent=PickerFrameInner })
        local RgbInputInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=18; Parent=RgbInputOuter })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=RgbInputInner })
        local RgbInputBox = Library:Create('TextBox', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,0); Size=UDim2.new(1,-(4),1,0); Font=Library.Font; PlaceholderText='R,G,B'; PlaceholderColor3=Color3.fromRGB(190,190,190); Text='255,255,255'; TextColor3=Library.FontColor; TextSize=(13); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=20; Parent=RgbInputInner })
        Library:AddToRegistry(RgbInputInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:AddToRegistry(RgbInputBox,   { TextColor3='FontColor' })

        local TransparencyInner, TransparencyCursor
        if Info.Transparency ~= nil then
            local TransparencyOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Position=UDim2.new(0,(4),0,transY); Size=UDim2.new(1,-(8),0,(14)); ZIndex=19; Parent=PickerFrameInner })
            TransparencyInner = Library:Create('Frame', { BackgroundColor3=GradColorPickerInfo.Values[1]; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=19; Parent=TransparencyOuter })
            Library:AddToRegistry(TransparencyInner, { BorderColor3='OutlineColor' })
            Library:Create('ImageLabel', { BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Image='rbxassetid://12978095818'; ZIndex=20; Parent=TransparencyInner })
            TransparencyCursor = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BorderColor3=Color3.new(0,0,0); AnchorPoint=Vector2.new(0.5,0); Size=UDim2.new(0,1,1,0); ZIndex=21; Parent=TransparencyInner })
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
            HueCursor.Position = UDim2.new(0, 0, GradColorPickerInfo.Hue, 0)
            HexInputBox.Text = '#'..col:ToHex()
            RgbInputBox.Text = math.floor(col.R*255)..','..math.floor(col.G*255)..','..math.floor(col.B*255)
            if TransparencyInner then
                TransparencyInner.BackgroundColor3 = col
                TransparencyCursor.Position = UDim2.new(1 - GradColorPickerInfo.Transparencies[GradColorPickerInfo.ActiveStop], 0, 0, 0)
            end
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
            if Library:IsPointerOverSwatchOrFrame(Input.Position.X, Input.Position.Y, Swatch, PickerFrameOuter, swH) then return end
            local px, py = Input.Position.X, Input.Position.Y
            task.defer(function()
                if GradColorPickerInfo.suppressClose then
                    GradColorPickerInfo.suppressClose = false
                    return
                end
                if Library:IsPositionOverFrame(px, py, PickerFrameOuter) then return end
                GradColorPickerInfo:Hide()
            end)
        end)

        Swatch.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then return end
            if not PickerFrameOuter.Visible and Library:MouseIsOverOpenedFrame() then return end
            if PickerFrameOuter.Visible then GradColorPickerInfo:Hide() else GradColorPickerInfo:Show() end
        end)

        PickerFrameOuter.Active = true
        PickerFrameInner.Active = true
        for _, d in ipairs(PickerFrameOuter:GetDescendants()) do
            if d:IsA('GuiObject') then d.ZIndex = d.ZIndex + 400 end
        end
        PickerFrameOuter.ZIndex = PickerFrameOuter.ZIndex + 400

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

        local KeyPickOuter = Library:Create('Frame', { BorderColor3 = Color3.new(0,0,0); Size = UDim2.fromOffset((44), (15)); ZIndex = 15; Active = true; Visible = not IsTouch; Parent = TextLabelRef })
        local KeyPickInner  = Library:Create('Frame', { BackgroundColor3 = Library.BackgroundColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 16; Parent = KeyPickOuter })
        Library:AddToRegistry(KeyPickInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' })
        local DisplayLabel = Library:CreateLabel({ Size = UDim2.new(1,0,1,0); TextSize = (12); Text = fmtKey(Info.Default); TextScaled = true; ZIndex = 17; Parent = KeyPickInner })

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' }
        local ModeOuter = Library:Create('Frame', {
            Active        = true;
            BorderColor3  = Color3.new(0,0,0);
            Size          = UDim2.fromOffset((60), #Modes * (15) + (4));
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
            ModeOuter.Position = UDim2.fromOffset((TextLabelRef.AbsolutePosition.X + TextLabelRef.AbsoluteSize.X + (4)) / scale, (TextLabelRef.AbsolutePosition.Y + 1) / scale)
        end
        TextLabelRef:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdateModePos)
        UpdateModePos()

        local HudBindLabel = Library:CreateLabel({ TextXAlignment = Enum.TextXAlignment.Left; Size = UDim2.new(1,0,0,(18)); TextSize = (12); Visible = false; ZIndex = 110; Parent = Library.KeybindContainer }, true)
        if not IsTouch then
            table.insert(Library.KeybindRegistry, KeybindInfo)
        end

        local ModeButtonList = {}
        for _, mode in ipairs(Modes) do
            local btn = {}
            local lbl = Library:CreateLabel({ Active = false; Size = UDim2.new(1,0,0,(15)); TextSize = (12); Text = mode; ZIndex = 16; Parent = ModeInner })
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
                if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then btn:Select(); Library:AttemptSave() end
            end)
            if mode == KeybindInfo.Mode then btn:Select() end
            ModeButtonList[mode] = btn
        end

        local function ParentEnabled()
            if ParentObj.Type ~= 'Toggle' then return true end
            return ParentObj.Value and true or false
        end

        function KeybindInfo:Update()
            if Info.NoUI then return end
            local state   = KeybindInfo:GetState()
            local enabled = ParentEnabled()
            local mode    = Library.KeybindListMode or 'Enabled'
            local showInList
            if mode == 'All' then
                showInList = true
            elseif mode == 'Toggled' then
                showInList = enabled and state
            else
                showInList = enabled
            end

            HudBindLabel.Text    = string.format('[%s] %s', fmtKey(KeybindInfo.Value), Library:ApplyCase(Info.Text or '', "Keybinds"))
            HudBindLabel.Visible = showInList
            HudBindLabel.TextColor3 = state and Library.AccentColor or Library.FontColor
            Library.RegistryMap[HudBindLabel].Properties.TextColor3 = state and 'AccentColor' or 'FontColor'

            local ys, xs = 0, 0
            for _, ch in ipairs(Library.KeybindContainer:GetChildren()) do
                if ch:IsA('TextLabel') and ch.Visible then
                    ys = ys + (18)
                    xs = math.max(xs, ch.TextBounds.X)
                end
            end
            Library.KeybindFrame.Size = UDim2.fromOffset(math.max(xs + (16), (210)), ys + (26))
        end

        function KeybindInfo:GetState()
            if KeybindInfo.Mode == 'Always' then
                return ParentEnabled()
            end
            if KeybindInfo.Mode == 'Hold' then
                if KeybindInfo.Value == 'None' then return false end
                local down
                if KeybindInfo.Value == 'MB1' then down = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                elseif KeybindInfo.Value == 'MB2' then down = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                else down = KeybindInfo.Value ~= nil and Enum.KeyCode[KeybindInfo.Value] and Services.UserInputService:IsKeyDown(Enum.KeyCode[KeybindInfo.Value]) or false end
                return ParentEnabled() and down
            end
            return ParentEnabled() and KeybindInfo.Toggled
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
                if px < ap.X or px > ap.X+as.X or py < ap.Y-(20)-1 or py > ap.Y+as.Y then
                    ModeOuter.Visible = false
                end
            end
        end))
        Library:GiveSignal(Services.UserInputService.InputEnded:Connect(function() if not Picking then KeybindInfo:Update() end end))
        KeybindInfo:Update()
        Options[Idx] = KeybindInfo
        return self
    end

    BaseAddons.__index = Funcs
end

do
    local Funcs = {}

    function Funcs:AddBlank(sz)
        return Library:Create('Frame', { BackgroundTransparency=1; Size=UDim2.new(1,0,0,(sz)); ZIndex=1; Parent=self.Container })
    end

    function Funcs:AddLabel(Text, DoesWrap)
        Library:BuildTick()
        local Label = {}
        local Groupbox    = self
        local TextLabelRef    = Library:CreateLabel({
            Size            = UDim2.new(1, -(4), 0, (15));
            TextSize        = (14);
            Text            = Library:ApplyCase(Text or "", "Labels");
            TextWrapped     = DoesWrap or false;
            RichText        = true;
            TextXAlignment  = Enum.TextXAlignment.Left;
            ZIndex          = 5;
            Parent          = Groupbox.Container;
        })
        if DoesWrap then
            local _, y = Library:GetTextBounds(Text, Library.Font, (14), Vector2.new(TextLabelRef.AbsoluteSize.X, math.huge))
            TextLabelRef.Size = UDim2.new(1, -(4), 0, y)
        else
            Library:Create('UIListLayout', { Padding=UDim.new(0,(4)); FillDirection=Enum.FillDirection.Horizontal; HorizontalAlignment=Enum.HorizontalAlignment.Right; SortOrder=Enum.SortOrder.LayoutOrder; Parent=TextLabelRef })
        end
        Library:TrackLabel(TextLabelRef, Text or "", "Labels")
        Label.TextLabel = TextLabelRef
        Label.Container = Groupbox.Container
        function Label:SetText(t)
            local raw = tostring(t or "")
            for _, e in ipairs(Library.TextRegistry) do
                if e.lbl == TextLabelRef then e.text = raw; break end
            end
            Library:SetTRText(TextLabelRef, Library:ApplyCase(raw, "Labels"))
            if DoesWrap then
                local _, y = Library:GetTextBounds(TextLabelRef.Text, Library.Font, (14), Vector2.new(TextLabelRef.AbsoluteSize.X, math.huge))
                TextLabelRef.Size = UDim2.new(1, -(4), 0, y)
            end
            Groupbox:Resize()
        end
        if not DoesWrap then setmetatable(Label, BaseAddons) end
        Groupbox:AddBlank(5); Groupbox:Resize()
        return Label
    end

    function Funcs:AddNote(Text)
        Library:BuildTick()
        local Groupbox = self
        local Note = {}

        local Inner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderSizePixel=0; Size=UDim2.new(1,-4,0,0); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(Inner, { BackgroundColor3='MainColor' })
        local Stroke = Library:Create('UIStroke', { Color=Library.OutlineColor; Thickness=1; Parent=Inner })
        Library:AddToRegistry(Stroke, { Color='OutlineColor' })

        local TextLabelRef = Library:CreateLabel({
            Position        = UDim2.new(0,6,0,6);
            Size            = UDim2.new(1,-12,0,14);
            TextSize        = (13);
            Text            = Library:ApplyCase(Text or "", "Labels");
            TextWrapped     = true;
            RichText        = true;
            TextXAlignment  = Enum.TextXAlignment.Left;
            TextYAlignment  = Enum.TextYAlignment.Top;
            ZIndex          = 7;
            Parent          = Inner;
        })
        Library:TrackLabel(TextLabelRef, Text or "", "Labels")

        local function Reflow()
            local _, TextHeight = Library:GetTextBounds(TextLabelRef.Text, Library.Font, (13), Vector2.new(TextLabelRef.AbsoluteSize.X, math.huge))
            TextLabelRef.Size = UDim2.new(1,-12,0,TextHeight)
            Inner.Size = UDim2.new(1,-4,0, 12 + TextHeight)
            Groupbox:Resize()
        end
        Reflow()

        Note.TextLabel = TextLabelRef
        Note.Container = Groupbox.Container
        function Note:SetText(t)
            local raw = tostring(t or "")
            for _, e in ipairs(Library.TextRegistry) do
                if e.lbl == TextLabelRef then e.text = raw; break end
            end
            Library:SetTRText(TextLabelRef, Library:ApplyCase(raw, "Labels"))
            Reflow()
        end

        Groupbox:AddBlank(5); Groupbox:Resize()
        return Note
    end

    function Funcs:AddDynamicList(Info)
        local Groupbox       = self
        local ROW_H    = (20)
        local entries  = {}
        local onChange  = Info and Info.OnChanged or function() end
        local textOnly  = Info and Info.TextOnly or false

        local Wrap = Library:Create('Frame', {
            BackgroundTransparency  = 1;
            Size                    = UDim2.new(1, -(4), 0, 0);
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
            Wrap.Size = UDim2.new(1, -(4), 0, h)
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
                local Clip = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,(3),0,0); Size=UDim2.new(1,-(3),1,0); ZIndex=7; Parent=Inner })
                local Box = Library:Create('TextBox', {
                    BackgroundTransparency  = 1; Size=UDim2.new(1,0,1,0);
                    Font                    = Library.Font; Text=defText or ""; TextColor3=Library.FontColor;
                    TextSize                = (13); TextStrokeTransparency=0; TextXAlignment=Enum.TextXAlignment.Left;
                    PlaceholderColor3       = Color3.fromRGB(150,150,150); ZIndex=7; Parent=Clip;
                })
                Library:AddToRegistry(Box, { TextColor3='FontColor', Font='Font' })
                return Box
            end

            local TxtBox = makeBox(txtW, entry.textVal)
            local PercentBox = not textOnly and makeBox(pctW, entry.chanceVal) or nil

            local ButtonOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(0,btnW,1,0); ZIndex=5; Parent=Row })
            local ButtonInner  = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=ButtonOuter })
            Library:AddToRegistry(ButtonInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
            Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=ButtonInner })
            Library:CreateLabel({ Size=UDim2.new(1,0,1,0); Text="-"; TextSize=(14); ZIndex=7; Parent=ButtonInner })
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
        Library:CreateLabel({ Size=UDim2.new(1,0,1,0); Text="+ add fact"; TextSize=(13); ZIndex=7; Parent=AddButtonInner })
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

    function Funcs:AddDivider()
        self:AddBlank(2)
        local DividerOuter = Library:Create('Frame', { BackgroundColor3 = Color3.new(0,0,0); BorderColor3 = Color3.new(0,0,0); Size = UDim2.new(1,-4,0,5); ZIndex = 5; Parent = self.Container })
        local DividerInner = Library:Create('Frame', { BackgroundColor3 = Library.MainColor; BorderColor3 = Library.OutlineColor; BorderMode = Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex = 6; Parent = DividerOuter })
        Library:AddToRegistry(DividerOuter, { BorderColor3 = 'Black' })
        Library:AddToRegistry(DividerInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })
        self:AddBlank(9)
    end

    function Funcs:AddCustom(InstanceOrInfo)
        Library:BuildTick()
        local Groupbox = self
        local Info = typeof(InstanceOrInfo) == 'table' and InstanceOrInfo or { Instance = InstanceOrInfo }
        local CustomInstance = Info.Instance
        assert(typeof(CustomInstance) == 'Instance' and CustomInstance:IsA('GuiObject'), 'AddCustom: `Instance` must be a GuiObject.')
        CustomInstance.Parent = Groupbox.Container
        if Info.FillWidth ~= false then
            CustomInstance.Size = UDim2.new(1, -(4), CustomInstance.Size.Y.Scale, CustomInstance.Size.Y.Offset)
        end
        Library:GiveSignal(CustomInstance:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() Groupbox:Resize() end))
        Groupbox:Resize()
        return CustomInstance
    end

    function Funcs:AddButton(...)
        Library:BuildTick()
        local Button = {}
        local args = { ... }
        local info = type(args[1]) == 'table' and args[1] or { Text=args[1]; Func=args[2] }
        Button.Text = info.Text; Button.Func = info.Func; Button.DoubleClick = info.DoubleClick; Button.Tooltip = info.Tooltip
        assert(type(Button.Func) == 'function', 'AddButton: `Func` callback is missing.')

        local Groupbox = self

        local function MakeBtn(b)
            local o = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size = UDim2.new(1,-(4),0,(20)); ZIndex=5 })
            local i = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size = UDim2.new(1,0,1,0); ZIndex=6; Parent=o })
            local l = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(14); Text=Library:ApplyCase(b.Text or "", "Buttons"); ZIndex=6; Parent=i })
            Library:TrackLabel(l, b.Text or "", "Buttons")
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
            self.Outer.Size = UDim2.new(0.5, -(3), 0, (20))
            Sub.Outer, Sub.Inner, Sub.Label = MakeBtn(Sub)
            Sub.Outer.Position = UDim2.new(1, (3), 0, 0)
            Sub.Outer.Size = UDim2.new(1, -(2), 1, 0)
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
        local _inputLbl = Library:CreateLabel({ Size=UDim2.new(1,0,0,(15)); TextSize=(14); Text=Library:ApplyCase(Info.Text or "", "Inputs"); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=5; Parent=Groupbox.Container })
        Library:TrackLabel(_inputLbl, Info.Text or "", "Inputs")
        Groupbox:AddBlank(1)
        local BoxHeight = (20)
        local Outer = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-(4),0,BoxHeight); ZIndex=5; Parent=Groupbox.Container })
        local Inner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=Outer })
        Library:AddToRegistry(Inner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:OnHighlight(Outer, Outer, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=Inner })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, Outer) end
        local Clip = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,(5),0,0); Size=UDim2.new(1,-(5),1,0); ZIndex=7; Parent=Inner })
        local Box  = Library:Create('TextBox', {
            BackgroundTransparency  = 1; Position=UDim2.fromOffset(0,0); Size=UDim2.fromScale(5,1);
            Font                    = Library.Font; PlaceholderColor3=Color3.fromRGB(190,190,190); PlaceholderText=Info.Placeholder or '';
            Text                    = Info.Default or ''; TextColor3=Library.FontColor; TextSize=(14); TextStrokeTransparency=0;
            TextXAlignment          = Enum.TextXAlignment.Left; ZIndex=7; Parent=Clip;
        })
        Library:AddToRegistry(Box, { TextColor3='FontColor', Font='Font' })
        if type(Info.Placeholder) == 'string' and Info.Placeholder ~= '' then
            Box.PlaceholderText = Library:ApplyCase(Info.Placeholder, "Inputs")
            Library:TrackLabel(Box, Info.Placeholder, "Inputs", "PlaceholderText")
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
        Textbox.TitleLabel = _inputLbl
        Textbox.DestroyParts = { _inputLbl, Outer }
        Options[Idx] = Textbox
        return Textbox
    end

    function Funcs:AddToggle(Idx, Info)
        Library:BuildTick()
        assert(Info.Text, 'AddToggle: Missing `Text`.')
        local Toggle = { Value=Info.Default or false; Type='Toggle'; Callback=Info.Callback or function() end; Addons={}; Risky=Info.Risky }
        local Groupbox = self
        local boxSz = (13)
        local TOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.fromOffset(boxSz,boxSz); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(TOuter, { BorderColor3='Black' })
        local TInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=TOuter })
        Library:AddToRegistry(TInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        local TLabel = Library:CreateLabel({ Size=UDim2.new(0,(245),1,0); Position=UDim2.new(1,(6),0,0); TextSize=(14); Text=Library:ApplyCase(Info.Text or "", "Toggles"); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=6; Parent=TInner })
        Library:TrackLabel(TLabel, Info.Text or "", "Toggles")
        Library:Create('UIListLayout', { Padding=UDim.new(0,(4)); FillDirection=Enum.FillDirection.Horizontal; HorizontalAlignment=Enum.HorizontalAlignment.Right; SortOrder=Enum.SortOrder.LayoutOrder; Parent=TLabel })
        local function syncTLW()
            local cw = Groupbox.Container.AbsoluteSize.X
            if cw > 0 then TLabel.Size = UDim2.new(0, math.max(0, cw - (4) - boxSz - (6)), 1, 0) end
        end
        Groupbox.Container:GetPropertyChangedSignal('AbsoluteSize'):Connect(syncTLW)
        task.defer(syncTLW)
        local HitW = (155)
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
        local ToggleBlank = Groupbox:AddBlank(Info.BlankSize or 7); Groupbox:Resize()
        Toggle.TextLabel = TLabel; Toggle.Container = Groupbox.Container
        Toggle.DestroyParts = { TOuter, TLabel, HitRegion, ToggleBlank }
        setmetatable(Toggle, BaseAddons)
        Toggles[Idx] = Toggle
        Library:UpdateDependencyBoxes()
        return Toggle
    end

    local function BuildSliderPiece(Parent, OuterSize, Info)
        local Slider = { Value=Info.Default; Min=Info.Min; Max=Info.Max; Rounding=Info.Rounding; MaxSize=(232); Type='Slider'; Callback=Info.Callback or function() end; Info=Info }
        local SOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=OuterSize; ZIndex=5; Parent=Parent })
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
        local DropdownLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(13); Text=''; ZIndex=9; Parent=SInner })
        Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 4); PaddingRight = UDim.new(0, 4); Parent = DropdownLabel })

        local ValueInputBox = Library:Create('TextBox', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; Visible=false; Font=Library.Font; Text=''; TextColor3=Library.FontColor; TextSize=(13); TextXAlignment=Enum.TextXAlignment.Left; ClearTextOnFocus=false; Size=UDim2.new(1,-16,1,0); ZIndex=10; Parent=SInner })
        Library:Create('UIPadding', { PaddingLeft = UDim.new(0, 4); PaddingRight = UDim.new(0, 4); Parent = ValueInputBox })
        Library:AddToRegistry(ValueInputBox, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor'; TextColor3='FontColor'; Font='Font' })

        local ValueConfirmBtn = Library:Create('TextButton', { BackgroundColor3=Library.AccentColor; BorderColor3=Library.OutlineColor; Visible=false; Font=Library.Font; Text='✓'; TextColor3=Color3.new(1,1,1); TextSize=(13); Position=UDim2.new(1,-16,0,0); Size=UDim2.new(0,16,1,0); Active=true; ZIndex=11; Parent=SInner })
        Library:AddToRegistry(ValueConfirmBtn, { BackgroundColor3='AccentColor'; BorderColor3='OutlineColor'; Font='Font' })

        Library:OnHighlight(SOuter, SInner, { BorderColor3='AccentColor' }, { BorderColor3='OutlineColor' })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, SOuter) end

        local function Round(v)
            if Slider.Rounding == 0 then
                local step = math.max(1, math.floor((Slider.Max - Slider.Min) / 200))
                return math.floor(v / step + 0.5) * step
            end
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
                CurX = CurX + (TargetX - CurX) * math.clamp(dt * 8, 0, 1)
                if math.abs(TargetX - CurX) <= 0.5 then CurX = TargetX; ApplyFill(CurX); StopLerp(); return end
                ApplyFill(CurX)
            end)
        end
        function Slider:Display()
            local suf = Slider.Info.Suffix or ''
            DropdownLabel.Text = Library:ApplyCase(Slider.Info.Text or "", "Sliders", Slider.Info.CaseOverride)..': '..Slider.Value..suf
            TargetX = math.floor(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize) + 0.5)
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

        local function CloseValueInput()
            ValueInputBox.Visible = false
            ValueConfirmBtn.Visible = false
            DropdownLabel.Visible = true
        end
        local function OpenValueInput()
            ValueInputBox.Text = tostring(Slider.Value)
            ValueInputBox.Visible = true
            ValueConfirmBtn.Visible = true
            DropdownLabel.Visible = false
            ValueInputBox:CaptureFocus()
        end
        local function CommitValueInput()
            local n = tonumber(ValueInputBox.Text)
            if n then Slider:SetValue(n) end
            CloseValueInput()
        end
        ValueInputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then CommitValueInput() else CloseValueInput() end
        end)
        ValueConfirmBtn.MouseButton1Click:Connect(CommitValueInput)
        local HoldToken = nil
        SInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                OpenValueInput()
            elseif Input.UserInputType == Enum.UserInputType.Touch then
                local Token = {}
                HoldToken = Token
                task.delay(0.45, function()
                    if HoldToken == Token then OpenValueInput() end
                end)
            end
        end)
        SInner.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then HoldToken = nil end
        end)

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
        Slider.Outer = SOuter
        table.insert(Library.SliderRegistry, Slider)
        return Slider
    end

    function Funcs:AddSlider(Idx, Info)
        Library:BuildTick()
        assert(Info.Default ~= nil, 'AddSlider: Missing default.')
        assert(Info.Text,           'AddSlider: Missing text.')
        assert(Info.Min ~= nil,     'AddSlider: Missing min.')
        assert(Info.Max ~= nil,     'AddSlider: Missing max.')
        assert(Info.Rounding ~= nil,'AddSlider: Missing rounding.')
        local Groupbox = self
        local Slider = BuildSliderPiece(Groupbox.Container, UDim2.new(1,-(4),0,(13)), Info)
        local First = Slider
        local Count = 1

        local function Chain(PrevSlider)
            function PrevSlider:AddSlider(Idx2, Info2)
                assert(Info2.Default ~= nil, 'AddSlider: Missing default.')
                assert(Info2.Text,           'AddSlider: Missing text.')
                assert(Info2.Min ~= nil,     'AddSlider: Missing min.')
                assert(Info2.Max ~= nil,     'AddSlider: Missing max.')
                assert(Info2.Rounding ~= nil,'AddSlider: Missing rounding.')
                Count = Count + 1
                First.Outer.Size = UDim2.new(1/Count, -(3), 0, (13))
                local Sub = BuildSliderPiece(PrevSlider.Outer, UDim2.new(1,-(2),1,0), Info2)
                Sub.Outer.Position = UDim2.new(1, (3), 0, 0)
                Chain(Sub)
                Options[Idx2] = Sub
                return Sub
            end
        end
        Chain(Slider)

        local SliderBlank = Groupbox:AddBlank(Info.BlankSize or 6); Groupbox:Resize()
        Slider.DestroyParts = { SliderBlank }
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
        local DropdownBlanks = {}

        if not Info.Compact then
            local _ddLbl = Library:CreateLabel({ PreserveCase = true; Size=UDim2.new(1,0,0,(10)); TextSize=(14); Text=Library:ApplyCase(Info.Text or "", "Dropdowns"); TextXAlignment=Enum.TextXAlignment.Left; TextYAlignment=Enum.TextYAlignment.Bottom; ZIndex=5; Parent=Groupbox.Container })
            Library:TrackLabel(_ddLbl, Info.Text or "", "Dropdowns")
            DropdownData.TitleLabel = _ddLbl
            table.insert(DropdownBlanks, Groupbox:AddBlank(3))
        end
        for _, el in ipairs(Groupbox.Container:GetChildren()) do
            if not el:IsA('UIListLayout') then RelOff = RelOff + el.Size.Y.Offset end
        end

        local ddH = (20)
        local DropdownOuter = Library:Create('Frame', { BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-(4),0,ddH); ZIndex=5; Parent=Groupbox.Container })
        Library:AddToRegistry(DropdownOuter, { BorderColor3='Black' })
        DropdownData.Outer = DropdownOuter
        local DropdownInner = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=DropdownOuter })
        Library:AddToRegistry(DropdownInner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:Create('UIGradient', { Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))}); Rotation=90; Parent=DropdownInner })
        local Arrow = Library:CreateLabel({ PreserveCase=true; AnchorPoint=Vector2.new(0.5,0.5); BackgroundTransparency=1; Position=UDim2.new(1,-(11),0.5,0); Size=UDim2.fromOffset((14),(14)); Text='>'; TextSize=(14); Font=Enum.Font.GothamBold; ZIndex=8; Parent=DropdownInner })
        local ItemClip  = Library:Create('Frame', { BackgroundTransparency=1; ClipsDescendants=true; Position=UDim2.new(0,(4),0,0); Size=UDim2.new(1,-(22),1,0); ZIndex=8; Parent=DropdownInner })
        local ItemLabel = Library:CreateLabel({ PreserveCase=true; Size=UDim2.new(1,0,1,0); TextSize=(13); Text=''; TextXAlignment=Enum.TextXAlignment.Left; TextTruncate=Enum.TextTruncate.AtEnd; ZIndex=8; Parent=ItemClip })
        Library:OnHighlight(DropdownOuter, DropdownOuter, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })
        if type(Info.Tooltip)=='string' then Library:AddToolTip(Info.Tooltip, DropdownOuter) end

        local MAX = 8
        local itemH = (20)
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

        local function UpdateListPos()
            if not DropdownOuter.Parent then return end
            local scale = Library.UIScaleValue or 1.0
            local ap  = DropdownOuter.AbsolutePosition
            local asz = DropdownOuter.AbsoluteSize
            ListOuter.Size     = UDim2.fromOffset(asz.X / scale, ListOuter.Size.Y.Offset)
            ListOuter.Position = UDim2.fromOffset(ap.X, ap.Y + asz.Y + 1)
        end

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
                    if DropdownData.Value[v] then s = s..v..', ' end
                end
                s = s:sub(1,-3)
            else
                s = DropdownData.Value or ''
            end
            if #s > 30 then s = s:sub(1, 30) .. '...' end
            if s == '' then s = '...' end
            if s ~= '...' then s = Library:ApplyCase(s, "DropdownItems", DropdownData.CaseOverride) end
            if ItemLabel and ItemLabel.Parent then ItemLabel.Text = s end
        end

        function DropdownData:GetActiveValues()
            if Info.Multi then local t={} for v in next,DropdownData.Value do t[#t+1]=v end; return t
            else return DropdownData.Value and 1 or 0 end
        end

        local Buttons = {}
        local justClickedItem = false
        DropdownData.ItemLabels = {}
        function DropdownData:SetValues()
            for _, ch in ipairs(Scroll:GetChildren()) do if not ch:IsA('UIListLayout') then ch:Destroy() end end
            Buttons = {}
            DropdownData.ItemLabels = {}
            local count = 0
            for _, val in ipairs(DropdownData.Values) do
                count = count + 1
                local SliderBackFrame = Library:Create('Frame', { BackgroundColor3=Library.MainColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Middle; Size=UDim2.new(1,-1,0,itemH); ZIndex=23; Active=true; Parent=Scroll })
                Library:AddToRegistry(SliderBackFrame, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
                local SliderBarSelected = Library:Create('Frame', { BackgroundColor3=Color3.new(1,1,1); BackgroundTransparency=0.75; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); Visible=false; ZIndex=24; Parent=SliderBackFrame })
                local SliderBarLabel = Library:CreateLabel({ PreserveCase = true; Active=false; Size=UDim2.new(1,-(6),1,0); Position=UDim2.new(0,(6),0,0); TextSize=(13); Text=Library:ApplyCase(val, "DropdownItems", DropdownData.CaseOverride); TextXAlignment=Enum.TextXAlignment.Left; ZIndex=25; Parent=SliderBackFrame })
                table.insert(DropdownData.ItemLabels, { lbl = SliderBarLabel, val = val })
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
                        justClickedItem = true
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
                        Library:UpdateDependencyBoxes()
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

        local DropdownAnimInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        function DropdownData:OpenDropdown()
            UpdateListPos()
            Blocker.Visible = true
            ListOuter.Visible = true
            Library.OpenedFrames[ListOuter] = true
            Library.ActiveDropdownList = ListOuter
            Services.TweenService:Create(Arrow, DropdownAnimInfo, { Rotation = 90 }):Play()
            StartCorrecting()
        end
        function DropdownData:CloseDropdown()
            Blocker.Visible = false
            ListOuter.Visible = false
            Library.OpenedFrames[ListOuter] = nil
            if Library.ActiveDropdownList == ListOuter then Library.ActiveDropdownList = nil end
            Services.TweenService:Create(Arrow, DropdownAnimInfo, { Rotation = 0 }):Play()
        end
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
            Library:UpdateDependencyBoxes()
        end

        table.insert(Library.DropdownRegistry, DropdownData)

        local ignoreOpenUntil = 0

        DropdownOuter.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            if ListOuter.Visible then DropdownData:CloseDropdown(); return end
            if os.clock() < ignoreOpenUntil then return end
            local otherOpen = Library.ActiveDropdownList
            if otherOpen and otherOpen ~= ListOuter and Library:IsPositionOverFrame(Input.Position.X, Input.Position.Y, otherOpen) then return end
            for _, dd in next, Library.DropdownRegistry do
                if dd ~= DropdownData and dd.CloseDropdown then dd:CloseDropdown() end
            end
            DropdownData:OpenDropdown()
        end)

        Blocker.InputBegan:Connect(function(Input)
            if not Library:IsPointerInput(Input) then return end
            task.defer(function()
                if justClickedItem then justClickedItem = false; return end
                if Library:IsMouseOverFrame(ListOuter) then return end
                DropdownData:CloseDropdown()
                ignoreOpenUntil = os.clock() + 0.15
            end)
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
        table.insert(DropdownBlanks, Groupbox:AddBlank(Info.BlankSize or 5)); Groupbox:Resize()
        DropdownData.DestroyParts = { DropdownData.TitleLabel, DropdownOuter, Blocker, ListOuter, table.unpack(DropdownBlanks) }
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
                local option, want = dep[1], dep[2]
                if option.Type == 'Toggle' then
                    if option.Value ~= want then
                        Holder.Visible = false; Depbox:Resize(); return
                    end
                elseif option.Type == 'Dropdown' then
                    local match
                    if option.Multi then
                        match = option.Value[want] ~= nil
                    else
                        match = option.Value == want
                    end
                    if not match then
                        Holder.Visible = false; Depbox:Resize(); return
                    end
                end
            end
            Holder.Visible = true; Depbox:Resize()
        end
        function Depbox:SetupDependencies(deps)
            Depbox.Dependencies = deps; Depbox:Update()
        end
        Depbox.Container = Inner
        Depbox.Outer      = Holder
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
            Size                    = UDim2.new(1, 0, 0, (18));
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
                TextSize  = (12);
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

    function Funcs:AddCaseRow(Idx, Info)
        Library:BuildTick()
        local Groupbox = self
        local modes = { "Capitalized", "Lowercase", "Uppercase" }
        local Option = { Value = Info.Default or "Capitalized"; Type = 'CaseRow'; Callback = Info.Callback or function() end }

        local rowH = 16
        local Row = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size   = UDim2.new(1, -(4), 0, rowH);
            ZIndex = 5;
            Parent = Groupbox.Container;
        })

        Library:CreateLabel({
            Size           = UDim2.new(0.48, 0, 1, 0);
            TextSize       = 12;
            Text           = Info.Text or Idx;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex         = 6;
            Parent         = Row;
        })

        local Outer = Library:Create('Frame', {
            BorderColor3    = Color3.new(0,0,0);
            Position        = UDim2.new(0.48, 2, 0, 1);
            Size            = UDim2.new(0.52, -2, 1, -2);
            ZIndex          = 5;
            Parent          = Row;
        })
        Library:AddToRegistry(Outer, { BorderColor3='Black' })
        local Inner = Library:Create('TextButton', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3     = Library.OutlineColor;
            BorderMode       = Enum.BorderMode.Inset;
            AutoButtonColor  = false;
            Size             = UDim2.new(1, 0, 1, 0);
            Text             = '';
            ZIndex           = 6;
            Parent           = Outer;
        })
        Library:AddToRegistry(Inner, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })
        Library:Create('UIGradient', {
            Color    = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(212,212,212)) });
            Rotation = 90;
            Parent   = Inner;
        })

        local ValueLabel = Library:CreateLabel({
            PreserveCase    = true;
            AnchorPoint     = Vector2.new(0, 0.5);
            Position        = UDim2.new(0, 5, 0.5, 0);
            Size            = UDim2.new(1, -8, 1, 0);
            TextSize        = 12;
            Text            = Option.Value;
            TextXAlignment  = Enum.TextXAlignment.Left;
            TextTruncate    = Enum.TextTruncate.AtEnd;
            ZIndex          = 7;
            Parent          = Inner;
        })

        local function refresh()
            ValueLabel.Text = Option.Value
        end

        function Option:OnChanged(fn) Option.Changed = fn; fn(Option.Value) end
        function Option:SetValue(v)
            Option.Value = v
            refresh()
            Library:SafeCallback(Option.Callback, v)
            Library:SafeCallback(Option.Changed,  v)
        end

        Library:OnHighlight(Inner, Outer, { BorderColor3='OutlineColor' }, { BorderColor3='Black' })

        Inner.MouseButton1Click:Connect(function()
            if not Library:HasOpenedFrames() then
                local idx = 1
                for i, m in ipairs(modes) do if m == Option.Value then idx = i; break end end
                Option:SetValue(modes[(idx % #modes) + 1])
                Library:AttemptSave()
            end
        end)

        refresh()
        Groupbox:AddBlank(3)
        Groupbox:Resize()
        Options[Idx] = Option
        return Option
    end

    BaseGroupbox.__index = Funcs
end

function Library:CreateHeadlessGroupbox(Container)
    local Groupbox = { Container = Container }
    function Groupbox:Resize() end
    setmetatable(Groupbox, BaseGroupbox)
    return Groupbox
end

function Library:CreateWindow(...)
    local args   = { ... }
    local Config = type(args[1]) == 'table' and args[1] or { Title=args[1]; AutoShow=args[2] }
    if type(Config.Title) ~= 'string' then Config.Title = 'Window' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 8 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

    local WinW, WinH
    do
        WinW = 545; WinH = 650
        if typeof(Config.Size) == 'UDim2' then
            WinW = Config.Size.X.Offset; WinH = Config.Size.Y.Offset
        end
        if IsTouch then
            local Viewport = workspace.CurrentCamera.ViewportSize
            WinW = math.clamp(math.floor(Viewport.X - (20)), (280), WinW)
            WinH = math.clamp(math.floor(Viewport.Y - (20)), (240), WinH)
        end
        if Config.Center then
            Config.AnchorPoint = Vector2.zero
            Config.Position    = UDim2.new(0.5, -math.floor(WinW / 2), 0.5, -math.floor(WinH / 2))
        else
            Config.AnchorPoint = Config.AnchorPoint or Vector2.zero
            if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
        end
    end

    local Window = { Tabs = {} }
    Library.MainWindow = Window
    local defaultPosition = Config.Position

    local Backdrop
    if not IsTouch then
        local parent_gui
        if gethui then
            pcall(function() parent_gui = gethui() end)
        end
        if not parent_gui then
            pcall(function() parent_gui = game:GetService("CoreGui") end)
        end
        if not parent_gui then
            pcall(function() parent_gui = Services.Players.LocalPlayer:WaitForChild("PlayerGui") end)
        end

        for _, inst in ipairs(parent_gui:GetChildren()) do
            if inst:IsA("ScreenGui") and inst.Name == "ScreenGUI" and inst:FindFirstChild("Overlay") then
                inst:Destroy()
            end
        end

        local backdropGui = Instance.new("ScreenGui")
        backdropGui.Name             = "ScreenGUI"
        backdropGui.IgnoreGuiInset   = true
        backdropGui.ResetOnSpawn     = false
        backdropGui.DisplayOrder     = 2147483646
        backdropGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
        backdropGui.Parent          = parent_gui

        Backdrop = Instance.new("Frame")
        Backdrop.Name                   = "Overlay"
        Backdrop.Size                   = UDim2.fromScale(1, 1)
        Backdrop.Position               = UDim2.fromScale(0, 0)
        Backdrop.BackgroundColor3       = Color3.new(0, 0, 0)
        Backdrop.BackgroundTransparency = 0.9
        Backdrop.BorderSizePixel        = 0
        Backdrop.ZIndex                 = 2147483647
        Backdrop.Visible                = false
        Backdrop.Parent                 = backdropGui

        Library.Backdrop = Backdrop

        local EzLogoHolder = Instance.new("Frame")
        EzLogoHolder.Name                   = "Holder"
        EzLogoHolder.AnchorPoint            = Vector2.new(0.5, 0.5)
        EzLogoHolder.Position               = UDim2.fromScale(0.5, 0.5)
        EzLogoHolder.Size                   = UDim2.fromOffset(600, 600)
        EzLogoHolder.BackgroundTransparency = 1
        EzLogoHolder.BorderSizePixel        = 0
        EzLogoHolder.ZIndex                 = 2147483647
        EzLogoHolder.Visible                = false
        EzLogoHolder.Parent                 = backdropGui

        local EzLogoViewport = Instance.new("ViewportFrame")
        EzLogoViewport.Name                   = "Viewport"
        EzLogoViewport.Size                   = UDim2.fromScale(1, 1)
        EzLogoViewport.BackgroundTransparency  = 1
        EzLogoViewport.BorderSizePixel        = 0
        EzLogoViewport.ZIndex                 = 1
        EzLogoViewport.Parent                 = EzLogoHolder

        local EzLogoCamera = Instance.new("Camera")
        EzLogoCamera.Parent = EzLogoViewport
        EzLogoViewport.CurrentCamera = EzLogoCamera

        local EzLogoModel
        local EzLogoOriginalSizes = {}
        local okLogo, logoObjs = pcall(function()
            return game:GetObjects("rbxassetid://134868130308257")
        end)
        if okLogo and logoObjs and logoObjs[1] then
            EzLogoModel = logoObjs[1]
            EzLogoModel.Name = "Model"
            if not EzLogoModel.PrimaryPart then
                EzLogoModel.PrimaryPart = EzLogoModel:FindFirstChildWhichIsA("BasePart")
            end
            for _, d in ipairs(EzLogoModel:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored    = true
                    d.CanCollide  = false
                    d.Material    = Enum.Material.Neon
                end
            end
            local _, bbSize = EzLogoModel:GetBoundingBox()
            local maxExtent = math.max(bbSize.X, bbSize.Y, bbSize.Z)
            if maxExtent > 0 then
                EzLogoModel:ScaleTo(6 / maxExtent)
            end
            for _, d in ipairs(EzLogoModel:GetDescendants()) do
                if d:IsA("BasePart") then
                    EzLogoOriginalSizes[d] = d.Size
                end
            end
            EzLogoModel.Parent = EzLogoViewport
        end

        local EzLogoOrbitDistance = 15
        if EzLogoModel then
            local _, finalSize = EzLogoModel:GetBoundingBox()
            EzLogoOrbitDistance = math.max(finalSize.X, finalSize.Y, finalSize.Z) * 2.2
        end

        Library.EzLogoFrame          = EzLogoHolder
        Library.EzLogoViewport       = EzLogoViewport
        Library.EzLogoCamera         = EzLogoCamera
        Library.EzLogoModel          = EzLogoModel
        Library.EzLogoOriginalSizes  = EzLogoOriginalSizes
        Library.EzLogoOrbitDistance  = EzLogoOrbitDistance
    end

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

    Library:MakeDraggable(Outer, (25))

    local OuterScale = Library:Create('UIScale', {
        Scale   = Library.UIScaleValue or 1;
        Parent  = Outer;
    })
    Library.OuterScale = OuterScale

    local Inner = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        BorderMode        = Enum.BorderMode.Inset;
        Size              = UDim2.new(1,0,1,0);
        ZIndex            = 1;
        Parent            = Outer;
    })
    Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })

    local GameNameLabel = Library:CreateLabel({
        Position                = UDim2.new(1, -(7), 0, 0);
        Size                    = UDim2.new(0, 0, 0, (25));
        AnchorPoint             = Vector2.new(1, 0);
        Text                    = "Rivals";
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
        Size            = UDim2.new(1,0,0,(25));
        Text            = Config.Title;
        PreserveCase    = true;
        TextXAlignment  = Enum.TextXAlignment.Center;
        ZIndex          = 1;
        Parent          = Inner;
    })

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
        for _, cb in next, Library.TabResizeCallbacks do pcall(cb) end
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
            Size                    = UDim2.fromOffset((22), (22));
            ZIndex                  = 300;
            Parent                  = Inner;
        })
        local scCircle = Library:Create('Frame', {
            AnchorPoint             = Vector2.new(0, 0);
            BackgroundColor3        = Library.AccentColor;
            BackgroundTransparency  = 0.4;
            BorderSizePixel         = 0;
            Position                = UDim2.fromOffset(0, 0);
            Size                    = UDim2.fromOffset((44), (44));
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
        end)
    end

    local ModalScrollOuter = Library:Create('Frame', {
        BackgroundColor3  = Library.BackgroundColor;
        BorderColor3      = Library.OutlineColor;
        Position          = UDim2.new(0,(8),0,(25));
        Size              = UDim2.new(1,-(16),1,-(33));
        ZIndex            = 1;
        Parent            = Inner;
    })
    Library:AddToRegistry(ModalScrollOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
    local ModalScrollInner = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,1,0); ZIndex=1; Parent=ModalScrollOuter })
    Library:AddToRegistry(ModalScrollInner, { BackgroundColor3='BackgroundColor' })

    local tabBarH    = (22)
    local tabConY    = (38)
    local tabConH    = -(46)
    local TAB_OUTER  = (4)
    local TabArea = Library:Create('ScrollingFrame', {
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Position                = UDim2.new(0,(8),0,(8));
        Size                    = UDim2.new(1,-(16),0,tabBarH);
        CanvasSize              = UDim2.new(0,0,0,0);
        ScrollBarThickness      = 0;
        ScrollingDirection      = Enum.ScrollingDirection.X;
        ZIndex                  = 1;
        Parent                  = ModalScrollInner;
    })
    Library:Create('UIPadding', {
        PaddingTop     = UDim.new(0, (3));
        PaddingBottom  = UDim.new(0, (3));
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
        Position          = UDim2.new(0,(8),0,tabConY);
        Size              = UDim2.new(1,-(16),1,tabConH);
        ZIndex            = 2;
        Parent            = ModalScrollInner;
    })
    Library:AddToRegistry(TabContainer, { BackgroundColor3='MainColor'; BorderColor3='OutlineColor' })

    local SearchBtn = Library:Create('ImageButton', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, (8), 0, (4));
        Size                    = UDim2.fromOffset((18), (18));
        Image                   = "rbxassetid://118685771787843";
        ImageColor3             = Library.FontColor;
        ZIndex                  = 5;
        Parent                  = Inner;
    })

    local SearchModal = Library:Create('Frame', {
        BackgroundColor3  = Library.MainColor;
        BorderColor3      = Library.OutlineColor;
        Position          = UDim2.new(0, (8), 0, (25));
        Size              = UDim2.new(1, -(16), 1, -(33));
        Visible           = false;
        ZIndex            = 50;
        Parent            = Inner;
    })
    Library:AddToRegistry(SearchModal, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })

    local SearchBackBtn = Library:Create('TextButton', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, (4), 0, (4));
        Size                    = UDim2.fromOffset((20), (20));
        Text                    = "<";
        Font                    = Enum.Font.GothamBold;
        TextSize                = (16);
        TextColor3              = Library.FontColor;
        ZIndex                  = 52;
        Parent                  = SearchModal;
    })
    Library:AddToRegistry(SearchBackBtn, { TextColor3 = 'FontColor' })

    local SearchInput = Library:Create('TextBox', {
        BackgroundTransparency  = 1;
        Position                = UDim2.new(0, (30), 0, (4));
        Size                    = UDim2.new(1, -(38), 0, (20));
        Font                    = Library.Font;
        TextSize                = (14);
        PlaceholderText         = "Search features...";
        Text                    = "";
        TextColor3              = Library.FontColor;
        TextXAlignment          = Enum.TextXAlignment.Left;
        ClearTextOnFocus        = false;
        ZIndex                  = 51;
        Parent                  = SearchModal;
    })
    Library:AddToRegistry(SearchInput, { TextColor3 = 'FontColor'; Font = 'Font' })

    local SearchDivider = Library:Create('Frame', {
        BackgroundColor3  = Library.OutlineColor;
        BorderSizePixel   = 0;
        Position          = UDim2.new(0, (8), 0, (28));
        Size              = UDim2.new(1, -(16), 0, 1);
        ZIndex            = 51;
        Parent            = SearchModal;
    })
    Library:AddToRegistry(SearchDivider, { BackgroundColor3 = 'OutlineColor' })

    local SearchResults = Library:Create('ScrollingFrame', {
        BackgroundTransparency  = 1;
        BorderSizePixel         = 0;
        Position                = UDim2.new(0, (8), 0, (32));
        Size                    = UDim2.new(1, -(16), 1, -(40));
        CanvasSize              = UDim2.new(0,0,0,0);
        ScrollBarThickness      = (4);
        ScrollBarImageColor3    = Library.AccentColor;
        ZIndex                  = 51;
        Parent                  = SearchModal;
    })
    Library:AddToRegistry(SearchResults, { ScrollBarImageColor3 = 'AccentColor' })

    local SearchLayout = Library:Create('UIListLayout', {
        Padding    = UDim.new(0, (4));
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
                BackgroundColor3  = Library.MainColor;
                BorderColor3      = Library.OutlineColor;
                Size              = UDim2.new(1, -(8), 0, (24));
                Text              = "  " .. m.Text;
                Font              = Library.Font;
                TextSize          = (14);
                TextColor3        = Library.FontColor;
                TextXAlignment    = Enum.TextXAlignment.Left;
                ZIndex            = 52;
                Parent            = SearchResults;
            })
            Library:AddToRegistry(btn, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; TextColor3 = 'FontColor'; Font = 'Font' })

            local locLabel = Library:CreateLabel({
                Size            = UDim2.new(1, -(10), 1, 0);
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

    local sideH = WinH - (95)

    function Library:RevealElement(elementGUI)
        local function scrollTo(gui)
            task.wait(0.05)
            local sf = gui:FindFirstAncestorWhichIsA("ScrollingFrame")
            if sf then
                local y = gui.AbsolutePosition.Y - sf.AbsolutePosition.Y + sf.CanvasPosition.Y
                sf.CanvasPosition = Vector2.new(0, math.max(0, y - (10)))
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
        local tabOrigName    = tostring(Name or "")
        local tabDisplayName = Library:ApplyCase(tabOrigName, "Tabs")

        local tabFontSz = (15)
        local tbW = Library:GetTextBounds(tabDisplayName, Library.Font, tabFontSz) + (18)
        local TBtn = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderSizePixel=2; Size=UDim2.new(0,tbW,1,0); ZIndex=1; Parent=TabArea })
        Library:AddToRegistry(TBtn, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
        local TBtnLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,-1); TextSize=tabFontSz; Text=tabDisplayName; PreserveCase=true; ZIndex=3; Parent=TBtn })
        Library:TrackLabel(TBtnLabel, tabOrigName, "Tabs")
        Library:RemoveFromRegistry(TBtnLabel)
        Library:AddToRegistry(TBtnLabel, { TextColor3 = function() return Tab.Active and Library.FontColor or Color3.fromRGB(120, 120, 120) end; Font = 'Font' })
        TBtnLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        local TInline = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); Visible=false; ZIndex=6; Parent=TBtn })
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
        local TUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,-2,0,0); Size=UDim2.new(1,4,0,1); Visible=false; ZIndex=3; Parent=TBtn })
        Library:AddToRegistry(TUnder, { BackgroundColor3='AccentColor' })

        local TFrame = Library:Create('Frame', { Name='TabFrame'; BackgroundTransparency=1; Size=UDim2.new(1,0,1,0); Visible=false; ZIndex=2; Parent=TabContainer })
        Tab.Frame = TFrame
        Tab.TabFrame = TFrame

        local function MakeSide(parent, xScale, xOffset)
            local sf = Library:Create('ScrollingFrame', {
                BackgroundTransparency  = 1;
                BorderSizePixel         = 0;
                Position                = UDim2.new(xScale, xOffset, 0, (7));
                Size                    = UDim2.new(0.5, -(8), 1, -(7));
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
            local ll = Library:Create('UIListLayout', { Padding=UDim.new(0,(10)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; HorizontalAlignment=Enum.HorizontalAlignment.Center; Parent=sf })
            ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                sf.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + (8))
            end)
            return sf
        end
        local LeftSide, RightSide
        LeftSide  = MakeSide(TFrame, 0,   (4))
        RightSide = MakeSide(TFrame, 0.5, (4))

        local TFull = Library:Create('ScrollingFrame', {
            BackgroundTransparency  = 1;
            BorderSizePixel         = 0;
            Position                = UDim2.new(0, (4), 0, (7));
            Size                    = UDim2.new(1, -(8), 1, -(7));
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
        Library:AddToRegistry(TFull, { ScrollBarImageColor3='AccentColor' })
        local TFullLayout = Library:Create('UIListLayout', { Padding=UDim.new(0,(8)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=TFull })
        TFullLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            TFull.CanvasSize = UDim2.fromOffset(0, TFullLayout.AbsoluteContentSize.Y + (8))
        end)
        local TabFullMode = false

        function Tab:AddCustom(InstanceOrInfo)
            Library:BuildTick()
            local Info = typeof(InstanceOrInfo) == 'table' and InstanceOrInfo or { Instance = InstanceOrInfo }
            local CustomInstance = Info.Instance
            assert(typeof(CustomInstance) == 'Instance' and CustomInstance:IsA('GuiObject'), 'AddCustom: `Instance` must be a GuiObject.')
            if not TabFullMode then
                TabFullMode = true
                LeftSide.Visible  = false
                RightSide.Visible = false
                TFull.Visible = true
            end
            CustomInstance.Parent = TFull
            if Info.FillWidth ~= false then
                CustomInstance.Size = UDim2.new(1, -(4), CustomInstance.Size.Y.Scale, CustomInstance.Size.Y.Offset)
            end
            return CustomInstance
        end

        function Tab:ShowTab()
            for _, t in next, Window.Tabs do t:HideTab() end
            TUnder.Visible = true; TFrame.Visible = true
            TBtn.BackgroundColor3 = Library.MainColor
            if Library.RegistryMap[TBtn] then Library.RegistryMap[TBtn].Properties.BackgroundColor3 = 'MainColor' end
            TInline.Visible = true
            Tab.Active = true
            TBtnLabel.TextColor3 = Library.FontColor
        end
        function Tab:HideTab()
            for _, dd in next, Library.DropdownRegistry do dd:CloseDropdown() end
            TUnder.Visible = false; TFrame.Visible = false
            TBtn.BackgroundColor3 = Library.BackgroundColor
            if Library.RegistryMap[TBtn] then Library.RegistryMap[TBtn].Properties.BackgroundColor3 = 'BackgroundColor' end
            TInline.Visible = false
            Tab.Active = false
            TBtnLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        end
        function Tab:SetLayoutOrder(p) TBtn.LayoutOrder = p; TabLayout:ApplyLayout() end

        function Tab:AddGroupbox(Info2)
            Library:BuildTick()
            local Groupbox = {}
            local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,(40)); ZIndex=2; Parent=Info2.Side==1 and LeftSide or RightSide })
            Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
            local SliderBarInner  = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
            Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
            local btnRow = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,(19)); ZIndex=5; Parent=SliderBarInner })
            local Button = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=btnRow })
            Library:AddToRegistry(Button, { BackgroundColor3='BackgroundColor' })
            local GroupboxUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=Button })
            Library:AddToRegistry(GroupboxUnder, { BackgroundColor3='AccentColor' })
            local _gbLbl2 = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(12); Text=Library:ApplyCase(Info2.Name or "", "Groupboxes"); PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=Button })
            Library:TrackLabel(_gbLbl2, Info2.Name or "", "Groupboxes")
            local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,(20)); Size=UDim2.new(1,-(8),0,0); ZIndex=1; Parent=SliderBarInner })
            local linkedList = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,(2)); Parent=ContentFrame })

            function Groupbox:Resize()
                local sz = linkedList.AbsoluteContentSize.Y
                SliderBarOuter.Size = UDim2.new(1,0,0, (20) + sz + 4)
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
            local TabBtns = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,(19)); ZIndex=5; Parent=SliderBarInner })
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
                local ButtonLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(13); Text=Library:ApplyCase(TabName or "", "Groupboxes"); ZIndex=7; Parent=Button })
                Library:TrackLabel(ButtonLabel, TabName or "", "Groupboxes")
                local UpperLine = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button })
                Library:AddToRegistry(UpperLine, { BackgroundColor3='AccentColor' })

                local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,(20)); Size=UDim2.new(1,-(8),1,-(20)); ZIndex=1; Visible=false; Parent=SliderBarInner })
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
                    SliderBarOuter.Size = UDim2.new(1,0,0, (20) + sz + 4)
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

            Tabbox.Frame = SliderBarOuter
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

            local TitleRow = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,(19)); ZIndex=6; Parent=SliderBarInner })
            Library:AddToRegistry(TitleRow, { BackgroundColor3='BackgroundColor' })
            local TitleUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,1,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=TitleRow })
            Library:AddToRegistry(TitleUnder, { BackgroundColor3='AccentColor' })
            Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(12); Text=Info2.Name or ''; PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=TitleRow })

            local TabBtns = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,(20)); Size=UDim2.new(1,0,0,(19)); ZIndex=5; Parent=SliderBarInner })
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
                Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(13); Text=TabName; ZIndex=7; Parent=Button })
                local UpperLine = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button })
                Library:AddToRegistry(UpperLine, { BackgroundColor3='AccentColor' })

                local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,(40)); Size=UDim2.new(1,-(8),1,-(40)); ZIndex=1; Visible=false; Parent=SliderBarInner })
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
                    SliderBarOuter.Size = UDim2.new(1,0,0, (40) + sz + 4)
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

        local function BuildSubTabSystem(TFrame, YOffset)
            local SubTabSystem = { Tabs={} }

            local SubArea = Library:Create('ScrollingFrame', {
                BackgroundTransparency  = 1;
                BorderSizePixel         = 0;
                Position                = UDim2.new(0,0,0,YOffset);
                Size                    = UDim2.new(1,0,0,(28));
                CanvasSize              = UDim2.new(0,0,0,0);
                ScrollBarThickness      = 0;
                ScrollingDirection      = Enum.ScrollingDirection.X;
                ZIndex                  = 3;
                Parent                  = TFrame;
            })
            Library:Create('UIPadding', {
                PaddingTop     = UDim.new(0, (4));
                PaddingBottom  = UDim.new(0, (4));
                PaddingLeft    = UDim.new(0, (8));
                PaddingRight   = UDim.new(0, (8));
                Parent         = SubArea;
            })
            local SubLayout = Library:Create('UIListLayout', {
                FillDirection       = Enum.FillDirection.Horizontal;
                SortOrder           = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding             = UDim.new(0, (6));
                Parent              = SubArea;
            })

            local function MakeSubSide(xScale, xOffset)
                local sf = Library:Create('ScrollingFrame', {
                    BackgroundTransparency  = 1;
                    BorderSizePixel         = 0;
                    Position                = UDim2.new(xScale, xOffset, 0, (YOffset+30));
                    Size                    = UDim2.new(0.5, -(8), 1, -(YOffset+30));
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
                local ll = Library:Create('UIListLayout', { Padding=UDim.new(0,(8)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; HorizontalAlignment=Enum.HorizontalAlignment.Center; Parent=sf })
                ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    sf.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + (8))
                end)
                return sf
            end

            function SubTabSystem:GetTab(SubName)
                return SubTabSystem.Tabs[tostring(SubName or "")]
            end

            function SubTabSystem:AddTab(SubName)
                Library:BuildTick()
                local Existing = SubTabSystem.Tabs[tostring(SubName or "")]
                if Existing then return Existing end
                local ST = { Groupboxes={}; Tabboxes={} }
                local subOrigName    = tostring(SubName or "")
                local subDisplayName = Library:ApplyCase(subOrigName, "SubTabs")

                local stFontSz = (13)
                local stW = Library:GetTextBounds(subDisplayName, Library.Font, stFontSz) + (18)
                local STBtn = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderSizePixel=2; Size=UDim2.new(0,stW,1,0); ZIndex=4; Parent=SubArea })
                Library:AddToRegistry(STBtn, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
                local STBtnLabel = Library:CreateLabel({ Size=UDim2.new(1,0,1,-1); TextSize=stFontSz; Text=subDisplayName; PreserveCase=true; ZIndex=5; Parent=STBtn })
                Library:TrackLabel(STBtnLabel, subOrigName, "SubTabs")
                Library:RemoveFromRegistry(STBtnLabel)
                Library:AddToRegistry(STBtnLabel, { TextColor3 = function() return ST.Active and Library.FontColor or Color3.fromRGB(120, 120, 120) end; Font = 'Font' })
                STBtnLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                local STInline = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Color3.new(0,0,0); BorderSizePixel=1; Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); Visible=false; ZIndex=6; Parent=STBtn })
                local STUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,-2,0,0); Size=UDim2.new(1,4,0,1); Visible=false; ZIndex=5; Parent=STBtn })
                Library:AddToRegistry(STUnder, { BackgroundColor3='AccentColor' })

                local STLeft  = MakeSubSide(0,   (4))
                local STRight = MakeSubSide(0.5, (4))

                ST.LeftContainer = STLeft
                ST.RightContainer = STRight

                local STFull = Library:Create('ScrollingFrame', {
                    BackgroundTransparency  = 1;
                    BorderSizePixel         = 0;
                    Position                = UDim2.new(0, (4), 0, (YOffset+30));
                    Size                    = UDim2.new(1, -(8), 1, -(YOffset+30));
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
                Library:AddToRegistry(STFull, { ScrollBarImageColor3='AccentColor' })
                local STFullLayout = Library:Create('UIListLayout', { Padding=UDim.new(0,(8)); FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Parent=STFull })
                STFullLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    STFull.CanvasSize = UDim2.fromOffset(0, STFullLayout.AbsoluteContentSize.Y + (8))
                end)
                ST.FullContainer = STFull
                ST.FullMode = false

                function ST:ShowTab()
                    for _, t in next, SubTabSystem.Tabs do t:HideTab() end
                    STUnder.Visible = true
                    STInline.Visible = true
                    STBtn.BackgroundColor3 = Library.MainColor
                    if Library.RegistryMap[STBtn] then Library.RegistryMap[STBtn].Properties.BackgroundColor3 = 'MainColor' end
                    if ST.FullMode then
                        STFull.Visible = true
                    else
                        STLeft.Visible  = true
                        STRight.Visible = true
                    end
                    ST.Active = true
                    STBtnLabel.TextColor3 = Library.FontColor
                end
                function ST:HideTab()
                    for _, dd in next, Library.DropdownRegistry do dd:CloseDropdown() end
                    STUnder.Visible = false
                    STInline.Visible = false
                    STBtn.BackgroundColor3 = Library.BackgroundColor
                    if Library.RegistryMap[STBtn] then Library.RegistryMap[STBtn].Properties.BackgroundColor3 = 'BackgroundColor' end
                    STLeft.Visible  = false
                    STRight.Visible = false
                    STFull.Visible  = false
                    ST.Active = false
                    STBtnLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                end

                function ST:AddCustom(InstanceOrInfo)
                    Library:BuildTick()
                    local Info = typeof(InstanceOrInfo) == 'table' and InstanceOrInfo or { Instance = InstanceOrInfo }
                    local CustomInstance = Info.Instance
                    assert(typeof(CustomInstance) == 'Instance' and CustomInstance:IsA('GuiObject'), 'AddCustom: `Instance` must be a GuiObject.')
                    if not ST.FullMode then
                        ST.FullMode = true
                        STLeft.Visible  = false
                        STRight.Visible = false
                        if ST.Active then STFull.Visible = true end
                    end
                    CustomInstance.Parent = STFull
                    if Info.FillWidth ~= false then
                        CustomInstance.Size = UDim2.new(1, -(4), CustomInstance.Size.Y.Scale, CustomInstance.Size.Y.Offset)
                    end
                    return CustomInstance
                end

                function ST:AddGroupbox(Info3)
                    Library:BuildTick()
                    local Groupbox = {}
                    local SliderBarOuter = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Library.OutlineColor; BorderMode=Enum.BorderMode.Inset; Size=UDim2.new(1,0,0,(40)); ZIndex=2; Parent=Info3.Side==1 and STLeft or STRight })
                    Library:AddToRegistry(SliderBarOuter, { BackgroundColor3='BackgroundColor'; BorderColor3='OutlineColor' })
                    local SliderBarInner  = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderColor3=Color3.new(0,0,0); Size=UDim2.new(1,-2,1,-2); Position=UDim2.new(0,1,0,1); ZIndex=4; Parent=SliderBarOuter })
                    Library:AddToRegistry(SliderBarInner, { BackgroundColor3='BackgroundColor' })
                    local btnRow = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,(19)); ZIndex=5; Parent=SliderBarInner })
                    local Button = Library:Create('Frame', { BackgroundColor3=Library.BackgroundColor; BorderSizePixel=0; Size=UDim2.new(1,0,1,0); ZIndex=6; Parent=btnRow })
                    Library:AddToRegistry(Button, { BackgroundColor3='BackgroundColor' })
                    local GroupboxUnder = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Parent=Button })
                    Library:AddToRegistry(GroupboxUnder, { BackgroundColor3='AccentColor' })
                    local _gbLbl3 = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(12); Text=Library:ApplyCase(Info3.Name or "", "Groupboxes"); PreserveCase=true; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=7; Parent=Button })
                    Library:TrackLabel(_gbLbl3, Info3.Name or "", "Groupboxes")
                    local ContentFrame = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,(20)); Size=UDim2.new(1,-(8),0,0); ZIndex=1; Parent=SliderBarInner })
                    local linkedList = Library:Create('UIListLayout', { FillDirection=Enum.FillDirection.Vertical; SortOrder=Enum.SortOrder.LayoutOrder; Padding=UDim.new(0,(2)); Parent=ContentFrame })
                    function Groupbox:Resize()
                        local sz = linkedList.AbsoluteContentSize.Y
                        SliderBarOuter.Size = UDim2.new(1,0,0, (20) + sz + 4)
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
                    local TabBtns2 = Library:Create('Frame', { BackgroundTransparency=1; BorderColor3=Library.OutlineColor; BorderSizePixel=1; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,(19)); ZIndex=5; Parent=SliderBarInner })
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
                        local _tb2Lbl = Library:CreateLabel({ Size=UDim2.new(1,0,1,0); TextSize=(13); Text=Library:ApplyCase(TN or "", "Groupboxes"); ZIndex=7; Parent=Button2 })
                        Library:TrackLabel(_tb2Lbl, TN or "", "Groupboxes")
                        local UpperLine2 = Library:Create('Frame', { BackgroundColor3=Library.AccentColor; BorderSizePixel=0; Position=UDim2.new(0,0,0,0); Size=UDim2.new(1,0,0,1); ZIndex=8; Visible=false; Parent=Button2 })
                        Library:AddToRegistry(UpperLine2, { BackgroundColor3='AccentColor' })
                        local ContentFrame2 = Library:Create('Frame', { BackgroundTransparency=1; Position=UDim2.new(0,(4),0,(20)); Size=UDim2.new(1,-(8),0,0); ZIndex=1; Visible=false; Parent=SliderBarInner })
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
                            SliderBarOuter.Size = UDim2.new(1,0,0, (20)+LL2.AbsoluteContentSize.Y+4)
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
                    Tabbox2.Frame = SliderBarOuter
                    ST.Tabboxes[Info3.Name or ''] = Tabbox2
                    return Tabbox2
                end
                function ST:AddLeftTabbox(n)  return ST:AddTabbox({ Name=n; Side=1 }) end
                function ST:AddRightTabbox(n) return ST:AddTabbox({ Name=n; Side=2 }) end

                function ST:AddSubTabs()
                    if ST._nestedSubTabs then return ST._nestedSubTabs end
                    if not ST.FullMode then
                        ST.FullMode = true
                        STLeft.Visible  = false
                        STRight.Visible = false
                        if ST.Active then STFull.Visible = true end
                    end
                    local Nested = BuildSubTabSystem(TFrame, YOffset + 30)
                    Nested.SubArea.Visible = ST.Active

                    local OldNestedAddTab = Nested.AddTab
                    function Nested:AddTab(SubName)
                        local WasFirst = next(Nested.Tabs) == nil
                        local Page = OldNestedAddTab(Nested, SubName)
                        local OldPageShowTab = Page.ShowTab
                        function Page:ShowTab()
                            OldPageShowTab(Page)
                            Nested.CurrentTab = Page
                        end
                        if WasFirst then
                            Nested.CurrentTab = Page
                            if not ST.Active then Page:HideTab() end
                        end
                        return Page
                    end

                    local OldShowTab, OldHideTab = ST.ShowTab, ST.HideTab
                    function ST:ShowTab()
                        OldShowTab(ST)
                        Nested.SubArea.Visible = true
                        if Nested.CurrentTab then Nested.CurrentTab:ShowTab() end
                    end
                    function ST:HideTab()
                        OldHideTab(ST)
                        Nested.SubArea.Visible = false
                        for _, t in next, Nested.Tabs do t:HideTab() end
                    end
                    ST._nestedSubTabs = Nested
                    return Nested
                end

                STBtn.InputBegan:Connect(function(Input)
                    if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then ST:ShowTab() end
                end)

                SubTabSystem.Tabs[SubName] = ST
                local count = 0; for _ in next, SubTabSystem.Tabs do count=count+1 end
                if count == 1 then ST:ShowTab() end

                for _, cb in ipairs(Library.TabResizeCallbacks) do pcall(cb) end
                return ST
            end

            SubTabSystem.SubArea = SubArea
            return SubTabSystem
        end

        function Tab:AddSubTabs()
            if Tab.SubTabSystem then return Tab.SubTabSystem end
            LeftSide.Visible  = false
            RightSide.Visible = false
            Tab.SubTabSystem = BuildSubTabSystem(TFrame, 0)
            return Tab.SubTabSystem
        end

        TBtn.InputBegan:Connect(function(Input)
            if Library:IsPointerInput(Input) and not Library:MouseIsOverOpenedFrame() then Tab:ShowTab() end
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

    local Blur
    if not IsTouch then
        Blur = Services.Lighting:FindFirstChild("Blur") or Library:Create('BlurEffect', {
            Name    = "Blur",
            Size    = 30,
            Enabled = false,
            Parent  = Services.Lighting
        })
    end
    Library.Blur = Blur
    if Library.BackdropBlurOn == nil then Library.BackdropBlurOn = not IsTouch end
    if Library.BackdropFrameOn == nil then Library.BackdropFrameOn = not IsTouch end
    if Library.EzLogoOn == nil then Library.EzLogoOn = true end

    function Library:SetBackdropColor(color)
        if Backdrop then Backdrop.BackgroundColor3 = color end
    end
    function Library:SetBackdropOpacity(opacity)
        if Backdrop then Backdrop.BackgroundTransparency = 1 - opacity end
    end
    function Library:SetBlurOpacity(opacity)
        if Blur then Blur.Size = opacity * 40 end
    end

    function Library:SetEzLogoTransparency(alpha)
        if not Library.EzLogoModel then return end
        for _, d in ipairs(Library.EzLogoModel:GetDescendants()) do
            if d:IsA("BasePart") then d.Transparency = alpha end
        end
    end
    function Library:SetEzLogoPosition(x, y)
        if Library.EzLogoFrame then Library.EzLogoFrame.Position = UDim2.fromScale(x, y) end
    end
    function Library:SetEzLogoSize(size)
        if Library.EzLogoFrame then Library.EzLogoFrame.Size = UDim2.fromOffset(size, size) end
    end
    function Library:SetEzLogoColor(color)
        if not Library.EzLogoModel then return end
        for _, d in ipairs(Library.EzLogoModel:GetDescendants()) do
            if d:IsA("BasePart") then d.Color = color end
        end
    end
    function Library:SetEzLogoFatness(percent)
        if not Library.EzLogoModel or not Library.EzLogoOriginalSizes then return end
        local ratio = (percent / 100) * 0.6
        for d, origSize in next, Library.EzLogoOriginalSizes do
            if d.Parent then
                local widest = math.max(origSize.X, origSize.Y)
                local targetZ = ratio > 0 and (widest * ratio) or origSize.Z
                d.Size = Vector3.new(origSize.X, origSize.Y, targetZ)
            end
        end
    end
    function Library:SetEzLogoMaterial(materialName)
        if not Library.EzLogoModel then return end
        local mat = Enum.Material[materialName] or Enum.Material.Plastic
        for _, d in ipairs(Library.EzLogoModel:GetDescendants()) do
            if d:IsA("BasePart") then d.Material = mat end
        end
    end
    function Library:SetEzLogoSpeed(value)
        Library.EzLogoSpeed = value
    end

    if Library.EzLogoSpeed == nil then Library.EzLogoSpeed = 0.5 end

    if Library.EzLogoModel then
        task.spawn(function()
            local angle = 0
            local currentCFrame
            local center = Library.EzLogoModel:GetPivot().Position
            while Library.EzLogoModel and Library.EzLogoModel.Parent do
                local dt = Services.RunService.RenderStepped:Wait()
                if Library.EzLogoFrame and Library.EzLogoFrame.Visible then
                    angle = angle + math.rad(90) * (Library.EzLogoSpeed or 0.5) * dt
                    local dist = Library.EzLogoOrbitDistance or 15
                    local targetCFrame = CFrame.new(
                        center + Vector3.new(math.sin(angle) * dist, dist * 0.3, math.cos(angle) * dist),
                        center
                    )
                    if not currentCFrame then
                        currentCFrame = targetCFrame
                    else
                        currentCFrame = currentCFrame:Lerp(targetCFrame, 1 - math.exp(-12 * dt))
                    end
                    Library.EzLogoCamera.CFrame = currentCFrame
                end
            end
        end)
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

        if Blur then Blur.Enabled = isVisible and Library.BackdropBlurOn end
        if Backdrop then Backdrop.Visible = isVisible and Library.BackdropFrameOn end
        if Library.EzLogoFrame then Library.EzLogoFrame.Visible = isVisible and Library.EzLogoOn end
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

    if IsTouch then
        local vp0   = workspace.CurrentCamera.ViewportSize
        local btnSz = (44)
        local initX = math.floor(vp0.X / 2 - btnSz / 2)
        local initY = (12)

        local mobLogo = Library:Create('ImageButton', {
            BackgroundColor3  = Color3.fromRGB(20, 20, 20);
            BorderSizePixel   = 0;
            Position          = UDim2.fromOffset(initX, initY);
            Size              = UDim2.fromOffset(btnSz, btnSz);
            Image             = 'https://ez-ez.vercel.app/big_logo.png';
            ScaleType         = Enum.ScaleType.Fit;
            ZIndex            = 260;
            Parent            = ScreenGui;
        })
        Library:Create('UICorner', { CornerRadius = UDim.new(0, (8)); Parent = mobLogo })

        task.spawn(function()
            local assetPath = 'Elite Zone/Assets/big_logo.png'
            pcall(function()
                if isfile and isfile(assetPath) and getcustomasset then
                    mobLogo.Image = getcustomasset(assetPath)
                    return
                end
                local req = request or http_request or (syn and syn.request)
                if not req or not writefile or not getcustomasset then return end
                if makefolder then
                    pcall(makefolder, 'Elite Zone')
                    pcall(makefolder, 'Elite Zone/Assets')
                end
                local res = req({ Url = 'https://ez-ez.vercel.app/big_logo.png', Method = 'GET' })
                local body = res and (res.Body or res.body)
                if type(body) ~= 'string' or #body == 0 then return end
                writefile(assetPath, body)
                mobLogo.Image = getcustomasset(assetPath)
            end)
        end)

        local ActiveDragInput = nil
        local movedLogo   = false
        local dragStartX, dragStartY = 0, 0
        local frameStartX, frameStartY = 0, 0

        mobLogo.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch
                and inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            ActiveDragInput = inp
            movedLogo   = false
            dragStartX  = inp.Position.X
            dragStartY  = inp.Position.Y
            frameStartX = mobLogo.AbsolutePosition.X
            frameStartY = mobLogo.AbsolutePosition.Y
        end)

        Library:GiveSignal(Services.UserInputService.InputChanged:Connect(function(inp)
            if not ActiveDragInput then return end
            if inp ~= ActiveDragInput and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local dx = inp.Position.X - dragStartX
            local dy = inp.Position.Y - dragStartY
            if not movedLogo and (math.abs(dx) > 5 or math.abs(dy) > 5) then
                movedLogo = true
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
            if not ActiveDragInput then return end
            if inp ~= ActiveDragInput then return end
            ActiveDragInput = nil
            if not movedLogo then
                task.spawn(Library.Toggle)
            end
        end))
    end

    Library:GiveSignal(Services.UserInputService.InputBegan:Connect(function(Input, Processed)
        if IsTouch then return end
        if Input.KeyCode == Enum.KeyCode.RightControl
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
    Library:MakeDraggable(outer, (22))
    local titleBar = Library:Create("Frame", {
        Size              = UDim2.new(1, 0, 0, (22)),
        BackgroundColor3  = Library.AccentColor,
        BorderSizePixel   = 0,
        ZIndex            = 101,
        Parent            = outer,
    })
    Library:AddToRegistry(titleBar, {BackgroundColor3="AccentColor"})
    Library:CreateLabel({
        Position        = UDim2.new(0, (5), 0, 0),
        Size            = UDim2.new(1, -(26), 1, 0),
        Text            = config.Title or "panel",
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextSize        = (14),
        PreserveCase    = true,
        ZIndex          = 102,
        Parent          = titleBar,
    })
    local closeBtn = Library:Create("TextButton", {
        AnchorPoint       = Vector2.new(1, 0.5),
        Position          = UDim2.new(1, -(3), 0.5, 0),
        Size              = UDim2.new(0, (18), 0, (18)),
        BackgroundColor3  = Library.RiskColor,
        BorderSizePixel   = 0,
        Text              = "x",
        TextColor3        = Library.FontColor,
        TextSize          = (12),
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
        Position                = UDim2.new(0, 0, 0, (22)),
        Size                    = UDim2.new(1, 0, 1, -(22)),
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
    local w = isConfirm and (300) or (400)
    local h = isConfirm and (120) or (350)

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
        Size              = UDim2.new(1, 0, 0, (22)),
        BackgroundColor3  = Library.MainColor,
        BorderSizePixel   = 0,
        ZIndex            = 2002,
        Parent            = inner,
    })
    Library:AddToRegistry(titleBar, {BackgroundColor3="MainColor"})

    local backButton = Library:Create("TextButton", {
        Position          = UDim2.new(0, (3), 0.5, 0),
        AnchorPoint       = Vector2.new(0, 0.5),
        Size              = UDim2.fromOffset((16), (16)),
        BackgroundTransparency = 1,
        AutoButtonColor   = false,
        Text              = "<",
        TextColor3        = Library.FontColor,
        TextSize          = (14),
        Font              = Library.Font,
        ZIndex            = 2003,
        Parent            = titleBar,
    })
    Library:AddToRegistry(backButton, {TextColor3="FontColor", Font="Font"})
    backButton.MouseButton1Click:Connect(function() outer:Destroy() end)

    Library:CreateLabel({
        Position        = UDim2.new(0, (22), 0, 0),
        Size            = UDim2.new(1, -(43), 1, 0),
        Text            = config.Title or "Prompt",
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextSize        = (14),
        ZIndex          = 2003,
        Parent          = titleBar,
    })

    if isConfirm then
        Library:CreateLabel({
            Position        = UDim2.fromOffset((10), (30)),
            Size            = UDim2.new(1, -(20), 1, -(70)),
            Text            = config.Text or "Are you sure?",
            TextXAlignment  = Enum.TextXAlignment.Center,
            TextYAlignment  = Enum.TextYAlignment.Center,
            TextSize        = (14),
            TextWrapped     = true,
            ZIndex          = 2002,
            Parent          = inner,
        })

        local confirmBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0, (10), 1, -(30)),
            Size              = UDim2.new(0.5, -(15), 0, (20)),
            BackgroundColor3  = Library.RiskColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = (14),
            Font              = Library.Font,
            Text              = "Confirm",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(confirmBtn, {BackgroundColor3="RiskColor", BorderColor3="OutlineColor", TextColor3="FontColor", Font="Font"})

        local cancelBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0.5, (5), 1, -(30)),
            Size              = UDim2.new(0.5, -(15), 0, (20)),
            BackgroundColor3  = Library.MainColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = (14),
            Font              = Library.Font,
            Text              = "Cancel",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(cancelBtn, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor", Font="Font"})

        confirmBtn.MouseButton1Click:Connect(function()
            if config.Callback then config.Callback() end
            outer:Destroy()
        end)
        cancelBtn.MouseButton1Click:Connect(function()
            outer:Destroy()
        end)
    else
        local textBox = Library:Create("TextBox", {
            Position          = UDim2.fromOffset((10), (30)),
            Size              = UDim2.new(1, -(20), 1, config.Mode == "Import" and -(100) or -(70)),
            BackgroundColor3  = Library.MainColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = (14),
            Font              = Library.Font,
            TextXAlignment    = Enum.TextXAlignment.Left,
            TextYAlignment    = Enum.TextYAlignment.Top,
            ClearTextOnFocus  = false,
            TextWrapped       = true,
            MultiLine         = true,
            Text              = config.Text or "",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(textBox, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor", Font="Font"})

        local nameInput
        if config.Mode == "Import" then
            nameInput = Library:Create("TextBox", {
                Position          = UDim2.new(0, (10), 1, -(60)),
                Size              = UDim2.new(1, -(20), 0, (20)),
                BackgroundColor3  = Library.MainColor,
                BorderColor3      = Library.OutlineColor,
                TextColor3        = Library.FontColor,
                PlaceholderText   = "Enter Name...",
                Text              = "",
                TextSize          = (14),
                Font              = Library.Font,
                ZIndex            = 2002,
                Parent            = inner,
            })
            Library:AddToRegistry(nameInput, {BackgroundColor3="MainColor", BorderColor3="OutlineColor", TextColor3="FontColor", Font="Font"})
        end

        local actionBtn = Library:Create("TextButton", {
            Position          = UDim2.new(0, (10), 1, -(30)),
            Size              = UDim2.new(1, -(20), 0, (20)),
            BackgroundColor3  = Library.AccentColor,
            BorderColor3      = Library.OutlineColor,
            TextColor3        = Library.FontColor,
            TextSize          = (14),
            Font              = Library.Font,
            Text              = config.Mode == "Export" and "Copy to Clipboard" or "Import & Save",
            ZIndex            = 2002,
            Parent            = inner,
        })
        Library:AddToRegistry(actionBtn, {BackgroundColor3="AccentColor", BorderColor3="OutlineColor", TextColor3="FontColor", Font="Font"})

        actionBtn.MouseButton1Click:Connect(function()
            if config.Mode == "Export" then
                if setclipboard then
                    setclipboard(textBox.Text)
                    Library:Notify("Copied to clipboard.", 2)
                    actionBtn.Text = "Copied"
                    task.delay(3, function()
                        if actionBtn and actionBtn.Parent then actionBtn.Text = "Copy to Clipboard" end
                    end)
                else
                    Library:Notify("Executor does not support setclipboard.", 3)
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

local AUTOLOAD_FILE = 'Elite Zone/Cache/AutoLoad.json'
local AUTOLOAD_GAME = 'Rivals'

local function ReadAutoloadRoot()
	if isfile and isfile(AUTOLOAD_FILE) then
		local ok, data = pcall(function() return Services.HttpService:JSONDecode(readfile(AUTOLOAD_FILE)) end)
		if ok and type(data) == 'table' then return data end
	end
	return {}
end

local function ReadAutoloadFile()
	local game = ReadAutoloadRoot()[AUTOLOAD_GAME]
	if type(game) ~= 'table' then game = { theme = 'none', config = 'none' } end
	return game
end

local function WriteAutoloadField(field, value)
	if not writefile then return end
	if makefolder and isfolder and not isfolder('Elite Zone/Cache') then makefolder('Elite Zone/Cache') end
	local root = ReadAutoloadRoot()
	local game = root[AUTOLOAD_GAME]
	if type(game) ~= 'table' then game = { theme = 'none', config = 'none' } end
	game[field] = value
	root[AUTOLOAD_GAME] = game
	writefile(AUTOLOAD_FILE, Services.HttpService:JSONEncode(root))
end

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
    ['Default']      = { 0,  Services.HttpService:JSONDecode('{"FontColor":"ebdbb2","MainColor":"282828","AccentColor":"fe8019","BackgroundColor":"1d2021","OutlineColor":"3c3836"}') },
    ['Elite Zone']   = { 1,  Services.HttpService:JSONDecode('{"MainColor":"181818","AccentColor":"858586","OutlineColor":"1f1f1f","BackgroundColor":"141414","FontColor":"ffffff"}') },
    ['UE']           = { 2,  Services.HttpService:JSONDecode('{"MainColor":"181818","AccentColor":"4777b6","OutlineColor":"1f1f1f","BackgroundColor":"141414","FontColor":"ffffff"}') },
    ['Better UE']    = { 2.5, Services.HttpService:JSONDecode('{"MainColor":"181818","AccentColor":"4777b6","OutlineColor":"1f1f1f","BackgroundColor":"141414","FontColor":"d6d6d6"}') },
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
    ['Ayu Mirage']   = { 28, Services.HttpService:JSONDecode('{"FontColor":"cccac2","MainColor":"1f2430","AccentColor":"ffcc66","BackgroundColor":"171b24","OutlineColor":"242936"}') },
    ['Material Ocean']={ 29, Services.HttpService:JSONDecode('{"FontColor":"8f93a2","MainColor":"0f111a","AccentColor":"80cbc4","BackgroundColor":"090b10","OutlineColor":"1a1c25"}') },
    ['Deep Sea']     = { 30, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"001220","AccentColor":"0077b6","BackgroundColor":"000b14","OutlineColor":"002a45"}') },
    ['Vampire']      = { 31, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1a0000","AccentColor":"e60000","BackgroundColor":"0d0000","OutlineColor":"330000"}') },
    ['Obsidian']     = { 32, Services.HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"0a0a0a","AccentColor":"00ff88","BackgroundColor":"050505","OutlineColor":"1a1a1a"}') },
}
do
	
	
	local CapsCase, LowerCase = {}, {}
	for _, k in ipairs({"CaseTabs","CaseSubTabs","CaseGroupboxes","CaseToggles","CaseButtons",
		"CaseSliders","CaseDropdowns","CaseDDItems","CaseLabels","CaseInputs","CaseTooltip"}) do
		CapsCase[k]  = "Capitalized"
		LowerCase[k] = "Lowercase"
	end
	for name, entry in next, ThemeManager.BuiltInThemes do
		local colors = entry[2]
		colors.backgroundBlur, colors.blurOpacity, colors.backgroundFrame = true, 75, true
		colors.backgroundOpacity = 74
		colors.caseSettings = (name == 'UE' or name == 'Better UE') and LowerCase or CapsCase
	end
end
	local function getFontName(font)
		for name, enum in next, ThemeManager.FontMap do
			if enum == font then
				return name
			end
		end
		return 'Code'
	end

	function ThemeManager:GetAutoloadFile()
		return AUTOLOAD_FILE
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

		if type(data.caseSettings) == 'table' then
			out.caseSettings = data.caseSettings
		end

		if type(data.notifications) == 'table' then
			out.notifications = data.notifications
		end

		local backgroundOpacity = data.backgroundOpacity or data.BackgroundOpacity
		if type(backgroundOpacity) == 'number' then
			out.backgroundOpacity = backgroundOpacity
		end

		local blurOpacity = data.blurOpacity or data.BlurOpacity
		if type(blurOpacity) == 'number' then
			out.blurOpacity = blurOpacity
		end

		local backgroundBlur = data.backgroundBlur
		if backgroundBlur == nil then backgroundBlur = data.BackgroundBlur end
		if type(backgroundBlur) == 'boolean' then
			out.backgroundBlur = backgroundBlur
		end

		local backgroundFrame = data.backgroundFrame
		if backgroundFrame == nil then backgroundFrame = data.BackgroundFrame end
		if type(backgroundFrame) == 'boolean' then
			out.backgroundFrame = backgroundFrame
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

		if Options and Options.NotifyTransparency then
			state.notifications = {
				ClipDescendants = Toggles.NotifyClipDescendants and Toggles.NotifyClipDescendants.Value,
				MaxHeight       = Options.NotifyMaxHeight and Options.NotifyMaxHeight.Value,
				PosX            = Options.NotifyPosX and Options.NotifyPosX.Value,
				PosY            = Options.NotifyPosY and Options.NotifyPosY.Value,
				Transparency    = Options.NotifyTransparency and Options.NotifyTransparency.Value,
				Alignment       = Options.NotifyAlignment and Options.NotifyAlignment.Value,
				BarSide         = Options.NotifyBarSide and Options.NotifyBarSide.Value,
				SortOrder       = Options.NotifySortOrder and Options.NotifySortOrder.Value,
			}
		end

		return state
	end

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local builtInTheme = self.BuiltInThemes[theme]
		local isBuiltIn = builtInTheme ~= nil and customThemeData == nil
		local data = self:NormalizeThemeData(customThemeData or (builtInTheme and builtInTheme[2]))

		if not data then return false end

		self.CurrentThemeName = theme
		self.CurrentThemeCustom = not isBuiltIn
		self.ApplyingTheme = true

		if self.Library and type(self.Library.SetMainWindowSize) == 'function' then
			local sw, sh
			if isBuiltIn then
				sw, sh = 500, 592
			elseif data.mainWindowSize then
				sw = tonumber(data.mainWindowSize.w)
				sh = tonumber(data.mainWindowSize.h)
			end
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
				Options.ThemeManager_Font:SetValue(theme == 'Default' and 'arcade' or theme == 'Better UE' and 'tahoma' or 'code')
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

		local caseKeys = {"CaseTabs","CaseSubTabs","CaseGroupboxes","CaseToggles","CaseButtons","CaseSliders","CaseDropdowns","CaseDDItems","CaseLabels","CaseInputs","CaseTooltip"}
		if data.caseSettings then
			for _, k in ipairs(caseKeys) do
				if Options[k] then Options[k]:SetValue(data.caseSettings[k] or "Capitalized") end
			end
		end

		if data.backgroundOpacity and Options.BackgroundOpacity then
			Options.BackgroundOpacity:SetValue(data.backgroundOpacity)
		end
		if data.blurOpacity and Options.BlurOpacity then
			Options.BlurOpacity:SetValue(data.blurOpacity)
		end
		if data.backgroundBlur ~= nil and Toggles.BackgroundBlur then
			Toggles.BackgroundBlur:SetValue(data.backgroundBlur)
		end
		if data.backgroundFrame ~= nil and Toggles.BackgroundFrame then
			Toggles.BackgroundFrame:SetValue(data.backgroundFrame)
		end

		if data.notifications then
			local n = data.notifications
			if n.ClipDescendants ~= nil and Toggles.NotifyClipDescendants then Toggles.NotifyClipDescendants:SetValue(n.ClipDescendants) end
			if n.MaxHeight ~= nil    and Options.NotifyMaxHeight    then Options.NotifyMaxHeight:SetValue(n.MaxHeight) end
			if n.PosX ~= nil         and Options.NotifyPosX         then Options.NotifyPosX:SetValue(n.PosX) end
			if n.PosY ~= nil         and Options.NotifyPosY         then Options.NotifyPosY:SetValue(n.PosY) end
			if n.Transparency ~= nil and Options.NotifyTransparency then Options.NotifyTransparency:SetValue(n.Transparency) end
			if n.Alignment ~= nil    and Options.NotifyAlignment    then Options.NotifyAlignment:SetValue(n.Alignment) end
			if n.BarSide ~= nil      and Options.NotifyBarSide      then Options.NotifyBarSide:SetValue(n.BarSide) end
			if n.SortOrder ~= nil    and Options.NotifySortOrder    then Options.NotifySortOrder:SetValue(n.SortOrder) end
		end

		self.ApplyingTheme = nil
		self:ThemeUpdate()
		return true
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
		WriteAutoloadField('theme', name)
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
		end

		gb:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = Library.FontSystem.AllNames(), Default = 'code' })
		if self.Library and self.Library.IsMobile then
			gb:AddSlider('ThemeManager_IconSize', { Text = 'Icon Size', Default = self.Library.IconSize or 20, Min = 12, Max = 32, Rounding = 0 })
		end

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

		gb:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom Theme Name' })
		gb:AddDropdown('ThemeManager_CustomThemeList', {
			Text     = 'Custom Themes',
			Values   = self:ReloadCustomThemes(),
			Default  = 1,
		})
		gb:AddButton('Save', function()
			local n = Options.ThemeManager_CustomThemeName.Value
			self:SaveCustomTheme(n)
			local list = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList.Values = list
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(n)
		end):AddButton('Load', function()
			local val = Options.ThemeManager_CustomThemeList.Value
			if val and val ~= '' then
				if not self:ApplyTheme(val) then
					self.Library:Notify('Failed to load theme.', 3)
				end
			end
		end)
		gb:AddButton('Overwrite', function()
			local name = Options.ThemeManager_CustomThemeList.Value
			if not name or name == '' then return self.Library:Notify('No theme selected.', 2) end
			self:SaveCustomTheme(name)
		end):AddButton('Delete', function()
			local name = Options.ThemeManager_CustomThemeList.Value
			if not name or name == '' then return self.Library:Notify('No theme selected.', 2) end
			if not delfile or not isfile then return self.Library:Notify('Unsupported executor.', 2) end
			local path = self.Folder .. '/Themes/' .. name .. '.json'
			if not isfile(path) then return self.Library:Notify('Theme not found.', 2) end
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
						return self.Library:Notify('Name cannot be empty.', 2)
					end
					if not writefile then return self.Library:Notify('Unsupported executor.', 2) end
					local ok = pcall(Services.HttpService.JSONDecode, Services.HttpService, text)
					if not ok then return self.Library:Notify('Invalid Theme.', 3) end
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
		local name = ReadAutoloadFile().theme
		if type(name) == 'string' and name ~= '' and name ~= 'none' then return name end
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

		normalTab:AddDivider()

		self:BuildThemeSections(settingsGroupbox, false)

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

		local caseKeys = {"CaseTabs","CaseSubTabs","CaseGroupboxes","CaseToggles","CaseButtons","CaseSliders","CaseDropdowns","CaseDDItems","CaseLabels","CaseInputs","CaseTooltip"}
		theme.caseSettings = {}
		for _, k in ipairs(caseKeys) do
			if Options[k] then theme.caseSettings[k] = Options[k].Value end
		end
		theme.backgroundOpacity = tonumber(Options.BackgroundOpacity and Options.BackgroundOpacity.Value) or 10
		theme.blurOpacity       = tonumber(Options.BlurOpacity and Options.BlurOpacity.Value) or 75
		theme.backgroundBlur    = Toggles.BackgroundBlur and Toggles.BackgroundBlur.Value
		theme.backgroundFrame   = Toggles.BackgroundFrame and Toggles.BackgroundFrame.Value

		if Options.NotifyTransparency then
			theme.notifications = {
				ClipDescendants = Toggles.NotifyClipDescendants and Toggles.NotifyClipDescendants.Value,
				MaxHeight       = Options.NotifyMaxHeight and Options.NotifyMaxHeight.Value,
				PosX            = Options.NotifyPosX and Options.NotifyPosX.Value,
				PosY            = Options.NotifyPosY and Options.NotifyPosY.Value,
				Transparency    = Options.NotifyTransparency and Options.NotifyTransparency.Value,
				Alignment       = Options.NotifyAlignment and Options.NotifyAlignment.Value,
				BarSide         = Options.NotifyBarSide and Options.NotifyBarSide.Value,
				SortOrder       = Options.NotifySortOrder and Options.NotifySortOrder.Value,
			}
		end

		local ok, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, theme)
        if not ok then return false end
        return true, encoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if type(file) ~= 'string' or file:gsub(' ', '') == '' or file == '__default' then
			return self.Library:Notify('Name cannot be empty.', 3)
		end
		if not writefile then return self.Library:Notify('Unsupported executor.', 2) end

		local ok, encoded = self:GetThemeJSON()
		if not ok then return self.Library:Notify('Failed to save theme.', 3) end

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

local SaveManager = {} do

SaveManager.Folder = 'DarkCheats/Rivals'
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
            return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value, toggled = object.Toggled }
        end,
        Load = function(idx, data)
            if not Options[idx] then return end
            Options[idx]:SetValue{ data.key, data.mode }
            if type(data.toggled) == 'boolean' then
                Options[idx].Toggled = data.toggled
                Options[idx]:Update()
            end
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
    CaseRow = {
        Save = function(idx, object)
            return { type = 'CaseRow', idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if Options[idx] and type(data.value) == 'string' then Options[idx]:SetValue(data.value) end
        end,
    },
}

function SaveManager.BuildFolderTree(self)
    if not isfolder then return end
    local paths = {
        'DarkCheats',
        'DarkCheats/Assets',
        'DarkCheats/Rivals',
        'DarkCheats/Rivals/Settings',
        'DarkCheats/Rivals/Themes',
    }
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
        'CaseTabs', 'CaseSubTabs', 'CaseGroupboxes', 'CaseToggles', 'CaseButtons',
        'CaseSliders', 'CaseDropdowns', 'CaseDDItems', 'CaseLabels', 'CaseInputs', 'CaseTooltip',
        'BackgroundOpacity', 'BlurOpacity', 'BackgroundBlur', 'BackgroundFrame',
        'EzLogo', 'EzLogoTransparency', 'EzLogoPosX', 'EzLogoPosY', 'EzLogoMaterial', 'EzLogoSize',
        'EzLogoColor', 'EzLogoFatness', 'EzLogoSpeed',
        'NotifyClipDescendants', 'NotifyMaxHeight', 'NotifyPosX', 'NotifyPosY',
        'NotifyTransparency', 'NotifyAlignment', 'NotifyBarSide', 'NotifySortOrder',
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
    if not ok then return false end
    return true, encoded
end

function SaveManager.Save(self, name)
    if not writefile then self.Library:Notify('Unsupported executor.', 2) return false end
    if not name or name:gsub(' ', '') == '' then self.Library:Notify('Name cannot be empty.', 2) return false end

    local ok, encoded = self:GetConfigJSON()
    if not ok then return false end

    writefile('Elite Zone/Rivals/Settings/' .. name .. '.json', encoded)
    return true
end

function SaveManager.LoadConfigJSON(self, jsonString)
    local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, jsonString)
    if not ok then return false end

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
    if not readfile then self.Library:Notify('Unsupported executor.', 2) return false end
    if not name then self.Library:Notify('Name cannot be empty.', 2) return false end

    local file = 'DarkCheats/Rivals/Settings/' .. name .. '.json'
    if not isfile(file) then self.Library:Notify('Config not found.', 2) return false end

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
    local name = ReadAutoloadFile().config
    if type(name) == 'string' and name ~= '' and name ~= 'none' then
        local ok = self:Load(name)
        if not ok then
            if self.Library then self.Library:Notify('Autoload failed for config: ' .. tostring(name), 3) end
            return
        end
    end
end

function SaveManager.GetAutoloadName(self)
    local name = ReadAutoloadFile().config
    if type(name) == 'string' and name ~= '' and name ~= 'none' then return name end
    return nil
end

function SaveManager.SetAutoloadName(self, name)
    WriteAutoloadField('config', name)
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

    section:AddButton('Save', function()
        local name = Options.SaveManager_ConfigName.Value
        if name:gsub(' ', '') == '' then return self.Library:Notify('Name cannot be empty.', 2) end
        local ok, err = self:Save(name)
        if not ok then return self.Library:Notify('Failed to save config.', 3) end
        Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
        Options.SaveManager_ConfigList:SetValues()
        Options.SaveManager_ConfigList:SetValue(nil)
    end):AddButton('Load', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        local ok, err = self:Load(name)
        if not ok then return self.Library:Notify('Failed to load config.', 3) end
    end)

    section:AddButton('Overwrite', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        local ok, err = self:Save(name)
        if not ok then return self.Library:Notify('Failed to save config.', 3) end
    end):AddButton('Delete', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        self.Library:CreatePrompt({
            Title = "Delete Config",
            Mode = "Confirm",
            Text = 'Are you sure you want to delete "' .. name .. '"?',
            Callback = function()
                local path = 'DarkCheats/Rivals/Settings/' .. name .. '.json'
                if isfile(path) then
                    delfile(path)
                    Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
                    Options.SaveManager_ConfigList:SetValues()
                    Options.SaveManager_ConfigList:SetValue(nil)
                end
            end
        })
    end)

    section:AddButton('Refresh', function()
        Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
        Options.SaveManager_ConfigList:SetValues()
        Options.SaveManager_ConfigList:SetValue(nil)
    end):AddButton('Set as Autoload', function()
        local name = Options.SaveManager_ConfigList.Value
        if not name then return self.Library:Notify('No config selected.', 2) end
        WriteAutoloadField('config', name)
        if SaveManager.AutoloadLabel then SaveManager.AutoloadLabel:SetText('Autoload: ' .. name) end
    end)


    section:AddButton('Export', function()
        local ok, encoded = self:GetConfigJSON()
        if not ok then return self.Library:Notify('Invalid Config.', 3) end
        self.Library:CreatePrompt({
            Title = "Export Config",
            Mode = "Export",
            Text = encoded,
        })
    end):AddButton('Import', function()
        self.Library:CreatePrompt({
            Title = "Import Config",
            Mode = "Import",
            Callback = function(text, name)
                if name:gsub(' ', '') == '' then
                    return self.Library:Notify('Name cannot be empty.', 2)
                end
                local ok, err = self:LoadConfigJSON(text)
                if not ok then
                    return self.Library:Notify('Invalid Config.', 3)
                end
                self:Save(name)
                Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
                Options.SaveManager_ConfigList:SetValues()
                Options.SaveManager_ConfigList:SetValue(nil)
            end
        })
    end)

    local autoName = '__autosave'
    local savedConfig = ReadAutoloadFile().config
    if type(savedConfig) == 'string' and savedConfig ~= '' and savedConfig ~= 'none' then
        autoName = savedConfig
    end
    SaveManager.AutoloadLabel = section:AddLabel('Autoload: ' .. autoName, true)

    self:SetIgnoreIndexes{ 'SaveManager_ConfigList', 'SaveManager_ConfigName' }
end

SaveManager:BuildFolderTree()
end

return {
    Library      = Library;
    ThemeManager = ThemeManager;
    SaveManager  = SaveManager;
}
end)()
