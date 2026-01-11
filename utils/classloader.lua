local mq          = require('mq')
local Core        = require("utils.core")
local Config      = require('utils.config')
local Globals     = require('utils.globals')
local Modules     = require("utils.modules")
local Files       = require("utils.files")
local Logger      = require("utils.logger")

local ClassLoader = { _version = '0.1', _name = "ClassLoader", _author = 'Derple', }

function ClassLoader.getClassConfigFileName(class)
    local baseConfigDir = Globals.ScriptDir .. "/class_configs"
    local classConfigDir = Config:GetSetting('ClassConfigDir') -- now defaults to current server
    local useCustomConfig = (classConfigDir:find("Custom: ") ~= nil)

    -- temp fix to patch incorrect initial config dir settings due to a previous bug
    if Core.OnEMU() and not useCustomConfig then
        local defaultConfig
        for _, server in ipairs(Globals.ClassConfigDirs) do
            if server == classConfigDir then
                defaultConfig = true
                break
            end
        end
        if not defaultConfig then
            Config:SetSetting('ClassConfigDir', "Live")
            Config:SaveSettings()
            classConfigDir = "Live"
        end
    end

    local configFile = string.format("%s/%s/%s_class_config.lua", baseConfigDir, classConfigDir, class:lower())

    if useCustomConfig then
        classConfigDir = classConfigDir:sub(9) -- remove "Custom:"
        configFile = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", mq.configDir, classConfigDir, class:lower())
    end

    if not Files.file_exists(configFile) then
        -- Fall back to the appropriate config.
        local oldConfig = configFile
        useCustomConfig = false
        local folder = ClassLoader.getFallbackClassConfigFolder()
        configFile = string.format("%s/%s/%s_class_config.lua", baseConfigDir, folder, class:lower())
    end

    return configFile, useCustomConfig
end

function ClassLoader.getFallbackClassConfigFolder()
    if Core.OnEMU() then
        if Config.Constants.SupportedEmuServers:contains(Globals.CurServer) then
            return Globals.CurServer
        end
    end
    return "Live"
end

---@param class string # EQ Class ShortName
function ClassLoader.load(class)
    local classConfigFile, customConfig = ClassLoader.getClassConfigFileName(class)
    Logger.log_debug("Loading Base Config:\n\ag%s", classConfigFile)

    if Files.file_exists(classConfigFile) then
        local config, err = loadfile(classConfigFile)
        if not config or err then
            Logger.log_error("Failed to load custom class config:\n\ay%s", classConfigFile)
        else
            local classConfig
            classConfig = config()
            classConfig.IsCustom = customConfig
            return classConfig
        end
    end

    return {}
end

function ClassLoader.writeCustomConfig(class)
    -- Define file paths
    local currentConfigPath = mq.luaDir
    local currentConfigDir = Config:GetSetting('ClassConfigDir')
    if currentConfigDir:find("Custom: ") ~= nil then
        currentConfigPath = mq.configDir
        currentConfigDir = currentConfigDir:sub(9)
    end
    local current_File = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", currentConfigPath, currentConfigDir, class:lower())
    local configType = Globals.BuildType:lower() ~= "emu" and "Live" or Globals.CurServer
    local customFile = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", mq.configDir, configType, class:lower())
    local backupFile = string.format("%s/rgmercs/class_configs/%s/%s_class_config_%s.lua", mq.configDir, configType, class:lower(), os.date("%Y%m%d_%H%M%S"))

    -- Backup the custom config file if one exists
    local fileCustom = io.open(customFile, "r")
    if fileCustom ~= nil then
        mq.pickle(backupFile, {}) -- build the path so we don't get an error
        local content = fileCustom:read("*all")
        fileCustom:close()

        local fileBackup, err = io.open(backupFile, "w")
        if not fileBackup then
            Logger.log_error("Failed to Backup Custom Core Class Config: %s %s", backupFile, err)
            return
        end

        fileBackup:write(content)
        fileBackup:close()
        Logger.log_info("Custom Class Config Backup Created: %s", backupFile)
    end

    if not Files.file_exists(customFile) then
        mq.pickle(customFile, {}) -- build the path so we don't get an error
    end

    -- Load the current config file content
    local file = io.open(current_File, "r")
    if not file then
        Logger.log_error("Failed to Load Base Class Config: %s", current_File)
        return
    end

    local content = file:read("*all")
    file:close()

    -- Write the updated content to the custom config file
    mq.pickle(customFile, {}) -- incase the path isn't made yet
    local custom_file, err = io.open(customFile, "w")
    if not custom_file then
        Logger.log_error("Failed to Write Custom Class Config: %s", customFile)
        return
    end

    custom_file:write(content)
    custom_file:close()

    Logger.log_info("Custom Class Config Written: %s", customFile)
end

function ClassLoader.mergeTables(tblA, tblB)
    for k, v in pairs(tblB) do
        if type(v) == "table" then
            if type(tblA[k] or false) == "table" then
                ClassLoader.mergeTables(tblA[k] or {}, tblB[k] or {})
            else
                tblA[k] = v
            end
        else
            tblA[k] = v
        end
    end
    return tblA
end

function ClassLoader.changeLoadedClass()
    Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    Logger.log_info("\ayPersona class swap detected! \awLoading settings for \ag%s.", mq.TLO.Me.Class())
    ClassLoader.reloadConfig()
end

function ClassLoader.reloadConfig()
    Config:ClearAllModuleSettings()
    Config:LoadSettings()
    Core.ScanConfigDirs()
    Modules:ExecAll("LoadSettings")
    Config:UpdateCommandHandlers()
end

return ClassLoader
