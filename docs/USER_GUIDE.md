# FostercareBattleText user guide

Type `/fbt` to open the settings (`/msbt` still works). The tabs are **General,
Areas, Incoming, Outgoing, Notices, Triggers, Filters and Profiles**. Every
change applies at once and is saved when you log out or reload. The close button or Escape closes the window.

The same eight pages are under **FostercareBattleText** in Game Menu > AddOn
Options, one column each; scroll down for the rest of a page. Its first entry
opens the window. Opening the window closes AddOn Options, and a page shows in
one place at a time.

## General

Turn the battle text on or off (while it is off, the game shows its own damage
numbers), and choose partial effects (absorbed, blocked, resisted, crushing and
glancing amounts, and overhealing), sticky critical hits, all mana gains (regeneration and
drinking included, in every druid form), the game's own damage numbers, the low
health, low mana and frost-resist sounds, and the scroll speed.
**Fonts** sets the master font, outline and size for normal and critical text;
areas and events inherit them unless you change them. **Game damage font**
changes the game's own damage numbers after you log in again.

In a font editor, the arrows or the mouse wheel step through the fonts. **Inherit
size** uses the size of the area or master font; turn it off to set a size
(12-64).

## Areas

Pick Incoming, Outgoing or Notices, then its movement (straight or curved, up or
down), text alignment, scroll height and fonts. **Move areas** shows a handle per
area: drag it to place the area, and click **Move areas** again to hide the
handles. **Preview** shows a sample line in each area. **Reset positions** puts
all three areas back.

## Incoming, Outgoing and Notices

One row per event: turn it on or off, click the dot to pick its color, click the
message to edit it (Enter saves, Escape keeps the old text), and **Font** edits
its font. The message tooltip lists the codes it fills, such as `%a` amount,
`%n` name, `%s` spell and `%t` damage type. Fire, nature, frost, shadow and
arcane damage take their school's colour. On Notices, **Sticky** pops the event
in the middle of the area instead of scrolling it. On the Enter Combat and Leave
Combat rows, **Icon** adds crossed swords (twice the text size): red beside
"+Combat", green beside "-Combat". The arrows at the bottom turn the page.

All combat text comes from ClassicAPI's combat log. A heal shows what it healed,
with the overheal after it, such as `+300 <200>`; a heal over time that heals
nothing is not shown. The game knows the overheal only for you, your group and
units in view; other heals show their whole amount. A damage shield names its spell, such as Thorns, when
the game says which. Killing blows count a player kill even when you never
targeted the player. Power Losses shows mana, rage or energy drained from you.
Reputation changes show the faction and amount. Experience Gains shows every
gain: kills, quests and exploring.

## Triggers

Each trigger shows a message when something happens. A row has an on/off switch,
the message (click to edit; `%1` is the health or mana amount), its color,
**Sticky**, **Font**, **Edit** and **X** to delete. **Add trigger** creates one
and opens its editor.

The editor sets the type, the classes it applies to, an icon path and:

- **Threshold types** (self health or mana, pet health, enemy or friendly target
  health): the percentage it fires below.
- **Aura Gained**: the exact buff name, for example Clearcasting.
- **You Dodge**, **You Parry**, **Your Attack Dodged**: no further setting.

All but the threshold types can require a stance or form. **Save** keeps the
changes, **Cancel** drops them.

## Filters

A filter hides every message whose text or spell name contains its text, for
example `Vigor` or `Judgement of Wisdom`. Click a filter to edit it, **X**
deletes it, **Add filter** adds one.

## Profiles

Profiles are shared by your characters, and each character uses its own
choice: click a profile's dot to use it on this character.
**Create** adds a profile with the default settings, **Delete** removes one (not
Default), and **Reset this profile** puts the current profile back to the
defaults, triggers and filters included. `/fbt reset` does the same.

## Commands and other addons

`/fbt`, `/fbt enable`, `/fbt disable`, `/fbt version`, `/fbt reset`.

Other addons can send text through `FostercareBattleText.DisplayMessage`. The
battle text leaves other addons' floating text and settings alone.

Requirements: ClassicAPI. SuperWoW, NamPower and UnitXP are not needed.
DLL updates need a full client restart.
