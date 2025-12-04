-- Load X2ZU UI Framework
local Framework = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Aimbot Script Logic
local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local Workspace = game:GetService("Workspace")

-- Aimbot Variables
local aimbotConnection = nil
local aimbotEnabled = false
local targetHead = true
local blatantMode = false
local wallCheckEnabled = false
local teamCheckEnabled = false

local COLOR_ON = Color3.fromRGB(0, 200, 0)
local COLOR_OFF = Color3.fromRGB(200, 0, 0)

-- Color gradients
local function createGradientColor(startColor, endColor, ratio)
    ratio = math.clamp(ratio, 0, 1)
    return Color3.new(
        startColor.R + (endColor.R - startColor.R) * ratio,
        startColor.G + (endColor.G - startColor.G) * ratio,
        startColor.B + (endColor.B - startColor.B) * ratio
    )
end

-- Title gradient animation
local titleHue = 0
local function animateTitleGradient(label)
    spawn(function()
        while label and label.Parent do
            titleHue = (titleHue + 0.005) % 1
            local red = Color3.fromRGB(255, 50, 50)
            local yellow = Color3.fromRGB(255, 255, 50)
            label.TextColor3 = titleHue < 0.5 and createGradientColor(red, yellow, titleHue * 2) 
                                            or createGradientColor(yellow, red, (titleHue - 0.5) * 2)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- Subtitle gradient animation
local subtitleHue = 0
local function animateSubtitleGradient(label)
    spawn(function()
        while label and label.Parent do
            subtitleHue = (subtitleHue + 0.003) % 1
            local lightGreen = Color3.fromRGB(100, 255, 100)
            local darkGreen = Color3.fromRGB(0, 150, 0)
            label.TextColor3 = subtitleHue < 0.5 and createGradientColor(lightGreen, darkGreen, subtitleHue * 2)
                                                or createGradientColor(darkGreen, lightGreen, (subtitleHue - 0.5) * 2)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- Function to check if enemy is valid
local function isEnemy(player)
    if player == Player then return false end
    if teamCheckEnabled and player.Team == Player.Team then return false end
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

-- Wall check function
local function isTargetVisible(targetPart)
    if not targetPart or not wallCheckEnabled then return true end
    if not Player.Character then return false end
    
    local head = Player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local origin = head.Position
    local direction = (targetPart.Position - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Player.Character}
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction * 1000, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

-- Get closest enemy
function getClosestEnemy()
    local smallest = math.huge
    local closest = nil
    
    local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, enemy in pairs(game:GetService("Players"):GetPlayers()) do
        if isEnemy(enemy) then
            local root = enemy.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if not wallCheckEnabled or isTargetVisible(root) then
                    local dist = (root.Position - myHRP.Position).Magnitude
                    if dist < smallest then
                        smallest = dist
                        closest = enemy.Character
                    end
                end
            end
        end
    end
    return closest
end

-- Aim functions
function setAim(pos)
    local head = Player.Character and Player.Character:FindFirstChild("Head")
    if head and pos then
        local dir = (pos - head.Position).Unit
        local targetCFrame = CFrame.new(head.Position, head.Position + dir)
        pcall(function()
            TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = targetCFrame}):Play()
        end)
    end
end

function instantAim(pos)
    local head = Player.Character and Player.Character:FindFirstChild("Head")
    if head and pos then
        local dir = (pos - head.Position).Unit
        Camera.CFrame = CFrame.new(head.Position, head.Position + dir)
    end
end

-- Main aimbot loop
function mainAimbotLoop()
    if not aimbotEnabled then return end
    
    local target = getClosestEnemy()
    if target then
        local aimPos = targetHead and target:FindFirstChild("Head") and target.Head.Position
            or target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart.Position
        
        if aimPos then
            if not wallCheckEnabled or isTargetVisible(targetHead and target.Head or target.HumanoidRootPart) then
                if blatantMode then
                    instantAim(aimPos)
                else
                    setAim(aimPos)
                end
            end
        end
    end
end

-- Start/Stop aimbot
function startAimbot()
    if not aimbotConnection then
        aimbotConnection = RunService.Heartbeat:Connect(function()
            pcall(mainAimbotLoop)
        end)
    end
end

function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- Create X2ZU UI Window
local Window = Framework.CreateWindow({
    Title = "MACROPEAK | V1.0",
    SubTitle = "Made By @LuaDev",
    Size = UDim2.new(0, 500, 0, 450),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightControl,
    ShowOnStart = true
})

-- Apply custom colors to title and subtitle
if Window.TitleLabel then
    animateTitleGradient(Window.TitleLabel)
end

if Window.SubTitleLabel then
    animateSubtitleGradient(Window.SubTitleLabel)
