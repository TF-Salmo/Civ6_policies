# Frontier Expansion Policies (Civilization VI)

Eight early-game policy cards that reward settling far from your Capital.

| Card | Slot | Effect | Archetype |
|---|---|---|---|
| Frontier Spirit | Economic | Cities founded at least 6 tiles from your Capital begin with 25% of a Monument already built. | Expansion |
| Frontier Craftsmen | Economic | Builders trained in cities with 3 or fewer Population receive +1 Build Charge. | Development |
| Frontier Expeditions | Wildcard | Settlers ignore movement penalties from Woods, Rainforest, Hills, and River crossings. | Exploration |
| Frontier Pilgrimage | Wildcard | Cities founded at least 6 tiles from your Capital begin with +25 Faith. | Religion |
| Frontier Scholars | Wildcard | Cities founded at least 6 tiles from your Capital receive +1 Science until they reach 7 Population. | Science |
| Frontier Delegations | Wildcard | The first time you discover a City-State, gain 25 Influence Points. | Diplomacy / City-States |
| Frontier Militia | Military | Units receive +5 Combat Strength while within 3 tiles of a city with 4 or fewer Population. | Defense |
| Frontier Raiders (revised) | Military | Units receive +2 Combat Strength while within 6 tiles of a city with 4 or fewer Population. | Early Aggression / Conquest |

## Status
Work in progress, **untested in game**.
- All eight cards now have logic (Lua + unit abilities in `Data/FrontierPolicies.xml`).
- Unverified engine names that may need adjusting on first load: `MODIFIER_UNIT_ADJUST_IGNORE_TERRAIN_COST` (Expeditions), `MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH` (Militia/Raiders), and the Lua calls `SetBuildCharges`, `GetAbility():ChangeAbilityCount`.
- Scholars is approximated as +1 Science of research progress per qualifying city per turn.
- Unlock civics are placeholders to tune.

## Install
Copy this folder into your Civilization VI `Mods` folder and enable it under Additional Content.
