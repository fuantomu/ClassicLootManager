-- ------------------------------- --
local  _, CLM = ...
-- ------ CLM common cache ------- --
local LOG       = CLM.LOG
local CONSTANTS = CLM.CONSTANTS
local UTILS     = CLM.UTILS
-- ------------------------------- --

local colorTurquoise = {r = 0.2, g = 0.93, b = 0.93, a = 1.0}
local colorGreen = {r = 0.2, g = 0.93, b = 0.2, a = 1.0}
local colorGold = {a = 1, r = 1, g = 0.8, b = 0}

CONSTANTS.HISTORY_TYPE = {
    ALL = 1,
    LOOT = 2,
    POINT = 3
}

CONSTANTS.HISTORY_TYPES_GUI = {
    [CONSTANTS.HISTORY_TYPE.ALL] = CLM.L["All"],
    [CONSTANTS.HISTORY_TYPE.LOOT] = CLM.L["Loot"],
    [CONSTANTS.HISTORY_TYPE.POINT] = CLM.L["Point"]
}

local function ST_GetInfo(row)
    return row.cols[2].value
end

local function ST_GetValue(row)
    return row.cols[3].value
end

local function ST_GetDate(row)
    return row.cols[4].value
end

local function ST_GetPlayer(row)
    return row.cols[5].value
end

local function ST_GetIsLoot(row)
    return row.cols[6].value
end

local function ST_GetObject(row)
    return row.cols[7].value
end


local function refreshFn(...)
    CLM.GUI.Unified:Refresh(...)
end

local tooltipPool = CreateObjectPool(function(pool)
    if not pool.nextId then
        pool.nextId = 0
    end
    pool.nextId = pool.nextId + 1
    return CreateFrame("GameTooltip", "CLMHistoryTT" .. tostring(pool.nextId), UIParent, "GameTooltipTemplate")
end, function(_, frame) frame:Hide() end)

local UnifiedGUI_History = {
    name = "history",
    filter = CLM.MODELS.Filters:New(
    refreshFn,
    {},
    UTILS.Set({
        "search", "horizontal"
    }),
    nil, 3),
    -- tooltip = CreateFrame("GameTooltip", "CLMUnifiedGUIHistoryDialogTooltip", UIParent, "GameTooltipTemplate"),
    tooltip = GameTooltip,
    historyType = CONSTANTS.HISTORY_TYPE.ALL
}