end

-- Create Aim Tab
local AimTab = Window:CreateTab({
    Title = "Aim",
    Icon = "🎯"
})

-- Create sections
local AimbotSection = AimTab:CreateSection({
    Title = "Aimbot Settings",
    Description = "Configure your aiming preferences"
})

local ModeSection = AimTab:CreateSection({
    Title = "Aiming Mode",
    Description = "Select how the aimbot behaves"
})

local FeaturesSection = AimTab:CreateSection({
    Title = "Additional Features",
    Description = "Extra aiming utilities"
})

-- Aimbot Toggle
local AimbotToggle = AimbotSection:CreateToggle({
    Title = "Enable Aimbot",
    Description = "Toggle the aimbot on/off",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then
            startAimbot()
        else
            stopAimbot()
        end
    end
})

-- Aim Part Dropdown
local AimPartDropdown = AimbotSection:CreateDropdown({
    Title = "Aim Part",
    Description = "Select where to aim",
    Options = {"Head", "Body"},
    Default = "Head",
    Callback = function(option)
        targetHead = (option == "Head")
    end
})

-- Team Check Toggle
local TeamCheckToggle = AimbotSection:CreateToggle({
    Title = "Team Check",
    Description = "Ignore teammates when aiming",
    Default = false,
    Callback = function(state)
        teamCheckEnabled = state
    end
})

-- Wall Check Toggle
local WallCheckToggle = AimbotSection:CreateToggle({
    Title = "Wall Check",
    Description = "Only aim at visible targets",
    Default = false,
    Callback = function(state)
        wallCheckEnabled = state
    end
})

-- Blatant Mode Toggle
local BlatantToggle = ModeSection:CreateToggle({
    Title = "Blatant Mode",
    Description = "Instant snap to target (more obvious)",
    Default = false,
    Callback = function(state)
        blatantMode = state
    end
})

-- FOV Slider
local FOVSlider = ModeSection:CreateSlider({
    Title = "Field of View",
    Description = "Target detection range",
    Min = 1,
    Max = 360,
    Default = 100,
    Callback = function(value)
        -- Add FOV logic here if needed
    end
})

-- Smoothness Slider
local SmoothSlider = ModeSection:CreateSlider({
    Title = "Smoothness",
    Description = "Aim smoothing factor",
    Min = 1,
    Max = 30,
    Default = 10,
    Callback = function(value)
        -- Add smoothness logic here if needed
    end
})

-- Trigger Bot Toggle
local TriggerToggle = FeaturesSection:CreateToggle({
    Title = "Trigger Bot",
    Description = "Auto shoot when target is in sight",
    Default = false,
    Callback = function(state)
        if state then
            -- Add trigger bot logic here
            spawn(function()
                local mouse = Player:GetMouse()
                while TriggerToggle.State do
                    if aimbotEnabled and getClosestEnemy() then
                        mouse1press()
                        wait(0.1)
                        mouse1release()
                    end
                    wait(0.05)
                end
            end)
        end
    end
})

-- Silent Aim Toggle
local SilentToggle = FeaturesSection:CreateToggle({
    Title = "Silent Aim",
    Description = "Hidden aiming (less detectable)",
    Default = false,
    Callback = function(state)
        -- Add silent aim logic here
        if state then
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            
            setreadonly(mt, false)
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if state and method == "FireServer" then
                    if tostring(self):find("Remote") then
                        local target = getClosestEnemy()
                        if target then
                            local aimPos = targetHead and target:FindFirstChild("Head") and target.Head.Position
                                or target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart.Position
                            
                            if aimPos then
                                -- Modify hit argument
                                if args[1] and type(args[1]) == "table" then
                                    args[1].Hit = aimPos
                                end
                            end
                        end
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end)
            
            setreadonly(mt, true)
        end
    end
})

-- Create Visuals Tab
local VisualTab = Window:CreateTab({
    Title = "Visuals",
    Icon = "👁️"
})

local EspSection = VisualTab:CreateSection({
    Title = "ESP Settings",
    Description = "Player highlighting and visuals"
})

-- ESP Toggle
local EspToggle = EspSection:CreateToggle({
    Title = "Enable ESP",
    Description = "Show player highlights",
    Default = false,
    Callback = function(state)
        if state then
            -- ESP logic
            spawn(function()
                while EspToggle.State do
                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= Player and player.Character then
                            local char = player.Character
                            if not char:FindFirstChild("PEAKMACRO_Highlight") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "PEAKMACRO_Highlight"
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Adornee = char
                                highlight.Parent = char
                            end
                        end
                    end
                    wait(0.1)
                end
                
                -- Clean up when ESP is disabled
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("PEAKMACRO_Highlight") then
                        player.Character.PEAKMACRO_Highlight:Destroy()
                    end
                end
            end)
        end
    end
})

