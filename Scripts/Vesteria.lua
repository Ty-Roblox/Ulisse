if not game:IsLoaded() then
	game.Loaded:Wait()
end
rconsolename'Ulisse'
local FireServer=Instance.new'RemoteEvent'.FireServer
local OldFS
local GodMode=false
OldFS=hookfunction(FireServer, newcclosure(function(Self, ...)
	if not checkcaller() then
		local Args={...}
		if Args and Args[3] and typeof(Args[3])=='string' and Args[3]=='monster' and GodMode then
			return
		end
	end
	return OldFS(Self,...)
end))
local UI=UlisseUI:Main()
local Tab=UI:Tab'Tab 1'
local Section=Tab:Section'Section'
Section:Item('toggle','Monster Godmode',function(v)
    GodMode=v
end)