function UnifiedGUI_History:GetSelection()
    LOG:Trace("UnifiedGUI_History:GetSelection()")
    local st = CLM.GUI.Unified:GetScrollingTable()
    local lootList, historyList = {}, {}
    -- Profiles
    local selected = st:GetSelection()
    if #selected == 0 then -- nothing selected: assume all visible are selected
        return {}, {}
    end
    for _,s in pairs(selected) do
        local row = st:GetRow(s)
        if ST_GetIsLoot(row) == true then
            lootList[#lootList+1] = ST_GetObject(row)
        elseif ST_GetIsLoot(row) == false then
            historyList[#historyList+1] = ST_GetObject(row)
        end
    end
    return lootList, historyList
end

local function GenerateUntrustedOptions(self)
    local options = {}
    local roster = CLM.MODULES.RosterManager:GetRosterByUid(self.roster)
    if not roster then return {} end
    local profiles = roster:Profiles()
    local profileNameMap = { [CLM.L["-- All --"]] = CLM.L["-- All --"]}
    local profileList = {CLM.L["-- All --"]}
    for _, GUID in ipairs(profiles) do
        local profile = CLM.MODULES.ProfileManager:GetProfileByGUID(GUID)
        if profile then
            profileNameMap[profile:Name()] = profile:ShortName()
            profileList[#profileList + 1] = profile:Name()
        end
    end
    table.sort(profileList)

    options.roster = {
        name = CLM.L["Roster"],
        type = "select",
        values = CLM.MODULES.RosterManager:GetRostersUidMap(),
        set = function(i, v)
            self.roster = v
            refreshFn()
        end,
        get = function(i) return self.roster end,
        order = 0
    }
    options.player = {
        name = CLM.L["Player"],
        type = "select",
        values = profileNameMap,
        sorting = profileList,
        set = function(i, v)
            self.profile = v
            refreshFn()
        end,
        get = function(i) return self.profile end,
        order = 1
    }
    options.history = {
        name = CLM.L["History type"],
        type = "select",
        values = CONSTANTS.HISTORY_TYPES_GUI,
        set = function(i, v)
            self.historyType = v
            refreshFn()
        end,
        get = function(i) return self.historyType end,
        width = 0.75,
        order = 4
    }
    UTILS.mergeDictsInline(options, self.filter:GetAceOptions())
    return options
end

local function horizontalOptionsFeeder()
    local options = {
        type = "group",
        args = { }
    }
    UTILS.mergeDictsInline(options.args, GenerateUntrustedOptions(UnifiedGUI_History))
    return options
end

local function buildLootTooltip(tooltip, loot, itemLink, detailsMode)
    -- local itemId = UTILS.GetItemIdFromLink(itemLink)
    -- local itemString = "item:" .. tostring(itemId)
    tooltip:SetHyperlink(itemLink)
    if loot then
        local profile = CLM.MODULES.ProfileManager:GetProfileByGUID(UTILS.getGuidFromInteger(loot:Creator()))
        local name
        if profile then
            name = UTILS.ColorCodeText(profile:ShortName(), UTILS.GetClassColor(profile:Class()).hex)
        else
            name = CLM.L["Unknown"]
        end
        local raid = CLM.MODULES.RaidManager:GetRaidByUid(loot:RaidUid())
        if raid then
            tooltip:AddLine(raid:Name())
        end
        tooltip:AddDoubleLine(CLM.L["Awarded by"], name)
        local auction = CLM.MODULES.AuctionHistoryManager:GetByUUID(loot:Entry():uuid())
        if detailsMode and auction then
            tooltip:AddLine("\n")
            for bidder, bid in pairs(auction.bids) do
                local names = auction.names or {}
                local rolls = auction.rolls or {}
                bid  = tostring(bid)
                if rolls[bidder] then
                    bid  = bid .. "/" .. tostring(rolls[bidder])
                end
                if names[bidder] then
                    bid = bid .. " (" .. names[bidder] .. ")"
                end
                local bidderProfile = CLM.MODULES.ProfileManager:GetProfileByName(bidder)
                if bidderProfile then
                    bidder = UTILS.ColorCodeText(bidder, UTILS.GetClassColor(bidderProfile:Class()).hex)
                end

                tooltip:AddDoubleLine(bidder, bid)
            end
            if detailsMode then
                local upgraded = auction.upgraded or {}
                local previousUpgradeTooltip
                for _, it in ipairs(upgraded[loot:Owner():Name()] or {}) do
                    local upgradeTooltip = tooltipPool:Acquire()
                    if previousUpgradeTooltip then
                        upgradeTooltip:SetOwner(previousUpgradeTooltip, "ANCHOR_NONE")
                        upgradeTooltip:ClearAllPoints()
                        upgradeTooltip:SetPoint("TOPLEFT", previousUpgradeTooltip, "BOTTOMLEFT")
                    else
                        upgradeTooltip:SetOwner(tooltip, "ANCHOR_RIGHT")
                    end
                    upgradeTooltip:SetHyperlink("item:" .. tostring(it))
                    upgradeTooltip:Show()
                    previousUpgradeTooltip = upgradeTooltip
                end
            end
        end
    end
end

local function buildPointTooltip(tooltip, history)
    local profiles = history:Profiles()
    local numProfiles = #profiles
    tooltip:AddDoubleLine(CLM.L["Affected players:"], tostring(numProfiles))
    if not profiles or numProfiles == 0 then
        tooltip:AddLine(CLM.L["None"])
    else
        UTILS.buildPlayerListForTooltip(profiles, tooltip)
    end
    local note = history:Note()
    if note ~= "" then
        local numNote = tonumber(note)
        if numNote then
            note = CLM.EncounterIDsMap[numNote] or note
        end
        tooltip:AddDoubleLine(CLM.L["Note"] .. "", note)
    end
    local profile = CLM.MODULES.ProfileManager:GetProfileByGUID(UTILS.getGuidFromInteger(history:Creator()))
    local name
    if profile then
        name = UTILS.ColorCodeText(profile:ShortName(), UTILS.GetClassColor(profile:Class()).hex)
    else
        name = CLM.L["Unknown"]
    end
    tooltip:AddDoubleLine(CLM.L["Awarded by"], name)
end

local tableStructure = {
    rows = 22,
    -- columns - structure of the ScrollingTable
    columns = {
        {name = "", width = 18, DoCellUpdate = (function(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
            if data[realrow] then
                local itemData = data[realrow].cols[column].value
                local isLoot = ST_GetIsLoot(data[realrow])
                if isLoot and itemData then
                    local _, _, _, _, icon = UTILS.GetItemInfoInstant(itemData)
                    frame:SetNormalTexture(icon)
                else
                    frame:SetNormalTexture("Interface\\Icons\\INV_Misc_Head_Dragon_Bronze")
                end
            end
        end)},
        {name = CLM.L["Info"],  width = 217 },
        {name = CLM.L["Value"], width = 85, color = colorGreen,
            comparesort = UTILS.LibStCompareSortWrapper(function(a1,b1)
                a1 = strsplit(" ", a1)
                a1 = string.gsub(a1, "%%", "")
                b1 = strsplit(" ", b1)
                b1 = string.gsub(b1, "%%", "")
                return (tonumber(a1) or 0), (tonumber(b1) or 0)
            end),
        },
        {name = CLM.L["Date"],  width = 205, sort = LibStub("ScrollingTable").SORT_DSC},
        {name = CLM.L["Player"],width = 95,
            comparesort = UTILS.LibStCompareSortWrapper(UTILS.LibStModifierFn), DoCellUpdate = UTILS.LibStNameCellUpdate
        }
    },
    -- Function to filter ScrollingTable
    filter = (function(_, row)
        return UnifiedGUI_History.filter:Filter("", "", {ST_GetInfo(row)})
    end),
    -- Events to override for ScrollingTable
    events = {
        -- OnEnter handler -> on hover
        OnEnter = (function (rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
            local status = table.DefaultEvents["OnEnter"](rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
            local rowData = table:GetRow(realrow)
            if not rowData or not rowData.cols then return status end
            local tooltip = UnifiedGUI_History.tooltip
            if not tooltip then return end
            local detailsMode = IsControlKeyDown()

            if detailsMode then
                tooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            else
                tooltip:SetOwner(rowFrame, "ANCHOR_RIGHT")
            end

            if ST_GetIsLoot(rowData) == true then
                buildLootTooltip(tooltip, ST_GetObject(rowData), ST_GetInfo(rowData) or "", detailsMode)
            elseif ST_GetIsLoot(rowData) == false then
                buildPointTooltip(tooltip, ST_GetObject(rowData))
            else
                return status
            end
            -- ------------------------------ --
            -- Display
            tooltip:Show()
            return status
        end),
        -- OnLeave handler -> on hover out
        OnLeave = (function (rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
            local status = table.DefaultEvents["OnLeave"](rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
            UnifiedGUI_History.tooltip:Hide()
            tooltipPool:ReleaseAll()
            return status
        end),
        -- OnClick handler -> click
        OnClick = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
            UTILS.LibStSingleSelectClickHandler(table, UnifiedGUI_History.RightClickMenu, rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
            if IsModifiedClick() then
                local rowData = table:GetRow(realrow)
                if rowData and rowData.cols then
                    local message = (ST_GetInfo(rowData) or "") .. " - " .. (ST_GetValue(rowData) or "") .. " - " .. (ST_GetDate(rowData) or "") .. " - " .. (ST_GetPlayer(rowData) or "")
                    HandleModifiedItemClick(message)
                end
            end
            return true
        end
    }
}

local function fillLootList(displayedLoot, loot)
    if UTILS.GetItemInfoInstant(loot:Id()) then
        local _, itemLink = UTILS.GetItemInfo(loot:String())
        if not itemLink then
            UnifiedGUI_History.pendingLoot = true
        elseif not UnifiedGUI_History.pendingLoot then -- dont populate if we will be skipping it anyway - not displaying partially atm
            local owner = loot:Owner()
            displayedLoot[#displayedLoot+1] = {loot, UTILS.SpoofLink(itemLink, loot:Extra()), owner:Name(), UTILS.GetClassColor(owner:Class())}
        end
    end
end

local function tableDataFeeder()
    LOG:Trace("UnifiedGUI_History tableDataFeeder()")
    local data = {}

    local roster = CLM.MODULES.RosterManager:GetRosterByUid(UnifiedGUI_History.roster)
    if not roster then return {} end

    local isEPGP = (roster:GetPointType() == CONSTANTS.POINT_TYPE.EPGP)
    -- TODO: Change from loot type and profile name to filter as its faster
    local profile = CLM.MODULES.ProfileManager:GetProfileByName(UnifiedGUI_History.profile or "")
    if UnifiedGUI_History.historyType ~= CONSTANTS.HISTORY_TYPE.POINT then
        local isProfileLoot = (profile and roster:IsProfileInRoster(profile:GUID()))
        local lootList
        local disenchantedList
        -- player loot
        if isProfileLoot then
            lootList = roster:GetProfileLootByGUID(profile:GUID())
            disenchantedList = {}
        else -- raid loot
            lootList = roster:GetRaidLoot()
            disenchantedList = roster:GetDisenchantedLoot()
        end

        local displayedLoot, displayedDe = {}, {}
        UnifiedGUI_History.pendingLoot = false

        for _,loot in ipairs(lootList) do
            fillLootList(displayedLoot, loot)
        end

        for _,loot in ipairs(disenchantedList) do
            fillLootList(displayedDe, loot)
        end

        if UnifiedGUI_History.pendingLoot then
            return {{cols = { {value = ""}, {value = ""}, {value = CLM.L["Loading..."]}, {value = ""}, {value = nil}, {value = nil} }}}
        end

        for _,lootData in ipairs(displayedLoot) do
            local loot = lootData[1]
            local value = tostring(loot:Value())
            if isEPGP then
                value = (value) .. " " .. CLM.L["GP"]
            -- else
                -- value = (value) .. " " .. CLM.L["DKP"]
            end
            local row = {cols = {
                {value = lootData[2]},
                {value = lootData[2]}, -- itemLink
                {value = value},
                {value = date(CLM.L["%Y/%m/%d %H:%M:%S (%A)"], loot:Timestamp())},
                {value = lootData[3], color = lootData[4]}, -- owner
                -- Not visible
                {value = true}, -- is Loot
                {value = loot} -- Loot Object
            }}
            data[#data + 1] =  row
        end

        for _,lootData in ipairs(displayedDe) do
            local loot = lootData[1]
            local row = {cols = {
                {value = lootData[2]},
                {value = lootData[2]}, -- itemLink
                {value = ""},
                {value = date(CLM.L["%Y/%m/%d %H:%M:%S (%A)"], loot:Timestamp())},
                {value = lootData[3], color = lootData[4]}, -- owner
                -- Not visible
                {value = true}, -- is Loot
                {value = loot} -- Loot Object
            }}
            data[#data + 1] =  row
        end
    end

    if UnifiedGUI_History.historyType ~= CONSTANTS.HISTORY_TYPE.LOOT then
        local isProfileHistory = (profile and roster:IsProfileInRoster(profile:GUID()))

        local pointList
        -- player loot
        if isProfileHistory then
            pointList = roster:GetProfilePointHistoryByGUID(profile:GUID())
        else -- raid loot
            pointList = roster:GetRaidPointHistory()
        end
        local player
        for _,history in ipairs(pointList) do
            local reason = history:Reason() or 0
            local value = tostring(history:Value())
            if reason == CONSTANTS.POINT_CHANGE_REASON.DECAY then
                value = value .. "%"
            end
            local suffix = UTILS.DecodePointTypeChangeName(roster:GetPointType(), history:Type())
            value = value .. " " .. suffix
            local color
            local profiles = history:Profiles()
            if #profiles == 1 then
                local currentProfile = profiles[1]
                player = currentProfile:Name()
                color = UTILS.GetClassColor(currentProfile:Class())
            else
                player = CLM.L["Multiple"]
                color = colorGold
            end

            local row = {cols = {
                {value = ""},
                {value = CONSTANTS.POINT_CHANGE_REASONS.ALL[reason] or ""},
                {value = value,
                    color = ((isEPGP and (history:Type() == CONSTANTS.POINT_CHANGE_TYPE.SPENT)) and colorTurquoise)
                },
                {value = date(CLM.L["%Y/%m/%d %H:%M:%S (%A)"], history:Timestamp())},
                {value = player, color = color},
                {value = false},
                {value = history}
            }}
            data[#data + 1] =  row
        end
    end
    return data
end

local function initializeHandler()
    LOG:Trace("UnifiedGUI_History initializeHandler()")
    UnifiedGUI_History.RightClickMenu = CLM.UTILS.GenerateDropDownMenu(
        {
            {
                title = CLM.L["Remove selected"],
                func = (function()
                    local selectedLoot, selectedHistory = UnifiedGUI_History:GetSelection()
                    for _, loot in pairs(selectedLoot) do
                        CLM.MODULES.LedgerManager:Remove(loot:Entry())
                        CLM.MODULES.EventManager:DispatchEvent(CONSTANTS.EVENTS.GLOBAL_LOOT_REMOVED, {
                            id = loot:Id(), name = loot:Owner():Name()
                        }, loot:Timestamp() + 7200) -- only up to 2 hours after loot is created
                    end
                    for _, history in pairs(selectedHistory) do
                        CLM.MODULES.LedgerManager:Remove(history:Entry())
                    end
                    CLM.GUI.Unified:ClearSelection()
                end),
                trustedOnly = true,
                color = "cc0000"
            }
        },
        CLM.MODULES.ACL:CheckLevel(CONSTANTS.ACL.LEVEL.ASSISTANT),
        CLM.MODULES.ACL:CheckLevel(CONSTANTS.ACL.LEVEL.MANAGER)
    )
end

-- local function refreshHandler()
-- end

-- local function beforeShowHandler()
-- end

local function storeHandler()
    LOG:Trace("UnifiedGUI_History storeHandler()")
    local storage = CLM.GUI.Unified:GetStorage(UnifiedGUI_History.name)
    storage.roster = UnifiedGUI_History.roster
end

local function restoreHandler()
    LOG:Trace("UnifiedGUI_History restoreHandler()")
    local storage = CLM.GUI.Unified:GetStorage(UnifiedGUI_History.name)
    UnifiedGUI_History.roster = storage.roster
end

local function dataReadyHandler()
    LOG:Trace("UnifiedGUI_History dataReadyHandler()")
    if not CLM.MODULES.RosterManager:GetRosterByUid(UnifiedGUI_History.roster) then
        local _, roster = next(CLM.MODULES.RosterManager:GetRosters())
        if roster then
            UnifiedGUI_History.roster = roster:UID()
        end
    end
end

-- CONSTANTS.HISTORY_TYPES = UTILS.Set({
--     CONSTANTS.HISTORY_TYPE.ALL,
--     CONSTANTS.HISTORY_TYPE.LOOT,
--     CONSTANTS.HISTORY_TYPE.POINT
-- })

CLM.GUI.Unified:RegisterTab(
    UnifiedGUI_History.name, 2,
    tableStructure,
    tableDataFeeder,
    horizontalOptionsFeeder,
    nil,
    {
        initialize = initializeHandler,
        -- refresh = refreshHandler,
        -- beforeShow = beforeShowHandler,
        store = storeHandler,
        restore = restoreHandler,
        dataReady = dataReadyHandler
    },
    "Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up.blp"
)
