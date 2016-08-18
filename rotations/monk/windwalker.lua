local mKey = 'NoC_Monk_WW'
local config = {
	key = mKey,
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Monk WindWalker Settings',
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		-- General
			{type = 'header',text = 'General', align = 'center'},
			{type = 'checkbox', text = 'SEF', key = 'SEF', default = true},
			{type = 'checkbox', text = 'Opener', key = 'opener', default = true},
			{type = 'checkbox', text = 'Automatic CJL', key = 'auto_cjl', default = true},
			{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 45},
		{type = 'spinner', text = 'Effuse', key = 'effuse', default = 40},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local SEF_Fixate_Casted = false

local _SEF = function()
	if E('player.buff(Storm, Earth, and Fire)') then
		if SEF_Fixate_Casted then
			return false
		else
			SEF_Fixate_Casted = true
			return true
		end
	else
		SEF_Fixate_Casted = false
	end
	return false
end

-- List of spells that can benefit Mastery
local MasterySpells = {
	[100784] = '', -- Blackout Kick
	[113656] = '', -- Fists of Fury
	[101545] = '', -- Flying Serpent Kick
	[107428] = '', -- Rising Sun Kick
	[101546] = '', -- Spinning Crane Kick
	[205320] = '', -- Strike of the Windlord
	[100780] = '', -- Tiger Palm
	[115080] = '', -- Touch of Death
	[115098] = '', -- Chi Wave
	[123986] = '', -- Chi Burst
	[116847] = '', -- Rushing Jade Wind
	[152175] = '', -- Whirling Dragon Punch
}

local _GoodLastCast = function()
	local _, _, _, _, _, _, spellID = GetSpellInfo(NeP.Engine.lastCast)
	return MasterySpells[spellID] ~= nil
end

local healthstn = function()
	return E('player.health <= ' .. F('Healthstone'))
end

local effuse = function()
	return E('player.health <= ' .. F('effuse'))
end

local _OOC = {
	{ "Effuse", { "player.health < 100", "player.lastmoved >= 1", "!player.combat" }, "player" },
}

local _All = {
	-- Keybinds
	--{ 'pause', 'modifier.shift' },
	{ "Leg Sweep", "modifier.lcontrol" },
  { "Touch of Karma", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return F('dpstest') end) }},

	-- FREEDOOM!
	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841
}

local _Cooldowns = {
	{ "Touch of Death", "!player.spell.usable(Gale Burst)" },
	{ "Touch of Death", { "player.spell.usable(Gale Burst)", "player.spell(Strike of the Windlord).cooldown <= 0.5", "player.spell(Fists of Fury).cooldown <= 3", "player.spell(Rising Sun Kick).cooldown < 8" }},
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
	-- Use Xuen only while hero or potion is active
	{ "Invoke Xuen, the White Tiger", "player.hashero" },
	{ "Invoke Xuen, the White Tiger", "player.buff(156423)" }, -- Draenic Agility Potion (WoD)
	--{ "Invoke Xuen, the White Tiger", "player.buff(188027)" }, -- Potion of Deadly Grace (Legion)
}

local _Survival = {
	{ "Effuse", { "player.energy >= 60", "!player.movingfor > 0.5", effuse }, "player" },
	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ "#109223", healthstn, "player" }, -- Healing Tonic
	{ '#5512', healthstn, "player" }, -- Healthstone
	{ "Detox", "player.dispellable(Detox)", "player" },
}

local _Interrupts = {
	{ "Ring of Peace", { -- Ring of Peace when SHS is on CD
     "!target.debuff(Spear Hand Strike)",
     "player.spell(Spear Hand Strike).cooldown > 1",
     "!lastcast(Spear Hand Strike)"
  }},
  { "Leg Sweep", { -- Leg Sweep when SHS is on CD
     "player.spell(Spear Hand Strike).cooldown > 1",
     "target.range <= 5",
     "!lastcast(Spear Hand Strike)"
  }},
  { "Quaking Palm", { -- Quaking Palm when SHS is on CD
     "!target.debuff(Spear Hand Strike)",
     "player.spell(Spear Hand Strike).cooldown > 1",
     "!lastcast(Spear Hand Strike)"
  }},
  { "Spear Hand Strike" }, -- Spear Hand Strike
}

