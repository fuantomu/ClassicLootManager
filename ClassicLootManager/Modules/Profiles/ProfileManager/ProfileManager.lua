-- ------------------------------- --
local  _, CLM = ...
-- ------ CLM common cache ------- --
local LOG       = CLM.LOG
local CONSTANTS = CLM.CONSTANTS
local UTILS     = CLM.UTILS
-- ------------------------------- --

local whoamiGUID = UTILS.whoamiGUID()

local notEmptyiGUID
if CLM.WoW10 or CLM.WoWSeasonal or CLM.WoWCata then
    notEmptyiGUID = function(iGUID)
        return iGUID[2] ~= 0
    end
else
    notEmptyiGUID = function(iGUID)
        return iGUID ~= 0
    end
end

local ProfileManager = {}
function ProfileManager:Initialize()
    LOG:Trace("ProfileManager:Initialize()")

    self._deProfile = CLM.MODELS.Profile:New(nil, CLM.L["Disenchanted"])

    self.cache = {
        profilesGuidMap = {},
        profiles = {}
    }

    self.db = CLM.MODULES.Database:Personal('profileManager', {
        pruneLog = {}
    })

    -- Register mutators
    CLM.MODULES.LedgerManager:RegisterEntryType(
        CLM.MODELS.LEDGER.PROFILE.Update,
        (function(entry)
            LOG:TraceAndCount("mutator(ProfileUpdate)")
            local iGUID = entry:GUID()
            if not UTILS.ValidateIntegerGUID(iGUID) then return end
            if not notEmptyiGUID(iGUID) then return end
            local GUID = UTILS.getGuidFromInteger(iGUID)
            local name = entry:name()
            if UTILS.empty(name) then return end

            local class = UTILS.NumberToClass(entry:ingameClass()) or ""
            local main = entry:main()
            main = (UTILS.ValidateIntegerGUID(main) and notEmptyiGUID(main)) and UTILS.getGuidFromInteger(main) or ""
            -- Check if it's an update
            local profileInternal = self.cache.profiles[GUID]
            if profileInternal then
                if UTILS.empty(class) then
                    class = profileInternal:Class()
                end
                if UTILS.empty(main) then
                    main = profileInternal:Main()
                end
                profileInternal.class = class
                profileInternal.main = main
                -- Renam:
                -- Remove old map
                self.cache.profilesGuidMap[strlower(profileInternal.name)] = nil
                -- set new name
                profileInternal.name = name
                self.cache.profilesGuidMap[strlower(name)] = GUID
            else
                -- If profile with this name already exists we need to remove it
                -- before updating guid map
                local oldProfile = self:GetProfileByName(name)
                if oldProfile then
                    self.cache.profiles[oldProfile:GUID()] = nil
                end
                -- New mapping
                local profile = CLM.MODELS.Profile:New(entry, name, class, main)
                profile:SetGUID(GUID)
                self.cache.profiles[GUID] = profile
                self.cache.profilesGuidMap[strlower(name)] = GUID
                -- Check for conditional restore
                local rosters = CLM.MODULES.RosterManager:GetRosters()
                for _, roster in pairs(rosters) do
                    if roster:IsConditionallyRemoved(GUID) then
                        roster:RestoreConditionallyRemoved(GUID)
                    end
                end
            end
        end))

    CLM.MODULES.LedgerManager:RegisterEntryType(
        CLM.MODELS.LEDGER.PROFILE.Remove,
        (function(entry)
            LOG:TraceAndCount("mutator(ProfileRemove)")
            local GUID = entry:GUID()
            if not UTILS.ValidateIntegerGUID(GUID) then return end
            GUID = UTILS.getGuidFromInteger(GUID)
            local profile = self.cache.profiles[GUID]
            if profile then
                -- Check alt-main linking before removing
                if profile:HasAlts() then
                    for altGUID in pairs(profile:Alts()) do
                        local altProfile = self:GetProfileByGUID(altGUID)
                        if altProfile then
                            altProfile:SetMain("")
                        end
                    end
                elseif (profile:Main() ~= "") then
                    local mainProfile = self:GetProfileByGUID(profile:Main())
                    if mainProfile then
                        mainProfile:RemoveAlt(GUID)
                    end
                end
                -- Remove
                self.cache.profiles[GUID] = nil
                self.cache.profilesGuidMap[strlower(profile:Name())] = nil
                -- Conditonally remove for backwards compatibility
                local rosters = CLM.MODULES.RosterManager:GetRosters()
                for _, roster in pairs(rosters) do
                    if roster:IsProfileInRoster(GUID) then
                        roster:MarkAsConditionallyRemoved(GUID)
                    end
                end
            end
        end))

    CLM.MODULES.LedgerManager:RegisterEntryType(
        CLM.MODELS.LEDGER.PROFILE.Link,
        (function(entry)
            LOG:TraceAndCount("mutator(ProfileLink)")
            local altGUID = entry:GUID()
            if not UTILS.ValidateIntegerGUID(altGUID) then return end
            altGUID = UTILS.getGuidFromInteger(altGUID)
            local mainGUID = entry:main()
            if not UTILS.ValidateIntegerGUID(mainGUID) then return end
            if altGUID == mainGUID then return end
            mainGUID = UTILS.getGuidFromInteger(mainGUID)
            local altProfile = self:GetProfileByGUID(altGUID)
            if not UTILS.typeof(altProfile, CLM.MODELS.Profile) then return end
            local mainProfile = self:GetProfileByGUID(mainGUID)
            if not UTILS.typeof(mainProfile, CLM.MODELS.Profile) then -- Unlink
                -- Check if our main exists
                local currentMainProfile = self:GetProfileByGUID(altProfile:Main())
                if not UTILS.typeof(currentMainProfile, CLM.MODELS.Profile) then return end
                -- Remove main from this alt
                altProfile:ClearMain()
                -- Remove alt count from main
                currentMainProfile:RemoveAlt(altGUID)
            else -- Link
                -- Sanity check if not setting existing one
                if altProfile:Main() == mainProfile:GUID() then return end
                -- Do not allow alt chaining if main is alt
                if UTILS.typeof(self:GetProfileByGUID(mainProfile:Main()), CLM.MODELS.Profile) then return end
                -- Do not allow alt chaining if alt has alts
                if altProfile:HasAlts() then return end
                -- Unlink old main
                local currentMainProfile = self:GetProfileByGUID(altProfile:Main())
                if UTILS.typeof(currentMainProfile, CLM.MODELS.Profile) then
                    -- Remove main from this alt
                    altProfile:ClearMain()
                    -- Remove alt count from main
                    currentMainProfile:RemoveAlt(altGUID)
                end
                -- Set new main of this alt
                altProfile:SetMain(mainGUID)
                -- Add alt to our main
                mainProfile:AddAlt(altGUID)
                -- Handle consequences of linking:
                -- For each roster this alt is present in:
                local rosters = CLM.MODULES.RosterManager:GetRosters()
                for _,roster in pairs(rosters) do
                    if roster:IsProfileInRoster(altGUID) then
                        -- 1) Add main if not present in roster
                        roster:AddProfileByGUID(mainGUID)
                        -- 2) Sum points of the pool and new alt
                        local pointSum = roster:Standings(mainGUID) + roster:Standings(altGUID)
                        -- 3) Set new Main standings
                        roster:SetStandings(mainGUID, pointSum)
                        -- 2a) Sum spent points of the pool and new alt
                        local spentSum = roster:GetPointInfoForPlayer(mainGUID).spent + roster:GetPointInfoForPlayer(altGUID).spent
                        if roster:GetPointType() == CONSTANTS.POINT_TYPE.EPGP then
                            spentSum = spentSum - roster:GetConfiguration("minGP")
                        end
                        -- 3a) Set new Main spent
                        roster:SetSpent(mainGUID, spentSum)
                        -- 4) Mirror standings (includes spent) from main to alts
                        roster:MirrorStandings(mainGUID, mainProfile:Alts(), true)
                        -- 5) Mirror weekly gains from main to alts
                        roster:MirrorWeeklyGains(mainGUID, mainProfile:Alts(), true)
                        -- 6) History entry
                        local targets = UTILS.keys(mainProfile:Alts())
                        table.insert(targets, 1, mainGUID)
                        CLM.MODULES.PointManager:AddFakePointHistory(roster, targets, pointSum, CONSTANTS.POINT_CHANGE_REASON.LINKING_OVERRIDE, entry:time(), entry:creatorFull())
                        CLM.MODULES.PointManager:AddFakePointHistory(roster, targets, spentSum, CONSTANTS.POINT_CHANGE_REASON.LINKING_OVERRIDE, entry:time(), entry:creatorFull(), nil, CONSTANTS.POINT_CHANGE_TYPE.SPENT)

                    end
                end
            end
        end))

    CLM.MODULES.LedgerManager:RegisterEntryType(
        CLM.MODELS.LEDGER.PROFILE.Lock,
        (function(entry)
            LOG:TraceAndCount("mutator(ProfileLock)")
            local action
            if entry:lock() then
                action = (function(p) p:Lock() end)
            else
                action = (function(p) p:Unlock() end)
            end
            -- Same action for all alts and mains
            for _, target in ipairs(entry:targets()) do
                local profile = self:GetProfileByGUID(UTILS.getGuidFromInteger(target))
                if profile then
                    action(profile) -- main lock/unlock
                    if profile:HasAlts() then -- Is Main - has alts
                        for altGUID in pairs(profile:Alts()) do
                            local altProfile = self:GetProfileByGUID(altGUID)
                            if altProfile then action(altProfile) end
                        end
                    elseif (profile:Main() ~= "") then -- is alt - has main
                        local mainProfile = self:GetProfileByGUID(profile:Main())
                        if mainProfile then
                            action(mainProfile)
                            for altGUID in pairs(mainProfile:Alts()) do
                                local altProfile = self:GetProfileByGUID(altGUID)
                                if altProfile then action(altProfile) end
                            end
                        end
                    end
                end
            end
        end))

    CLM.MODULES.LedgerManager:RegisterOnRestart(function()
        self:WipeAll()
    end)


