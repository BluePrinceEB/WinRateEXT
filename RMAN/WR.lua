
    --[[
        WR.lua
        Weedle
    --]]

    if _G.WR_Loaded then
        return 
    end

    _G.WR_Loaded = true

    local core_version       = "0.9.9"
    local version            = "0.9.9"
    local isUpdated          = false
    local timeCheck          = false

    local script_data        = nil 
    local module_data        = nil

    local isSupported        = false 
    local char_name          = myHero.charName 

    local update_progress    = 0 
    local script_path        = SCRIPT_PATH
    local common_path        = COMMON_PATH  
    local open               = io.open   
    local seed               = math.randomseed(os.time())
    local concat             = table.concat

    local wr_script_data     = "wr_script_data.lua"
    local wr_module_data     = "wr_module_data.lua"
    local wr_core            = "wr_core.lua"
    local wr_check           = "wr_check.lua"    
    local wr_champ           = "wr_"..char_name..".lua"
    local wr_script_data_url = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/winrate_script_data.lua"
    local wr_module_data_url = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/winrate_module_data.lua"
    local wr_core_url        = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/winrate_core.lua"
    local wr_champ_url       = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Modules/winrate_"..char_name:lower()..".lua"
    local wr_icon_url        = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Logo/wr_logo_"..tostring(math.random(1,7))..".png"
    
    
    --WR--

    local function CreateUpdateTime()
        local newFile = open(common_path..wr_check, "w+")
        newFile:write(os.time())
        newFile:close()
    end

    local function CheckUpdateTime()
        local file = nil
        if not FileExist(common_path..wr_check) then 
            CreateUpdateTime()
            return true
        end
        local file = open(common_path..wr_check, "r")
        local current_time = os.time()
        local check_time = file:read()
        file:close()
        CreateUpdateTime()
        return current_time - check_time >= 300
    end

    local function DownloadFile(from, to, msg)
        DownloadFileAsync(from, to, function() end)
        update_progress = update_progress + 1
        print("Updating: "..update_progress.." | "..msg)
        repeat until FileExist(to)
    end   

    local function GetVersion()
        if not FileExist(common_path..wr_script_data) then 
            return 
        end
        dofile(common_path..wr_script_data)
        script_data  = _G.WR_SCRIPT_DATA
        core_version = script_data.core_version
        version = script_data.version
    end      

    local function GetScriptData()
        local check_version = core_version
        DownloadFile(wr_script_data_url, common_path..wr_script_data, wr_script_data)
        GetVersion()
        if check_version ~= core_version then
            DownloadFile(wr_core_url, common_path..wr_core, wr_core.." | version: "..core_version) 
            isUpdated = true
        end
    end   

    local function GetModuleData()
        DownloadFile(wr_module_data_url, common_path..wr_module_data, wr_module_data)
        dofile(common_path..wr_module_data)
        module_data  = _G.WR_MODULE_DATA 
    end     

    local function UpdateModules()
        for i, utils in pairs(module_data.utilities) do 
            local wr_utility = "wr_"..utils..".lua"
            local wr_utility_url = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Modules/winrate_"..utils..".lua"
            DownloadFile(wr_utility_url, common_path..wr_utility, wr_utility)
        end 
        if module_data.champions[char_name] == nil then return end
        DownloadFile(wr_champ_url, common_path..wr_champ, wr_champ)
        isSupported = true 
    end     

    local function AutoUpdate()
        GetVersion()
        if CheckUpdateTime() then
            timeCheck = true
            GetScriptData()
            GetModuleData()
            UpdateModules()
        end
    end

    local function readAll(file)
        local f = assert(open(file, "r"))
        local content = f:read("*all")
        f:close()
        return content
    end

    local function clearModule()
        local f = assert(open(COMMON_PATH.."\\WinRate\\activeModule.lua", "w"))
        f:write()
        f:close()        
    end

    local function appendModule(content)
        local f = assert(open(COMMON_PATH.."\\WinRate\\activeModule.lua", "a"))
        local content = f:write(content)
        f:close()        
    end

    local function LoadWR()
        local path, ending = COMMON_PATH.."\\WinRate\\", ".lua"
        local dependencies = {"menuLoad", "commonLib", "callbacks", "prediction", "\\Champion Modules\\WR_"..char_name} 
        clearModule()
        for i=1, #dependencies do
            local dependency = readAll(concat({path, dependencies[i], ending}))
            appendModule(dependency)    
        end                          
        dofile(path.."activeModule"..ending) 
    end

    --WR--

    function OnLoad()
        --AutoUpdate()
        --_G.script_data = script_data
        --_G.isSupported = isSupported
        --_G.isUpdated, _G.timeCheck = isUpdated, timeCheck       
        --require("wr_changelog")
        LoadWR()
    --  require("wr_core") 
    end    