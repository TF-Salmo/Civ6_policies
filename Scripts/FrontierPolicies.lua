-- Frontier Expansion Policies: gameplay script (UNTESTED first draft).
-- Cards are defined in Data/FrontierPolicies.xml; effects needing custom logic live here.

local FRONTIER_DISTANCE = 6

local function HasPolicy(playerID, policyType)
    local info = GameInfo.Policies[policyType]
    if info == nil then return false end
    local player = Players[playerID]
    return player ~= nil and player:GetCulture():IsPolicyActive(info.Index)
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

-- TODO (needs gameplay hooks beyond this draft):
--   Frontier Craftsmen   : +1 Builder charge when trained in a city with <= 3 pop.
--   Frontier Expeditions : Settlers ignore Woods/Rainforest/Hills/River move costs.
--   Frontier Scholars    : +1 Science in frontier cities until pop 7.
--   Frontier Militia/Raiders : combat strength bonus near small cities.
