repeat task.wait() until game:IsLoaded()
local library = {currentTab = nil, flags = {}}
local ToggleUI = false
local services = setmetatable({}, {
    __index = function(t, k) return game:GetService(k) end
})
local mouse = services.Players.LocalPlayer:GetMouse()
-- 优化配色：更柔和的深色调+清新 accent，降低视觉疲劳
local COLORS = {
    MAIN = Color3.fromRGB(25, 28, 35),
    BACKGROUND = Color3.fromRGB(32, 36, 45),
    ELEMENT = Color3.fromRGB(45, 50, 60),
    ACCENT = Color3.fromRGB(76, 201, 240),
    TEXT = Color3.fromRGB(230, 230, 230),
    HIGHLIGHT = Color3.fromRGB(56, 178, 214),
    SHADOW = Color3.fromRGB(15, 18, 22)
}
local ALTransparency = 0.55
-- 优化动画函数：增加缓动多样性，统一时长参数
function Tween(obj, t, data)
    local tweenInfo = TweenInfo.new(
        t.duration or 0.3,
        Enum.EasingStyle[t.style] or Enum.EasingStyle.Quad,
        Enum.EasingDirection[t.dir] or Enum.EasingDirection.Out,
        t.repeatCount or 0,
        t.reverse or false,
        t.delay or 0
    )
    services.TweenService:Create(obj, tweenInfo, data):Play()
    return true
end
-- 重写涟漪效果：更自然的扩散+淡入淡出，替换旧图片ID
function Ripple(obj)
    spawn(function()
        obj.ClipsDescendants = true
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 8
        -- 替换为柔和圆形波纹图片（浅蓝色系，适配新配色）
        Ripple.Image = "rbxassetid://1287537502"
        Ripple.ImageTransparency = 0.7
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = COLORS.ACCENT
        Ripple.ImageRectOffset = Vector2.new(0, 0)
        Ripple.ImageRectSize = Vector2.new(512, 512)
        
        -- 基于鼠标位置精准定位涟漪起点
        local objPos = obj.AbsolutePosition
        local rippleSize = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        Ripple.Position = UDim2.new(
            (mouse.X - objPos.X) / obj.AbsoluteSize.X, 0,
            (mouse.Y - objPos.Y) / obj.AbsoluteSize.Y, 0
        )
        
        -- 分阶段动画：先快速扩散+淡入，再缓慢淡出
        Tween(Ripple, {duration = 0.25, style = "Circ", dir = "Out"}, {
            Size = UDim2.new(0, rippleSize, 0, rippleSize),
            ImageTransparency = 0.4
        })
        wait(0.2)
        Tween(Ripple, {duration = 0.4, style = "Quad", dir = "Out"}, {
            ImageTransparency = 1
        })
        wait(0.4)
        Ripple:Destroy()
    end)
end
-- 增强按钮悬停效果：增加缩放+阴影变化
function SetupHoverEffect(button, normalColor, hoverColor)
    -- 初始化按钮阴影
    if not button:FindFirstChild("HoverShadow") then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "HoverShadow"
        shadow.Parent = button
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1287537502"
        shadow.ImageColor3 = COLORS.SHADOW
        shadow.ImageTransparency = 0.7
        shadow.ScaleType = Enum.ScaleType.Fit
        shadow.Size = UDim2.new(1, 4, 1, 4)
        shadow.Position = UDim2.new(0, -2, 0, -2)
        shadow.ZIndex = button.ZIndex - 1
    end
    local shadow = button.HoverShadow
    
    button.MouseEnter:Connect(function()
        Tween(button, {duration = 0.2, style = "Quad"}, {
            BackgroundColor3 = hoverColor,
            Size = button.Size + UDim2.new(0, 2, 0, 2)
        })
        Tween(shadow, {duration = 0.2, style = "Quad"}, {
            Size = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0, -4, 0, -4),
            ImageTransparency = 0.5
        })
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {duration = 0.2, style = "Quad"}, {
            BackgroundColor3 = normalColor,
            Size = button.Size - UDim2.new(0, 2, 0, 2)
        })
        Tween(shadow, {duration = 0.2, style = "Quad"}, {
            Size = UDim2.new(1, 4, 1, 4),
            Position = UDim2.new(0, -2, 0, -2),
            ImageTransparency = 0.7
        })
    end)