-- Box ESP Toggle
local BoxToggle = EspSection:CreateToggle({
    Title = "Box ESP",
    Description = "Show boxes around players",
    Default = false,
    Callback = function(state)
        -- Add box ESP logic here
    end
})

-- Tracer ESP Toggle
local TracerToggle = EspSection:CreateToggle({
    Title = "Tracer ESP",
    Description = "Show lines to players",
    Default = false,
    Callback = function(state)
        -- Add tracer ESP logic here
    end
})

-- Create Misc Tab
local MiscTab = Window:CreateTab({
    Title = "Misc",
    Icon = "⚙️"
})

local MovementSection = MiscTab:CreateSection({
    Title = "Movement",
    Description = "Player movement enhancements"
})

-- WalkSpeed Toggle
local WalkSpeedToggle = MovementSection:CreateToggle({
    Title = "Speed Hack",
    Description = "Increase movement speed",
    Default = false,
    Callback = function(state)
        if state then
            spawn(function()
                while WalkSpeedToggle.State do
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.WalkSpeed = 50
                    end
                    wait(0.1)
                end
                -- Reset when disabled
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid.WalkSpeed = 16
                end
            end)
        end
    end
})

-- JumpPower Toggle
local JumpPowerToggle = MovementSection:CreateToggle({
    Title = "High Jump",
    Description = "Increase jump power",
    Default = false,
    Callback = function(state)
        if state then
            spawn(function()
                while JumpPowerToggle.State do
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.JumpPower = 100
                    end
                    wait(0.1)
                end
                -- Reset when disabled
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid.JumpPower = 50
                end
            end)
        end
    end
})

-- Noclip Toggle
local NoclipToggle = MovementSection:CreateToggle({
    Title = "Noclip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(state)
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

local UtilitySection = MiscTab:CreateSection({
    Title = "Utility",
    Description = "Useful tools and features"
})

-- Rejoin Button
UtilitySection:CreateButton({
    Title = "Rejoin Server",
    Description = "Reconnect to current server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

-- Server Hop Button
UtilitySection:CreateButton({
    Title = "Server Hop",
    Description = "Switch to a different server",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        
        local servers = {}
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
        end)
        
        if success then
            local data = Http:JSONDecode(result)
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            
            if #servers > 0 then
                TPS:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
            end
        end
    end
})

-- Anti Lag Toggle
UtilitySection:CreateToggle({
    Title = "Anti Lag",
    Description = "Reduce graphics for better performance",
    Default = false,
    Callback = function(state)
        if state then
            settings().Rendering.QualityLevel = 1
            game.Lighting.GlobalShadows = false
            game.Lighting.FogEnd = 100000
            
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = 10
            game.Lighting.GlobalShadows = true
            game.Lighting.FogEnd = 1000000
            
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = true
                end
            end
        end
    end
})

-- Create Settings Tab
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "🔧"
})

local UISection = SettingsTab:CreateSection({
    Title = "UI Settings",
    Description = "Customize the interface"
})

-- UI Toggle Key
UISection:CreateKeybind({
    Title = "UI Toggle Key",
    Description = "Key to show/hide the UI",
    Default = "RightControl",
    Callback = function(key)
        Window.ToggleKey = key
    end
})

-- Theme Selector
UISection:CreateDropdown({
    Title = "Theme",
    Description = "Select UI color theme",
    Options = {"Dark", "Light", "Blue", "Red", "Green", "Purple"},
    Default = "Dark",
    Callback = function(theme)
        -- Add theme change logic here
    end
})

-- Watermark Toggle
UISection:CreateToggle({
    Title = "Show Watermark",
    Description = "Display MACROPEAK watermark",
    Default = true,
    Callback = function(state)
        -- Add watermark logic here
    end
})

-- Create Credits Tab
local CreditsTab = Window:CreateTab({
    Title = "Credits",
    Icon = "🌟"
})

local CreditsSection = CreditsTab:CreateSection({
    Title = "Credits & Information",
    Description = "About MACROPEAK V1.0"
})

-- Credits information
CreditsSection:CreateLabel({
    Title = "Developer",
    Description = "@LuaDev"
})

CreditsSection:CreateLabel({
    Title = "Version",
    Description = "V1.0"
})

CreditsSection:CreateLabel({
    Title = "UI Framework",
    Description = "X2ZU UI by x2zu"
})

CreditsSection:CreateLabel({
    Title = "Features",
    Description = "Aimbot, ESP, Movement, Utility"
})

-- Footer label
CreditsSection
