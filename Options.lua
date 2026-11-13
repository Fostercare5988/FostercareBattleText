-------------------------------------------------------------------------------------
-- FostercareBattleText: the settings window (ForgeUI) and its pages in AddOn Options.
-------------------------------------------------------------------------------------

local addonName, FBT = ...
if not FBT.ready then return end

local UI, Combat = FBT.UI, FBT.Combat
local Options = {}
FBT.Options = Options

-- Event rows per scroll area: event type, label, tooltip and the codes it fills.
local EVENTS = {
 Incoming = {
  {Type="MSBT_EVENTTYPE_INCOMING_DAMAGE", Label="Melee Damage", Tip="Show incoming melee damage.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_MISS", Label="Melee Misses", Tip="Show incoming melee misses.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_DODGE", Label="Melee Dodges", Tip="Show incoming melee dodges.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PARRY", Label="Melee Parries", Tip="Show incoming melee parries.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_BLOCK", Label="Melee Blocks", Tip="Show incoming melee blocks.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_ABSORB", Label="Melee Absorbs", Tip="Show absorbed incoming melee damage.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_IMMUNE", Label="Melee Immunes", Tip="Show incoming melee damage you are immune to.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_EVADE", Label="Melee Evades", Tip="Show incoming melee evades.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_DAMAGE", Label="Ability/Spell Damage", Tip="Show incoming spell and ability damage.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker.\n%s - Name of the spell or ability.\n%t - Type of damage taken."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_DOT", Label="Ability/Spell DoTs", Tip="Show incoming spell and ability damage over time.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker.\n%s - Name of the spell or ability.\n%t - Type of damage taken."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_MISS", Label="Ability Misses", Tip="Show incoming ability misses.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_DODGE", Label="Ability Dodges", Tip="Show incoming ability dodges.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_PARRY", Label="Ability Parries", Tip="Show incoming ability parries.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_BLOCK", Label="Ability Blocks", Tip="Show incoming ability blocks.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_RESIST", Label="Spell Resists", Tip="Show incoming spell resists.", Codes="%n - Name of the attacker.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_ABSORB", Label="Ability/Spell Absorbs", Tip="Show absorbed damage from incoming spells and abilities.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_IMMUNE", Label="Ability/Spell Immunes", Tip="Show incoming spell and ability damage you are immune to.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_REFLECT", Label="Ability/Spell Reflects", Tip="Show incoming spell and ability damage you reflected.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_SPELL_EVADE", Label="Ability/Spell Evades", Tip="Show incoming spell and ability evades.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_HEAL", Label="Heals", Tip="Show incoming heals.", Codes="%a - Healing taken, without overhealing.\n%n - Name of the healer.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_INCOMING_HOT", Label="Heals Over Time", Tip="Show incoming heals over time.", Codes="%a - Healing taken, without overhealing.\n%n - Name of the healer.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_INCOMING_ENVIRONMENTAL", Label="Environmental Damage", Tip="Show environmental (falling, drowning, lava, etc...) damage.", Codes="%a - Amount of damage taken.\n%s - Name of the source of the damage (falling, drowning, lava, etc...)"},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_DAMAGE", Label="Pet Melee Damage", Tip="Show incoming melee damage on your pet.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_MISS", Label="Pet Melee Misses", Tip="Show incoming melee misses on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_DODGE", Label="Pet Melee Dodges", Tip="Show incoming melee dodges on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_PARRY", Label="Pet Melee Parries", Tip="Show incoming melee parries on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_BLOCK", Label="Pet Melee Blocks", Tip="Show incoming melee blocks on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_ABSORB", Label="Pet Melee Absorbs", Tip="Show absorbed incoming melee damage on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_IMMUNE", Label="Pet Melee Immunes", Tip="Show incoming melee damage your pet is immune to.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_EVADE", Label="Pet Melee Evades", Tip="Show incoming melee evades on your pet.", Codes="%n - Name of the attacker."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_DAMAGE", Label="Pet Ability/Spell Damage", Tip="Show incoming spell and ability damage on your pet.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker.\n%s - Name of the spell or ability.\n%t - Type of damage taken."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_DOT", Label="Pet Ability/Spell DoTs", Tip="Show incoming spell and ability damage over time on your pet.", Codes="%a - Amount of damage taken.\n%n - Name of the attacker.\n%s - Name of the spell or ability.\n%t - Type of damage taken."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_MISS", Label="Pet Ability Misses", Tip="Show incoming ability misses on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_DODGE", Label="Pet Ability Dodges", Tip="Show incoming ability dodges on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_PARRY", Label="Pet Ability Parries", Tip="Show incoming ability parries on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_BLOCK", Label="Pet Ability Blocks", Tip="Show incoming ability blocks on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_RESIST", Label="Pet Spell Resists", Tip="Show incoming spell resists on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_ABSORB", Label="Pet Ability/Spell Absorbs", Tip="Show absorbed damage from incoming spells and abilities on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_IMMUNE", Label="Pet Ability/Spell Immunes", Tip="Show incoming spell and ability damage your pet is immune to.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_EVADE", Label="Pet Ability/Spell Evades", Tip="Show incoming spell and ability evades on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_SPELL_REFLECT", Label="Pet Ability/Spell Reflects", Tip="Show incoming spell and ability reflects on your pet.", Codes="%n - Name of the attacker.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_HEAL", Label="Pet Heals", Tip="Show incoming heals on your pet.", Codes="%a - Healing taken, without overhealing.\n%n - Name of the healer.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_INCOMING_PET_HOT", Label="Pet Heals Over Time", Tip="Show incoming heals over time on your pet.", Codes="%a - Healing taken, without overhealing.\n%n - Name of the healer.\n%s - Name of the spell."},
 },
 Outgoing = {
  {Type="MSBT_EVENTTYPE_OUTGOING_DAMAGE", Label="Melee Damage", Tip="Show outgoing melee damage.", Codes="%a - Amount of damage done.\n%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_MISS", Label="Melee Misses", Tip="Show outgoing melee misses.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_DODGE", Label="Melee Dodges", Tip="Show outgoing melee dodges.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PARRY", Label="Melee Parries", Tip="Show outgoing melee parries.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_BLOCK", Label="Melee Blocks", Tip="Show outgoing melee blocks.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_ABSORB", Label="Melee Absorbs", Tip="Show absorbed outgoing melee damage.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_IMMUNE", Label="Melee Immunes", Tip="Show outgoing melee damage the enemy is immune to.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_EVADE", Label="Melee Evades", Tip="Show outgoing melee evades.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_DAMAGE", Label="Ability/Spell Damage", Tip="Show outgoing spell and ability damage.", Codes="%a - Amount of damage done.\n%n - Name of the attacked unit.\n%s - Name of the spell or ability.\n%t - Type of damage done."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_DOT", Label="Ability/Spell DoTs", Tip="Show outgoing spell and ability damage over time.", Codes="%a - Amount of damage done.\n%n - Name of the attacked unit.\n%s - Name of the spell or ability.\n%t - Type of damage done."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_MISS", Label="Ability Misses", Tip="Show outgoing ability misses.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_DODGE", Label="Ability Dodges", Tip="Show outgoing ability dodges.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_PARRY", Label="Ability Parries", Tip="Show outgoing ability parries.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_BLOCK", Label="Ability Blocks", Tip="Show outgoing ability blocks.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_RESIST", Label="Spell Resists", Tip="Show outgoing spell resists.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_ABSORB", Label="Ability/Spell Absorbs", Tip="Show absorbed damage from outgoing spells and abilities.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_IMMUNE", Label="Ability/Spell Immunes", Tip="Show outgoing spell and ability damage the enemy is immune to.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT", Label="Ability/Spell Reflects", Tip="Show outgoing spell and ability damage reflected back to you.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_SPELL_EVADE", Label="Ability/Spell Evades", Tip="Show outgoing spell and ability evades.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_HEAL", Label="Heals", Tip="Show outgoing heals.", Codes="%a - Healing done, without overhealing.\n%n - Name of the healed unit.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_OUTGOING_HOT", Label="Heals Over Time", Tip="Show outgoing heals over time.", Codes="%a - Healing done, without overhealing.\n%n - Name of the healed unit.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_DAMAGE", Label="Pet Melee Damage", Tip="Show your pet's outgoing melee damage.", Codes="%a - Amount of damage done.\n%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_MISS", Label="Pet Melee Misses", Tip="Show your pet's outgoing melee misses.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_DODGE", Label="Pet Melee Dodges", Tip="Show your pet's outgoing melee dodges.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_PARRY", Label="Pet Melee Parries", Tip="Show your pet's outgoing melee parries.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_BLOCK", Label="Pet Melee Blocks", Tip="Show your pet's outgoing melee blocks.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_ABSORB", Label="Pet Melee Absorbs", Tip="Show your pet's absorbed outgoing melee damage.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_IMMUNE", Label="Pet Melee Immunes", Tip="Show your pet's outgoing melee damage the enemy is immune to.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_EVADE", Label="Pet Melee Evades", Tip="Show your pet's outgoing melee evades.", Codes="%n - Name of the attacked unit."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DAMAGE", Label="Pet Ability/Spell Damage", Tip="Show your pet's outgoing spell and ability damage.", Codes="%a - Amount of damage done.\n%n - Name of the attacked unit.\n%s - Name of the spell or ability.\n%t - Type of damage done."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_MISS", Label="Pet Ability Misses", Tip="Show your pet's outgoing ability misses.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DODGE", Label="Pet Ability Dodges", Tip="Show your pet's outgoing ability dodges.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_PARRY", Label="Pet Ability Parries", Tip="Show your pet's outgoing ability parries.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_BLOCK", Label="Pet Ability Blocks", Tip="Show your pet's outgoing ability blocks.", Codes="%n - Name of the attacked unit.\n%s - Name of the ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_RESIST", Label="Pet Spell Resists", Tip="Show your pet's outgoing spell resists.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_ABSORB", Label="Pet Ability/Spell Absorbs", Tip="Show your pet's absorbed damage from outgoing spells and abilities.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_IMMUNE", Label="Pet Ability/Spell Immunes", Tip="Show your pet's outgoing spell and ability damage the enemy is immune to.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
  {Type="MSBT_EVENTTYPE_OUTGOING_PET_SPELL_EVADE", Label="Pet Ability/Spell Evades", Tip="Show your pet's outgoing spell and ability evades.", Codes="%n - Name of the attacked unit.\n%s - Name of the spell or ability."},
 },
 Notification = {
  {Type="MSBT_EVENTTYPE_NOTIFICATION_DEBUFF", Label="Debuffs", Tip="Show debuffs you are afflicted by.", Codes="%s - Name of the debuff."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_BUFF", Label="Buffs", Tip="Show buffs you receive.", Codes="%s - Name of the buff."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_BUFF_FADE", Label="Buff Fades", Tip="Show buffs and debuffs that have faded from you.", Codes="%s - Name of the buff/debuff."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_COMBAT_ENTER", Label="Enter Combat", Tip="Show when you have entered combat.", Codes="None."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_COMBAT_LEAVE", Label="Leave Combat", Tip="Show when you have left combat.", Codes="None."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_POWER_GAIN", Label="Power Gains", Tip="Show when you gain extra mana, rage, or energy.", Codes="%a - Amount and type of power gained, such as 25 Energy.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_POWER_LOSS", Label="Power Losses", Tip="Show when you lose mana, rage, or energy from drains.", Codes="%a - Amount and type of power lost, such as 120 Mana.\n%s - Name of the spell."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_CP_GAIN", Label="Combo Point Gains", Tip="Show when you gain combo points.", Codes="%a - Amount of combo points you have."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_CP_FULL", Label="Combo Points Full", Tip="Show when you attain full combo points.", Codes="%a - Amount of combo points you have."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_HONOR_GAIN", Label="Honor Gains", Tip="Show when you gain honor.", Codes="%a - Amount of honor you gained."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_REP_GAIN", Label="Reputation Gains", Tip="Show when you gain reputation.", Codes="%a - Amount of reputation you gained.\n%s - Name of the faction."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_REP_LOSS", Label="Reputation Losses", Tip="Show when you lose reputation.", Codes="%a - Amount of reputation you lost.\n%s - Name of the faction."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_SKILL_GAIN", Label="Skill Gains", Tip="Show when you gain skill points.", Codes="%a - Amount of points you have in the skill.\n%s - Name of the skill."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_EXPERIENCE_GAIN", Label="Experience Gains", Tip="Show when you gain experience points.", Codes="%a - Amount of experience you gained."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_PC_KILLING_BLOW", Label="Player Killing Blows", Tip="Show when you get a killing blow against a hostile player.", Codes="%s - Name of the unit killed."},
  {Type="MSBT_EVENTTYPE_NOTIFICATION_NPC_KILLING_BLOW", Label="NPC Killing Blows", Tip="Show when you get a killing blow against an NPC.", Codes="%s - Name of the unit killed."},
 },
};

local WIDTH, ROWS_PER_PAGE = 600, 10
-- The window's left margin, column width (ForgeLayout), the width from which a
-- block uses the window's places, and the extra space between switch lines.
local LEFT, SIDE, WIDE, ROW_GAP = 28, 208, 440, 10
local PAGER_WIDTH = 160
local AREAS = {"Incoming", "Outgoing", "Notification"}
local AREA_LABELS = {Incoming = "Incoming", Outgoing = "Outgoing", Notification = "Notices"}

local L, R = UI.L, UI.R
local layout = UI.NewLayout()
local panel, ShowTab, fontEditor, triggerEditor
local book                      -- the pages in AddOn Options (ForgeLayout.lua)
local refresh = {}              -- each page's sync: values and visibility only
local tab = 1
local selectedArea = "Incoming"
local moversShown = false

-- Syncs the open page, then places it for the width it has (window or AddOn Options).
local function Refresh()
 if refresh[tab] then refresh[tab]() end
 if book then book:Place(tab) end
end

local function Profile() return FBT.CurrentProfile end

-- Sorted keys, so list rows keep their order between refreshes.
local function SortedKeys(t)
 local keys = {}
 for key in pairs(t) do table.insert(keys, key) end
 table.sort(keys)
 return keys
end

-------------------------------------------------------------------------------------
-- Small widgets on top of the kit: text box, color swatch, cycle, pager.
-------------------------------------------------------------------------------------

local function TextBox(name, parent, x, y, width, onAccept)
 local box = CreateFrame("EditBox", name, parent)
 box:SetWidth(width); box:SetHeight(20)
 box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
 box:SetAutoFocus(false)
 box:SetFontObject(GameFontHighlightSmall)
 box:SetTextInsets(6, 6, 0, 0)
 UI.Rounded(box, "BACKGROUND", 6, UI.track)
 box:SetScript("OnEscapePressed", function() box:ClearFocus() end)
 box:SetScript("OnEnterPressed", function()
  box:ClearFocus()
  if onAccept then onAccept(box:GetText()) end
 end)
 return box
end

local function Swatch(name, parent, onClick)
 local button = CreateFrame("Button", name, parent)
 button:SetWidth(16); button:SetHeight(16)
 button:RegisterForClicks("LeftButtonUp")
 UI.Disc(button, "BACKGROUND", 16, UI.edge):SetPoint("CENTER", button, "CENTER", 0, 0)
 button.fill = UI.Disc(button, "ARTWORK", 12, UI.white)
 button.fill:SetPoint("CENTER", button, "CENTER", 0, 0)
 UI.Disc(button, "HIGHLIGHT", 22, UI.halo):SetPoint("CENTER", button, "CENTER", 0, 0)
 button:SetScript("OnClick", onClick)
 return button
end

local function PaintSwatch(button, color)
 button.fill:SetVertexColor(color.r, color.g, color.b, 1)
end

-- "<  value  >": onStep(-1 or 1) changes the value; the mouse wheel steps too.
local function Cycle(name, parent, x, y, width, onStep)
 local frame = CreateFrame("Frame", name, parent)
 frame:SetWidth(width); frame:SetHeight(22)
 frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
 UI.Rounded(frame, "BACKGROUND", 11, UI.track)
 local style = {ghost = true}
 UI.Button(name .. "Prev", frame, "<", 2, 0, 24, function() onStep(-1) end, style)
 local nextButton = UI.Button(name .. "Next", frame, ">", width - 26, 0, 24, function() onStep(1) end, style)
 frame.text = frame:CreateFontString(name .. "Text", "OVERLAY", "GameFontHighlightSmall")
 frame.text:SetPoint("LEFT", frame, "LEFT", 28, 0)
 frame.text:SetPoint("RIGHT", nextButton, "LEFT", -2, 0)
 UI.Color(frame.text, "text")
 frame:EnableMouseWheel(true)
 frame:SetScript("OnMouseWheel", function() onStep(arg1 > 0 and -1 or 1) end)
 return frame
end

-- "<  Page 1 of 2  >" in one frame, a footer of its page: centred along the
-- window's bottom, under the list in AddOn Options.
local function Pager(name, parent, onPage)
 local pager = {page = 1, pages = 1}
 local frame = CreateFrame("Frame", name, parent)
 frame:SetWidth(PAGER_WIDTH); frame:SetHeight(22)
 local text = frame:CreateFontString(name .. "Text", "OVERLAY", "GameFontDisableSmall")
 text:SetPoint("CENTER", frame, "CENTER", 0, 0)
 UI.Color(text, "hint")
 local style = {ghost = true}
 local prev = UI.Button(name .. "Prev", frame, "<", 0, 0, 24, function() onPage(-1) end, style)
 prev:ClearAllPoints(); prev:SetPoint("RIGHT", text, "LEFT", -8, 0)
 local nextButton = UI.Button(name .. "Next", frame, ">", 0, 0, 24, function() onPage(1) end, style)
 nextButton:ClearAllPoints(); nextButton:SetPoint("LEFT", text, "RIGHT", 8, 0)
 layout:Footer(parent, frame, (WIDTH - PAGER_WIDTH) / 2)
 function pager:Set(total)
  self.pages = math.max(1, math.ceil(total / ROWS_PER_PAGE))
  if self.page > self.pages then self.page = self.pages end
  if self.page < 1 then self.page = 1 end
  text:SetText("Page " .. self.page .. " of " .. self.pages)
  UI.SetEnabled(prev, self.page > 1)
  UI.SetEnabled(nextButton, self.page < self.pages)
  return (self.page - 1) * ROWS_PER_PAGE
 end
 return pager
end

-- One text box shared by every list: it opens over the clicked message,
-- Enter saves, Escape or leaving the box keeps the old text.
local inlineEdit, inlineAccept
local function EditInline(anchor, text, onAccept)
 inlineAccept = onAccept
 inlineEdit:SetParent(anchor:GetParent())
 inlineEdit:ClearAllPoints()
 inlineEdit:SetPoint("LEFT", anchor, "LEFT", -4, 0)
 inlineEdit:SetWidth(anchor:GetWidth() + 8)
 inlineEdit:SetFrameLevel(anchor:GetFrameLevel() + 5)
 inlineEdit:SetText(text or "")
 inlineEdit:Show()
 inlineEdit:SetFocus()
end

local function MessageButton(name, parent, x, width, onClick)
 local button = UI.Button(name, parent, "", x, -2, width, onClick, {ghost = true})
 local label = button:GetFontString()
 label:ClearAllPoints()
 label:SetPoint("LEFT", button, "LEFT", 6, 0)
 label:SetPoint("RIGHT", button, "RIGHT", -6, 0)
 label:SetJustifyH("LEFT")
 return button
end

-------------------------------------------------------------------------------------
-- Color picker. ColorPickerFrame is shared by every addon: FBT remembers which
-- profile and color it opened for, so a late callback never writes elsewhere.
-------------------------------------------------------------------------------------

local pickerOwner

local function ApplyPickedColor(owner, r, g, b)
 owner.color.r, owner.color.g, owner.color.b = r, g, b
 if owner.profile == Profile() then PaintSwatch(owner.swatch, owner.color) end
end

function Options.OnPickerColor()
 local owner = pickerOwner
 if not owner or owner.profile ~= Profile() then return end
 ApplyPickedColor(owner, ColorPickerFrame:GetColorRGB())
end

function Options.OnPickerCancel()
 local owner = pickerOwner
 if not owner then return end
 pickerOwner = nil
 ApplyPickedColor(owner, owner.previous.r, owner.previous.g, owner.previous.b)
end

-- Closes FBT's picker. restore puts the original color back (profile load,
-- reset, delete); otherwise the chosen color stays (closing the window).
-- Another addon's open picker is never touched.
function Options.RetireColorPicker(restore)
 local owner = pickerOwner
 if not owner then return end
 pickerOwner = nil
 if ColorPickerFrame:IsShown() and ColorPickerFrame.func == Options.OnPickerColor then
  HideUIPanel(ColorPickerFrame)
  if restore then ApplyPickedColor(owner, owner.previous.r, owner.previous.g, owner.previous.b) end
 end
