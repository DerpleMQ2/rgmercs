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
        ['BardRunBuff'] = {
        -- Bard RunSpeed 
        [1] = "Selo's Accelerato",
        -- Song of travel has been removed due to causing Bugs with Invis and rotation.
        -- [] = ["Selo's Song of Travel"],
        [1] = "Selo's Accelerating Chorus",
        [2] = "Selo's Accelerando",
        },
        ['MainAriaSong'] = {
            [1] = "Aria of Pli Xin Liako",
            [2] = "Aria of Margidor",
            [3] = "Aria of Begalru",
            [4] = "Aria of Maetanrus",
            [5] = "Aria of Va'Ker",
            [6] = "Aria of the Orator",  
            [7] = "Aria of the Composer",
            [8] = "Aria of the Poet",
            [9] = "Ancient: Call of Power",
            [10] = "Aria of the Artist",
            [11] = "Yelhun's Mystic Call",
            [12] = "Ancient: Call of Power",
            [13] = "Rizlona's Call of Flame",
            [14] = "Rizlona's Fire",
            [15] = "Rizlona's Embers",
        },
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
        ['DichoSong'] = {
            -- DichoSong Level Range - 101 - 106
            [1] = "Ecliptic Psalm",
            [2] = "Composite Psalm",
            [3] = "Dissident Psalm",
            [4] = "Dichotomic Psalm",    
        },
        ['BardDPSAura'] = {
                    -- BardDPSAura - Level Ranges 55 - 115
        [] = ["Aura of Pli Xin Liako"]
        [] = ["Aura of Margidor"]
        [] = ["Aura of Begalru"]
        [] = ["Aura of Maetanrus"]
        [] = ["Aura of Va'Ker"]
        [] = ["Aura of the Orator"]
        [] = ["Aura of the Composer"]
        [] = ["Aura of the Poet"]
        [] = ["Aura of the Artist"]
        [] = ["Aura of the Muse"]
        [] = ["Aura of Insight"]

        },
        ['BardRegenAura'] = {
            [] = ["Aura of Shei Vinitras"]
            [] = ["Aura of Vhal`Sera"]
            [] = ["Aura of Xigam"]
            [] = ["Aura of Sionachie"]
            [] = ["Aura of Salarra"]
            [] = ["Aura of Lunanyn"]
            [] = ["Aura of Renewal"]
            [] = ["Aura of Rodcet"]
        },
        ['PulseRegenSong'] = {},
        ['ChorusRegenSong'] = {},
        ['WarMarchSong'] = {},
        ['CasterAriaSong'] = {
            [] = "Constance's Aria",
            [] = "Sontalak's Aria",
            [] = "Qunard's Aria",
            [] = "Nilsara's Aria",
            [] = "Gosik's Aria",
            [] = "Daevan's Aria",
            [] = "Sotor's Aria",
            [] = "Talendor's Aria",
            [] = "Performer's Explosive Aria",
            [] = "Weshlu's Chillsong Aria",
        },
        ['SlowSong'] = {},
        ['AESlowSong'] = {},
        ['AccelerandoSong'] = {},
        ['SpitefulSong'] = {},
        ['RecklessSong'] = {},
        ['SelfRune1'] = {},
        ['StripBuffSpell'] = {},
        ['FateSong'] = {},
        ['PsalmSong'] = {},
        ['DotSong'] = { -- DotSong - Level Range 30 - 115 
                -- Fire Dot  
                [1] = "Shak Dathor's Chant of Flame",
                [5] = "Sontalak's Chant of Flame",
                [9] = "Qunard's Chant of Flame",
                [13] = "Nilsara's Chant of Flame",
                [17] = "Gosik's Chant of Flame", 
                [21] = "Daevan's Chant of Flame",    
                [25] = "Sotor's Chant of Flame",  
                [29] = "Talendor's Chant of Flame", 
                [33] = "Tjudawos' Chant of Flame",   
                [38] = "Vulka's Chant of Flame",
                [43] = "Tuyen's Chant of Fire",
                [52] = "Tuyen's Chant of Flame",  

                -- Posion Dot             
                [2] = "Cruor's Chant of Poison",
                [6] = "Malvus's Chant of Poison",  
                [10] = "Nexona's Chant of Poison",
                [14] = "Serisaria's Chant of Poison",  
                [18] = "Slaunk's Chant of Poison",
                [22] = "Hiqork's Chant of Poison",
                [26] = "Spinechiller's Chant of Poison",
                [30] = "Severilous' Chant of Poison",
                [34] = "Kildrukaun's Chant of Poison",
                [39] = "Vulka's Chant of Poison",
                [45] = "Tuyen's Chant of Venom",    
                [59] = "Tuyen's Chant of Poison",    

                -- Ice Dot
                [3] = "Sylra Fris' Chant of Frost",
                [7] = "Yelinak's Chant of Frost",    
                [11] = "Ekron's Chant of Frost",    
                [15] = "Kirchen's Chant of Frost",
                [19] = "Edoth's Chant of Frost",
                [23] = "Kalbrok's Chant of Frost",
                [27] = "Fergar's Chant of Frost",
                [31] = "Gorenaire's Chant of Frost",
                [35] = "Zeixshi-Kar's Chant of Frost",  
                [40] = "Vulka's Chant of Frost",
                [44] = "Tuyen's Chant of Ice",  
                [50] = "Tuyen's Chant of Frost",

                -- Disease Dot
                [4] = "Coagulus' Chant of Disease",
                [8] = "Zlexak's Chant of Disease",                              
                [12] = "Hoshkar's Chant of Disease",                                         
                [17] = "Horthin's Chant of Disease",               
                [20] = "Siavonn's Chant of Disease",
                [24] = "Wasinai's Chant of Disease",  
                [28] = "Shiverback's Chant of Disease",   
                [32] = "Trakanon's Chant of Disease",  
                [36] = "Vyskudra's Chant of Disease", 
                [41] = "Vulka's Chant of Disease",                    
                [46] = "Tuyen's Chant of the Plague",
                [51] = "Tuyen's Chant of Disease",

                -- Misc Dot -- Or Minsc Dot (HEY HEY BOO BOO!)
                [37] = "Ancient: Chaos Chant",               
                [47] = "Angstlich's Assonance",
                [48] = "Fufil's Diminishing Dirge",
                [53] = "Fufil's Curtailing Chant",    
        },
        ['CureSpell'] = {},
        ['AllianceSong'] = {
            [1] = "Conjunction of Sticks and Stones",
            [2] = "Alliance of Sticks and Stones",
            [3] = "Covenant of Sticks and Stones",
            [4] = "Coalition of Sticks and Stones",   
        },
        ['CharmSong'] = {
            [1] = "Omiyad's Demand",
            [2] = "Voice of the Diabo",
            [3] = "Silisia's Demand",
            [4] = "Dawnbreeze's Demand",
            [5] = "Desirae's Demand",
            -- Low Level Aria Song - before Combination of Effects Under Level 68
            [6] = "Battlecry of the Vah Shir",
            [7] = "Warsong of the Vah Shir",
        },
        ['ReflexStrike'] = {
            -- Bard ReflexStrike - Restores mana to group
            [1] = "Reflexive Retort",
            [2] = "Reflexive Rejoinder",
            [3] = "Reflexive Rebuttal",
        },
        ['ChordsAE'] = {},
        ['LowAriaSong'] = {},
        ['AmpSong'] = {
            [1] = "Amplification",
        },
        ['DispelSong'] = {},
        ['ResistSong'] = {
            -- Resists Song
            [1] = "Psalm of Cooling",
            [2] = "Psalm of Purity",
            [3] = "Psalm of Warmth",
            [4] = "Psalm of Vitality",
            [5] = "Psalm of Veeshan",
            [6] = "Psalm of the Forsaken",
            [7] = "Second Psalm of Veeshan",
            [8] = "Psalm of the Restless",
            [9] = "Psalm of the Pious",
        },       
        ['MezSpell'] = {
            -- MezSpell - Level Range 15 - 114
            [1] = "Slumber of the Diabo",
            -- [] = "Lullaby of Nightfall",
            -- [] = "Lullaby of Zburator",
            [2] = "Slumber of Zburator",
            [3] = "Slumber of Jembel", 
            -- [] = "Lullaby of Jembel",
            [4] = "Slumber of Silisia",
            -- [] = "Lullaby of Silisia",
            [5] = "Slumber of Motlak",
            -- [] = "Lullaby of the Forsaken",   
            [6] = "Slumber of Kolain",
            -- [] = "Lullaby of the Forlorn",
            [7] = "Slumber of Sionachie", 
            -- [] = "Lullaby of the Lost",   
            [8] = "Slumber of the Mindshear",
            [9] = "Serenity of Oceangreen",
            [10] = "Amber's Last Lullaby",
            [11] = "Queen Eletyl's Screech",
            [12] = "Command of Queen Veneneu",
            [13] = "Aelfric's Last Lullaby",   
            [14] = "Vulka's Lullaby",
            [15] = "Creeping Dreams",
            [16] = "Luvwen's Lullaby", 
            [17] = "Lullaby of Morell",   
            [18] = "Dreams of Terris",
            [19] = "Dreams of Thule", 
            [20] = "Dreams of Ayonae",  
            [21] = "Song of Twilight",
            [22] = "Sionachie's Dreams", 
            [23] = "Crission's Pixie Strike",  
            [24] = "Kelin's Lucid Lullaby",
        },
        ['MezAESpell'] = {
        -- Bard PBAE - Used Only for Level 2 Pull Spell.
            [1] = "Chords of Dissonance",
        },

    



    
 

    
    
        /varset BardDPSAura_name ${GetAuraName[${BardDPSAura},BardDPSAura]}



    


        -- MainAriaSong - Level Ranges 45 - 111
        -- What differs between PsalmSong and MainAriaSong ???

        },
        -- CasterAriaSong - Level Range 72 - 113


    
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
--    
--          [] =     ["Nord's Disdain"] InsultSong
--          [] =   ["Sogran's Insult"] InsultSong
--          [] =    ["Yelinak's Insult"] InsultSong
--          [] =    ["Omorden's Insult"] InsultSong 
--          [] =    ["Sathir's Insult"] InsultSong
--          [] =    ["Travenro's Insult"] InsultSong  
--          [] =     ["Tsaph's Insult"] InsultSong
--          [] =     ["Fjilnauk's Insult"] InsultSong
--          [] =     ["Kaficus' Insult"] InsultSong
--          [] =     ["Garath's Insult"] InsultSong
--          [] =     ["Hykast's Insult"] InsultSong
--          [] =     ["Venimor's Insult"] InsultSong 
        -- Below Level 85 This line turns into "bellow" instead of "Insult"
