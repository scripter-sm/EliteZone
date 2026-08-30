local IsScriptable = clonefunction(isscriptable);
local SetScriptable = clonefunction(setscriptable);
local SetScriptableCache = {};

local TextService = cloneref(game:GetService("TextService"));

local Drawing = {};

local Renv = getrenv();
local Genv = getgenv();
local pi = Renv.math.pi;
local huge = Renv.math.huge;
local _assert = clonefunction(Renv.assert);
local Color3New = clonefunction(Renv.Color3.new);
local InstanceNew = clonefunction(Renv.Instance.new);
local MathAtan2 = clonefunction(Renv.math.atan2);
local MathClamp = clonefunction(Renv.math.clamp);
local MathMax = clonefunction(Renv.math.max);
local tick = Renv.tick or tick or os.clock;
local _setmetatable = clonefunction(Renv.setmetatable);
local StringFormat = clonefunction(Renv.string.format);
local TypeOf = clonefunction(Renv.typeof);
local TaskSpawn = clonefunction(Renv.task.spawn);
local UdimNew = clonefunction(Renv.UDim.new);
local Udim2FromOffset = clonefunction(Renv.UDim2.fromOffset);
local Udim2New = clonefunction(Renv.UDim2.new);
local Vector2New = clonefunction(Renv.Vector2.new);
local destroy = clonefunction(game.Destroy);
local GetTextBoundsAsync = clonefunction(TextService.GetTextBoundsAsync);
local HttpGet = clonefunction(game.HttpGet);
local WriteCustomAsset = writecustomasset and clonefunction(writecustomasset);
local ProtectInstance = protectinstance and clonefunction(protectinstance);

local function create(ClassName, Properties, Children)
    local Inst = InstanceNew(ClassName);
    for i, v in Properties do
        if i ~= "Parent" then
            Inst[i] = v;
        end
    end
    if Children then
        for i, v in Children do
            v.Parent = Inst;
        end
    end
    if ProtectInstance then
        ProtectInstance(Inst);
    end
    Inst.Parent = Properties.Parent;
    return Inst;
end

do 
    local Fonts = {
        Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    };

    for i, v in Fonts do
        game:GetService("TextService"):GetTextBoundsAsync(create("GetTextBoundsParams", {
            Text = "Hi",
            Size = 12,
            Font = v,
            Width = huge
        }));
    end
end

