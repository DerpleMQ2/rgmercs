local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

local ClassLoader = { _version = '0.1', _name = "ClassLoader", _author = 'Derple', }

function ClassLoader.getClassConfigFileName(class)
    local info = debug.getinfo(6, "S")
    local baseConfigDir = RGMercConfig.Globals.ScriptDir .. "/class_configs"

    local customConfigFile = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir, class:lower())

    local classConfigDir = RGMercUtils.GetSetting('ClassConfigDir')
    local customConfig = (classConfigDir == "Custom")

    local configFile = customConfig and customConfigFile or string.format("%s/%s/%s_class_config.lua", baseConfigDir, classConfigDir, class:lower())

    if not RGMercUtils.file_exists(configFile) then
        -- Fall back to live.
        local oldConfig = configFile
        customConfig = false
        configFile = string.format("%s/%s/%s_class_config.lua", baseConfigDir, "Live", class:lower())
        RGMercsLogger.log_error("Could not find requested class config %s falling back to %s", oldConfig, configFile)
    end

    return configFile, customConfig
end

---@param class string # EQ Class ShortName
function ClassLoader.load(class)
    local classConfigFile, customConfig = ClassLoader.getClassConfigFileName(class)
    RGMercsLogger.log_info("Loading Base Config: %s", classConfigFile)

    if RGMercUtils.file_exists(classConfigFile) then
        local config, err = loadfile(classConfigFile)
        if not config or err then
            RGMercsLogger.log_error("Failed to Load Custom Core Class Config: %s", classConfigFile)
        else
            local classConfig
            RGMercsLogger.log_info("\agFull Config Loaded")
            classConfig = config()
            classConfig.IsCustom = customConfig
            return classConfig
        end
    end

    return {}
end

function ClassLoader.writeCustomConfig(class)
    -- Define file paths
    local base_config_file = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.luaDir, class:lower())
    local custom_config_file = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir, class:lower())
    local backup_config_file = string.format("%s/rgmercs/class_configs/BACKUP/%s_class_config_%s.lua", mq.configDir, class:lower(), os.date("%Y%m%d_%H%M%S"))

    -- Backup the custom config file if one exists
    local fileCustom = io.open(custom_config_file, "r")
    if fileCustom then
        mq.pickle(backup_config_file, {}) -- build the path so we don't get an error
        local content = fileCustom:read("*all")
        fileCustom:close()

        local fileBackup, err = io.open(backup_config_file, "w")
        if not fileBackup then
            RGMercsLogger.log_error("Failed to Backup Custom Core Class Config: %s %s", backup_config_file, err)
            return
        end

        fileBackup:write(content)
        fileBackup:close()
    end

    -- Load the default config file content
    local file = io.open(base_config_file, "r")
    if not file then
        RGMercsLogger.log_error("Failed to Load Base Class Config: %s", base_config_file)
        return
    end

    local content = file:read("*all")
    file:close()

    -- Find the location of the _author line and insert FullConfig
    local updated_content = content:gsub("(_author%s*=%s*[%S%s]-\n)", "%1    FullConfig = true,\n")

    -- Write the updated content to the custom config file
    mq.pickle(custom_config_file, {}) -- incase the path isn't made yet
    local custom_file, err = io.open(custom_config_file, "w")
    if not custom_file then
        RGMercsLogger.log_error("Failed to Write Custom Core Class Config: %s Error:", custom_config_file)
        return
    end

    custom_file:write(updated_content)
    custom_file:close()

    RGMercsLogger.log_info("Custom Core Class Config Written: %s", custom_config_file)
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

return ClassLoader
