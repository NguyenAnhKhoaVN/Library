
local CombinedLibrary = {}
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

-- Kế thừa các tiện ích từ TeddyLib
function CombinedLibrary:TweenInstance(Instance, Time, OldValue, NewValue)
    local Tween = TweenService:Create(Instance, TweenInfo.new(Time, Enum.EasingStyle.Quad),
        { [OldValue] = NewValue })
    Tween:Play()
    return Tween
end

function CombinedLibrary:UpdateContent(Content, Title, Object)
    if Content.Text ~= "" then
        Title.Position = UDim2.new(0, 10, 0, 7)
        Title.Size = UDim2.new(1, -60, 0, 16)
        local MaxY = math.max(Content.TextBounds.Y + 15, 45)
        Object.Size = UDim2.new(1, 0, 0, MaxY)
    end
end

function CombinedLibrary:UpdateScrolling(Scroll, List)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 15)
    end)
end

function CombinedLibrary:MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, 
                              StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        self:TweenInstance(object, 0.2, "Position", pos)
    end
    
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end)
end

-- Kế thừa themes và cấu trúc từ redzlib
CombinedLibrary.Themes = {
    Darker = {
        ["Color Hub 1"] = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
        }),
        ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
        ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
        ["Color Theme"] = Color3.fromRGB(88, 101, 242),
        ["Color Text"] = Color3.fromRGB(243, 243, 243),
        ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
    },
    Dark = {
        ["Color Hub 1"] = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(47.5, 47.5, 47.5)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 40, 40))
        }),
        ["Color Hub 2"] = Color3.fromRGB(45, 45, 45),
        ["Color Stroke"] = Color3.fromRGB(65, 65, 65),
        ["Color Theme"] = Color3.fromRGB(65, 150, 255),
        ["Color Text"] = Color3.fromRGB(245, 245, 245),
        ["Color Dark Text"] = Color3.fromRGB(190, 190, 190)
    },
    Purple = {
        ["Color Hub 1"] = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(27.5, 25, 30)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(27.5, 25, 30))
        }),
        ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
        ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
        ["Color Theme"] = Color3.fromRGB(150, 0, 255),
        ["Color Text"] = Color3.fromRGB(240, 240, 240),
        ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
    }
}

CombinedLibrary.Info = { Version = "2.0.0" }
CombinedLibrary.Save = { UISize = {550, 380}, TabSize = 160, Theme = "Darker" }
CombinedLibrary.Settings = {}
CombinedLibrary.Flags = {}
CombinedLibrary.Tabs = {}
CombinedLibrary.Options = {}

-- Hàm tiện ích chung
function CombinedLibrary:MakeConfig(Config, NewConfig)
    for i, v in next, Config do
        if not NewConfig[i] then
            NewConfig[i] = v
        end
    end
    return NewConfig
end

local function Create(className, parent, properties, children)
    local instance = Instance.new(className)
    
    if parent then
        instance.Parent = parent
    end
    
    if properties then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    
    return instance
end

