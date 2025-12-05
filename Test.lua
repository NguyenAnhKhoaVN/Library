-- Lunox UI Library - Fixed & Beautified Version
-- By ! xHoang (Fixed by Assistant)

local Lunox = {
    Stepped = game:GetService("RunService").Stepped
}

-- ==================== UTILITY FUNCTIONS ====================
function Lunox:Tween(target, duration, easingStyle, property, goal)
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[easingStyle])
    local tween = tweenService:Create(target, tweenInfo, {[property] = goal})
    tween:Play()
    return tween
end

function Lunox:MouseEvent(guiObject, onEnter, onLeave)
    guiObject.MouseEnter:Connect(onEnter)
    guiObject.MouseLeave:Connect(onLeave)
end

function Lunox:MakeDraggable(frame, dragHandle)
    local isDragging = false
    local dragInput, startPos, startDragPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            startDragPos = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - startDragPos
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            self:Tween(frame, 0.1, "Quad", "Position", newPos)
        end
    end)
end

function Lunox:CustomSize(frame)
    local isResizing = false
    local originalMouseIcon = game.Players.LocalPlayer:GetMouse().Icon
    local resizeInput, startMousePos, startSize
    
    local minWidth = frame.Size.X.Offset - 100
    local minHeight = minWidth
    
    local resizeHandle = Instance.new("Frame")
    local resizeIcon = Instance.new("ImageLabel")
    
    -- Create resize handle
    resizeHandle.Parent = frame
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.Size = UDim2.new(0, 50, 0, 50)
    resizeHandle.Name = "ResizeHandle"
    
    resizeIcon.Parent = resizeHandle
    resizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Position = UDim2.new(0.5, -13, 0.5, -13)
    resizeIcon.Size = UDim2.new(0, 100, 0, 100)
    resizeIcon.Image = "rbxassetid://120997033468887"
    resizeIcon.ImageTransparency = 0.8
    
    -- Mouse events for resize handle
    self:MouseEvent(resizeIcon,
        function()
            resizeIcon.ImageTransparency = 0.5
            game.Players.LocalPlayer:GetMouse().Icon = "rbxassetid://97880490001888"
        end,
        function()
            game.Players.LocalPlayer:GetMouse().Icon = originalMouseIcon
            resizeIcon.ImageTransparency = 0.8
        end
    )
    
    -- Resize logic
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            startMousePos = input.Position
            startSize = frame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                end
            end)
        end
    end)
    
    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            resizeInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == resizeInput and isResizing then
            local delta = input.Position - startMousePos
            local newWidth = math.max(startSize.X.Offset + delta.X, minWidth)
            local newHeight = math.max(startSize.Y.Offset + delta.Y, minHeight)
            
            self:Tween(frame, 0.2, "Quad", "Size", UDim2.new(0, newWidth, 0, newHeight))
        end
    end)
end

function Lunox:UpdateScroll(scrollFrame, uiListLayout)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
end

-- ==================== NOTIFICATION SYSTEM ====================
function Lunox:NewNotify(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.Duration = config.Duration or 5
    
    task.spawn(function()
        -- Ensure notification GUI exists
        if not game.CoreGui:FindFirstChild("NotifyGui") then
            local notifyGui = Instance.new("ScreenGui")
            notifyGui.Name = "NotifyGui"
            notifyGui.Parent = game.CoreGui
            notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            local layout = Instance.new("Frame")
            layout.Name = "NotifyLayout"
            layout.Parent = notifyGui
            layout.BackgroundTransparency = 1
            layout.Position = UDim2.new(1, -350, 1, -100)
            layout.Size = UDim2.new(0, 300, 1, -900)
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Name = "List"
            listLayout.Padding = UDim.new(0, 5)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            listLayout.Parent = layout
        end
        
        local notifyGui = game.CoreGui:WaitForChild("NotifyGui")
        local notifyLayout = notifyGui:WaitForChild("NotifyLayout")
        
        -- Create notification frame
        local notifyFrame = Instance.new("Frame")
        local mainBackground = Instance.new("ImageLabel")
        local titleLabel = Instance.new("TextLabel")
        local closeButton = Instance.new("ImageButton")
        local descLabel = Instance.new("TextLabel")
        local uiStroke = Instance.new("ImageLabel")
        
        -- Configure notification frame
        notifyFrame.Name = "NotifyFrame"
        notifyFrame.Parent = notifyLayout
        notifyFrame.BackgroundTransparency = 1
        notifyFrame.Size = UDim2.new(1, 0, 0, 80)
        
        -- Main background
        mainBackground.Name = "Main"
        mainBackground.Parent = notifyFrame
        mainBackground.BackgroundTransparency = 1
        mainBackground.Size = UDim2.new(1, 0, 1, 0)
        mainBackground.Position = UDim2.new(0, 500, 0, 0)
        mainBackground.Image = "rbxassetid://80999662900595"
        mainBackground.ImageColor3 = Color3.fromRGB(16, 16, 16)
        mainBackground.ImageTransparency = 0.1
        mainBackground.ScaleType = Enum.ScaleType.Slice
        mainBackground.SliceCenter = Rect.new(256, 256, 256, 256)
        mainBackground.SliceScale = 0.055
        
        -- Title
        titleLabel.Name = "Title"
        titleLabel.Parent = mainBackground
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 14, 0, 11)
        titleLabel.Size = UDim2.new(1, -30, 0, 18)
        titleLabel.Font = Enum.Font.Arial
        titleLabel.Text = config.Title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Close button
        closeButton.Name = "Close"
        closeButton.Parent = mainBackground
        closeButton.BackgroundTransparency = 1
        closeButton.Position = UDim2.new(1, -27, 0, 8)
        closeButton.Size = UDim2.new(0, 18, 0, 18)
        closeButton.Image = "rbxassetid://105957381820378"
        closeButton.ImageRectOffset = Vector2.new(480, 0)
        closeButton.ImageRectSize = Vector2.new(96, 96)
        closeButton.MouseButton1Click:Connect(function()
            self:Tween(mainBackground, 0.3, "Quad", "Position", UDim2.new(0, 500, 0, 0))
            task.wait(0.3)
            notifyFrame:Destroy()
        end)
        
        -- Description
        descLabel.Name = "Desc"
        descLabel.Parent = mainBackground
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 14, 0, 29)
        descLabel.Size = UDim2.new(1, -30, 1, -29)
        descLabel.Font = Enum.Font.Arial
        descLabel.Text = config.Content
        descLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        descLabel.TextSize = 14
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.RichText = true
        
        -- Auto-size notification based on content
        if descLabel.Text ~= "" then
            self.Stepped:Connect(function()
                notifyFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 30, 68))
            end)
        end
        
        -- UI Stroke
        uiStroke.Name = "UIStroke"
        uiStroke.Parent = mainBackground
        uiStroke.BackgroundTransparency = 1
        uiStroke.Size = UDim2.new(1, 0, 1, 0)
        uiStroke.Image = "rbxassetid://117788349049947"
        uiStroke.ImageTransparency = 0.7
        uiStroke.ScaleType = Enum.ScaleType.Slice
        uiStroke.SliceCenter = Rect.new(256, 256, 256, 256)
        uiStroke.SliceScale = 0.05
        
        -- Animation
        self:Tween(mainBackground, 0.3, "Quad", "Position", UDim2.new(0, 0, 0, 0))
        task.wait(config.Duration)
        self:Tween(mainBackground, 0.3, "Quad", "Position", UDim2.new(0, 500, 0, 0))
        task.wait(0.6)
        notifyFrame:Destroy()
    end)
end

