# FostercareBattleText

Scrolling combat text for World of Warcraft 1.12.1: player and pet damage,
heals, misses, absorbs, critical hits, resource gains and configurable alerts.

## Requirements

- World of Warcraft 1.12.1 (build 5875).
- ClassicAPI 1.20.6 or newer.

## Install or update

Download the latest zip from
[Releases](https://github.com/Fostercare5988/FostercareBattleText/releases/latest).
Close the game and extract it into `Interface/AddOns`, so the TOC is at
`Interface/AddOns/FostercareBattleText/FostercareBattleText.toc`.


## Configure

Type `/fbt`. The tabs are General, Areas, Incoming,
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
`_OUTGOING` or `_NOTIFICATION`, and the colour channels are 0-255.

## License and credits

Maintained by [Fostercare5988](https://github.com/Fostercare5988). Licensed under the MIT License.