--          [] = ["Bellow of Chaos"] InsultSong
--          [] =     ["Brusco's Bombastic Bellow"] InsultSong   
--          [] =     ["Brusco's Boastful Bellow"] InsultSong
--
    
    
    
    
    -- MezAESpell - Level Range 85 - 115 **
    [] = ["Wave of Nocturn"] MezAESpell
            [] = ["Wave of Sleep"] MezAESpell
            [] = ["Wave of Somnolence"] MezAESpell
            [] = ["Wave of Torpor"] MezAESpell    
            [] = ["Wave of Quietude"] MezAESpell
            [] = ["Wave of the Conductor"] MezAESpell
            [] = ["Wave of Dreams"] MezAESpell  
            [] = ["Wave of Slumber"] MezAESpell    
    
    
    -- SlowSong - We only get 1 single target slow
            ["Requiem of Time"] SlowSong          
    -- Singletarget Assonant Slow Line
    
    
    -- AESlowSong - Level Range 20 - 114 (Single target works better)  
    
    [] =     ["Radiwol's Melodic Binding"] AESlowSong
    [] =     ["Dekloaz's Melodic Binding"] AESlowSong
    [] =     ["Protan's Melodic Binding"] AESlowSong  
    [] =     ["Largo's Melodic Binding"] AESlowSong    
    
     -- AccelerandoSong - Level Range 88 - 113 **
     [] =     ["Satisfying Accelerando"] AccelerandoSong
     [] =     ["Placating Accelerando"] AccelerandoSong
     [] =     ["Atoning Accelerando"] AccelerandoSong    
     [] =     ["Allaying Accelerando"] AccelerandoSong
     [] =     ["Ameliorating Accelerando"] AccelerandoSong
     [] =     ["Assuaging Accelerando"] AccelerandoSong  
     [] =     ["Alleviating Accelerando"] AccelerandoSong    
    
     -- SpitefulSong - Level Range 90 - 
     [] =     ["Von Deek's Spiteful Lyric"] SpitefulSong
     [] =     ["Omorden's Spiteful Lyric"] SpitefulSong
     [] =     ["Travenro's Spiteful Lyric"] SpitefulSong    
     [] =     ["Fjilnauk's Spiteful Lyric"] SpitefulSong
     [] =     ["Kaficus' Spiteful Lyric"] SpitefulSong
     [] =     ["Hykast's Spiteful Lyric"] SpitefulSong  
     [] =     ["Lyrin's Spiteful Lyric"] SpitefulSong    
    
     -- RecklessSong - Level Range 93 - 113 **
     [] =     ["Kai's Reckless Renewal"] RecklessSong
     [] =     ["Reivaj's Reckless Renewal"] RecklessSong    
     [] =     ["Rigelon's Reckless Renewal"] RecklessSong
     [] =     ["Rytan's Reckless Renewal"] RecklessSong
     [] =     ["Ruaabri's Reckless Renewal"] RecklessSong  
     [] =     ["Ryken's Reckless Renewal"] RecklessSong    
        
     -- Fatesong - Level Range 77 - 112 **
     [] =     ["Fatesong of Lucca"] FateSong
     [] =     ["Fatesong of Radiwol"] FateSong
     [] =     ["Fatesong of Dekloaz"] FateSong 
     [] =     ["Fatesong of Jocelyn"] FateSong
     [] =     ["Fatesong of Protan"] FateSong    
     [] =     ["Fatesong of Illdaera"] FateSong
     [] =     ["Fatesong of Fergar"] FateSong
     [] =     ["Fatesong of the Gelidran"] FateSong  
     [] =     ["Garadell's Fatesong"] FateSong    
        
        -- PsalmSong - Level Range 69 - 112 **
        -- What differs between PsalmSong and MainAriaSong ???
        [] = ["Fyrthek Fior's Psalm of Potency"] PsalmSong
        [] =    ["Velketor's Psalm of Potency"] PsalmSong
        [] =    ["Akett's Psalm of Potency"] PsalmSong  
        [] =    ["Horthin's Psalm of Potency"] PsalmSong
        [] =    ["Siavonn's Psalm of Potency"] PsalmSong 
        [] =   ["Wasinai's Psalm of Potency"] PsalmSong
        [] =   ["Lyrin's Psalm of Potency"] PsalmSong    
        [] =   ["Druzzil's Psalm of Potency"] PsalmSong
        [] =   ["Erradien's Psalm of Potency"] PsalmSong
         [] =   ["Performer's Psalm of Pyrotechnics"] PsalmSong  
            [] = ["Ancient: Call of Power"] PsalmSong 
            [] = ["Eriki's Psalm of Power"] PsalmSong    
    

      
            [] = ["Aria of Absolution"] CureSpell    

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
