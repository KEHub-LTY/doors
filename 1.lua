repeat task.wait() until game:IsLoaded()
local library = {currentTab = nil, flags = {}}
local ToggleUI = false

local services = setmetatable({}, {
    __index = function(t, k) return game:GetService(k) end
})

local mouse = services.Players.LocalPlayer:GetMouse()

-- 简化颜色配置
local COLORS = {
    MAIN = Color3.fromRGB(15, 15, 15),
    BACKGROUND = Color3.fromRGB(20, 20, 20),
    ELEMENT = Color3.fromRGB(35, 35, 35),
    ACCENT = Color3.fromRGB(0, 255, 0),
    TEXT = Color3.fromRGB(0, 255, 0)
}

local ALTransparency = 0.6

function Tween(obj, t, data)
    services.TweenService:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data):Play()
    return true
end

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
        
        Tween(Ripple, {.3, 'Linear', 'InOut'}, {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)})
        wait(0.15)
        Tween(Ripple, {.3, 'Linear', 'InOut'}, {ImageTransparency = 1})
        wait(.3)
        Ripple:Destroy()
    end)
end

local switchingTabs = false
function switchTab(new)
    if switchingTabs or (library.currentTab and library.currentTab[1] == new[1]) then return end
    switchingTabs = true
    
    local old = library.currentTab
    library.currentTab = new

    if old then
        services.TweenService:Create(old[1], TweenInfo.new(0.1), {ImageTransparency = 0.2}):Play()
        services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), {TextTransparency = 0.2}):Play()
        old[2].Visible = false
    end

    services.TweenService:Create(new[1], TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
    services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
    new[2].Visible = true
    
    task.wait(0.1)
    switchingTabs = false
end

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

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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

function library.new(name)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty" then v:Destroy() end
    end

    local dogent = Instance.new("ScreenGui")
    dogent.Name = "frosty"
    if syn and syn.protect_gui then syn.protect_gui(dogent) end
    dogent.Parent = services.CoreGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = COLORS.BACKGROUND
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.Active = true
    Main.Draggable = true
    drag(Main)

    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            Main.Visible = not Main.Visible
        end
    end)

    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 3)
    UICornerMain.Parent = Main

    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundTransparency = 1
    TabMain.Position = UDim2.new(0.217, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 353)

    local SB = Instance.new("Frame")
    SB.Name = "SB"
    SB.Parent = Main
    SB.BackgroundColor3 = COLORS.MAIN
    SB.Size = UDim2.new(0, 8, 0, 353)

    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.Parent = SB
    Side.BackgroundColor3 = COLORS.MAIN
    Side.Position = UDim2.new(1, 0, 0, 0)
    Side.Size = UDim2.new(0, 110, 0, 353)

    local TabBtns = Instance.new("ScrollingFrame")
    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundTransparency = 1
    TabBtns.Position = UDim2.new(0, 0, 0.097, 0)
    TabBtns.Size = UDim2.new(0, 110, 0, 318)
    TabBtns.ScrollBarThickness = 0

    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)

    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Position = UDim2.new(0, 0, 0.01, 0)
    ScriptTitle.Size = UDim2.new(0, 102, 0, 20)
    ScriptTitle.Font = Enum.Font.GothamSemibold
    ScriptTitle.Text = name or "UI Library"
    ScriptTitle.TextColor3 = COLORS.TEXT
    ScriptTitle.TextSize = 14
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

    local OpenBtn = Instance.new("ImageButton")
    OpenBtn.Name = "Open"
    OpenBtn.Parent = dogent
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Position = UDim2.new(0.008, 0, 0.311, 0)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Image = "rbxassetid://18942159845"
    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        OpenBtn.Image = Main.Visible and "rbxassetid://18941591417" or "rbxassetid://18930445827"
    end)

    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 18)
    end)

    local window = {}
    function window:Tab(name, icon)
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.Visible = false

        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = icon or "rbxassetid://18941716391"
        TabIco.ImageTransparency = 0.2
        TabIco.ImageColor3 = COLORS.ACCENT

        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.417, 0, 0, 0)
        TabText.Size = UDim2.new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = COLORS.TEXT
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.2

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.Text = ""

        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({TabIco, Tab})
        end)

        if not library.currentTab then switchTab({TabIco, Tab}) end

        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
        end)

        local tab = {}
        function tab:Section(name, isOpen)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Section.Size = UDim2.new(0.981, 0, 0, 36)
            Section.ClipsDescendants = true

            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Parent = Section

            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.089, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 401, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = COLORS.TEXT
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left

            local SectionToggle = Instance.new("TextButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionText
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Position = UDim2.new(-0.08, 0, 0, 0)
            SectionToggle.Size = UDim2.new(1.08, 0, 1, 0)
            SectionToggle.Text = ""

            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.Position = UDim2.new(0, 6, 0, 36)
            Objs.Size = UDim2.new(0.986, 0, 0, 0)

            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)

            local open = isOpen ~= false
            if isOpen ~= false then
                Section.Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
            end

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Section.Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
            end)

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    Section.Size = UDim2.new(0.981, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
                end
            end)

            local section = {}
            function section:Button(text, callback)
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = Objs
                Btn.BackgroundColor3 = COLORS.ELEMENT
                Btn.Size = UDim2.new(0, 428, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = COLORS.TEXT
                Btn.TextSize = 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left

                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    if callback then callback() end
                end)
            end

            function section:Toggle(text, flag, enabled, callback)
                enabled = enabled or false
                library.flags[flag] = enabled

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = Objs
                ToggleBtn.BackgroundColor3 = COLORS.ELEMENT
                ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = COLORS.TEXT
                ToggleBtn.TextSize = 16
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and COLORS.ACCENT or Color3.fromRGB(40, 40, 40)
                ToggleSwitch.Position = UDim2.new(0.9, 0, 0.2, 0)
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
                ToggleSwitch.Position = UDim2.new(0.9, enabled and 12 or 0, 0.2, 0)

                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Parent = ToggleSwitch

                local funcs = {
                    SetState = function(state)
                        state = state or not library.flags[flag]
                        if library.flags[flag] == state then return end
                        
                        Tween(ToggleSwitch, {0.2, 'Quad', 'Out'}, {
                            Position = UDim2.new(0.9, state and 12 or 0, 0.2, 0),
                            BackgroundColor3 = state and COLORS.ACCENT or Color3.fromRGB(40, 40, 40)
                        })
                        
                        library.flags[flag] = state
                        if callback then callback(state) end
                    end
                }

                if enabled then funcs.SetState(true) end

                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs.SetState()
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