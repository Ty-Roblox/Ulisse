if not syn then --[[Sorry, this only supports synapse for now]]
    return
end
local HttpService=game:service'HttpService'
local AssetService=game:service'AssetService'
local RawServer='https://raw.githubusercontent.com'
local Repo='Ty-Roblox/Ulisse'
local Branch='main'
local VersionFileName='Version'
local RepoPath=string.format('%s/%s/%s',RawServer,Repo,Branch)
local UlisseFolderExists=isfolder'Ulisse'
local IsDebug=false

local Pages=AssetService:GetGamePlacesAsync()
local Places={}

local function Debugp(...)
    if IsDebug then
        local Args={...}
        if Args then
            for i,v in pairs(Args) do 
                Args[i]=tostring(v)
            end
            local PrintStr=table.concat(Args, '    ')
            warn(PrintStr)
        else
            warn'No args'
        end
    end
end

getgenv().OutputToConsole=function(...)
    if not shared.StopOutput then
        local Args={...}
        for i,v in pairs(Args) do 
            Args[i]=tostring(v)
        end
        local PrintStr=table.concat(Args, '    ')
        rconsoleprint(string.format('%s\n', PrintStr))
    end
end

getgenv().DownloadString=function(Path)
    SetColor'light_green'
    OutputToConsole(string.format('Downloading: %s',Path))
    SetColor()
    local Request=syn.request({
        Url=Path,
        Method='GET',
        Headers={
            ['Cache-Control']='no-cache, no-store, max-age=0, must-revalidate';
            ['Pragma']='no-cache';
            ['Expires']='-1';
        }
    })
    if Request and Request.Success then
        Debugp('Request Success', Path)
        return Request.Body
    else
        Debugp('Request Failed', Path, Request.StatusMessage, Request.StatusCode)
    end
end

getgenv().SetColor=function(Color) 
	if not Color or typeof(Color)~='string' then
		Color='WHITE'
	end
	Color=string.upper(Color)
	rconsoleprint('@@'..Color..'@@')
end

while true do
	for i,v in ipairs(Pages:GetCurrentPage()) do
		table.insert(Places, v.PlaceId)
	end
	if Pages.IsFinished then
		break
	end
	Pages:AdvanceToNextPageAsync()
end

local function IsPlace()
	for i,v in ipairs(Places) do
		if v==game.PlaceId then
			return v
		end	
	end
end

local function CheckTable(Table,Value)
    for i,v in ipairs(Table) do
        if v==Value then
            return v
        end
    end
end

local function Load()
    Debugp'Load'
    local DecodedGameScripts=HttpService:JSONDecode(readfile'Ulisse/UlisseScripts.json')
    if DecodedGameScripts then
        local UIFile=isfile'Ulisse/UI.lua'
        local EnvFile=isfile'Ulisse/Env.lua'
        if EnvFile then
            local Env=readfile'Ulisse/Env.lua'
            loadstring(Env)()
            syn.queue_on_teleport(Env)
        end
        if UIFile and EnvFile then
            local CurrentGame=DecodedGameScripts[tostring(game.PlaceId)]
            if IsPlace() and CurrentGame then
                for i,v in ipairs(CurrentGame) do
                    local ScrPath=string.format('Ulisse/Scripts/%s',v)
                    if isfile(ScrPath) then
                        SetColor'green'
                        OutputToConsole(string.format('Running file: %s', ScrPath))
                        SetColor()
                        loadstring(readfile(ScrPath))()
                    else
                        SetColor'red'
                        OutputToConsole(string.format('File missing: %s',ScrPath))
                        SetColor()
                    end
                end
            else
                SetColor'red'
                OutputToConsole'No scripts for game found'
                SetColor()
            end
        else
            SetColor'red'
            OutputToConsole'UI file missing..? / Env file missing'
            SetColor()
        end
    else
        SetColor'red'
        OutputToConsole'Failed to run, try again..?'
        SetColor()
    end
end

local function Update()
    SetColor'green'
    OutputToConsole('New version detected/Files not found, Updating!')
    SetColor()
    Debugp'Update Called'
    if UlisseFolderExists then
        Debugp'Folder removed'
        delfolder'Ulisse'
    end
    makefolder'Ulisse'
    local ScriptsFolder=isfolder'Ulisse/Scripts'
    local VersionFile=DownloadString(string.format('%s/%s',RepoPath,VersionFileName))
    if VersionFile then
        writefile('Ulisse/Ulisse.VERSION', VersionFile)
    end
    if not ScriptsFolder then
        makefolder'Ulisse/Scripts'
    end
    local UiFile=DownloadString(string.format('%s/%s',RepoPath,'UI.lua'))
    if UiFile then
        writefile('Ulisse/UI.lua', UiFile)
    end
    local EnvFile=DownloadString(string.format('%s/%s',RepoPath,'Env.lua'))
    if EnvFile then
        writefile('Ulisse/Env.lua', EnvFile)
    end
    local ManifestFile=DownloadString(string.format('%s/Scripts.json',RepoPath))
    if ManifestFile then
        writefile('Ulisse/UlisseScripts.json', ManifestFile)
        local DecodedGameScripts=HttpService:JSONDecode(readfile'Ulisse/UlisseScripts.json')
        if DecodedGameScripts then
            local Downloaded={}
            for i,v in pairs(DecodedGameScripts) do
                for Idx,Val in ipairs(v) do
                    Debugp(Val)
                    if not CheckTable(Downloaded,Val) then
                        table.insert(Downloaded, Val)
                        local Script=DownloadString(string.format('%s/Scripts/%s',RepoPath,Val))
                        if Script then
                            local Path=string.format('Ulisse/Scripts/%s',Val)
                            writefile(string.format('Ulisse/Scripts/%s',Val), Script)
                        end
                    end
                end
            end
        end
    end
    SetColor'green'
    OutputToConsole('Done, Loading now.')
    SetColor()
    Load()
end

local function Start()
    if not shared.StopOutput then
        rconsolename'Ulisse'
    end
    if UlisseFolderExists then
        local CurrentVersionFileExists=isfile'Ulisse/Ulisse.VERSION'
        if CurrentVersionFileExists then
            local CurrentVersion=readfile'Ulisse/Ulisse.VERSION'
            local ServerVersion=DownloadString(string.format('%s/%s',RepoPath,VersionFileName))
            SetColor'yellow'
            OutputToConsole(string.format('Client Version: %s, Server Version: %s',CurrentVersion,ServerVersion))
            SetColor()
            if ServerVersion and CurrentVersion==ServerVersion then
                Load()
            else
                Update()
            end
        else
            Update()
        end
    else
        Update()
    end    
end

Start()

Debugp'Done'