-- ==================== WINDOW SYSTEM ====================
function Lunox:NewWindow(config)
    if self.Window then
        warn("Window already exists!")
        return
    end
    
    self.Window = true
    config = config or {}
    
    -- Default configuration
    local windowConfig = {
        Title = config.Title or "Lunox Example",
        Author = config.Author or "By ! xHoang",
        Icon = config.Icon or "rbxassetid://119115999130075",
        Scale = config.Scale or UDim2.fromOffset(600, 500),
        Transparency = config.Transparency or 0,
        KeyCode = config.KeyCode or Enum.KeyCode.LeftControl
    }
    
    -- ========== CREATE WINDOW UI ==========
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Name = "LunoxWindow"
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Position = UDim2.new(0.5, 0, 0.53, 0)
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Name = "MainFrame"
    
    -- Blur background
    local blurBackground = Instance.new("ImageLabel")
    blurBackground.Name = "Blur"
    blurBackground.Parent = mainFrame
    blurBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    blurBackground.BackgroundTransparency = 1
    blurBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
    blurBackground.Size = UDim2.new(1, 120, 1, 120)
    blurBackground.ZIndex = -5
    blurBackground.Image = "rbxassetid://8992230677"
    blurBackground.ImageColor3 = Color3.fromRGB(0, 0, 0)
    blurBackground.ImageTransparency = 0.33
    
    -- Main background
    local windowBackground = Instance.new("ImageLabel")
    windowBackground.Name = "Background"
    windowBackground.Parent = mainFrame
    windowBackground.BackgroundTransparency = 1
    windowBackground.Size = UDim2.new(1, 0, 1, 0)
    windowBackground.ImageTransparency = windowConfig.Transparency
    windowBackground.Image = "rbxassetid://80999662900595"
    windowBackground.ImageColor3 = Color3.fromRGB(16, 16, 16)
    windowBackground.ScaleType = Enum.ScaleType.Slice
    windowBackground.SliceCenter = Rect.new(256, 256, 256, 256)
    windowBackground.SliceScale = 0.083
    
    -- Main container
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "Main"
    mainContainer.Parent = mainFrame
    mainContainer.BackgroundTransparency = 1
    mainContainer.Size = UDim2.new(1, 0, 1, 0)
    
    -- Close overlay (for dropdowns)
    local closeOverlay = Instance.new("TextButton")
    closeOverlay.Name = "Click"
    closeOverlay.Parent = screenGui
    closeOverlay.BackgroundTransparency = 1
    closeOverlay.TextTransparency = 1
    closeOverlay.Size = UDim2.new(1, 0, 1, 0)
    closeOverlay.Visible = false
    
    -- ========== TOPBAR ==========
    local topBar = Instance.new("Frame")
    topBar.Name = "Topbar"
    topBar.Parent = mainContainer
    topBar.BackgroundTransparency = 1
    topBar.Size = UDim2.new(1, 0, 0, 65)
    
    -- Left side (Title/Author)
    local leftSide = Instance.new("Frame")
    leftSide.Name = "Left"
    leftSide.Parent = topBar
    leftSide.BackgroundTransparency = 1
    leftSide.Size = UDim2.new(0, 250, 1, 0)
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = leftSide
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 20, 0.5, 0)
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Image = windowConfig.Icon
    icon.ImageTransparency = 0.23
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Name"
    titleLabel.Parent = leftSide
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 69, 0, 10)
    titleLabel.Size = UDim2.new(0, 200, 0, 30)
    titleLabel.Font = Enum.Font.ArialBold
    titleLabel.Text = windowConfig.Title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "Author"
    authorLabel.Parent = leftSide
    authorLabel.BackgroundTransparency = 1
    authorLabel.Position = UDim2.new(0, 69, 0, 35)
    authorLabel.Size = UDim2.new(0, 200, 0, 30)
    authorLabel.Font = Enum.Font.Arial
    authorLabel.Text = windowConfig.Author
    authorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    authorLabel.TextSize = 15
    authorLabel.TextTransparency = 0.4
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Right side (Window controls)
    local rightSide = Instance.new("Frame")
    rightSide.Name = "Right"
    rightSide.Parent = topBar
    rightSide.BackgroundTransparency = 1
    rightSide.Position = UDim2.new(1, -160, 0, 0)
    rightSide.Size = UDim2.new(0, 160, 1, 0)
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Parent = rightSide
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 15)
    
    local padding = Instance.new("UIPadding")
    padding.Parent = rightSide
    padding.PaddingTop = UDim.new(0, 12)
    
    -- Minimize button
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "Minimized"
    minimizeButton.Parent = rightSide
    minimizeButton.AnchorPoint = Vector2.new(0, 0.5)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Position = UDim2.new(0, 5, 0.5, 0)
    minimizeButton.Selectable = false
    minimizeButton.Size = UDim2.new(0, 40, 0, 40)
    minimizeButton.Image = "rbxassetid://80999662900595"
    minimizeButton.ImageTransparency = 1
    minimizeButton.ScaleType = Enum.ScaleType.Slice
    
    local minimizeIcon = Instance.new("ImageLabel")
    minimizeIcon.Name = "Icon"
    minimizeIcon.Parent = minimizeButton
    minimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeIcon.BackgroundTransparency = 1
    minimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    minimizeIcon.Size = UDim2.new(0, 25, 0, 25)
    minimizeIcon.Image = "rbxassetid://136452605242985"
    minimizeIcon.ImageRectOffset = Vector2.new(288, 672)
    minimizeIcon.ImageRectSize = Vector2.new(96, 96)
    minimizeIcon.ImageTransparency = 0.7
    
    -- Maximize button
    local maximizeButton = Instance.new("ImageButton")
    maximizeButton.Name = "Larged"
    maximizeButton.Parent = rightSide
    maximizeButton.AnchorPoint = Vector2.new(0, 0.5)
    maximizeButton.BackgroundTransparency = 1
    maximizeButton.Position = UDim2.new(0, 5, 0.5, 0)
    maximizeButton.Selectable = false
    maximizeButton.Size = UDim2.new(0, 40, 0, 40)
    maximizeButton.Image = "rbxassetid://80999662900595"
    maximizeButton.ImageTransparency = 1
    
    local maximizeIcon = Instance.new("ImageLabel")
    maximizeIcon.Name = "Icon"
    maximizeIcon.Parent = maximizeButton
    maximizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    maximizeIcon.BackgroundTransparency = 1
    maximizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    maximizeIcon.Size = UDim2.new(0, 20, 0, 20)
    maximizeIcon.Image = "rbxassetid://136452605242985"
    maximizeIcon.ImageRectOffset = Vector2.new(580, 194)
    maximizeIcon.ImageRectSize = Vector2.new(96, 96)
    maximizeIcon.ImageTransparency = 0.7
    
    -- Close button
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "Removed"
    closeButton.Parent = rightSide
    closeButton.AnchorPoint = Vector2.new(0, 0.5)
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(0, 5, 0.5, 0)
    closeButton.Selectable = false
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Image = "rbxassetid://80999662900595"
    closeButton.ImageTransparency = 1
    
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.Name = "Icon"
    closeIcon.Parent = closeButton
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    closeIcon.Size = UDim2.new(0, 25, 0, 25)
    closeIcon.Image = "rbxassetid://105957381820378"
    closeIcon.ImageRectOffset = Vector2.new(480, 0)
    closeIcon.ImageRectSize = Vector2.new(100, 100)
    closeIcon.ImageTransparency = 0.7
    
    -- ========== CHANNEL FRAME (Content Area) ==========
    local channelFrame = Instance.new("Frame")
    channelFrame.Name = "ChannelFrame"
    channelFrame.Parent = mainContainer
    channelFrame.BackgroundTransparency = 1
    channelFrame.Position = UDim2.new(0, 210, 0, 70)
    channelFrame.Size = UDim2.new(1, -220, 1, -80)
    
    local channelBackground = Instance.new("ImageLabel")
    channelBackground.Name = "Background"
    channelBackground.Parent = channelFrame
    channelBackground.BackgroundTransparency = 0.99
    channelBackground.Size = UDim2.new(1, 0, 1, 0)
    channelBackground.Image = "rbxassetid://80999662900595"
    channelBackground.ImageTransparency = 0.95
    
    -- Folder to store tab channels
    local channelsFolder = Instance.new("Folder")
    channelsFolder.Name = "List"
    channelsFolder.Parent = channelFrame
    
    -- Channel header
    local channelHeader = Instance.new("Frame")
    channelHeader.Name = "NameChannel"
    channelHeader.Parent = channelFrame
    channelHeader.BackgroundTransparency = 1
    channelHeader.Size = UDim2.new(1, 0, 0, 50)
    
    local headerLine = Instance.new("Frame")
    headerLine.Name = "Line"
    headerLine.Parent = channelHeader
    headerLine.BackgroundTransparency = 0.9
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    
    local channelIcon = Instance.new("ImageLabel")
    channelIcon.Name = "Icon"
    channelIcon.Parent = channelHeader
    channelIcon.AnchorPoint = Vector2.new(0, 0.5)
    channelIcon.BackgroundTransparency = 1
    channelIcon.Position = UDim2.new(0, 20, 0.5, 0)
    channelIcon.Size = UDim2.new(0, 20, 0, 20)
    channelIcon.Image = "rbxassetid://132003413384414"
    
    local channelName = Instance.new("TextLabel")
    channelName.Name = "NameTab"
    channelName.Parent = channelHeader
    channelName.AnchorPoint = Vector2.new(0, 0.5)
    channelName.BackgroundTransparency = 1
    channelName.Position = UDim2.new(0, 50, 0.5, 0)
    channelName.Size = UDim2.new(0, 300, 1, 0)
    channelName.Font = Enum.Font.Arial
    channelName.Text = "Tab"
    channelName.TextColor3 = Color3.fromRGB(255, 255, 255)
    channelName.TextSize = 15
    channelName.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ========== TAB FRAME (Left Sidebar) ==========
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Parent = mainContainer
    tabFrame.BackgroundTransparency = 1
    tabFrame.Position = UDim2.new(0, 0, 0, 60)
    tabFrame.Size = UDim2.new(0, 200, 1, -60)
    
    local scrollTab = Instance.new("ScrollingFrame")
    scrollTab.Name = "ScrollTab"
    scrollTab.Parent = tabFrame
    scrollTab.BackgroundTransparency = 1
    scrollTab.Selectable = false
    scrollTab.Size = UDim2.new(1, 0, 1, 0)
    scrollTab.CanvasSize = UDim2.new(0, 0, 1.3, 0)
    scrollTab.ScrollBarThickness = 0
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Parent = scrollTab
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = scrollTab
    tabPadding.PaddingBottom = UDim.new(0, 8)
    tabPadding.PaddingLeft = UDim.new(0, 12)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.PaddingTop = UDim.new(0, 8)
    
    -- Auto-update scroll
    self.Stepped:Connect(function()
        self:UpdateScroll(scrollTab, tabListLayout)
    end)
    
    -- ========== WINDOW FUNCTIONALITY ==========
    local windowData = {
        OldSize = nil,
        CurrentTab = nil,
        Tabs = {}
    }
    
    -- Minimize function
    local function minimizeWindow()
        windowData.OldSize = mainFrame.Size
        mainContainer.Visible = false
        self:Tween(mainFrame, 0.13, "Quad", "Size", UDim2.fromOffset(500, 300))
        self:Tween(windowBackground, 0.2, "Quad", "ImageTransparency", 1)
        self:Tween(blurBackground, 0.2, "Quad", "ImageTransparency", 1)
        task.wait(0.1)
        mainFrame.Visible = false
    end
    
    -- Maximize function
    local maxSize, maxPos
    maximizeButton.Activated:Connect(function()
        if mainFrame.Size ~= UDim2.new(1, -20, 1, -20) then
            maxSize = mainFrame.Size
            maxPos = mainFrame.Position
            self:Tween(mainFrame, 0.2, "Quad", "Position", UDim2.new(0, 10, 0, 10))
            self:Tween(mainFrame, 0.2, "Quad", "Size", UDim2.new(1, -20, 1, -20))
        else
            self:Tween(mainFrame, 0.2, "Quad", "Position", maxPos)
            self:Tween(mainFrame, 0.2, "Quad", "Size", maxSize)
        end
    end)
    
    -- Button events
    minimizeButton.Activated:Connect(minimizeWindow)
    closeButton.Activated:Connect(function()
        mainContainer.Visible = false
        self:Tween(mainFrame, 0.13, "Quad", "Size", UDim2.fromOffset(500, 300))
        self:Tween(windowBackground, 0.2, "Quad", "ImageTransparency", 1)
        self:Tween(blurBackground, 0.2, "Quad", "ImageTransparency", 1)
        task.wait(0.1)
        screenGui:Destroy()
        self.Window = false
    end)
    
    -- Mouse hover effects
    self:MouseEvent(minimizeButton, 
        function() minimizeButton.ImageTransparency = 0.95 end,
        function() minimizeButton.ImageTransparency = 1 end
    )
    
    self:MouseEvent(maximizeButton,
        function() maximizeButton.ImageTransparency = 0.95 end,
        function() maximizeButton.ImageTransparency = 1 end
    )
    
    self:MouseEvent(closeButton,
        function() closeButton.ImageTransparency = 0.95 end,
        function() closeButton.ImageTransparency = 1 end
    )
    
    -- Make window draggable and resizable
    self:MakeDraggable(mainFrame, topBar)
    self:CustomSize(mainFrame)
    
    -- Open animation
    local openTween = self:Tween(mainFrame, 0.2, "Quad", "Size", windowConfig.Scale)
    openTween.Completed:Connect(function()
        mainFrame.AnchorPoint = Vector2.new(0, 0)
        local viewport = game.Workspace.Camera.ViewportSize
        mainFrame.Position = UDim2.fromOffset(
            viewport.X/2 - mainFrame.Size.X.Offset/2,
            viewport.Y/2 - mainFrame.Size.Y.Offset/2
        )
    end)
    
    -- ========== WINDOW METHODS ==========
    local windowMethods = {}
    
    function windowMethods:SetTransparency(value)
        windowBackground.ImageTransparency = value * 0.01
    end
    
    -- Toggle window with hotkey
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == windowConfig.KeyCode then
            if mainContainer.Visible then
                minimizeWindow()
            else
                mainFrame.Visible = true
                task.wait(0.05)
                mainContainer.Visible = true
                mainFrame.Size = UDim2.new(0, windowData.OldSize.X.Offset - 40, 0, windowData.OldSize.Y.Offset - 40)
                self:Tween(mainFrame, 0.13, "Quad", "Size", UDim2.fromOffset(windowData.OldSize.X.Offset, windowData.OldSize.Y.Offset))
                self:Tween(windowBackground, 0.2, "Quad", "ImageTransparency", windowConfig.Transparency)
                self:Tween(blurBackground, 0.2, "Quad", "ImageTransparency", 0.33)
            end
        end
    end)
    
    -- ========== SECTION SYSTEM ==========
    local sectionCount = 0
    
    function windowMethods:AddSection(config)
        config = config or {}
        config.Open = config.Open or false
        config.Title = config.Title or "Section"
        
        local sectionFrame = Instance.new("Frame")
        local sectionTitle = Instance.new("TextButton")
        local sectionIcon = Instance.new("ImageLabel")
        local sectionLayout = Instance.new("UIListLayout")
        local sectionPadding = Instance.new("UIPadding")
        
        -- Configure section
        sectionFrame.Name = "SectionTab"
        sectionFrame.Parent = scrollTab
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.ClipsDescendants = true
        sectionFrame.Size = UDim2.new(1, 0, 0, 140)
        
        -- Section title button
        sectionTitle.Name = "Title"
        sectionTitle.Parent = sectionFrame
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Position = UDim2.new(0, 15, 0, 0)
        sectionTitle.Size = UDim2.new(1, -30, 0, 30)
        sectionTitle.Font = Enum.Font.ArialBold
        sectionTitle.Text = config.Title
        sectionTitle.TextColor3 = Color3.fromRGB(144, 144, 144)
        sectionTitle.TextSize = 15
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Expand/collapse icon
        sectionIcon.Name = "Icon"
        sectionIcon.Parent = sectionTitle
        sectionIcon.AnchorPoint = Vector2.new(0, 0.5)
        sectionIcon.BackgroundTransparency = 1
        sectionIcon.Position = UDim2.new(1, 1, 0.5, 0)
        sectionIcon.Size = UDim2.new(0, 18, 0, 18)
        sectionIcon.Image = "rbxassetid://98740753192722"
        sectionIcon.ImageColor3 = Color3.fromRGB(100, 100, 100)
        sectionIcon.ImageRectOffset = Vector2.new(0, 192)
        sectionIcon.ImageRectSize = Vector2.new(96, 96)
        
        -- Layout for tabs
        sectionLayout.Parent = sectionFrame
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Padding = UDim.new(0, 5)
        
        sectionPadding.Parent = sectionFrame
        sectionPadding.PaddingLeft = UDim.new(0, 8)
        
        -- Mouse events for section title
        self:MouseEvent(sectionTitle,
            function()
                sectionIcon.ImageColor3 = Color3.fromRGB(188, 188, 188)
                sectionTitle.TextColor3 = Color3.fromRGB(188, 188, 188)
            end,
            function()
                sectionIcon.ImageColor3 = Color3.fromRGB(100, 100, 100)
                sectionTitle.TextColor3 = Color3.fromRGB(144, 144, 144)
            end
        )
        
        -- Set initial state
        if not config.Open then
            sectionIcon.Rotation = 180
            sectionFrame.Size = UDim2.new(1, 0, 0, 32)
        end
        
        -- Toggle expand/collapse
        sectionTitle.Activated:Connect(function()
            config.Open = not config.Open
            if config.Open then
                self:Tween(sectionIcon, 0.3, "Quad", "Rotation", 0)
            else
                self:Tween(sectionIcon, 0.3, "Quad", "Rotation", 180)
                self:Tween(sectionFrame, 0.3, "Quad", "Size", UDim2.new(1, 0, 0, 32))
            end
        end)
        
        -- Auto-size when open
        self.Stepped:Connect(function()
            if config.Open then
                self:Tween(sectionFrame, 0.3, "Quad", "Size", 
                    UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 15))
            end
        end)
        
        -- ========== TAB METHODS ==========
        local sectionMethods = {}
        
        -- Tab switching function (FIXED VERSION)
        local function changeTab(channel, tabTitle, tabIcon)
            -- Update channel header
            channelName.Text = tabTitle or ""
            channelIcon.Image = tabIcon or ""
            
            -- Hide all channels
            for _, existingChannel in pairs(channelsFolder:GetChildren()) do
                if existingChannel:IsA("ScrollingFrame") then
                    self:Tween(existingChannel, 0.2, "Quad", "Position", UDim2.new(0, 0, 0, 60))
                    existingChannel.Visible = false
                end
            end
            
            -- Show selected channel
            if channel then
                channel.Visible = true
                self:Tween(channel, 0.2, "Quad", "Position", UDim2.new(0, 0, 0, 50))
            end
            
            -- Update current tab
            windowData.CurrentTab = channel
        end
        
        function sectionMethods:AddTab(config)
            config = config or {}
            config.Title = config.Title or "Tab"
            config.Icon = config.Icon
            config.Lock = config.Lock or false
            config.LockCallback = config.LockCallback or function() end
            
            local tabButton = Instance.new("ImageButton")
            local tabBackground = Instance.new("ImageLabel")
            local tabStroke = Instance.new("ImageLabel")
            local tabName = Instance.new("TextLabel")
            local tabIconLabel = Instance.new("ImageLabel")
            local tabChannel = Instance.new("ScrollingFrame")
            
            -- Tab button
            tabButton.Name = "TabDisable"
            tabButton.Parent = sectionFrame
            tabButton.BackgroundTransparency = 1
            tabButton.Size = UDim2.new(1, 0, 0, 45)
            
            -- Tab background
            tabBackground.Name = "Background"
            tabBackground.Parent = tabButton
            tabBackground.BackgroundTransparency = 1
            tabBackground.Size = UDim2.new(1, 0, 1, 0)
            tabBackground.Image = "rbxassetid://80999662900595"
            tabBackground.ImageTransparency = 1
            tabBackground.ScaleType = Enum.ScaleType.Slice
            
            -- Tab stroke
            tabStroke.Name = "UIStroke"
            tabStroke.Parent = tabButton
            tabStroke.BackgroundTransparency = 1
            tabStroke.Size = UDim2.new(1, 0, 1, 0)
            tabStroke.Image = "rbxassetid://117788349049947"
            tabStroke.ImageTransparency = 1
            tabStroke.ScaleType = Enum.ScaleType.Slice
            
            -- Tab name
            tabName.Name = "TabName"
            tabName.Parent = tabButton
            tabName.BackgroundTransparency = 1
            tabName.Position = UDim2.new(0, 18, 0, 0)
            tabName.Size = UDim2.new(1, -35, 1, 0)
            tabName.Font = Enum.Font.Arial
            tabName.Text = config.Title
            tabName.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabName.TextSize = 15
            tabName.TextTransparency = 0.3
            tabName.TextWrapped = true
            tabName.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Tab channel (content area)
            tabChannel.Name = "Channel"
            tabChannel.Parent = channelsFolder
            tabChannel.BackgroundTransparency = 1
            tabChannel.Position = UDim2.new(0, 0, 0, 50)
            tabChannel.Selectable = false
            tabChannel.Size = UDim2.new(1, 0, 1, -50)
            tabChannel.CanvasSize = UDim2.new(0, 0, 0, 560)
            tabChannel.ScrollBarThickness = 0
            tabChannel.Visible = false
            
            -- Channel layout
            local channelPadding = Instance.new("UIPadding")
            channelPadding.Parent = tabChannel
            channelPadding.PaddingBottom = UDim.new(0, 4)
            channelPadding.PaddingLeft = UDim.new(0, 12)
            channelPadding.PaddingRight = UDim.new(0, 7)
            channelPadding.PaddingTop = UDim.new(0, 9)
            
            local channelLayout = Instance.new("UIListLayout")
            channelLayout.Parent = tabChannel
            channelLayout.SortOrder = Enum.SortOrder.LayoutOrder
            channelLayout.Padding = UDim.new(0, 5)
            
            -- Auto-update scroll
            self.Stepped:Connect(function()
                self:UpdateScroll(tabChannel, channelLayout)
            end)
            
            -- Tab icon (if provided)
            if config.Icon and config.Icon ~= "" then
                tabName.Position = UDim2.new(0, 32, 0, 0)
                tabIconLabel.Name = "Icon"
                tabIconLabel.Parent = tabButton
                tabIconLabel.AnchorPoint = Vector2.new(0, 0.5)
                tabIconLabel.BackgroundTransparency = 1
                tabIconLabel.Position = UDim2.new(0, 10, 0.5, 0)
                tabIconLabel.Size = UDim2.new(0, 18, 0, 18)
                tabIconLabel.Image = config.Icon
                tabIconLabel.ImageTransparency = 0.3
            end
            
            -- Make first tab active by default
            if sectionCount == 0 then
                sectionCount += 1
                tabChannel.Visible = true
                if tabIconLabel then tabIconLabel.ImageTransparency = 0.1 end
                tabName.TextTransparency = 0
                tabBackground.ImageTransparency = 0.95
                tabStroke.ImageTransparency = 0.9
                changeTab(tabChannel, config.Title, config.Icon)
            end
            
            -- Mouse events for tab
            self:MouseEvent(tabButton,
                function()
                    tabBackground.ImageTransparency = 0.95
                end,
                function()
                    if tabName.TextTransparency >= 0.1 then
                        tabBackground.ImageTransparency = 1
                    end
                end
            )
            
            -- Tab click event (FIXED)
            tabButton.Activated:Connect(function()
                if config.Lock then
                    config.LockCallback()
                    return
                end
                
                -- Reset all tabs to inactive state
                for _, section in pairs(scrollTab:GetChildren()) do
                    if section:IsA("Frame") then
                        for _, tab in pairs(section:GetChildren()) do
                            if tab:IsA("ImageButton") then
                                self:Tween(tab.Background, 0.3, "Quad", "ImageTransparency", 1)
                                self:Tween(tab.TabName, 0.3, "Quad", "TextTransparency", 0.3)
                                self:Tween(tab.UIStroke, 0.3, "Quad", "ImageTransparency", 1)
                                
                                -- Reset tab icon if exists
                                if tab:FindFirstChild("Icon") then
                                    self:Tween(tab.Icon, 0.3, "Quad", "ImageTransparency", 0.3)
                                end
                            end
                        end
                    end
                end
                
                -- Activate clicked tab
                self:Tween(tabBackground, 0.3, "Quad", "ImageTransparency", 0.95)
                self:Tween(tabName, 0.3, "Quad", "TextTransparency", 0)
                self:Tween(tabStroke, 0.3, "Quad", "ImageTransparency", 0.9)
                
                -- Activate tab icon if exists
                if tabIconLabel then
                    self:Tween(tabIconLabel, 0.3, "Quad", "ImageTransparency", 0.1)
                end
                
                -- Switch to this tab's channel
                changeTab(tabChannel, config.Title, config.Icon)
            end)
            
            -- ========== CONTROL METHODS ==========
            local tabMethods = {}
            
            -- Toggle control
            function tabMethods:AddToggle(config)
                config = config or {}
                config.Title = config.Title or "Toggle"
                config.Description = config.Description
                config.Default = config.Default or false
                config.Active = config.Active or config.Default
                config.Callback = config.Callback or function() end
                
                local toggleFrame = Instance.new("Frame")
                local toggleButton = Instance.new("ImageButton")
                local titleLabel = Instance.new("TextLabel")
                local descLabel = Instance.new("TextLabel")
                local toggleBackground = Instance.new("Frame")
                local toggleCircle = Instance.new("Frame")
                
                -- Toggle frame
                toggleFrame.Name = "Toggle"
                toggleFrame.Parent = tabChannel
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, 55)
                
                -- Background button
                toggleButton.Name = "Background"
                toggleButton.Parent = toggleFrame
                toggleButton.BackgroundTransparency = 1
                toggleButton.Size = UDim2.new(1, 0, 1, 0)
                toggleButton.Image = "rbxassetid://80999662900595"
                toggleButton.ImageTransparency = 0.95
                toggleButton.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = toggleButton
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 0)
                titleLabel.Size = UDim2.new(1, -80, 1, 0)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Description (optional)
                if config.Description and config.Description ~= "" then
                    descLabel.Name = "Desc"
                    descLabel.Parent = toggleButton
                    descLabel.BackgroundTransparency = 1
                    descLabel.Position = UDim2.new(0, 15, 0, 26)
                    descLabel.Size = UDim2.new(1, -80, 1, -26)
                    descLabel.Font = Enum.Font.Arial
                    descLabel.Text = config.Description
                    descLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    descLabel.TextSize = 13
                    descLabel.TextWrapped = true
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextYAlignment = Enum.TextYAlignment.Top
                    descLabel.RichText = true
                    
                    -- Adjust layout for description
                    titleLabel.Size = UDim2.new(1, -80, 0, 18)
                    titleLabel.Position = UDim2.new(0, 15, 0, 8)
                    
                    self.Stepped:Connect(function()
                        toggleFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 23, 55))
                    end)
                end
                
                -- Toggle switch
                toggleBackground.Name = "CheckToggle"
                toggleBackground.Parent = toggleFrame
                toggleBackground.AnchorPoint = Vector2.new(0, 0.5)
                toggleBackground.BackgroundTransparency = 0.85
                toggleBackground.Position = UDim2.new(1, -55, 0.5, 0)
                toggleBackground.Size = UDim2.new(0, 45, 0, 26)
                
                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(1, 0)
                bgCorner.Parent = toggleBackground
                
                toggleCircle.Name = "Check"
                toggleCircle.Parent = toggleBackground
                toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
                toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleCircle.Position = UDim2.new(0, 3, 0.5, 0)
                toggleCircle.Size = UDim2.new(0, 20, 0, 20)
                
                local circleCorner = Instance.new("UICorner")
                circleCorner.CornerRadius = UDim.new(1, 0)
                circleCorner.Parent = toggleCircle
                
                -- Mouse events
                self:MouseEvent(toggleFrame,
                    function() toggleButton.ImageTransparency = 0.93 end,
                    function() toggleButton.ImageTransparency = 0.95 end
                )
                
                -- Toggle methods
                local toggleMethods = {}
                
                function toggleMethods:SetValue(value)
                    config.Active = value
                    if value then
                        self:Tween(toggleBackground, 0.2, "Quad", "BackgroundTransparency", 0.75)
                        self:Tween(toggleCircle, 0.2, "Quad", "Position", UDim2.new(0, 22, 0.5, 0))
                    else
                        self:Tween(toggleBackground, 0.2, "Quad", "BackgroundTransparency", 0.85)
                        self:Tween(toggleCircle, 0.2, "Quad", "Position", UDim2.new(0, 3, 0.5, 0))
                    end
                    config.Callback(config.Active)
                end
                
                -- Initialize
                toggleMethods:SetValue(config.Active)
                
                -- Click event
                toggleButton.Activated:Connect(function()
                    toggleMethods:SetValue(not config.Active)
                end)
                
                return toggleMethods
            end
            
            -- Button control
            function tabMethods:AddButton(config)
                config = config or {}
                config.Title = config.Title or "Button"
                config.Description = config.Description
                config.Callback = config.Callback or function() end
                
                local buttonFrame = Instance.new("Frame")
                local buttonButton = Instance.new("ImageButton")
                local titleLabel = Instance.new("TextLabel")
                local descLabel = Instance.new("TextLabel")
                local buttonIcon = Instance.new("ImageLabel")
                
                -- Button frame
                buttonFrame.Name = "Button"
                buttonFrame.Parent = tabChannel
                buttonFrame.BackgroundTransparency = 1
                buttonFrame.Size = UDim2.new(1, 0, 0, 55)
                
                -- Background button
                buttonButton.Name = "Background"
                buttonButton.Parent = buttonFrame
                buttonButton.BackgroundTransparency = 1
                buttonButton.Size = UDim2.new(1, 0, 1, 0)
                buttonButton.Image = "rbxassetid://80999662900595"
                buttonButton.ImageTransparency = 0.95
                buttonButton.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = buttonButton
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 0)
                titleLabel.Size = UDim2.new(1, -80, 1, 0)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Description (optional)
                if config.Description and config.Description ~= "" then
                    descLabel.Name = "Desc"
                    descLabel.Parent = buttonButton
                    descLabel.BackgroundTransparency = 1
                    descLabel.Position = UDim2.new(0, 15, 0, 26)
                    descLabel.Size = UDim2.new(1, -80, 1, -26)
                    descLabel.Font = Enum.Font.Arial
                    descLabel.Text = config.Description
                    descLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    descLabel.TextSize = 13
                    descLabel.TextWrapped = true
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextYAlignment = Enum.TextYAlignment.Top
                    descLabel.RichText = true
                    
                    -- Adjust layout
                    titleLabel.Size = UDim2.new(1, -80, 0, 18)
                    titleLabel.Position = UDim2.new(0, 15, 0, 8)
                    
                    self.Stepped:Connect(function()
                        buttonFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 23, 55))
                    end)
                end
                
                -- Icon
                buttonIcon.Name = "Icon"
                buttonIcon.Parent = buttonFrame
                buttonIcon.AnchorPoint = Vector2.new(0, 0.5)
                buttonIcon.BackgroundTransparency = 1
                buttonIcon.Position = UDim2.new(1, -40, 0.5, 0)
                buttonIcon.Size = UDim2.new(0, 25, 0, 25)
                buttonIcon.Image = "rbxassetid://85905776508942"
                
                -- Mouse events
                self:MouseEvent(buttonFrame,
                    function() buttonButton.ImageTransparency = 0.93 end,
                    function() buttonButton.ImageTransparency = 0.95 end
                )
                
                -- Button methods
                local buttonMethods = {}
                
                function buttonMethods:SetDesc(text)
                    if descLabel then
                        descLabel.Text = text
                    end
                end
                
                -- Click event with animation
                buttonButton.Activated:Connect(function()
                    buttonButton.ImageTransparency = 0.98
                    self:Tween(buttonButton, 0.15, "Quad", "ImageTransparency", 0.95)
                    config.Callback()
                end)
                
                return buttonMethods
            end
            
            -- Slider control
            function tabMethods:AddSlider(config)
                config = config or {}
                config.Title = config.Title or "Slider"
                config.Description = config.Description
                config.Min = config.Min or 0
                config.Max = config.Max or 100
                config.Default = config.Default or config.Min
                config.Callback = config.Callback or function() end
                
                local sliderFrame = Instance.new("Frame")
                local sliderBackground = Instance.new("ImageLabel")
                local titleLabel = Instance.new("TextLabel")
                local descLabel = Instance.new("TextLabel")
                local sliderTrack = Instance.new("ImageLabel")
                local sliderFill = Instance.new("ImageLabel")
                local sliderThumb = Instance.new("ImageLabel")
                local valueLabel = Instance.new("TextLabel")
                
                -- Slider frame
                sliderFrame.Name = "Slider"
                sliderFrame.Parent = tabChannel
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(1, 0, 0, 65)
                
                -- Background
                sliderBackground.Name = "Background"
                sliderBackground.Parent = sliderFrame
                sliderBackground.Active = true
                sliderBackground.BackgroundTransparency = 1
                sliderBackground.Size = UDim2.new(1, 0, 1, 0)
                sliderBackground.Image = "rbxassetid://80999662900595"
                sliderBackground.ImageTransparency = 0.95
                sliderBackground.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = sliderBackground
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 8)
                titleLabel.Size = UDim2.new(1, -80, 0, 18)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Description (optional)
                if config.Description and config.Description ~= "" then
                    descLabel.Name = "Desc"
                    descLabel.Parent = sliderBackground
                    descLabel.BackgroundTransparency = 1
                    descLabel.Position = UDim2.new(0, 15, 0, 26)
                    descLabel.Size = UDim2.new(1, -80, 1, -60)
                    descLabel.Font = Enum.Font.Arial
                    descLabel.Text = config.Description
                    descLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    descLabel.TextSize = 13
                    descLabel.TextWrapped = true
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextYAlignment = Enum.TextYAlignment.Top
                    descLabel.RichText = true
                    
                    self.Stepped:Connect(function()
                        sliderFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 35, 75))
                    end)
                end
                
                -- Slider track (background)
                sliderTrack.Name = "UIStroke"
                sliderTrack.Parent = sliderBackground
                sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
                sliderTrack.BackgroundTransparency = 1
                sliderTrack.Position = UDim2.new(0, 15, 0.75, 0)
                sliderTrack.Size = UDim2.new(1, -100, 0, 7)
                sliderTrack.Image = "rbxassetid://117788349049947"
                sliderTrack.ImageTransparency = 0.85
                sliderTrack.ScaleType = Enum.ScaleType.Slice
                
                -- Slider fill (foreground)
                sliderFill.Name = "SliderDraggable"
                sliderFill.Parent = sliderBackground
                sliderFill.AnchorPoint = Vector2.new(0, 0.5)
                sliderFill.BackgroundTransparency = 1
                sliderFill.Position = UDim2.new(0, 15, 0.75, 0)
                sliderFill.Size = UDim2.new(1, -100, 0, 7)
                sliderFill.Image = "rbxassetid://80999662900595"
                sliderFill.ImageTransparency = 0.95
                sliderFill.ScaleType = Enum.ScaleType.Slice
                
                -- Slider thumb
                sliderThumb.Name = "Draggable"
                sliderThumb.Parent = sliderFill
                sliderThumb.BackgroundTransparency = 1
                sliderThumb.Size = UDim2.new(0, 100, 1, 0)
                sliderThumb.Image = "rbxassetid://80999662900595"
                sliderThumb.ImageTransparency = 0.5
                sliderThumb.ScaleType = Enum.ScaleType.Slice
                
                local thumbCircle = Instance.new("ImageLabel")
                thumbCircle.Name = "Circle"
                thumbCircle.Parent = sliderThumb
                thumbCircle.BackgroundTransparency = 1
                thumbCircle.Position = UDim2.new(1, -8, 0, -4)
                thumbCircle.Size = UDim2.new(0, 15, 0, 15)
                thumbCircle.Image = "rbxassetid://80999662900595"
                thumbCircle.ImageColor3 = Color3.fromRGB(188, 188, 188)
                thumbCircle.ScaleType = Enum.ScaleType.Slice
                
                -- Value label
                valueLabel.Parent = sliderFill
                valueLabel.AnchorPoint = Vector2.new(0, 0.5)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Position = UDim2.new(1, 6, 0.3, 0)
                valueLabel.Size = UDim2.new(0, 50, 0, 30)
                valueLabel.Font = Enum.Font.Arial
                valueLabel.Text = tostring(config.Default)
                valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                valueLabel.TextSize = 15
                valueLabel.TextTransparency = 0.4
                
                -- Slider logic
                local isDragging = false
                local sliderData = {Value = config.Default}
                
                local function round(value, increment)
                    return math.floor(value / increment + (math.sign(value) * 0.5)) * increment
                end
                
                function sliderData:Set(value)
                    value = math.clamp(round(value, 1), config.Min, config.Max)
                    self.Value = value
                    valueLabel.Text = tostring(value)
                    config.Callback(self.Value)
                    
                    local percentage = (value - config.Min) / (config.Max - config.Min)
                    self:Tween(sliderThumb, 0.2, "Quad", "Size", UDim2.fromScale(percentage, 1))
                end
                
                -- Drag events
                sliderFill.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or 
                       input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                    end
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or 
                       input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if isDragging then
                        local mousePos = input.Position.X
                        local sliderPos = sliderFill.AbsolutePosition.X
                        local sliderWidth = sliderFill.AbsoluteSize.X
                        
                        local percentage = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
                        local value = config.Min + ((config.Max - config.Min) * percentage)
                        
                        sliderData:Set(value)
                    end
                end)
                
                -- Initialize
                sliderData:Set(config.Default)
                
                return sliderData
            end
            
            -- Dropdown control
            function tabMethods:AddDropdown(config)
                config = config or {}
                config.Title = config.Title or "Dropdown"
                config.Description = config.Description or ""
                config.Values = config.Values or {}
                config.Default = config.Default or (config.Multi and {} or "")
                config.Multi = config.Multi or false
                config.Callback = config.Callback or function() end
                
                local dropdownFrame = Instance.new("Frame")
                local dropdownBackground = Instance.new("ImageLabel")
                local titleLabel = Instance.new("TextLabel")
                local descLabel = Instance.new("TextLabel")
                local dropdownButton = Instance.new("ImageButton")
                local dropdownContainer = Instance.new("Frame")
                local selectedLabel = Instance.new("TextLabel")
                local dropdownIcon = Instance.new("ImageLabel")
                local dropdownStroke = Instance.new("ImageLabel")
                
                -- Dropdown frame
                dropdownFrame.Name = "Dropdown"
                dropdownFrame.Parent = tabChannel
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Size = UDim2.new(1, 0, 0, 90)
                
                -- Background
                dropdownBackground.Name = "Background"
                dropdownBackground.Parent = dropdownFrame
                dropdownBackground.Active = true
                dropdownBackground.BackgroundTransparency = 1
                dropdownBackground.Size = UDim2.new(1, 0, 1, 0)
                dropdownBackground.Image = "rbxassetid://80999662900595"
                dropdownBackground.ImageTransparency = 0.95
                dropdownBackground.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = dropdownBackground
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 8)
                titleLabel.Size = UDim2.new(1, -80, 0, 18)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Description
                if config.Description and config.Description ~= "" then
                    descLabel.Name = "Desc"
                    descLabel.Parent = dropdownBackground
                    descLabel.BackgroundTransparency = 1
                    descLabel.Position = UDim2.new(0, 15, 0, 26)
                    descLabel.Size = UDim2.new(1, -80, 1, 0)
                    descLabel.Font = Enum.Font.Arial
                    descLabel.Text = config.Description
                    descLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    descLabel.TextSize = 13
                    descLabel.TextWrapped = true
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextYAlignment = Enum.TextYAlignment.Top
                    descLabel.RichText = true
                    
                    self.Stepped:Connect(function()
                        dropdownFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 75, 90))
                    end)
                end
                
                -- Dropdown button
                dropdownButton.Name = "Click"
                dropdownButton.Parent = dropdownBackground
                dropdownButton.AnchorPoint = Vector2.new(0, 0.5)
                dropdownButton.BackgroundTransparency = 1
                dropdownButton.Position = UDim2.new(0, 10, 0.7, 0)
                dropdownButton.Size = UDim2.new(1, -20, 0, 35)
                dropdownButton.Image = "rbxassetid://80999662900595"
                dropdownButton.ImageTransparency = 0.94
                dropdownButton.ScaleType = Enum.ScaleType.Slice
                
                dropdownContainer.Parent = dropdownButton
                dropdownContainer.BackgroundTransparency = 1
                dropdownContainer.Size = UDim2.new(1, 0, 1, 0)
                
                selectedLabel.Name = "Select"
                selectedLabel.Parent = dropdownContainer
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.Position = UDim2.new(0, 10, 0, 0)
                selectedLabel.Size = UDim2.new(1, -60, 1, 0)
                selectedLabel.Font = Enum.Font.Arial
                selectedLabel.Text = ""
                selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                selectedLabel.TextSize = 15
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                
                dropdownIcon.Name = "Icon"
                dropdownIcon.Parent = dropdownContainer
                dropdownIcon.AnchorPoint = Vector2.new(0, 0.5)
                dropdownIcon.BackgroundTransparency = 1
                dropdownIcon.Position = UDim2.new(1, -30, 0.5, 0)
                dropdownIcon.Size = UDim2.new(0, 20, 0, 20)
                dropdownIcon.Image = "rbxassetid://86169870187835"
                dropdownIcon.ImageTransparency = 0.1
                
                dropdownStroke.Name = "UIStroke"
                dropdownStroke.Parent = dropdownBackground
                dropdownStroke.AnchorPoint = Vector2.new(0, 0.5)
                dropdownStroke.BackgroundTransparency = 1
                dropdownStroke.Position = UDim2.new(0, 10, 0.7, 0)
                dropdownStroke.Size = UDim2.new(1, -20, 0, 35)
                dropdownStroke.Image = "rbxassetid://117788349049947"
                dropdownStroke.ImageTransparency = 0.85
                dropdownStroke.ScaleType = Enum.ScaleType.Slice
                
                -- Dropdown popup
                local dropdownPopup = Instance.new("ImageLabel")
                dropdownPopup.Name = "Dropdown1"
                dropdownPopup.Parent = screenGui
                dropdownPopup.BackgroundTransparency = 1
                dropdownPopup.Size = UDim2.new(0, 341, 0, 150)
                dropdownPopup.Image = "rbxassetid://80999662900595"
                dropdownPopup.ImageColor3 = Color3.fromRGB(50, 50, 50)
                dropdownPopup.ScaleType = Enum.ScaleType.Slice
                dropdownPopup.Visible = false
                dropdownPopup.ZIndex = 100
                
                local popupStroke = Instance.new("ImageLabel")
                popupStroke.Name = "UIStroke"
                popupStroke.Parent = dropdownPopup
                popupStroke.AnchorPoint = Vector2.new(0.5, 0.5)
                popupStroke.BackgroundTransparency = 1
                popupStroke.Size = UDim2.new(1, 0, 1, 0)
                popupStroke.Image = "rbxassetid://117788349049947"
                popupStroke.ImageTransparency = 0.73
                popupStroke.ScaleType = Enum.ScaleType.Slice
                
                local popupContainer = Instance.new("Frame")
                popupContainer.Parent = dropdownPopup
                popupContainer.BackgroundTransparency = 1
                popupContainer.Size = UDim2.new(1, 0, 1, 0)
                
                local optionsScroll = Instance.new("ScrollingFrame")
                optionsScroll.Name = "nn"
                optionsScroll.Parent = popupContainer
                optionsScroll.BackgroundTransparency = 1
                optionsScroll.Size = UDim2.new(1, 0, 1, 0)
                optionsScroll.ScrollBarThickness = 0
                optionsScroll.ScrollingEnabled = false
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.Parent = optionsScroll
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Padding = UDim.new(0, 4)
                
                local optionsPadding = Instance.new("UIPadding")
                optionsPadding.Parent = optionsScroll
                optionsPadding.PaddingBottom = UDim.new(0, 7)
                optionsPadding.PaddingLeft = UDim.new(0, 7)
                optionsPadding.PaddingRight = UDim.new(0, 7)
                optionsPadding.PaddingTop = UDim.new(0, 7)
                
                -- Auto-size popup
                optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    local contentHeight = optionsLayout.AbsoluteContentSize.Y + 20
                    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
                    optionsScroll.ScrollingEnabled = contentHeight >= 300
                end)
                
                -- Open dropdown
                dropdownButton.Activated:Connect(function()
                    scrollTab.ScrollingEnabled = false
                    tabChannel.ScrollingEnabled = false
                    closeOverlay.Visible = true
                    
                    dropdownPopup.Position = UDim2.new(0, dropdownButton.AbsolutePosition.X, 
                                                       0, dropdownButton.AbsolutePosition.Y)
                    dropdownPopup.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 
                                                   0, math.min(optionsLayout.AbsoluteContentSize.Y + 20, 300) - 30)
                    dropdownPopup.Visible = true
                    
                    self:Tween(dropdownPopup, 0.3, "Quad", "Size", 
                        UDim2.new(0, dropdownButton.AbsoluteSize.X, 
                                  0, math.min(optionsLayout.AbsoluteContentSize.Y + 20, 300)))
                end)
                
                -- Close dropdown when clicking overlay
                closeOverlay.Activated:Connect(function()
                    self:Tween(dropdownPopup, 0.3, "Quad", "Size", 
                        UDim2.new(0, dropdownButton.AbsoluteSize.X, 
                                  0, math.min(optionsLayout.AbsoluteContentSize.Y + 20, 300)))
                    task.wait(0.05)
                    
                    dropdownPopup.Visible = false
                    scrollTab.ScrollingEnabled = true
                    closeOverlay.Visible = false
                    tabChannel.ScrollingEnabled = true
                end)
                
                -- Dropdown methods
                local dropdownMethods = {Select = config.Default}
                
                function dropdownMethods:Set(selection)
                    self.Select = selection or self.Select
                    
                    -- Update option visuals
                    for _, option in pairs(optionsScroll:GetChildren()) do
                        if option:IsA("ImageButton") then
                            local optionText = option.TextLabel.Text
                            local isSelected = table.find(self.Select, optionText)
                            
                            if isSelected then
                                self:Tween(option, 0.2, "Quad", "ImageTransparency", 0.89)
                                self:Tween(option.TextLabel, 0.2, "Quad", "TextTransparency", 0)
                            else
                                self:Tween(option, 0.2, "Quad", "ImageTransparency", 1)
                                self:Tween(option.TextLabel, 0.2, "Quad", "TextTransparency", 0.5)
                            end
                        end
                    end
                    
                    -- Update selected text
                    if #self.Select == 0 then
                        selectedLabel.Text = ""
                    else
                        selectedLabel.Text = table.concat(self.Select, ", ")
                    end
                    
                    -- Callback
                    if config.Multi then
                        config.Callback(self.Select)
                    else
                        config.Callback(table.concat(self.Select, ", "))
                    end
                end
                
                function dropdownMethods:Add(value)
                    local optionButton = Instance.new("ImageButton")
                    local optionLabel = Instance.new("TextLabel")
                    
                    optionButton.Name = "Option"
                    optionButton.Parent = optionsScroll
                    optionButton.BackgroundTransparency = 1
                    optionButton.Size = UDim2.new(1, 0, 0, 40)
                    optionButton.Image = "rbxassetid://80999662900595"
                    optionButton.ImageTransparency = 1
                    optionButton.ScaleType = Enum.ScaleType.Slice
                    
                    optionLabel.Parent = optionButton
                    optionLabel.BackgroundTransparency = 1
                    optionLabel.Position = UDim2.new(0, 10, 0, 0)
                    optionLabel.Size = UDim2.new(1, -10, 1, 0)
                    optionLabel.Font = Enum.Font.Arial
                    optionLabel.Text = value
                    optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionLabel.TextSize = 14
                    optionLabel.TextTransparency = 0.5
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    
                    optionButton.Activated:Connect(function()
                        if config.Multi then
                            if optionLabel.TextTransparency >= 0.5 then
                                table.insert(self.Select, optionLabel.Text)
                            else
                                for i, selected in ipairs(self.Select) do
                                    if selected == optionLabel.Text then
                                        table.remove(self.Select, i)
                                        break
                                    end
                                end
                            end
                            self:Set(self.Select)
                        else
                            self.Select = {optionLabel.Text}
                            self:Set(self.Select)
                        end
                    end)
                end
                
                function dropdownMethods:Refresh(values)
                    self.Select = {}
                    self:Set(self.Select)
                    
                    -- Clear existing options
                    for _, option in pairs(optionsScroll:GetChildren()) do
                        if option:IsA("ImageButton") then
                            option:Destroy()
                        end
                    end
                    
                    -- Add new options
                    for _, value in ipairs(values) do
                        self:Add(value)
                    end
                end
                
                -- Initialize
                dropdownMethods:Refresh(config.Values)
                dropdownMethods:Set(type(config.Default) == "string" and {config.Default} or config.Default)
                
                return dropdownMethods
            end
            
            -- Input control
            function tabMethods:AddInput(config)
                config = config or {}
                config.Title = config.Title or "Input"
                config.Description = config.Description or ""
                config.PlaceHolder = config.PlaceHolder or ""
                config.Default = config.Default or ""
                config.Callback = config.Callback or function() end
                
                local inputFrame = Instance.new("Frame")
                local inputBackground = Instance.new("ImageLabel")
                local titleLabel = Instance.new("TextLabel")
                local descLabel = Instance.new("TextLabel")
                local inputStroke = Instance.new("ImageLabel")
                local inputField = Instance.new("ImageButton")
                local inputContainer = Instance.new("Frame")
                local inputIcon = Instance.new("ImageLabel")
                local textBox = Instance.new("TextBox")
                
                -- Input frame
                inputFrame.Name = "Input"
                inputFrame.Parent = tabChannel
                inputFrame.BackgroundTransparency = 1
                inputFrame.Size = UDim2.new(1, 0, 0, 95)
                
                -- Background
                inputBackground.Name = "Background"
                inputBackground.Parent = inputFrame
                inputBackground.Active = true
                inputBackground.BackgroundTransparency = 1
                inputBackground.Size = UDim2.new(1, 0, 1, 0)
                inputBackground.Image = "rbxassetid://80999662900595"
                inputBackground.ImageTransparency = 0.95
                inputBackground.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = inputBackground
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 8)
                titleLabel.Size = UDim2.new(1, -80, 0, 18)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Description
                if config.Description and config.Description ~= "" then
                    descLabel.Name = "Desc"
                    descLabel.Parent = inputBackground
                    descLabel.BackgroundTransparency = 1
                    descLabel.Position = UDim2.new(0, 15, 0, 26)
                    descLabel.Size = UDim2.new(1, -80, 1, -60)
                    descLabel.Font = Enum.Font.Arial
                    descLabel.Text = config.Description
                    descLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    descLabel.TextSize = 13
                    descLabel.TextWrapped = true
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextYAlignment = Enum.TextYAlignment.Top
                    descLabel.RichText = true
                    
                    self.Stepped:Connect(function()
                        inputFrame.Size = UDim2.new(1, 0, 0, math.max(descLabel.TextBounds.Y + 50, 100))
                    end)
                end
                
                -- Input field
                inputStroke.Name = "UIStroke"
                inputStroke.Parent = inputBackground
                inputStroke.AnchorPoint = Vector2.new(0, 0.5)
                inputStroke.BackgroundTransparency = 1
                inputStroke.Position = UDim2.new(0, 10, 0.7, 0)
                inputStroke.Size = UDim2.new(1, -20, 0, 35)
                inputStroke.Image = "rbxassetid://117788349049947"
                inputStroke.ImageTransparency = 0.85
                inputStroke.ScaleType = Enum.ScaleType.Slice
                
                inputField.Name = "Click"
                inputField.Parent = inputBackground
                inputField.Active = true
                inputField.AnchorPoint = Vector2.new(0, 0.5)
                inputField.BackgroundTransparency = 1
                inputField.Position = UDim2.new(0, 10, 0.7, 0)
                inputField.Selectable = true
                inputField.Size = UDim2.new(1, -20, 0, 35)
                inputField.Image = "rbxassetid://126409600467363"
                inputField.ImageTransparency = 0.94
                inputField.ScaleType = Enum.ScaleType.Slice
                
                inputContainer.Parent = inputField
                inputContainer.BackgroundTransparency = 1
                inputContainer.Size = UDim2.new(1, 0, 1, 0)
                
                inputIcon.Name = "Icon"
                inputIcon.Parent = inputContainer
                inputIcon.AnchorPoint = Vector2.new(0, 0.5)
                inputIcon.BackgroundTransparency = 1
                inputIcon.Position = UDim2.new(1, -30, 0.5, 0)
                inputIcon.Size = UDim2.new(0, 20, 0, 20)
                inputIcon.Image = "rbxassetid://126409600467363"
                inputIcon.ImageTransparency = 0.1
                
                textBox.Name = "Select"
                textBox.Parent = inputContainer
                textBox.BackgroundTransparency = 1
                textBox.ClipsDescendants = true
                textBox.Position = UDim2.new(0, 10, 0, 0)
                textBox.Selectable = false
                textBox.Size = UDim2.new(1, -50, 1, 0)
                textBox.Font = Enum.Font.Arial
                textBox.PlaceholderText = config.PlaceHolder
                textBox.Text = config.Default
                textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                textBox.TextSize = 15
                textBox.TextXAlignment = Enum.TextXAlignment.Left
                
                textBox.FocusLost:Connect(function()
                    config.Callback(textBox.Text)
                end)
            end
            
            -- Paragraph control
            function tabMethods:AddParagraph(config)
                config = config or {}
                config.Title = config.Title or "Title"
                config.Content = config.Content or ""
                config.Icon = config.Icon or ""
                config.Theme = config.Theme or "Dark"
                
                local paragraphFrame = Instance.new("Frame")
                local paragraphBackground = Instance.new("ImageLabel")
                local titleLabel = Instance.new("TextLabel")
                local contentLabel = Instance.new("TextLabel")
                local paragraphIcon = Instance.new("ImageLabel")
                
                -- Paragraph frame
                paragraphFrame.Name = config.Theme
                paragraphFrame.Parent = tabChannel
                paragraphFrame.BackgroundTransparency = 1
                paragraphFrame.Size = UDim2.new(1, 0, 0, 55)
                
                -- Background
                paragraphBackground.Name = "Background"
                paragraphBackground.Parent = paragraphFrame
                paragraphBackground.Active = true
                paragraphBackground.BackgroundTransparency = 1
                paragraphBackground.Size = UDim2.new(1, 0, 1, 0)
                paragraphBackground.Image = "rbxassetid://80999662900595"
                paragraphBackground.ImageTransparency = 0.95
                paragraphBackground.ScaleType = Enum.ScaleType.Slice
                
                -- Title
                titleLabel.Name = "Title"
                titleLabel.Parent = paragraphBackground
                titleLabel.BackgroundTransparency = 1
                titleLabel.Position = UDim2.new(0, 15, 0, 0)
                titleLabel.Size = UDim2.new(1, -80, 1, 0)
                titleLabel.Font = Enum.Font.Arial
                titleLabel.Text = config.Title
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 15
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Content
                if config.Content and config.Content ~= "" then
                    contentLabel.Name = "Desc"
                    contentLabel.Parent = paragraphBackground
                    contentLabel.BackgroundTransparency = 1
                    contentLabel.Position = UDim2.new(0, 15, 0, 26)
                    contentLabel.Size = UDim2.new(1, -80, 1, -26)
                    contentLabel.Font = Enum.Font.Arial
                    contentLabel.Text = config.Content
                    contentLabel.TextColor3 = Color3.fromRGB(144, 144, 144)
                    contentLabel.TextSize = 13
                    contentLabel.TextWrapped = true
                    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
                    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
                    contentLabel.RichText = true
                    
                    -- Adjust layout
                    titleLabel.Position = UDim2.new(0, 15, 0, 8)
                    titleLabel.Size = UDim2.new(1, -80, 0, 18)
                    
                    self.Stepped:Connect(function()
                        paragraphFrame.Size = UDim2.new(1, 0, 0, math.max(contentLabel.TextBounds.Y + 40, 60))
                    end)
                end
                
                -- Icon
                if config.Icon and config.Icon ~= "" then
                    paragraphIcon.Name = "Icon"
                    paragraphIcon.Parent = paragraphBackground
                    paragraphIcon.AnchorPoint = Vector2.new(0, 0.5)
                    paragraphIcon.BackgroundTransparency = 1
                    paragraphIcon.Position = UDim2.new(1, -40, 0.5, 0)
                    paragraphIcon.Size = UDim2.new(0, 25, 0, 25)
                    paragraphIcon.Image = config.Icon
                end
                
                -- Paragraph methods
                local paragraphMethods = {}
                
                function paragraphMethods:SetTitle(text)
                    titleLabel.Text = text
                end
                
                function paragraphMethods:SetDesc(text)
                    if contentLabel then
                        contentLabel.Text = text
                    end
                end
                
                function paragraphMethods:SetIcon(icon)
                    if paragraphIcon then
                        paragraphIcon.Image = icon
                    end
                end
                
                function paragraphMethods:SetTheme(theme)
                    if theme == "White" then
                        paragraphBackground.ImageTransparency = 0.1
                        if paragraphIcon then
                            paragraphIcon.ImageColor3 = Color3.fromRGB(40, 40, 40)
                        end
                        titleLabel.TextColor3 = Color3.fromRGB(40, 40, 40)
                    else
                        paragraphBackground.ImageTransparency = 0.95
                        if paragraphIcon then
                            paragraphIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        end
                        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
                
                paragraphMethods:SetTheme(config.Theme)
                return paragraphMethods
            end
            
            -- Separator control
            function tabMethods:AddSeperator(text, icon)
                local separatorFrame = Instance.new("Frame")
                local separatorIcon = Instance.new("ImageLabel")
                local separatorPadding = Instance.new("UIPadding")
                local separatorLabel = Instance.new("TextLabel")
                
                -- Separator frame
                separatorFrame.Name = "Seperator"
                separatorFrame.Parent = tabChannel
                separatorFrame.BackgroundTransparency = 1
                separatorFrame.Size = UDim2.new(1, 0, 0, 40)
                
                -- Icon (optional)
                if icon and icon ~= "" then
                    separatorIcon.Parent = separatorFrame
                    separatorIcon.AnchorPoint = Vector2.new(0, 0.5)
                    separatorIcon.BackgroundTransparency = 1
                    separatorIcon.Position = UDim2.new(0, 0, 0.5, 0)
                    separatorIcon.Size = UDim2.new(0, 25, 0, 25)
                    separatorIcon.Image = icon
                    
                    separatorPadding.Parent = separatorFrame
                    separatorPadding.PaddingLeft = UDim.new(0, 7)
                    
                    separatorLabel.Parent = separatorFrame
                    separatorLabel.AnchorPoint = Vector2.new(0, 0.5)
                    separatorLabel.BackgroundTransparency = 1
                    separatorLabel.Position = UDim2.new(0, 35, 0.5, 0)
                    separatorLabel.Size = UDim2.new(1, -50, 1, 0)
                    separatorLabel.Font = Enum.Font.Arial
                    separatorLabel.Text = text or ""
                    separatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    separatorLabel.TextSize = 14
                    separatorLabel.TextXAlignment = Enum.TextXAlignment.Left
                else
                    -- Simple line separator
                    separatorLabel.Parent = separatorFrame
                    separatorLabel.BackgroundTransparency = 1
                    separatorLabel.Position = UDim2.new(0, 0, 0, 0)
                    separatorLabel.Size = UDim2.new(1, 0, 1, 0)
                    separatorLabel.Font = Enum.Font.Arial
                    separatorLabel.Text = text or ""
                    separatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    separatorLabel.TextSize = 17
                    separatorLabel.TextXAlignment = Enum.TextXAlignment.Left
                end
            end
            
            return tabMethods
        end
        
        return sectionMethods
    end
    
    return windowMethods
end

return Lunox
