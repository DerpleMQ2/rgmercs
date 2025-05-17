local mq              = require('mq')

local ImagesUI        = { _version = '1.0', _name = "ImagesUI", _author = 'Derple', }
ImagesUI.__index      = ImagesUI
-- Icon Rendering
ImagesUI.derpImg      = nil
ImagesUI.burnImg      = nil
ImagesUI.grimImg      = nil
ImagesUI.imgDisplayed = nil

function ImagesUI:InitLoader()
    self.derpImg = self.derpImg or mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/derpdog_60.png")
    self.burnImg = self.burnImg or mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/algar2_60.png")
    self.grimImg = self.grimImg or mq.CreateTexture(mq.TLO.Lua.Dir() .. "/rgmercs/extras/grim_60.png")

    if not self.imgDisplayed then
        math.randomseed(os.time())
        local images = { self.erpImg, self.burnImg, self.grimImg, }

        self.imgDisplayed = images[math.floor(math.random(1000, ((#images + 1) * 1000) - 1) / 1000)]
    end
end

return ImagesUI