-- Tạo UI chính kết hợp cả hai phong cách
function CombinedLibrary:NewWindow(ConfigWindow)
    local ConfigWindow = self:MakeConfig({
        Title = "Combined Library",
        Description = "Kết hợp từ redzlib và TeddyLib",
        Theme = "Darker",
        Size = {555, 350}
    }, ConfigWindow or {})
    
    -- Tạo ScreenGui
    local CombinedUI = Create("ScreenGui", CoreGui, {
        Name = "CombinedLibraryUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Tạo drop shadow (từ TeddyLib)
    local DropShadowHolder = Create("Frame", CombinedUI, {
        Name = "DropShadowHolder",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, ConfigWindow.Size[1], 0, ConfigWindow.Size[2]),
        ZIndex = 0
    })
    
    local DropShadow = Create("ImageLabel", DropShadowHolder, {
        Name = "DropShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 47, 1, 47),
        ZIndex = 0,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.500,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    
    -- Main frame (kết hợp cả hai)
    local Main = Create("Frame", DropShadowHolder, {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, ConfigWindow.Size[1], 0, ConfigWindow.Size[2])
    })
    
    local UICorner = Create("UICorner", Main, {CornerRadius = UDim.new(0, 8)})
    
    -- Top bar (từ TeddyLib với gradient từ redzlib)
    local Top = Create("Frame", Main, {
        Name = "Top",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    -- Gradient cho top bar (từ redzlib)
    local TopGradient = Create("UIGradient", Top, {
        Color = self.Themes[ConfigWindow.Theme]["Color Hub 1"],
        Rotation = 45
    })
    
    local Line = Create("Frame", Top, {
        Name = "Line",
        BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Theme"],
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })
    
    -- Title và description
    local Left = Create("Folder", Top, {Name = "Left"})
    
    local NameHub = Create("TextLabel", Left, {
        Name = "NameHub",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 10),
        Size = UDim2.new(0, 470, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = ConfigWindow.Title,
        TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Desc = Create("TextLabel", Left, {
        Name = "Desc",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 27),
        Size = UDim2.new(0, 470, 1, -30),
        Font = Enum.Font.Gotham,
        Text = ConfigWindow.Description,
        TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    -- Control buttons (từ redzlib)
    local Right = Create("Folder", Top, {Name = "Right"})
    
    local Frame = Create("Frame", Right, {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -110, 0, 0),
        Size = UDim2.new(0, 110, 1, 0)
    })
    
    local UIListLayout = Create("UIListLayout", Frame, {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    
    local CloseButton = Create("TextButton", Frame, {
        Name = "Close",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Text = "",
        AutoButtonColor = false
    })
    
    local CloseIcon = Create("ImageLabel", CloseButton, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://10747384394" -- X icon từ redzlib
    })
    
    local MinizeButton = Create("TextButton", Frame, {
        Name = "Minimize",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Text = "",
        AutoButtonColor = false
    })
    
    local MinizeIcon = Create("ImageLabel", MinizeButton, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://10734896206" -- Minus icon
    })
    
    -- Tab area (kết hợp cả hai)
    local TabFrame = Create("Frame", Main, {
        Name = "TabFrame",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 144, 1, -50)
    })
    
    local Line2 = Create("Frame", TabFrame, {
        Name = "Line",
        BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Theme"],
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })
    
    -- Search (từ TeddyLib)
    local SearchFrame = Create("Frame", TabFrame, {
        Name = "SearchFrame",
        BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 7, 0, 10),
        Size = UDim2.new(1, -14, 0, 30)
    })
    
    Create("UICorner", SearchFrame, {CornerRadius = UDim.new(0, 3)})
    
    local SearchBox = Create("TextBox", SearchFrame, {
        Name = "SearchBox",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.GothamBold,
        PlaceholderText = "Search...",
        Text = "",
        TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab scrolling (từ TeddyLib)
    local ScrollingTab = Create("ScrollingFrame", TabFrame, {
        Name = "ScrollingTab",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Selectable = false,
        Size = UDim2.new(1, 0, 1, -50),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local UIPadding2 = Create("UIPadding", ScrollingTab, {
        PaddingBottom = UDim.new(0, 3),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 3)
    })
    
    local UIListLayout2 = Create("UIListLayout", ScrollingTab, {
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Content area
    local LayoutFrame = Create("Frame", Main, {
        Name = "LayoutFrame",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 144, 0, 50),
        Size = UDim2.new(1, -144, 1, -50),
        ClipsDescendants = true
    })
    
    local RealLayout = Create("Frame", LayoutFrame, {
        Name = "RealLayout",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })
    
    local LayoutList = Create("Folder", RealLayout, {Name = "Layout List"})
    
    local UIPageLayout = Create("UIPageLayout", LayoutList, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        EasingStyle = Enum.EasingStyle.Quad,
        TweenTime = 0.300
    })
    
    local LayoutName = Create("Frame", LayoutFrame, {
        Name = "LayoutName",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    local TextLabel = Create("TextLabel", LayoutName, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Dropdown zone (từ TeddyLib)
    local DropdownZone = Create("Frame", Main, {
        Name = "DropdownZone",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    Create("UICorner", DropdownZone, {CornerRadius = UDim.new(0, 5)})
    
    -- Toggle button (từ TeddyLib)
    local ToggleButton = Create("ImageButton", CombinedUI, {
        BorderSizePixel = 0,
        BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
        Image = "rbxassetid://136103435617044",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.26651, 0, 0.43687, 0),
        AutoButtonColor = false
    })
    
    Create("UICorner", ToggleButton, {CornerRadius = UDim.new(1, 0)})
    
    local UIStroke = Create("UIStroke", ToggleButton, {
        Thickness = 2,
        Color = self.Themes[ConfigWindow.Theme]["Color Theme"]
    })
    
    -- Làm cho cửa sổ có thể kéo
    self:MakeDraggable(Top, DropShadowHolder)
    self:MakeDraggable(ToggleButton, ToggleButton)
    
    -- Cập nhật kích thước
    self:UpdateScrolling(ScrollingTab, UIListLayout2)
    
    -- Biến trạng thái
    local AllLayouts = 0
    local Window = {}
    
    -- Sự kiện nút
    ToggleButton.MouseButton1Click:Connect(function()
        CombinedUI.Enabled = not CombinedUI.Enabled
    end)
    
    MinizeButton.MouseButton1Click:Connect(function()
        CombinedUI.Enabled = false
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        DropdownZone.Visible = true
        local ConfirmDialog = Create("Frame", DropdownZone, {
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(19, 19, 19),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 400, 0, 150),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        
        Create("UIStroke", ConfirmDialog, {
            Transparency = 0.5,
            Color = Color3.fromRGB(101, 101, 101)
        })
        
        Create("UICorner", ConfirmDialog, {CornerRadius = UDim.new(0, 5)})
        
        local DialogText = Create("TextLabel", ConfirmDialog, {
            BorderSizePixel = 0,
            TextSize = 20,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 400, 0, 50),
            Text = "Are you sure?",
            TextWrapped = true
        })
        
        local YesButton = Create("TextButton", ConfirmDialog, {
            BorderSizePixel = 0,
            TextSize = 25,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(5, 5, 5),
            Font = Enum.Font.GothamBold,
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(0, 150, 0, 50),
            Position = UDim2.new(0, 40, 1, -40),
            Text = "Yes"
        })
        
        Create("UICorner", YesButton)
        Create("UIStroke", YesButton, {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(39, 39, 39)
        })
        
        local NoButton = Create("TextButton", ConfirmDialog, {
            BorderSizePixel = 0,
            TextSize = 25,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(5, 5, 5),
            Font = Enum.Font.GothamBold,
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.new(0, 150, 0, 50),
            Position = UDim2.new(1, -40, 1, -40),
            Text = "No"
        })
        
        Create("UICorner", NoButton)
        Create("UIStroke", NoButton, {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(39, 39, 39)
        })
        
        YesButton.MouseButton1Down:Connect(function()
            CombinedUI:Destroy()
        end)
        
        NoButton.MouseButton1Down:Connect(function()
            ConfirmDialog:Destroy()
            DropdownZone.Visible = false
        end)
    end)
    
    -- Hàm tạo tab (kết hợp cả hai)
    function Window:MakeTab(tabConfig)
        local tabConfig = self:MakeConfig({
            Title = "New Tab",
            Icon = ""
        }, tabConfig or {})
        
        local TabDisable = Create("Frame", ScrollingTab, {
            Name = "TabDisable",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25)
        })
        
        local Choose = Create("Frame", TabDisable, {
            Name = "Choose",
            BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Theme"],
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 5),
            Size = UDim2.new(0, 4, 0, 15),
            Visible = false
        })
        
        Create("UICorner", Choose, {CornerRadius = UDim.new(1, 0)})
        
        local NameTab = Create("TextLabel", TabDisable, {
            Name = "NameTab",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -15, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabConfig.Title,
            TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
            TextSize = 12,
            TextTransparency = 0.300,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ClickTab = Create("TextButton", TabDisable, {
            Name = "Click_Tab",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false
        })
        
        -- Layout content
        local Layout = Create("ScrollingFrame", LayoutList, {
            Name = "Layout",
            BackgroundTransparency = 1,
            Selectable = false,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 1, 0),
            ScrollBarThickness = 0,
            LayoutOrder = AllLayouts
        })
        
        local UIPadding3 = Create("UIPadding", Layout, {
            PaddingBottom = UDim.new(0, 7),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 7)
        })
        
        local UIListLayout3 = Create("UIListLayout", Layout, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        -- Cập nhật kích thước
        self:UpdateScrolling(Layout, UIListLayout3)
        
        -- Chọn tab đầu tiên
        if AllLayouts == 0 then
            NameTab.TextTransparency = 0
            Choose.Visible = true
            UIPageLayout:JumpToIndex(0)
            TextLabel.Text = tabConfig.Title
        end
        
        -- Sự kiện click tab
        ClickTab.Activated:Connect(function()
            TextLabel.Text = tabConfig.Title
            for _, v in next, ScrollingTab:GetChildren() do
                if v:IsA("Frame") and v.Name == "TabDisable" then
                    self:TweenInstance(v.NameTab, 0.3, "TextTransparency", 0.3)
                    v.Choose.Visible = false
                end
            end
            self:TweenInstance(NameTab, 0.2, "TextTransparency", 0)
            UIPageLayout:JumpToIndex(Layout.LayoutOrder)
            Choose.Visible = true
        end)
        
        AllLayouts = AllLayouts + 1
        
        local Tab = {}
        
        -- Hàm thêm section (từ TeddyLib)
        function Tab:AddSection(sectionConfig)
            local sectionConfig = self:MakeConfig({
                Title = "New Section"
            }, sectionConfig or {})
            
            local Section = Create("Frame", Layout, {
                Name = "Section",
                BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                BackgroundTransparency = 0.98,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 55)
            })
            
            Create("UICorner", Section, {CornerRadius = UDim.new(0, 4)})
            
            Create("UIStroke", Section, {
                Color = self.Themes[ConfigWindow.Theme]["Color Stroke"],
                Thickness = 2,
                Transparency = 0.92
            })
            
            local NameSection = Create("Frame", Section, {
                Name = "NameSection",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            local Title = Create("TextLabel", NameSection, {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionConfig.Title,
                TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                TextSize = 14
            })
            
            local Line3 = Create("Frame", NameSection, {
                Name = "Line",
                BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2)
            })
            
            local UIGradient = Create("UIGradient", Line3, {
                Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0.00, self.Themes[ConfigWindow.Theme]["Color Hub 2"]),
                    ColorSequenceKeypoint.new(0.52, self.Themes[ConfigWindow.Theme]["Color Theme"]),
                    ColorSequenceKeypoint.new(1.00, self.Themes[ConfigWindow.Theme]["Color Hub 2"])
                }
            })
            
            local SectionList = Create("Frame", Section, {
                Name = "SectionList",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 1, -35)
            })
            
            local UIPadding4 = Create("UIPadding", SectionList, {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7)
            })
            
            local UIListLayout4 = Create("UIListLayout", SectionList, {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            
            -- Tự động cập nhật kích thước
            UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, UIListLayout4.AbsoluteContentSize.Y + 55)
            end)
            
            local SectionFunc = {}
            
            -- Thêm toggle (từ TeddyLib)
            function SectionFunc:AddToggle(toggleConfig)
                local toggleConfig = self:MakeConfig({
                    Title = "Toggle",
                    Description = "",
                    Default = false,
                    Callback = function() end
                }, toggleConfig or {})
                
                local Toggle = Create("Frame", SectionList, {
                    Name = "Toggle",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                Create("UICorner", Toggle, {CornerRadius = UDim.new(0, 3)})
                
                local Title2 = Create("TextLabel", Toggle, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = toggleConfig.Title,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleCheck = Create("Frame", Toggle, {
                    Name = "ToggleCheck",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 22)
                })
                
                Create("UICorner", ToggleCheck, {CornerRadius = UDim.new(1, 0)})
                
                local Check = Create("Frame", ToggleCheck, {
                    Name = "Check",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                
                Create("UICorner", Check, {CornerRadius = UDim.new(1, 0)})
                
                local ToggleClick = Create("TextButton", Toggle, {
                    Name = "Toggle_Click",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local Content = Create("TextLabel", Toggle, {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = toggleConfig.Description,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                
                -- Cập nhật nội dung
                self:UpdateContent(Content, Title2, Toggle)
                
                local ToggleFunc = { Value = toggleConfig.Default }
                
                function ToggleFunc:Set(Boolean)
                    if Boolean then
                        self:TweenInstance(ToggleCheck, 0.3, "BackgroundColor3", self.Themes[ConfigWindow.Theme]["Color Theme"])
                        self:TweenInstance(Check, 0.3, "Position", UDim2.new(0, 22, 0.5, 0))
                        self:TweenInstance(Check, 0.3, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
                    else
                        self:TweenInstance(ToggleCheck, 0.3, "BackgroundColor3", Color3.fromRGB(60, 60, 60))
                        self:TweenInstance(Check, 0.3, "BackgroundColor3", Color3.fromRGB(200, 200, 200))
                        self:TweenInstance(Check, 0.3, "Position", UDim2.new(0, 3, 0.5, 0))
                    end
                    self.Value = Boolean
                    toggleConfig.Callback(Boolean)
                end
                
                -- Khởi tạo trạng thái
                ToggleFunc:Set(ToggleFunc.Value)
                
                -- Sự kiện click
                ToggleClick.Activated:Connect(function()
                    ToggleFunc:Set(not ToggleFunc.Value)
                end)
                
                return ToggleFunc
            end
            
            -- Thêm button (từ TeddyLib)
            function SectionFunc:AddButton(buttonConfig)
                local buttonConfig = self:MakeConfig({
                    Title = "Button",
                    Description = "",
                    Callback = function() end
                }, buttonConfig or {})
                
                local Button = Create("Frame", SectionList, {
                    Name = "Button",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                Create("UICorner", Button, {CornerRadius = UDim.new(0, 3)})
                
                local Title3 = Create("TextLabel", Button, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = buttonConfig.Title,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ButtonClick = Create("TextButton", Button, {
                    Name = "Button_Click",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local Content2 = Create("TextLabel", Button, {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = buttonConfig.Description,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                
                local ImageLabel = Create("ImageLabel", Button, {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -35, 0.5, 0),
                    Size = UDim2.new(0, 24, 0, 24),
                    Image = "rbxassetid://85905776508942" -- Arrow icon
                })
                
                -- Cập nhật nội dung
                self:UpdateContent(Content2, Title3, Button)
                
                -- Sự kiện click
                ButtonClick.Activated:Connect(function()
                    Button.BackgroundTransparency = 0.97
                    buttonConfig.Callback()
                    self:TweenInstance(Button, 0.2, "BackgroundTransparency", 0.95)
                end)
                
                return Button
            end
            
            -- Thêm slider (từ TeddyLib)
            function SectionFunc:AddSlider(sliderConfig)
                local sliderConfig = self:MakeConfig({
                    Title = "Slider",
                    Description = "",
                    Min = 0,
                    Max = 100,
                    Default = 50,
                    Callback = function() end
                }, sliderConfig or {})
                
                local Slider = Create("Frame", SectionList, {
                    Name = "Slider",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                Create("UICorner", Slider, {CornerRadius = UDim.new(0, 3)})
                
                local Title4 = Create("TextLabel", Slider, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = sliderConfig.Title,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Content3 = Create("TextLabel", Slider, {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -160, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = sliderConfig.Description,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                
                local SliderFrame = Create("Frame", Slider, {
                    Name = "SliderFrame",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -140, 0.5, 0),
                    Size = UDim2.new(0, 130, 0, 8)
                })
                
                Create("UICorner", SliderFrame, {CornerRadius = UDim.new(1, 0)})
                
                local SliderDraggable = Create("Frame", SliderFrame, {
                    Name = "SliderDraggable",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Theme"],
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 20, 1, 0)
                })
                
                Create("UICorner", SliderDraggable, {CornerRadius = UDim.new(1, 0)})
                
                local Circle = Create("Frame", SliderDraggable, {
                    Name = "Circle",
                    AnchorPoint = Vector2.new(0, 0.1),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -6, 0, 0),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                
                Create("UICorner", Circle, {CornerRadius = UDim.new(1, 0)})
                
                local SliderValue = Create("TextBox", Slider, {
                    Name = "SliderValue",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Theme"],
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -185, 0.5, 0),
                    Size = UDim2.new(0, 35, 0, 20),
                    Font = Enum.Font.GothamBold,
                    PlaceholderText = "...",
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11
                })
                
                Create("UICorner", SliderValue, {CornerRadius = UDim.new(0, 2)})
                
                -- Cập nhật nội dung
                self:UpdateContent(Content3, Title4, Slider)
                
                local SliderFunc = { Value = sliderConfig.Default }
                local Dragging = false
                
                function SliderFunc:Set(Value)
                    Value = math.clamp(Value, sliderConfig.Min, sliderConfig.Max)
                    SliderFunc.Value = Value
                    SliderValue.Text = tostring(Value)
                    
                    local percentage = (Value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    self:TweenInstance(SliderDraggable, 0.3, "Size", UDim2.fromScale(percentage, 1))
                end
                
                -- Khởi tạo
                SliderFunc:Set(SliderFunc.Value)
                
                -- Sự kiện kéo
                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end)
                
                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                        sliderConfig.Callback(SliderFunc.Value)
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        local SizeScale = math.clamp(
                            (Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                        SliderFunc:Set(sliderConfig.Min + ((sliderConfig.Max - sliderConfig.Min) * SizeScale))
                    end
                end)
                
                -- Sự kiện nhập giá trị
                SliderValue.FocusLost:Connect(function()
                    if SliderValue.Text ~= "" then
                        SliderFunc:Set(tonumber(SliderValue.Text) or sliderConfig.Default)
                    end
                end)
                
                return SliderFunc
            end
            
            -- Thêm textbox (từ TeddyLib)
            function SectionFunc:AddTextBox(textboxConfig)
                local textboxConfig = self:MakeConfig({
                    Title = "Textbox",
                    Description = "",
                    PlaceHolder = "Enter text...",
                    Default = "",
                    Callback = function() end
                }, textboxConfig or {})
                
                local Input = Create("Frame", SectionList, {
                    Name = "Input",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                Create("UICorner", Input, {CornerRadius = UDim.new(0, 3)})
                
                local Title7 = Create("TextLabel", Input, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = textboxConfig.Title,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Content5 = Create("TextLabel", Input, {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -160, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = textboxConfig.Description,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                
                local TextboxFrame = Create("Frame", Input, {
                    Name = "TextboxFrame",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -140, 0.5, 0),
                    Size = UDim2.new(0, 130, 0, 28)
                })
                
                Create("UICorner", TextboxFrame, {CornerRadius = UDim.new(0, 3)})
                
                local RealTextBox = Create("TextBox", TextboxFrame, {
                    Name = "RealTextBox",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 35, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.GothamBold,
                    PlaceholderText = textboxConfig.PlaceHolder,
                    Text = textboxConfig.Default,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local WritingIcon = Create("ImageLabel", TextboxFrame, {
                    Name = "WritingIcon",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    Image = "rbxassetid://126409600467363" -- Pencil icon
                })
                
                -- Cập nhật nội dung
                self:UpdateContent(Content5, Title7, Input)
                
                -- Sự kiện nhập
                RealTextBox.FocusLost:Connect(function()
                    textboxConfig.Callback(RealTextBox.Text)
                end)
                
                -- Khởi tạo
                textboxConfig.Callback(RealTextBox.Text)
                
                return RealTextBox
            end
            
            -- Thêm paragraph (từ TeddyLib)
            function SectionFunc:AddParagraph(paraConfig)
                local paraConfig = self:MakeConfig({
                    Title = "Paragraph",
                    Content = ""
                }, paraConfig or {})
                
                local Paragraph = Create("Frame", SectionList, {
                    Name = "Paragraph",
                    BackgroundColor3 = self.Themes[ConfigWindow.Theme]["Color Hub 2"],
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 45)
                })
                
                Create("UICorner", Paragraph, {CornerRadius = UDim.new(0, 3)})
                
                local Title6 = Create("TextLabel", Paragraph, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 7),
                    Size = UDim2.new(1, -60, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = paraConfig.Title,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Content4 = Create("TextLabel", Paragraph, {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 22),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = paraConfig.Content,
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Dark Text"],
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                
                -- Cập nhật nội dung
                self:UpdateContent(Content4, Title6, Paragraph)
                
                local ParaFunc = {}
                
                function ParaFunc:SetTitle(args)
                    Title6.Text = args
                end
                
                function ParaFunc:SetDesc(args)
                    Content4.Text = args
                end
                
                return ParaFunc
            end
            
            -- Thêm separator (từ TeddyLib)
            function SectionFunc:AddSeperator(text)
                local Seperator = Create("Frame", SectionList, {
                    Name = "Seperator",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                local Title5 = Create("TextLabel", Seperator, {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = text or "Seperator",
                    TextColor3 = self.Themes[ConfigWindow.Theme]["Color Text"],
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            return SectionFunc
        end
        
        return Tab
    end
    
    -- Hàm thay đổi theme (từ redzlib)
    function Window:SetTheme(themeName)
        if self.Themes[themeName] then
            ConfigWindow.Theme = themeName
            
            -- Cập nhật màu sắc
            local theme = self.Themes[themeName]
            
            -- Cập nhật top gradient
            TopGradient.Color = theme["Color Hub 1"]
            
            -- Cập nhật màu đường line
            Line.BackgroundColor3 = theme["Color Theme"]
            
            -- Cập nhật màu chữ
            NameHub.TextColor3 = theme["Color Text"]
            Desc.TextColor3 = theme["Color Dark Text"]
            TextLabel.TextColor3 = theme["Color Text"]
            
            -- Cập nhật màu toggle button
            UIStroke.Color = theme["Color Theme"]
            ToggleButton.BackgroundColor3 = theme["Color Hub 2"]
            
            -- Cập nhật màu search
            SearchFrame.BackgroundColor3 = theme["Color Hub 2"]
            SearchBox.TextColor3 = theme["Color Text"]
            
            print("Theme changed to: " .. themeName)
        else
            warn("Theme not found: " .. themeName)
        end
    end
    
    return Window
end

return CombinedLibrary
