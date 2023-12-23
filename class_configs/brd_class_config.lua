return {
    ['Modes'] = {
        ['MeleeGroup'] = 1,
        ['DotGroup'] = 1, -- Druid/Necro
        ['CasterGroup'] = 1,
        ['TLP'] = 1,
        ['BuffAndCCOnly'] = 1, -- Buff and CC only - No melee or dmg
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Innoruuk's Dark Blessing",
            [2] = "Innoruuk's Voice",
        },
    },
    ['AbilitySets'] = {
        ['BardRunBuff'] = {},
        ['MainAriaSong'] = {},
        ['SufferingSong'] = {},
        ['SprySonataSong'] = {},
        ['CrescendoSong'] = {},
        ['ArcaneSong'] = {},
        ['InsultSong'] = {
            [] = ["Nord's Disdain"],
            [] = ["Sogran's Insult"],
            [] = ["Yelinak's Insult"],
            [] = ["Omorden's Insult"],
            [] = ["Sathir's Insult"],
            [] = ["Travenro's Insult"],
            [] = ["Tsaph's Insult"],
            [] = ["Fjilnauk's Insult"],
            [] = ["Kaficus' Insult"],
            [] = ["Garath's Insult"],
            [] = ["Hykast's Insult"],
            [] = ["Venimor's Insult"],
            -- Below Level 85 This line turns into "bellow" instead of "Insult"
            [] = ["Bellow of Chaos"],
            [] = ["Brusco's Bombastic Bellow"],
            [] = ["Brusco's Boastful Bellow"],
        },
        ['InsultSong1'] = {},
        ['InsultSong2'] = {},
        ['DichoSong'] = {},
        ['BardDPSAura'] = {},
        ['BardRegenAura'] = {},
        ['PulseRegenSong'] = {},
        ['ChorusRegenSong'] = {},
        ['WarMarchSong'] = {},
        ['CasterAriaSong'] = {},
        ['SlowSong'] = {},
        ['AESlowSong'] = {},
        ['AccelerandoSong'] = {},
        ['SpitefulSong'] = {},
        ['RecklessSong'] = {},
        ['SelfRune1'] = {},
        ['StripBuffSpell'] = {},
        ['FateSong'] = {},
        ['PsalmSong'] = {},
        ['DotSong'] = {},
        ['CureSpell'] = {},
        ['AllianceSong'] = {},
        ['CharmSong'] = {},
        ['ReflexStrike'] = {},
        ['ChordsAE'] = {},
        ['LowAriaSong'] = {},
        ['AmpSong'] = {},
        ['DispelSong'] = {},
        ['ResistSong'] = {},       
        ['MezSpell'] = {},
        ['MezAESpell'] = {},

    



      

        -- Bard PBAE - Used Only for Level 2 Pull Spell.
        [] = ["Chords of Dissonance"] ChordsAE
    
        -- Bard RunSpeed 
        [] = ["Selo's Accelerato"] BardRunBuff

        -- Song of travel has been removed due to causing Bugs with Invis and rotation.
        --        ["Selo's Song of Travel" BardRunBuff
        [] = ["Selo's Accelerating Chorus"] BardRunBuff
        [] = ["Selo's Accelerando"] BardRunBuff
    
        -- Bard ReflexStrike - Restores mana to group
        [] = ["Reflexive Retort"] ReflexStrike
        [] = ["Reflexive Rejoinder"] ReflexStrike
        [] = ["Reflexive Rebuttal"] ReflexStrike
    
        -- BardDPSAura - Level Ranges 55 - 115
        [] = ["Aura of Pli Xin Liako"]   "Aura of Pli Xin Liako" BardDPSAura
        [] = ["Aura of Margidor"]        "Aura of Margidor"      BardDPSAura   
        [] = ["Aura of Begalru"]         "Aura of Begalru"       BardDPSAura
        [] = ["Aura of Maetanrus"]       "Aura of Maetanrus"     BardDPSAura 
        [] = ["Aura of Va'Ker"]          "Aura of Va'Ker"        BardDPSAura
        [] = ["Aura of the Orator"]      "Aura of the Orator"    BardDPSAura
        [] = ["Aura of the Composer"]    "Aura of the Composer"  BardDPSAura
        [] = ["Aura of the Poet"]        "Aura of the Poet"      BardDPSAura    
        [] = ["Aura of the Artist"]      "Aura of the Artist"    BardDPSAura
        [] = ["Aura of the Muse"]        "Aura of the Muse"      BardDPSAura
        [] = ["Aura of Insight"]         "Aura of Insight"       BardDPSAura     
    
        /varset BardDPSAura_name ${GetAuraName[${BardDPSAura},BardDPSAura]}
    
        -- Amplify Song
        [] = ["Amplification"] AmpSong 
    
        -- BardRegenAura - Level Ranges 82 - 112
        [] = ["Aura of Shei Vinitras"] "Aura of Shei Vinitras" BardRegenAura
        [] = ["Aura of Vhal`Sera"]   "Aura of Vhal`Sera"   BardRegenAura
        [] = ["Aura of Xigam"]       "Aura of Xigam"       BardRegenAura
        [] = ["Aura of Sionachie"]   "Aura of Sionachie"   BardRegenAura
        [] = ["Aura of Salarra"]     "Aura of Salarra"     BardRegenAura    
        [] = ["Aura of Lunanyn"]     "Aura of Lunanyn"     BardRegenAura
        [] = ["Aura of Renewal"]     "Aura of Renewal"     BardRegenAura
        [] = ["Aura of Rodcet"]      "Aura of Rodcet"      BardRegenAura     

        -- Bard Alliance
        ["Conjunction of Sticks and Stones"] AllianceSong
        ["Alliance of Sticks and Stones"] AllianceSong
        ["Covenant of Sticks and Stones"] AllianceSong
        ["Coalition of Sticks and Stones"] AllianceSong
    
        -- Bard Charm Song
        ["Omiyad's Demand"] CharmSong
        ["Voice of the Diabo"] CharmSong
        ["Silisia's Demand"] CharmSong
        ["Dawnbreeze's Demand"] CharmSong
        ["Desirae's Demand"] CharmSong
    
        -- Low Level Aria Song - before Combination of Effects Under Level 68
        ["Battlecry of the Vah Shir"] LowAriaSong
        ["Warsong of the Vah Shir"] LowAriaSong
    
    
        -- Resists Song
        ["Psalm of Cooling"] ResistSong
        ["Psalm of Purity"] ResistSong
        ["Psalm of Warmth"] ResistSong
        ["Psalm of Vitality"] ResistSong
        ["Psalm of Veeshan"] ResistSong
        ["Psalm of the Forsaken"] ResistSong
        ["Second Psalm of Veeshan"] ResistSong
        ["Psalm of the Restless"] ResistSong
        ["Psalm of the Pious"] ResistSong
    
        -- MainAriaSong - Level Ranges 45 - 111
        -- What differs between PsalmSong and MainAriaSong ???
        ["Aria of Pli Xin Liako"] MainAriaSong
        ["Aria of Margidor"] MainAriaSong 
        ["Aria of Begalru"] MainAriaSong
        ["Aria of Maetanrus"] MainAriaSong
        ["Aria of Va'Ker"] MainAriaSong
        ["Aria of the Orator"] MainAriaSong    
        ["Aria of the Composer"] MainAriaSong
        ["Aria of the Poet"] MainAriaSong
        ["Ancient: Call of Power"] MainAriaSong     
        ["Aria of the Artist"] MainAriaSong   
        ["Yelhun's Mystic Call"] MainAriaSong 
        ["Ancient: Call of Power"] MainAriaSong
        ["Rizlona's Call of Flame"] MainAriaSong
        ["Rizlona's Fire"] MainAriaSong  
        ["Rizlona's Embers"] MainAriaSong  
    
        -- CasterAriaSong - Level Range 72 - 113
        ["Constance's Aria"] CasterAriaSong
        ["Sontalak's Aria"] CasterAriaSong 
        ["Qunard's Aria"] CasterAriaSong 
        ["Nilsara's Aria"] CasterAriaSong
        ["Gosik's Aria"] CasterAriaSong
        ["Daevan's Aria"] CasterAriaSong
        ["Sotor's Aria"] CasterAriaSong    
        ["Talendor's Aria"] CasterAriaSong
        ["Performer's Explosive Aria"] CasterAriaSong
        ["Weshlu's Chillsong Aria"] CasterAriaSong     

    
        -- WarMarchSong Level Range 10 - 114
        ["War March of Centien Xi Va Xakra"] WarMarchSong
        ["War March of Radiwol"] WarMarchSong 
        ["War March of Dekloaz"] WarMarchSong 
        ["War March of Jocelyn"] WarMarchSong
        ["War March of Protan"] WarMarchSong
        ["War March of Illdaera"] WarMarchSong
        ["War March of Dagda"] WarMarchSong    
        ["War March of Brekt"] WarMarchSong
        ["War March of Meldrath"] WarMarchSong
        ["War March of Muram"] WarMarchSong  
        ["War March of the Mastruq"] WarMarchSong
        ["Warsong of Zek"] WarMarchSong
        ["McVaxius' Rousing Rondo"] WarMarchSong
        ["Vilia's Chorus of Celerity"] WarMarchSong    
        ["Verses of Victory"] WarMarchSong
        ["McVaxius' Berserker Crescendo"] WarMarchSong
        ["Vilia's Verses of Celerity"] WarMarchSong  
        ["Anthem de Arms"] WarMarchSong    
      
        -- SufferingSong - Level Range 89 - 114
        ["Shojralen's Song of Suffering"] SufferingSong
        ["Omorden's Song of Suffering"] SufferingSong 
        ["Travenro's Song of Suffering"] SufferingSong 
        ["Fjilnauk's Song of Suffering"] SufferingSong
        ["Kaficus' Song of Suffering"] SufferingSong
        ["Hykast's Song of Suffering"] SufferingSong
        ["Noira's Song of Suffering"] SufferingSong    
    
        -- ArcaneSong - Level Range 70 - 115
        ["Arcane Harmony"] ArcaneSong
        ["Arcane Symphony"] ArcaneSong  
        ["Arcane Ballad"] ArcaneSong
        ["Arcane Melody"] ArcaneSong
        ["Arcane Hymn"] ArcaneSong
        ["Arcane Address"] ArcaneSong    
        ["Arcane Chorus"] ArcaneSong
        ["Arcane Arietta"] ArcaneSong
        ["Arcane Anthem"] ArcaneSong  
        ["Arcane Aria"] ArcaneSong    
    
    
        -- SprySonataSong - Level Range 77 - 118
        ["Xetheg's Spry Sonata"] SprySonataSong
        ["Kellek's Spry Sonata"] SprySonataSong
        ["Kluzen's Spry Sonata"] SprySonataSong    
        ["Doben's Spry Sonata"] SprySonataSong
        ["Terasal's Spry Sonata"] SprySonataSong
        ["Sionachie's Spry Sonata"] SprySonataSong  
        ["Coldcrow's Spry Sonata"] SprySonataSong  
    
        -- Adding misc songs below level 77 to fill in first spell gem  
        --   ['Psalm of Veeshan"] SprySonataSong    
        --   ["Nillipus' March of the Wee"] SprySonataSong
        --   ["Verses of Victory"] SprySonataSong
        --   ["Psalm of Mystic Shielding"] SprySonataSong  
        --   ["Psalm of Cooling"] SprySonataSong  
        --   ["Psalm of Vitality"] SprySonataSong 
        --    ["Psalm of Warmth"] SprySonataSong
        --    ["Guardian Rhythms"] SprySonataSong    
        --    ["Purifying Rhythms"] SprySonataSong
        --    ["Elemental Rhythms"] SprySonataSong  
        --    ["Jonthan's Whistling Warsong"] SprySonataSong  
        --    ["Chant of Battle"] SprySonataSong    
        --
        
    -- PulseRegenSong - Level Range 77 - 111 ** -- Low level regens are for TLP users thus preferring mana over health.
            ["Pulse of Nikolas"] PulseRegenSong
            ["Pulse of Vhal`Sera"] PulseRegenSong
            ["Pulse of Xigam"] PulseRegenSong
            ["Pulse of Sionachie"] PulseRegenSong
            ["Pulse of Salarra"] PulseRegenSong    
            ["Pulse of Lunanyn"] PulseRegenSong
            ["Pulse of Renewal"] PulseRegenSong
            ["Pulse of Rodcet"] PulseRegenSong  
            ["Cassindra's Chorus of Clarity"] PulseRegenSong
            ["Cassindra's Chant of Clarity"] PulseRegenSong
            ["Rhythm of Restoration"] PulseRegenSong    
    
    
    -- ChorusRegenSong - Level Range 6 - 113
            ["Chorus of Shei Vinitras"] ChorusRegenSong
            ["Chorus of Vhal`Sera"] ChorusRegenSong
            ["Chorus of Xigam"] ChorusRegenSong  
            ["Chorus of Sionachie"] ChorusRegenSong 
            ["Chorus of Salarra"] ChorusRegenSong
            ["Chorus of Lunanyn"] ChorusRegenSong
            ["Chorus of Renewal"] ChorusRegenSong
            ["Chorus of Rodcet"] ChorusRegenSong    
            ["Cantata of Rodcet"] ChorusRegenSong
            ["Chorus of Restoration"] ChorusRegenSong
            ["Cantata of Restoration"] ChorusRegenSong  
            ["Erollisi's Cantata"] ChorusRegenSong    
            ["Chorus of Life"] ChorusRegenSong
            ["Cantata of Life"] ChorusRegenSong
            ["Chorus of Marr"] ChorusRegenSong
            ["Wind of Marr"] ChorusRegenSong    
            ["Chorus of Replenishment"] ChorusRegenSong
            ["Cantata of Replenishment"] ChorusRegenSong
            ["Cantata of Soothing"] ChorusRegenSong  
            ["Hymn of Restoration"] ChorusRegenSong    
    
    
    -- Dispel Song - For pulling to avoid Summons
            ["Syvelian's Anti-Magic Aria"] DispelSong
            ["Druzzil's Disillusionment"] DispelSong
    
    
    -- CrescendoSong - Level Range 75 - 114
            ["Zelinstein's Lively Crescendo"] CrescendoSong
            ["Zburator's Lively Crescendo"] CrescendoSong  
            ["Jembel's Lively Crescendo"] CrescendoSong
            ["Silisia's Lively Crescendo"] CrescendoSong
            ["Motlak's Lively Crescendo"] CrescendoSong
            ["Kolain's Lively Crescendo"] CrescendoSong    
            ["Lyssa's Lively Crescendo"] CrescendoSong
            ["Gruber's Lively Crescendo"] CrescendoSong
            ["Kaerra's Spirited Crescendo"] CrescendoSong  
            ["Veshma's Lively Crescendo"] CrescendoSong    
    
    -- Seperated the Insult Songs Since they are on 2 different timers and the new one with them as one would Pick 2 Insult Timer 3 songs by Default.
    -- InsultSong1 - Level Range 12 - 112 Timer 3
    |**
            ["Nord's Disdain"] InsultSong
            ["Sogran's Insult"] InsultSong
            ["Yelinak's Insult"] InsultSong
            ["Omorden's Insult"] InsultSong 
            ["Sathir's Insult"] InsultSong
            ["Travenro's Insult"] InsultSong  
            ["Tsaph's Insult"] InsultSong
            ["Fjilnauk's Insult"] InsultSong
            ["Kaficus' Insult"] InsultSong
            ["Garath's Insult"] InsultSong
            ["Hykast's Insult"] InsultSong
            ["Venimor's Insult"] InsultSong 
        -- Below Level 85 This line turns into "bellow" instead of "Insult"
            ["Bellow of Chaos"] InsultSong
            ["Brusco's Bombastic Bellow"] InsultSong   
            ["Brusco's Boastful Bellow"] InsultSong
    **|
    
    -- DichoSong Level Range - 101 - 106
            ["Ecliptic Psalm"] DichoSong
            ["Composite Psalm"] DichoSong
            ["Dissident Psalm"] DichoSong    
            ["Dichotomic Psalm"] DichoSong
    
    
    -- MezSpell - Level Range 15 - 114
            ["Slumber of the Diabo"] MezSpell
        -- /call AbilitySet_Add "Lullaby of Nightfall" MezSpell
        -- /call AbilitySet_Add "Lullaby of Zburator" MezSpell
            ["Slumber of Zburator"] MezSpell
            ["Slumber of Jembel"] MezSpell  
        -- /call AbilitySet_Add "Lullaby of Jembel" MezSpell 
            ["Slumber of Silisia"] MezSpell
        -- /call AbilitySet_Add "Lullaby of Silisia" MezSpell
            ["Slumber of Motlak"] MezSpell
        -- /call AbilitySet_Add "Lullaby of the Forsaken" MezSpell    
            ["Slumber of Kolain"] MezSpell
        -- /call AbilitySet_Add "Lullaby of the Forlorn" MezSpell
            ["Slumber of Sionachie"] MezSpell  
        -- /call AbilitySet_Add "Lullaby of the Lost" MezSpell    
            ["Slumber of the Mindshear"] MezSpell
            ["Serenity of Oceangreen"] MezSpell
            ["Amber's Last Lullaby"] MezSpell
            ["Queen Eletyl's Screech"] MezSpell
            ["Command of Queen Veneneu"] MezSpell
            ["Aelfric's Last Lullaby"] MezSpell    
            ["Vulka's Lullaby"] MezSpell
            ["Creeping Dreams"] MezSpell
            ["Luvwen's Lullaby"] MezSpell  
            ["Lullaby of Morell"] MezSpell    
            ["Dreams of Terris"] MezSpell
            ["Dreams of Thule"] MezSpell  
            ["Dreams of Ayonae"] MezSpell   
            ["Song of Twilight"] MezSpell
            ["Sionachie's Dreams"] MezSpell  
            ["Crission's Pixie Strike"] MezSpell   
            ["Kelin's Lucid Lullaby"] MezSpell 
    
    
    -- MezAESpell - Level Range 85 - 115 **
            ["Wave of Nocturn"] MezAESpell
            ["Wave of Sleep"] MezAESpell
            ["Wave of Somnolence"] MezAESpell
            ["Wave of Torpor"] MezAESpell    
            ["Wave of Quietude"] MezAESpell
            ["Wave of the Conductor"] MezAESpell
            ["Wave of Dreams"] MezAESpell  
            ["Wave of Slumber"] MezAESpell    
    
    
    -- SlowSong - We only get 1 single target slow
            ["Requiem of Time"] SlowSong    
        
    -- Singletarget Assonant Slow Line
    
    
    -- AESlowSong - Level Range 20 - 114 (Single target works better)  
    
            ["Radiwol's Melodic Binding"] AESlowSong
            ["Dekloaz's Melodic Binding"] AESlowSong
            ["Protan's Melodic Binding"] AESlowSong  
            ["Largo's Melodic Binding"] AESlowSong    
    
     -- AccelerandoSong - Level Range 88 - 113 **
            ["Satisfying Accelerando"] AccelerandoSong
            ["Placating Accelerando"] AccelerandoSong
            ["Atoning Accelerando"] AccelerandoSong    
            ["Allaying Accelerando"] AccelerandoSong
            ["Ameliorating Accelerando"] AccelerandoSong
            ["Assuaging Accelerando"] AccelerandoSong  
            ["Alleviating Accelerando"] AccelerandoSong    
    
     -- SpitefulSong - Level Range 90 - 
            ["Von Deek's Spiteful Lyric"] SpitefulSong
            ["Omorden's Spiteful Lyric"] SpitefulSong
            ["Travenro's Spiteful Lyric"] SpitefulSong    
            ["Fjilnauk's Spiteful Lyric"] SpitefulSong
            ["Kaficus' Spiteful Lyric"] SpitefulSong
            ["Hykast's Spiteful Lyric"] SpitefulSong  
            ["Lyrin's Spiteful Lyric"] SpitefulSong    
    
     -- RecklessSong - Level Range 93 - 113 **
            ["Kai's Reckless Renewal"] RecklessSong
            ["Reivaj's Reckless Renewal"] RecklessSong    
            ["Rigelon's Reckless Renewal"] RecklessSong
            ["Rytan's Reckless Renewal"] RecklessSong
            ["Ruaabri's Reckless Renewal"] RecklessSong  
            ["Ryken's Reckless Renewal"] RecklessSong    
        
     -- Fatesong - Level Range 77 - 112 **
            ["Fatesong of Lucca"] FateSong
            ["Fatesong of Radiwol"] FateSong
            ["Fatesong of Dekloaz"] FateSong 
            ["Fatesong of Jocelyn"] FateSong
            ["Fatesong of Protan"] FateSong    
            ["Fatesong of Illdaera"] FateSong
            ["Fatesong of Fergar"] FateSong
            ["Fatesong of the Gelidran"] FateSong  
            ["Garadell's Fatesong"] FateSong    
        
     -- PsalmSong - Level Range 69 - 112 **
     -- What differs between PsalmSong and MainAriaSong ???
            ["Fyrthek Fior's Psalm of Potency"] PsalmSong
            ["Velketor's Psalm of Potency"] PsalmSong
            ["Akett's Psalm of Potency"] PsalmSong  
            ["Horthin's Psalm of Potency"] PsalmSong
            ["Siavonn's Psalm of Potency"] PsalmSong 
            ["Wasinai's Psalm of Potency"] PsalmSong
            ["Lyrin's Psalm of Potency"] PsalmSong    
            ["Druzzil's Psalm of Potency"] PsalmSong
            ["Erradien's Psalm of Potency"] PsalmSong
            ["Performer's Psalm of Pyrotechnics"] PsalmSong  
            ["Ancient: Call of Power"] PsalmSong 
            ["Eriki's Psalm of Power"] PsalmSong    
    
    -- DotSong - Level Range 30 - 115  
            ["Shak Dathor's Chant of Flame"] DotSong
            ["Cruor's Chant of Poison"] DotSong
            ["Sylra Fris' Chant of Frost"] DotSong
            ["Coagulus' Chant of Disease"] DotSong
            ["Sontalak's Chant of Flame"] DotSong
            ["Malvus's Chant of Poison"] DotSong  
            ["Yelinak's Chant of Frost"] DotSong    
            ["Zlexak's Chant of Disease"] DotSong
            ["Qunard's Chant of Flame"] DotSong
            ["Nexona's Chant of Poison"] DotSong
            ["Ekron's Chant of Frost"] DotSong    
            ["Hoshkar's Chant of Disease"] DotSong
            ["Nilsara's Chant of Flame"] DotSong
            ["Serisaria's Chant of Poison"] DotSong  
            ["Kirchen's Chant of Frost"] DotSong
            ["Horthin's Chant of Disease"] DotSong  
            ["Gosik's Chant of Flame"] DotSong 
            ["Slaunk's Chant of Poison"] DotSong
            ["Edoth's Chant of Frost"] DotSong
            ["Siavonn's Chant of Disease"] DotSong
            ["Daevan's Chant of Flame"] DotSong    
            ["Hiqork's Chant of Poison"] DotSong
            ["Kalbrok's Chant of Frost"] DotSong
            ["Wasinai's Chant of Disease"] DotSong  
            ["Sotor's Chant of Flame"] DotSong    
            ["Spinechiller's Chant of Poison"] DotSong
            ["Fergar's Chant of Frost"] DotSong
            ["Shiverback's Chant of Disease"] DotSong
            ["Talendor's Chant of Flame"] DotSong    
            ["Severilous' Chant of Poison"] DotSong
            ["Gorenaire's Chant of Frost"] DotSong
            ["Trakanon's Chant of Disease"] DotSong  
            ["Tjudawos' Chant of Flame"] DotSong   
            ["Kildrukaun's Chant of Poison"] DotSong
            ["Zeixshi-Kar's Chant of Frost"] DotSong  
            ["Vyskudra's Chant of Disease"] DotSong 
            ["Ancient: Chaos Chant"] DotSong 
            ["Vulka's Chant of Flame"] DotSong
            ["Vulka's Chant of Poison"] DotSong
            ["Vulka's Chant of Frost"] DotSong
            ["Vulka's Chant of Disease"] DotSong    
            ["Ancient: Chaos Chant"] DotSong
            ["Tuyen's Chant of Fire"] DotSong
            ["Tuyen's Chant of Ice"] DotSong  
            ["Tuyen's Chant of Venom"] DotSong    
            ["Tuyen's Chant of the Plague"] DotSong
            ["Angstlich's Assonance"] DotSong
            ["Fufil's Diminishing Dirge"] DotSong
            ["Tuyen's Chant of Poison"] DotSong    
            ["Tuyen's Chant of Frost"] DotSong
            ["Tuyen's Chant of Disease"] DotSong
            ["Tuyen's Chant of Flame"] DotSong  
            ["Fufil's Curtailing Chant"] DotSong    
      
            ["Aria of Absolution"] CureSpell    

        ['Mantle'] = {
            [1] = "Malarian Mantle",
            [2] = "Gorgon Mantle",
            [3] = "Recondite Mantle",
            [4] = "Bonebrood Mantle",
            [5] = "Doomscale Mantle",
            [6] = "Krellnakor Mantle",
            [7] = "Restless Mantle",
            [8] = "Fyrthek Mantle",
            [9] = "Geomimus Mantle",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Debuff'] = 1,
            ['Heal'] = 1,
            ['DPS'] = 1,
            ['Downtime'] = 1,
            ['Burn'] = 1,
        },
        ['DPS'] = {
            ['Debuff'] = 1,
            ['Heal'] = 1,
            ['DPS'] = 1,
            ['Downtime'] = 1,
            ['Burn'] = 1,
        },
        ['TLP'] = {
            ['Debuff'] = 1,
            ['Heal'] = 1,
            ['DPS'] = 1,
            ['Downtime'] = 1,
            ['Burn'] = 1,
        },
    },
    ['DefaultConfig'] = {
        ['Mode'] = 'Tank',
    },
}
