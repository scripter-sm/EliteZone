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

					local Stroke = Instance.new('UIStroke');
					Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Stroke.Color = EZ.AccentColor;

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
							Item.Label.TextColor3 = EZ.FontColor;
						end;
						Stroke.Color = EZ.AccentColor;
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
							Visual.Size = ImageSize;
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
						Label.ZIndex = 7;
						Label.Parent = Cell;

						Item.Button = Cell;
						Item.Label = Label;
						Item.Search = Label.Text:lower();
						Items[Index] = Item;

						if Grid.Query then
							Cell.Visible = Item.Search:find(Grid.Query, 1, true) ~= nil;
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
						Grid.Selected = Item;
						Stroke.Parent = Item and Item.Button;
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
						Stroke.Parent = nil;
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
