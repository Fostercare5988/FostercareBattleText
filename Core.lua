-------------------------------------------------------------------------------------
-- FostercareBattleText: profiles, merging and the scroll areas.
-------------------------------------------------------------------------------------

local addonName, FBT = ...
if not FBT.ready then return end

local Combat = FBT.Combat
local string_find, string_gsub, string_format = string.find, string.gsub, string.format
local math_ceil, math_floor, math_random = math.ceil, math.floor, math.random
local table_insert, table_wipe = table.insert, table.wipe
local GetTime, UnitClass, UnitExists, UnitIsUnit = GetTime, UnitClass, UnitExists, UnitIsUnit
local pairs, ipairs, tonumber, tostring = pairs, ipairs, tonumber, tostring

-- Public display types for FBT.DisplayMessage.
FBT.DISPLAYTYPE_INCOMING = 1
FBT.DISPLAYTYPE_OUTGOING = 2
FBT.DISPLAYTYPE_NOTIFICATION = 3

-- The profile in use.
FBT.CurrentProfile = nil

-------------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------------

-- Font strings per scroll area: 1-10 scroll, 11-20 are stickies.
local NUM_FONT_STRINGS, FIRST_STICKY = 20, 11
local MIN_VERTICAL_SPACING = 8
-- Incoming and outgoing events wait this long so that like events merge.
local MERGE_DELAY_TIME = 0.3
local STICKY_FADE_IN_TIME, STICKY_DISPLAY_TIME, STICKY_FADE_OUT_TIME = 0.15, 2, 0.5
-- Scrolling text moves at most this often; each step scales with the time passed.
local ANIMATION_SPEED = 0.02
local SCROLL_DOWN = 2
local STYLE_LEFT, STYLE_RIGHT = 2, 3
local MAX_COMBO_POINTS = 5

-- Damage schools: the colour of the amount and of the text, and the %t name.
local SCHOOL_HEX = {
 [Combat.DAMAGETYPE_HOLY] = "|cffF6F99E|h", [Combat.DAMAGETYPE_FIRE] = "|cffFF4444|h",
 [Combat.DAMAGETYPE_NATURE] = "|cff44FF44|h", [Combat.DAMAGETYPE_FROST] = "|cff4488FF|h",
 [Combat.DAMAGETYPE_SHADOW] = "|cff6600CC|h", [Combat.DAMAGETYPE_ARCANE] = "|cffCC66FF|h",
}
local SCHOOL_RGB = {
 [Combat.DAMAGETYPE_FIRE] = {1.0, 0.27, 0.27}, [Combat.DAMAGETYPE_NATURE] = {0.27, 1.0, 0.27},
 [Combat.DAMAGETYPE_FROST] = {0.27, 0.53, 1.0}, [Combat.DAMAGETYPE_SHADOW] = {0.4, 0.0, 0.8},
 [Combat.DAMAGETYPE_ARCANE] = {0.8, 0.4, 1.0},
}
local SCHOOL_NAME = {
 [Combat.DAMAGETYPE_PHYSICAL] = "Physical", [Combat.DAMAGETYPE_HOLY] = "Holy", [Combat.DAMAGETYPE_FIRE] = "Fire",
 [Combat.DAMAGETYPE_NATURE] = "Nature", [Combat.DAMAGETYPE_FROST] = "Frost", [Combat.DAMAGETYPE_SHADOW] = "Shadow",
 [Combat.DAMAGETYPE_ARCANE] = "Arcane",
}

local CLASS_COLORS = {
 PALADIN = "|cffF58CBA|h", DRUID = "|cffFF7D0A|h", HUNTER = "|cffABD473|h", MAGE = "|cff69CCF0|h",
 PRIEST = "|cffFFFFFF|h", ROGUE = "|cffFFF569|h", SHAMAN = "|cff0070DE|h", WARLOCK = "|cff9482C9|h",
 WARRIOR = "|cffC79C6E|h",
}

local ENVIRONMENT_NAMES = {
 [Combat.ACTIONTYPE_DROWNING] = "Drowning", [Combat.ACTIONTYPE_FALLING] = "Falling",
 [Combat.ACTIONTYPE_FATIGUE] = "Fatigue", [Combat.ACTIONTYPE_FIRE] = "Fire",
 [Combat.ACTIONTYPE_LAVA] = "Lava", [Combat.ACTIONTYPE_SLIME] = "Slime",
}

-- Mage spells whose resist plays the resist sound.
local RESIST_SOUND_SPELLS = {["Cone of Cold"] = true, ["Frost Nova"] = true}

