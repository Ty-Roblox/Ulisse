local TeleportService=game:service'TeleportService'
local HttpService=game:service'HttpService'
local RunService=game:service'RunService'

local Module={}

function Module:GetServerPage(PlaceId, Cursor)
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

function Module:GetAllServers(PlaceId, FastMode)
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

function Module:BlacklistServer(JobId, Time)
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

function Module:UpdateBlacklistTime(Time)
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

function Module:CheckBlacklisted(JobId)
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

function Module:JoinServer(PlaceId, Method, BlacklistTime, FastMode, FreeSlots)
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

return Module