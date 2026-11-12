-------------------------------------------------------------------------------------
-- FostercareBattleText: combat events and triggers.
-- Everything in combat comes from ClassicAPI's COMBAT_LOG_EVENT_UNFILTERED;
-- honor and skill gains, which have no structured event, from their chat line.
-------------------------------------------------------------------------------------

local _, FBT = ...
if not FBT.ready then return end

local Combat = {}
FBT.Combat = Combat

local string_match, table_wipe = string.match, table.wipe
local GetTime, UnitHealth, UnitHealthMax = GetTime, UnitHealth, UnitHealthMax
local UnitPower, UnitPowerMax, UnitGUID = UnitPower, UnitPowerMax, UnitGUID
local UnitIsFriend, UnitExists, GetSpellInfo = UnitIsFriend, UnitExists, GetSpellInfo
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local pairs, next, unpack, tonumber = pairs, next, unpack, tonumber
local bit_band = bit.band

-------------------------------------------------------------------------------------
-- Public constants.
-------------------------------------------------------------------------------------

Combat.EVENTTYPE_DAMAGE = 1
Combat.EVENTTYPE_HEAL = 2
Combat.EVENTTYPE_NOTIFICATION = 3

Combat.DIRECTIONTYPE_PLAYER_INCOMING = 1
Combat.DIRECTIONTYPE_PLAYER_OUTGOING = 2
Combat.DIRECTIONTYPE_PET_OUTGOING = 3
Combat.DIRECTIONTYPE_PET_INCOMING = 4

Combat.ACTIONTYPE_HIT = 1
Combat.ACTIONTYPE_MISS = 2
Combat.ACTIONTYPE_DODGE = 3
Combat.ACTIONTYPE_PARRY = 4
Combat.ACTIONTYPE_BLOCK = 5
Combat.ACTIONTYPE_RESIST = 6
Combat.ACTIONTYPE_ABSORB = 7
Combat.ACTIONTYPE_IMMUNE = 8
Combat.ACTIONTYPE_EVADE = 9
Combat.ACTIONTYPE_REFLECT = 10
Combat.ACTIONTYPE_DROWNING = 11
Combat.ACTIONTYPE_FALLING = 12
Combat.ACTIONTYPE_FATIGUE = 13
Combat.ACTIONTYPE_FIRE = 14
Combat.ACTIONTYPE_LAVA = 15
Combat.ACTIONTYPE_SLIME = 16

Combat.HITTYPE_NORMAL = 1
Combat.HITTYPE_CRIT = 2
Combat.HITTYPE_OVER_TIME = 3

Combat.DAMAGETYPE_PHYSICAL = 1
Combat.DAMAGETYPE_HOLY = 2
Combat.DAMAGETYPE_NATURE = 3
Combat.DAMAGETYPE_FIRE = 4
Combat.DAMAGETYPE_FROST = 5
Combat.DAMAGETYPE_SHADOW = 6
Combat.DAMAGETYPE_ARCANE = 7

Combat.PARTIALACTIONTYPE_ABSORB = 1
Combat.PARTIALACTIONTYPE_BLOCK = 2
Combat.PARTIALACTIONTYPE_RESIST = 3
Combat.PARTIALACTIONTYPE_CRUSHING = 5
Combat.PARTIALACTIONTYPE_GLANCING = 6

Combat.HEALTYPE_NORMAL = 1
Combat.HEALTYPE_CRIT = 2
Combat.HEALTYPE_OVER_TIME = 3

Combat.NOTIFICATIONTYPE_DEBUFF = 1
Combat.NOTIFICATIONTYPE_BUFF = 2
Combat.NOTIFICATIONTYPE_BUFF_FADE = 4
Combat.NOTIFICATIONTYPE_COMBAT_ENTER = 5
Combat.NOTIFICATIONTYPE_COMBAT_LEAVE = 6
Combat.NOTIFICATIONTYPE_POWER_GAIN = 7
Combat.NOTIFICATIONTYPE_POWER_LOSS = 8
Combat.NOTIFICATIONTYPE_CP_GAIN = 9
Combat.NOTIFICATIONTYPE_HONOR_GAIN = 10
Combat.NOTIFICATIONTYPE_REP_GAIN = 11
Combat.NOTIFICATIONTYPE_REP_LOSS = 12
Combat.NOTIFICATIONTYPE_SKILL_GAIN = 13
Combat.NOTIFICATIONTYPE_EXPERIENCE_GAIN = 14
Combat.NOTIFICATIONTYPE_PC_KILLING_BLOW = 15
Combat.NOTIFICATIONTYPE_NPC_KILLING_BLOW = 16

