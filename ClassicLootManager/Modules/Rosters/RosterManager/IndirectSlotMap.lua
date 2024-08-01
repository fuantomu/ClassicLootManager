local _, CLM = ...

local IndirectMap = {
    slot = {
        --- WOTLK P1 ---
        [44577] = "INVTYPE_NECK",       -- Heroic Key to the Focusing Iris
        [40618] = "INVTYPE_HEAD",       -- Helm of the Lost Vanquisher
        [40612] = "INVTYPE_CHEST",      -- Chestguard of the Lost Vanquisher
        [40621] = "INVTYPE_LEGS",       -- Leggings of the Lost Vanquisher
        [40624] = "INVTYPE_SHOULDER",   -- Spaulders of the Lost Vanquisher
        [40615] = "INVTYPE_HAND",       -- Gloves of the Lost Vanquisher
        [40616] = "INVTYPE_HEAD",       -- Helm of the Lost Conqueror
        [40610] = "INVTYPE_CHEST",      -- Chestguard of the Lost Conqueror
        [40619] = "INVTYPE_LEGS",       -- Leggings of the Lost Conqueror
        [40622] = "INVTYPE_SHOULDER",   -- Spaulders of the Lost Conqueror
        [40613] = "INVTYPE_HAND",       -- Gloves of the Lost Conqueror
        [40617] = "INVTYPE_HEAD",       -- Helm of the Lost Protector
        [40611] = "INVTYPE_CHEST",      -- Chestguard of the Lost Protector
        [40620] = "INVTYPE_LEGS",       -- Leggings of the Lost Protector
        [40623] = "INVTYPE_SHOULDER",   -- Spaulders of the Lost Protector
        [40614] = "INVTYPE_HAND",       -- Gloves of the Lost Protector
        [40630] = "INVTYPE_HAND",       -- Gauntlets of the Lost Vanquisher
        [40633] = "INVTYPE_HEAD",       -- Crown of the Lost Vanquisher
        [40636] = "INVTYPE_LEGS",       -- Legplates of the Lost Vanquisher
        [40627] = "INVTYPE_CHEST",      -- Breastplate of the Lost Vanquisher
        [40639] = "INVTYPE_SHOULDER",   -- Mantle of the Lost Vanquisher
        [40628] = "INVTYPE_HAND",       -- Gauntlets of the Lost Conqueror
        [40631] = "INVTYPE_HEAD",       -- Crown of the Lost Conqueror
        [40634] = "INVTYPE_LEGS",       -- Legplates of the Lost Conqueror
        [40625] = "INVTYPE_CHEST",      -- Breastplate of the Lost Conqueror
        [40637] = "INVTYPE_SHOULDER",   -- Mantle of the Lost Conqueror
        [40626] = "INVTYPE_CHEST",      -- Breastplate of the Lost Protector
        [40629] = "INVTYPE_HAND",       -- Gauntlets of the Lost Protector
        [40632] = "INVTYPE_HEAD",       -- Crown of the Lost Protector
        [40635] = "INVTYPE_LEGS",       -- Legplates of the Lost Protector
        [40638] = "INVTYPE_SHOULDER",   -- Mantle of the Lost Protector
        --- WOTLK P2 ---
        [45637] = "INVTYPE_CHEST",      -- Chestguard of the Wayward Vanquisher
        [45649] = "INVTYPE_HEAD",       -- Helm of the Wayward Vanquisher
        [45646] = "INVTYPE_HAND",       -- Gloves of the Wayward Vanquisher
        [45652] = "INVTYPE_LEGS",       -- Leggings of the Wayward Vanquisher
        [45661] = "INVTYPE_SHOULDER",   -- Spaulders of the Wayward Vanquisher
        [45645] = "INVTYPE_HAND",       -- Gloves of the Wayward Protector
        [45648] = "INVTYPE_HEAD",       -- Helm of the Wayward Protector
        [45651] = "INVTYPE_LEGS",       -- Leggings of the Wayward Protector
        [45660] = "INVTYPE_SHOULDER",   -- Spaulders of the Wayward Protector
        [45636] = "INVTYPE_CHEST",      -- Chestguard of the Wayward Protector
        [45644] = "INVTYPE_HAND",       -- Gloves of the Wayward Conqueror
        [45650] = "INVTYPE_LEGS",       -- Leggings of the Wayward Conqueror
        [45647] = "INVTYPE_HEAD",       -- Helm of the Wayward Conqueror
        [45659] = "INVTYPE_SHOULDER",   -- Spaulders of the Wayward Conqueror
        [45635] = "INVTYPE_CHEST",      -- Chestguard of the Wayward Conqueror
        [45634] = "INVTYPE_CHEST",      -- Breastplate of the Wayward Vanquisher
        [45643] = "INVTYPE_HAND",       -- Gauntlets of the Wayward Vanquisher
        [45640] = "INVTYPE_HEAD",       -- Crown of the Wayward Vanquisher
        [45655] = "INVTYPE_LEGS",       -- Legplates of the Wayward Vanquisher
        [45658] = "INVTYPE_SHOULDER",   -- Mantle of the Wayward Vanquisher
        [45641] = "INVTYPE_HAND",       -- Gauntlets of the Wayward Conqueror
        [45656] = "INVTYPE_SHOULDER",   -- Mantle of the Wayward Conqueror
        [45632] = "INVTYPE_CHEST",      -- Breastplate of the Wayward Conqueror
        [45653] = "INVTYPE_LEGS",       -- Legplates of the Wayward Conqueror
        [45638] = "INVTYPE_HEAD",       -- Crown of the Wayward Conqueror
        [45633] = "INVTYPE_CHEST",      -- Breastplate of the Wayward Protector
        [45642] = "INVTYPE_HAND",       -- Gauntlets of the Wayward Protector
        [45639] = "INVTYPE_HEAD",       -- Crown of the Wayward Protector
        [45654] = "INVTYPE_LEGS",       -- Legplates of the Wayward Protector
        [45657] = "INVTYPE_SHOULDER",   -- Mantle of the Wayward Protector
        --- SOD P3 ---
        [220636] = "INVTYPE_NON_EQUIP", -- Atal'ai Blood Icon
        [220637] = "INVTYPE_NON_EQUIP", -- Atal'ai Ritual Token
        --- SOD P4 ---
        [227532] = "INVTYPE_HEAD",  -- Incandescent Hood
        [227537] = "INVTYPE_SHOULDER",  -- Incandescent Shoulderpads
        [227535] = "INVTYPE_CHEST",  -- Incandescent Robe
        [227534] = "INVTYPE_LEGS",  -- Incandescent Leggings
        [227531] = "INVTYPE_WRIST",  -- Incandescent Bindings
        [227536] = "INVTYPE_FEET",  -- Incandescent Boots
        [227530] = "INVTYPE_WAIST",  -- Incandescent Belt
        [227533] = "INVTYPE_HAND",  -- Incandescent Gloves
        [227764] = "INVTYPE_HEAD",  -- Scorched Core Helm
        [227762] = "INVTYPE_SHOULDER",  -- Scorched Core Shoulderpads
        [227766] = "INVTYPE_CHEST",  -- Scorched Core Chest
        [227763] = "INVTYPE_LEGS",  -- Scorched Core Leggings
        [227760] = "INVTYPE_WRIST",  -- Scorched Core Bindings
        [227765] = "INVTYPE_FEET",  -- Scorched Core Boots
        [227761] = "INVTYPE_WAIST",  -- Scorched Core Belt
        [227759] = "INVTYPE_HAND",  -- Scorched Core Gloves
        [227755] = "INVTYPE_HEAD",  -- Molten Scaled Helm
        [227752] = "INVTYPE_SHOULDER",  -- Molten Scaled Shoulderpads
        [227758] = "INVTYPE_CHEST",  -- Molten Scaled Chest
        [227754] = "INVTYPE_LEGS",  -- Molten Scaled Leggings
        [227750] = "INVTYPE_WRIST",  -- Molten Scaled Bindings
        [227757] = "INVTYPE_FEET",  -- Molten Scaled Boots
        [227751] = "INVTYPE_WAIST",  -- Molten Scaled Belt
        [227756] = "INVTYPE_HAND",  -- Molten Scaled Gloves
        --- Cataclysm P1 Normal ---
        [63682] = "INVTYPE_HEAD",       -- Helm of the Forlorn Vanquisher
        [63684] = "INVTYPE_HEAD",       -- Helm of the Forlorn Protector
        [63683] = "INVTYPE_HEAD",       -- Helm of the Forlorn Conqueror
        [64314] = "INVTYPE_SHOULDER",   -- Mantle of the Forlorn Vanquisher
        [64316] = "INVTYPE_SHOULDER",   -- Mantle of the Forlorn Protector
        [64315] = "INVTYPE_SHOULDER",   -- Mantle of the Forlorn Conqueror
        --- Cataclysm P1 Heroic ---
        [66998] = "INVTYPE_NON_EQUIP",  -- Essence of the Forlorn
        [65002] = "INVTYPE_HEAD",       -- Crown of the Forlorn Vanquisher
        [65000] = "INVTYPE_HEAD",       -- Crown of the Forlorn Protector
        [65001] = "INVTYPE_HEAD",       -- Crown of the Forlorn Conqueror
        [65089] = "INVTYPE_SHOULDER",   -- Shoulders of the Forlorn Vanquisher
        [65087] = "INVTYPE_SHOULDER",   -- Shoulders of the Forlorn Protector
        [65088] = "INVTYPE_SHOULDER",   -- Shoulders of the Forlorn Conqueror
        [67426] = "INVTYPE_LEGS",       -- Leggings of the Forlorn Vanquisher
        [67427] = "INVTYPE_LEGS",       -- Leggings of the Forlorn Protector
        [67428] = "INVTYPE_LEGS",       -- Leggings of the Forlorn Conqueror
        [67431] = "INVTYPE_HAND",       -- Gauntlets of the Forlorn Vanquisher
        [67430] = "INVTYPE_HAND",       -- Gauntlets of the Forlorn Protector
        [67429] = "INVTYPE_HAND",       -- Gauntlets of the Forlorn Conqueror
        [67425] = "INVTYPE_CHEST",      -- Chest of the Forlorn Vanquisher
        [67424] = "INVTYPE_CHEST",      -- Chest of the Forlorn Protector
        [67423] = "INVTYPE_CHEST",      -- Chest of the Forlorn Conqueror
    },
    ilvl = {
        --- WOTLK P1 ---
        [44577] = 226,  -- Heroic Key to the Focusing Iris
        [40618] = 200,  -- Helm of the Lost Vanquisher
        [40612] = 200,  -- Chestguard of the Lost Vanquisher
        [40621] = 200,  -- Leggings of the Lost Vanquisher
        [40624] = 200,  -- Spaulders of the Lost Vanquisher
        [40615] = 200,  -- Gloves of the Lost Vanquisher
        [40616] = 200,  -- Helm of the Lost Conqueror
        [40610] = 200,  -- Chestguard of the Lost Conqueror
        [40619] = 200,  -- Leggings of the Lost Conqueror
        [40622] = 200,  -- Spaulders of the Lost Conqueror
        [40613] = 200,  -- Gloves of the Lost Conqueror
        [40617] = 200,  -- Helm of the Lost Protector
        [40611] = 200,  -- Chestguard of the Lost Protector
        [40620] = 200,  -- Leggings of the Lost Protector
        [40623] = 200,  -- Spaulders of the Lost Protector
        [40614] = 200,  -- Gloves of the Lost Protector
        [40630] = 213,  -- Gauntlets of the Lost Vanquisher
        [40633] = 213,  -- Crown of the Lost Vanquisher
        [40636] = 213,  -- Legplates of the Lost Vanquisher
        [40627] = 213,  -- Breastplate of the Lost Vanquisher
        [40639] = 213,  -- Mantle of the Lost Vanquisher
        [40628] = 213,  -- Gauntlets of the Lost Conqueror
        [40631] = 213,  -- Crown of the Lost Conqueror
        [40634] = 213,  -- Legplates of the Lost Conqueror
        [40625] = 213,  -- Breastplate of the Lost Conqueror
        [40637] = 213,  -- Mantle of the Lost Conqueror
        [40626] = 213,  -- Breastplate of the Lost Protector
        [40629] = 213,  -- Gauntlets of the Lost Protector
        [40632] = 213,  -- Crown of the Lost Protector
        [40635] = 213,  -- Legplates of the Lost Protector
        [40638] = 213,  -- Mantle of the Lost Protector
        --- WOTLK P2 ---
        [45637] = 225,  -- Chestguard of the Wayward Vanquisher
        [45649] = 225,  -- Helm of the Wayward Vanquisher
        [45646] = 225,  -- Gloves of the Wayward Vanquisher
        [45652] = 225,  -- Leggings of the Wayward Vanquisher
        [45661] = 225,  -- Spaulders of the Wayward Vanquisher
        [45645] = 225,  -- Gloves of the Wayward Protector
        [45648] = 225,  -- Helm of the Wayward Protector
        [45651] = 225,  -- Leggings of the Wayward Protector
        [45660] = 225,  -- Spaulders of the Wayward Protector
        [45636] = 225,  -- Chestguard of the Wayward Protector
        [45644] = 225,  -- Gloves of the Wayward Conqueror
        [45650] = 225,  -- Leggings of the Wayward Conqueror
        [45647] = 225,  -- Helm of the Wayward Conqueror
        [45659] = 225,  -- Spaulders of the Wayward Conqueror
        [45635] = 225,  -- Chestguard of the Wayward Conqueror
        [45634] = 232,  -- Breastplate of the Wayward Vanquisher
        [45643] = 232,  -- Gauntlets of the Wayward Vanquisher
        [45640] = 232,  -- Crown of the Wayward Vanquisher
        [45655] = 232,  -- Legplates of the Wayward Vanquisher
        [45658] = 232,  -- Mantle of the Wayward Vanquisher
        [45641] = 232,  -- Gauntlets of the Wayward Conqueror
        [45656] = 232,  -- Mantle of the Wayward Conqueror
        [45632] = 232,  -- Breastplate of the Wayward Conqueror
        [45653] = 232,  -- Legplates of the Wayward Conqueror
        [45638] = 232,  -- Crown of the Wayward Conqueror
        [45633] = 232,  -- Breastplate of the Wayward Protector
        [45642] = 232,  -- Gauntlets of the Wayward Protector
        [45639] = 232,  -- Crown of the Wayward Protector
        [45654] = 232,  -- Legplates of the Wayward Protector
        [45657] = 232,  -- Mantle of the Wayward Protector
        --- WOTLK P3 ---
        [47242] = 245,  -- Trophy of the Crusade
        [47557] = 258,  -- Regalia of the Grand Conqueror
        [47558] = 258,  -- Regalia of the Grand Protector
        [47559] = 258,  -- Regalia of the Grand Vanquisher
        --- WOTLK P4 ---
        [52025] = 264,  -- Vanquisher's Mark of Sanctification
        [52026] = 264,  -- Protector's Mark of Sanctification
        [52027] = 264,  -- Conqueror's Mark of Sanctification
        [52028] = 277,  -- Vanquisher's Mark of Sanctification (Heroic)
        [52029] = 277,  -- Protector's Mark of Sanctification (Heroic)
        [52030] = 277,  -- Conqueror's Mark of Sanctification (Heroic)
        --- SOD P3 ---
        [220636] = 55,  -- Atal'ai Blood Icon
        [220637] = 55,  -- Atal'ai Ritual Token
        -- SOD P4 -- 
        [227532] = 66,  -- Incandescent Hood
        [227537] = 66,  -- Incandescent Shoulderpads
        [227535] = 66,  -- Incandescent Robe
        [227534] = 66,  -- Incandescent Leggings
        [227531] = 66,  -- Incandescent Bindings
        [227536] = 66,  -- Incandescent Boots
        [227530] = 66,  -- Incandescent Belt
        [227533] = 66,  -- Incandescent Gloves
        [227764] = 66,  -- Scorched Core Helm
        [227762] = 66,  -- Scorched Core Shoulderpads
        [227766] = 66,  -- Scorched Core Chest
        [227763] = 66,  -- Scorched Core Leggings
        [227760] = 66,  -- Scorched Core Bindings
        [227765] = 66,  -- Scorched Core Boots
        [227761] = 66,  -- Scorched Core Belt
        [227759] = 66,  -- Scorched Core Gloves
        [227755] = 66,  -- Molten Scaled Helm
        [227752] = 66,  -- Molten Scaled Shoulderpads
        [227758] = 66,  -- Molten Scaled Chest
        [227754] = 66,  -- Molten Scaled Leggings
        [227750] = 66,  -- Molten Scaled Bindings
        [227757] = 66,  -- Molten Scaled Boots
        [227751] = 66,  -- Molten Scaled Belt
        [227756] = 66,  -- Molten Scaled Gloves
        --- Cataclysm P1 Normal ---
        [63682] = 359, -- Helm of the Forlorn Vanquisher
        [63684] = 359, -- Helm of the Forlorn Protector
        [63683] = 359, -- Helm of the Forlorn Conqueror
        [64314] = 359, -- Mantle of the Forlorn Vanquisher
        [64316] = 359, -- Mantle of the Forlorn Protector
        [64315] = 359, -- Mantle of the Forlorn Conqueror
        --- Cataclysm P1 Heroic ---
        [66998] = 372, -- Essence of the Forlorn
        [65002] = 372, -- Crown of the Forlorn Vanquisher
        [65000] = 372, -- Crown of the Forlorn Protector
        [65001] = 372, -- Crown of the Forlorn Conqueror
        [65089] = 372, -- Shoulders of the Forlorn Vanquisher
        [65087] = 372, -- Shoulders of the Forlorn Protector
        [65088] = 372, -- Shoulders of the Forlorn Conqueror
        [67426] = 372, -- Leggings of the Forlorn Vanquisher
        [67427] = 372, -- Leggings of the Forlorn Protector
        [67428] = 372, -- Leggings of the Forlorn Conqueror
        [67431] = 372, -- Gauntlets of the Forlorn Vanquisher
        [67430] = 372, -- Gauntlets of the Forlorn Protector
        [67429] = 372, -- Gauntlets of the Forlorn Conqueror
        [67425] = 372, -- Chest of the Forlorn Vanquisher
        [67424] = 372, -- Chest of the Forlorn Protector
        [67423] = 372, -- Chest of the Forlorn Conqueror
    }
}
CLM.IndirectMap = IndirectMap