do
    local DrawingDirectory = create("ScreenGui", {
        DisplayOrder = 15,
        IgnoreGuiInset = true,
        Name = "drawingDirectory",
        Parent = gethui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    });

    local function UpdatePosition(Frame, From, To, Thickness)
        local Central = (From + To) / 2;
        local Offset = To - From;
        Frame.Position = Udim2FromOffset(Central.X, Central.Y);
        Frame.Rotation = MathAtan2(Offset.Y, Offset.X) * 180 / pi;
        Frame.Size = Udim2FromOffset(Offset.Magnitude, Thickness);
    end

    local ItemCounter = 0;
    local Cache = {};

    local Classes = {};
    do
        local Line = {};

        function Line.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewLine = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Properties = {
                    Color = Color3New(),
                    From = Vector2New(),
                    Thickness = 1,
                    To = Vector2New(),
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("Frame", {
                    Name = id,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundColor3 = Color3New(),
                    BorderSizePixel = 0,
                    Parent = DrawingDirectory,
                    Position = Udim2New(),
                    Size = Udim2New(),
                    Visible = false,
                    ZIndex = 0
                })
            }, Line);

            Cache[id] = NewLine;
            return NewLine;
        end

        function Line:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Line[k];
        end

        function Line:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props = self.Properties;

                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end

                Props[k] = v;

                if k == "Color" then
                    self.Frame.BackgroundColor3 = v;
                elseif k == "From" then
                    self:UpdatePosition();
                elseif k == "Thickness" then
                    self.Frame.Size = Udim2FromOffset(self.Frame.AbsoluteSize.X, MathMax(v, 0.1));
                elseif k == "To" then
                    self:UpdatePosition();
                elseif k == "Transparency" then
                    self.Frame.BackgroundTransparency = MathClamp(1 - v, 0, 1);
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Line:__iter()
            return next, self.Properties;
        end

        function Line:__tostring()
            return "Drawing";
        end

        function Line:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Line:UpdatePosition()
            local Props = self.Properties;
            UpdatePosition(self.Frame, Props.From, Props.To, Props.Thickness);
        end

        Line.Remove = Line.Destroy;
        Classes.Line = Line;
    end

    do
        local Circle = {};

        function Circle.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewCircle = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Properties = {
                    Color = Color3New(),
                    Filled = false,
                    NumSides = 0,
                    Position = Vector2New(),
                    Radius = 0,
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("Frame", {
                    Name = id,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundColor3 = Color3New(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = DrawingDirectory,
                    Position = Udim2New(),
                    Size = Udim2New(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UICorner", {
                        Name = "Corner",
                        CornerRadius = UdimNew(1, 0)
                    }),
                    create("UIStroke", {
                        Name = "Stroke",
                        Color = Color3New(),
                        Thickness = 1,
                    })
                })
            }, Circle);

            Cache[id] = NewCircle;
            return NewCircle;
        end

        function Circle:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Circle[k];
        end

        function Circle:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props = self.Properties;
                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Color" then
                    self.Frame.BackgroundColor3 = v;
                    self.Frame.Stroke.Color = v;
                elseif k == "Filled" then
                    self.Frame.BackgroundTransparency = v and 1 - Props.Transparency or 1;
                elseif k == "Position" then
                    self.Frame.Position = Udim2FromOffset(v.X, v.Y);
                elseif k == "Radius" then
                    self:UpdateRadius();
                elseif k == "Thickness" then
                    self.Frame.Stroke.Thickness = MathMax(v, 0.1);
                    self:UpdateRadius();
                elseif k == "Transparency" then
                    self.Frame.Stroke.Transparency = 1 - v;
                    if Props.Filled then
                        self.Frame.BackgroundTransparency = 1 - v;
                    end
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Circle:__iter()
            return next, self.Properties;
        end

        function Circle:__tostring()
            return "Drawing";
        end

        function Circle:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Circle:UpdateRadius()
            local Props = self.Properties;
            local Diameter = (Props.Radius * 2) - (Props.Thickness * 2);
            self.Frame.Size = Udim2FromOffset(Diameter, Diameter);
        end

        Circle.Remove = Circle.Destroy;
        Classes.Circle = Circle;
    end

    do
        local EnumToFont = {
            [0] = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            [1] = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            [2] = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            [3] = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        };

        local Text = {};

        function Text.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewText = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Properties = {
                    Center = false,
                    Color = Color3New(),
                    Font = 0,
                    Outline = false,
                    OutlineColor = Color3New(),
                    Position = Vector2New(),
                    Size = 12,
                    Text = "",
                    TextBounds = Vector2New(),
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("TextLabel", {
                    Name = id,
                    BackgroundTransparency = 1,
                    FontFace = EnumToFont[0],
                    Parent = DrawingDirectory,
                    Position = Udim2New(),
                    Size = Udim2New(),
                    Text = "",
                    TextColor3 = Color3New(),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UIStroke", {
                        Name = "Stroke",
                        Color = Color3New(),
                        Enabled = false,
                        Thickness = 1
                    })
                })
            }, Text);

            Cache[id] = NewText;
            return NewText;
        end

        function Text:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Text[k];
        end

        function Text:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props = self.Properties;
                if k == "Font" then
                    if (typeof(v) ~= "number" and typeof(v) ~= "Font") or Props.Font == v then
                        return;
                    end
                elseif k == "TextBounds" or Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Center" then
                    self.Frame.TextXAlignment = v and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left;
                elseif k == "Color" then
                    self.Frame.TextColor3 = v;
                elseif k == "Font" then
                    self.Frame.FontFace = typeof(v) == "Font" and v or EnumToFont[v];
                    self:UpdateTextBounds();
                elseif k == "Outline" then
                    self.Frame.Stroke.Enabled = v;
                elseif k == "OutlineColor" then
                    self.Frame.Stroke.Color = v;
                elseif k == "Position" then
                    self.Frame.Position = Udim2FromOffset(v.X, v.Y);
                elseif k == "Size" then
                    self.Frame.TextSize = v;
                    self:UpdateTextBounds();
                elseif k == "Text" then
                    self.Frame.Text = v;
                    self:UpdateTextBounds();
                elseif k == "Transparency" then
                    self.Frame.TextTransparency = 1 - v;
                    self.Frame.Stroke.Transparency = 1 - v;
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Text:__iter()
            return next, self.Properties;
        end

        function Text:__tostring()
            return "Drawing";
        end

        function Text:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Text:UpdateTextBounds()
            local Props = self.Properties;
            Props.TextBounds = GetTextBoundsAsync(TextService, create("GetTextBoundsParams", {
                Text = Props.Text,
                Size = Props.Size,
                Font = typeof(Props.Font) == "Font" and Props.Font or EnumToFont[Props.Font],
                Width = huge
            }));
        end

        Text.Remove = Text.Destroy;
        Classes.Text = Text;
    end

    do
        local Square = {};

        function Square.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewSquare = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Properties = {
                    Color = Color3New(),
                    Filled = false,
                    Position = Vector2New(),
                    Size = Vector2New(),
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("Frame", {
                    BackgroundColor3 = Color3New(),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = DrawingDirectory,
                    Position = Udim2New(),
                    Size = Udim2New(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UIStroke", {
                        Name = "Stroke",
                        Color = Color3New(),
                        Thickness = 1,
                        LineJoinMode = Enum.LineJoinMode.Miter;
                    })
                })
            }, Square);

            Cache[id] = NewSquare;
            return NewSquare;
        end

        function Square:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Square[k];
        end

        function Square:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props = self.Properties;
                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Color" then
                    self.Frame.BackgroundColor3 = v;
                    self.Frame.Stroke.Color = v;
                elseif k == "Filled" then
                    self.Frame.BackgroundTransparency = v and 1 - Props.Transparency or 1;
                elseif k == "Position" then
                    self:UpdateScale();
                elseif k == "Size" then
                    self:UpdateScale();
                elseif k == "Thickness" then
                    self.Frame.Stroke.Thickness = v;
                    self:UpdateScale();
                elseif k == "Transparency" then
                    self.Frame.Stroke.Transparency = 1 - v;
                    if Props.Filled then
                        self.Frame.BackgroundTransparency = 1 - v;
                    end
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Square:__iter()
            return next, self.Properties;
        end

        function Square:__tostring()
            return "Drawing";
        end

        function Square:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Square:UpdateScale()
            local Props = self.Properties;
            self.Frame.Position = Udim2FromOffset(Props.Position.X + Props.Thickness, Props.Position.Y + Props.Thickness);
            local Thickness = Props.Thickness;
            self.Frame.Size = Udim2FromOffset(Props.Size.X - Thickness * 2, Props.Size.Y - Thickness * 2);
        end

        Square.Remove = Square.Destroy;
        Classes.Square = Square;
    end

    do
        local Image = {};

        function Image.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewImage = _setmetatable({
                InstanceId = id,
                ImageId = 0,
                __OBJECT_EXISTS = true,
                Properties = {
                    Color = Color3New(1, 1, 1),
                    Data = "",
                    Position = Vector2New(),
                    Rounding = 0,
                    Size = Vector2New(),
                    Transparency = 1,
                    Uri = "",
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("ImageLabel", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Image = "",
                    ImageColor3 = Color3New(1, 1, 1),
                    Parent = DrawingDirectory,
                    Position = Udim2New(),
                    Size = Udim2New(),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("UICorner", {
                        Name = "Corner",
                        CornerRadius = UdimNew()
                    })
                })
            }, Image);

            Cache[id] = NewImage;
            return NewImage;
        end

        function Image:__index(k)
            _assert(k ~= "Data", StringFormat("Attempt to read writeonly property '%s'", k));
            if k == "Loaded" then
                return self.Frame.IsLoaded;
            end
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Image[k];
        end

        function Image:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props = self.Properties;
                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Color" then
                    self.Frame.ImageColor3 = v;
                elseif k == "Data" then
                    self:NewImage(v);
                elseif k == "Position" then
                    self.Frame.Position = Udim2FromOffset(v.X, v.Y);
                elseif k == "Rounding" then
                    self.Frame.Corner.CornerRadius = UdimNew(0, v);
                elseif k == "Size" then
                    self.Frame.Size = Udim2FromOffset(v.X, v.Y);
                elseif k == "Transparency" then
                    self.Frame.ImageTransparency = 1 - v;
                elseif k == "Uri" then
                    self:NewImage(v, true);
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Image:__iter()
            return next, self.Properties;
        end

        function Image:__tostring()
            return "Drawing";
        end

        function Image:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Image:NewImage(Data, IsUri)
            TaskSpawn(function() 
                self.ImageId = self.ImageId + 1;
                local Path = StringFormat("%s-%s.png", self.InstanceId, self.ImageId);
                if IsUri then
                    local NewData;
                    while NewData == nil do
                        local Success, Res = pcall(HttpGet, game, Data, true);
                        if Success then
                            NewData = Res;
                        elseif string.find(string.lower(Res), "too many requests") then
                            task.wait(3);
                        else
                            error(Res, 2);
                            return;
                        end
                    end
                    self.Properties.Data = Data;
                else
                    self.Properties.Uri = "";
                end
                self.Frame.Image = WriteCustomAsset(Path, Data);
            end);
        end

        Image.Remove = Image.Destroy;
        Classes.Image = Image;
    end

    do
        local Triangle = {};

        function Triangle.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewTriangle = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Scanlines = {},
                Properties = {
                    Color = Color3New(),
                    Filled = false,
                    PointA = Vector2New(),
                    PointB = Vector2New(),
                    PointC = Vector2New(),
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Parent = DrawingDirectory,
                    Size = Udim2New(1, 0, 1, 0),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("Frame", {
                        Name = "Line1",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    }),
                    create("Frame", {
                        Name = "Line2",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    }),
                    create("Frame", {
                        Name = "Line3",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    })
                })
            }, Triangle);

            Cache[id] = NewTriangle;
            return NewTriangle;
        end

        function Triangle:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Triangle[k];
        end

        function Triangle:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props, Frame = self.Properties, self.Frame;
                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Color" then
                    Frame.Line1.BackgroundColor3 = v;
                    Frame.Line2.BackgroundColor3 = v;
                    Frame.Line3.BackgroundColor3 = v;
                    for _, Sl in ipairs(self.Scanlines) do Sl.BackgroundColor3 = v end
                elseif k == "Filled" then
                    self:CalculateFill()
                elseif k == "PointA" then
                    self:UpdateVertices({
                        { Frame.Line1, Props.PointA, Props.PointB },
                        { Frame.Line3, Props.PointC, Props.PointA }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "PointB" then
                    self:UpdateVertices({
                        { Frame.Line1, Props.PointA, Props.PointB },
                        { Frame.Line2, Props.PointB, Props.PointC }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "PointC" then
                    self:UpdateVertices({
                        { Frame.Line2, Props.PointB, Props.PointC },
                        { Frame.Line3, Props.PointC, Props.PointA }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "Thickness" then
                    local Thickness = MathMax(v, 0.1);
                    Frame.Line1.Size = Udim2FromOffset(Frame.Line1.AbsoluteSize.X, Thickness);
                    Frame.Line2.Size = Udim2FromOffset(Frame.Line2.AbsoluteSize.X, Thickness);
                    Frame.Line3.Size = Udim2FromOffset(Frame.Line3.AbsoluteSize.X, Thickness);
                elseif k == "Transparency" then
                    Frame.Line1.BackgroundTransparency = 1 - v;
                    Frame.Line2.BackgroundTransparency = 1 - v;
                    Frame.Line3.BackgroundTransparency = 1 - v;
                    for _, Sl in ipairs(self.Scanlines) do Sl.BackgroundTransparency = 1 - v end
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                    for _, Sl in ipairs(self.Scanlines) do Sl.Visible = v end
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                    for _, Sl in ipairs(self.Scanlines) do Sl.ZIndex = v end
                end
            end
        end

        function Triangle:__iter()
            return next, self.Properties;
        end

        function Triangle:__tostring()
            return "Drawing";
        end

        function Triangle:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            for _, Sl in ipairs(self.Scanlines) do destroy(Sl) end
            destroy(self.Frame);
        end

        function Triangle:UpdateVertices(Vertices)
            local Thickness = self.Properties.Thickness;
            for i, v in Vertices do
                UpdatePosition(v[1], v[2], v[3], Thickness);
            end
        end

        function Triangle:CalculateFill()
            local Props = self.Properties
            local Scanlines = self.Scanlines
            if not Props.Filled then
                for _, Sl in ipairs(Scanlines) do Sl.Visible = false end
                return
            end
            local A, B, C = Props.PointA, Props.PointB, Props.PointC
            local Verts = {{X=A.X,Y=A.Y},{X=B.X,Y=B.Y},{X=C.X,Y=C.Y}}
            table.sort(Verts, function(a, b) return a.Y < b.Y end)
            local V1, V2, V3 = Verts[1], Verts[2], Verts[3]
            local YMin = math.floor(V1.Y)
            local YMax = math.ceil(V3.Y)
            local Height = YMax - YMin
            local Color = Props.Color
            local BgTrans = 1 - Props.Transparency
            local Vis = Props.Visible
            local Zi = Props.ZIndex
            while #Scanlines < Height + 1 do
                local Sl = InstanceNew("Frame")
                Sl.BorderSizePixel = 0
                Sl.AnchorPoint = Vector2New(0, 0)
                Sl.BackgroundColor3 = Color
                Sl.BackgroundTransparency = BgTrans
                Sl.ZIndex = Zi
                Sl.Parent = self.Frame
                Scanlines[#Scanlines + 1] = Sl
            end
            local function EdgeX(Ya, Yb, Xa, Xb, y)
                if Ya == Yb then return Xa end
                return Xa + (y - Ya) / (Yb - Ya) * (Xb - Xa)
            end
            local SlIdx = 0
            for y = YMin, YMax do
                local XL, XR
                if y <= V2.Y then
                    XL = EdgeX(V1.Y, V2.Y, V1.X, V2.X, y)
                    XR = EdgeX(V1.Y, V3.Y, V1.X, V3.X, y)
                else
                    XL = EdgeX(V2.Y, V3.Y, V2.X, V3.X, y)
                    XR = EdgeX(V1.Y, V3.Y, V1.X, V3.X, y)
                end
                if XL > XR then XL, XR = XR, XL end
                local w = XR - XL
                if w > 0 then
                    SlIdx = SlIdx + 1
                    local Sl = Scanlines[SlIdx]
                    Sl.BackgroundColor3 = Color
                    Sl.BackgroundTransparency = BgTrans
                    Sl.ZIndex = Zi
                    Sl.Position = Udim2FromOffset(XL, y)
                    Sl.Size = Udim2FromOffset(w, 1)
                    Sl.Visible = Vis
                end
            end
            for i = SlIdx + 1, #Scanlines do
                Scanlines[i].Visible = false
            end
        end

        Triangle.Remove = Triangle.Destroy;
        Classes.Triangle = Triangle;
    end

    do
        local Quad = {};

        function Quad.new()
            ItemCounter = ItemCounter + 1;
            local id = ItemCounter;

            local NewQuad = _setmetatable({
                InstanceId = id,
                __OBJECT_EXISTS = true,
                Properties = {
                    Color = Color3New(),
                    Filled = false,
                    PointA = Vector2New(),
                    PointB = Vector2New(),
                    PointC = Vector2New(),
                    PointD = Vector2New(),
                    Thickness = 1,
                    Transparency = 1,
                    Visible = false,
                    ZIndex = 0
                },
                Frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Parent = DrawingDirectory,
                    Size = Udim2New(1, 0, 1, 0),
                    Visible = false,
                    ZIndex = 0
                }, {
                    create("Frame", {
                        Name = "Line1",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    }),
                    create("Frame", {
                        Name = "Line2",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    }),
                    create("Frame", {
                        Name = "Line3",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    }),
                    create("Frame", {
                        Name = "Line4",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BackgroundColor3 = Color3New(),
                        BorderSizePixel = 0,
                        Position = Udim2New(),
                        Size = Udim2New(),
                        ZIndex = 0
                    })
                })
            }, Quad);

            Cache[id] = NewQuad;
            return NewQuad;
        end

        function Quad:__index(k)
            local Prop = self.Properties[k];
            if Prop ~= nil then
                return Prop;
            end
            return Quad[k];
        end

        function Quad:__newindex(k, v)
            if self.__OBJECT_EXISTS == true then
                local Props, Frame = self.Properties, self.Frame;
                if Props[k] == nil or Props[k] == v or typeof(Props[k]) ~= typeof(v) then
                    return;
                end
                Props[k] = v;
                if k == "Color" then
                    Frame.Line1.BackgroundColor3 = v;
                    Frame.Line2.BackgroundColor3 = v;
                    Frame.Line3.BackgroundColor3 = v;
                    Frame.Line4.BackgroundColor3 = v;
                elseif k == "Filled" then
                elseif k == "PointA" then
                    self:UpdateVertices({
                        { Frame.Line1, Props.PointA, Props.PointB },
                        { Frame.Line4, Props.PointD, Props.PointA }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "PointB" then
                    self:UpdateVertices({
                        { Frame.Line1, Props.PointA, Props.PointB },
                        { Frame.Line2, Props.PointB, Props.PointC }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "PointC" then
                    self:UpdateVertices({
                        { Frame.Line2, Props.PointB, Props.PointC },
                        { Frame.Line3, Props.PointC, Props.PointD }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "PointD" then
                    self:UpdateVertices({
                        { Frame.Line3, Props.PointC, Props.PointD },
                        { Frame.Line4, Props.PointD, Props.PointA }
                    });
                    if Props.Filled then
                        self:CalculateFill();
                    end
                elseif k == "Thickness" then
                    local Thickness = MathMax(v, 0.1);
                    Frame.Line1.Size = Udim2FromOffset(Frame.Line1.AbsoluteSize.X, Thickness);
                    Frame.Line2.Size = Udim2FromOffset(Frame.Line2.AbsoluteSize.X, Thickness);
                    Frame.Line3.Size = Udim2FromOffset(Frame.Line3.AbsoluteSize.X, Thickness);
                    Frame.Line4.Size = Udim2FromOffset(Frame.Line4.AbsoluteSize.X, Thickness);
                elseif k == "Transparency" then
                    Frame.Line1.BackgroundTransparency = 1 - v;
                    Frame.Line2.BackgroundTransparency = 1 - v;
                    Frame.Line3.BackgroundTransparency = 1 - v;
                    Frame.Line4.BackgroundTransparency = 1 - v;
                elseif k == "Visible" then
                    self.Frame.Visible = v;
                elseif k == "ZIndex" then
                    self.Frame.ZIndex = v;
                end
            end
        end

        function Quad:__iter()
            return next, self.Properties;
        end

        function Quad:__tostring()
            return "Drawing";
        end

        function Quad:Destroy()
            Cache[self.InstanceId] = nil;
            self.__OBJECT_EXISTS = false;
            destroy(self.Frame);
        end

        function Quad:UpdateVertices(Vertices)
            local Thickness = self.Properties.Thickness;
            for i, v in Vertices do
                UpdatePosition(v[1], v[2], v[3], Thickness);
            end
        end

        function Quad:CalculateFill()

        end

        Quad.Remove = Quad.Destroy;
        Classes.Quad = Quad;
    end

    Drawing.new = newcclosure(function(x)
        return _assert(Classes[x], StringFormat("Invalid drawing type '%s'", x)).new();
    end);

    Drawing.clear = newcclosure(function()
        for i, v in Cache do
            if v.__OBJECT_EXISTS then
                v:Destroy();
            end
        end
    end);

    Drawing.Cache = Cache;
end

setreadonly(Drawing, true);

Genv.Drawing = Drawing;
Genv.Cleardrawcache = Drawing.clear;

Genv.Isrenderobj = newcclosure(function(x)
    return tostring(x) == "Drawing";
end);

local IsRenderObj = clonefunction(Isrenderobj);

Genv.Getrenderproperty = newcclosure(function(x, y)
    _assert(IsRenderObj(x), StringFormat("invalid argument #1 to 'getrenderproperty' (Drawing expected, got %s)", TypeOf(x)));
    return x[y];
end);

Genv.Setrenderproperty = newcclosure(function(x, y, z)
    _assert(IsRenderObj(x), StringFormat("invalid argument #1 to 'setrenderproperty' (Drawing expected, got %s)", TypeOf(x)));
    x[y] = z;
end);

Genv.DrawingLoaded = true;

return Drawing;