end

local function PickColor(swatch, color)
 Options.RetireColorPicker(false)
 pickerOwner = {profile = Profile(), color = color, swatch = swatch,
  previous = {r = color.r, g = color.g, b = color.b}}
 ColorPickerFrame.func = Options.OnPickerColor
 ColorPickerFrame.cancelFunc = Options.OnPickerCancel
 ColorPickerFrame.opacityFunc = nil
 ColorPickerFrame.hasOpacity = nil
 ColorPickerFrame.previousValues = pickerOwner.previous
 ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
 ShowUIPanel(ColorPickerFrame)
end

-------------------------------------------------------------------------------------
-- Font editor: font, outline and size for normal and critical text. 0 means
-- inherit from the next table in the chain (event -> area -> master).
-------------------------------------------------------------------------------------

local KINDS = {"Normal", "Crit"}
local OUTLINE_LABELS = {"None", "Thin", "Thick"}
local OUTLINE_LABELS_INHERIT = {"Inherit", "None", "Thin", "Thick"}

-- The place of a font in the list; 0 for none (inherit).
local function FontPlace(name)
 for i, font in ipairs(FBT.AVAILABLE_FONTS) do if font.Name == name then return i end end
 return 0
end

local function Resolve(chain, kind, field)
 for _, settings in ipairs(chain) do
  local fs = settings[kind]
  if fs and fs[field] and fs[field] ~= 0 then return fs[field] end
 end