end
-- 优化标签切换动画：增加位移+透明度过渡
local switchingTabs = false
function switchTab(new)
    if switchingTabs or (library.currentTab and library.currentTab[1] == new[1]) then return end
    switchingTabs = true
    
    local old = library.currentTab
    library.currentTab = new
    if old then
        -- 旧标签：缩小+褪色+轻微下移
        Tween(old[1], {duration = 0.2, style = "Quad"}, {
            ImageTransparency = 0.6,
            Size = UDim2.new(0, 22, 0, 22),
            Position = old[1].Position + UDim2.new(0, 0, 0, 3)
        })
        Tween(old[1].TabText, {duration = 0.2, style = "Quad"}, {
            TextTransparency = 0.6,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Position = old[1].TabText.Position + UDim2.new(0, 0, 0, 3)
        })
        -- 旧标签内容：淡入淡出切换
        Tween(old[2], {duration = 0.15, style = "Quad"}, {
            Transparency = 1
        })
        wait(0.15)
        old[2].Visible = false
        Tween(old[2], {duration = 0, style = "Quad"}, {
            Transparency = 0
        })
    end
    -- 新标签：放大+高亮+轻微上移
    Tween(new[1], {duration = 0.2, style = "Quad"}, {
        ImageTransparency = 0,
        Size = UDim2.new(0, 29, 0, 29),
        Position = new[1].Position - UDim2.new(0, 0, 0, 3)
    })
    Tween(new[1].TabText, {duration = 0.2, style = "Quad"}, {
        TextTransparency = 0,
        TextColor3 = COLORS.ACCENT,
        Position = new[1].TabText.Position - UDim2.new(0, 0, 0, 3)
    })
    new[2].Visible = true
    -- 新标签内容：淡入效果
    Tween(new[2], {duration = 0.2, style = "Quad"}, {
        Transparency = 0
    })
    
    task.wait(0.2)
    switchingTabs = false
    -- 重置标签位置（避免累积偏移）
    if old then
        Tween(old[1], {duration = 0, style = "Quad"}, {Position = old[1].Position - UDim2.new(0, 0, 0, 3)})
        Tween(old[1].TabText, {duration = 0, style = "Quad"}, {Position = old[1].TabText.Position - UDim2.new(0, 0, 0, 3)})
    end
    Tween(new[1], {duration = 0, style = "Quad"}, {Position = new[1].Position + UDim2.new(0, 0, 0, 3)})
    Tween(new[1].TabText, {duration = 0, style = "Quad"}, {Position = new[1].TabText.Position + UDim2.new(0, 0, 0, 3)})