-- Event type keys, built once: [direction][suffix] for melee and for spells.
local PREFIXES = {
 [Combat.DIRECTIONTYPE_PLAYER_INCOMING] = "MSBT_EVENTTYPE_INCOMING_",
 [Combat.DIRECTIONTYPE_PLAYER_OUTGOING] = "MSBT_EVENTTYPE_OUTGOING_",
 [Combat.DIRECTIONTYPE_PET_OUTGOING] = "MSBT_EVENTTYPE_OUTGOING_PET_",
 [Combat.DIRECTIONTYPE_PET_INCOMING] = "MSBT_EVENTTYPE_INCOMING_PET_",
}
local AREA_OF = {
 [Combat.DIRECTIONTYPE_PLAYER_INCOMING] = "Incoming", [Combat.DIRECTIONTYPE_PET_INCOMING] = "Incoming",
 [Combat.DIRECTIONTYPE_PLAYER_OUTGOING] = "Outgoing", [Combat.DIRECTIONTYPE_PET_OUTGOING] = "Outgoing",
}
local ACTION_SUFFIX = {
 [Combat.ACTIONTYPE_MISS] = "MISS", [Combat.ACTIONTYPE_DODGE] = "DODGE", [Combat.ACTIONTYPE_PARRY] = "PARRY",
 [Combat.ACTIONTYPE_BLOCK] = "BLOCK", [Combat.ACTIONTYPE_RESIST] = "RESIST", [Combat.ACTIONTYPE_ABSORB] = "ABSORB",
 [Combat.ACTIONTYPE_IMMUNE] = "IMMUNE", [Combat.ACTIONTYPE_EVADE] = "EVADE", [Combat.ACTIONTYPE_REFLECT] = "REFLECT",
}
local NOTICE_KEYS = {
 [Combat.NOTIFICATIONTYPE_DEBUFF] = "DEBUFF", [Combat.NOTIFICATIONTYPE_BUFF] = "BUFF",
 [Combat.NOTIFICATIONTYPE_BUFF_FADE] = "BUFF_FADE", [Combat.NOTIFICATIONTYPE_COMBAT_ENTER] = "COMBAT_ENTER",
 [Combat.NOTIFICATIONTYPE_COMBAT_LEAVE] = "COMBAT_LEAVE", [Combat.NOTIFICATIONTYPE_POWER_GAIN] = "POWER_GAIN",
 [Combat.NOTIFICATIONTYPE_POWER_LOSS] = "POWER_LOSS", [Combat.NOTIFICATIONTYPE_CP_GAIN] = "CP_GAIN",
 [Combat.NOTIFICATIONTYPE_HONOR_GAIN] = "HONOR_GAIN", [Combat.NOTIFICATIONTYPE_REP_GAIN] = "REP_GAIN",
 [Combat.NOTIFICATIONTYPE_REP_LOSS] = "REP_LOSS", [Combat.NOTIFICATIONTYPE_SKILL_GAIN] = "SKILL_GAIN",
 [Combat.NOTIFICATIONTYPE_EXPERIENCE_GAIN] = "EXPERIENCE_GAIN",
 [Combat.NOTIFICATIONTYPE_PC_KILLING_BLOW] = "PC_KILLING_BLOW", [Combat.NOTIFICATIONTYPE_NPC_KILLING_BLOW] = "NPC_KILLING_BLOW",
}
local CP_FULL_KEY = "MSBT_EVENTTYPE_NOTIFICATION_CP_FULL"

local meleeKeys, spellKeys, healKeys = {}, {}, {}
do
 local suffixes = {"DAMAGE", "DOT", "MISS", "DODGE", "PARRY", "BLOCK", "RESIST", "ABSORB", "IMMUNE", "EVADE", "REFLECT", "ENVIRONMENTAL"}
 for direction, prefix in pairs(PREFIXES) do
  meleeKeys[direction], spellKeys[direction] = {}, {}
  for _, suffix in ipairs(suffixes) do
   meleeKeys[direction][suffix] = prefix .. suffix
   spellKeys[direction][suffix] = prefix .. "SPELL_" .. suffix
  end
  -- Over-time damage, resists and reflects are always spell events.
  meleeKeys[direction].DOT = prefix .. "SPELL_DOT"
  meleeKeys[direction].RESIST = prefix .. "SPELL_RESIST"
  meleeKeys[direction].REFLECT = prefix .. "SPELL_REFLECT"
  healKeys[direction] = {HEAL = prefix .. "HEAL", HOT = prefix .. "HOT"}
 end
 -- Your pet's over-time damage, reflects and heals show as yours.
 local pet = Combat.DIRECTIONTYPE_PET_OUTGOING
 meleeKeys[pet].DOT, spellKeys[pet].DOT = "MSBT_EVENTTYPE_OUTGOING_SPELL_DOT", "MSBT_EVENTTYPE_OUTGOING_SPELL_DOT"
 meleeKeys[pet].REFLECT, spellKeys[pet].REFLECT = "MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT", "MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT"
 healKeys[pet] = {HEAL = "MSBT_EVENTTYPE_OUTGOING_HEAL", HOT = "MSBT_EVENTTYPE_OUTGOING_HOT"}
 for notificationType, suffix in pairs(NOTICE_KEYS) do NOTICE_KEYS[notificationType] = "MSBT_EVENTTYPE_NOTIFICATION_" .. suffix end
end

-------------------------------------------------------------------------------------
-- State.
-------------------------------------------------------------------------------------

-- The three scroll areas: frame, settings and display slots.
local scrollAreas = {}
FBT.scrollAreas = scrollAreas

-- Incoming and outgoing events wait in these queues to merge.
local mergeQueues = {
 Incoming = {Generation = 0, Unmerged = {}, Spare = {}, Merged = {}},
 Outgoing = {Generation = 0, Unmerged = {}, Spare = {}, Merged = {}},
}

local activeNonStickies, activeStickies = {}, {}

-- Message tables are reused: combat makes many and Lua 5.0 collects in one pass.
local pool, pooled = {}, {}
local function Acquire()
 local n = #pool
 if n == 0 then return {} end
 local t = pool[n]
 pool[n], pooled[t] = nil, nil
 return t
end
local function Reclaim(t)
 if pooled[t] then return end
 table_wipe(t)
 if #pool < 40 then pool[#pool + 1], pooled[t] = t, true end
end

function FBT.Print(message, r, g, b)
 DEFAULT_CHAT_FRAME:AddMessage("FBT: " .. message, r, g, b)
end

function FBT.CopyTable(source)
 local copy = {}
 for key, value in pairs(source) do
  copy[key] = type(value) == "table" and FBT.CopyTable(value) or value
 end
 return copy
end

-------------------------------------------------------------------------------------
-- Incoming events.
-------------------------------------------------------------------------------------

local function Disabled()
 return not FBT.CurrentProfile or FostercareBattleTextDB.UserDisabled
end

