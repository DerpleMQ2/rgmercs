local mq             = require('mq')
local RGMercUtils    = require("rgmercs.utils.rgmercs_utils")

return {
    ['Modes'] = {
        ['Modes'] = {
            [1] = 'Tank',
            [2] = 'DPS',
            [3] = 'Healer',
            [4] = 'Hybrid',
        },
    },
    ['ItemSets'] = {
        ['Epic'] = {
            [1] = "Epic 1.5",
            [2] = "Epic 2.0",
        },
    },
    ['AbilitySets'] = {
        ['AbilityGroup'] = {
            [1] = "Spell or Disc Name",
        },
    },
    ['Rotations'] = {
        ['Tank'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['DPS'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['Healer'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['Hybrid'] = {
            ['Rotation'] = {
                ['Burn'] = {
                    [1] = {},
                },
                ['Debuff'] = {
                    [1] = {},
                },
                ['Heal'] = {
                    [1] = {},
                },
                ['DPS'] = {
                    [1] = {},
                },
                ['Downtime'] = {
                    [1] = {},
                },
            },
            ['Spells'] = {
                [1] = { name="", gem=1 },
                [2] = { name="", gem=2 },
                [3] = { name="", gem=3},
                [4] = { name="", gem=4},
                [5] = { name="", gem=5 },
                [6] = { name="", gem=6 },
                [7] = { name="", gem=7 },
                [8] = { name="", gem=8 },
                [9] = { name="", gem=9 },
                [10] = { name="", gem=10 },
                [11] = { name="", gem=11 },
                [12] = { name="", gem=12 },
            },
        },
        ['DefaultConfig'] = {
            ['Mode'] = '1',
        },
    },
}