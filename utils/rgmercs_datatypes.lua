local mq = require 'mq'

---@class RGMercsType
---@field name string

---@type DataType
local rgMercsType = mq.DataType.new('RGMercs', {
    Members = {
        --- Data Member: Name retrieves the counter's name.
        Name = function(_)
            local ret = "RGMercs Modules Loaded: "
            for _, m in pairs(RGMercModules:getModuleOrderedNames()) do
                ret = ret .. m
                ret = ret .. ", "
            end
            return 'string', ret
        end,
    },

    Methods = {
    },

    ToString = function()
        return string.format("RGMercs [%s/%s] by: %s running for %s (%s)", RGMercConfig._version, RGMercConfig._subVersion, RGMercConfig._author,
            RGMercConfig.Globals.CurLoadedChar,
            RGMercConfig.Globals.CurLoadedClass)
    end,
})

---@type { [string]: RGMercsType }
local rgMercsTLO = {}

---@return MQType
---@return RGMercsType
local function RGMercsTLOHandler(param)
    return rgMercsType, rgMercsTLO
end
-- Register our TLO functions
mq.AddTopLevelObject('RGMercs', RGMercsTLOHandler)
