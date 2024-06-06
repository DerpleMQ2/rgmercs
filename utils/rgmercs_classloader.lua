local mq          = require('mq')
local RGMercUtils = require("utils.rgmercs_utils")

local ClassLoader = { _version = '0.1', _name = "ClassLoader", _author = 'Derple', }

---@param class string # EQ Class ShortName
function ClassLoader.load(class)
    local baseClassConfig = require(string.format("class_configs.%s_class_config", class:lower()))
    local overrideClassConfig = {}
    local customConfigLoaded = false

    -- check for overrides
    local custom_config_file = string.format("%s/rgmercs/class_configs/%s_class_config.lua", mq.configDir, class:lower())

    if RGMercUtils.file_exists(custom_config_file) then
        RGMercsLogger.log_info("Loading Custom Core Class Config: %s", custom_config_file)
        local config, err = loadfile(custom_config_file)
        if not config or err then
            RGMercsLogger.log_error("Failed to Load Custom Core Class Config: %s", custom_config_file)
        else
            overrideClassConfig = config()
            customConfigLoaded = true
        end
    end

    local classConfig = ClassLoader.mergeTables(baseClassConfig, overrideClassConfig)
    classConfig.IsCustom = customConfigLoaded
    return classConfig
end

function ClassLoader.mergeTables(tblA, tblB)
    for k, v in pairs(tblB) do
        if v == nil then
            -- Remove key from tblA if value in tblB is nil
            tblA[k] = nil
        elseif type(v) == "table" then
            if type(tblA[k]) == "table" then
                if #v > 0 or next(v) == nil then
                    -- Directly assign the list from tblB to tblA
                    tblA[k] = v
                else
                    -- Recursive call to merge nested tables
                    tblA[k] = ClassLoader.mergeTables(tblA[k], v)
                end
            else
                -- If tblA[k] is not a table, directly assign tblB[k]
                tblA[k] = v
            end
        else
            -- Directly assign the value if it's not a table
            tblA[k] = v
        end
    end
    return tblA
end



return ClassLoader
