getgenv().Ulisse={}
local Env=getgenv().Ulisse
local Players=game:GetService'Players'
local VirtualUser=game:GetService'VirtualUser'
local TeleportService=game:service'TeleportService'
local HttpService=game:service'HttpService'
local RunService=game:service'RunService'
local LocalPlayer=Players.LocalPlayer or Players.PlayerAdded:Wait()

function Env:InsertTable(Table1, Table2)
    for i,v in ipairs(Table2) do
        table.insert(Table1, v)
    end
end

function Env:ClickButton(Obj)
    if Obj and Obj:IsA'GuiButton' then
        local Connections={}
        self:InsertTable(Connections, getconnections(Obj.MouseButton1Down))
        self:InsertTable(Connections, getconnections(Obj.MouseButton1Up))
        self:InsertTable(Connections, getconnections(Obj.Activated))
        for i,v in ipairs(Connections) do
            v:Fire()
        end
    end
end

function Env:PrintConsole(...)
    if not shared.StopOutput then
        local Args={...}
        for i,v in pairs(Args) do 
            Args[i]=tostring(v)
        end
        local PrintStr=table.concat(Args, '    ')
        rconsoleprint(string.format('%s\n', PrintStr))
    end
end

function Env:SetColor(Color) 
	if not Color or typeof(Color)~='string' then
		Color='WHITE'
	end
	Color=string.upper(Color)
	rconsoleprint('@@'..Color..'@@')
end

function Env:GetServerPage(PlaceId, Cursor)
    if not PlaceId then
        PlaceId=game.PlaceId
    end
    local Request=syn.request({
        Url=string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100'..(Cursor and '&cursor=' .. Cursor or ''), tostring(PlaceId));
        Method='GET';
    })
    if Request and Request.Success then
        return HttpService:JSONDecode(Request.Body)
    end
end

function Env:GetAllServers(PlaceId, FastMode)
    local Servers={}
    local Cursor
    local Idx=0
    while true do
        local Page=self:GetServerPage(PlaceId, Cursor)
        if Page and Page.data then
            Idx+=1
            for i,v in ipairs(Page.data) do
                table.insert(Servers,v)
            end
            if FastMode and Idx>5 then
                break
            end
            if Page.nextPageCursor then
                Cursor=Page.nextPageCursor
            else
                break
            end
        else    
            warn'??'
            break
        end
        RunService.Heartbeat:Wait()
    end
    return Servers
end

function Env:BlacklistServer(JobId, Time)
    local Blacklisted
    if isfile'TeleportAPINew.JSON' then
        local Content=readfile'TeleportAPINew.JSON'
        Blacklisted=HttpService:JSONDecode(Content)
    else
        Blacklisted={}
    end
    table.insert(Blacklisted, {Time=os.time(), JobId=JobId})
    writefile('TeleportAPINew.JSON', HttpService:JSONEncode(Blacklisted))
end

function Env:UpdateBlacklistTime(Time)
    local Blacklisted
    if isfile'TeleportAPINew.JSON' then
        local Content=readfile'TeleportAPINew.JSON'
        Blacklisted=HttpService:JSONDecode(Content)
    else
        Blacklisted={}
    end
    local Clean={}
    local Changed=false
    for i,v in ipairs(Blacklisted) do
        if (os.time()-v.Time)<=Time then
            table.insert(Clean, v)
        else
            warn'Removed for time'
            Changed=true
        end
    end
    if Changed then
        writefile('TeleportAPINew.JSON', HttpService:JSONEncode(Clean))
    end
end

function Env:CheckBlacklisted(JobId)
    local Blacklisted
    if isfile'TeleportAPINew.JSON' then
        local Content=readfile'TeleportAPINew.JSON'
        Blacklisted=HttpService:JSONDecode(Content)
    else
        Blacklisted={}
    end
    for i,v in ipairs(Blacklisted) do
        if v and v.JobId and v.JobId==JobId then
            return true
        end
    end
end

function Env:JoinServer(PlaceId, Method, BlacklistTime, FastMode, FreeSlots)
    if not PlaceId then
        PlaceId=game.PlaceId
    end
    if not Method then
        Method='Asc'
    end
    if not BlacklistTime then
        BlacklistTime=300
    end
    if not FastMode then
        FastMode=false
    end
    if not FreeSlots then
        FreeSlots=1
    end
    self:UpdateBlacklistTime(BlacklistTime)
    local Servers=self:GetAllServers(PlaceId, FastMode)
    local Filtered={}
    for i,v in ipairs(Servers) do
        if (not self:CheckBlacklisted(v.id)) and v.playing and (v.playing+FreeSlots)<v.maxPlayers and v.id~=game.JobId then
            table.insert(Filtered, v)
        end
    end
    table.sort(Filtered,function(First,Second)
        if Method=='Asc' then
            return First.playing < Second.playing
        else
            return First.playing > Second.playing
        end
    end)
    if Filtered[1] then
        if not self:CheckBlacklisted(Filtered[1].id) then
            self:BlacklistServer(Filtered[1].id, BlacklistTime)
			local Success,Return = pcall(function()
			    TeleportService:TeleportToPlaceInstance(PlaceId, Filtered[1].id)
			end)
			if not Success then
				wait()
				self:JoinServer(PlaceId, Method, BlacklistTime, FastMode, FreeSlots)
			end
        end
    else
        warn'Failed'
    end
end

if isfile'Ulisse/Env.lua' then
    syn.queue_on_teleport(readfile'Ulisse/Env.lua')
end

if isfile'Ulisse/MaterialUI.lua' then
    Env.MaterialUI=loadstring(readfile'Ulisse/MaterialUI.lua')()
end

if isfile'Ulisse/UI.lua' then
    Env.UI=loadstring(readfile'Ulisse/UI.lua')()
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
