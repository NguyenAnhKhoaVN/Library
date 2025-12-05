-- NeoUI Library
-- Kết hợp từ FlurioreLib và Lunox
-- Version 1.0

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local NeoUI = {}

-- Utility Functions
function NeoUI:Tween(object, duration, easing, property, value)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[easing])
    local tween = TweenService:Create(object, tweenInfo, {[property] = value})
    tween:Play()
    return tween
end

function NeoUI:MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        self:Tween(frame, 0.1, "Quad", "Position", newPos)
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function NeoUI:CircleClick(button, x, y)
    task.spawn(function()
        button.ClipsDescendants = true
        local circle = Instance.new("ImageLabel")
        circle.Image = "rbxassetid://266543268"
        circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        circle.ImageTransparency = 0.9
        circle.BackgroundTransparency = 1
        circle.ZIndex = 10
        circle.Name = "Circle"
        circle.Parent = button
        
        local newX = x - circle.AbsolutePosition.X
        local newY = y - circle.AbsolutePosition.Y
        circle.Position = UDim2.new(0, newX, 0, newY)
        
        local size = 0
        if button.AbsoluteSize.X > button.AbsoluteSize.Y then
            size = button.AbsoluteSize.X * 1.5
        else
            size = button.AbsoluteSize.Y * 1.5
        end
        
        local time = 0.5
        circle:TweenSizeAndPosition(
            UDim2.new(0, size, 0, size),
            UDim2.new(0.5, -size/2, 0.5, -size/2),
            "Out", "Quad", time, false, nil
        )
        
        for i = 1, 10 do
            circle.ImageTransparency = circle.ImageTransparency + 0.01
            task.wait(time/10)
        end
        circle:Destroy()
    end)
end

-- Notification System
function NeoUI:Notify(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.Duration = config.Duration or 5
    config.Color = config.Color or Color3.fromRGB(0, 170, 255)
    
    local screenGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create notification container if it doesn't exist
    if not screenGui:FindFirstChild("NeoNotifyGui") then
        local notifyGui = Instance.new("ScreenGui")
        notifyGui.Name = "NeoNotifyGui"
        notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notifyGui.Parent = screenGui
        
        local notifyLayout = Instance.new("Frame")
        notifyLayout.Name = "NotifyLayout"
        notifyLayout.AnchorPoint = Vector2.new(1, 1)
        notifyLayout.BackgroundTransparency = 1
        notifyLayout.Position = UDim2.new(1, -20, 1, -20)
        notifyLayout.Size = UDim2.new(0, 350, 0, 500)
        notifyLayout.Parent = notifyGui
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        listLayout.Parent = notifyLayout
    end
    
    local notifyLayout = screenGui.NeoNotifyGui.NotifyLayout
    
    -- Create notification frame
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Name = "NotifyFrame"
    notifyFrame.BackgroundTransparency = 1
    notifyFrame.Size = UDim2.new(1, 0, 0, 0)
    notifyFrame.LayoutOrder = #notifyLayout:GetChildren()
    notifyFrame.Parent = notifyLayout
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Size = UDim2.new(1, 0, 0, 0)
    mainFrame.Position = UDim2.new(0, 400, 0, 0)
    mainFrame.Parent = notifyFrame
    
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = mainFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(50, 50, 50)
    uiStroke.Thickness = 1
    uiStroke.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = config.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = config.Color
    titleLabel.TextSize = 14
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 12)
    titleLabel.Size = UDim2.new(1, -30, 0, 18)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Text = config.Content
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 13
    contentLabel.BackgroundTransparency = 1
    contentLabel.Position = UDim2.new(0, 15, 0, 35)
    contentLabel.Size = UDim2.new(1, -30, 0, 20)
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = mainFrame
    
    -- Calculate size
    contentLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        local height = math.max(contentLabel.TextBounds.Y + 55, 80)
        mainFrame.Size = UDim2.new(1, 0, 0, height)
        notifyFrame.Size = UDim2.new(1, 0, 0, height)
    end)
    
    -- Animate in
    self:Tween(mainFrame, 0.3, "Back", "Position", UDim2.new(0, 0, 0, 0))
    
    -- Auto remove after duration
    task.delay(config.Duration, function()
        self:Tween(mainFrame, 0.3, "Back", "Position", UDim2.new(0, 400, 0, 0))
        task.wait(0.3)
        notifyFrame:Destroy()
    end)
    
    return {
        Close = function()
            self:Tween(mainFrame, 0.3, "Back", "Position", UDim2.new(0, 400, 0, 0))
            task.wait(0.3)
            notifyFrame:Destroy()
        end
    }