-- Saved trigger type numbers; 6 was the retired Search Pattern type.
Combat.TRIGGERTYPE_SELF_HEALTH = 1
Combat.TRIGGERTYPE_SELF_MANA = 2
Combat.TRIGGERTYPE_PET_HEALTH = 3
Combat.TRIGGERTYPE_ENEMY_HEALTH = 4
Combat.TRIGGERTYPE_FRIENDLY_HEALTH = 5
Combat.TRIGGERTYPE_AURA_GAIN = 7
Combat.TRIGGERTYPE_YOU_DODGE = 8
Combat.TRIGGERTYPE_YOU_PARRY = 9
Combat.TRIGGERTYPE_TARGET_DODGES = 10

local INCOMING, OUTGOING = Combat.DIRECTIONTYPE_PLAYER_INCOMING, Combat.DIRECTIONTYPE_PLAYER_OUTGOING
local PET_INCOMING, PET_OUTGOING = Combat.DIRECTIONTYPE_PET_INCOMING, Combat.DIRECTIONTYPE_PET_OUTGOING

-- Combat log values, as ClassicAPI documents them.
local SCHOOL_TO_TYPE = {
 [1] = Combat.DAMAGETYPE_PHYSICAL, [2] = Combat.DAMAGETYPE_HOLY, [4] = Combat.DAMAGETYPE_FIRE,
 [8] = Combat.DAMAGETYPE_NATURE, [16] = Combat.DAMAGETYPE_FROST, [32] = Combat.DAMAGETYPE_SHADOW,
 [64] = Combat.DAMAGETYPE_ARCANE,
}

local MISS_TO_ACTION = {
 MISS = Combat.ACTIONTYPE_MISS, RESIST = Combat.ACTIONTYPE_RESIST, DODGE = Combat.ACTIONTYPE_DODGE,
 PARRY = Combat.ACTIONTYPE_PARRY, DEFLECT = Combat.ACTIONTYPE_PARRY, BLOCK = Combat.ACTIONTYPE_BLOCK,
 EVADE = Combat.ACTIONTYPE_EVADE, IMMUNE = Combat.ACTIONTYPE_IMMUNE, ABSORB = Combat.ACTIONTYPE_ABSORB,
 REFLECT = Combat.ACTIONTYPE_REFLECT,
}

local ENVIRONMENT_TO_ACTION = {
 FATIGUE = Combat.ACTIONTYPE_FATIGUE, DROWNING = Combat.ACTIONTYPE_DROWNING, FALLING = Combat.ACTIONTYPE_FALLING,
 LAVA = Combat.ACTIONTYPE_LAVA, SLIME = Combat.ACTIONTYPE_SLIME, FIRE = Combat.ACTIONTYPE_FIRE,
}

-- The Enum.PowerType values shown.
local POWER_NAMES = {[0] = "Mana", [1] = "Rage", [3] = "Energy"}

