if not syn then
    return
end
if shared.NCHook then
    hookfunction(getrawmetatable(game).__namecall,shared.NCHook)
end
if shared.BindEvent then
    shared.BindEvent:Destroy()
end

local HttpService=game:service'HttpService'
local Players=game:service'Players'
local LocalPlayer=Players.LocalPlayer
local SocketHost='ws://localhost:7331'

local SocketHandler={}
SocketHandler.SocketServer='ws://localhost:7331'
SocketHandler.Debug=true
SocketHandler.CurrentSocket=nil
SocketHandler.MessageConnection=nil
local LogNamecall=true

local BindEvent=Instance.new'BindableEvent'
shared.BindEvent=BindEvent

function SocketHandler:SafePrint(...)
    local Args={...}
    for i,v in pairs(Args) do
        rconsoleprint(string.format('%s\n',tostring(v)))
    end
end

function SocketHandler:MessageHandler()
    if self.CurrentSocket then
        self.MessageConnection=self.CurrentSocket.OnMessage:Connect(function(Msg)
            self:SafePrint(Msg)
        end)
    end
end

function SocketHandler:Connect()
    local Success,Return=pcall(syn.websocket.connect, self.SocketServer)
    if Success and Return then
        if self.Debug then
            self:SafePrint('Connected to '..self.SocketServer)
        end
        if self.CurrentSocket then
            self.CurrentSocket:Close()
            self.CurrentSocket=nil
        end
        if self.MessageConnection then
            self.MessageConnection=nil
        end
        self.CurrentSocket=Return
        self:MessageHandler()
		wait(2)
    else
        self:SafePrint('Failed to connect to '..self.SocketServer)
        for i=-5,0 do
            self:SafePrint('Retrying in: '..tostring(i):gsub('-',''))
            wait(1)
        end
        self:Connect()
    end
end

if shared.UseServer then
    SocketHandler:Connect()
end

local function IsService(Name)
	local Success, Return=pcall(function()
		return game:service(Name)
	end)
	return Success
end

local Format={}

function Format:CheckTable(Table)
    for i,v in pairs(Table) do
        if typeof(i)~='number' then
            return true
        end
    end
end

function Format:FormatPath(This)
    local Path=This:GetFullName()
    local Args=string.split(Path, '.')
    if Args and Args[1] then
        if IsService(Args[1]) then
            Args[1]=string.format('game:service\'%s\'', Args[1])
            if Args[1]=='game:service\'Workspace\'' then
                Args[1]='workspace'
            end
            if Args[1]=='game:service\'Players\'' and Args[2]==LocalPlayer.Name then
                Args[2]='LocalPlayer'
            end
            if Args[1]=='workspace' and Args[2]==LocalPlayer.Name then
                Args[1]='game:service\'Players\''
                Args[2]='LocalPlayer'
                Args[3]='Character'
            end
        end
        for i,v in ipairs(Args) do
            if string.match(v, '%s') then
                Args[i]=string.format(':FindFirstChild\'%s\'',v)
            end
        end
    end
    local Concat=''
    for i,v in ipairs(Args) do
        if Args[i+1] and string.sub(Args[i+1],1,1)==':' or (not Args[i+1]) then
            Concat=Concat..string.format('%s',v)
        else
            Concat=Concat..string.format('%s.',v)
        end
    end
    return Concat
end

