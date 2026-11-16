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
- Cards, text and unlock civics are defined (unlock civics are placeholders to tune).
- Implemented in Lua: Spirit, Pilgrimage, Delegations.
- Still to do: Craftsmen, Expeditions, Scholars, Militia, Raiders (see TODO in `Scripts/FrontierPolicies.lua`).

## Install
Copy this folder into your Civilization VI `Mods` folder and enable it under Additional Content.