end

local function CreateFontEditor()
 local editor = UI.Window("FBT_FontEditor", "Fonts", 420, 330)
 editor:SetPoint("TOP", UIParent, "CENTER", 260, 190)
 editor.sections = {}

 local function Section(kind, y)
  local s = {kind = kind}
  s.heading = UI.Heading(editor, kind == "Crit" and "Critical hits" or "Normal hits", 28, y)
  s.font = Cycle("FBT_Font" .. kind .. "Face", editor, 28, y - 22, 220, function(step)
   local fonts, fs = FBT.AVAILABLE_FONTS, editor.target.own[kind]
   local low = editor.target.inherit and 0 or 1
   local value = FontPlace(fs.FontName) + step
   if value > #fonts then value = low elseif value < low then value = #fonts end
   fs.FontName = fonts[value] and fonts[value].Name
   editor.Changed()
  end)
  s.outlineButtons, s.SelectOutline, s.outlineTrack = UI.Segmented("FBT_Font" .. kind .. "Outline", editor,
   OUTLINE_LABELS_INHERIT, 264, y - 22, 128, function(index)
    local fs = editor.target.own[kind]
    fs.OutlineIndex = editor.target.inherit and index - 1 or index
    editor.Changed()
   end, {height = 22})
  s.outlineButtons3, s.SelectOutline3, s.outlineTrack3 = UI.Segmented("FBT_Font" .. kind .. "Outline3", editor,
   OUTLINE_LABELS, 264, y - 22, 128, function(index)
    editor.target.own[kind].OutlineIndex = index
    editor.Changed()
   end, {height = 22})
  s.inherit = UI.Switch("FBT_Font" .. kind .. "InheritSize", editor, "Inherit size",
   "Use the size of the area or master font.", 28, y - 56, function(value)
    local fs = editor.target.own[kind]
    fs.FontSize = value and 0 or (Resolve(editor.target.chain, kind, "FontSize") or 18)
    editor.Changed()
   end, 110)
  s.size = UI.Slider("FBT_Font" .. kind .. "Size", editor, "Size", 160, y - 54, 232, 12, 64, 2, function(value)
   editor.target.own[kind].FontSize = value
   editor.Changed()
  end)
  s.preview = editor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  s.preview:SetPoint("TOPLEFT", editor, "TOPLEFT", 28, y - 92)
  s.preview:SetText(kind == "Crit" and "12345 Crit!" or "1234 Normal")
  s.widgets = {s.heading, s.font, s.outlineTrack, s.outlineTrack3, s.inherit, s.inherit.label, s.size, s.size.label, s.size.valueText, s.preview}
  editor.sections[kind] = s
  return s
 end
 Section("Normal", -56)
 Section("Crit", -186)
 editor.note = UI.Label(editor, "The game damage font changes after you log in again.", 28, -90, "GameFontDisableSmall")

 local function ShowSection(s, shown)
  for _, w in ipairs(s.widgets) do if shown then w:Show() else w:Hide() end end
 end

 function editor.Refresh()
  local target = editor.target
  for _, kind in ipairs(KINDS) do
   local s, fs = editor.sections[kind], target.own[kind]
   ShowSection(s, fs ~= nil)
   if fs then
    local face = FBT.FONT_BY_NAME[fs.FontName or ""]
    local resolved = FBT.FONT_BY_NAME[Resolve(target.chain, kind, "FontName") or ""] or FBT.FONT_BY_NAME.Friz
    s.font.text:SetText(face and face.Name or ("Inherit: " .. resolved.Name))
    if target.blizzard then
     s.outlineTrack:Hide(); s.outlineTrack3:Hide(); s.inherit:Hide(); s.inherit.label:Hide()
     s.size:Hide(); s.size.label:Hide(); s.size.valueText:Hide()
    elseif target.inherit then
     s.outlineTrack3:Hide(); s.SelectOutline((fs.OutlineIndex or 0) + 1)
     UI.Sync(s.inherit, (fs.FontSize or 0) == 0)
    else
     s.outlineTrack:Hide(); s.SelectOutline3(fs.OutlineIndex or 1)
     s.inherit:Hide(); s.inherit.label:Hide()
    end
    local size = Resolve(target.chain, kind, "FontSize") or 18
    if not target.blizzard then
     UI.SetSlider(s.size, size)
     UI.SetEnabled(s.size, not target.inherit or (fs.FontSize or 0) ~= 0)
    end
    local outline = FBT.AVAILABLE_OUTLINES[Resolve(target.chain, kind, "OutlineIndex") or 1] or FBT.AVAILABLE_OUTLINES[1]
    s.preview:SetFont(resolved.Path, target.blizzard and 18 or size, outline.Style)
   end
  end
  if target.blizzard then editor.note:Show() else editor.note:Hide() end
  editor:SetHeight(target.own.Crit and 330 or (target.blizzard and 130 or 200))
 end

 function editor.Changed()
  if editor.target.blizzard then FBT.ApplyGameDamageFont() end
  editor.Refresh()
 end
 return editor