end

function ProfileManager:NewProfile(GUID, name, class)
    LOG:Trace("ProfileManager:NewProfile()")
    if type(GUID) ~= "string" or GUID == "" then
        LOG:Error("NewProfile(): Empty GUID")
        return
    end
    if type(name) ~= "string" or name == "" then
        LOG:Error("NewProfile(): Empty name")
        return
    end
    local guidProfile = self:GetProfileByGUID(GUID)
    local nameProfile = self:GetProfileByName(name)

    local discard, warning
    if guidProfile then -- profile with this GUID already exists. Is this a rename?
        if nameProfile then -- profile with name and guid exists
            if guidProfile:GUID() == nameProfile:GUID() then -- same profile, same name - do nothing
                discard = true
                LOG:Debug("NewProfile(): guidProfile:GUID() == nameProfile:GUID()")
            else -- 2 different profiles exist. Warning
                discard = true
                LOG:Debug("NewProfile(): guidProfile:GUID() ~= nameProfile:GUID()")
                warning = string.format(CLM.L["Two different profiles exist for target GUID %s (%s:%s) and name %s (%s:%s). Verify and clean up profiles before updating."], GUID, name, guidProfile:GUID(), guidProfile:Name(), nameProfile:GUID(), nameProfile:Name())
            end
        else -- profile with this name does not exist - this is an actual rename
            discard = false
            LOG:Debug("NewProfile(): guidProfile and not nameProfile")
        end
    else -- profile with this GUID does not exist. Is this new profile?
        if nameProfile then -- name is used already by different profile? Warning
            discard = true
            LOG:Debug("NewProfile(): no guidProfile and nameProfile")
            warning = string.format(CLM.L["Profile %s already exists and is used by different GUID %s (%s). "], name, nameProfile:GUID(), nameProfile:Name())
        else -- New profile!
            discard = false
            LOG:Debug("NewProfile(): not guidProfile and not nameProfile")
        end
    end
    if discard then
        if warning then LOG:Warning(warning) end
        LOG:Debug("NewProfile(): discarding request for %s (%s)", name, GUID)
        return
    end

    LOG:Debug("New profile: [%s]: %s", GUID, name)
    CLM.MODULES.LedgerManager:Submit(CLM.MODELS.LEDGER.PROFILE.Update:new(GUID, name, class), true)
