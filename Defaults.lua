-------------------------------------------------------------------------------------
-- FostercareBattleText: namespace, constants and the default profile.
-- Formerly Mik's Scrolling Battle Text (Mik); maintained by Fostercare5988.
-------------------------------------------------------------------------------------

local addonName, FBT = ...

-- Runs on ClassicAPI (combat log, GetSpellInfo, UnitGUID, unit events). The
-- other files load only when FBT.ready is set here.
if type(CLASSIC_API_VERSION) ~= "number" then
 DEFAULT_CHAT_FRAME:AddMessage("|cffff2020FBT:|r FostercareBattleText needs ClassicAPI. Update it and restart the game.", 1, 0.2, 0.2)
 return
end
FBT.ready = true

-- The one public table. Other addons call FostercareBattleText.DisplayMessage.
FostercareBattleText = FBT

FBT.VERSION = GetAddOnMetadata(addonName, "Version")
FBT.MEDIA = "Interface\\AddOns\\" .. addonName .. "\\"

-- Events that can show a large icon beside their message (the "Icon" button in
-- the Notices tab). Both combat notices show the crossed swords, greyed and
-- tinted: red in combat, green out of it. Spell icons are cropped to hide their
-- border; "full" would draw the whole texture.
FBT.BIG_ICONS = {
 MSBT_EVENTTYPE_NOTIFICATION_COMBAT_ENTER = {texture = "Interface\\Icons\\Ability_DualWield", tint = {1, 0.2, 0.2}},
 MSBT_EVENTTYPE_NOTIFICATION_COMBAT_LEAVE = {texture = "Interface\\Icons\\Ability_DualWield", tint = {0.2, 1, 0.2}},
}
FBT.BIG_ICON_SCALE = 2

-------------------------------------------------------------------------------------
-- Fonts, outlines and alignment. Saved settings keep the index, so new fonts go
-- at the end.
-------------------------------------------------------------------------------------

local FONTS = FBT.MEDIA .. "Fonts\\"
FBT.AVAILABLE_FONTS = {
 {Name = "Adventure", Path = FONTS .. "adventure.ttf"},
 {Name = "Backsplatter", Path = FONTS .. "backsplatter.ttf"},
 {Name = "Budhand", Path = FONTS .. "budhand.ttf"},
 {Name = "Comic", Path = FONTS .. "comic.ttf"},
 {Name = "Creeper", Path = FONTS .. "creeper.ttf"},
 {Name = "Friz", Path = "Fonts\\FRIZQT__.TTF"},
 {Name = "Porky", Path = FONTS .. "porky.ttf"},
 {Name = "Signature", Path = FONTS .. "signature.ttf"},
 {Name = "Black Castle", Path = FONTS .. "BlackCastleMF.ttf"},
 {Name = "Exocet", Path = FONTS .. "exocet.ttf"},
 {Name = "FuturaBold", Path = FONTS .. "FuturaBold.ttf"},
 {Name = "Mail Ray Stuff", Path = FONTS .. "mailrays.ttf"},
 {Name = "Pepsi", Path = FONTS .. "pepsi.ttf"},
 {Name = "Bazooka", Path = FONTS .. "bazooka.ttf"},
 {Name = "Cooline", Path = FONTS .. "cooline.ttf"},
 {Name = "Yellowjacket", Path = FONTS .. "yellowjacket.ttf"},
 {Name = "Defused", Path = FONTS .. "defused.ttf"},
 {Name = "Zombie", Path = FONTS .. "zombie.ttf"},
 {Name = "Basket Of Hammers", Path = FONTS .. "basketofhammers.ttf"},
 {Name = "College", Path = FONTS .. "college.ttf"},
 {Name = "Galaxy", Path = FONTS .. "galaxy.ttf"},
 {Name = "Skratch Punk", Path = FONTS .. "skratchpunk.ttf"},
 {Name = "DieDieDie", Path = FONTS .. "DieDieDie.ttf"},
 {Name = "BigNoodleTitling", Path = FONTS .. "BigNoodleTitling.ttf"},
 {Name = "Continuum", Path = FONTS .. "Continuum.ttf"},
 {Name = "Expressway", Path = FONTS .. "Expressway.ttf"},
 {Name = "Homespun", Path = FONTS .. "Homespun.ttf"},
 {Name = "Myriad-Pro", Path = FONTS .. "Myriad-Pro.ttf"},
 {Name = "PT-Sans-Narrow-Bold", Path = FONTS .. "PT-Sans-Narrow-Bold.ttf"},
 {Name = "PT-Sans-Narrow-Regular", Path = FONTS .. "PT-Sans-Narrow-Regular.ttf"},
 {Name = "Simhei", Path = FONTS .. "simhei.ttf"},
 {Name = "Archangelsk", Path = FONTS .. "archangelsk.ttf"},
 {Name = "Google Sans Bold", Path = FONTS .. "GoogleSans-Bold.ttf"},
 {Name = "Google Sans Medium", Path = FONTS .. "GoogleSans-Medium.ttf"},
 {Name = "Apple SF Pro Display", Path = FONTS .. "SFProDisplay-Bold.ttf"},
 {Name = "Apple SF Pro Text", Path = FONTS .. "SFProText-Bold.ttf"},
 {Name = "Inter Bold", Path = FONTS .. "Inter-Bold.ttf"},
 {Name = "Inter SemiBold", Path = FONTS .. "Inter-SemiBold.ttf"},
 {Name = "Roboto", Path = FONTS .. "Roboto.ttf"},
 {Name = "Roboto Mono", Path = FONTS .. "RobotoMono.ttf"},
}