-- The settings key of a combat event.
local function EventKey(combatEvent)
 local direction, eventType = combatEvent.DirectionType, combatEvent.EventType
 if eventType == Combat.EVENTTYPE_DAMAGE then
  local actionType = combatEvent.ActionType
  local environment = ENVIRONMENT_NAMES[actionType]
  if environment then
   combatEvent.EffectName = environment
   return meleeKeys[direction] and meleeKeys[direction].ENVIRONMENTAL
  end
  local suffix = actionType == Combat.ACTIONTYPE_HIT and (combatEvent.HitType == Combat.HITTYPE_OVER_TIME and "DOT" or "DAMAGE")
   or ACTION_SUFFIX[actionType]
  local keys = combatEvent.EffectName and spellKeys[direction] or meleeKeys[direction]
  return keys and keys[suffix]
 elseif eventType == Combat.EVENTTYPE_HEAL then
  return healKeys[direction] and healKeys[direction][combatEvent.HealType == Combat.HEALTYPE_OVER_TIME and "HOT" or "HEAL"]
 end
 if combatEvent.NotificationType == Combat.NOTIFICATIONTYPE_CP_GAIN and combatEvent.Amount == MAX_COMBO_POINTS then
  return CP_FULL_KEY
 end
 return NOTICE_KEYS[combatEvent.NotificationType]
end

local function PartialText(combatEvent)
 local kind, amount = combatEvent.PartialActionType, combatEvent.PartialAmount
 if kind == Combat.PARTIALACTIONTYPE_ABSORB then return "|cffFAFA00|h" .. string_format(ABSORB_TRAILER, amount) .. "|h|r"
 elseif kind == Combat.PARTIALACTIONTYPE_BLOCK then return "|cff7F00FF|h" .. string_format(BLOCK_TRAILER, amount) .. "|h|r"
 elseif kind == Combat.PARTIALACTIONTYPE_RESIST then return "|cff81007F|h" .. string_format(RESIST_TRAILER, amount) .. "|h|r"
 elseif kind == Combat.PARTIALACTIONTYPE_CRUSHING then return "|cff7D0000|h" .. CRUSHING_TRAILER .. "|h|r"
 elseif kind == Combat.PARTIALACTIONTYPE_GLANCING then return "|cffFA0000|h" .. GLANCING_TRAILER .. "|h|r"
 end
end

-- Takes each event from Combat.lua and sends it to its scroll area.
function FBT.CombatEventsHandler(combatEvent)
 if Disabled() then return end
 local key = EventKey(combatEvent)
 local settings = key and FBT.CurrentProfile.EventSettings[key]
 if not settings then return end

 local message = Acquire()
 message.ScrollArea = combatEvent.EventType == Combat.EVENTTYPE_NOTIFICATION and scrollAreas.Notification
  or scrollAreas[AREA_OF[combatEvent.DirectionType]]
 message.EventType, message.EventSettings, message.UnformattedText = key, settings, settings.Message
 message.IsCrit = combatEvent.IsCrit or combatEvent.HitType == Combat.HITTYPE_CRIT or combatEvent.HealType == Combat.HEALTYPE_CRIT
 message.Amount, message.EffectName, message.Name = combatEvent.Amount, combatEvent.EffectName, combatEvent.Name
 message.UnitGUID, message.SpellId, message.IsSpellManaGain = combatEvent.UnitGUID, combatEvent.SpellId, combatEvent.IsSpellManaGain
 message.DamageType = combatEvent.DamageType
 if combatEvent.PartialActionType then message.PartialEffectText = PartialText(combatEvent) end
 -- A large icon beside the message, when the player turned it on for this event.
 local bigIcon = FBT.BIG_ICONS[key]
 if bigIcon and settings.BigIcon then
  message.Texture, message.IconFull, message.IconTint, message.IconScale = bigIcon.texture, bigIcon.full, bigIcon.tint, FBT.BIG_ICON_SCALE
 end
 FBT.DispatchAnimationEvent(message)
end

-- Takes each trigger from Combat.lua; %1 in the message is the amount.
function FBT.TriggerHandler(triggerEvent)
 if Disabled() then return end
 local trigger = FBT.CurrentProfile.Triggers[triggerEvent.TriggerKey]
 if not trigger then return end
 local stance = trigger.TriggerSettings.Stance
 if stance then
  local _, _, active = GetShapeshiftFormInfo(stance)
  if not active then return end
 end
 local message = Acquire()
 message.ScrollArea, message.EventSettings, message.Texture = scrollAreas.Notification, trigger.EventSettings, trigger.Texture
 local text = trigger.EventSettings.Message
 if text and triggerEvent.Amount then text = string_gsub(text, "%%1", tostring(triggerEvent.Amount)) end
 message.Text = text
 FBT.DispatchAnimationEvent(message)
end

-------------------------------------------------------------------------------------
-- Merging: like events within MERGE_DELAY_TIME show as one, with the count.
-------------------------------------------------------------------------------------