end

function ProfileManager:RemoveProfile(GUID)
    LOG:Trace("ProfileManager:RemoveProfile()")
    if type(GUID) ~= "string" or GUID == "" then
        LOG:Error("RemoveProfile(): UTILS.empty GUID")
        return
    end
    LOG:Debug("Remove profile: [%s]", GUID)
    CLM.MODULES.LedgerManager:Submit(CLM.MODELS.LEDGER.PROFILE.Remove:new(GUID), true)
end

local function PruneProfile(self, GUID, log)
    local profile = self.cache.profiles[GUID]
    if not profile then return end
    local entry = profile:Entry()
    if not entry then return end
    log:Add(profile:Name())
    CLM.MODULES.LedgerManager:Remove(entry)
end

function ProfileManager:MarkAsAltByNames(alt, main)
    LOG:Trace("ProfileManager:MarkAsAltByNames()")
    local altProfile = self:GetProfileByName(alt)
    if not UTILS.typeof(altProfile, CLM.MODELS.Profile) then
        LOG:Error("Alt does not exist. Aborting")
        return
    end
    local mainProfile = self:GetProfileByName(main)
    -- Unlink
    if not UTILS.typeof(mainProfile, CLM.MODELS.Profile) then
        if altProfile:Main() ~= "" then
            CLM.MODULES.LedgerManager:Submit(CLM.MODELS.LEDGER.PROFILE.Link:new(altProfile:GUID(), nil), true)
            LOG:Message(string.format("%s: %s", CLM.L["Unlink Alt"], UTILS.ColorCodeText(altProfile:Name(), UTILS.GetClassColor(altProfile:Class()).hex)))
        else
            LOG:Error("Main does not exist.")
        end
    else -- Link
        -- Do not allow alt chaining if main is alt
        if UTILS.typeof(self:GetProfileByGUID(mainProfile:Main()), CLM.MODELS.Profile) then
            LOG:Error("Alt chaining: Main is an alt.")
            return
        end
        -- Do not allow alt chaining if alt has alts
        if altProfile:HasAlts() then
            LOG:Error("Alt chaining: Alt has alts.")
            return
        end
        -- Don't allow self setting
        if altProfile:GUID() == mainProfile:GUID() then
            LOG:Error("Alt and main are same character.")
            return
        end
        -- Don't allow re-setting
        if altProfile:Main() == mainProfile:GUID() then
            LOG:Error("Alt already set.")
            return
        end
        CLM.MODULES.LedgerManager:Submit(CLM.MODELS.LEDGER.PROFILE.Link:new(altProfile:GUID(), mainProfile:GUID()), true)
        LOG:Message(string.format("%s%s%s",
            UTILS.ColorCodeText(altProfile:Name(), UTILS.GetClassColor(altProfile:Class()).hex),
            CLM.L[" alt of: "],
            UTILS.ColorCodeText(mainProfile:Name(), UTILS.GetClassColor(mainProfile:Class()).hex)
        ))
    end