FBT.AVAILABLE_OUTLINES = {
 {Name = "None", Style = ""},
 {Name = "Thin", Style = "OUTLINE"},
 {Name = "Thick", Style = "THICKOUTLINE"},
}

FBT.AVAILABLE_TEXT_ALIGNS = {
 {Name = "Left", AnchorPoint = "BOTTOMLEFT"},
 {Name = "Center", AnchorPoint = "BOTTOM"},
 {Name = "Right", AnchorPoint = "BOTTOMRIGHT"},
}

-- Trigger types in editor order. The numbers are saved; 6 was the retired
-- Search Pattern type.
FBT.AVAILABLE_TRIGGER_TYPES = {
 {Type = 1, Name = "Self Health"},
 {Type = 2, Name = "Self Mana"},
 {Type = 3, Name = "Pet Health"},
 {Type = 4, Name = "Enemy Target Health"},
 {Type = 5, Name = "Friendly Target Health"},
 {Type = 7, Name = "Aura Gained"},
 {Type = 8, Name = "You Dodge"},
 {Type = 9, Name = "You Parry"},
 {Type = 10, Name = "Your Attack Dodged"},
}

-- Shapeshift slots 1-6 by class; the last entry is "any".
FBT.AVAILABLE_STANCES = {
 {Name = "|cffC79C6EBattle Stance|r/|cffFF7D0ABear Form|r/|cffFFF569Stealth|r/|cffF58CBADevotion Aura"},
 {Name = "|cffC79C6EDefensive Stance|r/|cffFF7D0AAquatic Form|r/|cffF58CBARetribution Aura"},
 {Name = "|cffC79C6EBerserker Stance|r/|cffFF7D0ACat Form|r/|cffF58CBAConcentration Aura"},
 {Name = "|cffFF7D0ATravel Form|r/|cffF58CBAShadow Resistance Aura"},
 {Name = "|cffFF7D0AMoonkin Form|r/|cffF58CBAFrost Resistance Aura"},
 {Name = "|cffF58CBAFire Resistance Aura"},
 {Name = "Any"},
}

-------------------------------------------------------------------------------------
-- The default profile. Event, trigger and filter keys keep their MSBT names:
-- they are the saved keys.
--  %a amount, %n other unit's name, %s spell/ability/buff/power, %t damage school.
-------------------------------------------------------------------------------------

