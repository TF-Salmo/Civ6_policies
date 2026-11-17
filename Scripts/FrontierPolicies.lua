-- Frontier Expansion Policies: gameplay script (UNTESTED first draft).
-- Cards are defined in Data/FrontierPolicies.xml; effects needing custom logic live here.

local FRONTIER_DISTANCE = 5

-- Each card expires once the owner discovers its tech (balanced per era).
local EXPIRY_TECH = {
    ["POLICY_FRONTIER_SPIRIT"] = "TECH_CURRENCY",
    ["POLICY_FRONTIER_CRAFTSMEN"] = "TECH_MASONRY",
    ["POLICY_FRONTIER_EXPEDITIONS"] = "TECH_IRRIGATION",
    ["POLICY_FRONTIER_PILGRIMAGE"] = "TECH_WRITING",
    ["POLICY_FRONTIER_SCHOLARS"] = "TECH_WRITING",
    ["POLICY_FRONTIER_DELEGATIONS"] = "TECH_CURRENCY",
    ["POLICY_FRONTIER_MILITIA"] = "TECH_IRON_WORKING",
    ["POLICY_FRONTIER_RAIDERS"] = "TECH_BRONZE_WORKING",
}

local function HasPolicy(playerID, policyType)
    local info = GameInfo.Policies[policyType]
    if info == nil then return false end
    local player = Players[playerID]
    if player == nil or not player:GetCulture():IsPolicyActive(info.Index) then return false end
    local tech = EXPIRY_TECH[policyType]
    if tech ~= nil and GameInfo.Technologies[tech] ~= nil
       and player:GetTechs():HasTech(GameInfo.Technologies[tech].Index) then
        return false -- expired
    end
    return true
end

local function IsFrontier(playerID, city)
    local capital = Players[playerID]:GetCities():GetCapitalCity()
    if capital == nil or capital:GetID() == city:GetID() then return false end
    return Map.GetPlotDistance(capital:GetX(), capital:GetY(), city:GetX(), city:GetY()) >= FRONTIER_DISTANCE
end

-- Frontier Spirit / Pilgrimage: applied when a city is founded.
local function OnCityBuilt(playerID, cityID, x, y)
    local city = CityManager.GetCity(playerID, cityID)
    if city == nil or not IsFrontier(playerID, city) then return end

    if HasPolicy(playerID, "POLICY_FRONTIER_SPIRIT") then
        local monument = GameInfo.Buildings["BUILDING_MONUMENT"]
        if monument then
            city:GetBuildQueue():CreateIncompleteBuilding(monument.Index, 25)
        end
    end
    if HasPolicy(playerID, "POLICY_FRONTIER_PILGRIMAGE") then
        Players[playerID]:GetReligion():ChangeFaithBalance(25)
    end
end
Events.CityBuilt.Add(OnCityBuilt)

-- Frontier Delegations: first City-State met grants 25 Influence Points.
local function OnDiplomacyMeet(firstID, secondID)
    for _, pair in ipairs({ { firstID, secondID }, { secondID, firstID } }) do
        local me, other = pair[1], pair[2]
        if Players[me]:IsMajor() and not Players[other]:IsMajor() and not Players[other]:IsBarbarian()
           and HasPolicy(me, "POLICY_FRONTIER_DELEGATIONS")
           and Players[me]:GetProperty("FRONTIER_DELEGATION_USED") == nil then
            Players[me]:SetProperty("FRONTIER_DELEGATION_USED", 1)
            Players[me]:GetInfluence():ChangeTokensToGive(25)
        end
    end
end
Events.DiplomacyMeet.Add(OnDiplomacyMeet)

-- Frontier Craftsmen: +1 Build Charge for Builders trained in cities with <= 3 pop.
local function OnCityProductionCompleted(playerID, cityID, orderType, itemType)
    if not HasPolicy(playerID, "POLICY_FRONTIER_CRAFTSMEN") then return end
    local builder = GameInfo.Units["UNIT_BUILDER"]
    if builder == nil or itemType ~= builder.Index then return end
    local city = CityManager.GetCity(playerID, cityID)
    if city == nil or city:GetPopulation() > 3 then return end
    local plot = Map.GetPlot(city:GetX(), city:GetY())
    for _, unit in ipairs(Units.GetUnitsInPlot(plot)) do
        if unit:GetType() == builder.Index and unit:GetOwner() == playerID
           and unit:GetProperty("FRONTIER_CRAFTED") == nil then
            unit:SetProperty("FRONTIER_CRAFTED", 1)
            unit:SetBuildCharges(unit:GetBuildCharges() + 1)
        end
    end
end
GameEvents.CityProductionCompleted.Add(OnCityProductionCompleted)

-- Set an ability on a unit to exactly want (0/1) using a stored flag, since
-- ChangeAbilityCount is additive.
local function SetAbility(unit, abilityType, want)
    local ab = unit:GetAbility()
    if ab == nil then return end
    local key = "FRONTIER_AB_" .. abilityType
    local has = unit:GetProperty(key) == 1
    if want and not has then
        ab:ChangeAbilityCount(abilityType, 1)
        unit:SetProperty(key, 1)
    elseif has and not want then
        ab:ChangeAbilityCount(abilityType, -1)
        unit:SetProperty(key, 0)
    end
end

-- True if any of the player's cities with <= 4 pop lies within range tiles of the unit.
local function NearSmallCity(player, unit, range)
    for _, city in player:GetCities():Members() do
        if city:GetPopulation() <= 4
           and Map.GetPlotDistance(unit:GetX(), unit:GetY(), city:GetX(), city:GetY()) <= range then
            return true
        end
    end
    return false
end

local function RefreshUnit(playerID, unit)
    local player = Players[playerID]
    if unit:GetUnitType() == GameInfo.Units["UNIT_SETTLER"].Index then
        SetAbility(unit, "ABILITY_FRONTIER_EXPEDITIONS", HasPolicy(playerID, "POLICY_FRONTIER_EXPEDITIONS"))
    elseif unit:GetCombat() > 0 or unit:GetRangedCombat() > 0 then
        SetAbility(unit, "ABILITY_FRONTIER_MILITIA",
            HasPolicy(playerID, "POLICY_FRONTIER_MILITIA") and NearSmallCity(player, unit, 3))
        SetAbility(unit, "ABILITY_FRONTIER_RAIDERS",
            HasPolicy(playerID, "POLICY_FRONTIER_RAIDERS") and NearSmallCity(player, unit, 6))
    end
end

-- Frontier Scholars (+1 Science per qualifying city) and ability refresh each turn.
local function OnPlayerTurnStarted(playerID)
    local player = Players[playerID]
    if player == nil or not player:IsMajor() then return end

    if HasPolicy(playerID, "POLICY_FRONTIER_SCHOLARS") then
        for _, city in player:GetCities():Members() do
            if city:GetPopulation() < 7 and IsFrontier(playerID, city) then
                player:GetTechs():ChangeCurrentResearchProgress(1)
            end
        end
    end
    for _, unit in player:GetUnits():Members() do RefreshUnit(playerID, unit) end
end
GameEvents.PlayerTurnStarted.Add(OnPlayerTurnStarted)

-- Refresh as units move so bonuses track position within the turn.
local function OnUnitMoved(playerID, unitID)
    local unit = UnitManager.GetUnit(playerID, unitID)
    if unit ~= nil then RefreshUnit(playerID, unit) end
end
Events.UnitMoved.Add(OnUnitMoved)
