getgenv().Ulisse={}
local Env=getgenv().Ulisse

local Players=game:service'Players'
local LocalPlayer=Players.LocalPlayer

function Env:InsertTable(Table1, Table2)
    for i,v in ipairs(Table2) do
        table.insert(Table1, v)
    end
end

function Env:ClickButton(Obj)
    if Obj and Obj:IsA'GuiButton' then
        local Connections={}
        self:InsertTable(Connections, getconnections(Obj.MouseButton1Click))
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

if isfile'Ulisse/Env.lua' then
    syn.queue_on_teleport(readfile'Ulisse/Env.lua')
end

if isfile'Ulisse/MaterialUI.lua' then
    Env.MaterialUI=loadstring(readfile'Ulisse/MaterialUI.lua')()
end

if isfile'Ulisse/UI.lua' then
    Env.UI=loadstring(readfile'Ulisse/UI.lua')()
end

repeat wait()
    LocalPlayer=Players.LocalPlayer
until LocalPlayer

for i,v in ipairs(getconnections(LocalPlayer.Idled)) do
    if v.Connected then
        v:Disconnect()
    end
end