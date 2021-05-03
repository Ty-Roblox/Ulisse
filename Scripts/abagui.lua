local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Thrown = workspace.Thrown
local Boost
local Soru

coroutine.wrap(function()
    settings().Physics.AllowSleep=false
    RunService.Heartbeat:Connect(function()
        setsimulationradius(math.huge,math.huge)
    end)
end)()

local LockedOnto = nil

function GetStringFromKeycode(KeyCode)
    return string.sub(tostring(KeyCode),14,#tostring(KeyCode))
end

function EncodeColor3(Color3Val)
    return {
        R = Color3Val.R;
        G = Color3Val.G;
        B = Color3Val.B;
    }
end

function DecodeColor3(Color3Table)
    return Color3.new(Color3Table.R,Color3Table.G,Color3Table.B)
end

local Settings = {
    ["ReflectGunEnabled"] = false;
    ["HitboxExpanderEnabled"] = false;
    ["HitboxSize"] = 15;
    ["NoStun"] = false;
    ["NoKnockback"] = false;
    ["RunSpeed"] = 10;
    ["TeleportDash"] = false;
}

local ReadSettings
pcall(function()
    ReadSettings = HttpService:JSONDecode(readfile("abagui.json"))
end)
if ReadSettings then
    for i,v in pairs(ReadSettings) do
        if string.find(i,"Bind") then
            Settings[i] = Enum.KeyCode[v]
        elseif string.find(i,"Color") then
            Settings[i] = DecodeColor3(v)
        else
            Settings[i] = v
        end
    end
end

function SaveSettings()
    local NewSettings = {}
    for i,v in pairs(Settings) do
        if typeof(v) == "EnumItem" and string.find(tostring(v),"KeyCode") then
            NewSettings[i] = GetStringFromKeycode(v)
        elseif string.find(i,"Color") then
            NewSettings[i] = EncodeColor3(v)
        else
            NewSettings[i] = v
        end
    end
    writefile("abagui.json",HttpService:JSONEncode(NewSettings))
end

function Notify(Message)
    local Sound = Instance.new("Sound",CoreGui)
    Sound.SoundId = "rbxassetid://5153734608"
    Sound:Play()
    game:GetService("Debris"):AddItem(Sound,3)
    StarterGui:SetCore("SendNotification",{
        Title = "New Notification";
        Text = Message;
        Duration = 10;
    })
end

local UI = Material.Load({
    Title = "ABA Gui";
    Style = 3;
    SizeX = 300;
    SizeY = 400;
    Theme = "Dark";
})

local MainPage = UI.New({
    Title = "Main"
})

local Stuns = {
    "Action";
    "Slow";
}

function ConnectCharacter(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    local Root = Character:WaitForChild("HumanoidRootPart")
    local MoveBV = Instance.new("BodyVelocity")
    MoveBV.Name = "MoveBV"
    MoveBV.Parent = Root
    MoveBV.MaxForce = Vector3.new()
    Boost = Instance.new("NumberValue")
    Boost.Name = "Boost"
    Boost.Parent = Character
    Boost.Value = Settings.RunSpeed/10
    if Settings.TeleportDash then
        Soru = Instance.new("Folder")
        Soru.Name = "Soru"
        Soru.Parent = Player.Character
    end
    Humanoid.Changed:Connect(function()
        MoveBV.Velocity = Humanoid.MoveDirection*24
        if Humanoid.WalkSpeed < 17 and Settings.NoStun then
            MoveBV.MaxForce = Vector3.new(10000000,0,10000000)
        else
            MoveBV.MaxForce = Vector3.new()
        end
    end)
    Character.DescendantAdded:Connect(function(Inst)
        if Inst:IsA("BodyMover") and Settings.NoKnockback then
            if Inst.Name ~= "DodgeVel" and Inst.Name ~= "MoveBV" then
                Inst.MaxForce = Vector3.new()
            end
        elseif Inst.Name == "creator" and Settings.NoStun then
            Character.Parent = nil
            Character.Parent = workspace.Live
            wait()
            Inst:Destroy()
        end
    end)
end

ConnectCharacter(Player.Character or Player.CharacterAdded:Wait())

Player.CharacterAdded:Connect(function(Character)
    ConnectCharacter(Character)
end)

function UpdateLoop(Type,Bool)
    if Type == "HitboxExpander" then
        if Bool then
            coroutine.wrap(function()
                while Settings.HitboxExpanderEnabled do
                    if not Settings.HitboxExpanderEnabled then return end
                    for i,v in ipairs(workspace.Live:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v ~= Player.Character then
                            local Root = v.HumanoidRootPart
                            Root.Size = Vector3.new(Settings.HitboxSize,Settings.HitboxSize,Settings.HitboxSize)
                            Root.Transparency = .7
                            Root.CanCollide = false
                            Root.Color = Color3.fromRGB(255,0,0)
                        end
                    end
                    wait(1)
                end
            end)()
        else
            for i,v in ipairs(workspace.Live:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") then
                    local Root = v.HumanoidRootPart
                    Root.Size = Vector3.new(2,2,1)
                    Root.Transparency = 1
                end
            end
        end
    end
end

function Orbit(Part)
    coroutine.wrap(function()
        while Part:IsDescendantOf(workspace) do
            if isnetworkowner(Part) then
                for i,v in ipairs(workspace.Live:GetChildren()) do
                    if v == Player.Character then continue end
                    if not isnetworkowner(Part) then break end
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        for i = 1,10 do
                            Part.CFrame = v.HumanoidRootPart.CFrame
                            RunService.Stepped:Wait()
                        end
                    end
                end
            end
            RunService.Stepped:Wait()
        end
    end)()
end

Thrown.ChildAdded:Connect(function(Child)
    wait()
    if Settings.ReflectGunEnabled and Child:IsA("BasePart") and Child:FindFirstChildWhichIsA("BodyMover") then
        Orbit(Child)
    end
end)

local A = MainPage.Toggle({
    Text = "Reflect Gun";
    Callback = function(Value)
        Settings.ReflectGunEnabled = Value
        SaveSettings()
    end;
    Enabled = Settings.ReflectGunEnabled;
    Menu = {
        Information = function(self)
            UI.Banner({
                Text = "Cycles the projectiles you shoot through everyone in the map, only works with lingering hitboxes. Best used with Yusuke.";
            })
        end
    };
})

local B = MainPage.Toggle({
    Text = "Hitbox Expander";
    Callback = function(Value)
        Settings.HitboxExpanderEnabled = Value
        SaveSettings()
        UpdateLoop("HitboxExpander",Value)
    end;
    Enabled = Settings.HitboxExpanderEnabled;
    Menu = {
        Information = function(self)
            UI.Banner({
                Text = "Expands everybodies hitboxes adjustant to the Hitbox Expander Size slider (Only applies to some moves such as Rasengan)";
            })
        end
    }
})

local C = MainPage.Slider({
    Text = "Hitbox Expander Size";
    Callback = function(Val)
        Settings.HitboxSize = Val
        SaveSettings()
        if Settings.HitboxExpanderEnabled then
            for i,v in ipairs(workspace.Live:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") and v ~= Player.Character then
                    local Root = v.HumanoidRootPart
                    Root.Size = Vector3.new(Settings.HitboxSize,Settings.HitboxSize,Settings.HitboxSize)
                    Root.Transparency = .7
                    Root.CanCollide = false
                    Root.Color = Color3.fromRGB(255,0,0)
                end
            end
        end
    end;
    Min = 5;
    Max = 300;
    Def = Settings.HitboxSize;
})

local D = MainPage.Toggle({
    Text = "No Knockback";
    Callback = function(Value)
        Settings.NoKnockback = Value
        SaveSettings()
    end;
    Enabled = Settings.NoKnockback;
    Menu = {
        Information = function(self)
            UI.Banner({
                Text = "Prevent knockback or other pushing or pulling forces from moving you (Such as Pains pull)";
            })
        end
    }
})

local E = MainPage.Toggle({
    Text = "No Stun";
    Callback = function(Value)
        Settings.NoStun = Value
        SaveSettings()
    end;
    Enabled = Settings.NoStun;
    Menu = {
        Information = function(self)
            UI.Banner({
                Text = "Prevents you from being stunned or frozen by others";
            })
        end
    }
})

local F = MainPage.Slider({
    Text = "Run Speed";
    Callback = function(Value)
        Settings.RunSpeed = Value
        SaveSettings()
        if Boost and Boost:IsDescendantOf(Player.Character) then
            Boost.Value = Value/10
        end
    end;
    Min = 10;
    Max = 50;
    Def = Settings.RunSpeed;
})

local G = MainPage.Toggle({
    Text = "Teleport Dash";
    Callback = function(Value)
        Settings.TeleportDash = Value
        SaveSettings()
        if Value then
            Soru = Instance.new("Folder")
            Soru.Name = "Soru"
            Soru.Parent = Player.Character
        else
            if Soru then
                Soru:Destroy()
            end
        end
    end;
    Enabled = Settings.TeleportDash;
    Menu = {
        Information = function(self)
            UI.Banner({
                Text = "Gives you the teleport dashes from forms without having to be in form";
            })
        end
    }
})