-- ------------------------------- --
local  _, CLM = ...
-- ------ CLM common cache ------- --
local LOG       = CLM.LOG
local CONSTANTS = CLM.CONSTANTS
local UTILS     = CLM.UTILS
-- ------------------------------- --

local setmetatable = setmetatable

local AuctionItem = CLM.MODELS.AuctionItem
local assertTypeof = UTILS.assertTypeof
local assertType = UTILS.assertType

local nickMap = {
    "Millhouse ",
    "Jenkins ",
    "Hemet ",
    "Mrgl-Mrgl "
}

local AuctionInfo = {} -- AuctionInfo
AuctionInfo.__index = AuctionInfo

local function assertNotInProgress(self)
    if self.state == CONSTANTS.AUCTION_INFO.STATE.IN_PROGRESS then
        error("Not allowed while auction is IN PROGRESS.", 2)
    end
end

local function assertInProgress(self)
    if self.state ~= CONSTANTS.AUCTION_INFO.STATE.IN_PROGRESS then
        error("Not allowed while auction is not IN PROGRESS.", 2)
    end
end

local function assertCantAddItems(self)
    if not self:CanAddItems() then
        error("Not allowed to add items in current state.", 2)
    end
end

function AuctionInfo:New(object)
    local o = {}
    object = object or {}
    setmetatable(o, self)

    o.state = object.state or CONSTANTS.AUCTION_INFO.STATE.NOT_CONFIGURED

    o.configuration = object.configuration
    o.roster = object.roster
    o.raid = object.raid

    o.items = {}
    o.itemCount = 0

    o.auctionTime = object.auctionTime or 0
    o.antiSnipe = object.antiSnipe or 0

    o.endTime = object.endTime or 0
    o.antiSnipeLimit = object.antiSnipeLimit or 0

    return o
end

local function _GetType(s)
    return s.auctionType
end
local function _GetMode(s)
    return s.mode
end
local function _GetUseOS(s)
    return s.useOS
end
local function _GetNamedButtonsMode(s)
    return s.namedButtons
end
local function _GetFieldName(s, tier)
    return s.fieldNames[tier] or ""
end
local function _GetIncrement(s)
    return s.increment
end

function AuctionInfo:NewShim(auctionType, mode, useOS, namedButtons, increment, fieldNames)
    local o = {}
    setmetatable(o, self)

    o.state = CONSTANTS.AUCTION_INFO.STATE.IDLE
    o.items = {}
    o.itemCount = 0

    o.auctionTime = 0
    o.antiSnipe = 0
    o.endTime = 0
    o.antiSnipeLimit =  0

    -- Remove unsupported
    o.UpdateRaid = nil
    o.UpdateRoster = nil
    o.GetAlwaysAllowBaseBids = nil
    o.GetAlwaysAllowAllInBids = nil
    o.GetAllowEqualBids = nil
    o.GetAllowCancelPass = nil
    o.GetTax = nil
    o.GetRounding = nil
    o.GetMinimumPoints = nil
    o.GetAllowBelowMinStandings = nil

    -- Overwrite new ones
    self.auctionType = auctionType
    self.mode = mode
    self.useOS = useOS
    self.namedButtons = namedButtons

    self.increment = increment
    self.fieldNames = UTILS.DeepCopy(fieldNames)

    o.GetType = _GetType
    o.GetMode = _GetMode
    o.GetUseOS = _GetUseOS
    o.GetNamedButtonsMode = _GetNamedButtonsMode
    o.GetFieldName = _GetFieldName
    o.GetIncrement = _GetIncrement

    return o
end

function AuctionInfo:CopySettings(object)
    assertTypeof(object, AuctionInfo)
    self.state = CONSTANTS.AUCTION_INFO.STATE.IDLE

    self.configuration = object.configuration
    self.roster = object.roster
    self.raid = object.raid

    self.auctionTime = object.auctionTime or 0
    self.antiSnipe = object.antiSnipe or 0

    if self.roster then
        for _,item in pairs(self.items) do
            item:LoadValues(self.roster)
        end
    end
end

local function UpdateConfigurableData(self)
    self.auctionTime = self.roster:GetConfiguration("auctionTime")
    self.antiSnipe = self.roster:GetConfiguration("antiSnipe")
end

local function UpdateConfigurationInternal(self)
    if self.raid then
        self.configuration = self.raid:Configuration()
    elseif self.roster then
        self.configuration = self.roster.configuration
    end
    if self.configuration then
        UpdateConfigurableData(self)
    end
end

local function UpdateRosterInternal(self, roster)
    self.roster = roster
end

local function UpdateRaidInternal(self, raid)
    self.raid = raid
end

function AuctionInfo:UpdateRoster(roster)
    assertTypeof(roster, CLM.MODELS.Roster)
    if self:IsInProgress() then
        LOG:Debug("AuctionInfo:UpdateRoster(): Called during auction. Ignoring.")
        return
    end

    UpdateRosterInternal(self, roster)
    UpdateRaidInternal(self, nil)
    UpdateConfigurationInternal(self)

    self.state = CONSTANTS.AUCTION_INFO.STATE.IDLE
end

-- Clears raid also
function AuctionInfo:UpdateRaid(raid)
    assertTypeof(raid, CLM.MODELS.Raid)
    if self:IsInProgress() then
        LOG:Debug("AuctionInfo:UpdateRaid(): Called during auction. Ignoring.")
        return
    end
    UpdateRaidInternal(self, raid)
    UpdateRosterInternal(self, raid:Roster())
    UpdateConfigurationInternal(self)

    self.state = CONSTANTS.AUCTION_INFO.STATE.IDLE
end