end

-- target: title, own = {Normal=..., Crit=...}, chain = font tables to resolve
-- through (own first), inherit = whether 0 (inherit) is allowed, blizzard.
local function EditFonts(target)
 if not fontEditor then fontEditor = CreateFontEditor() end
 fontEditor.target = target
 fontEditor.title:SetText(target.title)
 fontEditor.Refresh()
 fontEditor:Show()
end
Options.EditFonts = EditFonts

local function MasterChain()
 return {Profile().MasterFontSettings}
end

local function AreaChain(area)
 return {Profile().DisplaySettings[area].FontSettings, Profile().MasterFontSettings}
end

function Options.EditEventFonts(area, eventType, label)
 local settings = Profile().EventSettings[eventType].FontSettings
 local chain = AreaChain(area)
 table.insert(chain, 1, settings)
 EditFonts({title = label, own = {Normal = settings.Normal, Crit = settings.Crit}, chain = chain, inherit = true})
end

-------------------------------------------------------------------------------------
-- Pages are built as sections (ForgeLayout.lua): two columns in the 600-wide
-- window, one at full size in AddOn Options. Lists and rows are blocks that lay
-- themselves out for the width they get: the window's places at 440 and over,
-- stacked under that.
-------------------------------------------------------------------------------------

local function Move(region, parent, x, y)
 region:ClearAllPoints()
 region:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
end

-------------------------------------------------------------------------------------
-- General tab.
-------------------------------------------------------------------------------------

local function BuildGeneral(page)
 local switches = {}
 layout:Heading(page, L, "Display")
 local enabled = UI.Switch("FBT_Enabled", page, "Enable", "Show scrolling combat text. While off, the game shows its own damage numbers.", 0, 0, function(value)
  FBT.SetOptionUserDisabled(not value)
  Refresh()
 end)
 layout:Switch(page, L, enabled)
 -- shown: a switch that only some characters can use. The others do not see
 -- it, and it takes no room (so it must not be first under a heading).
 local function ProfileSwitch(column, key, text, tip, after, shown)
  local switch = UI.Switch("FBT_" .. key, page, text, tip, 0, 0, function(value)
   Profile()[key] = value
   if after then after(value) end
  end)
  switches[key] = switch
  if not shown then return layout:Switch(page, column, switch, {before = ROW_GAP}) end
  layout:Add(page, column, {before = ROW_GAP, place = function(x, y)
   if not shown() then switch:Hide(); return -ROW_GAP end
   switch:Show(); Move(switch, page, x, y - 2)
   return 26
  end})
 end
 local function HasMana() return UnitPowerMax("player", 0) > 0 end
 local function IsMage() local _, class = UnitClass("player"); return class == "MAGE" end
 ProfileSwitch(L, "ShowPartialEffects", "Partial effects", "Add absorbed, blocked, resisted, crushing and glancing amounts, and overhealing.")
 ProfileSwitch(L, "UseStickyCrits", "Sticky criticals", "Critical hits pop in the middle of the area instead of scrolling.")
 ProfileSwitch(L, "ShowAllManaGains", "All mana gains", "Show every mana increase, including regeneration and drinking.", function()
  -- Mana is observed only while something reads it.
  Combat.UpdateUnitEvents()
 end, HasMana)
 local gameDamage = UI.Switch("FBT_ShowGameDamage", page, "Game damage text", "Keep the game's own damage numbers above enemies.", 0, 0, function(value)
  FBT.SetOptionShowGameDamage(value)
 end)
 layout:Switch(page, L, gameDamage, {before = ROW_GAP})

 layout:Heading(page, R, "Sounds")
 ProfileSwitch(R, "LowHealthSound", "Low health", "Play a sound when a low health trigger fires.")
 ProfileSwitch(R, "LowManaSound", "Low mana", "Play a sound when a low mana trigger fires.", nil, HasMana)
 ProfileSwitch(R, "ResistSound", "Frost resists", "Play a sound when your Cone of Cold or Frost Nova is resisted.", nil, IsMage)

 layout:Section(page)
 local speed = UI.Slider("FBT_AnimationStep", page, "Scroll speed", 0, 0, SIDE, 1, 5, 0.5, function(value)
  Profile().AnimationStep = value
 end)
 layout:Slider(page, L, speed, {before = {22, 12}})
 layout:Button(page, R, UI.Button("FBT_MasterFonts", page, "Fonts", 0, 0, 172, function()
  local fonts = Profile().MasterFontSettings
  EditFonts({title = "Master fonts", own = {Normal = fonts.Normal, Crit = fonts.Crit}, chain = MasterChain(), inherit = false})
 end), {before = {18, 4}, indent = 36})
 layout:Button(page, R, UI.Button("FBT_GameDamageFont", page, "Game damage font", 0, 0, 172, function()
  local fonts = Profile().BlizzardFontSettings
  EditFonts({title = "Game damage font", own = {Normal = fonts.Normal}, chain = {fonts}, inherit = false, blizzard = true})
 end), {before = 6, indent = 36})

 return function()
  local enabledNow = not FostercareBattleTextDB.UserDisabled
  UI.Sync(enabled, enabledNow)
  for key, widget in pairs(switches) do UI.Sync(widget, Profile()[key], enabledNow) end
  UI.Sync(gameDamage, Profile().ShowGameDamage, enabledNow)
  UI.SetSlider(speed, Profile().AnimationStep)
 end