end
-- 优化拖动功能：增加窗口缩放反馈+平滑移动
function drag(frame, hold)
    hold = hold or frame
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        -- 平滑移动：基于鼠标位移比例计算
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- 限制窗口在屏幕内
        local screenSize = services.Workspace.CurrentCamera.ViewportSize
        local maxX = screenSize.X - frame.AbsoluteSize.X
        local maxY = screenSize.Y - frame.AbsoluteSize.Y
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, 0, maxX),
            0, math.clamp(newPos.Y.Offset, 0, maxY)
        )
        Tween(frame, {duration = 0.05, style = "Linear"}, {Position = newPos})
    end
    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            -- 拖动时窗口轻微缩小+阴影加深
            Tween(frame, {duration = 0.1, style = "Quad"}, {
                Size = frame.Size - UDim2.new(0, 6, 0, 6),
                BackgroundColor3 = COLORS.BACKGROUND:lerp(COLORS.SHADOW, 0.1)
            })
            Tween(frame.DropShadowHolder.DropShadow, {duration = 0.1, style = "Quad"}, {
                ImageTransparency = 0.6,
                Size = UDim2.new(1, 14, 1, 14)
            })
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- 释放时窗口恢复+弹性反馈
                    Tween(frame, {duration = 0.15, style = "Elastic", dir = "Out"}, {
                        Size = frame.Size + UDim2.new(0, 6, 0, 6),
                        BackgroundColor3 = COLORS.BACKGROUND
                    })
                    Tween(frame.DropShadowHolder.DropShadow, {duration = 0.15, style = "Quad"}, {
                        ImageTransparency = 0.8,
                        Size = UDim2.new(1, 10, 1, 10)
                    })
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end
-- UI创建函数：全面优化视觉层级与动画
function library.new(name)
    -- 清理旧UI
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty" then v:Destroy() end
    end
    local dogent = Instance.new("ScreenGui")
    dogent.Name = "frosty"
    if syn and syn.protect_gui then syn.protect_gui(dogent) end
    dogent.Parent = services.CoreGui
    -- 主窗口：增加边框+分层阴影
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = COLORS.BACKGROUND
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.Active = true
    Main.Draggable = false -- 禁用默认拖动，使用自定义拖动
    -- 主窗口边框
    local MainBorder = Instance.new("Frame")
    MainBorder.Name = "MainBorder"
    MainBorder.Parent = Main
    MainBorder.BackgroundColor3 = COLORS.ELEMENT
    MainBorder.Size = UDim2.new(1, -2, 1, -2)
    MainBorder.Position = UDim2.new(0, 1, 0, 1)
    MainBorder.ZIndex = 1
    local MainBorderCorner = Instance.new("UICorner")
    MainBorderCorner.CornerRadius = UDim.new(0, 7)
    MainBorderCorner.Parent = MainBorder
    -- 主窗口内容容器（避免边框遮挡）
    local MainContent = Instance.new("Frame")
    MainContent.Name = "MainContent"
    MainContent.Parent = MainBorder
    MainContent.BackgroundTransparency = 1
    MainContent.Size = UDim2.new(1, 0, 1, 0)
    MainContent.ZIndex = 2
    
    -- 优化阴影效果：双层阴影增强层次感
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Main
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder.ZIndex = 0
    
    local OuterShadow = Instance.new("ImageLabel")
    OuterShadow.Name = "OuterShadow"
    OuterShadow.Parent = DropShadowHolder
    OuterShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterShadow.BackgroundTransparency = 1
    OuterShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    OuterShadow.Size = UDim2.new(1, 20, 1, 20)
    OuterShadow.Image = "rbxassetid://1287537502"
    OuterShadow.ImageColor3 = COLORS.SHADOW
    OuterShadow.ImageTransparency = 0.4
    OuterShadow.ScaleType = Enum.ScaleType.Slice
    OuterShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    OuterShadow.ZIndex = -2
    
    local InnerShadow = Instance.new("ImageLabel")
    InnerShadow.Name = "InnerShadow"
    InnerShadow.Parent = DropShadowHolder
    InnerShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerShadow.BackgroundTransparency = 1
    InnerShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerShadow.Size = UDim2.new(1, 10, 1, 10)
    InnerShadow.Image = "rbxassetid://1287537502"
    InnerShadow.ImageColor3 = COLORS.SHADOW
    InnerShadow.ImageTransparency = 0.8
    InnerShadow.ScaleType = Enum.ScaleType.Slice
    InnerShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    InnerShadow.ZIndex = -1
    
    -- 圆角：适配边框
    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 8)
    UICornerMain.Parent = Main
    -- 应用自定义拖动功能
    drag(Main, MainContent)
    -- 控制显示/隐藏：增加淡入淡出动画
    local function toggleUI(visible)
        if visible == nil then visible = not Main.Visible end
        Main.Visible = true
        if visible then
            Tween(Main, {duration = 0.3, style = "Circ"}, {
                Size = UDim2.new(0, 572, 0, 353),
                Transparency = 0
            })
            Tween(OuterShadow, {duration = 0.3, style = "Circ"}, {
                Size = UDim2.new(1, 20, 1, 20),
                ImageTransparency = 0.4
            })
        else
            Tween(Main, {duration = 0.25, style = "Circ"}, {
                Size = UDim2.new(0, 0, 0, 0),
                Transparency = 1
            })
            Tween(OuterShadow, {duration = 0.25, style = "Circ"}, {
                Size = UDim2.new(0, 0, 0, 0),
                ImageTransparency = 1
            })
            wait(0.25)
            Main.Visible = false
        end
    end
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            toggleUI()
        end
    end)
    -- 入场动画：从中心放大+渐显
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Transparency = 1
    OuterShadow.Size = UDim2.new(0, 0, 0, 0)
    OuterShadow.ImageTransparency = 1
    Main.Visible = true
    Tween(Main, {duration = 0.5, style = "Circ", dir = "Out"}, {
        Size = UDim2.new(0, 572, 0, 353),
        Transparency = 0
    })
    Tween(OuterShadow, {duration = 0.5, style = "Circ", dir = "Out"}, {
        Size = UDim2.new(1, 20, 1, 20),
        ImageTransparency = 0.4
    })
    -- 标签容器：移至内容容器内
    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = MainContent
    TabMain.BackgroundTransparency = 1
    TabMain.Position = UDim2.new(0.217, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 353)
    TabMain.ZIndex = 3
    -- 侧边栏：增加渐变背景
    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.Parent = MainContent
    Side.BackgroundColor3 = COLORS.MAIN
    Side.Position = UDim2.new(0, 0, 0, 0)
    Side.Size = UDim2.new(0, 120, 0, 353)
    Side.ZIndex = 3
    -- 侧边栏渐变效果
    local SideGradient = Instance.new("UIGradient")
    SideGradient.Name = "SideGradient"
    SideGradient.Parent = Side
    SideGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.MAIN),
        ColorSequenceKeypoint.new(1, COLORS.ELEMENT)
    })
    SideGradient.Rotation = 90
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 7)
    SideCorner.Parent = Side
    -- 标签按钮容器
    local TabBtns = Instance.new("ScrollingFrame")
    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundTransparency = 1
    TabBtns.Position = UDim2.new(0, 10, 0.097, 0)
    TabBtns.Size = UDim2.new(0, 100, 0, 300)
    TabBtns.ScrollBarThickness = 3
    TabBtns.ScrollBarImageColor3 = COLORS.ACCENT
    TabBtns.ScrollBarImageTransparency = 0.5
    TabBtns.ZIndex = 4
    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)
    -- 标题：增加文字阴影
    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Position = UDim2.new(0, 10, 0.01, 0)
    ScriptTitle.Size = UDim2.new(0, 100, 0, 30)
    ScriptTitle.Font = Enum.Font.GothamBold
    ScriptTitle.Text = name or "Frosty UI"
    ScriptTitle.TextColor3 = COLORS.ACCENT
    ScriptTitle.TextSize = 16
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
    ScriptTitle.ZIndex = 4
    -- 标题文字阴影
    local TitleShadow = Instance.new("TextLabel")
    TitleShadow.Name = "TitleShadow"
    TitleShadow.Parent = ScriptTitle
    TitleShadow.BackgroundTransparency = 1
    TitleShadow.Position = UDim2.new(0, 1, 0, 1)
    TitleShadow.Size = UDim2.new(1, 0, 1, 0)
    TitleShadow.Font = Enum.Font.GothamBold
    TitleShadow.Text = ScriptTitle.Text
    TitleShadow.TextColor3 = COLORS.SHADOW
    TitleShadow.TextSize = 16
    TitleShadow.TextXAlignment = Enum.TextXAlignment.Left
    TitleShadow.ZIndex = 3
    -- 打开/关闭按钮：替换图标+优化动画
    local OpenBtn = Instance.new("ImageButton")
    OpenBtn.Name = "Open"
    OpenBtn.Parent = dogent
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Position = UDim2.new(0.008, 0, 0.311, 0)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    -- 替换为简约图标（适配新UI风格）
    OpenBtn.Image = "rbxassetid://1462490707"
    OpenBtn.ImageColor3 = COLORS.ACCENT
    OpenBtn.ImageTransparency = 0.8
    OpenBtn.ZIndex = 10
    -- 按钮悬停效果：增加缩放+透明度变化
    SetupHoverEffect(OpenBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
    OpenBtn.MouseButton1Click:Connect(function()
        toggleUI()
        -- 切换图标+弹性动画
        local newIcon = Main.Visible and "rbxassetid://1462490707" or "rbxassetid://1462490707"
        local newSize = Main.Visible and UDim2.new(0, 45, 0, 45) or UDim2.new(0, 55, 0, 55)
        Tween(OpenBtn, {duration = 0.15, style = "Elastic", dir = "Out"}, {Size = newSize})
        wait(0.1)
        OpenBtn.Image = newIcon
        Tween(OpenBtn, {duration = 0.15, style = "Elastic", dir = "Out"}, {Size = UDim2.new(0, 50, 0, 50)})
        -- 按钮透明度变化
        Tween(OpenBtn, {duration = 0.2, style = "Quad"}, {
            ImageTransparency = Main.Visible and 0.8 or 0.6
        })
    end)
    -- 自动调整滚动区域大小
    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 20)
    end)
    local window = {}
    function window:Tab(name, icon)
        local Tab = Instance.new("Frame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.Transparency = 0
        Tab.ZIndex = 3
        local TabScroll = Instance.new("ScrollingFrame")
        TabScroll.Name = "TabScroll"
        TabScroll.Parent = Tab
        TabScroll.Active = true
        TabScroll.BackgroundTransparency = 1
        TabScroll.Size = UDim2.new(1, 0, 1, 0)
        TabScroll.ScrollBarThickness = 5
        TabScroll.ScrollBarImageColor3 = COLORS.ACCENT
        TabScroll.ScrollBarImageTransparency = 0.5
        TabScroll.Visible = false
        TabScroll.ZIndex = 4
        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = TabScroll
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 12)
        TabL.Padding = UDim.new(0, 8)
        -- 标签图标：优化样式
        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = icon or "rbxassetid://1462490707"
        TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = COLORS.TEXT
        TabIco.ZIndex = 4
        -- 标签文本
        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.417, 0, 0, 0)
        TabText.Size = UDim2.new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        TabText.ZIndex = 4
        -- 标签按钮
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.Text = ""
        TabBtn.ZIndex = 5
        -- 标签悬停效果
        SetupHoverEffect(TabBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({TabIco, TabScroll})
        end)
        if not library.currentTab then 
            switchTab({TabIco, TabScroll})
        end
        -- 自动调整标签内容大小
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 16)
        end)
        local tab = {}
        function tab:Section(name, isOpen)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = TabScroll
            Section.BackgroundColor3 = COLORS.ELEMENT
            Section.Size = UDim2.new(0.98, 0, 0, 40)
            Section.ClipsDescendants = true
            Section.ZIndex = 4
            -- 区域渐变背景
            local SectionGradient = Instance.new("UIGradient")
            SectionGradient.Name = "SectionGradient"
            SectionGradient.Parent = Section
            SectionGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, COLORS.ELEMENT),
                ColorSequenceKeypoint.new(1, COLORS.MAIN:lerp(COLORS.ELEMENT, 0.5))
            })
            SectionGradient.Rotation = 90
            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Parent = Section
            -- 区域标题：增加左侧 accent 线条
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 40)
            SectionHeader.ZIndex = 5
            
            local SectionLine = Instance.new("Frame")
            SectionLine.Name = "SectionLine"
            SectionLine.Parent = SectionHeader
            SectionLine.BackgroundColor3 = COLORS.ACCENT
            SectionLine.Position = UDim2.new(0, 0, 0, 10)
            SectionLine.Size = UDim2.new(0, 4, 0, 20)
            SectionLine.ZIndex = 5
            local SectionLineCorner = Instance.new("UICorner")
            SectionLineCorner.CornerRadius = UDim.new(0, 2)
            SectionLineCorner.Parent = SectionLine
            
            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = SectionHeader
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.05, 0, 0, 0)
            SectionText.Size = UDim2.new(0.9, 0, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = COLORS.TEXT
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            SectionText.ZIndex = 5
            
            local SectionToggle = Instance.new("TextButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            SectionToggle.Text = ""
            SectionToggle.ZIndex = 6
            
            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.Position = UDim2.new(0, 10, 0, 45)
            Objs.Size = UDim2.new(0.95, 0, 0, 0)
            Objs.ZIndex = 5
            
            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 10)
            
            local open = isOpen ~= false
            local function updateSectionSize()
                local targetHeight = open and (50 + ObjsL.AbsoluteContentSize.Y + 10) or 40
                Tween(Section, {duration = 0.2, style = "Quad"}, {
                    Size = UDim2.new(0.98, 0, 0, targetHeight)
                })
            end
            if isOpen ~= false then
                updateSectionSize()
            end
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                updateSectionSize()
                -- 切换时内容淡入淡出
                if open then
                    Tween(Objs, {duration = 0.2, style = "Quad"}, {Transparency = 0})
                else
                    Tween(Objs, {duration = 0.15, style = "Quad"}, {Transparency = 1})
                end
            end)
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionSize()
                end
            end)
            -- 初始化内容透明度
            Objs.Transparency = open and 0 or 1
            
            local section = {}
            function section:Button(text, callback)
                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.Size = UDim2.new(1, 0, 0, 40)
                BtnModule.ZIndex = 5
                
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = COLORS.MAIN
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = COLORS.TEXT
                Btn.TextSize = 14
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.ZIndex = 5
                
                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn
                
                -- 按钮左侧 accent 条
                local BtnAccent = Instance.new("Frame")
                BtnAccent.Name = "BtnAccent"
                BtnAccent.Parent = Btn
                BtnAccent.BackgroundColor3 = COLORS.ACCENT
                BtnAccent.Position = UDim2.new(0, 0, 0, 0)
                BtnAccent.Size = UDim2.new(0, 3, 1, 0)
                BtnAccent.ZIndex = 6
                
                -- 按钮效果
                SetupHoverEffect(Btn, COLORS.MAIN, COLORS.ELEMENT)
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    if callback then 
                        -- 点击动画：轻微收缩+颜色变化
                        Tween(Btn, {duration = 0.1, style = "Quad"}, {
                            Size = UDim2.new(0.98, 0, 0, 38),
                            BackgroundColor3 = COLORS.ELEMENT:lerp(COLORS.SHADOW, 0.2)
                        })
                        wait(0.1)
                        Tween(Btn, {duration = 0.15, style = "Elastic", dir = "Out"}, {
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundColor3 = COLORS.MAIN
                        })
                        callback() 
                    end
                end)
                return Btn
            end
            function section:Toggle(text, flag, enabled, callback)
                enabled = enabled or false
                library.flags[flag] = enabled
                local ToggleModule = Instance.new("Frame")
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.Size = UDim2.new(1, 0, 0, 40)
                ToggleModule.ZIndex = 5
                
                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = COLORS.MAIN
                ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = COLORS.TEXT
                ToggleBtn.TextSize = 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                ToggleBtn.ZIndex = 5
                
                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn
                
                -- 开关左侧 accent 条
                local ToggleAccent = Instance.new("Frame")
                ToggleAccent.Name = "ToggleAccent"
                ToggleAccent.Parent = ToggleBtn
                ToggleAccent.BackgroundColor3 = COLORS.ACCENT
                ToggleAccent.Position = UDim2.new(0, 0, 0, 0)
                ToggleAccent.Size = UDim2.new(0, 3, 1, 0)
                ToggleAccent.ZIndex = 6
                
                -- 优化开关样式：更圆润的滑块
                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and COLORS.ACCENT or Color3.fromRGB(80, 80, 80)
                ToggleSwitch.Position = UDim2.new(0.85, enabled and 26 or 0, 0.2, 0)
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 24)
                ToggleSwitch.ZIndex = 5
                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 12)
                ToggleSwitchC.Parent = ToggleSwitch
                
                -- 滑块：增加阴影效果
                local ToggleKnob = Instance.new("Frame")
                ToggleKnob.Name = "ToggleKnob"
                ToggleKnob.Parent = ToggleSwitch
                ToggleKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
                ToggleKnob.Position = UDim2.new(0, enabled and 26 or 2, 0, 1)
                ToggleKnob.ZIndex = 6
                local ToggleKnobC = Instance.new("UICorner")
                ToggleKnobC.CornerRadius = UDim.new(0, 11)
                ToggleKnobC.Parent = ToggleKnob
                local KnobShadow = Instance.new("Frame")
                KnobShadow.Name = "KnobShadow"
                KnobShadow.Parent = ToggleKnob
                KnobShadow.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
                KnobShadow.Size = UDim2.new(1, 0, 1, 0)
                KnobShadow.Position = UDim2.new(0, 0, 0, 1)
                KnobShadow.ZIndex = 5
                local KnobShadowC = Instance.new("UICorner")
                KnobShadowC.CornerRadius = UDim.new(0, 11)
                KnobShadowC.Parent = KnobShadow
                
                -- 悬停效果
                SetupHoverEffect(ToggleBtn, COLORS.MAIN, COLORS.ELEMENT)
                local funcs = {
                    SetState = function(self, state)
                        state = state or not library.flags[flag]
                        if library.flags[flag] == state then return end
                        
                        -- 开关动画：颜色+滑块位置同步变化
                        Tween(ToggleSwitch, {duration = 0.2, style = "Quad"}, {
                            BackgroundColor3 = state and COLORS.ACCENT or Color3.fromRGB(80, 80, 80)
                        })
                        Tween(ToggleKnob, {duration = 0.2, style = "Circ", dir = "Out"}, {
                            Position = UDim2.new(0, state and 26 or 2, 0, 1)
                        })
                        Tween(KnobShadow, {duration = 0.2, style = "Circ", dir = "Out"}, {
                            Position = UDim2.new(0, state and 0 or 0, 0, 1)
                        })
                        
                        library.flags[flag] = state
                        if callback then callback(state) end
                    end
                }
                if enabled then funcs:SetState(true) end
                ToggleBtn.MouseButton1Click:Connect(function()
                    Ripple(ToggleBtn)
                    funcs:SetState()
                end)
                return funcs
            end
            return section
        end
        return tab
    end
    return window
end
return library
