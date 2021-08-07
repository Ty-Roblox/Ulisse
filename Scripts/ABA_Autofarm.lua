if shared.ABAFarmRan then
    return
end
shared.ABAFarmRan=true
shared.AbaDebugMode=false
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
syn.queue_on_teleport(readfile'Ulisse/Scripts/ABA_Autofarm.lua')
if not MainPrompt then
    repeat 
        MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)
        Stepped:Wait()
    until MainPrompt
end

local function Debug(...)
    if shared.AbaDebugMode then
        pcall(OutputToConsole, string.format('[ULISSE ABA DEBUG] %s', ...))
    end
end

local function GetServers(PlaceId, Cursor)
    Debug('Requesting Pages')
    if not PlaceId then
        PlaceId=1458767429
    end
    local Request=syn.request({
        Url=string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100'..(Cursor and '&cursor=' .. Cursor or ''), tostring(PlaceId));
        Method='GET';
    })
    if Request and Request.Success then
        Debug('Got pages success')
        return HttpService:JSONDecode(Request.Body)
    end
    Debug('Pages failed')
end
local function GetSmallest()
    local Servers={}
    local Cursor
    local iteration=0
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
        warn(Cursor,iteration)
        iteration+=1
        Debug(string.format('Iteration: %d', iteration))
    until not Cursor
    Debug(string.format('Final: %s', Cursor))
    local Server
    local Lowest=1e5
    for i,v in ipairs(Servers) do
        if v.playing and v.playing>=1 and v.playing<Lowest then
            Lowest=v.playing
            Server=v
        end
    end
    Debug('Done getting servers')
    return Server, Lowest
end

local function CallTeleport()
    local Server,Lowest=GetSmallest()
    if Server and Server.id and Lowest then
        Ulisse:SetColor'yellow'
        Ulisse:PrintConsole(string.format('Joining Server: %s Playing: [%s]', Server.id, Lowest))
        Ulisse:SetColor()
        for I=1,5 do
            pcall(TeleportService.TeleportToPlaceInstance, TeleportService, 1458767429, Server.id)
            wait(1)
        end
    end
    wait(2)
    Debug('Teleport called again')
    CallTeleport()
end

MainPrompt.ChildAdded:Connect(function(Child)
    if Child.Name=='ErrorPrompt' then
        Ulisse:SetColor'red'
        Ulisse:PrintConsole'ErrorPrompt Found, Teleport called'
        Ulisse:SetColor()
        Debug('Error prompt got')
        CallTeleport()
    end
end)

if not game:IsLoaded() then
	game.Loaded:Wait()
end
if not LocalPlayer then
    repeat 
        LocalPlayer=Players.LocalPlayer
        Stepped:Wait()
    until LocalPlayer
end
Debug('Localplayer got')
local PlayerGui=LocalPlayer.PlayerGui
if not PlayerGui then
    repeat 
        PlayerGui=LocalPlayer.PlayerGui
        Stepped:Wait()
    until PlayerGui
end
Debug('Playergui got')

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    Debug('Idle captured')
end)

local function Play()
    if LocalPlayer:FindFirstChild'Loaded' then
        Debug('Loaded true')
        return
    end
    Debug('Not loaded')
    local MainMenu=PlayerGui:WaitForChild'MainMenu'
    local PlayButton
    repeat
        for i,v in ipairs(MainMenu:GetChildren()) do
            if v:IsA'GuiButton' and v.Text=='PLAY' then 
                PlayButton=v
                break
            end
        end
        Debug('No playbutton')
        Stepped:Wait()
    until PlayButton
    Debug('Got playbutton')
    if not PlayButton then
        Ulisse:SetColor'red'
        Ulisse:PrintConsole'PlayButton not found, err'
        Ulisse:SetColor()
        CallTeleport()
        Debug('Button not found')
        return
    end
    repeat
        Ulisse:ClickButton(PlayButton) 
        wait(1)
        Debug('Commit click button')
    until LocalPlayer:FindFirstChild'Loaded'
end

local function CheckPlayers()
    local Count=0
    Debug('Player check called')
    for i,v in ipairs(Players:GetPlayers()) do
        if v~=LocalPlayer then
            local AFK=v:FindFirstChild'AFK'
            if AFK and (not AFK.Value) and v:FindFirstChild'Loaded' then
                Count+=1
            end
        end
    end
    Debug('Done checking players')
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
        Debug('Got moolah')
        local Money=tonumber(MoneyLabel.Text:sub(2))
        if Money then
            CurrentMoney=Money
            Ulisse:PrintConsole(string.format('Current Money: %i',Money))
        end
    end
    wait(45)
    local MoneyLabel=HUD:WaitForChild'Money'
    if MoneyLabel then
        Debug('Got moolah 2')
        local Money=tonumber(MoneyLabel.Text:sub(2))
        if Money then
            if Money>CurrentMoney then
                Ulisse:SetColor'green'
                Ulisse:PrintConsole(string.format('Money After 45: %i',Money))
                Ulisse:SetColor()
                return
            else
                Ulisse:SetColor'red'
                Ulisse:PrintConsole'Money unchanged after 45 seconds, hopping'
                Ulisse:SetColor()
                CallTeleport()
            end
        end
    end
end

if game.PlaceId==5411459567 then
    CallTeleport()
    Debug('afk world got, teleporting')
end
Play()
coroutine.wrap(CheckMoney)()

while true do
    local HUD=PlayerGui:FindFirstChild'HUD'
    if HUD then
        local AFK=LocalPlayer:FindFirstChild'AFK'
        if AFK and (not AFK.Value) then
            Debug('Click button called cuz afk yes')
            local AFKButton=HUD:WaitForChild('AFK',3)
            Ulisse:ClickButton(AFKButton)
            wait(.5)
        end
    end
    Debug('Checking players')
    coroutine.wrap(CheckPlayers)()
    local Voting=PlayerGui:FindFirstChild'Voting'
    if Voting then
        Debug('voting found')
        local Mode1=Voting:FindFirstChild'mode1'
        local Mode2=Voting:FindFirstChild'mode2'
        if Mode1 and Mode2 then
            local TL1=Mode1:FindFirstChild'TextLabel'
            local TL2=Mode2:FindFirstChild'TextLabel'
            if TL1 and TL2 then
                if TL1.Text=='Lives' then
                    wait(.5)
                    Ulisse:ClickButton(TL1)
                    Debug('Button 1 lives clicked')
                elseif TL2.Text=='Lives' then
                    wait(.5)
                    Ulisse:ClickButton(TL2)
                    Debug('Button 2 lives clicked')
                else
                    Debug('No lives :(')
                    Ulisse:SetColor'red'
                    Ulisse:PrintConsole'Lives gamemode not found, teleporting.'
                    Ulisse:SetColor()
                    CallTeleport()
                end
            end
        end
    end
    Debug('Looping')
    wait(1)
end