FBT.DEFAULT_PROFILE_NAME = "Default"

local function Font(size) return {FontIndex = 0, OutlineIndex = 0, FontSize = size or 0} end

-- A combat event: message, color, normal size, and a crit size when the event
-- can crit (0 inherits the size).
local function Event(message, r, g, b, size, critSize)
 local fonts = {Color = {r = r, g = g, b = b}, Normal = Font(size)}
 if critSize then fonts.Crit = Font(critSize) end
 return {Show = true, Message = message, FontSettings = fonts}
end

-- A notice: message, color, whether it pops in place, its size.
local function Notice(message, r, g, b, sticky, size)
 local event = Event(message, r, g, b, size)
 event.IsSticky = sticky
 return event
end

local E, N = Event, Notice
local events = {
 MSBT_EVENTTYPE_INCOMING_DAMAGE = E("-%a", 1, 1, 1, 0, 0),
 MSBT_EVENTTYPE_INCOMING_MISS = E("Miss!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_DODGE = E("Dodge!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_PARRY = E("Parry!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_BLOCK = E("Block!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_ABSORB = E("Absorb!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_IMMUNE = E("Immune!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_EVADE = E("Evade!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_DAMAGE = E("-%a", 1, 1, 0, 0, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_DOT = E("-%a", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_MISS = E("Miss!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_SPELL_DODGE = E("Dodge!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_SPELL_PARRY = E("Parry!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_SPELL_BLOCK = E("Block!", 0, 0, 1),
 MSBT_EVENTTYPE_INCOMING_SPELL_RESIST = E("(%s) Resist!", 0.502, 0, 0.502),
 MSBT_EVENTTYPE_INCOMING_SPELL_ABSORB = E("(%s) Absorb!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_IMMUNE = E("(%s) Immune!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_REFLECT = E("(%s) Reflect!", 0.502, 0, 0.502, 0, 0),
 MSBT_EVENTTYPE_INCOMING_SPELL_EVADE = E("(%s) Evade!", 1, 1, 0),
 MSBT_EVENTTYPE_INCOMING_HEAL = E("+%a (%n)", 0, 1, 0, 0, 0),
 MSBT_EVENTTYPE_INCOMING_HOT = E("+%a (%n)", 0, 1, 0),
 MSBT_EVENTTYPE_INCOMING_ENVIRONMENTAL = E("-%a %s", 1, 0, 0),
 MSBT_EVENTTYPE_INCOMING_PET_DAMAGE = E("-%a (Pet)", 1, 1, 1, 0, 0),
 MSBT_EVENTTYPE_INCOMING_PET_MISS = E("Miss! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_DODGE = E("Dodge! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_PARRY = E("Parry! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_BLOCK = E("Block! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_ABSORB = E("Absorb! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_IMMUNE = E("Immune! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_EVADE = E("Evade! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_DAMAGE = E("-%a (Pet)", 1, 0.7, 0, 0, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_DOT = E("-%a (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_MISS = E("Miss! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_DODGE = E("Dodge! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_PARRY = E("Parry! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_BLOCK = E("Block! (Pet)", 0.2, 0.4, 1),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_RESIST = E("Resist! (Pet)", 0.5, 0, 0.4),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_ABSORB = E("(%s) Absorb! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_IMMUNE = E("(%s) Immune! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_EVADE = E("(%s) Evade! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_SPELL_REFLECT = E("(%s) Reflect! (Pet)", 1, 0.7, 0),
 MSBT_EVENTTYPE_INCOMING_PET_HEAL = E("+%a (%n) (Pet)", 0, 1, 0.4, 0, 0),
 MSBT_EVENTTYPE_INCOMING_PET_HOT = E("+%a (%n) (Pet)", 0, 1, 0.4),

 MSBT_EVENTTYPE_OUTGOING_DAMAGE = E("%a", 1, 1, 1, 0, 0),
 MSBT_EVENTTYPE_OUTGOING_MISS = E("Miss!", 0, 0, 1),
 MSBT_EVENTTYPE_OUTGOING_DODGE = E("Dodge!", 0, 0, 1),
 MSBT_EVENTTYPE_OUTGOING_PARRY = E("Parry!", 0, 0, 1),
 MSBT_EVENTTYPE_OUTGOING_BLOCK = E("Block!", 0, 0, 1),
 MSBT_EVENTTYPE_OUTGOING_ABSORB = E("Absorb!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_IMMUNE = E("Immune!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_EVADE = E("Evade!", 1, 0.502, 0, 22),
 MSBT_EVENTTYPE_OUTGOING_SPELL_DAMAGE = E("%a", 1, 1, 0, 0, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_DOT = E("%a", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_MISS = E("Miss!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_DODGE = E("Dodge!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_PARRY = E("Parry!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_BLOCK = E("Block!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_RESIST = E("Resist!", 0.502, 0.502, 0.698),
 MSBT_EVENTTYPE_OUTGOING_SPELL_ABSORB = E("(%s) Absorb!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_IMMUNE = E("(%s) Immune!", 1, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_REFLECT = E("(%s) Reflect!", 1, 1, 0, 0, 0),
 MSBT_EVENTTYPE_OUTGOING_SPELL_EVADE = E("(%s) Evade!", 1, 0.502, 0, 22),
 MSBT_EVENTTYPE_OUTGOING_HEAL = E("+%a", 0, 1, 0, 0, 22),
 MSBT_EVENTTYPE_OUTGOING_HOT = E("+%a", 0, 1, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_DAMAGE = E("Pet %a", 1, 0.502, 0, 0, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_MISS = E("Pet Miss!", 1, 0.502, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_DODGE = E("Pet Dodge!", 1, 0.502, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_PARRY = E("Pet Parry!", 1, 0.502, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_BLOCK = E("Pet Block!", 1, 0.502, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_ABSORB = E("Pet Absorb!", 0.502, 0.502, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_IMMUNE = E("Pet Immune!", 0.502, 0.502, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_EVADE = E("Pet Evade!", 1, 0.502, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DAMAGE = E("Pet %a (%s)", 0.33, 0.33, 1, 0, 0),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_MISS = E("Pet Miss! (%s)", 0.33, 0.33, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_DODGE = E("Pet Dodge! (%s)", 0.33, 0.33, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_PARRY = E("Pet Parry! (%s)", 0.33, 0.33, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_BLOCK = E("Pet Block! (%s)", 0.33, 0.33, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_RESIST = E("Pet Resist! (%s)", 0.502, 0.502, 0.698),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_ABSORB = E("Pet Absorb! (%s)", 0.502, 0.502, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_IMMUNE = E("Pet Immune! (%s)", 0.502, 0.502, 1),
 MSBT_EVENTTYPE_OUTGOING_PET_SPELL_EVADE = E("Pet Evade! (%s)", 1, 0.502, 1, 22),

 MSBT_EVENTTYPE_NOTIFICATION_DEBUFF = N("[%s]", 0, 0.502, 0.502, false),
 MSBT_EVENTTYPE_NOTIFICATION_BUFF = N("[%s]", 0.698, 0.698, 0, false),
 MSBT_EVENTTYPE_NOTIFICATION_BUFF_FADE = N("-[%s]", 0.698, 0.698, 0, false),
 MSBT_EVENTTYPE_NOTIFICATION_COMBAT_ENTER = N("+Combat", 1, 0.25, 0.25, false),
 MSBT_EVENTTYPE_NOTIFICATION_COMBAT_LEAVE = N("-Combat", 0.25, 1, 0.25, false),
 MSBT_EVENTTYPE_NOTIFICATION_POWER_GAIN = N("+%a", 0.3098039215686275, 0.3098039215686275, 0.8784313725490196, false),
 MSBT_EVENTTYPE_NOTIFICATION_POWER_LOSS = N("-%a", 0.7568627450980392, 0.2705882352941176, 0.8235294117647058, false),
 MSBT_EVENTTYPE_NOTIFICATION_CP_GAIN = N("%a CP", 1, 0.502, 0, false),
 MSBT_EVENTTYPE_NOTIFICATION_CP_FULL = N("%a CP Finish It!", 1, 0.502, 0, false),
 MSBT_EVENTTYPE_NOTIFICATION_HONOR_GAIN = N("+%a Honor", 0.502, 0.502, 0.698, false),
 MSBT_EVENTTYPE_NOTIFICATION_REP_GAIN = N("+%a Reputation (%s)", 0.502, 0.502, 0.698, false),
 MSBT_EVENTTYPE_NOTIFICATION_REP_LOSS = N("-%a Reputation (%s)", 0.502, 0.502, 0.698, false),
 MSBT_EVENTTYPE_NOTIFICATION_SKILL_GAIN = N("%s: %a", 0.333, 0.333, 1, false),
 MSBT_EVENTTYPE_NOTIFICATION_EXPERIENCE_GAIN = N("%a XP", 0.756, 0.270, 0.823, true, 26),
 MSBT_EVENTTYPE_NOTIFICATION_PC_KILLING_BLOW = N("Killing Blow! (%s)", 0.333, 0.333, 1, true, 20),
 MSBT_EVENTTYPE_NOTIFICATION_NPC_KILLING_BLOW = N("Killing Blow! (%s)", 0.333, 0.333, 1, true, 20),
}
events.MSBT_EVENTTYPE_NOTIFICATION_COMBAT_ENTER.BigIcon = false
events.MSBT_EVENTTYPE_NOTIFICATION_COMBAT_LEAVE.BigIcon = false
events.MSBT_EVENTTYPE_NOTIFICATION_NPC_KILLING_BLOW.Show = false

-- A trigger: message, color, sticky, the trigger settings and an icon.
local function Trigger(message, r, g, b, sticky, settings, icon)
 return {
  EventSettings = {Show = true, Message = message, IsSticky = sticky,
   FontSettings = {Color = {r = r, g = g, b = b}, Normal = Font(26)}},
  TriggerSettings = settings,
  Texture = icon and ("Interface\\Icons\\" .. icon),
 }
end

local CASTERS = {DRUID = true, HUNTER = true, MAGE = true, PALADIN = true, PRIEST = true, SHAMAN = true, WARLOCK = true}

FBT.DEFAULT_CONFIG = {
 ShowPartialEffects = true,
 ShowGameDamage = false,
 UseStickyCrits = true,
 ShowAllManaGains = false,
 LowHealthSound = true,
 LowManaSound = true,
 ResistSound = true,
 AnimationStep = 1.5,
 MasterFontSettings = {
  Normal = {FontIndex = 37, OutlineIndex = 2, FontSize = 20},
  Crit = {FontIndex = 37, OutlineIndex = 2, FontSize = 26},
 },
 BlizzardFontSettings = {Normal = {FontIndex = 6}},
 DisplaySettings = {
  Incoming = {Show = true, FrameOffsets = {x = -159, y = -46}, AnimationStyle = 1, ScrollDirection = 1, ScrollHeight = 222,
   FontSettings = {Normal = Font(), Crit = Font(), TextAlignIndex = 3}},
  Outgoing = {Show = true, FrameOffsets = {x = 153, y = -43}, AnimationStyle = 1, ScrollDirection = 1, ScrollHeight = 212,
   FontSettings = {Normal = Font(), Crit = Font(), TextAlignIndex = 1}},
  Notification = {Show = true, FrameOffsets = {x = -5, y = 169}, AnimationStyle = 1, ScrollDirection = 1, ScrollHeight = 150,
   FontSettings = {Normal = Font(), Crit = Font(), TextAlignIndex = 2}},
 },
 EventSettings = events,
 Triggers = {
  MSBT_TRIGGER_LOW_HEALTH = Trigger("Low Health! (%1)", 1, 0.502, 0.502, false,
   {TriggerType = 1, Threshold = 40}, "spell_holy_sealofsacrifice"),
  MSBT_TRIGGER_LOW_MANA = Trigger("Low Mana! (%1)", 0.502, 0.502, 1, false,
   {Classes = CASTERS, TriggerType = 2, Threshold = 35}),
  MSBT_TRIGGER_LOW_PET_HEALTH = Trigger("Low Pet Health! (%1)", 1, 0.502, 0.502, false,
   {Classes = {HUNTER = true, WARLOCK = true}, TriggerType = 3, Threshold = 40}, "spell_holy_sealofsacrifice"),
  MSBT_TRIGGER_EXECUTE = Trigger("Execute!", 1, 1, 0, true,
   {Classes = {WARRIOR = true}, TriggerType = 4, Threshold = 20}, "inv_sword_48"),
  MSBT_TRIGGER_HAMMER_OF_WRATH = Trigger("Hammer of Wrath!", 1, 1, 0, true,
   {Classes = {PALADIN = true}, TriggerType = 4, Threshold = 20}, "ability_thunderclap"),
  MSBT_TRIGGER_COUNTER_ATTACK = Trigger("Counterattack!", 1, 1, 0, true,
   {Classes = {HUNTER = true}, TriggerType = 9}, "ability_warrior_challange"),
  MSBT_TRIGGER_MONGOOSE_BITE = Trigger("Mongoose Bite!", 1, 1, 0, true,
   {Classes = {HUNTER = true}, TriggerType = 8}, "ability_hunter_swiftstrike"),
  MSBT_TRIGGER_CLEARCAST = Trigger("Clearcasting!", 1, 1, 0, true,
   {Classes = {MAGE = true, SHAMAN = true}, TriggerType = 7, AuraName = "Clearcasting"}, "spell_shadow_manaburn"),
  MSBT_TRIGGER_RIPOSTE = Trigger("Riposte!", 1, 1, 0, true,
   {Classes = {ROGUE = true}, TriggerType = 9}, "ability_warrior_challange"),
  MSBT_TRIGGER_WINDFURY = Trigger("Windfury!", 1, 1, 0, true,
   {TriggerType = 7, AuraName = "Windfury Totem"}, "spell_nature_cyclone"),
  MSBT_TRIGGER_NIGHTFALL = Trigger("Nightfall!", 0.709, 0, 0.709, true,
   {Classes = {WARLOCK = true}, TriggerType = 7, AuraName = "Shadow Trance"}, "spell_shadow_twilight"),
  MSBT_TRIGGER_OVERPOWER = Trigger("Overpower!", 1, 1, 0, true,
   {Classes = {WARRIOR = true}, TriggerType = 10}, "ability_meleedamage"),
 },
 -- Filters hide messages that contain the text.
 Suppressions = {
  MSBT_SUPPRESSION_WISDOM_MANA_GAINS = {Enabled = true, SearchPattern = "Judgement of Wisdom"},
  MSBT_SUPPRESSION_ROGUE_VIGOR = {Enabled = true, SearchPattern = "Vigor"},
  MSBT_SUPPRESSION_SHAMAN_WINDFURY = {Enabled = false, SearchPattern = "Windfury"},
  MSBT_SUPPRESSION_SHAMAN_HEALING_STREAM = {Enabled = true, SearchPattern = "Healing Stream"},
  MSBT_SUPPRESSION_SHAMAN_MANA_SPRING = {Enabled = true, SearchPattern = "Mana Spring"},
  MSBT_SUPPRESSION_SHAMAN_GRACE_OF_AIR = {Enabled = false, SearchPattern = "Grace of Air"},
  MSBT_SUPPRESSION_SHAMAN_STRENGTH_OF_EARTH = {Enabled = true, SearchPattern = "Strength of Earth"},
  MSBT_SUPPRESSION_SHAMAN_STONESKIN = {Enabled = true, SearchPattern = "Stoneskin"},
  MSBT_SUPPRESSION_SHAMAN_LIGHTNING_SHIELD = {Enabled = true, SearchPattern = "Lightning Shield"},
 },
}
