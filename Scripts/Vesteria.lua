if not game:IsLoaded() then
	game.Loaded:Wait()
end
rconsolename'Ulisse'
local FireServer=Instance.new'RemoteEvent'.FireServer
local OldFS
OldFS=hookfunction(FireServer, newcclosure(function(Self, ...)
	if not checkcaller() then
		local Args={...}
		if Args and Args[3] and typeof(Args[3])=='string' and Args[3]=='monster' then
			rconsoleprint'Monster damage called, returning\n'
			return
		end
	end
	return OldFS(Self,...)
end))
