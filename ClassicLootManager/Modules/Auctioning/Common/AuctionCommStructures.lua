-- ------------------------------- --
local  _, CLM = ...
-- ------ CLM common cache ------- --
-- local LOG       = CLM.LOG
local CONSTANTS = CLM.CONSTANTS
-- local UTILS     = CLM.UTILS
-- ------------------------------- --

local type, setmetatable = type, setmetatable
local tonumber = tonumber

-------------------------------
--- AuctionCommStartAuction ---
-------------------------------
local AuctionCommStartAuction = {}
AuctionCommStartAuction.__index = AuctionCommStartAuction

-- Empty or Copy constructor
function AuctionCommStartAuction:New(object)
    local o = (type(object) == "table") and object or {}
    setmetatable(o, self)

    return o
end

local function SerializeItems(items)
    local serialized = {}
    for id, auctionItem in pairs(items) do
        serialized[id] = {
            values = auctionItem:GetValues(),
            note = auctionItem:GetNote()
        }
    end
    return serialized
end

function AuctionCommStartAuction:NewFromAuctionInfo(auction)
    local o = {}
    setmetatable(o, self)

    o.e = auction:GetTime()
    o.d = auction:GetEndTime()
    o.s = auction:GetAntiSnipe()
    o.i = SerializeItems(auction:GetItems())

    return o
end

function AuctionCommStartAuction:Time()
    return tonumber(self.e) or 0
end

function AuctionCommStartAuction:EndTime()
    return tonumber(self.d) or 0
end

function AuctionCommStartAuction:AntiSnipe()
    return tonumber(self.s) or 0
end

function AuctionCommStartAuction:Items()
    return self.i or {}
end

--------------------------
--- AuctionCommDenyBid ---
--------------------------
local AuctionCommDenyBid = {}
function AuctionCommDenyBid:New(itemIdOrObject, reason)
    local isCopyConstructor = (type(itemIdOrObject) == "table")
    local o = isCopyConstructor and itemIdOrObject or {}

    setmetatable(o, self)
    self.__index = self

    if isCopyConstructor then return o end

    o.i = itemIdOrObject
    o.r = reason

    return o
end

function AuctionCommDenyBid:ItemId()
    return self.i or 0
end

function AuctionCommDenyBid:Reason()
    return self.r or 0
end

--------------------------------
--- AuctionCommDistributeBid ---
--------------------------------
local AuctionCommDistributeBid = {}
function AuctionCommDistributeBid:New(object)
    local isCopyConstructor = (type(object) == "table")

    local o = isCopyConstructor and object or {}

    setmetatable(o, self)
    self.__index = self

    if isCopyConstructor then return o end

    o.d = object

    return o
end

function AuctionCommDistributeBid:NewFromAggregatedData(data)
    local o = {}
    setmetatable(o, self)

    o.d = data

    return o
end

function AuctionCommDistributeBid:Data()
    return self.d or {}
end

local AuctionCommStructure = {}
function AuctionCommStructure:New(typeOrObject, data)
    local isCopyConstructor = (type(typeOrObject) == "table")

    local o = isCopyConstructor and typeOrObject or {}

    setmetatable(o, self)
    self.__index = self

    if isCopyConstructor then
        if o.t == CONSTANTS.AUCTION_COMM.TYPE.START_AUCTION then
            o.d = AuctionCommStartAuction:New(o.d)
        elseif o.t == CONSTANTS.AUCTION_COMM.TYPE.DENY_BID then
            o.d = AuctionCommDenyBid:New(o.d)
        elseif o.t == CONSTANTS.AUCTION_COMM.TYPE.DISTRIBUTE_BID then
            o.d = AuctionCommDistributeBid:New(o.d)
        end
        return o
    end

    o.t = tonumber(typeOrObject) or 0
    o.d = data

    return o
end

function AuctionCommStructure:Type()
    return self.t or 0
end

function AuctionCommStructure:Data()
    return self.d
end

CLM.MODELS.AuctionCommStructure = AuctionCommStructure
CLM.MODELS.AuctionCommStartAuction = AuctionCommStartAuction
CLM.MODELS.AuctionCommDenyBid = AuctionCommDenyBid
CLM.MODELS.AuctionCommDistributeBid = AuctionCommDistributeBid