-- Honor and skill chat lines (GlobalStrings), as patterns: %s and %d capture.
local function ChatPattern(format)
 local pattern = string.gsub(format, "([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
 pattern = string.gsub(pattern, "%%s", "(.+)")
 pattern = string.gsub(pattern, "%%d", "(%%d+)")
 return "^" .. pattern .. "$"
end
local HONOR_KILL = ChatPattern(COMBATLOG_HONORGAIN)    -- victim, rank, honor
local HONOR_AWARD = ChatPattern(COMBATLOG_HONORAWARD)  -- honor
local SKILL_UP = ChatPattern(SKILL_RANK_UP)            -- skill, rank

local SOUNDS = FBT.MEDIA .. "sounds\\"

-------------------------------------------------------------------------------------
-- State.
-------------------------------------------------------------------------------------

local playerClass
-- GUIDs of the player and pet, refreshed on world entry, enable and UNIT_PET.
-- Every combat log event is matched against them with a plain ==.
local playerGUID, petGUID

-- One combat event and one trigger event, reused for every event.
local eventData, triggerData = {}, {}

-- Triggers by kind; aura triggers by aura name.
local selfHealthTriggers, selfManaTriggers, petHealthTriggers = {}, {}, {}
local enemyHealthTriggers, friendlyHealthTriggers = {}, {}
local auraGainTriggers, youDodgeTriggers, youParryTriggers, targetDodgesTriggers = {}, {}, {}, {}

local lastSelfHealth, lastPetHealth, lastEnemyHealth, lastFriendlyHealth = 0, 0, 0, 0
local lastManaPercent, lastMana = 0, 0

-- Health checks run at most every 0.15 s per unit; a skipped one runs late.
local TRIGGER_THROTTLE_INTERVAL = 0.15
local lastHealthCheck = {player = 0, target = 0, pet = 0}
local pendingHealthChecks = {}
local thresholdGeneration = 0

-- Spell names and icons by ID; unknown IDs are cached as false.
local spellNames, spellIcons = {}, {}
local spellCacheSize, MAX_CACHED_SPELLS = 0, 256

-- Experience at the last PLAYER_XP_UPDATE; nil until the first one after login.
local lastXP, lastXPMax

local frame = CreateFrame("Frame")
local combatLogFrame = CreateFrame("Frame")
Combat.frame = frame
-- Whether the events are on (off while the addon is disabled).
local eventsOn = false
local healthUnits = {}

-------------------------------------------------------------------------------------
-- Helpers.
-------------------------------------------------------------------------------------

local function RefreshGUIDs()
 playerGUID, petGUID = UnitGUID("player"), UnitGUID("pet")
end

local function Direction(sourceGUID, destGUID)
 if destGUID == playerGUID then return INCOMING end
 if petGUID and destGUID == petGUID then return PET_INCOMING end
 if sourceGUID == playerGUID then return OUTGOING end
 if petGUID and sourceGUID == petGUID then return PET_OUTGOING end
end

local function CacheSpell(spellId)
 if spellCacheSize >= MAX_CACHED_SPELLS then
  table_wipe(spellNames); table_wipe(spellIcons)
  spellCacheSize = 0
 end
 local name, _, icon = GetSpellInfo(spellId)
 spellNames[spellId], spellIcons[spellId] = name or false, icon or false
 spellCacheSize = spellCacheSize + 1
end

local function SpellName(spellId)
 if not spellId or spellId == 0 then return nil end
 if spellNames[spellId] == nil then CacheSpell(spellId) end
 return spellNames[spellId] or nil
end

function Combat.GetSpellIcon(spellId)
 if not spellId or spellId == 0 then return nil end
 if spellIcons[spellId] == nil then CacheSpell(spellId) end
 return spellIcons[spellId] or nil
end

local function Send(data) FBT.CombatEventsHandler(data) end
local function SendTrigger(data) FBT.TriggerHandler(data) end

local function NewEvent(eventType)
 table_wipe(eventData)
 eventData.EventType = eventType
 return eventData
end

local function Damage(directionType, actionType, hitType, damageType, amount, effectName, name)
 local data = NewEvent(Combat.EVENTTYPE_DAMAGE)
 data.DirectionType, data.ActionType, data.HitType, data.DamageType = directionType, actionType, hitType, damageType
 data.Amount, data.EffectName, data.Name = amount, effectName, name
 return data
end

-- Power amounts read "25 Energy"; the spell is the effect name.
local function Notice(notificationType, amount, effectName, powerName)
 local data = NewEvent(Combat.EVENTTYPE_NOTIFICATION)
 data.NotificationType = notificationType
 if powerName then
  data.Amount, data.EffectName = (amount or 0) .. " " .. powerName, effectName
 else
  data.Amount, data.EffectName = amount, effectName
 end
 return data
end

local function TriggerEvent(triggerKey, amount)
 table_wipe(triggerData)
 triggerData.TriggerKey, triggerData.Amount = triggerKey, amount
 return triggerData
end

local function FireTriggers(triggers)
 for triggerKey in pairs(triggers) do SendTrigger(TriggerEvent(triggerKey)) end
end

-------------------------------------------------------------------------------------
-- Combat log. Values of the event being handled, numbered as ClassicAPI documents
-- them: 1-11 are the same for every event, 12 on depend on the subevent.
-------------------------------------------------------------------------------------

local cSubevent, cSourceName, cDestName, cDestFlags
local v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23
local handlers = {}

-- The other unit: the attacker for incoming events, else the target.
local function OtherName(directionType)
 if directionType == INCOMING or directionType == PET_INCOMING then return cSourceName end
 return cDestName
end

local function Identity(data, sourceGUID, destGUID)
 local incoming = data.DirectionType == INCOMING or data.DirectionType == PET_INCOMING
 data.UnitGUID = incoming and sourceGUID or destGUID
end

local function Hit(sourceGUID, destGUID, spellId, spellName, amount, school, resisted, blocked, absorbed, critical, glancing, crushing, periodic)
 local directionType = Direction(sourceGUID, destGUID)
 if not directionType then return end
 local hitType = periodic and Combat.HITTYPE_OVER_TIME or critical and Combat.HITTYPE_CRIT or Combat.HITTYPE_NORMAL
 amount = amount or 0
 local data = Damage(directionType, Combat.ACTIONTYPE_HIT, hitType, SCHOOL_TO_TYPE[school] or Combat.DAMAGETYPE_PHYSICAL,
  amount, spellName, OtherName(directionType))
 data.SpellId, data.IsCrit = spellId, critical and true or nil
 -- One partial effect: crushing or glancing, then absorbed, blocked, resisted.
 if crushing then data.PartialActionType = Combat.PARTIALACTIONTYPE_CRUSHING
 elseif glancing then data.PartialActionType = Combat.PARTIALACTIONTYPE_GLANCING
 elseif absorbed then data.PartialActionType, data.PartialAmount = Combat.PARTIALACTIONTYPE_ABSORB, absorbed
 elseif blocked then data.PartialActionType, data.PartialAmount = Combat.PARTIALACTIONTYPE_BLOCK, blocked
 elseif resisted then data.PartialActionType, data.PartialAmount = Combat.PARTIALACTIONTYPE_RESIST, resisted
 end
 if amount == 0 and absorbed then data.ActionType, data.PartialActionType = Combat.ACTIONTYPE_ABSORB, nil end
 Identity(data, sourceGUID, destGUID)
 Send(data)
end

-- Dodge and parry triggers: you avoided an attack, or your target dodged.
local function Miss(sourceGUID, destGUID, spellId, spellName, missType)
 local directionType = Direction(sourceGUID, destGUID)
 if not directionType then return end
 if directionType == INCOMING then
  if missType == "DODGE" then FireTriggers(youDodgeTriggers) elseif missType == "PARRY" then FireTriggers(youParryTriggers) end
 elseif directionType == OUTGOING and missType == "DODGE" then
  FireTriggers(targetDodgesTriggers)
 end
 local data = Damage(directionType, MISS_TO_ACTION[missType] or Combat.ACTIONTYPE_MISS, nil, nil, nil, spellName, OtherName(directionType))
 data.SpellId = spellId
 Identity(data, sourceGUID, destGUID)
 Send(data)
end

-- Melee: amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing.
handlers.SWING_DAMAGE = function(sourceGUID, destGUID)
 Hit(sourceGUID, destGUID, nil, nil, v12, v14, v15, v16, v17, v18, v19, v20)
end
handlers.SWING_MISSED = function(sourceGUID, destGUID)
 Miss(sourceGUID, destGUID, nil, nil, v12)
end

-- Spells, ranged and split damage: spellId, spellName, school, then the damage suffix.
local function SpellDamage(sourceGUID, destGUID)
 Hit(sourceGUID, destGUID, v12, v13, v15, v17, v18, v19, v20, v21, v22, v23, cSubevent == "SPELL_PERIODIC_DAMAGE")
end
handlers.SPELL_DAMAGE = SpellDamage
handlers.SPELL_PERIODIC_DAMAGE = SpellDamage
handlers.RANGE_DAMAGE = SpellDamage
handlers.DAMAGE_SPLIT = SpellDamage

local function SpellMiss(sourceGUID, destGUID)
 Miss(sourceGUID, destGUID, v12, v13, v15)
end
handlers.SPELL_MISSED = SpellMiss
handlers.SPELL_PERIODIC_MISSED = SpellMiss
handlers.RANGE_MISSED = SpellMiss

-- A damage shield names its spell (Thorns) when the owner has one shield of
-- that school; otherwise spellId is 0 and the name nil.
local function ShieldSpell()
 if v12 ~= 0 then return v12, v13 or "Damage Shield" end
 return nil, "Damage Shield"
end
handlers.DAMAGE_SHIELD = function(sourceGUID, destGUID)
 local spellId, spellName = ShieldSpell()
 Hit(sourceGUID, destGUID, spellId, spellName, v15, v17, v18, v19, v20, v21, v22, v23)
end
handlers.DAMAGE_SHIELD_MISSED = function(sourceGUID, destGUID)
 local spellId, spellName = ShieldSpell()
 Miss(sourceGUID, destGUID, spellId, spellName, v15)
end

-- Environment: type, then amount, overkill, school, resisted, blocked, absorbed.
handlers.ENVIRONMENTAL_DAMAGE = function(sourceGUID, destGUID)
 if destGUID ~= playerGUID then return end
 local data = Damage(INCOMING, ENVIRONMENT_TO_ACTION[v12] or Combat.ACTIONTYPE_FALLING, Combat.HITTYPE_NORMAL,
  Combat.DAMAGETYPE_PHYSICAL, v13 or 0)
 if v18 then data.PartialActionType, data.PartialAmount = Combat.PARTIALACTIONTYPE_ABSORB, v18
 elseif v16 then data.PartialActionType, data.PartialAmount = Combat.PARTIALACTIONTYPE_RESIST, v16 end
 Send(data)
end

-- Heals: amount, overhealing, absorbed, critical.
local function Heal(sourceGUID, destGUID)
 local directionType = Direction(sourceGUID, destGUID)
 if not directionType then return end
 local data = NewEvent(Combat.EVENTTYPE_HEAL)
 data.DirectionType = directionType
 data.HealType = cSubevent == "SPELL_PERIODIC_HEAL" and Combat.HEALTYPE_OVER_TIME or v18 and Combat.HEALTYPE_CRIT or Combat.HEALTYPE_NORMAL
 data.Amount, data.EffectName, data.Name = v15 or 0, v13, OtherName(directionType)
 data.SpellId, data.IsCrit = v12, v18 and true or nil
 Identity(data, sourceGUID, destGUID)
 Send(data)
end
handlers.SPELL_HEAL = Heal
handlers.SPELL_PERIODIC_HEAL = Heal

-- Power you gain: amount, powerType.
local function Energize(sourceGUID, destGUID)
 if destGUID ~= playerGUID then return end
 local powerType = tonumber(v16)
 local powerName = POWER_NAMES[powerType]
 if not powerName then return end
 local data = Notice(Combat.NOTIFICATIONTYPE_POWER_GAIN, v15 or 0, v13, powerName)
 data.SpellId, data.IsSpellManaGain = v12, powerType == 0
 Send(data)
end
handlers.SPELL_ENERGIZE = Energize
handlers.SPELL_PERIODIC_ENERGIZE = Energize

-- Power taken from you: amount, powerType.
local function Drain(sourceGUID, destGUID)
 if destGUID ~= playerGUID then return end
 local powerName, amount = POWER_NAMES[tonumber(v16)], tonumber(v15) or 0
 if powerName and amount > 0 then
  local data = Notice(Combat.NOTIFICATIONTYPE_POWER_LOSS, amount, v13, powerName)
  data.SpellId = v12
  Send(data)
 end
end
handlers.SPELL_DRAIN = Drain
handlers.SPELL_PERIODIC_DRAIN = Drain
handlers.SPELL_LEECH = Drain
handlers.SPELL_PERIODIC_LEECH = Drain

-- Your auras: spellId, spellName, school, auraType. A stack gain shows again
-- like a new aura; a stack loss (REMOVED_DOSE) is not a fade.
local function AuraGained(sourceGUID, destGUID)
 if destGUID ~= playerGUID then return end
 local spellName = v13 or SpellName(v12)
 if not spellName then return end
 if cSubevent == "SPELL_AURA_APPLIED" and auraGainTriggers[spellName] then FireTriggers(auraGainTriggers[spellName]) end
 local data = Notice(v15 == "DEBUFF" and Combat.NOTIFICATIONTYPE_DEBUFF or Combat.NOTIFICATIONTYPE_BUFF, nil, spellName)
 data.SpellId = v12
 Send(data)
end
handlers.SPELL_AURA_APPLIED = AuraGained
handlers.SPELL_AURA_APPLIED_DOSE = AuraGained
handlers.SPELL_AURA_REMOVED = function(sourceGUID, destGUID)
 if destGUID ~= playerGUID then return end
 local spellName = v13 or SpellName(v12)
 if not spellName then return end
 local data = Notice(Combat.NOTIFICATIONTYPE_BUFF_FADE, nil, spellName)
 data.SpellId = v12
 Send(data)
end

-- Killing blows: the victim's flags say whether it was a player.
handlers.PARTY_KILL = function(sourceGUID)
 if sourceGUID ~= playerGUID then return end
 local player = bit_band(cDestFlags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
 Send(Notice(player and Combat.NOTIFICATIONTYPE_PC_KILLING_BLOW or Combat.NOTIFICATIONTYPE_NPC_KILLING_BLOW, nil, cDestName))
end

-- The whole nearby combat stream arrives here; events that involve neither you
-- nor your pet return after the GUID compares.
combatLogFrame:SetScript("OnEvent", function()
 local sourceGUID, destGUID = arg4, arg8
 if sourceGUID ~= playerGUID and destGUID ~= playerGUID and
    (petGUID == nil or (sourceGUID ~= petGUID and destGUID ~= petGUID)) then return end
 local handler = handlers[arg2]
 if not handler then return end
 local _
 _, cSubevent, _, _, cSourceName, _, _, _, cDestName, cDestFlags, _,
  v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23 = CombatLogGetCurrentEventInfo()
 handler(sourceGUID, destGUID)
end)

-------------------------------------------------------------------------------------
-- Thresholds: health and mana triggers fire when the value falls below them.
-------------------------------------------------------------------------------------

local function CheckHealth(unit, triggers, lastPercent)
 if not next(triggers) or not UnitExists(unit) then return lastPercent end
 local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
 if not health or not maxHealth or maxHealth <= 0 then return lastPercent end
 local percent = health / maxHealth
 for triggerKey, settings in pairs(triggers) do
  local threshold = settings.Threshold / 100
  if percent < threshold and lastPercent >= threshold then
   SendTrigger(TriggerEvent(triggerKey, health))
   if unit == "player" and FBT.CurrentProfile.LowHealthSound then PlaySoundFile(SOUNDS .. "LowHealth.mp3", "Master") end
  end
 end
 return percent
end

local function CheckTargetHealth()
 if UnitIsFriend("player", "target") then
  lastFriendlyHealth = CheckHealth("target", friendlyHealthTriggers, lastFriendlyHealth)
 else
  lastEnemyHealth = CheckHealth("target", enemyHealthTriggers, lastEnemyHealth)
 end
end

local function CheckUnitHealth(unit)
 if unit == "player" then lastSelfHealth = CheckHealth("player", selfHealthTriggers, lastSelfHealth)
 elseif unit == "pet" then lastPetHealth = CheckHealth("pet", petHealthTriggers, lastPetHealth)
 else CheckTargetHealth() end
end

-- Mana by type, so a druid's mana is read in every form.
local function CheckMana()
 local mana, maxMana = UnitPower("player", 0), UnitPowerMax("player", 0)
 if maxMana == 0 then return end
 local percent = mana / maxMana
 if mana > lastMana and FBT.CurrentProfile.ShowAllManaGains then
  Send(Notice(Combat.NOTIFICATIONTYPE_POWER_GAIN, mana - lastMana, nil, "Mana"))
 end
 for triggerKey, settings in pairs(selfManaTriggers) do
  local threshold = settings.Threshold / 100
  if percent < threshold and lastManaPercent >= threshold then
   SendTrigger(TriggerEvent(triggerKey, mana))
   if FBT.CurrentProfile.LowManaSound then PlaySoundFile(SOUNDS .. "LowMana.mp3", "Master") end
  end
 end
 lastManaPercent, lastMana = percent, mana
end

local function ResetThresholds()
 thresholdGeneration = thresholdGeneration + 1
 for unit, timer in pairs(pendingHealthChecks) do timer:Cancel(); pendingHealthChecks[unit] = nil end
 lastSelfHealth, lastPetHealth, lastEnemyHealth, lastFriendlyHealth = 0, 0, 0, 0
 lastManaPercent, lastMana = 0, UnitPower("player", 0)
 lastHealthCheck.player, lastHealthCheck.pet, lastHealthCheck.target = 0, 0, 0
end

local function CancelHealthCheck(unit)
 if pendingHealthChecks[unit] then pendingHealthChecks[unit]:Cancel(); pendingHealthChecks[unit] = nil end
end

-------------------------------------------------------------------------------------
-- Events.
-------------------------------------------------------------------------------------

local EVENTS = {
 "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "PLAYER_COMBO_POINTS", "UNIT_PET",
 "CHAT_MSG_COMBAT_HONOR_GAIN", "FACTION_STANDING_CHANGED", "CHAT_MSG_SKILL",
 -- Every XP gain (kills, quests, exploration) as the change in UnitXP.
 "PLAYER_XP_UPDATE",
}

local onEvent = {}

onEvent.PLAYER_REGEN_ENABLED = function() Send(Notice(Combat.NOTIFICATIONTYPE_COMBAT_LEAVE)) end
onEvent.PLAYER_REGEN_DISABLED = function() Send(Notice(Combat.NOTIFICATIONTYPE_COMBAT_ENTER)) end

onEvent.PLAYER_COMBO_POINTS = function()
 local points = GetComboPoints()
 if points and points > 0 then Send(Notice(Combat.NOTIFICATIONTYPE_CP_GAIN, points)) end
end

onEvent.UNIT_HEALTH = function()
 local unit, now = arg1, GetTime()
 local lastCheck = lastHealthCheck[unit]
 if not lastCheck then return end
 if now - lastCheck >= TRIGGER_THROTTLE_INTERVAL then
  lastHealthCheck[unit] = now
  CancelHealthCheck(unit)
  CheckUnitHealth(unit)
 elseif not pendingHealthChecks[unit] then
  local generation = thresholdGeneration
  pendingHealthChecks[unit] = C_Timer.NewTimer(TRIGGER_THROTTLE_INTERVAL - (now - lastCheck), function()
   if generation ~= thresholdGeneration then return end
   pendingHealthChecks[unit] = nil
   lastHealthCheck[unit] = GetTime()
   CheckUnitHealth(unit)
  end)
 end
end

onEvent.UNIT_POWER_UPDATE = function()
 if arg2 == "MANA" then CheckMana() end
end

-- A new target counts as full health, so one already below a threshold fires.
onEvent.PLAYER_TARGET_CHANGED = function()
 CancelHealthCheck("target")
 lastEnemyHealth, lastFriendlyHealth, lastHealthCheck.target = 1, 1, 0
 CheckTargetHealth()
end

onEvent.UNIT_PET = function()
 if arg1 ~= "player" then return end
 RefreshGUIDs()
 CancelHealthCheck("pet")
 lastPetHealth, lastHealthCheck.pet = 1, 0
 lastPetHealth = CheckHealth("pet", petHealthTriggers, lastPetHealth)
end

onEvent.CHAT_MSG_COMBAT_HONOR_GAIN = function()
 local _, _, honor = string_match(arg1, HONOR_KILL)
 honor = honor or string_match(arg1, HONOR_AWARD)
 if honor then Send(Notice(Combat.NOTIFICATIONTYPE_HONOR_GAIN, honor)) end
end

-- ClassicAPI: factionID, new standing, signed change.
onEvent.FACTION_STANDING_CHANGED = function()
 local change = tonumber(arg3) or 0
 if change == 0 then return end
 Send(Notice(change > 0 and Combat.NOTIFICATIONTYPE_REP_GAIN or Combat.NOTIFICATIONTYPE_REP_LOSS,
  math.abs(change), (GetFactionInfoByID(arg1))))
end

onEvent.CHAT_MSG_SKILL = function()
 local skill, rank = string_match(arg1, SKILL_UP)
 if skill then Send(Notice(Combat.NOTIFICATIONTYPE_SKILL_GAIN, rank, skill)) end
end

onEvent.PLAYER_XP_UPDATE = function()
 local xp, xpMax = UnitXP("player"), UnitXPMax("player")
 if lastXP then
  local gain = xp - lastXP
  -- A level-up starts the bar again: the rest of the old level plus the new.
  if gain < 0 then gain = (lastXPMax - lastXP) + xp end
  if gain > 0 then Send(Notice(Combat.NOTIFICATIONTYPE_EXPERIENCE_GAIN, gain)) end
 end
 lastXP, lastXPMax = xp, xpMax
end

frame:SetScript("OnEvent", function() onEvent[event]() end)

-- Health, target and mana events only for the units that triggers or "All mana
-- gains" read; with none, those events never reach Lua.
function Combat.UpdateUnitEvents()
 frame:UnregisterEvent("UNIT_HEALTH")
 frame:UnregisterEvent("PLAYER_TARGET_CHANGED")
 frame:UnregisterEvent("UNIT_POWER_UPDATE")
 ResetThresholds()
 if not eventsOn then return end
 table_wipe(healthUnits)
 if next(selfHealthTriggers) then healthUnits[#healthUnits + 1] = "player" end
 if next(petHealthTriggers) then healthUnits[#healthUnits + 1] = "pet" end
 if next(enemyHealthTriggers) or next(friendlyHealthTriggers) then
  healthUnits[#healthUnits + 1] = "target"
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
 end
 if healthUnits[1] then frame:RegisterUnitEvent("UNIT_HEALTH", unpack(healthUnits)) end
 if next(selfManaTriggers) or FBT.CurrentProfile.ShowAllManaGains then
  frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
 end
end

function Combat.RegisterEvents()
 RefreshGUIDs()
 for _, name in ipairs(EVENTS) do frame:RegisterEvent(name) end
 combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
 lastXP, lastXPMax = UnitXP("player"), UnitXPMax("player")
 eventsOn = true
 Combat.UpdateUnitEvents()
end

function Combat.UnregisterEvents()
 frame:UnregisterAllEvents()
 combatLogFrame:UnregisterAllEvents()
 lastXP, lastXPMax = nil, nil
 eventsOn = false
 Combat.UpdateUnitEvents()
end

-- At ADDON_LOADED, before any trigger registers: triggers filter by class.
function Combat.Init()
 local _
 _, playerClass = UnitClass("player")
 RefreshGUIDs()
end

function Combat.OnEnteringWorld()
 RefreshGUIDs()
 if eventsOn then lastXP, lastXPMax = UnitXP("player"), UnitXPMax("player") end
 table_wipe(spellNames); table_wipe(spellIcons); spellCacheSize = 0
 ResetThresholds()
end

-------------------------------------------------------------------------------------
-- Triggers.
-------------------------------------------------------------------------------------

local TRIGGER_TABLES = {
 [Combat.TRIGGERTYPE_SELF_HEALTH] = selfHealthTriggers,
 [Combat.TRIGGERTYPE_SELF_MANA] = selfManaTriggers,
 [Combat.TRIGGERTYPE_PET_HEALTH] = petHealthTriggers,
 [Combat.TRIGGERTYPE_ENEMY_HEALTH] = enemyHealthTriggers,
 [Combat.TRIGGERTYPE_FRIENDLY_HEALTH] = friendlyHealthTriggers,
 [Combat.TRIGGERTYPE_YOU_DODGE] = youDodgeTriggers,
 [Combat.TRIGGERTYPE_YOU_PARRY] = youParryTriggers,
 [Combat.TRIGGERTYPE_TARGET_DODGES] = targetDodgesTriggers,
}

function Combat.RegisterTrigger(triggerKey, settings)
 if settings.Classes and not settings.Classes[playerClass] then return end
 if settings.TriggerType == Combat.TRIGGERTYPE_AURA_GAIN then
  local auraName = settings.AuraName
  if auraName and auraName ~= "" then
   auraGainTriggers[auraName] = auraGainTriggers[auraName] or {}
   auraGainTriggers[auraName][triggerKey] = settings
  end
 elseif TRIGGER_TABLES[settings.TriggerType] then
  TRIGGER_TABLES[settings.TriggerType][triggerKey] = settings
 end
end

function Combat.UnregisterAllTriggers()
 for _, triggers in pairs(TRIGGER_TABLES) do table_wipe(triggers) end
 table_wipe(auraGainTriggers)
 ResetThresholds()
end