local function AddItemInternal(self, item)
    if self.items[item:GetItemID()] then
        LOG:Message("%s already in auction list.", item:GetItemLink())
        return
    end
    local auctionItem = AuctionItem:New(item)
    self.items[item:GetItemID()] = auctionItem
    self.itemCount = self.itemCount + 1
    return auctionItem
end

function AuctionInfo:AddItem(item)
    assertCantAddItems(self)
    local auctionItem = AddItemInternal(self, item)
    if auctionItem and self.roster then
        auctionItem:LoadValues(self.roster)
    end
    return auctionItem
end

function AuctionInfo:RemoveItem(id)
    assertNotInProgress(self)
    if self.items[id] then
        self.items[id] = nil
        self.itemCount = self.itemCount - 1
    end
end

function AuctionInfo:GetItem(id)
    return self.items[id]
end

function AuctionInfo:GetItems()
    return self.items
end

function AuctionInfo:SetResponse(id, username, response)
    assertInProgress(self)
    local auctionItem = self.items[id]
    if not auctionItem then
        LOG:Warning("Received response to non existent item.")
        return
    end
    auctionItem:SetResponse(username, response)
end

function AuctionInfo:IsInProgress()
    return self.state == CONSTANTS.AUCTION_INFO.STATE.IN_PROGRESS
end

function AuctionInfo:IsComplete()
    return self.state == CONSTANTS.AUCTION_INFO.STATE.COMPLETE
end

function AuctionInfo:CanAddItems()
    return CONSTANTS.AUCTION_INFO.STATES_ALLOW_ADDING_ITEMS[self.state]
end

function AuctionInfo:IsEmpty()
    return (self.itemCount <= 0)
end

function AuctionInfo:GetItemCount()
    return self.itemCount
end

function AuctionInfo:Start(endTime)
    assertNotInProgress(self)
    self.endTime = endTime and endTime or (GetServerTime() + self.auctionTime)
    self.state = CONSTANTS.AUCTION_INFO.STATE.IN_PROGRESS

    self.antiSnipeLimit = CONSTANTS.AUCTION_TYPES_OPEN[self:GetType()] and 100 or 3

    for _, item in pairs(self.items) do
        item:Clear()
    end

    self.anonymousMap = {}
    self.nextAnonymousId = 1
end

function AuctionInfo:End()
    assertInProgress(self)
    self.state = CONSTANTS.AUCTION_INFO.STATE.COMPLETE
end

-- Configuration API

function AuctionInfo:SetTime(time)
    assertType(time, 'number')
    assertNotInProgress(self)
    self.auctionTime = time
end

function AuctionInfo:GetTime()
    return self.auctionTime
end

function AuctionInfo:GetEndTime()
    return self.endTime
end

function AuctionInfo:SetAntiSnipe(time)
    assertType(time, 'number')
    assertNotInProgress(self)
    self.antiSnipe = time
end

function AuctionInfo:GetAntiSnipe()
    return self.antiSnipe
end

function AuctionInfo:AntiSnipe()
    self.antiSnipeLimit = self.antiSnipeLimit - 1
    self.endTime = self.endTime + self.antiSnipe
end

function AuctionInfo:IsAntiSnipeAvailable()
    return self.antiSnipeLimit > 0
end

function AuctionInfo:GetType()
    return self.configuration:Get("auctionType")
end

function AuctionInfo:GetMode()
    return self.configuration:Get("itemValueMode")
end

function AuctionInfo:GetUseOS()
    return self.configuration:Get("useOS")
end

function AuctionInfo:GetAlwaysAllowBaseBids()
    return self.configuration:Get("baseAlways")
end

function AuctionInfo:GetAlwaysAllowAllInBids()
    return self.configuration:Get("allInAlways")
end

function AuctionInfo:GetAllowEqualBids()
    return self.configuration:Get("allowEqualMax")
end

function AuctionInfo:GetAllowCancelPass()
    return self.configuration:Get("allowCancelPass")
end

function AuctionInfo:GetNamedButtonsMode()
    return self.configuration:Get("namedButtons")
end

function AuctionInfo:GetIncrement()
    return self.configuration:Get("minimalIncrement")
end

function AuctionInfo:GetTax()
    return self.configuration:Get("tax")
end

function AuctionInfo:GetRounding()
    return self.configuration:Get("roundDecimals")
end

function AuctionInfo:GetMinimumPoints()
    return self.configuration:Get("minimumPoints")
end

function AuctionInfo:GetAllowBelowMinStandings()
    return self.configuration:Get("allowBelowMinStandings")
end

function AuctionInfo:GetFieldName(tier)
    return self.roster:GetFieldName(tier)
end

function AuctionInfo:GetRoster()
    return self.roster
end

function AuctionInfo:GetRaid()
    return self.raid
end

function AuctionInfo:HasBids(itemId, username)
    local item = self.items[itemId]
    if item then
        return (item:GetResponse(username) ~= nil)
    end
    return false
end

function AuctionInfo:GetAnonymousName(name)
    if not self.anonymousMap[name] then
        self.anonymousMap[name] = nickMap[math.random(1,#nickMap)] .. tostring(self.nextAnonymousId)
        self.nextAnonymousId = self.nextAnonymousId + 1
    end
    return self.anonymousMap[name]
end

-----------------
--- CONSTANTS ---
-----------------
CONSTANTS.AUCTION_INFO = {
    STATE = {
        NOT_CONFIGURED = 0,
        IDLE = 1,
        IN_PROGRESS = 2,
        COMPLETE = 3
    }
}

CONSTANTS.AUCTION_INFO.STATES_ALLOW_ADDING_ITEMS = UTILS.Set({
    CONSTANTS.AUCTION_INFO.STATE.NOT_CONFIGURED,
    CONSTANTS.AUCTION_INFO.STATE.IDLE
})

CLM.MODELS.AuctionInfo = AuctionInfo