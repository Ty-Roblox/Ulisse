if not syn then --[[Sorry, this only supports synapse for now]]
    return
end
local HttpService=game:service'HttpService'
local RawServer='https://raw.githubusercontent.com'
local Repo='Ty-Roblox/Ulisse'
local Branch='main'
local VersionFileName='Version'
local RepoPath=string.format('%s/%s/%s',RawServer,Repo,Branch)
local UlisseFolderExists=isfolder'Ulisse'
local IsDebug=false

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
    local Args={...}
    for i,v in pairs(Args) do 
        Args[i]=tostring(v)
    end
    local PrintStr=table.concat(Args, '    ')
    rconsoleprint(string.format('%s\n', PrintStr))
end

getgenv().DownloadString=function(Path)
    OutputToConsole(string.format('Downloading: %s',Path))
    local Request=syn.request({
        Url=Path,
        Method='GET'
    })
    if Request and Request.Success then
        Debugp('Request Success', Path)
        return Request.Body
    else
        Debugp('Request Failed', Path, Request.StatusMessage, Request.StatusCode)
    end
end

local function Load()
    Debugp'Load'
    local DecodedGameScripts=HttpService:JSONDecode(readfile'Ulisse/UlisseScripts.json')
    if DecodedGameScripts then
        local UIFile=isfile'Ulisse/UI.lua'
        if UIFile then
            getgenv().UlisseUI=loadstring(readfile'Ulisse/UI.lua')()
            local CurrentGame=DecodedGameScripts[tostring(game.PlaceId)]
            if CurrentGame then
                for i,v in ipairs(CurrentGame) do
                    local ScrPath=string.format('Ulisse/Scripts/%s',v)
                    if isfile(ScrPath) then
                        loadstring(readfile(ScrPath))()
                        OutputToConsole(string.format('Ran file: %s',ScrPath))
                    else
                        OutputToConsole(string.format('File missing: %s',ScrPath))
                    end
                end
            else
                OutputToConsole'No scripts for game found'
            end
        else
            OutputToConsole'UI file missing..?'
        end
    else
        OutputToConsole'Failed to run, try again..?'
    end
end

local function Update()
    OutputToConsole('New version detected/Files not found, Updating!')
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
    local ManifestFile=DownloadString(string.format('%s/Scripts.json',RepoPath))
    if ManifestFile then
        writefile('Ulisse/UlisseScripts.json', ManifestFile)
        local DecodedGameScripts=HttpService:JSONDecode(readfile'Ulisse/UlisseScripts.json')
        if DecodedGameScripts then
            for i,v in pairs(DecodedGameScripts) do
                for Idx,Val in ipairs(v) do
                    Debugp(Val)
                    local Script=DownloadString(string.format('%s/Scripts/%s',RepoPath,Val))
                    if Script then
                        local Path=string.format('Ulisse/Scripts/%s',Val)
                        writefile(string.format('Ulisse/Scripts/%s',Val), Script)
                    end
                end
            end
        end
    end
    OutputToConsole('Done, Loading now.')
    Load()
end

local function Start()
    if UlisseFolderExists then
        local CurrentVersionFileExists=isfile'Ulisse/Ulisse.VERSION'
        if CurrentVersionFileExists then
            local CurrentVersion=readfile'Ulisse/Ulisse.VERSION'
            local ServerVersion=DownloadString(string.format('%s/%s',RepoPath,VersionFileName))
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