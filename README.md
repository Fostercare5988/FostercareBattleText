# FostercareBattleText

Scrolling combat text for World of Warcraft 1.12.1: player and pet damage,
heals, misses, absorbs, critical hits, resource gains and configurable alerts.
Formerly Mik's Scrolling Battle Text (MSBT).

## Requirements

- World of Warcraft 1.12.1 (build 5875).
- ClassicAPI. SuperWoW, NamPower and UnitXP are not needed.

Load ClassicAPI with your client's launcher; DLL changes need a complete client
restart.

## Install or update

Download the latest zip from
[Releases](https://github.com/Fostercare5988/FostercareBattleText/releases/latest).
Close the game and extract it into `Interface/AddOns`, so the TOC is at
`Interface/AddOns/FostercareBattleText/FostercareBattleText.toc`.

Coming from MSBT: the folder, the saved settings (`FostercareBattleTextDB`,
formerly `MikSBT_Save`) and the command changed. Delete the old
`MikScrollingBattleText` folder, and copy
`WTF/Account/<account>/SavedVariables/MikScrollingBattleText.lua` to
`FostercareBattleText.lua` in the same folder, with `MikSBT_Save` on its first
line renamed to `FostercareBattleTextDB`, to keep your profiles.

## Configure

Type `/fbt` (`/msbt` still works). The tabs are General, Areas, Incoming,
Outgoing, Notices, Triggers, Filters and Profiles. Each tab is also a page under
FostercareBattleText in Game Menu > AddOn Options, in one column. See
[the user guide](docs/USER_GUIDE.md).

Commands: `/fbt`, `/fbt enable`, `/fbt disable`, `/fbt version`, `/fbt reset`.

## Healing and other displays

All combat text comes from ClassicAPI's combat log; heals show the total, as the
log reports no overheal. Reputation comes from its `FACTION_STANDING_CHANGED`
event, mana from `UNIT_POWER_UPDATE` (a druid's mana in every form).

Game damage text controls the native damage numbers above enemies. Other addons
keep their own floating text. Combat text does not capture mouse input.

## For other addons

`FostercareBattleText.DisplayMessage(text, displayType, sticky, r, g, b, size)`
shows a line; `displayType` is `FostercareBattleText.DISPLAYTYPE_INCOMING`,
`_OUTGOING` or `_NOTIFICATION`, and the colour channels are 0-255. MSBT's
`MikSBT` table no longer exists.

## License and credits

Original author: Mik. Maintained by [Fostercare5988](https://github.com/Fostercare5988). Licensed under the MIT License.
The settings window uses the ForgeUI kit. Original source credits are retained.