end

-------------------------------------------------------------------------------------
-- Areas tab: layout of the three scroll areas, movers and preview.
-------------------------------------------------------------------------------------

local movers = {}

local function PlaceMover(area)
 local settings = Profile().DisplaySettings[area]
 local mover = movers[area]
 mover:ClearAllPoints()
 mover:SetPoint("BOTTOM", UIParent, "CENTER", settings.FrameOffsets.x, settings.FrameOffsets.y)
 mover:SetHeight(settings.ScrollHeight)
 mover.label:SetText(AREA_LABELS[area] .. " (" .. settings.FrameOffsets.x .. ", " .. settings.FrameOffsets.y .. ")")
end

local function CreateMover(area)
 local mover = CreateFrame("Frame", "FBT_Mover" .. area, UIParent)
 mover:SetWidth(80)
 mover:SetFrameStrata("DIALOG")
 mover:EnableMouse(true); mover:SetMovable(true); mover:SetClampedToScreen(true)
 mover:RegisterForDrag("LeftButton")
 UI.Rounded(mover, "BACKGROUND", 8, UI.selected)
 mover.label = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
 mover.label:SetPoint("BOTTOM", mover, "TOP", 0, 4)
 UI.Color(mover.label, "heading")
 mover:SetScript("OnDragStart", function() mover:StartMoving() end)
 mover:SetScript("OnDragStop", function()
  mover:StopMovingOrSizing()
  local centerX, centerY = UIParent:GetCenter()
  local offsets = Profile().DisplaySettings[area].FrameOffsets
  offsets.x = math.floor(mover:GetCenter() - centerX)
  offsets.y = math.ceil(mover:GetBottom() - centerY)
  FBT.RepositionAnimationFrames()
  PlaceMover(area)
 end)
 mover:Hide()
 movers[area] = mover
end

local function ShowMovers(shown)
 moversShown = shown
 for _, area in ipairs(AREAS) do
  if not movers[area] then CreateMover(area) end
  if shown then PlaceMover(area); movers[area]:Show() else movers[area]:StopMovingOrSizing(); movers[area]:Hide() end
 end
end

local function BuildAreas(page)
 local function Settings() return Profile().DisplaySettings[selectedArea] end
 local _, SelectArea, areaTrack = UI.Segmented("FBT_Area", page, {"Incoming", "Outgoing", "Notices"}, 0, 0, 300, function(index)
  selectedArea = AREAS[index]
  Refresh()
 end, {height = 26})
 local show = UI.Switch("FBT_AreaShow", page, "Show this area", "Show the events of this area.", 0, 0, function(value)
  Settings().Show = value
 end)
 layout:Section(page, true)
 -- The area to set, and whether it shows: one line in the window, two narrower.
 layout:Add(page, L, {place = function(x, y, width)
  Move(areaTrack, page, x, y)
  if width >= WIDE then Move(show, page, x + 324, y - 8); return 32 end
  Move(show, page, x, y - 36)
  return 58
 end})

 layout:Heading(page, L, "Movement")
 local _, SelectStyle, styleTrack = UI.Segmented("FBT_AreaStyle", page, {"Straight", "Curve left", "Curve right"}, 0, 0, 300, function(index)
  Settings().AnimationStyle = index
  Refresh()
 end, {height = 24})
 local _, SelectDirection, directionTrack = UI.Segmented("FBT_AreaDirection", page, {"Up", "Down"}, 0, 0, 120, function(index)
  Settings().ScrollDirection = index
  Refresh()
 end, {height = 24})
 layout:Add(page, L, {place = function(x, y, width)
  Move(styleTrack, page, x, y)
  if width >= WIDE then Move(directionTrack, page, x + 324, y); return 26 end
  Move(directionTrack, page, x, y - 30)
  return 56
 end})

 layout:Heading(page, L, "Text")
 local _, SelectAlign, alignTrack = UI.Segmented("FBT_AreaAlign", page, {"Left", "Center", "Right"}, 0, 0, 300, function(index)
  Settings().FontSettings.TextAlignIndex = index
  Refresh()
 end, {height = 24})
 layout:Add(page, L, {height = 40, regions = {{alignTrack, "TOPLEFT", "TOPLEFT", 0, 0}}})

 local height = UI.Slider("FBT_AreaHeight", page, "Scroll height", 0, 0, 300, 100, 600, 10, function(value)
  Settings().ScrollHeight = value
  if moversShown then PlaceMover(selectedArea) end
 end)
 local unlock = UI.Button("FBT_AreaUnlock", page, "Move areas", 0, 0, 120, function()
  ShowMovers(not moversShown)
  Refresh()
 end)
 local preview = UI.Button("FBT_AreaPreview", page, "Preview", 0, 0, 120, function()
  FBT.DisplayMessage("Incoming", FBT.DISPLAYTYPE_INCOMING, false, 255, 80, 80)
  FBT.DisplayMessage("Outgoing", FBT.DISPLAYTYPE_OUTGOING, false, 255, 255, 255)
  FBT.DisplayMessage("Notices", FBT.DISPLAYTYPE_NOTIFICATION, false, 255, 220, 120)
 end)
 local areaFonts = UI.Button("FBT_AreaFonts", page, "Area fonts", 0, 0, 120, function()
  local fonts = Profile().DisplaySettings[selectedArea].FontSettings
  EditFonts({title = AREA_LABELS[selectedArea] .. " fonts", own = {Normal = fonts.Normal, Crit = fonts.Crit},
   chain = AreaChain(selectedArea), inherit = true})
 end)
 local reset = UI.Button("FBT_AreaReset", page, "Reset positions", 0, 0, 140, function()
  for _, area in ipairs(AREAS) do
   local default = FBT.DEFAULT_CONFIG.DisplaySettings[area].FrameOffsets
   Profile().DisplaySettings[area].FrameOffsets.x = default.x
   Profile().DisplaySettings[area].FrameOffsets.y = default.y
  end
  FBT.RepositionAnimationFrames()
  if moversShown then ShowMovers(true) end
 end)
 -- The height slider with the buttons beside it in the window; one a line narrower.
 layout:Add(page, L, {place = function(x, y, width)
  if width >= WIDE then
   UI.MoveSlider(height, page, x, y, 300)
   Move(unlock, page, x + 324, y); Move(preview, page, x + 324, y - 30)
   Move(areaFonts, page, x + 324, y - 60); Move(reset, page, x, y - 60)
   return 98
  end
  UI.MoveSlider(height, page, x, y, math.min(300, width))
  Move(unlock, page, x, y - 46); Move(preview, page, x, y - 76)
  Move(areaFonts, page, x, y - 106); Move(reset, page, x, y - 136)
  return 162
 end})
 layout:Hint(page, L, "Move areas shows a handle per area; drag it to place the area.", {before = 0})

 return function()
  local settings = Settings()
  for i, area in ipairs(AREAS) do if area == selectedArea then SelectArea(i) end end
  UI.Sync(show, settings.Show)
  SelectStyle(settings.AnimationStyle)
  SelectDirection(settings.ScrollDirection)
  SelectAlign(settings.FontSettings.TextAlignIndex)
  UI.SetSlider(height, settings.ScrollHeight)
  UI.Select(unlock, moversShown)
 end
end

-------------------------------------------------------------------------------------
-- Lists: ten rows a page, a pager under them. In the window every page keeps
-- room for ten rows; in AddOn Options only the rows shown take room.
-------------------------------------------------------------------------------------

local function ListBlock(page, rows, placeRow)
 layout:Add(page, L, {place = function(x, y, width)
  local wide, top = width >= WIDE, y
  for _, row in ipairs(rows) do
   if wide or row:IsShown() then
    Move(row, page, x, y)
    row:SetWidth(width)
    y = y - placeRow(row, wide, width) - 2
   end
  end
  return top - y
 end})
end

-------------------------------------------------------------------------------------
-- Incoming, Outgoing and Notices tabs: one row per event.
-------------------------------------------------------------------------------------