end

function ProfileManager:SetProfilesLock(profiles, lock)
    LOG:Trace("ProfileManager:SetProfilesLock()")

    local entry = CLM.MODELS.LEDGER.PROFILE.Lock:new(profiles, lock and true or false)

    local t = entry:targets()
    if not t or (#t == 0) then
        LOG:Error("ProfileManager:SetProfilesLock(): Empty targets list")
        return
    end

    CLM.MODULES.LedgerManager:Submit(entry, true)
end

-- Functionalities

function ProfileManager:FillFromGuild(selectedRank, minLevel)
    LOG:Trace("ProfileManager:FillFromGuild()")
    if LOG.SEVERITY.DEBUG >= LOG:GetSeverity() then
        LOG:Debug("FillFromGuild: rank: {%s}, minLevel: %s", selectedRank, minLevel)
    end

    local rankFilterFn, minLevelFn
    if type(selectedRank) == "number" and selectedRank >= 0 then
        rankFilterFn = (function(rankIndex)
            return (selectedRank - 1) == rankIndex
        end)
    else
        rankFilterFn = (function(rankIndex)
            return true
        end)
    end

    minLevel = tonumber(minLevel)
    if type(minLevel) == "number" then
        minLevelFn = (function(level, minLevelValue)
            if level >= minLevelValue then
                return true
            end
            return false
        end)
    else
        minLevelFn = (function(level, _)
            return true
        end)
    end

    for i=1,GetNumGuildMembers() do
        local name, _, rankIndex, level, _, _, _, _, _, _, class, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if rankFilterFn(rankIndex) and minLevelFn(level, minLevel) then
            self:NewProfile(GUID, UTILS.Disambiguate(name), class)
        end
    end
end

function ProfileManager:FillFromRaid()
    LOG:Trace("ProfileManager:FillFromRaid()")
    if not IsInRaid() then return end
    for i=1,MAX_RAID_MEMBERS do
        local name, _, _, _, _, class = GetRaidRosterInfo(i)
        if name ~= nil then
            local GUID = UnitGUID("raid" .. tostring(i))
            self:NewProfile(GUID, UTILS.Disambiguate(name), class)
        end
    end
end

function ProfileManager:AddTarget()
    LOG:Trace("ProfileManager:AddTarget()")
    if UnitIsPlayer("target") then
        local GUID = UnitGUID("target")
        local name = UTILS.GetUnitName("target")
        local _, class, _ = UnitClass("target");

        self:NewProfile(GUID, name, class)
    else
        LOG:Warning("Your target must be a player.")
    end
end

function ProfileManager:PruneBelowLevel(minLevel, nop)
    LOG:Trace("ProfileManager:PruneBelowLevel()")
    local log = CLM.MODELS.ProfilePruneLog:New("level", nop)
    local prune
    if nop then
        LOG:Info("Pruning: No operation")
        prune = (function(GUID)
            local profile = self.cache.profiles[GUID]
            if not profile then return end
            log:Add(profile:Name())
        end)
    else
        prune = (function(GUID) PruneProfile(self, GUID, log) end)
    end
    local pruned = 0
    for i=1,GetNumGuildMembers() do
        local _, _, _, level, _, _, _, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if level < minLevel then
            prune(GUID)
            pruned = pruned + 1
        end
    end
    if pruned > 0 then table.insert(self.db.pruneLog, log) end
    LOG:Info("Pruned %s profiles below level %s", pruned, minLevel)
end

function ProfileManager:PruneRank(rank, nop)
    LOG:Trace("ProfileManager:PruneRank()")
    local log = CLM.MODELS.ProfilePruneLog:New("rank", nop)
    local prune
    if nop then
        LOG:Info("Pruning: No operation")
        prune = (function(GUID)
            local profile = self.cache.profiles[GUID]
            if not profile then return end
            log:Add(profile:Name())
        end)
    else
        prune = (function(GUID) PruneProfile(self, GUID, log) end)
    end
    local check
    if type(rank) == "number" then
        check = (function(_, rankIndexValue, rankValue)
            return (rankIndexValue == rankValue)
        end)
    else
        rank = strlower(rank or "")
        check = (function(rankNameValue, _, rankValue)
            return (strlower(rankNameValue) == rankValue)
        end)
    end
    local pruned = 0
    for i=1,GetNumGuildMembers() do
        local _, rankName, rankIndex, _, _, _, _, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        if check(rankName, rankIndex, rank) then
            prune(GUID)
            pruned = pruned + 1
        end
    end
    if pruned > 0 then table.insert(self.db.pruneLog, log) end
    LOG:Info("Pruned %s profiles with rank %s", pruned, rank)
end

function ProfileManager:PruneUnguilded(nop)
    LOG:Trace("ProfileManager:PruneUnguilded()")
    local log = CLM.MODELS.ProfilePruneLog:New("unguilded", nop)
    local prune
    if nop then
        LOG:Info("Pruning: No operation")
        prune = (function(GUID)
            local profile = self.cache.profiles[GUID]
            if not profile then return end
            log:Add(profile:Name())
        end)
    else
        prune = (function(GUID) PruneProfile(self, GUID, log) end)
    end
    local GUIDs = {}
    local pruned = 0
    for i=1,GetNumGuildMembers() do
        local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, GUID = GetGuildRosterInfo(i)
        GUIDs[GUID] = true
    end
    for GUID in pairs(self.cache.profiles) do
        if not GUIDs[GUID] then
            prune(GUID)
            pruned = pruned + 1
        end
    end
    if pruned > 0 then table.insert(self.db.pruneLog, log) end
    LOG:Info("Pruned %s unguilded profiles", pruned)
end

function ProfileManager:WipeAll()
    LOG:Trace("ProfileManager:WipeAll()")
    self.cache = { profilesGuidMap = {}, profiles = {} }
end

function ProfileManager:GetMyProfile()
    LOG:Trace("ProfileManager:GetMyProfile()")
    return self:GetProfileByGUID(whoamiGUID)
end

-- Utility

function ProfileManager:GetGUIDFromName(name)
    return self.cache.profilesGuidMap[name]
end

function ProfileManager:GetProfiles()
    return self.cache.profiles
end

function ProfileManager:GetProfileByGUID(GUID)
    return self.cache.profiles[GUID]
end

function ProfileManager:GetProfileByName(name)
    return self.cache.profiles[self.cache.profilesGuidMap[strlower(name)]]
end

function ProfileManager:GetDisenchanterProfile()
    return self._deProfile
end

-- Publis API
CLM.MODULES.ProfileManager = ProfileManager
