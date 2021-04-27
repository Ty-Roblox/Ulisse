if not game:IsLoaded() then
	game.Loaded:Wait()
end
if game.PlaceId==5411459567 or game.PlaceId==1458767429 then	
	syn.queue_on_teleport(readfile'Ulisse/Scripts/ABACoinfarm.lua')
	local Players=game:service'Players'
	local HttpService=game:service'HttpService'
	local TeleportService=game:service'TeleportService'
	local ReplicatedStorage=game:service'ReplicatedStorage'
	local VirtualUser=game:service'VirtualUser'
	local CoreGui=game:service'CoreGui'
	local LocalPlayer=Players.LocalPlayer
	local PlayerGui=LocalPlayer.PlayerGui
	local BP
	local Joined=0
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
			rconsoleprint(string.format('Joining Server: %s Playing: [%s]\n', Server.id, Lowest))
			TeleportService:TeleportToPlaceInstance(1458767429, Server.id)
		end
		wait(2)
		CallTeleport()
	end

	coroutine.wrap(function()
		local HUD=PlayerGui:WaitForChild'HUD'
		local CurrentMoney=0
		local MoneyLabel=HUD:WaitForChild'Money'
		wait(4)
		if MoneyLabel then
			local Money=tonumber(MoneyLabel.Text:sub(2))
			if Money then
				CurrentMoney=Money
				rconsoleprint(string.format('Current Money: %i\n',Money))
			end
		end
		wait(30)
		local MoneyLabel=HUD:WaitForChild'Money'
		if MoneyLabel then
			local Money=tonumber(MoneyLabel.Text:sub(2))
			if Money then
				if Money>CurrentMoney then
					rconsoleprint(string.format('Money After 30: %i\n',Money))
					return
				else
					rconsoleprint'Money unchanged after 30 seconds, hopping\n'
					CallTeleport()
				end
			end
		end
	end)()

	local MainPrompt=CoreGui:FindFirstChild('promptOverlay', true)

	local function Alert()
		local CurrentTimeTable=os.date('*t', os.time())
		rconsoleprint(string.format('Disconnected: [%s:%s](%s) Reconnecting\n',tostring(CurrentTimeTable.hour),tostring(CurrentTimeTable.min),tostring(CurrentTimeTable.sec)))
		while true do
			pcall(TeleportService.Teleport, TeleportService, LocalPlayer)
			wait(2)
		end
	end

	if MainPrompt then
		if MainPrompt:FindFirstChild'ErrorPrompt' then
			Alert()
		end
		MainPrompt.ChildAdded:Connect(function(Child)
			if typeof(Child)=='Instance' and Child.Name=='ErrorPrompt' and Child.ClassName=='Frame' then
				Alert()
			end
		end)
	else
		rconsoleprint'Error promptOverlay not found\n'
	end

	repeat wait()
	BP=LocalPlayer.Backpack
	until LocalPlayer.Backpack
	local PlayerGui
	repeat wait()
	PlayerGui=LocalPlayer.PlayerGui
	until LocalPlayer.PlayerGui
	local Chat=ReplicatedStorage:WaitForChild'DefaultChatSystemChatEvents':WaitForChild'SayMessageRequest'
	local Loaded=ReplicatedStorage:WaitForChild('Loaded',15)
	local HUD
	local LastInt=0

	LocalPlayer.Idled:Connect(function()
	   VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	   wait(1)
	   VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)

	local function StartLives()
		local Traits=BP:FindFirstChild'ServerTraits'
		if Traits then
			local Input=Traits:FindFirstChild'Input'
			if Input then
				rconsoleprint'Voted for lives\n'
				local Payload={'mode', {choice='Lives'}}
				Input:FireServer(unpack(Payload))
				wait(3)
			end
		end
	end

	if game.PlaceId==5411459567 then
		CallTeleport()
	end

	local function CheckPlayers()
		local Count=0
		for i,v in ipairs(Players:GetPlayers()) do
			if v~=LocalPlayer then
				local AFK=v:FindFirstChild'AFK'
				if AFK and (not AFK.Value) then
					Count+=1
				end
			end
		end
		if Count>1 then
			rconsoleprint('Players that arent afk: '..tostring(Count)..'>1\n')
			CallTeleport()
		end
	end

	coroutine.wrap(function()
		if not Loaded then
			rconsoleprint'Not loaded???\n'
		end
		if Loaded then
			Loaded:FireServer()
		end
		delay(10, function()
			game:service'ReplicatedStorage'.Loaded:FireServer()
		end)
		HUD=PlayerGui:WaitForChild('HUD',10)
		local RandomStr='afk'
		if shared.ChatTroll then
			local String = game:HttpGet'https://pastebin.com/raw/0DmvhYvd'
			local StringTable = {}
			local LastIndex = 1
			for i = 1,#String do
				if String:sub(i,i) == "." then
					table.insert(StringTable,String:sub(LastIndex,i))
					LastIndex = i+1
				end
			end
			while true do
				for i,v in pairs(StringTable) do
					Chat:FireServer(RandomStr, 'All')
					wait(2.5)
				end
			end
		end
	end)()

	while true do
		local HUD=PlayerGui:FindFirstChild'HUD'
		if HUD then
			local MyAFK=LocalPlayer:FindFirstChild'AFK'
			if MyAFK and (not MyAFK.Value) then
				local Traits=BP:FindFirstChild'ServerTraits'
				if Traits then
					local AFK=Traits:FindFirstChild'AFK'
					if AFK then
						AFK:FireServer(true)
						wait(.5)
					end
				end
			end
		end
		CheckPlayers()
		local Voting=PlayerGui:FindFirstChild'Voting'
		if Voting then
			local Mode1=Voting:FindFirstChild'mode1'
			local Mode2=Voting:FindFirstChild'mode2'
			if Mode1 and Mode2 then
				local TL1=Mode1:FindFirstChild'TextLabel'
				local TL2=Mode2:FindFirstChild'TextLabel'
				if TL1 and TL2 then
					if TL1.Text=='Lives' then
						wait(1)
						StartLives()
					elseif TL2.Text=='Lives' then
						wait(1)
						StartLives()
					else
						rconsoleprint'Lives gamemode not found, teleporting.\n'
						CallTeleport()
					end
				end
			end
		end
		wait(1)
	end
end 