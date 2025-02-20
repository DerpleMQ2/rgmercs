local mq          = require('mq')
local Core        = require("utils.core")
local Config      = require('utils.config')
local Modules     = require("utils.modules")
local Files       = require("utils.files")
local Logger      = require("utils.logger")

local ClassLoader = { _version = '0.1', _name = "ClassLoader", _author = 'Derple', }

function ClassLoader.getClassConfigFileName(class)
    local baseConfigDir = Config.Globals.ScriptDir .. "/class_configs"

    local customConfigFile = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", mq.configDir, Config.Globals.BuildType, class:lower())

    local classConfigDir = Config:GetSetting('ClassConfigDir')
    local customConfig = (classConfigDir == "Custom")

    local configFile = customConfig and customConfigFile or string.format("%s/%s/%s_class_config.lua", baseConfigDir, classConfigDir, class:lower())

    if not Files.file_exists(configFile) then
        -- Fall back to the appropriate config.
        local oldConfig = configFile
        customConfig = false
        local folder = Core.OnLaz() and "Project Lazarus" or "Live"
        configFile = string.format("%s/%s/%s_class_config.lua", baseConfigDir, folder, class:lower())
        Logger.log_error("Could not find requested class config:\n \ay(%s)\n\awFalling back to:\n\ag%s", oldConfig, configFile)
    end

    return configFile, customConfig
end

---@param class string # EQ Class ShortName
function ClassLoader.load(class)
    local classConfigFile, customConfig = ClassLoader.getClassConfigFileName(class)
    Logger.log_info("Loading Base Config:\n\ag%s", classConfigFile)

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
    local base_config_file = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", mq.luaDir, Config:GetSetting('ClassConfigDir'), class:lower())
    local custom_config_old = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir, class:lower())
    local custom_config_file = string.format("%s/rgmercs/class_configs/%s/%s_class_config.lua", mq.configDir, Config.Globals.BuildType, class:lower())
    local backup_config_file = string.format("%s/rgmercs/class_configs/BACKUP/%s/%s_class_config_%s.lua", mq.configDir, Config.Globals.BuildType, class:lower(),
        os.date("%Y%m%d_%H%M%S"))

    if not Files.file_exists(custom_config_file) then
        if not Files.file_exists(custom_config_old) then
            mq.pickle(custom_config_file, {}) -- build the path so we don't get an error
        end
    end
    -- Backup the custom config file if one exists
    local fileCustom = io.open(custom_config_file, "r")
    if fileCustom then
        mq.pickle(backup_config_file, {}) -- build the path so we don't get an error
        local content = fileCustom:read("*all")
        fileCustom:close()

        local fileBackup, err = io.open(backup_config_file, "w")
        if not fileBackup then
            Logger.log_error("Failed to Backup Custom Core Class Config: %s %s", backup_config_file, err)
            return
        end

        fileBackup:write(content)
        fileBackup:close()
    end

    -- Load the default config file content
    local file = io.open(base_config_file, "r")
    if not file then
        Logger.log_error("Failed to Load Base Class Config: %s", base_config_file)
        return
    end

    local content = file:read("*all")
    file:close()

    -- Write the updated content to the custom config file
    mq.pickle(custom_config_file, {}) -- incase the path isn't made yet
    local custom_file, err = io.open(custom_config_file, "w")
    if not custom_file then
        Logger.log_error("Failed to Write Custom Core Class Config: %s Error:", custom_config_file)
        return
    end

    custom_file:write(content)
    custom_file:close()

    Logger.log_info("Custom Core Class Config Written: %s", custom_config_file)
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
    Config.Globals.CurLoadedClass = mq.TLO.Me.Class.ShortName()
    Logger.log_info("\ayPersona class swap detected! \awLoading settings for \ag%s.", mq.TLO.Me.Class())
    Config:LoadSettings()
    Core.ScanConfigDirs()
    Modules:ExecAll("Init")
    Config:UpdateCommandHandlers()
end

return ClassLoader
