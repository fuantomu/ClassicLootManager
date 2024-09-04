local _, CLM = ...

if not CLM.WoWSoD then return end
-- Append to existing ones
CLM.EncounterIDsMap[2694] = CLM.L["Baron Aquanis"]
CLM.EncounterIDsMap[2697] = CLM.L["Ghamoo-ra"]
CLM.EncounterIDsMap[2699] = CLM.L["Lady Sarevess"]
CLM.EncounterIDsMap[2704] = CLM.L["Gelihast"]
CLM.EncounterIDsMap[2710] = CLM.L["Lorgus Jett"]
CLM.EncounterIDsMap[2825] = CLM.L["Twilight Lord Kelris"]
CLM.EncounterIDsMap[2891] = CLM.L["Aku'mai"]
-- Gnomeregan
CLM.EncounterIDsMap[2925] = CLM.L["Grubbis"]
CLM.EncounterIDsMap[2928] = CLM.L["Viscous Fallout"]
CLM.EncounterIDsMap[2927] = CLM.L["Electrocutioner 6000"]
CLM.EncounterIDsMap[2899] = CLM.L["Crowd Pummeler 9-60"]
CLM.EncounterIDsMap[2935] = CLM.L["Mechanical Menagerie"]
CLM.EncounterIDsMap[2940] = CLM.L["Mekgineer Thermaplugg"]
-- Sunken Temple
CLM.EncounterIDsMap[2952] = CLM.L["Atal'alarion"]
CLM.EncounterIDsMap[2953] = CLM.L["Festering Rotslime"]
CLM.EncounterIDsMap[2955] = CLM.L["Dreamscythe and Weaver"]
CLM.EncounterIDsMap[2954] = CLM.L["Atal'ai Defenders"]
CLM.EncounterIDsMap[2957] = CLM.L["Jammal'an and Ogom"]
CLM.EncounterIDsMap[2958] = CLM.L["Morphaz and Hazzas"]
CLM.EncounterIDsMap[2959] = CLM.L["Shade of Eranikus"]
CLM.EncounterIDsMap[2956] = CLM.L["Avatar of Hakkar"]
-- Molten Core
CLM.EncounterIDsMap[3018] = CLM.L["Molten Core"]
-- World Bosses
CLM.EncounterIDsMap[3027] = CLM.L["Azuregos"]
CLM.EncounterIDsMap[3026] = CLM.L["Lord Kazzak"]
CLM.EncounterIDs.SoD = {
    {
        name = CLM.L["Blackfathom Deeps"],
        difficulty = {3},
        data = {
            { id = 2694, name = CLM.EncounterIDsMap[2694] },
            { id = 2697, name = CLM.EncounterIDsMap[2697] },
            { id = 2699, name = CLM.EncounterIDsMap[2699] },
            { id = 2704, name = CLM.EncounterIDsMap[2704] },
            { id = 2710, name = CLM.EncounterIDsMap[2710] },
            { id = 2825, name = CLM.EncounterIDsMap[2825] },
            { id = 2891, name = CLM.EncounterIDsMap[2891] },
        }
    },
    {
        name = CLM.L["Gnomeregan"],
        difficulty = {3},
        data = {
            { id = 2925, name = CLM.EncounterIDsMap[2925] },
            { id = 2928, name = CLM.EncounterIDsMap[2928] },
            { id = 2927, name = CLM.EncounterIDsMap[2927] },
            { id = 2899, name = CLM.EncounterIDsMap[2899] },
            { id = 2935, name = CLM.EncounterIDsMap[2935] },
            { id = 2940, name = CLM.EncounterIDsMap[2940] },
        }
    },
    {
        name = CLM.L["Sunken Temple"],
        difficulty = {148},
        data = {
            { id = 2952, name = CLM.EncounterIDsMap[2952] },
            { id = 2953, name = CLM.EncounterIDsMap[2953] },
            { id = 2955, name = CLM.EncounterIDsMap[2955] },
            { id = 2954, name = CLM.EncounterIDsMap[2954] },
            { id = 2957, name = CLM.EncounterIDsMap[2957] },
            { id = 2958, name = CLM.EncounterIDsMap[2958] },
            { id = 2959, name = CLM.EncounterIDsMap[2959] },
            { id = 2956, name = CLM.EncounterIDsMap[2956] },
        }
    },
    {
        name = CLM.L["Zul'Gurub"],
        difficulty = {148},
        data = {
            { id = 789, name = CLM.EncounterIDsMap[789] },
            { id = 784, name = CLM.EncounterIDsMap[784] },
            { id = 791, name = CLM.EncounterIDsMap[791] },
            { id = 785, name = CLM.EncounterIDsMap[785] },
            { id = 786, name = CLM.EncounterIDsMap[786] },
            { id = 787, name = CLM.EncounterIDsMap[787] },
            { id = 792, name = CLM.EncounterIDsMap[792] },
            { id = 793, name = CLM.EncounterIDsMap[793] },
            { id = 788, name = CLM.EncounterIDsMap[788] },
            { id = 790, name = CLM.EncounterIDsMap[790] },
        },
    },
    {
        name = CLM.L["Molten Core"],
        difficulty = {148},
        data = {
            { id = 663, name = CLM.EncounterIDsMap[663] },
            { id = 664, name = CLM.EncounterIDsMap[664] },
            { id = 665, name = CLM.EncounterIDsMap[665] },
            { id = 666, name = CLM.EncounterIDsMap[666] },
            { id = 668, name = CLM.EncounterIDsMap[668] },
            { id = 667, name = CLM.EncounterIDsMap[667] },
            { id = 669, name = CLM.EncounterIDsMap[669] },
            { id = 670, name = CLM.EncounterIDsMap[670] },
            { id = 671, name = CLM.EncounterIDsMap[671] },
            { id = 672, name = CLM.EncounterIDsMap[672] },
            { id = 3018, name = CLM.EncounterIDsMap[3018] },
        },
    },
    {
        name = CLM.L["World Bosses"],
        difficulty = {0},
        data = {
            { id = 3027, name = CLM.EncounterIDsMap[3027] },
            { id = 3026, name = CLM.EncounterIDsMap[3026] },
        }
    }
}