local _SEF = {
	{{
		{ "Storm, Earth, and Fire", { '!modifier.multitarget', (function() return _SEF() end) }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Strike of the Windlord).cooldown <= 0.5", "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
	{{
		{ "Storm, Earth, and Fire", { '!modifier.multitarget', (function() return _SEF() end) }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
}

local _Ranged = {
	{ "116841", { "player.movingfor > 0.5", "target.alive" }},
	{ "Crackling Jade Lightning", { "!player.moving", (function() return F('auto_cjl') end) }},
}

local _Openner = {
	{ "Rising Sun Kick" },
	{ "Fists of Fury", { "player.buff(Serenity)", "player.buff(Serenity).duration < 1.5" }},

	-- This should 'constrain' BoK to be only casted once during the opener
	{{
		{ "Blackout Kick", "player.buff(Serenity)" },
		{ "Blackout Kick", "player.spell(Chi Brew).charges = 2" },
	}, { "player.chidiff <= 1", "player.spell(Blackout Kick).casted = 0" }},
	{ 'Serenity', "player.chidiff >= 2" },
	{ "Tiger Palm", { "player.chidiff >= 2", "!player.buff(Serenity)", "!lastcast(Tiger Palm)", "player.spell(Blackout Kick).casted = 0" }},
}

local _AoE = {
	-- TODO: add some complicated logic to 'multi-dot' enemies to set-up for the big Spinning Crane Kick bonus
	{ 'Spinning Crane Kick', { '!talent(6,1)', '!lastcast(Spinning Crane Kick)', (function() return _GoodLastCast() end) }},
	{ "Strike Of The Windlord" },
	{ "Rushing Jade Wind", { "player.chi >= 2", "!lastcast(Rushing Jade Wind)", (function() return _GoodLastCast() end) }},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "!player.buff(Serenity)" }},
	{ "Tiger Palm", { "!player.buff(Serenity)", "player.chi <= 2", "!lastcast(Tiger Palm)", (function() return _GoodLastCast() end) }},
}

local _Melee = {
	{ 'Serenity', { "player.spell(Strike of the Windlord).cooldown <= 0.5", "player.spell(Rising Sun Kick).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 3" }},
	{ 'Serenity', { "player.spell(Rising Sun Kick).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 3" }},
	{ "Energizing Elixir", { "player.energy < 100", "player.chi <= 1", "!player.buff(Serenity)" }},
	{ "Rushing Jade Wind", { "player.buff(Serenity)", "!lastcast(Rushing Jade Wind)", (function() return _GoodLastCast() end) }},
	{ "Whirling Dragon Punch" },
	{ "Fists of Fury" },

	{_AoE, { 'player.area(8).enemies >= 3', 'modifier.multitarget' }},

	{ "Rising Sun Kick" },
	{ "Strike Of The Windlord" },
	{ "Rushing Jade Wind", { "player.chi > 1", "!lastcast(Rushing Jade Wind)", (function() return _GoodLastCast() end) }},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "!player.buff(Serenity)" }},
	{{
  	{ "Blackout Kick", "player.buff(Blackout Kick!)" },
  	{ "Blackout Kick", "player.chi > 1" },
	}, { "!player.buff(Serenity)", "!lastcast(Blackout Kick)", (function() return _GoodLastCast() end) }},
	{ "Tiger Palm", { "!player.buff(Serenity)", "player.chi <= 2", "!lastcast(Tiger Palm)", (function() return _GoodLastCast() end) }},
	{ "Blackout Kick", { "!lastcast(Blackout Kick)", (function() return _GoodLastCast() end) }},
	{ "Tiger Palm", { "!lastcast(Tiger Palm)", (function() return _GoodLastCast() end) }},
}

NeP.Engine.registerRotation(269, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Windwalker',
	{ -- In-Combat
		{'pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, {'target.interruptAt(40)', "target.infront" }},
		{_Cooldowns, 'modifier.cooldowns'},
		{_SEF, { "target.range <= 5", (function() return F('SEF') end) }},
		{_Openner, { "player.time < 16", "target.infront", (function() return F('opener') end) }},
		{_Melee, { "target.range <= 5", "target.infront" }},
		{_Ranged, { "target.range > 8", "target.range <= 40", "target.infront" }},
	}, _OOC, exeOnLoad)