end

-- Window System
function NeoUI:Window(config)
    config = config or {}
    config.Name = config.Name or "NeoUI Window"
    config.Description = config.Description or "Made with NeoUI Library"
    config.Size = config.Size or UDim2.new(0, 600, 0, 450)
    config.Color = config.Color or Color3.fromRGB(0, 170, 255)
    config.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    mainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainWindow.BackgroundTransparency = 0.05
    mainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainWindow.Size = config.Size
    mainWindow.Parent = screenGui
    
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = mainWindow
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(40, 40, 40)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainWindow
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.Parent = mainWindow
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = config.Name
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Text = config.Description
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextColor3 = config.Color
    descLabel.TextSize = 12
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, 15, 0, 20)
    descLabel.Size = UDim2.new(1, -100, 1, -20)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = topBar
    
    -- Control Buttons
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.TextSize = 20
    closeButton.BackgroundTransparency = 1
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.Position = UDim2.new(1, -10, 0.5, 0)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Parent = topBar
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "Minimize"
    minimizeButton.Text = "−"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.TextSize = 20
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    minimizeButton.Position = UDim2.new(1, -45, 0.5, 0)
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Parent = topBar
    
    -- Tab System
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.Size = UDim2.new(0, 150, 1, -60)
    tabContainer.Parent = mainWindow
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local scrollTabs = Instance.new("ScrollingFrame")
    scrollTabs.Name = "ScrollTabs"
    scrollTabs.BackgroundTransparency = 1
    scrollTabs.Size = UDim2.new(1, 0, 1, -50)
    scrollTabs.ScrollBarThickness = 0
    scrollTabs.Parent = tabContainer
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = scrollTabs
    
    -- Content Area
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    contentContainer.Position = UDim2.new(0, 170, 0, 50)
    contentContainer.Size = UDim2.new(1, -180, 1, -60)
    contentContainer.Parent = mainWindow
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentContainer
    
    local contentPages = Instance.new("Folder")
    contentPages.Name = "Pages"
    contentPages.Parent = contentContainer
    
    local pageLayout = Instance.new("UIPageLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.TweenTime = 0.3
    pageLayout.EasingStyle = Enum.EasingStyle.Quad
    pageLayout.EasingDirection = Enum.EasingDirection.InOut
    pageLayout.Parent = contentPages
    
    -- Make draggable
    self:MakeDraggable(mainWindow, topBar)
    
    -- Button Events
    closeButton.MouseButton1Click:Connect(function()
        self:CircleClick(closeButton, Mouse.X, Mouse.Y)
        screenGui:Destroy()
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        self:CircleClick(minimizeButton, Mouse.X, Mouse.Y)
        mainWindow.Visible = not mainWindow.Visible
    end)
    
    -- Toggle with key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == config.ToggleKey then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)
    
    local windowAPI = {}
    local tabCount = 0
    
    function windowAPI:Tab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or ""
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton"
        tabButton.Text = ""
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabButton.BackgroundTransparency = 0.5
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.LayoutOrder = tabCount
        tabButton.Parent = scrollTabs
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        local tabName = Instance.new("TextLabel")
        tabName.Name = "TabName"
        tabName.Text = tabConfig.Name
        tabName.Font = Enum.Font.Gotham
        tabName.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabName.TextSize = 14
        tabName.BackgroundTransparency = 1
        tabName.Position = UDim2.new(0, tabConfig.Icon ~= "" and 35 or 10, 0, 0)
        tabName.Size = UDim2.new(1, -(tabConfig.Icon ~= "" and 45 or 20), 1, 0)
        tabName.TextXAlignment = Enum.TextXAlignment.Left
        tabName.Parent = tabButton
        
        if tabConfig.Icon ~= "" then
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Name = "TabIcon"
            tabIcon.Image = tabConfig.Icon
            tabIcon.BackgroundTransparency = 1
            tabIcon.Position = UDim2.new(0, 10, 0.5, -12)
            tabIcon.Size = UDim2.new(0, 24, 0, 24)
            tabIcon.Parent = tabButton
        end
        
        -- Create content page
        local contentPage = Instance.new("ScrollingFrame")
        contentPage.Name = "Page"
        contentPage.BackgroundTransparency = 1
        contentPage.Size = UDim2.new(1, 0, 1, 0)
        contentPage.ScrollBarThickness = 0
        contentPage.LayoutOrder = tabCount
        contentPage.Parent = contentPages
        
        local pageListLayout = Instance.new("UIListLayout")
        pageListLayout.Padding = UDim.new(0, 10)
        pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageListLayout.Parent = contentPage
        
        -- Update scroll size
        RunService.Heartbeat:Connect(function()
            contentPage.CanvasSize = UDim2.new(0, 0, 0, pageListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Set first tab as active
        if tabCount == 0 then
            tabButton.BackgroundTransparency = 0
            tabName.TextColor3 = config.Color
            pageLayout:JumpToIndex(0)
        end
        
        -- Tab button click
        tabButton.MouseButton1Click:Connect(function()
            self:CircleClick(tabButton, Mouse.X, Mouse.Y)
            
            -- Reset all tabs
            for _, tab in ipairs(scrollTabs:GetChildren()) do
                if tab:IsA("TextButton") then
                    self:Tween(tab, 0.2, "Quad", "BackgroundTransparency", 0.5)
                    tab.TabName.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            
            -- Highlight active tab
            self:Tween(tabButton, 0.2, "Quad", "BackgroundTransparency", 0)
            tabName.TextColor3 = config.Color
            
            -- Switch page
            pageLayout:JumpToIndex(tabCount)
        end)
        
        local tabAPI = {}
        local sectionCount = 0
        
        function tabAPI:Section(sectionConfig)
            sectionConfig = sectionConfig or {}
            sectionConfig.Name = sectionConfig.Name or "Section"
            sectionConfig.Open = sectionConfig.Open or true
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section"
            sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            sectionFrame.BackgroundTransparency = 0.2
            sectionFrame.Size = UDim2.new(1, 0, 0, 40)
            sectionFrame.LayoutOrder = sectionCount
            sectionFrame.ClipsDescendants = true
            sectionFrame.Parent = contentPage
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame
            
            local sectionHeader = Instance.new("TextButton")
            sectionHeader.Name = "Header"
            sectionHeader.Text = ""
            sectionHeader.BackgroundTransparency = 1
            sectionHeader.Size = UDim2.new(1, 0, 0, 40)
            sectionHeader.Parent = sectionFrame
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Text = sectionConfig.Name
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
            sectionTitle.TextSize = 14
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Position = UDim2.new(0, 15, 0, 0)
            sectionTitle.Size = UDim2.new(1, -40, 1, 0)
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionFrame
            
            local arrowIcon = Instance.new("ImageLabel")
            arrowIcon.Name = "Arrow"
            arrowIcon.Image = "rbxassetid://16851841101"
            arrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
            arrowIcon.Rotation = sectionConfig.Open and 90 or -90
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
            arrowIcon.Position = UDim2.new(1, -10, 0.5, 0)
            arrowIcon.Size = UDim2.new(0, 20, 0, 20)
            arrowIcon.Parent = sectionFrame
            
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.BackgroundTransparency = 1
            sectionContent.Position = UDim2.new(0, 0, 0, 45)
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Parent = sectionFrame
            
            local contentList = Instance.new("UIListLayout")
            contentList.Padding = UDim.new(0, 8)
            contentList.SortOrder = Enum.SortOrder.LayoutOrder
            contentList.Parent = sectionContent
            
            local function updateSectionSize()
                if sectionConfig.Open then
                    sectionContent.Size = UDim2.new(1, 0, 0, contentList.AbsoluteContentSize.Y)
                    sectionFrame.Size = UDim2.new(1, 0, 0, contentList.AbsoluteContentSize.Y + 50)
                else
                    sectionFrame.Size = UDim2.new(1, 0, 0, 40)
                end
            end
            
            contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
            
            if sectionConfig.Open then
                updateSectionSize()
            end
            
            sectionHeader.MouseButton1Click:Connect(function()
                sectionConfig.Open = not sectionConfig.Open
                self:Tween(arrowIcon, 0.2, "Quad", "Rotation", sectionConfig.Open and 90 or -90)
                updateSectionSize()
            end)
            
            local sectionAPI = {}
            local itemCount = 0
            
            function sectionAPI:Button(buttonConfig)
                buttonConfig = buttonConfig or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Callback = buttonConfig.Callback or function() end
                
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Name = "Button"
                buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                buttonFrame.BackgroundTransparency = 0.3
                buttonFrame.Size = UDim2.new(1, 0, 0, 40)
                buttonFrame.LayoutOrder = itemCount
                buttonFrame.Parent = sectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = buttonFrame
                
                local buttonText = Instance.new("TextLabel")
                buttonText.Name = "Text"
                buttonText.Text = buttonConfig.Name
                buttonText.Font = Enum.Font.Gotham
                buttonText.TextColor3 = Color3.fromRGB(220, 220, 220)
                buttonText.TextSize = 13
                buttonText.BackgroundTransparency = 1
                buttonText.Position = UDim2.new(0, 15, 0, 0)
                buttonText.Size = UDim2.new(1, -30, 1, 0)
                buttonText.TextXAlignment = Enum.TextXAlignment.Left
                buttonText.Parent = buttonFrame
                
                local buttonBtn = Instance.new("TextButton")
                buttonBtn.Name = "Click"
                buttonBtn.Text = ""
                buttonBtn.BackgroundTransparency = 1
                buttonBtn.Size = UDim2.new(1, 0, 1, 0)
                buttonBtn.Parent = buttonFrame
                
                buttonBtn.MouseButton1Click:Connect(function()
                    self:CircleClick(buttonBtn, Mouse.X, Mouse.Y)
                    buttonConfig.Callback()
                end)
                
                buttonBtn.MouseEnter:Connect(function()
                    self:Tween(buttonFrame, 0.2, "Quad", "BackgroundTransparency", 0.1)
                end)
                
                buttonBtn.MouseLeave:Connect(function()
                    self:Tween(buttonFrame, 0.2, "Quad", "BackgroundTransparency", 0.3)
                end)
                
                itemCount = itemCount + 1
                
                return {
                    SetName = function(name)
                        buttonText.Text = name
                    end
                }
            end
            
            function sectionAPI:Toggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Callback = toggleConfig.Callback or function() end
                
                local toggleState = toggleConfig.Default
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle"
                toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                toggleFrame.BackgroundTransparency = 0.3
                toggleFrame.Size = UDim2.new(1, 0, 0, 40)
                toggleFrame.LayoutOrder = itemCount
                toggleFrame.Parent = sectionContent
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 4)
                toggleCorner.Parent = toggleFrame
                
                local toggleText = Instance.new("TextLabel")
                toggleText.Name = "Text"
                toggleText.Text = toggleConfig.Name
                toggleText.Font = Enum.Font.Gotham
                toggleText.TextColor3 = Color3.fromRGB(220, 220, 220)
                toggleText.TextSize = 13
                toggleText.BackgroundTransparency = 1
                toggleText.Position = UDim2.new(0, 15, 0, 0)
                toggleText.Size = UDim2.new(1, -80, 1, 0)
                toggleText.TextXAlignment = Enum.TextXAlignment.Left
                toggleText.Parent = toggleFrame
                
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "Switch"
                toggleSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                toggleSwitch.AnchorPoint = Vector2.new(1, 0.5)
                toggleSwitch.Position = UDim2.new(1, -15, 0.5, 0)
                toggleSwitch.Size = UDim2.new(0, 50, 0, 25)
                toggleSwitch.Parent = toggleFrame
                
                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(1, 0)
                switchCorner.Parent = toggleSwitch
                
                local toggleCircle = Instance.new("Frame")
                toggleCircle.Name = "Circle"
                toggleCircle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
                toggleCircle.Position = toggleState and UDim2.new(0, 26, 0, 3) or UDim2.new(0, 3, 0, 3)
                toggleCircle.Size = UDim2.new(0, 19, 0, 19)
                toggleCircle.Parent = toggleSwitch
                
                local circleCorner = Instance.new("UICorner")
                circleCorner.CornerRadius = UDim.new(1, 0)
                circleCorner.Parent = toggleCircle
                
                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Name = "Click"
                toggleBtn.Text = ""
                toggleBtn.BackgroundTransparency = 1
                toggleBtn.Size = UDim2.new(1, 0, 1, 0)
                toggleBtn.Parent = toggleFrame
                
                local function updateToggle()
                    if toggleState then
                        self:Tween(toggleSwitch, 0.2, "Quad", "BackgroundColor3", config.Color)
                        self:Tween(toggleCircle, 0.2, "Quad", "Position", UDim2.new(0, 26, 0, 3))
                    else
                        self:Tween(toggleSwitch, 0.2, "Quad", "BackgroundColor3", Color3.fromRGB(60, 60, 60))
                        self:Tween(toggleCircle, 0.2, "Quad", "Position", UDim2.new(0, 3, 0, 3))
                    end
                    toggleConfig.Callback(toggleState)
                end
                
                toggleBtn.MouseButton1Click:Connect(function()
                    self:CircleClick(toggleBtn, Mouse.X, Mouse.Y)
                    toggleState = not toggleState
                    updateToggle()
                end)
                
                toggleBtn.MouseEnter:Connect(function()
                    self:Tween(toggleFrame, 0.2, "Quad", "BackgroundTransparency", 0.1)
                end)
                
                toggleBtn.MouseLeave:Connect(function()
                    self:Tween(toggleFrame, 0.2, "Quad", "BackgroundTransparency", 0.3)
                end)
                
                updateToggle()
                itemCount = itemCount + 1
                
                return {
                    SetValue = function(value)
                        toggleState = value
                        updateToggle()
                    end,
                    GetValue = function()
                        return toggleState
                    end
                }
            end
            
            function sectionAPI:Slider(sliderConfig)
                sliderConfig = sliderConfig or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or 50
                sliderConfig.Callback = sliderConfig.Callback or function() end
                
                local sliderValue = sliderConfig.Default
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "Slider"
                sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                sliderFrame.BackgroundTransparency = 0.3
                sliderFrame.Size = UDim2.new(1, 0, 0, 60)
                sliderFrame.LayoutOrder = itemCount
                sliderFrame.Parent = sectionContent
                
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 4)
                sliderCorner.Parent = sliderFrame
                
                local sliderText = Instance.new("TextLabel")
                sliderText.Name = "Text"
                sliderText.Text = sliderConfig.Name
                sliderText.Font = Enum.Font.Gotham
                sliderText.TextColor3 = Color3.fromRGB(220, 220, 220)
                sliderText.TextSize = 13
                sliderText.BackgroundTransparency = 1
                sliderText.Position = UDim2.new(0, 15, 0, 8)
                sliderText.Size = UDim2.new(1, -30, 0, 15)
                sliderText.TextXAlignment = Enum.TextXAlignment.Left
                sliderText.Parent = sliderFrame
                
                local valueText = Instance.new("TextLabel")
                valueText.Name = "Value"
                valueText.Text = tostring(sliderValue)
                valueText.Font = Enum.Font.GothamBold
                valueText.TextColor3 = config.Color
                valueText.TextSize = 12
                valueText.BackgroundTransparency = 1
                valueText.AnchorPoint = Vector2.new(1, 0)
                valueText.Position = UDim2.new(1, -15, 0, 8)
                valueText.Size = UDim2.new(0, 50, 0, 15)
                valueText.TextXAlignment = Enum.TextXAlignment.Right
                valueText.Parent = sliderFrame
                
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                sliderTrack.Position = UDim2.new(0, 15, 0, 35)
                sliderTrack.Size = UDim2.new(1, -30, 0, 5)
                sliderTrack.Parent = sliderFrame
                
                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(1, 0)
                trackCorner.Parent = sliderTrack
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.BackgroundColor3 = config.Color
                sliderFill.Size = UDim2.new((sliderValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
                sliderFill.Parent = sliderTrack
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = sliderFill
                
                local sliderBtn = Instance.new("TextButton")
                sliderBtn.Name = "Click"
                sliderBtn.Text = ""
                sliderBtn.BackgroundTransparency = 1
                sliderBtn.Size = UDim2.new(1, 0, 1, 0)
                sliderBtn.Parent = sliderFrame
                
                local dragging = false
                
                local function updateSlider(value)
                    value = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                    sliderValue = value
                    valueText.Text = tostring(math.floor(value))
                    sliderFill.Size = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
                    sliderConfig.Callback(sliderValue)
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local pos = input.Position.X - sliderTrack.AbsolutePosition.X
                        local value = sliderConfig.Min + ((pos / sliderTrack.AbsoluteSize.X) * (sliderConfig.Max - sliderConfig.Min))
                        updateSlider(value)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = input.Position.X - sliderTrack.AbsolutePosition.X
                        local value = sliderConfig.Min + ((pos / sliderTrack.AbsoluteSize.X) * (sliderConfig.Max - sliderConfig.Min))
                        updateSlider(value)
                    end
                end)
                
                updateSlider(sliderValue)
                itemCount = itemCount + 1
                
                return {
                    SetValue = function(value)
                        updateSlider(value)
                    end,
                    GetValue = function()
                        return sliderValue
                    end
                }
            end
            
            function sectionAPI:Dropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {"Option 1", "Option 2"}
                dropdownConfig.Default = dropdownConfig.Default or dropdownConfig.Options[1]
                dropdownConfig.Multi = dropdownConfig.Multi or false
                dropdownConfig.Callback = dropdownConfig.Callback or function() end
                
                local selected = dropdownConfig.Multi and {dropdownConfig.Default} or dropdownConfig.Default
                local isOpen = false
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "Dropdown"
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                dropdownFrame.BackgroundTransparency = 0.3
                dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
                dropdownFrame.LayoutOrder = itemCount
                dropdownFrame.Parent = sectionContent
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 4)
                dropdownCorner.Parent = dropdownFrame
                
                local dropdownText = Instance.new("TextLabel")
                dropdownText.Name = "Text"
                dropdownText.Text = dropdownConfig.Name
                dropdownText.Font = Enum.Font.Gotham
                dropdownText.TextColor3 = Color3.fromRGB(220, 220, 220)
                dropdownText.TextSize = 13
                dropdownText.BackgroundTransparency = 1
                dropdownText.Position = UDim2.new(0, 15, 0, 0)
                dropdownText.Size = UDim2.new(1, -80, 1, 0)
                dropdownText.TextXAlignment = Enum.TextXAlignment.Left
                dropdownText.Parent = dropdownFrame
                
                local selectedText = Instance.new("TextLabel")
                selectedText.Name = "Selected"
                selectedText.Text = dropdownConfig.Multi and table.concat(selected, ", ") or selected
                selectedText.Font = Enum.Font.Gotham
                selectedText.TextColor3 = Color3.fromRGB(180, 180, 180)
                selectedText.TextSize = 12
                selectedText.BackgroundTransparency = 1
                selectedText.AnchorPoint = Vector2.new(1, 0.5)
                selectedText.Position = UDim2.new(1, -25, 0.5, 0)
                selectedText.Size = UDim2.new(0, 100, 1, 0)
                selectedText.TextXAlignment = Enum.TextXAlignment.Right
                selectedText.TextTruncate = Enum.TextTruncate.AtEnd
                selectedText.Parent = dropdownFrame
                
                local arrowIcon = Instance.new("ImageLabel")
                arrowIcon.Name = "Arrow"
                arrowIcon.Image = "rbxassetid://16851841101"
                arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                arrowIcon.Rotation = -90
                arrowIcon.BackgroundTransparency = 1
                arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
                arrowIcon.Position = UDim2.new(1, -5, 0.5, 0)
                arrowIcon.Size = UDim2.new(0, 15, 0, 15)
                arrowIcon.Parent = dropdownFrame
                
                local dropdownBtn = Instance.new("TextButton")
                dropdownBtn.Name = "Click"
                dropdownBtn.Text = ""
                dropdownBtn.BackgroundTransparency = 1
                dropdownBtn.Size = UDim2.new(1, 0, 1, 0)
                dropdownBtn.Parent = dropdownFrame
                
                -- Dropdown menu (created when needed)
                local dropdownMenu
                
                local function updateSelection()
                    if dropdownConfig.Multi then
                        selectedText.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                    else
                        selectedText.Text = selected
                    end
                    dropdownConfig.Callback(selected)
                end
                
                local function createMenu()
                    if dropdownMenu then dropdownMenu:Destroy() end
                    
                    dropdownMenu = Instance.new("Frame")
                    dropdownMenu.Name = "DropdownMenu"
                    dropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    dropdownMenu.BackgroundTransparency = 0.1
                    dropdownMenu.Position = UDim2.new(0, 0, 0, 45)
                    dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
                    dropdownMenu.ClipsDescendants = true
                    dropdownMenu.Parent = dropdownFrame
                    
                    local menuCorner = Instance.new("UICorner")
                    menuCorner.CornerRadius = UDim.new(0, 4)
                    menuCorner.Parent = dropdownMenu
                    
                    local menuList = Instance.new("UIListLayout")
                    menuList.Padding = UDim.new(0, 2)
                    menuList.SortOrder = Enum.SortOrder.LayoutOrder
                    menuList.Parent = dropdownMenu
                    
                    for _, option in ipairs(dropdownConfig.Options) do
                        local optionBtn = Instance.new("TextButton")
                        optionBtn.Name = "Option"
                        optionBtn.Text = ""
                        optionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        optionBtn.BackgroundTransparency = 0.5
                        optionBtn.Size = UDim2.new(1, 0, 0, 30)
                        optionBtn.LayoutOrder = _
                        optionBtn.Parent = dropdownMenu
                        
                        local optionCorner = Instance.new("UICorner")
                        optionCorner.CornerRadius = UDim.new(0, 4)
                        optionCorner.Parent = optionBtn
                        
                        local optionText = Instance.new("TextLabel")
                        optionText.Name = "Text"
                        optionText.Text = option
                        optionText.Font = Enum.Font.Gotham
                        optionText.TextColor3 = Color3.fromRGB(220, 220, 220)
                        optionText.TextSize = 12
                        optionText.BackgroundTransparency = 1
                        optionText.Position = UDim2.new(0, 10, 0, 0)
                        optionText.Size = UDim2.new(1, -20, 1, 0)
                        optionText.TextXAlignment = Enum.TextXAlignment.Left
                        optionText.Parent = optionBtn
                        
                        local function isSelected()
                            if dropdownConfig.Multi then
                                return table.find(selected, option)
                            else
                                return selected == option
                            end
                        end
                        
                        if isSelected() then
                            optionBtn.BackgroundColor3 = config.Color
                            optionBtn.BackgroundTransparency = 0.3
                        end
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            if dropdownConfig.Multi then
                                if table.find(selected, option) then
                                    table.remove(selected, table.find(selected, option))
                                else
                                    table.insert(selected, option)
                                end
                            else
                                selected = option
                            end
                            
                            updateSelection()
                            createMenu() -- Refresh menu
                        end)
                    end
                    
                    menuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        dropdownMenu.Size = UDim2.new(1, 0, 0, menuList.AbsoluteContentSize.Y + 5)
                    end)
                end
                
                dropdownBtn.MouseButton1Click:Connect(function()
                    self:CircleClick(dropdownBtn, Mouse.X, Mouse.Y)
                    isOpen = not isOpen
                    
                    if isOpen then
                        createMenu()
                        self:Tween(arrowIcon, 0.2, "Quad", "Rotation", 90)
                        self:Tween(dropdownMenu, 0.2, "Quad", "Size", UDim2.new(1, 0, 0, dropdownMenu.Size.Y.Offset))
                    else
                        self:Tween(arrowIcon, 0.2, "Quad", "Rotation", -90)
                        if dropdownMenu then
                            self:Tween(dropdownMenu, 0.2, "Quad", "Size", UDim2.new(1, 0, 0, 0))
                            task.wait(0.2)
                            dropdownMenu:Destroy()
                        end
                    end
                end)
                
                updateSelection()
                itemCount = itemCount + 1
                
                return {
                    SetOptions = function(options)
                        dropdownConfig.Options = options
                        if isOpen then createMenu() end
                    end,
                    GetSelection = function()
                        return selected
                    end,
                    SetSelection = function(selection)
                        selected = selection
                        updateSelection()
                        if isOpen then createMenu() end
                    end
                }
            end
            
            function sectionAPI:Label(labelConfig)
                labelConfig = labelConfig or {}
                labelConfig.Text = labelConfig.Text or "Label"
                labelConfig.Color = labelConfig.Color or Color3.fromRGB(220, 220, 220)
                
                local labelFrame = Instance.new("Frame")
                labelFrame.Name = "Label"
                labelFrame.BackgroundTransparency = 1
                labelFrame.Size = UDim2.new(1, 0, 0, 30)
                labelFrame.LayoutOrder = itemCount
                labelFrame.Parent = sectionContent
                
                local labelText = Instance.new("TextLabel")
                labelText.Name = "Text"
                labelText.Text = labelConfig.Text
                labelText.Font = Enum.Font.Gotham
                labelText.TextColor3 = labelConfig.Color
                labelText.TextSize = 13
                labelText.BackgroundTransparency = 1
                labelText.Position = UDim2.new(0, 10, 0, 0)
                labelText.Size = UDim2.new(1, -20, 1, 0)
                labelText.TextXAlignment = Enum.TextXAlignment.Left
                labelText.Parent = labelFrame
                
                itemCount = itemCount + 1
                
                return {
                    SetText = function(text)
                        labelText.Text = text
                    end,
                    SetColor = function(color)
                        labelText.TextColor3 = color
                    end
                }
            end
            
            sectionCount = sectionCount + 1
            return sectionAPI
        end
        
        tabCount = tabCount + 1
        return tabAPI
    end
    
    function windowAPI:Destroy()
        screenGui:Destroy()
    end
    
    return windowAPI
end

return NeoUI
