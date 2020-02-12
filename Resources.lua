local Resources = {}

GimmeTheLoot.Resources = Resources

Resources.ItemTypes = {
    [-1] = 'Any',
    [0] = 'Consumable',
    [1] = 'Container',
    [2] = 'Weapon',
    -- [3] = 'Gem', -- unused
    [4] = 'Armor',
    [5] = 'Reagent',
    [6] = 'Projectile',
    [7] = 'Tradeskill',
    -- [8] = 'Item Enhancement', -- unused
    [9] = 'Recipe',
    -- [10] = 'Money', -- unused
    [11] = 'Quiver',
    [12] = 'Quest',
    -- [13] = 'Key', -- unused
    -- [14] = 'Permanent', -- unused
    [15] = 'Misc',
    -- [16] = 'Glyph', -- unused
    -- [17] = 'Battle Pet', -- unused
    -- [18] = 'WoW Token', -- unused
}

Resources.ItemSubTypes = {
    --[0] = {}, -- consumable
    --[1] = {}, -- container

    [2] = { -- weapons
        [-1] = 'Any',
        [0] = 'One-Handed Axes',
        [1] = 'Two-Handed Axes',
        [2] = 'Bows',
        [3] = 'Guns',
        [4] = 'One-Handed Maces',
        [5] = 'Two-Handed Maces',
        [6] = 'Polearms',
        [7] = 'One-Handed Swords',
        [8] = 'Two-Handed Swords',
        -- [9] = 'Warglaives',
        [10] = 'Staves',
        -- [11] = 'Bear Claws',
        -- [12] = 'Cat Claws',
        [13] = 'Fist Weapons',
        -- [14] = 'Misc',
        [15] = 'Daggers',
        [16] = 'Thrown',
        -- [17] = 'Spears', -- I wish
        [18] = 'Crossbows',
        [19] = 'Wands',
        [20] = 'Fishing Poles',
    },

    -- [3] = {}, -- gem (unused)

    [4] = { -- armor
        [-1] = 'Any',
        [0] = 'Jewelry and Trinkets',
        [1] = 'Cloth',
        [2] = 'Leather',
        [3] = 'Mail',
        [4] = 'Plate',
        -- [5] = 'Cosmetic',
        [6] = 'Shields',
        [7] = 'Librams',
        [8] = 'Idols',
        [9] = 'Totems',
        [10] = 'Sigils',
        [11] = 'Relics',
    },

    -- [5] = {}, -- reagent

    [6] = { -- projectile
        [-1] = 'Any',
        [2] = 'Arrow',
        [3] = 'Bullet',
    },

    -- [7] = {}, -- tradeskill
    -- [8] = {}, -- item enhancement (unused)
    -- [9] = {}, -- recipe
    -- [10] = {}, -- money (unused)
    -- [11] = {}, -- quiver
    -- [12] = {}, -- quest
    -- [13] = {}, -- key (unused)
    -- [14] = {}, -- permanent (unused)
    -- [15] = {}, -- misc
    -- [16] = {}, -- glyph (unused)
    -- [17] = {}, -- battle pets (unused)
    -- [18] = {}, -- wow token (unused)
}
