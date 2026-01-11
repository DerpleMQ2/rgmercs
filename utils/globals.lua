local mq                    = require("mq")
local Set                   = require("mq.set")

-- very simple table to hold our globals that includes nothing.

local Globals               = {}
Globals.__index             = Globals

Globals.MainAssist          = ""
Globals.ScriptDir           = ""
Globals.AutoTargetID        = 0
Globals.ForceTargetID       = 0
Globals.ForceCombatID       = 0
Globals.LastPulledID        = 0
Globals.CurrentState        = "None"
Globals.IgnoredTargetIDs    = Set.new({})
Globals.SubmodulesLoaded    = false
Globals.PauseMain           = false
Globals.LastMove            = nil
Globals.BackOffFlag         = false
Globals.InMedState          = false
Globals.LastPetCmd          = 0
Globals.LastFaceTime        = 0
Globals.CurZoneId           = mq.TLO.Zone.ID()
Globals.CurInstance         = mq.TLO.Me.Instance()
Globals.CurLoadedChar       = mq.TLO.Me.DisplayName()
Globals.CurLoadedClass      = mq.TLO.Me.Class.ShortName()
Globals.CurServer           = mq.TLO.EverQuest.Server()
Globals.CurServerNormalized = mq.TLO.EverQuest.Server():gsub(" ", "")
Globals.CastResult          = 0
Globals.BuildType           = mq.TLO.MacroQuest.BuildName()
Globals.Minimized           = false
Globals.LastUsedSpell       = "None"
Globals.CorpseConned        = false
Globals.RezzedCorpses       = {}
Globals.SLPeerLooting       = false

return Globals
