repeat task.wait() until game:IsLoaded()
local library = {currentTab = nil, flags = {}}
local ToggleUI = false

local services = setmetatable({}, {
    __index = function(t, k) return game:GetService(k) end
})

local mouse = services.Players.LocalPlayer:GetMouse()

-- 颜色配置
local COLORS = {
    MAIN = Color3.fromRGB(15, 15, 15),
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    ELEMENT = Color3.fromRGB(35, 35, 35),
    ACCENT = Color3.fromRGB(0, 255, 0),
    TEXT = Color3.fromRGB(220, 220, 220),
    HIGHLIGHT = Color3.fromRGB(0, 180, 0)
}

local ALTransparency = 0.6

-- 动画函数
function Tween(obj, t, data)
    services.TweenService:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data):Play()
    return true
end

-- 涟漪效果
function Ripple(obj)
    spawn(function()
        obj.ClipsDescendants = true
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://18941591417"
        Ripple.ImageTransparency = 0.8
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = COLORS.ACCENT
        Ripple.Position = UDim2.new((mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X, 0, 
                                  (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y, 0)
        
        Tween(Ripple, {0.3, 'Quad', 'Out'}, {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)})
        wait(0.15)
        Tween(Ripple, {0.3, 'Quad', 'Out'}, {ImageTransparency = 1})
        wait(0.3)
        Ripple:Destroy()
    end)
end

-- 按钮悬停效果
function SetupHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        Tween(button, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = hoverColor})
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = normalColor})
    end)
end

-- 标签切换
local switchingTabs = false
function switchTab(new)
    if switchingTabs or (library.currentTab and library.currentTab[1] == new[1]) then return end
    switchingTabs = true
    
    local old = library.currentTab
    library.currentTab = new

    if old then
        Tween(old[1], {0.15, 'Quad', 'Out'}, {ImageTransparency = 0.5, Size = UDim2.new(0, 24, 0, 24)})
        Tween(old[1].TabText, {0.15, 'Quad', 'Out'}, {TextTransparency = 0.5, TextColor3 = Color3.fromRGB(150, 150, 150)})
        old[2].Visible = false
    end

    Tween(new[1], {0.15, 'Quad', 'Out'}, {ImageTransparency = 0, Size = UDim2.new(0, 28, 0, 28)})
    Tween(new[1].TabText, {0.15, 'Quad', 'Out'}, {TextTransparency = 0, TextColor3 = COLORS.ACCENT})
    new[2].Visible = true
    
    task.wait(0.15)
    switchingTabs = false
end

-- 拖动功能 (从笑屁UI提取)
function drag(frame, hold)
    hold = hold or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            -- 添加点击效果
            Tween(frame, {0.1, 'Quad', 'Out'}, {Size = frame.Size + UDim2.new(0, -4, 0, -4)})
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(frame, {0.1, 'Quad', 'Out'}, {Size = frame.Size + UDim2.new(0, 4, 0, 4)})
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

