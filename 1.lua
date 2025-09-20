repeat task.wait() until game:IsLoaded()
local library = {}
local ToggleUI = false
library.currentTab = nil
library.flags = {}
local services = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})
local mouse = services.Players.LocalPlayer:GetMouse()

local function createBlurBackground()
    local blur = Instance.new("BlurEffect")
    blur.Name = "UIBackgroundBlur"
    blur.Size = 0
    blur.Parent = game.Lighting

    local function toggleBlur(enabled, intensity)
        intensity = intensity or 10
        if enabled then
            services.TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = intensity}):Play()
        else
            services.TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
    end

    return toggleBlur
end
local toggleBlur = createBlurBackground()

function Tween(obj, t, data)
    services.TweenService:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data):Play()
    return true
end

function Ripple(obj)
    spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Ripple.BackgroundTransparency = 1.000
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://18941591417"
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.Position = UDim2.new((mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X, 0, (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y, 0)
        Tween(Ripple, {0.3, 'Linear', 'InOut'}, {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)})
        wait(0.15)
        Tween(Ripple, {0.3, 'Linear', 'InOut'}, {ImageTransparency = 1})
        wait(.3)
        Ripple:Destroy()
    end)
end

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        return
    end

    if old[1] == new[1] then return end
    switchingTabs = true
    library.currentTab = new
    services.TweenService:Create(old[1], TweenInfo.new(0.1), {ImageTransparency = 0.2}):Play()
    services.TweenService:Create(new[1], TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
    services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), {TextTransparency = 0.2}):Play()
    services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
    old[2].Visible = false
    new[2].Visible = true

    task.wait(0.1)
    switchingTabs = false
end

function drag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