-- Merges `count` events of `unmerged` into queue.Merged; spell events on several
-- targets become "Multiple", melee events merge per target.
function FBT.MergeEvents(queue, unmerged, count)
 local merged = queue.Merged
 for x = 1, count do
  local event = unmerged[x]
  local into
  for _, candidate in ipairs(merged) do
   if event.EventType == candidate.EventType and event.EffectName == candidate.EffectName and event.SpellId == candidate.SpellId then
    if event.EffectName ~= nil then
     if candidate.UnitGUID ~= event.UnitGUID or candidate.Name ~= event.Name then
      candidate.Name, candidate.UnitGUID = "Multiple", nil
     end
     into = candidate
    elseif (event.UnitGUID and event.UnitGUID == candidate.UnitGUID) or
           (not event.UnitGUID and not candidate.UnitGUID and event.Name ~= nil and event.Name == candidate.Name) then
     into = candidate
    end
   end
   if into then break end
  end
  if into then
   local a, b = tonumber(into.Amount), tonumber(event.Amount)
   if a and b then into.Amount = a + b end
   into.PartialEffectText = nil
   into.NumMerged = into.NumMerged + 1
   if event.IsCrit then into.NumCrits = into.NumCrits + 1 end
   into.IsCrit = false
   Reclaim(event)
  else
   event.NumMerged, event.NumCrits = 0, event.IsCrit and 1 or 0
   merged[#merged + 1] = event
  end
 end
 for _, event in ipairs(merged) do
  if event.NumMerged > 0 then
   local crits = event.NumCrits
   event.MergeTrailerText = " [" .. (event.NumMerged + 1) .. " Hits" ..
    (crits > 1 and (", " .. crits .. " Crits") or crits == 1 and ", 1 Crit" or "") .. "]"
  end
 end
 table_wipe(unmerged)
end

local ScheduleMerge

local function ReclaimAll(list)
 for i, event in pairs(list) do Reclaim(event); list[i] = nil end
end

function FBT.ClearPendingEvents()
 for _, queue in pairs(mergeQueues) do
  queue.Generation = queue.Generation + 1
  if queue.Timer then queue.Timer:Cancel(); queue.Timer = nil end
  queue.TimerPending = false
  ReclaimAll(queue.Unmerged); ReclaimAll(queue.Spare); ReclaimAll(queue.Merged)
 end
 for _, area in pairs(scrollAreas) do
  for _, slot in ipairs(area.Slots) do
   slot.IsActive = false
   slot.timeLastJiggled, slot.originalPositionX, slot.originalPositionY = nil, nil, nil
   slot.FontObject:SetAlpha(0)
   if slot.Texture then slot.Texture:SetAlpha(0) end
  end
  area.Frame:Hide()
 end
end

-- The flags clear first: an error while showing one batch must not stop the
-- area for the rest of the session.
local function ProcessMerge(queue)
 queue.TimerPending, queue.Timer = false, nil
 local unmerged = queue.Unmerged
 queue.Unmerged, queue.Spare = queue.Spare, unmerged
 local merged = queue.Merged
 if #unmerged > 0 then
  FBT.MergeEvents(queue, unmerged, #unmerged)
  for i = 1, #merged do
   local event = merged[i]
   merged[i] = nil
   FBT.AddAnimation(event)
  end
 end
 if #queue.Unmerged > 0 then ScheduleMerge(queue) end
end

ScheduleMerge = function(queue)
 if queue.TimerPending then return end
 queue.TimerPending = true
 local generation = queue.Generation
 queue.Timer = C_Timer.NewTimer(MERGE_DELAY_TIME, function()
  if queue.Generation == generation then ProcessMerge(queue) end
 end)
end

-- Incoming and outgoing events wait to merge; notices show at once.
function FBT.DispatchAnimationEvent(message)
 local area = message.ScrollArea
 if not (message.EventSettings.Show and area.DisplaySettings.Show) then return Reclaim(message) end
 local queue = mergeQueues[area.Name]
 if queue then
  table_insert(queue.Unmerged, message)
  ScheduleMerge(queue)
 else
  FBT.AddAnimation(message)
 end
end

-------------------------------------------------------------------------------------
-- Text.
-------------------------------------------------------------------------------------

-- Font settings inherit event -> scroll area -> master; 0 means inherit.
local function InheritedFontValue(area, eventSettings, isCrit, field)
 local kind = isCrit and "Crit" or "Normal"
 local value = eventSettings and eventSettings.FontSettings[kind] and eventSettings.FontSettings[kind][field] or 0
 if value == 0 then value = area.DisplaySettings.FontSettings[kind][field] end
 if value == 0 then value = FBT.CurrentProfile.MasterFontSettings[kind][field] end
 return value
end

function FBT.GetFontSize(area, eventSettings, isCrit)
 return InheritedFontValue(area, eventSettings, isCrit, "FontSize")
end

function FBT.GetFontPath(area, eventSettings, isCrit)
 local font = FBT.AVAILABLE_FONTS[InheritedFontValue(area, eventSettings, isCrit, "FontIndex")]
 return (font or FBT.AVAILABLE_FONTS[1]).Path
end

function FBT.GetFontOutline(area, eventSettings, isCrit)
 local outline = FBT.AVAILABLE_OUTLINES[InheritedFontValue(area, eventSettings, isCrit, "OutlineIndex")]
 return (outline or FBT.AVAILABLE_OUTLINES[1]).Style
end

-- Fills the codes: %a amount, %n name, %s spell, %t school. Names and spell
-- names never hold a "%", so they go in as they are.
function FBT.FormatEventText(message)
 local text = message.UnformattedText
 if not text then return end
 text = string_gsub(text, "-%%a", "|cffff0000|h-|h|r%%a")
 local hex = SCHOOL_HEX[message.DamageType]
 if hex then text = string_gsub(text, "%%a", hex .. "%%a|h|r") end
 if message.Amount ~= nil then text = string_gsub(text, "%%a", message.Amount) end

 local name, guid = message.Name, message.UnitGUID
 if name and guid and UnitExists(guid) then
  if UnitIsUnit(guid, "player") then
   name = nil
  else
   local _, class = UnitClass(guid)
   if CLASS_COLORS[class] then name = CLASS_COLORS[class] .. name .. "|h|r" end
  end
 end
 if name then
  text = string_gsub(text, "%%n", name)
 else
  text = string_gsub(string_gsub(text, "%(%%n%)", ""), "%%n", "")
 end
 if message.EffectName ~= nil then text = string_gsub(text, "%%s", message.EffectName) end
 if SCHOOL_NAME[message.DamageType] then text = string_gsub(text, "%%t", SCHOOL_NAME[message.DamageType]) end
 if message.PartialEffectText and FBT.CurrentProfile.ShowPartialEffects then text = text .. message.PartialEffectText end
 if message.MergeTrailerText then text = text .. message.MergeTrailerText end
 message.Text = text
end

-- Filters hide a message whose text or spell name contains the filter text.
local function Contains(text, part)
 return text ~= nil and part ~= nil and part ~= "" and string_find(text, part, 1, true) ~= nil
end

local function Filtered(message)
 for _, filter in pairs(FBT.CurrentProfile.Suppressions) do
  if filter.Enabled and (Contains(message.Text, filter.SearchPattern) or Contains(message.EffectName, filter.SearchPattern)) then
   return true
  end
 end
end

-------------------------------------------------------------------------------------
-- Animation.
-------------------------------------------------------------------------------------

local function IsSticky(message)
 return message.IsSticky or (message.IsCrit and FBT.CurrentProfile.UseStickyCrits)
end

-- The next free slot: stickies use the last ten, so scrolling text never covers them.
function FBT.GetNextAnimationDisplayInfo(message)
 local area = message.ScrollArea
 local slot
 if IsSticky(message) then
  slot = area.Slots[area.NextSticky]
  area.NextSticky = area.NextSticky < NUM_FONT_STRINGS and area.NextSticky + 1 or FIRST_STICKY
 else
  slot = area.Slots[area.NextSlot]
  area.NextSlot = area.NextSlot < FIRST_STICKY - 1 and area.NextSlot + 1 or 1
 end
 return slot
end

-- Moves scrolling text apart so that none overlaps, oldest first.
local function SpreadScrolling(area)
 for x = area.NextSlot, FIRST_STICKY - 1 do
  if area.Slots[x].IsActive then table_insert(activeNonStickies, area.Slots[x]) end
 end
 for x = 1, area.NextSlot - 1 do
  if area.Slots[x].IsActive then table_insert(activeNonStickies, area.Slots[x]) end
 end
 local down = area.DisplaySettings.ScrollDirection == SCROLL_DOWN
 for x = #activeNonStickies, 2, -1 do
  local current, older = activeNonStickies[x], activeNonStickies[x - 1]
  if down then
   if older.PositionY + older.FontSize + MIN_VERTICAL_SPACING > current.PositionY then
    older.PositionY = current.PositionY - older.FontSize - MIN_VERTICAL_SPACING
   end
  else
   local top = current.PositionY + current.FontSize + MIN_VERTICAL_SPACING
   if older.PositionY < top then older.PositionY = top end
  end
 end
 table_wipe(activeNonStickies)
end

-- Stacks the stickies around the middle of the area.
local function SpreadStickies(area)
 for x = area.NextSticky, NUM_FONT_STRINGS do
  if area.Slots[x].IsActive then table_insert(activeStickies, area.Slots[x]) end
 end
 for x = FIRST_STICKY, area.NextSticky - 1 do
  if area.Slots[x].IsActive then table_insert(activeStickies, area.Slots[x]) end
 end
 local count = #activeStickies
 if count > 1 then
  local down = area.DisplaySettings.ScrollDirection == SCROLL_DOWN
  local middle = down and math_floor((count + 1) / 2) or math_ceil((count + 1) / 2)
  local sign = down and 1 or -1
  activeStickies[middle].PositionY = area.DisplaySettings.ScrollHeight / 2
  for x = middle - 1, 1, -1 do
   local below = down and activeStickies[x].FontSize or activeStickies[x + 1].FontSize
   activeStickies[x].PositionY = activeStickies[x + 1].PositionY - sign * (below + MIN_VERTICAL_SPACING)
  end
  for x = middle + 1, count do
   activeStickies[x].PositionY = activeStickies[x - 1].PositionY + sign * (activeStickies[x - 1].FontSize + MIN_VERTICAL_SPACING)
  end
 end
 table_wipe(activeStickies)
end

-- Shows a message in its area, unless a filter hides it.
function FBT.AddAnimation(message)
 FBT.FormatEventText(message)
 local profile = FBT.CurrentProfile
 if Filtered(message) or (message.IsSpellManaGain and profile.ShowAllManaGains) then return Reclaim(message) end

 local area, settings = message.ScrollArea, message.EventSettings
 if settings and settings.IsSticky then message.IsSticky = true end
 local sticky = IsSticky(message)
 local slot = FBT.GetNextAnimationDisplayInfo(message)
 slot.timeLastJiggled, slot.originalPositionX, slot.originalPositionY = nil, nil, nil
 slot.DecalageX, slot.DecalageY, slot.DeltaTime = nil, nil, nil

 -- Scrolling up starts at the bottom, down at the top; stickies in the middle.
 local height = area.DisplaySettings.ScrollHeight
 slot.PositionX = 0
 slot.PositionY = sticky and math_ceil(height / 2) or (area.DisplaySettings.ScrollDirection == SCROLL_DOWN and height or 0)

 if settings then
  slot.FontSize = FBT.GetFontSize(area, settings, message.IsCrit)
  slot.FontPath = FBT.GetFontPath(area, settings, message.IsCrit)
  slot.FontOutline = FBT.GetFontOutline(area, settings, message.IsCrit)
  local color = SCHOOL_RGB[message.DamageType]
  if color then
   slot.ColorR, slot.ColorG, slot.ColorB = color[1], color[2], color[3]
  else
   color = settings.FontSettings.Color
   slot.ColorR, slot.ColorG, slot.ColorB = color.r, color.g, color.b
  end
 else
  -- A message from FBT.DisplayMessage carries its own font and colour.
  slot.FontSize, slot.FontPath, slot.FontOutline = message.FontSize, message.FontPath, message.FontOutline
  slot.ColorR, slot.ColorG, slot.ColorB = message.ColorR, message.ColorG, message.ColorB
 end
 slot.Alpha = 0
 slot.AnchorPoint = FBT.AVAILABLE_TEXT_ALIGNS[area.DisplaySettings.FontSettings.TextAlignIndex].AnchorPoint
 slot.IsCrit, slot.IsSticky = message.IsCrit, sticky
 slot.IconScale, slot.IconFull, slot.IconTint = message.IconScale or 1, message.IconFull, message.IconTint

 if message.EventType == "MSBT_EVENTTYPE_OUTGOING_SPELL_RESIST" and profile.ResistSound and RESIST_SOUND_SPELLS[message.EffectName] then
  PlaySoundFile(FBT.MEDIA .. "sounds\\Resist.mp3")
 end

 -- SetFont caps the size at 32; SetTextHeight scales past it (softer, but
 -- readable on large screens). A missing font file falls back to Friz.
 local font = slot.FontObject
 local size = slot.FontSize
 if not size or size < 2 then size = 18 end
 font:ClearAllPoints()
 font:SetFont(slot.FontPath, size - 1, slot.FontOutline)
 if not font:GetFont() then font:SetFont("Fonts\\FRIZQT__.TTF", size - 1, slot.FontOutline) end
 font:SetTextColor(slot.ColorR, slot.ColorG, slot.ColorB)
 font:SetText(message.Text)
 font:SetTextHeight(slot.FontSize)
 font:SetAlpha(0)
 font:SetPoint(slot.AnchorPoint, slot.PositionX, slot.PositionY)
 slot.PlacedX, slot.PlacedY = slot.PositionX, slot.PositionY
 slot.Phase = nil

 -- The icon: the trigger's or event's own texture, else the spell's icon.
 local icon = message.Texture or Combat.GetSpellIcon(message.SpellId)
 if icon then
  local texture = slot.Texture
  if not texture then
   texture = area.Frame:CreateTexture(nil, "ARTWORK")
   slot.Texture = texture
  end
  texture:ClearAllPoints()
  texture:SetTexture(icon)
  texture:SetWidth(slot.FontSize * slot.IconScale)
  texture:SetHeight(slot.FontSize * slot.IconScale)
  if slot.IconFull then texture:SetTexCoord(0, 1, 0, 1) else texture:SetTexCoord(0.125, 0.875, 0.125, 0.875) end
  -- The texture is reused by the next message: always set its colour.
  local tint = slot.IconTint
  texture:SetDesaturated(tint and true or false)
  if tint then texture:SetVertexColor(tint[1], tint[2], tint[3]) else texture:SetVertexColor(1, 1, 1) end
  texture:SetPoint("RIGHT", font, "LEFT", -4, 0)
  texture:SetDrawLayer((slot.IsSticky or slot.IsCrit) and "OVERLAY" or "ARTWORK")
 elseif slot.Texture then
  slot.Texture:SetTexture(nil)
 end

 slot.LastUpdated = GetTime()
 slot.IsActive = true
 if not area.Frame:IsVisible() then area.Frame:Show() end
 if sticky then SpreadStickies(area) else SpreadScrolling(area) end
 Reclaim(message)
end

-- One step of scrolling text: up or down, straight or on a curve. Text fades
-- over the second half. Returns true at the end of the area.
local function Scroll(slot, settings)
 local height = settings.ScrollHeight
 local middle = height / 2
 local step = FBT.CurrentProfile.AnimationStep * slot.DeltaTime / ANIMATION_SPEED
 local y, done
 if settings.ScrollDirection == SCROLL_DOWN then
  y = slot.PositionY - step
  slot.Alpha = y < middle and 1 - (middle - y) / middle or 1
  done = y <= 0
 else
  y = slot.PositionY + step
  slot.Alpha = y >= middle and 1 - (y - middle) / middle or 1
  done = y >= height
 end
 slot.PositionY = y
 local style = settings.AnimationStyle
 if style == STYLE_LEFT or style == STYLE_RIGHT then
  -- A parabola through the middle: x = y^2 / 4a.
  local offset = y - middle
  local x = math_ceil(middle / 4) - math_ceil((offset * offset) / (4 * middle))
  slot.PositionX = style == STYLE_LEFT and -x or x
 end
 return done
end

-- Moves a sticky's text only when its position changed since the last write.
local function PlaceSticky(slot)
 if slot.PlacedX ~= slot.PositionX or slot.PlacedY ~= slot.PositionY then
  slot.FontObject:SetPoint(slot.AnchorPoint, slot.PositionX, slot.PositionY)
  slot.PlacedX, slot.PlacedY = slot.PositionX, slot.PositionY
 end
end

local function Deactivate(slot)
 slot.FontObject:SetAlpha(0)
 if slot.Texture then slot.Texture:SetAlpha(0) end
 slot.IsActive = false
end

-- Stickies pop in, hold while a crit jiggles, then fade. Widget values are
-- written when the phase or position changes, not every frame.
local function AnimateSticky(slot, elapsed)
 local font, texture = slot.FontObject, slot.Texture
 if elapsed <= STICKY_FADE_IN_TIME then
  local size = slot.FontSize * (2 - elapsed / STICKY_FADE_IN_TIME)
  if slot.Phase ~= 1 then
   slot.Phase = 1
   font:SetAlpha(1)
   if texture then texture:SetAlpha(1) end
  end
  font:SetTextHeight(size)
  if texture then texture:SetWidth(size * slot.IconScale); texture:SetHeight(size * slot.IconScale) end
 elseif elapsed <= STICKY_DISPLAY_TIME + STICKY_FADE_IN_TIME then
  if slot.Phase ~= 2 then
   slot.Phase = 2
   font:SetAlpha(1)
   font:SetTextHeight(slot.FontSize)
   if texture then
    texture:SetAlpha(1)
    texture:SetWidth(slot.FontSize * slot.IconScale)
    texture:SetHeight(slot.FontSize * slot.IconScale)
   end
  end
  if slot.IsCrit then
   if not slot.timeLastJiggled then
    slot.originalPositionX, slot.originalPositionY = slot.PositionX, slot.PositionY
    slot.DecalageX, slot.DecalageY, slot.timeLastJiggled = 0, 0, 0
   end
   -- Another sticky moved this one: jiggle around the new spot.
   if slot.PositionY ~= slot.originalPositionY + slot.DecalageY then
    slot.originalPositionX, slot.originalPositionY = slot.PositionX, slot.PositionY
   end
   if elapsed - slot.timeLastJiggled > 0.05 then
    slot.DecalageX, slot.DecalageY = math_random(-1, 1), math_random(-1, 1)
    slot.PositionX = slot.originalPositionX + slot.DecalageX
    slot.PositionY = slot.originalPositionY + slot.DecalageY
    slot.timeLastJiggled = elapsed
   end
  end
 elseif elapsed <= STICKY_DISPLAY_TIME + STICKY_FADE_IN_TIME + STICKY_FADE_OUT_TIME then
  local alpha = 1 - (elapsed - STICKY_DISPLAY_TIME - STICKY_FADE_IN_TIME) / STICKY_FADE_OUT_TIME
  slot.Phase, slot.timeLastJiggled = 3, nil
  font:SetAlpha(alpha)
  if texture then texture:SetAlpha(alpha) end
 else
  return Deactivate(slot)
 end
 PlaceSticky(slot)
end

function FBT.DoAnimation(slot, area)
 local now = GetTime()
 local elapsed = now - slot.LastUpdated
 if slot.IsSticky then return AnimateSticky(slot, elapsed) end
 if elapsed <= ANIMATION_SPEED then return end
 slot.DeltaTime = elapsed
 if Scroll(slot, area.DisplaySettings) then
  Deactivate(slot)
 else
  slot.FontObject:SetPoint(slot.AnchorPoint, slot.PositionX, slot.PositionY)
  slot.FontObject:SetAlpha(slot.Alpha)
  if slot.Texture then slot.Texture:SetAlpha(slot.Alpha) end
 end
 slot.LastUpdated = now
end

-- Runs while the area shows text; the area hides when the last message ends.
function FBT.OnUpdateAnimationFrame(frame)
 local area = frame.Area
 local active = false
 for i = 1, NUM_FONT_STRINGS do
  local slot = area.Slots[i]
  if slot.IsActive then
   FBT.DoAnimation(slot, area)
   active = true
  end
 end
 if not active then frame:Hide() end
end

-- An area: a hidden frame at the centre of the screen and its 20 font strings.
local function CreateScrollArea(name)
 local frame = CreateFrame("Frame", nil, UIParent)
 frame:SetWidth(24); frame:SetHeight(24)
 frame:SetFrameStrata("HIGH")
 frame:Hide()
 local area = {Name = name, Frame = frame, Slots = {}, NextSlot = 1, NextSticky = FIRST_STICKY}
 frame.Area = area
 for i = 1, NUM_FONT_STRINGS do
  area.Slots[i] = {FontObject = frame:CreateFontString(nil, "ARTWORK", "MasterFont"), LastUpdated = 0}
 end
 frame:SetScript("OnUpdate", function() FBT.OnUpdateAnimationFrame(frame) end)
 scrollAreas[name] = area
end
CreateScrollArea("Incoming")
CreateScrollArea("Outgoing")
CreateScrollArea("Notification")

function FBT.RepositionAnimationFrames()
 for _, area in pairs(scrollAreas) do
  local offsets = area.DisplaySettings.FrameOffsets
  area.Frame:ClearAllPoints()
  area.Frame:SetPoint("BOTTOM", UIParent, "CENTER", offsets.x, offsets.y)
 end
end

-------------------------------------------------------------------------------------
-- Profiles.
-------------------------------------------------------------------------------------

-- The game's own damage text font; the client reads it at login.
function FBT.ApplyGameDamageFont()
 local font = FBT.AVAILABLE_FONTS[FBT.CurrentProfile.BlizzardFontSettings.Normal.FontIndex]
 if font then DAMAGE_TEXT_FONT = font.Path end
end

function FBT.RegisterTriggers()
 Combat.UnregisterAllTriggers()
 for triggerKey, trigger in pairs(FBT.CurrentProfile.Triggers) do
  if trigger.EventSettings.Show then Combat.RegisterTrigger(triggerKey, trigger.TriggerSettings) end
 end
 Combat.UpdateUnitEvents()
end

-- Points everything at the saved current profile.
local function UseProfile()
 FBT.CurrentProfile = FostercareBattleTextDB.Profiles[FostercareBattleTextDB.CurrentProfile]
 for name, area in pairs(scrollAreas) do area.DisplaySettings = FBT.CurrentProfile.DisplaySettings[name] end
 FBT.RepositionAnimationFrames()
 FBT.RegisterTriggers()
 FBT.ApplyGameDamageFont()
end

-- Settings MSBT 1.x saved that nothing reads any more, and defaults the
-- profile lacks. Triggers and filters the player deleted stay deleted.
local RETIRED_EVENTS = {
 -- Resists and reflects are spell events; these four were never shown.
 "MSBT_EVENTTYPE_INCOMING_RESIST", "MSBT_EVENTTYPE_OUTGOING_RESIST",
 "MSBT_EVENTTYPE_INCOMING_REFLECT", "MSBT_EVENTTYPE_OUTGOING_REFLECT",
}
local function FillMissing(target, defaults)
 for key, value in pairs(defaults) do
  if target[key] == nil then
   target[key] = type(value) == "table" and FBT.CopyTable(value) or value
  elseif type(target[key]) == "table" and type(value) == "table" and key ~= "Triggers" and key ~= "Suppressions" then
   FillMissing(target[key], value)
  end
 end
end
function FBT.UpdateProfiles()
 for _, profile in pairs(FostercareBattleTextDB.Profiles) do
  if type(profile) == "table" then
   if type(profile.EventSettings) == "table" then
    for _, key in ipairs(RETIRED_EVENTS) do profile.EventSettings[key] = nil end
   end
   FillMissing(profile, FBT.DEFAULT_CONFIG)
  end
 end
end

function FBT.ProfileExists(name)
 return name ~= nil and FostercareBattleTextDB.Profiles[name] ~= nil
end

function FBT.ResetProfile(name, showOutput)
 if not FBT.ProfileExists(name) then return end
 local current = name == FostercareBattleTextDB.CurrentProfile
 if current then FBT.ClearPendingEvents() end
 FostercareBattleTextDB.Profiles[name] = FBT.CopyTable(FBT.DEFAULT_CONFIG)
 if current then UseProfile() end
 if showOutput then FBT.Print(name .. " profile reset.", 0, 1, 0) end
end

function FBT.SelectProfile(name)
 if not FBT.ProfileExists(name) then return end
 FBT.ClearPendingEvents()
 FostercareBattleTextDB.CurrentProfile = name
 UseProfile()
end

function FBT.CreateProfile(name)
 if name == nil or name == "" or FBT.ProfileExists(name) then return end
 FostercareBattleTextDB.Profiles[name] = FBT.CopyTable(FBT.DEFAULT_CONFIG)
end

function FBT.DeleteProfile(name)
 if name == FBT.DEFAULT_PROFILE_NAME or not FBT.ProfileExists(name) then return end
 if name == FostercareBattleTextDB.CurrentProfile then FBT.SelectProfile(FBT.DEFAULT_PROFILE_NAME) end
 FostercareBattleTextDB.Profiles[name] = nil
end

-------------------------------------------------------------------------------------
-- Options.
-------------------------------------------------------------------------------------

-- The game's own damage numbers: back on while the addon is off, otherwise the
-- player's choice.
function FBT.ApplyGameDamageSetting()
 SetCVar("CombatDamage", (FostercareBattleTextDB.UserDisabled or FBT.CurrentProfile.ShowGameDamage) and 1 or 0)
end

function FBT.SetOptionShowGameDamage(show)
 FBT.CurrentProfile.ShowGameDamage = show
 FBT.ApplyGameDamageSetting()
end

function FBT.SetOptionUserDisabled(disabled)
 FostercareBattleTextDB.UserDisabled = disabled
 if disabled then
  FBT.ClearPendingEvents()
  Combat.UnregisterEvents()
 else
  Combat.RegisterEvents()
 end
 FBT.ApplyGameDamageSetting()
end

-------------------------------------------------------------------------------------
-- Loading.
-------------------------------------------------------------------------------------

local function Init()
 local db = FostercareBattleTextDB
 if type(db) ~= "table" then db = {UserDisabled = false}; FostercareBattleTextDB = db end
 if type(db.Profiles) ~= "table" then db.Profiles = {} end
 if not db.CurrentProfile or not db.Profiles[db.CurrentProfile] then db.CurrentProfile = FBT.DEFAULT_PROFILE_NAME end
 if not db.Profiles[db.CurrentProfile] then db.Profiles[db.CurrentProfile] = FBT.CopyTable(FBT.DEFAULT_CONFIG) end
 FBT.UpdateProfiles()
 Combat.Init()
 UseProfile()
 FBT.SetOptionUserDisabled(db.UserDisabled)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
 if event == "ADDON_LOADED" then
  if arg1 ~= addonName then return end
  loader:UnregisterEvent("ADDON_LOADED")
  Init()
 elseif FBT.CurrentProfile then
  Combat.OnEnteringWorld()
  FBT.ClearPendingEvents()
 end
end)

-------------------------------------------------------------------------------------
-- Slash command: /fbt (and /msbt, the old name).
-------------------------------------------------------------------------------------

local COMMANDS = {
 reset = function() FBT.ResetProfile(FostercareBattleTextDB.CurrentProfile, true) end,
 disable = function() FBT.SetOptionUserDisabled(true); FBT.Print("Battle text is off. /fbt enable turns it on.", 1, 1, 1) end,
 enable = function() FBT.SetOptionUserDisabled(false); FBT.Print("Battle text is on.", 1, 1, 1) end,
 version = function() FBT.Print("v" .. FBT.VERSION, 1, 1, 1) end,
}

SLASH_FOSTERCAREBATTLETEXT1, SLASH_FOSTERCAREBATTLETEXT2 = "/fbt", "/msbt"
SlashCmdList.FOSTERCAREBATTLETEXT = function(text)
 local command = string.lower(string.match(text or "", "^%s*(%S*)"))
 if command == "" then return FBT.Options.Toggle() end
 if COMMANDS[command] then return COMMANDS[command]() end
 FBT.Print("/fbt opens the settings. /fbt reset | enable | disable | version", 1, 1, 1)
end

-------------------------------------------------------------------------------------
-- Public: other addons show text with FostercareBattleText.DisplayMessage.
-------------------------------------------------------------------------------------

-- message, display type (FBT.DISPLAYTYPE_*), sticky, colour as 0-255 channels,
-- font size, font index, outline index and an icon path; all but the message
-- are optional.
function FBT.DisplayMessage(message, displayType, isSticky, colorR, colorG, colorB, fontSize, fontIndex, outlineIndex, texture)
 if message == nil or Disabled() then return end
 local area = displayType == FBT.DISPLAYTYPE_INCOMING and scrollAreas.Incoming
  or displayType == FBT.DISPLAYTYPE_OUTGOING and scrollAreas.Outgoing or scrollAreas.Notification
 if not area.DisplaySettings.Show then return end
 local function Channel(value) return (value and value >= 0 and value <= 255) and value / 255 or 1 end
 local event = Acquire()
 event.ScrollArea, event.IsCrit, event.IsSticky, event.Text = area, false, isSticky, message
 event.FontSize = (fontSize and fontSize >= 12 and fontSize <= 64) and fontSize or FBT.GetFontSize(area, nil, false)
 event.FontPath = FBT.AVAILABLE_FONTS[fontIndex] and FBT.AVAILABLE_FONTS[fontIndex].Path or FBT.GetFontPath(area, nil, false)
 event.FontOutline = FBT.AVAILABLE_OUTLINES[outlineIndex] and FBT.AVAILABLE_OUTLINES[outlineIndex].Style or FBT.GetFontOutline(area, nil, false)
 event.ColorR, event.ColorG, event.ColorB = Channel(colorR), Channel(colorG), Channel(colorB)
 event.Texture = texture
 FBT.AddAnimation(event)
end