local function BuildEvents(page, area)
 local rows, pager = {}, nil
 local prefix = "FBT_" .. area .. "Row"
 local notices = area == "Notification"
 layout:Section(page, true)
 layout:Heading(page, L, "Show / Color / Message (click to edit) / Font")
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row(prefix .. i, page, 0, 0, WIDTH - 56)
  row.show = UI.Switch(prefix .. i .. "Show", row, "", nil, 4, -5, function(value)
   Profile().EventSettings[row.eventType].Show = value
  end, 150)
  row.swatch = Swatch(prefix .. i .. "Color", row, function()
   PickColor(row.swatch, Profile().EventSettings[row.eventType].FontSettings.Color)
  end)
  row.message = MessageButton(prefix .. i .. "Message", row, 214, notices and 168 or 220, function()
   EditInline(row.message, Profile().EventSettings[row.eventType].Message, function(text)
    Profile().EventSettings[row.eventType].Message = text
    Refresh()
   end)
  end)
  if notices then
   row.sticky = UI.Button(prefix .. i .. "Sticky", row, "Sticky", 438, -2, 52, function()
    local settings = Profile().EventSettings[row.eventType]
    settings.IsSticky = not settings.IsSticky
    Refresh()
   end, {ghost = true})
   UI.Tooltip(row.sticky, "Pop this event in the middle of the area instead of scrolling it.")
   row.icon = UI.Button(prefix .. i .. "Icon", row, "Icon", 386, -2, 48, function()
    local settings = Profile().EventSettings[row.eventType]
    settings.BigIcon = not settings.BigIcon
    Refresh()
   end, {ghost = true})
   UI.Tooltip(row.icon, "Show a large icon beside this message.")
  end
  row.font = UI.Button(prefix .. i .. "Font", row, "Font", 494, -2, 44, function()
   Options.EditEventFonts(area, row.eventType, row.show.label:GetText())
  end, {ghost = true})
  rows[i] = row
 end
 -- One line in the window; narrower, the message and its buttons on a second line.
 ListBlock(page, rows, function(row, wide, width)
  row:SetHeight(wide and 26 or 52)
  if wide then
   Move(row.swatch, row, 190, -5); Move(row.message, row, 214, -2)
   row.message:SetWidth(notices and 168 or 220)
   if notices then Move(row.icon, row, 386, -2); Move(row.sticky, row, 438, -2) end
   Move(row.font, row, width - 50, -2)
   return 26
  end
  Move(row.swatch, row, width - 78, -5); Move(row.font, row, width - 50, -2)
  Move(row.message, row, 4, -26)
  row.message:SetWidth(width - 8 - (notices and 108 or 0))
  if notices then Move(row.icon, row, width - 108, -26); Move(row.sticky, row, width - 56, -26) end
  return 52
 end)
 pager = Pager(prefix .. "Pager", page, function(step) pager.page = pager.page + step; Refresh() end)

 return function()
  local list = EVENTS[area]
  local offset = pager:Set(table.getn(list))
  for i, row in ipairs(rows) do
   local entry = list[offset + i]
   if entry then
    local settings = Profile().EventSettings[entry.Type]
    row.eventType = entry.Type
    row.show.label:SetText(entry.Label)
    UI.Tooltip(row.show, entry.Tip)
    UI.Tooltip(row.message, entry.Codes)
    UI.Sync(row.show, settings.Show)
    PaintSwatch(row.swatch, settings.FontSettings.Color)
    row.message:SetText(settings.Message or "")
    if row.sticky then UI.Select(row.sticky, settings.IsSticky and true or false) end
    if row.icon then
     if FBT.BIG_ICONS[entry.Type] then
      row.icon:Show()
      UI.Select(row.icon, settings.BigIcon and true or false)
     else
      row.icon:Hide()
     end
    end
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Trigger editor: works on a copy and writes it on Save.
-------------------------------------------------------------------------------------

