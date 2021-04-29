local Players=game:service'Players'
local HttpService=game:service'HttpService'
local TeleportService=game:service'TeleportService'
local ReplicatedStorage=game:service'ReplicatedStorage'
local VirtualUser=game:service'VirtualUser'
local CoreGui=game:service'CoreGui'
local RunService=game:service'RunService'
local Stepped=RunService.Stepped
local MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
local LocalPlayer=Players.LocalPlayer
syn.queue_on_teleport(readfile'Ulisse/Scripts/ABA.lua')
if not MainPrompt then
    repeat 
        MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
        Stepped:Wait()
    until MainPrompt
end
if not game:IsLoaded() then
	game.Loaded:Wait()
end
if not LocalPlayer then
    repeat 
        LocalPlayer=Players.LocalPlayer
        Stepped:Wait()
    until LocalPlayer
end
local PlayerGui=LocalPlayer.PlayerGui
if not PlayerGui then
    repeat 
        PlayerGui=LocalPlayer.PlayerGui
        Stepped:Wait()
    until PlayerGui
end

local function GetServers(PlaceId, Cursor)
    if not PlaceId then
        PlaceId=1458767429
    end
    local Request=syn.request({
        Url=string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100'..(Cursor and '&cursor=' .. Cursor or ''), tostring(PlaceId));
        Method='GET';
    })
    if Request and Request.Success then
        return HttpService:JSONDecode(Request.Body)
    end
end

local function GetSmallest()
    local Servers={}
    local Cursor
    repeat
        local GotServers=GetServers(PlaceId, Cursor)
        if GotServers and GotServers.data then
            for i,v in ipairs(GotServers.data) do
                table.insert(Servers, v)
            end
            Cursor = GotServers.nextPageCursor
        else
            Cursor=nil
        end
    until not Cursor
    local Server
    local Lowest=1e5
    for i,v in ipairs(Servers) do
        if v.playing and v.playing>=1 and v.playing<Lowest then
            Lowest=v.playing
            Server=v
        end
    end
    return Server, Lowest
end

local function CallTeleport()
    local Server,Lowest=GetSmallest()
    if Server and Server.id and Lowest then
        Ulisse:PrintConsole(string.format('Joining Server: %s Playing: [%s]', Server.id, Lowest))
        TeleportService:TeleportToPlaceInstance(1458767429, Server.id)
    end
    wait(2)
    CallTeleport()
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

MainPrompt.ChildAdded:Connect(function(Child)
    if typeof(Child)=='Instance' and Child.Name=='ErrorPrompt' and Child.ClassName=='Frame' then
        Ulisse:PrintConsole'ErrorPrompt Found, Teleport called'
        CallTeleport()
    end
end)

local function Play()
    if LocalPlayer:FindFirstChild'Loaded' then
        return
    end
    local MainMenu=PlayerGui:WaitForChild'MainMenu'
    local PlayButton
    repeat
        for i,v in ipairs(MainMenu:GetChildren()) do
            if v:IsA'GuiButton' and v.Text=='PLAY' then 
                PlayButton=v
                break
            end
        end
        Stepped:Wait()
    until PlayButton
    if not PlayButton then
        Ulisse:PrintConsole'PlayButton not found, err'
        return
    end
    repeat
        Ulisse:ClickButton(PlayButton) 
        wait(.5)
    until LocalPlayer:FindFirstChild'Loaded'
end

local function CheckPlayers()
    local Count=0
    for i,v in ipairs(Players:GetPlayers()) do
        if v~=LocalPlayer then
            local AFK=v:FindFirstChild'AFK'
            if AFK and (not AFK.Value) and v:FindFirstChild'Loaded' then
                Count+=1
            end
        end
    end
    if Count>1 then
        Ulisse:PrintConsole('Non AFK Players: '..tostring(Count)..'>1')
        CallTeleport()
    end
end

local function CheckMoney()
    local HUD=PlayerGui:WaitForChild'HUD'
    local CurrentMoney=0
    local MoneyLabel=HUD:WaitForChild'Money'
    if MoneyLabel then
        local Money=tonumber(MoneyLabel.Text:sub(2))
        if Money then
            CurrentMoney=Money
            Ulisse:PrintConsole(string.format('Current Money: %i',Money))
        end
    end
    wait(45)
    local MoneyLabel=HUD:WaitForChild'Money'
    if MoneyLabel then
        local Money=tonumber(MoneyLabel.Text:sub(2))
        if Money then
            if Money>CurrentMoney then
                Ulisse:PrintConsole(string.format('Money After 45: %i',Money))
                return
            else
                Ulisse:PrintConsole'Money unchanged after 45 seconds, hopping'
                CallTeleport()
            end
        end
    end
end

if game.PlaceId==5411459567 then
    CallTeleport()
end
Play()
coroutine.wrap(CheckMoney)()

while true do
    local HUD=PlayerGui:FindFirstChild'HUD'
    if HUD then
        local AFK=LocalPlayer:FindFirstChild'AFK'
        if AFK and (not AFK.Value) then
            local AFKButton=HUD:WaitForChild('AFK',3)
            Ulisse:ClickButton(AFKButton)
            wait(.5)
        end
    end
    coroutine.wrap(CheckPlayers)()
    local Voting=PlayerGui:FindFirstChild'Voting'
    if Voting then
        local Mode1=Voting:FindFirstChild'mode1'
        local Mode2=Voting:FindFirstChild'mode2'
        if Mode1 and Mode2 then
            local TL1=Mode1:FindFirstChild'TextLabel'
            local TL2=Mode2:FindFirstChild'TextLabel'
            if TL1 and TL2 then
                if TL1.Text=='Lives' then
                    wait(.5)
                    Ulisse:ClickButton(TL1)
                elseif TL2.Text=='Lives' then
                    wait(.5)
                    Ulisse:ClickButton(TL2)
                else
                    Ulisse:PrintConsole'Lives gamemode not found, teleporting.'
                    CallTeleport()
                end
            end
        end
    end
    wait(1)
end