function library.new(library, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty" then
            v:Destroy()
        end
    end

    local MainColor = Color3.fromRGB(0, 0, 0)
    local Background = Color3.fromRGB(0, 0, 0)
    local zyColor = Color3.fromRGB(0, 0, 0)
    local beijingColor = Color3.fromRGB(0, 0, 0)
    local ALcolor = Color3.fromRGB(255, 255, 255)
    local ALTransparency = 0.6

    local dogent = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local TabMain = Instance.new("Frame")
    local MainC = Instance.new("UICorner")
    local SB = Instance.new("Frame")
    local SBC = Instance.new("UICorner")
    local Side = Instance.new("Frame")
    local SideG = Instance.new("UIGradient")
    local TabBtns = Instance.new("ScrollingFrame")
    local TabBtnsL = Instance.new("UIListLayout")
    local ScriptTitle = Instance.new("TextLabel")
    local Open = Instance.new("ImageButton")
    local DropShadowHolder = Instance.new("Frame")
    local DropShadow = Instance.new("ImageLabel")
    local UICornerMain = Instance.new("UICorner")
    local Frame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UICorner_2 = Instance.new("UICorner")

    if syn and syn.protect_gui then syn.protect_gui(dogent) end

    dogent.Name = "frosty"
    dogent.Parent = services.CoreGui

    function UiDestroy()
        dogent:Destroy()
    end

    function ToggleUILib()
        if not ToggleUI then
            dogent.Enabled = false
            ToggleUI = true
            toggleBlur(false)
        else
            ToggleUI = false
            dogent.Enabled = true
            toggleBlur(true, 8)
        end
    end

    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Background
    Main.BorderColor3 = MainColor
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.ZIndex = 1
    Main.Active = true
    Main.Draggable = true
    Main.Transparency = 1.0
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            if Main.Visible == true then
                Main.Visible = false
                toggleBlur(false)
            else
                Main.Visible = true
                toggleBlur(true, 8)
            end
        end
    end)
    drag(Main)

    UICornerMain.Parent = Main
    UICornerMain.CornerRadius = UDim.new(0, 3)

    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Main
    DropShadowHolder.BackgroundTransparency = 1.000
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 10, 1, 10)
    DropShadow.Image = "rbxassetid://18930485323"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TabMain.BackgroundTransparency = 1.000
    TabMain.Position = UDim2.new(0.217000037, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 353)
    TabMain.Transparency = 1.0

    SB.Name = "SB"
    SB.Parent = Main
    SB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SB.BorderColor3 = MainColor
    SB.Size = UDim2.new(0, 8, 0, 353)
    SB.Transparency = 1.0

    SBC.CornerRadius = UDim.new(0, 6)
    SBC.Name = "SBC"
    SBC.Parent = SB

    Side.Name = "Side"
    Side.Parent = SB
    Side.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Side.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Side.BorderSizePixel = 0
    Side.ClipsDescendants = true
    Side.Position = UDim2.new(1, 0, 0, 0)
    Side.Size = UDim2.new(0, 110, 0, 353)
    Side.Transparency = 1.0

    SideG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor)}
    SideG.Rotation = 90
    SideG.Name = "SideG"
    SideG.Parent = Side

    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TabBtns.BackgroundTransparency = 1.000
    TabBtns.BorderSizePixel = 0
    TabBtns.Position = UDim2.new(0, 0, 0.0973535776, 0)
    TabBtns.Size = UDim2.new(0, 110, 0, 318)
    TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
    TabBtns.ScrollBarThickness = 0

    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)

    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ScriptTitle.BackgroundTransparency = 1.000
    ScriptTitle.Position = UDim2.new(0, 0, 0.00953488424, 0)
    ScriptTitle.Size = UDim2.new(0, 150, 0, 30)
    ScriptTitle.Font = Enum.Font.GothamBold
    ScriptTitle.Text = "科脚本V2 - 半自制脚本"
    ScriptTitle.TextColor3 = ALcolor
    ScriptTitle.TextSize = 16.000
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

    Open.Name = "Open"
    Open.Parent = dogent
    Open.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Open.BackgroundTransparency = 1.000
    Open.Position = UDim2.new(0.00800000038, 0, 0.311000025, 0)
    Open.Size = UDim2.new(0, 50, 0, 50)
    Open.Image = "rbxassetid://1462490707"
    Open.ImageColor3 = ALcolor
    Open.ImageTransparency = 0.800
    Open.ZIndex = 10

    Open.MouseButton1Click:Connect(function()
        if Main.Visible then
            Main.Visible = false
            toggleBlur(false)
        else
            Main.Visible = true
            toggleBlur(true, 8)
            Tween(Main, {0.3, 'Elastic', 'Out'}, {Size = UDim2.new(0, 572, 0, 353), Transparency = 0})
        end
    end)

    Open.MouseEnter:Connect(function()
        Tween(Open, {0.2, 'Quad', 'Out'}, {Size = UDim2.new(0, 55, 0, 55), ImageTransparency = 0.6})
    end)

    Open.MouseLeave:Connect(function()
        Tween(Open, {0.2, 'Quad', 'Out'}, {Size = UDim2.new(0, 50, 0, 50), ImageTransparency = 0.8})
    end)

    local window = {}

    function window:Tab(name, icon)
        local Tab = Instance.new("Frame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BackgroundTransparency = 1.000
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.Transparency = 1.0
        Tab.ZIndex = 3

        local TabScroll = Instance.new("ScrollingFrame")
        TabScroll.Name = "TabScroll"
        TabScroll.Parent = Tab
        TabScroll.Active = true
        TabScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabScroll.BackgroundTransparency = 1.000
        TabScroll.Size = UDim2.new(1, 0, 1, 0)
        TabScroll.ScrollBarThickness = 5
        TabScroll.ScrollBarImageColor3 = ALcolor
        TabScroll.ScrollBarImageTransparency = 0.5
        TabScroll.Visible = false
        TabScroll.ZIndex = 4

        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = TabScroll
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 8)

        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabIco.BackgroundTransparency = 1.000
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = icon or "rbxassetid://1462490707"
        TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = ALcolor
        TabIco.ZIndex = 4

        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabText.BackgroundTransparency = 1.000
        TabText.Position = UDim2.new(1.41700003, 0, 0, 0)
        TabText.Size = UDim2.new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.TextSize = 14.000
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        TabText.ZIndex = 4

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.BackgroundTransparency = 1.000
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.Text = ""
        TabBtn.ZIndex = 5

        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({TabIco, TabScroll})
        end)

        TabBtn.MouseEnter:Connect(function()
            Tween(TabIco, {0.2, 'Quad', 'Out'}, {ImageTransparency = 0, ImageColor3 = ALcolor})
            Tween(TabText, {0.2, 'Quad', 'Out'}, {TextTransparency = 0, TextColor3 = ALcolor})
        end)

        TabBtn.MouseLeave:Connect(function()
            if library.currentTab and library.currentTab[1] ~= TabIco then
                Tween(TabIco, {0.2, 'Quad', 'Out'}, {ImageTransparency = 0.5, ImageColor3 = Color3.fromRGB(150, 150, 150)})
                Tween(TabText, {0.2, 'Quad', 'Out'}, {TextTransparency = 0.5, TextColor3 = Color3.fromRGB(150, 150, 150)})
            end
        end)

        if not library.currentTab then
            switchTab({TabIco, TabScroll})
            Tween(TabIco, {0.2, 'Quad', 'Out'}, {ImageTransparency = 0, ImageColor3 = ALcolor})
            Tween(TabText, {0.2, 'Quad', 'Out'}, {TextTransparency = 0, TextColor3 = ALcolor})
        end

        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 16)
        end)

        local tab = {}

        function tab:Section(name, isOpen)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = TabScroll
            Section.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Section.Size = UDim2.new(0.98, 0, 0, 40)
            Section.ClipsDescendants = true
            Section.ZIndex = 4

            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Parent = Section

            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            SectionHeader.BackgroundTransparency = 1.000
            SectionHeader.Size = UDim2.new(1, 0, 0, 40)
            SectionHeader.ZIndex = 5

            local SectionLine = Instance.new("Frame")
            SectionLine.Name = "SectionLine"
            SectionLine.Parent = SectionHeader
            SectionLine.BackgroundColor3 = ALcolor
            SectionLine.Position = UDim2.new(0, 0, 0, 10)
            SectionLine.Size = UDim2.new(0, 4, 0, 20)
            SectionLine.ZIndex = 5

            local SectionLineC = Instance.new("UICorner")
            SectionLineC.CornerRadius = UDim.new(0, 2)
            SectionLineC.Parent = SectionLine

            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = SectionHeader
            SectionText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            SectionText.BackgroundTransparency = 1.000
            SectionText.Position = UDim2.new(0.05, 0, 0, 0)
            SectionText.Size = UDim2.new(0.9, 0, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = ALcolor
            SectionText.TextSize = 16.000
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            SectionText.ZIndex = 5

            local SectionToggle = Instance.new("TextButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            SectionToggle.BackgroundTransparency = 1.000
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            SectionToggle.Text = ""
            SectionToggle.ZIndex = 6

            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Objs.BackgroundTransparency = 1.000
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
                Tween(Section, {0.2, 'Quad', 'Out'}, {
                    Size = UDim2.new(0.98, 0, 0, targetHeight)
                })
            end

            if isOpen ~= false then
                updateSectionSize()
            end

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                updateSectionSize()
                if open then
                    Tween(Objs, {0.2, 'Quad', 'Out'}, {Transparency = 0})
                else
                    Tween(Objs, {0.15, 'Quad', 'Out'}, {Transparency = 1})
                end
            end)

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionSize()
                end
            end)

            Objs.Transparency = open and 0 or 1

            local section = {}

            function section:Button(text, callback)
                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                BtnModule.BackgroundTransparency = 1.000
                BtnModule.Size = UDim2.new(1, 0, 0, 40)
                BtnModule.ZIndex = 5

                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = ALcolor
                Btn.TextSize = 14.000
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.ZIndex = 5

                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn

                local BtnAccent = Instance.new("Frame")
                BtnAccent.Name = "BtnAccent"
                BtnAccent.Parent = Btn
                BtnAccent.BackgroundColor3 = ALcolor
                BtnAccent.Position = UDim2.new(0, 0, 0, 0)
                BtnAccent.Size = UDim2.new(0, 3, 1, 0)
                BtnAccent.ZIndex = 6

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                end)

                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
                end)

                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    if callback then
                        Tween(Btn, {0.1, 'Quad', 'Out'}, {
                            Size = UDim2.new(0.98, 0, 0, 38),
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        })
                        wait(0.1)
                        Tween(Btn, {0.15, 'Elastic', 'Out'}, {
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
                ToggleModule.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                ToggleModule.BackgroundTransparency = 1.000
                ToggleModule.Size = UDim2.new(1, 0, 0, 40)
                ToggleModule.ZIndex = 5

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = ALcolor
                ToggleBtn.TextSize = 14.000
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                ToggleBtn.ZIndex = 5

                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn

                local ToggleAccent = Instance.new("Frame")
                ToggleAccent.Name = "ToggleAccent"
                ToggleAccent.Parent = ToggleBtn
                ToggleAccent.BackgroundColor3 = ALcolor
                ToggleAccent.Position = UDim2.new(0, 0, 0, 0)
                ToggleAccent.Size = UDim2.new(0, 3, 1, 0)
                ToggleAccent.ZIndex = 6

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and ALcolor or Color3.fromRGB(80, 80, 80)
                ToggleSwitch.Position = UDim2.new(0.85, enabled and 26 or 0, 0.2, 0)
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 24)
                ToggleSwitch.ZIndex = 5

                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 12)
                ToggleSwitchC.Parent = ToggleSwitch

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

                ToggleBtn.MouseEnter:Connect(function()
                    Tween(ToggleBtn, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                end)

                ToggleBtn.MouseLeave:Connect(function()
                    Tween(ToggleBtn, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
                end)

                local funcs = {
                    SetState = function(self, state)
                        state = state or not library.flags[flag]
                        if library.flags[flag] == state then return end

                        Tween(ToggleSwitch, {0.2, 'Quad', 'Out'}, {
                            BackgroundColor3 = state and ALcolor or Color3.fromRGB(80, 80, 80)
                        })
                        Tween(ToggleKnob, {0.2, 'Quad', 'Out'}, {
                            Position = UDim2.new(0, state and 26 or 2, 0, 1)
                        })
                        Tween(KnobShadow, {0.2, 'Quad', 'Out'}, {
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