local CLASSES = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}
local CLASS_LABELS = {DRUID = "Druid", HUNTER = "Hunter", MAGE = "Mage", PALADIN = "Paladin", PRIEST = "Priest",
 ROGUE = "Rogue", SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior"}
local function CopyTable(t)
 return type(t) == "table" and FBT.CopyTable(t) or t
end

local function CreateTriggerEditor()
 local editor = UI.Window("FBT_TriggerEditor", "Trigger", 460, 360)
 editor:SetPoint("TOP", UIParent, "CENTER", 280, 190)
 local work

 UI.Heading(editor, "Type", 28, -56)
 editor.type = Cycle("FBT_TriggerType", editor, 28, -74, 220, function(step)
  local types = FBT.AVAILABLE_TRIGGER_TYPES
  local count, index = table.getn(types), 1
  for i, info in ipairs(types) do if info.Type == work.TriggerType then index = i end end
  work.TriggerType = types[(index - 1 + step + count) % count + 1].Type
  editor.Refresh()
 end)
 UI.Heading(editor, "Icon", 264, -56)
 editor.icon = TextBox("FBT_TriggerIcon", editor, 264, -75, 168)
 UI.Tooltip(editor.icon, "Path of an icon to show, such as Interface\\Icons\\Ability_Warrior_Charge. Leave empty for none.")

 UI.Heading(editor, "Classes", 28, -108)
 editor.allClasses = UI.Switch("FBT_TriggerAllClasses", editor, "All classes", nil, 28, -126, function(value)
  if value then work.Classes = nil else work.Classes = {} end
  editor.Refresh()
 end, 110)
 editor.classes = {}
 for i, class in ipairs(CLASSES) do
  local key = class
  local col, line = (i - 1) % 3, math.floor((i - 1) / 3)
  editor.classes[key] = UI.Switch("FBT_TriggerClass" .. key, editor, CLASS_LABELS[key], nil, 28 + col * 136, -154 - line * 24, function(value)
   work.Classes[key] = value or nil
  end, 100)
 end

 local y = -236
 editor.thresholdHeading = UI.Heading(editor, "Threshold", 28, y)
 editor.threshold = UI.Slider("FBT_TriggerThreshold", editor, "Below this percent", 28, y - 20, 404, 1, 100, 1, function(value)
  work.Threshold = value
 end)
 editor.auraHeading = UI.Heading(editor, "Aura name", 28, y)
 editor.aura = TextBox("FBT_TriggerAura", editor, 28, y - 18, 404)
 UI.Tooltip(editor.aura, "The exact name of the buff, for example Clearcasting.")
 editor.stanceHeading = UI.Heading(editor, "Stance or form", 28, y - 48)
 editor.stance = Cycle("FBT_TriggerStance", editor, 28, y - 66, 404, function(step)
  local count = table.getn(FBT.AVAILABLE_STANCES)
  work.Stance = ((work.Stance or count) - 1 + step + count) % count + 1
  if work.Stance == count then work.Stance = nil end
  editor.Refresh()
 end)

 local save = UI.Button("FBT_TriggerSave", editor, "Save", 0, 0, 120, function() editor.Save() end)
 save:ClearAllPoints(); save:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", 28, 18)
 local cancel = UI.Button("FBT_TriggerCancel", editor, "Cancel", 0, 0, 120, function() editor:Hide() end)
 cancel:ClearAllPoints(); cancel:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", 156, 18)

 local thresholdWidgets = {editor.thresholdHeading, editor.threshold}
 local auraWidgets = {editor.auraHeading, editor.aura}
 local stanceWidgets = {editor.stanceHeading, editor.stance}
 local function Shown(widget, shown)
  if shown then widget:Show() else widget:Hide() end
  if widget.label then Shown(widget.label, shown) end
  if widget.valueText then Shown(widget.valueText, shown) end
 end

 function editor.Refresh()
  local triggerType = work.TriggerType
  local isThreshold = triggerType <= Combat.TRIGGERTYPE_FRIENDLY_HEALTH
  local isAura = triggerType == Combat.TRIGGERTYPE_AURA_GAIN
  for _, info in ipairs(FBT.AVAILABLE_TRIGGER_TYPES) do
   if info.Type == triggerType then editor.type.text:SetText(info.Name) end
  end
  UI.Sync(editor.allClasses, work.Classes == nil)
  for key, widget in pairs(editor.classes) do
   UI.Sync(widget, work.Classes and work.Classes[key] or false, work.Classes ~= nil)
  end
  for _, w in ipairs(thresholdWidgets) do Shown(w, isThreshold) end
  for _, w in ipairs(auraWidgets) do Shown(w, isAura) end
  for _, w in ipairs(stanceWidgets) do Shown(w, not isThreshold) end
  if isThreshold then UI.SetSlider(editor.threshold, work.Threshold or 40) end
  local stances = FBT.AVAILABLE_STANCES
  editor.stance.text:SetText(stances[work.Stance or table.getn(stances)].Name)
  editor:SetHeight(isThreshold and 330 or 360)
 end

 function editor.Open(triggerKey)
  local trigger = Profile().Triggers[triggerKey]
  editor.key, editor.profile = triggerKey, Profile()
  work = CopyTable(trigger.TriggerSettings)
  editor.title:SetText(trigger.EventSettings.Message or "Trigger")
  editor.icon:SetText(trigger.Texture or "")
  editor.aura:SetText(work.AuraName or "")
  editor.Refresh()
  editor:Show()
 end

 function editor.Save()
  local trigger = editor.profile == Profile() and Profile().Triggers[editor.key]
  if not trigger then editor:Hide(); return end
  local triggerType = work.TriggerType
  local settings = {TriggerType = triggerType, Classes = work.Classes}
  if triggerType <= Combat.TRIGGERTYPE_FRIENDLY_HEALTH then
   settings.Threshold = work.Threshold or 40
  else
   settings.Stance = work.Stance
   if settings.Stance and not GetShapeshiftFormInfo(settings.Stance) then
    FBT.Print("This character has no such stance, so the trigger will not fire.", 1, 1, 0)
   end
   if triggerType == Combat.TRIGGERTYPE_AURA_GAIN then
    settings.AuraName = editor.aura:GetText()
   end
  end
  trigger.TriggerSettings = settings
  local icon = editor.icon:GetText()
  trigger.Texture = icon ~= "" and icon or nil
  FBT.RegisterTriggers()
  editor:Hide()
  Refresh()
 end
 return editor
end

function Options.EditTrigger(triggerKey)
 if not triggerEditor then triggerEditor = CreateTriggerEditor() end
 triggerEditor.Open(triggerKey)
end

-------------------------------------------------------------------------------------
-- Triggers tab.
-------------------------------------------------------------------------------------

local function BuildTriggers(page)
 local rows, pager, keys = {}, nil, {}
 layout:Section(page, true)
 layout:Heading(page, L, "On / Message (click to edit) / Color")
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("FBT_TriggerRow" .. i, page, 0, 0, WIDTH - 56)
  local function Trigger() return Profile().Triggers[row.key] end
  row.show = UI.Switch("FBT_TriggerRow" .. i .. "Show", row, "", "Turn this trigger on or off.", 4, -5, function(value)
   Trigger().EventSettings.Show = value
   FBT.RegisterTriggers()
  end, 20)
  row.message = MessageButton("FBT_TriggerRow" .. i .. "Message", row, 40, 230, function()
   EditInline(row.message, Trigger().EventSettings.Message, function(text)
    Trigger().EventSettings.Message = text
    Refresh()
   end)
  end)
  UI.Tooltip(row.message, "%1 shows the health or mana amount.")
  row.swatch = Swatch("FBT_TriggerRow" .. i .. "Color", row, function()
   PickColor(row.swatch, Trigger().EventSettings.FontSettings.Color)
  end)
  row.sticky = UI.Button("FBT_TriggerRow" .. i .. "Sticky", row, "Sticky", 300, -2, 52, function()
   Trigger().EventSettings.IsSticky = not Trigger().EventSettings.IsSticky
   Refresh()
  end, {ghost = true})
  row.font = UI.Button("FBT_TriggerRow" .. i .. "Font", row, "Font", 356, -2, 44, function()
   local settings = Trigger().EventSettings.FontSettings
   local chain = AreaChain("Notification")
   table.insert(chain, 1, settings)
   EditFonts({title = Trigger().EventSettings.Message, own = {Normal = settings.Normal}, chain = chain, inherit = true})
  end, {ghost = true})
  row.edit = UI.Button("FBT_TriggerRow" .. i .. "Edit", row, "Edit", 404, -2, 50, function()
   Options.EditTrigger(row.key)
  end, {ghost = true})
  row.delete = UI.Button("FBT_TriggerRow" .. i .. "Delete", row, "X", 512, -2, 26, function()
   Profile().Triggers[row.key] = nil
   FBT.RegisterTriggers()
   Refresh()
  end, {ghost = true})
  UI.Tooltip(row.delete, "Delete this trigger.")
  rows[i] = row
 end
 -- One line in the window; narrower, the color and buttons on a second line.
 ListBlock(page, rows, function(row, wide, width)
  row:SetHeight(wide and 26 or 52)
  Move(row.delete, row, width - 32, -2)
  if wide then
   row.message:SetWidth(230)
   Move(row.swatch, row, 278, -5); Move(row.sticky, row, 300, -2)
   Move(row.font, row, 356, -2); Move(row.edit, row, 404, -2)
   return 26
  end
  row.message:SetWidth(width - 76)
  Move(row.swatch, row, 44, -31); Move(row.sticky, row, 68, -28)
  Move(row.font, row, 124, -28); Move(row.edit, row, 172, -28)
  return 52
 end)
 pager = Pager("FBT_TriggerPager", page, function(step) pager.page = pager.page + step; Refresh() end)
 layout:Footer(page, UI.Button("FBT_TriggerAdd", page, "Add trigger", 0, 0, 140, function()
  local n = 1
  while Profile().Triggers["MSBT_TRIGGER_CUSTOM" .. n] do n = n + 1 end
  Profile().Triggers["MSBT_TRIGGER_CUSTOM" .. n] = {
   EventSettings = {Show = true, Message = "New trigger", IsSticky = false,
    FontSettings = {Color = {r = 1, g = 0.502, b = 0.502}, Normal = {OutlineIndex = 0, FontSize = 26}}},
   TriggerSettings = {TriggerType = 1, Threshold = 40},
  }
  FBT.RegisterTriggers()
  Refresh()
  Options.EditTrigger("MSBT_TRIGGER_CUSTOM" .. n)
 end), LEFT)

 return function()
  keys = SortedKeys(Profile().Triggers)
  local offset = pager:Set(table.getn(keys))
  for i, row in ipairs(rows) do
   local key = keys[offset + i]
   if key then
    local settings = Profile().Triggers[key].EventSettings
    row.key = key
    UI.Sync(row.show, settings.Show)
    row.message:SetText(settings.Message or "")
    PaintSwatch(row.swatch, settings.FontSettings.Color)
    UI.Select(row.sticky, settings.IsSticky and true or false)
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Filters tab (suppressions).
-------------------------------------------------------------------------------------

local function BuildFilters(page)
 local rows, pager = {}, nil
 layout:Section(page, true)
 layout:Heading(page, L, "Hide messages that contain")
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("FBT_FilterRow" .. i, page, 0, 0, WIDTH - 56)
  local function Filter() return Profile().Suppressions[row.key] end
  row.show = UI.Switch("FBT_FilterRow" .. i .. "On", row, "", "Turn this filter on or off.", 4, -5, function(value)
   Filter().Enabled = value
  end, 20)
  row.pattern = MessageButton("FBT_FilterRow" .. i .. "Pattern", row, 40, 460, function()
   EditInline(row.pattern, Filter().SearchPattern, function(text)
    Filter().SearchPattern = text
    Refresh()
   end)
  end)
  UI.Tooltip(row.pattern, "Hides every message whose text or spell name contains this text.")
  row.delete = UI.Button("FBT_FilterRow" .. i .. "Delete", row, "X", 512, -2, 26, function()
   Profile().Suppressions[row.key] = nil
   Refresh()
  end, {ghost = true})
  rows[i] = row
 end
 -- One line at every width: the text takes what the switch and X leave.
 ListBlock(page, rows, function(row, wide, width)
  row.pattern:SetWidth(wide and 460 or width - 76)
  Move(row.delete, row, width - 32, -2)
  return 26
 end)
 pager = Pager("FBT_FilterPager", page, function(step) pager.page = pager.page + step; Refresh() end)
 layout:Footer(page, UI.Button("FBT_FilterAdd", page, "Add filter", 0, 0, 140, function()
  -- One above the highest number, so the newest filter sorts first.
  local n = 1
  for key in pairs(Profile().Suppressions) do
   local number = tonumber(string.match(key, "^MSBT_SUPPRESSION_CUSTOM(%d+)$"))
   if number and number >= n then n = number + 1 end
  end
  Profile().Suppressions["MSBT_SUPPRESSION_CUSTOM" .. n] = {Enabled = true, SearchPattern = "New filter"}
  pager.page = 1
  Refresh()
 end), LEFT)

 return function()
  -- Custom filters first, newest on top; the built-in ones follow by name.
  local keys = SortedKeys(Profile().Suppressions)
  local function Custom(key) return tonumber(string.match(key, "^MSBT_SUPPRESSION_CUSTOM(%d+)$")) end
  table.sort(keys, function(a, b)
   local ca, cb = Custom(a), Custom(b)
   if ca and cb then return ca > cb end
   if ca or cb then return ca ~= nil end
   return a < b
  end)
  local offset = pager:Set(table.getn(keys))
  for i, row in ipairs(rows) do
   local key = keys[offset + i]
   if key then
    local filter = Profile().Suppressions[key]
    row.key = key
    UI.Sync(row.show, filter.Enabled)
    row.pattern:SetText(filter.SearchPattern or "")
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Profiles tab.
-------------------------------------------------------------------------------------

local function AfterProfileChange()
 if fontEditor then fontEditor:Hide() end
 if triggerEditor then triggerEditor:Hide() end
 if moversShown then ShowMovers(true) end
end

function Options.LoadProfile(name)
 Options.RetireColorPicker(true)
 FBT.SelectProfile(name)
 AfterProfileChange()
end

local function BuildProfiles(page)
 local rows, pager = {}, nil
 local listHeading = UI.Heading(page, "Profiles (each character picks one)", 0, 0)
 for i = 1, ROWS_PER_PAGE do
  local row = UI.Row("FBT_ProfileRow" .. i, page, 0, 0, 300)
  row.radio = UI.Radio("FBT_ProfileRow" .. i .. "Use", row)
  row.radio:SetPoint("LEFT", row, "LEFT", 4, 0)
  row.radio:SetScript("OnClick", function()
   Options.LoadProfile(row.name)
   Refresh()
  end)
  row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.label:SetPoint("LEFT", row.radio, "RIGHT", 8, 0)
  UI.Color(row.label, "text")
  row.delete = UI.Button("FBT_ProfileRow" .. i .. "Delete", row, "Delete", 236, -2, 60, function()
   Options.RetireColorPicker(true)
   FBT.DeleteProfile(row.name)
   AfterProfileChange()
   Refresh()
  end, {ghost = true})
  rows[i] = row
 end
 pager = Pager("FBT_ProfilePager", page, function(step) pager.page = pager.page + step; Refresh() end)

 local newHeading = UI.Heading(page, "New profile", 0, 0)
 local name = TextBox("FBT_ProfileName", page, 0, 0, 172)
 local create = UI.Button("FBT_ProfileCreate", page, "Create", 0, 0, 172, function()
  local text = name:GetText()
  if text ~= "" and not FBT.ProfileExists(text) then
   FBT.CreateProfile(text)
   name:SetText("")
   Refresh()
  end
 end)
 local note = UI.Label(page, "New profiles start from the defaults.", 0, 0, "GameFontDisableSmall")
 local reset = UI.Button("FBT_ProfileReset", page, "Reset this profile", 0, 0, 172, function()
  Options.RetireColorPicker(true)
  FBT.ResetProfile(FBT.CurrentProfileName(), true)
  AfterProfileChange()
  Refresh()
 end)
 -- The list 300 wide with "New profile" beside it in the window; under it narrower.
 layout:Section(page, true)
 layout:Add(page, L, {place = function(x, y, width)
  local wide, top = width >= WIDE, y
  Move(listHeading, page, x, y)
  y = y - 20
  for _, row in ipairs(rows) do
   if wide or row:IsShown() then
    local rowWidth = wide and 300 or width
    Move(row, page, x, y); row:SetWidth(rowWidth)
    Move(row.delete, row, rowWidth - 64, -2)
    y = y - 28
   end
  end
  local newX, newY = x + 324, top
  if not wide then newX, newY = x, y - 14 end
  Move(newHeading, page, newX, newY); Move(name, page, newX, newY - 20)
  Move(create, page, newX, newY - 48); Move(note, page, newX, newY - 76)
  Move(reset, page, newX, newY - 112)
  if wide then return top - y end
  return top - newY + 136
 end})

 return function()
  local names = SortedKeys(FostercareBattleTextDB.Profiles)
  local offset = pager:Set(table.getn(names))
  for i, row in ipairs(rows) do
   local profileName = names[offset + i]
   if profileName then
    row.name = profileName
    row.label:SetText(profileName)
    UI.SetCheck(row.radio, profileName == FBT.CurrentProfileName())
    UI.SetEnabled(row.delete, profileName ~= FBT.DEFAULT_PROFILE_NAME)
    row:Show()
   else
    row:Hide()
   end
  end
 end
end

-------------------------------------------------------------------------------------
-- Window and AddOn Options.
-------------------------------------------------------------------------------------

local TABS = {
 {label = "General", height = 410, build = BuildGeneral},
 {label = "Areas", height = 430, build = BuildAreas},
 {label = "Incoming", height = 460, build = function(page) return BuildEvents(page, "Incoming") end},
 {label = "Outgoing", height = 460, build = function(page) return BuildEvents(page, "Outgoing") end},
 {label = "Notices", height = 460, build = function(page) return BuildEvents(page, "Notification") end},
 {label = "Triggers", height = 460, build = BuildTriggers},
 {label = "Filters", height = 460, build = BuildFilters},
 {label = "Profiles", height = 460, build = BuildProfiles},
}

-- Keep the chosen color; close FBT's own editors and movers.
local function CloseExtras()
 Options.RetireColorPicker(false)
 inlineEdit:Hide()
 if fontEditor then fontEditor:Hide() end
 if triggerEditor then triggerEditor:Hide() end
 if moversShown then ShowMovers(false) end
end

panel = UI.Window("FBT_Options", "Fostercare Battle Text", WIDTH, 410, FBT.VERSION)
local pages
pages, ShowTab = UI.Tabs(panel, "FBT_", TABS, function(index)
 tab = index
 Refresh()
end)
for i, page in ipairs(pages) do refresh[i] = TABS[i].build(page) end

inlineEdit = TextBox("FBT_InlineEdit", panel, 0, 0, 200, function(text)
 inlineEdit:Hide()
 if inlineAccept then inlineAccept(text) end
end)
inlineEdit:SetScript("OnEscapePressed", function() inlineEdit:Hide() end)
inlineEdit:SetScript("OnEditFocusLost", function() inlineEdit:Hide() end)
inlineEdit:Hide()

-- A page back from AddOn Options is hidden even when its tab is the active one.
panel:SetScript("OnShow", function() ShowTab(tab); pages[tab]:Show() end)
panel:SetScript("OnHide", CloseExtras)

-- Game Menu > AddOn Options > FostercareBattleText (ClassicAPI): the same eight
-- pages, one category each, in one column (ForgeLayout.lua).
book = UI.Book({
 name = addonName, text = "Open a page under " .. addonName .. ", or type /fbt for the settings window.",
 open = function() Options.ShowTab(1) end,
 panel = panel, pages = pages, tabs = TABS, layout = layout, refresh = Refresh,
 select = function(index) tab = index end,
 hide = CloseExtras,
})

local function CloseAddOnOptions()
 if InterfaceOptionsFrame:IsShown() then InterfaceOptionsFrame:Hide() end
end

function Options.Toggle()
 if panel:IsShown() then panel:Hide() else CloseAddOnOptions(); panel:Show() end
end

-- Opens a tab (1-8); used by tests and the AddOn Options entry.
function Options.ShowTab(index)
 CloseAddOnOptions()
 tab = index
 if panel:IsShown() then ShowTab(index) else panel:Show() end
end