-- UI创建函数
function library.new(name)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty" then v:Destroy() end
    end

    local dogent = Instance.new("ScreenGui")
    dogent.Name = "frosty"
    if syn and syn.protect_gui then syn.protect_gui(dogent) end
    dogent.Parent = services.CoreGui

    -- 主窗口
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = COLORS.BACKGROUND
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.Active = true
    Main.Draggable = true
    
    -- 添加阴影效果
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Main
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder.ZIndex = 0

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 10, 1, 10)
    DropShadow.Image = "rbxassetid://18930485323"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.8
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.ZIndex = -1

    -- 圆角
    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 8)
    UICornerMain.Parent = Main

    -- 应用拖动功能
    drag(Main)

    -- 控制显示/隐藏
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    -- 入场动画
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Visible = true
    Tween(Main, {0.5, 'Quad', 'Out'}, {Size = UDim2.new(0, 572, 0, 353)})

    -- 标签容器
    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundTransparency = 1
    TabMain.Position = UDim2.new(0.217, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 353)

    -- 侧边栏
    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.Parent = Main
    Side.BackgroundColor3 = COLORS.MAIN
    Side.Position = UDim2.new(0, 0, 0, 0)
    Side.Size = UDim2.new(0, 120, 0, 353)

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
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

    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)

    -- 标题
    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Position = UDim2.new(0, 10, 0.01, 0)
    ScriptTitle.Size = UDim2.new(0, 100, 0, 30)
    ScriptTitle.Font = Enum.Font.GothamBold
    ScriptTitle.Text = name or "UI Library"
    ScriptTitle.TextColor3 = COLORS.ACCENT
    ScriptTitle.TextSize = 16
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- 打开/关闭按钮
    local OpenBtn = Instance.new("ImageButton")
    OpenBtn.Name = "Open"
    OpenBtn.Parent = dogent
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Position = UDim2.new(0.008, 0, 0.311, 0)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Image = "rbxassetid://18942159845"
    OpenBtn.ImageColor3 = COLORS.ACCENT
    
    -- 按钮悬停效果
    SetupHoverEffect(OpenBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))

    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        OpenBtn.Image = Main.Visible and "rbxassetid://18941591417" or "rbxassetid://18930445827"
        
        -- 按钮点击动画
        Tween(OpenBtn, {0.1, 'Quad', 'Out'}, {Size = UDim2.new(0, 45, 0, 45)})
        wait(0.1)
        Tween(OpenBtn, {0.1, 'Quad', 'Out'}, {Size = UDim2.new(0, 50, 0, 50)})
    end)

    -- 自动调整滚动区域大小
    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 20)
    end)

    local window = {}
    function window:Tab(name, icon)
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 5
        Tab.ScrollBarImageColor3 = COLORS.ACCENT
        Tab.Visible = false

        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 8)

        -- 标签图标
        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = icon or "rbxassetid://18941716391"
        TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = COLORS.TEXT

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

        -- 标签按钮
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.Text = ""
        
        -- 标签悬停效果
        SetupHoverEffect(TabBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))

        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({TabIco, Tab})
        end)

        if not library.currentTab then 
            switchTab({TabIco, Tab})
        end

        -- 自动调整标签内容大小
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 16)
        end)

        local tab = {}
        function tab:Section(name, isOpen)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = COLORS.ELEMENT
            Section.Size = UDim2.new(0.98, 0, 0, 40)
            Section.ClipsDescendants = true

            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Parent = Section

            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.05, 0, 0, 0)
            SectionText.Size = UDim2.new(0.9, 0, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = COLORS.TEXT
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left

            local SectionToggle = Instance.new("TextButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionText
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            SectionToggle.Text = ""

            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.Position = UDim2.new(0, 10, 0, 45)
            Objs.Size = UDim2.new(0.95, 0, 0, 0)

            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 10)

            local open = isOpen ~= false
            if isOpen ~= false then
                Section.Size = UDim2.new(0.98, 0, 0, open and 50 + ObjsL.AbsoluteContentSize.Y + 10 or 40)
            end

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Tween(Section, {0.2, 'Quad', 'Out'}, {
                    Size = UDim2.new(0.98, 0, 0, open and 50 + ObjsL.AbsoluteContentSize.Y + 10 or 40)
                })
            end)

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    Section.Size = UDim2.new(0.98, 0, 0, 50 + ObjsL.AbsoluteContentSize.Y + 10)
                end
            end)

            local section = {}
            function section:Button(text, callback)
                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.Size = UDim2.new(1, 0, 0, 40)

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

                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn

                -- 按钮效果
                SetupHoverEffect(Btn, COLORS.MAIN, COLORS.ELEMENT)

                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    if callback then 
                        -- 点击动画
                        Tween(Btn, {0.1, 'Quad', 'Out'}, {Size = UDim2.new(0.98, 0, 0, 38)})
                        wait(0.1)
                        Tween(Btn, {0.1, 'Quad', 'Out'}, {Size = UDim2.new(1, 0, 0, 40)})
                        
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

                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and COLORS.ACCENT or Color3.fromRGB(80, 80, 80)
                ToggleSwitch.Position = UDim2.new(0.85, 0, 0.2, 0)
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 24)
                ToggleSwitch.Position = UDim2.new(0.85, enabled and 26 or 0, 0.2, 0)

                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 12)
                ToggleSwitchC.Parent = ToggleSwitch

                local ToggleKnob = Instance.new("Frame")
                ToggleKnob.Name = "ToggleKnob"
                ToggleKnob.Parent = ToggleSwitch
                ToggleKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
                ToggleKnob.Position = UDim2.new(0, enabled and 26 or 2, 0, 1)

                local ToggleKnobC = Instance.new("UICorner")
                ToggleKnobC.CornerRadius = UDim.new(0, 11)
                ToggleKnobC.Parent = ToggleKnob

                -- 悬停效果
                SetupHoverEffect(ToggleBtn, COLORS.MAIN, COLORS.ELEMENT)

                local funcs = {
                    SetState = function(self, state)
                        state = state or not library.flags[flag]
                        if library.flags[flag] == state then return end
                        
                        Tween(ToggleSwitch, {0.2, 'Quad', 'Out'}, {
                            BackgroundColor3 = state and COLORS.ACCENT or Color3.fromRGB(80, 80, 80)
                        })
                        
                        Tween(ToggleKnob, {0.2, 'Quad', 'Out'}, {
                            Position = UDim2.new(0, state and 26 or 2, 0, 1)
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