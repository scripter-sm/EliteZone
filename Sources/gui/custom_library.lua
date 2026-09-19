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

		local Outer = EZ:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderSizePixel = 0;
			Position = Config.Position or (EZ.MainFrame and UDim2.fromOffset(EZ.MainFrame.AbsolutePosition.X + EZ.MainFrame.AbsoluteSize.X + 10, EZ.MainFrame.AbsolutePosition.Y)) or UDim2.new(0.5, -Config.Size.X.Offset / 2, 0.5, -Config.Size.Y.Offset / 2);
			Size = Config.Size;
			Visible = false;
			Active = true;
			ZIndex = 1;
			Parent = EZ.ScreenGui;
		});

		local Drag, Start, Origin;

		Outer.InputBegan:Connect(function(Input)
			local Type = Input.UserInputType;
			if Drag or (Type ~= Enum.UserInputType.MouseButton1 and Type ~= Enum.UserInputType.Touch) then return end;
			if Input.Position.Y - Outer.AbsolutePosition.Y > 25 then return end;

			Drag, Start, Origin = Input, Input.Position, Outer.Position;
		end);

		EZ:GiveSignal(InputService.InputChanged:Connect(function(Input)
			if not Drag then return end;
			if Input ~= Drag and Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end;

			local D = Input.Position - Start;
			Outer.Position = UDim2.new(Origin.X.Scale, Origin.X.Offset + D.X, Origin.Y.Scale, Origin.Y.Offset + D.Y);
		end));

		EZ:GiveSignal(InputService.InputEnded:Connect(function(Input)
			if Input == Drag or (Drag and Input.UserInputType == Enum.UserInputType.MouseButton1) then
				Drag = nil;
			end;
		end));

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

		local GameLabel = EZ:Create('TextLabel', {
			BackgroundTransparency = 1;
			Font = EZ.Font;
			TextColor3 = EZ.AccentColor;
			TextSize = 16;
			Position = UDim2.fromOffset(-8, 0);
			Size = UDim2.new(1, 0, 0, 25);
			Text = Config.Game or '';
			TextXAlignment = Enum.TextXAlignment.Right;
			ZIndex = 1;
			Parent = Inner;
		});
		EZ:ApplyTextStroke(GameLabel);
		EZ:AddToRegistry(GameLabel, { TextColor3 = 'AccentColor' });

		local Main = EZ:Create('Frame', {
			BackgroundColor3 = EZ.BackgroundColor;
			BorderColor3 = EZ.OutlineColor;
			Position = UDim2.fromOffset(8, 25);
			Size = UDim2.new(1, -16, 1, -33);
			ZIndex = 1;
			Parent = Inner;
		});
		EZ:AddToRegistry(Main, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

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

		function Window:SetTitle(Title)
			TitleLabel.Text = Title;
		end;

		function Window:SetVisible(Bool)
			Outer.Visible = Bool;
			if not Bool then Drag = nil end;
		end;

		function Window:Toggle()
			Window:SetVisible(not Outer.Visible);
		end;

		function Window:Remove()
			Outer:Destroy();
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

			local Accent = EZ:Create('Frame', {
				BackgroundColor3 = EZ.AccentColor;
				BorderSizePixel = 0;
				Size = UDim2.new(1, 0, 0, 1);
				Visible = false;
				ZIndex = 2;
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
				Parent = TabContainer;
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
					Size = UDim2.new(1, 0, 0, 2);
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

					local Scroll = EZ:Create('ScrollingFrame', {
						BackgroundTransparency = 1;
						BorderSizePixel = 0;
						Position = GridInfo.Position or UDim2.new();
						Size = GridInfo.Size or UDim2.fromScale(1, 1);
						CanvasSize = UDim2.new();
						AutomaticCanvasSize = Enum.AutomaticSize.Y;
						ScrollingDirection = Enum.ScrollingDirection.Y;
						ScrollBarThickness = EZ.IsMobile and 0 or 3;
						ScrollBarImageColor3 = EZ.AccentColor;
						BottomImage = '';
						TopImage = '';
						ZIndex = 4;
						Parent = Section.Container;
					});
					EZ:AddToRegistry(Scroll, { ScrollBarImageColor3 = function()
						for _, Item in next, Grid.Items do
							Item.Button.BackgroundColor3 = EZ.MainColor;
							Item.Button.BorderColor3 = EZ.OutlineColor;
							Item.Stroke.Color = EZ.AccentColor;
							Item.Label.TextColor3 = EZ.FontColor;
						end;
						return EZ.AccentColor;
					end });
					EZ:Create('UIPadding', { PaddingTop = UDim.new(0, 2); PaddingLeft = UDim.new(0, 2); PaddingRight = UDim.new(0, 2); PaddingBottom = UDim.new(0, 2); Parent = Scroll });
					EZ:Create('UIGridLayout', {
						CellSize = CellSize;
						CellPadding = UDim2.fromOffset(4, 4);
						SortOrder = Enum.SortOrder.LayoutOrder;
						Parent = Scroll;
					});
					Grid.Holder = Scroll;

					function Grid:SetVisible(Bool)
						Scroll.Visible = Bool;
					end;

					function Grid:AddItem(Item)
						local Cell = EZ:Create('TextButton', {
							AutoButtonColor = false;
							Text = '';
							BackgroundColor3 = EZ.MainColor;
							BorderColor3 = EZ.OutlineColor;
							BorderMode = Enum.BorderMode.Inset;
							LayoutOrder = #Grid.Items + 1;
							ZIndex = 5;
							Parent = Scroll;
						});

						local Stroke = EZ:Create('UIStroke', {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = EZ.AccentColor;
							Enabled = false;
							Parent = Cell;
						});

						local Visual = Item.Instance or EZ:Create('ImageLabel', {
							BackgroundTransparency = 1;
							Image = Item.Image or '';
							ScaleType = Enum.ScaleType.Fit;
						});
						EZ:Create(Visual, {
							AnchorPoint = Vector2.zero;
							Position = UDim2.fromOffset(3, 3);
							Size = UDim2.new(1, -6, 1, -TextHeight - 6);
							ZIndex = 6;
							Parent = Cell;
						});

						local Label = EZ:Create('TextLabel', {
							BackgroundTransparency = 1;
							Font = EZ.Font;
							TextColor3 = EZ.FontColor;
							Position = UDim2.new(0, 2, 1, -TextHeight - 1);
							Size = UDim2.new(1, -4, 0, TextHeight);
							Text = Item.Text or '';
							TextSize = 12;
							TextTruncate = Enum.TextTruncate.AtEnd;
							ZIndex = 6;
							Parent = Cell;
						});
						EZ:ApplyTextStroke(Label);

						Item.Button = Cell;
						Item.Label = Label;
						Item.Stroke = Stroke;
						Grid.Items[#Grid.Items + 1] = Item;

						Cell.Activated:Connect(function()
							Grid:Select(Item);
							if Item.Callback then EZ:SafeCallback(Item.Callback, Item) end;
							if GridInfo.Callback then EZ:SafeCallback(GridInfo.Callback, Item) end;
						end);

						return Item;
					end;

					function Grid:Select(Item)
						if Grid.Selected then Grid.Selected.Stroke.Enabled = false end;
						Grid.Selected = Item;
						if Item then Item.Stroke.Enabled = true end;
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
