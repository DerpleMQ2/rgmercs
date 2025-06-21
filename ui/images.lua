local mq              = require('mq')

local ImagesUI        = { _version = '1.0', _name = "ImagesUI", _author = 'Derple', }
ImagesUI.__index      = ImagesUI
-- Icon Rendering
ImagesUI.derpImg      = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_60.png")
ImagesUI.burnImg      = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/algar2_60.png")
ImagesUI.grimImg      = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/grim_60.png")
ImagesUI.imgDisplayed = ImagesUI.derpImg

function ImagesUI:InitLoader()
    math.randomseed(os.time())
    local images = { self.derpImg, self.burnImg, self.grimImg, }
    self.imgDisplayed = images[math.floor(math.random(1000, ((#images + 1) * 1000) - 1) / 1000)]
end

return ImagesUI
