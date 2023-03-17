-- ------------------------------- --
local  _, CLM = ...
-- ------ CLM common cache ------- --
-- local LOG       = CLM.LOG
-- local CONSTANTS = CLM.CONSTANTS
local UTILS     = CLM.UTILS
-- ------------------------------- --

local PointInfo = {}
function PointInfo:New()
    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.rounding = 10

    -- Points spent on loot
    o.spent = 0
	-- Points spent on loot last raid
    o.spentLastRaid = 0
    -- Points received
    o.received = 0
    -- Pointes not received due to caps
    o.blocked = 0
    -- Points lost due to decay
    o.decayed = 0

    return o
end

function PointInfo:SetRounding(rounding)
    self.rounding = rounding
end

local function Add(self, param, value)
    self[param] = UTILS.round(self[param] + (value or 0), self.rounding) -- TODO rounding here!
end

local function Reset(self, param)
    self[param] = 0
end

function PointInfo:AddSpent(value)
    Add(self, "spent", value)
end

function PointInfo:AddSpentLastRaid(value)
	Add(self, "spentLastRaid", value)
end

function PointInfo:ResetLastRaid()
	Reset(self, "spentLastRaid")
end

function PointInfo:AddReceived(value)
    Add(self, "received", value)
end

function PointInfo:AddBlocked(value)
    Add(self, "blocked", value)
end

function PointInfo:AddDecayed(value)
    Add(self, "decayed", value)
end

CLM.MODELS.PointInfo = PointInfo
