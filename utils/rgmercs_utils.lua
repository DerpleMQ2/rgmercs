local Utils      = { _version = '0.1a', author = 'Derple' }
Utils.__index    = Utils
Utils.Actors     = require('actors')
Utils.ScriptName = "RGMercs"

function Utils.BroadcastUpdate(module, event)
    Utils.Actors.send({ from = RGMercConfig.CurLoadedChar, script = Utils.ScriptName, module = module, event = event })
end

return Utils