function Format:RecurseTable(Table, Index)
    if not Index then
        Index=0
    end
    if Index>5 then
        rconsoleprint'Table too big\n'
    end
    Index+=1
    local FormattedTable={}
    if not self:CheckTable(Table) then
        warn'Got normal table'
        for i=1,#Table do
            local v=Table[i]
            if v==nil then
                FormattedTable[i]='nil'
                warn'Got nil'
            end
            local Type=typeof(v)
            if Type=='Instance' then
                local InstancePath=Format:FormatPath(v)
                FormattedTable[i]=InstancePath
            elseif Type=='userdata' or Type=='boolean' then
                FormattedTable[i]=tostring(v)
            elseif Type=='CFrame' then
                local X,Y,Z=v.Position.X,v.Position.Y,v.Position.Z
                local LX,LY,LZ=v.LookVector.X,v.LookVector.Y,v.LookVector.Z
                FormattedTable[i]=string.format('CFrame.new(%f,%f,%f,%f,%f,%f)',X,Y,Z,LX,LY,LZ)
            elseif Type=='Vector3' then
                local X,Y,Z=v.X, v.Y, V.Z
                FormattedTable[i]=string.format('Vector3.new(%f,%f,%f)',X,Y,Z)
            elseif Type=='Color3' then
                local R,G,B=v.R*255,v.G*255,v.B*255
                FormattedTable[i]=string.format('Color3.fromRGB(%f,%f,%f)',R,G,B)
            elseif Type=='Vector2' then
                local X,Y=v.X, v.Y
                FormattedTable[i]=string.format('Vector2.new(%f,%f)',X,Y)
            elseif Type=='string' then
                FormattedTable[i]=string.format('\'%s\'',v)
            elseif Type=='number' then
                FormattedTable[i]=string.format('%s',tostring(v))
            end
            if Type=='table' then
                FormattedTable[i]=string.format('{%s}', Format:RecurseTable(v, Index))
                warn'Got table'
            end
            warn('Call:', i, typeof(v), v)
        end
    else
        warn'Got dictionary'
        for i,v in pairs(Table) do
            if v==nil then
                FormattedTable[i]='nil'
                warn'Got nil'
            end
            local Type=typeof(v)
            if Type=='Instance' then
                local InstancePath=Format:FormatPath(v)
                FormattedTable[i]=InstancePath
            elseif Type=='userdata' or Type=='boolean' then
                FormattedTable[i]=tostring(v)
            elseif Type=='CFrame' then
                local X,Y,Z=v.Position.X,v.Position.Y,v.Position.Z
                local LX,LY,LZ=v.LookVector.X,v.LookVector.Y,v.LookVector.Z
                FormattedTable[i]=string.format('CFrame.new(%f,%f,%f,%f,%f,%f)',X,Y,Z,LX,LY,LZ)
            elseif Type=='Vector3' then
                local X,Y,Z=v.X, v.Y, V.Z
                FormattedTable[i]=string.format('Vector3.new(%f,%f,%f)',X,Y,Z)
            elseif Type=='Color3' then
                local R,G,B=v.R*255,v.G*255,v.B*255
                FormattedTable[i]=string.format('Color3.fromRGB(%f,%f,%f)',R,G,B)
            elseif Type=='Vector2' then
                local X,Y=v.X, v.Y
                FormattedTable[i]=string.format('Vector2.new(%f,%f)',X,Y)
            elseif Type=='string' then
                FormattedTable[i]=string.format('\'%s\'',v)
            elseif Type=='number' then
                FormattedTable[i]=string.format('%s',tostring(v))
            end
            if Type=='table' then
                FormattedTable[i]=string.format('{%s}', Format:RecurseTable(v, Index))
                warn'Got table'
            end
            warn('Call:', i, typeof(v), v)
        end
    end
    if self:CheckTable(FormattedTable) then
        local Concat=''
        for i,v in pairs(FormattedTable) do
            Concat=Concat..string.format('%s=%s; ',tostring(i),tostring(v))
        end
        return Concat
    else
        local Concat=''
        for i,v in pairs(FormattedTable) do
            if (not FormattedTable[i+1]) then
                Concat=Concat..string.format('%s',tostring(v))
            else
                Concat=Concat..string.format('%s, ',tostring(v))
            end
        end
        return Concat
    end
end

BindEvent.Event:Connect(function(This, Method, ...)
    if This:IsA'RemoteFunction' or This:IsA'RemoteEvent' then
        local Args={...}
        local Path=Format:FormatPath(This)
        local NewArgs=Format:RecurseTable(Args)
        warn(NewArgs)
        if shared.UseServer then
            SocketHandler.CurrentSocket:Send(string.format('%s:%s(%s)', Path, Method, NewArgs))
        else
            rconsoleprint(string.format('%s:%s(%s)\n', Path, Method, NewArgs))
        end
    elseif This:IsA'ClickDetector' then
        local Path=Format:FormatPath(This)
        if shared.UseServer then
            SocketHandler.CurrentSocket:Send(string.format('fireclickdetector(%s)',Path))
        else
            rconsoleprint(string.format('fireclickdetector(%s)\n',Path))
        end
    elseif This:IsA'TouchTransmitter' then
        local Args={...}
        if Args and Args[1] then
            Args[1]=Format:FormatPath(Args[1])
        end
        local Path=Format:FormatPath(This.Parent)
        if shared.UseServer then
            SocketHandler.CurrentSocket:Send(string.format('firetouchinterest(%s,%s,0)',Path,Args[1]))
        else
            rconsoleprint(string.format('firetouchinterest(%s,%s,0)\n',Path,Args[1]))
        end
    end
end)

local OldNamecall
OldNamecall=hookfunction(getrawmetatable(game).__namecall, newcclosure(function(This, ...)
    if LogNamecall then
        if not checkcaller() then
            local Method=getnamecallmethod()
            if Method=='FireServer' or Method=='InvokeServer' then
                --coroutine.wrap(BindEvent.Fire, BindEvent, This, Method, ...)
                --BindEvent.Fire(BindEvent, This, Method, ...)
                local Success,Return=pcall(BindEvent.Fire, BindEvent, This, Method, ...)
                if not Success then
                    warn(Return)
                end
                return OldNamecall(This, ...)
            end
        end
    end
    return OldNamecall(This, ...)
end))

for i,v in ipairs(game:GetDescendants()) do
    if v:IsA'ClickDetector' then
        v.MouseClick:Connect(function()
            local Success,Return=pcall(BindEvent.Fire, BindEvent, v)
            if not Success then
                warn(Return)
            end
        end)
    elseif v:IsA'TouchTransmitter' and v.Parent and v.Parent:IsA'BasePart' then
        v.Parent.Touched:Connect(function(Hit)
            if LocalPlayer.Character then
                if Hit:IsDescendantOf(LocalPlayer.Character) then
                    local Success,Return=pcall(BindEvent.Fire, BindEvent, v, 'Touched', Hit)
                    if not Success then
                        warn(Return)
                    end
                end
            end
        end)
    end
end

shared.NCHook=OldNamecall

print''
print''
print''