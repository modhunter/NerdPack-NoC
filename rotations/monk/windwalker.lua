-- Syncronized with simc APL as of simc commit 2d8f9afd71e21254ced2891789722ff1970f57d4

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
			{type = 'checkbox', text = 'Automatic Chi Wave at pull', key = 'auto_cw', default = true},
			{type = 'checkbox', text = 'Automatic Mark of the Crane Dotting', key = 'auto_dot', default = false},
			{type = 'checkbox', text = 'Smart RJW usage during single-target rotation', key = 'smart_rjw', default = true},
			{type = 'checkbox', text = 'Automatic Res', key = 'auto_res', default = false},
			--{type = 'checkbox', text = 'Automatic Pre-Pot', key = 'auto_pot', default = false},
			{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 35},
		{type = 'spinner', text = 'Effuse', key = 'effuse', default = 30},
		{type = 'spinner', text = 'Healing Elixir', key = 'Healing Elixir', default = 70},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local SEF_Fixate_Casted = false
local sef = function()
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
	[117952] = '', -- Crackling Jade Lightning
}
local goodLastCast = function()
	local _, _, _, _, _, _, spellID = GetSpellInfo(NeP.Engine.lastCast)
	return MasterySpells[spellID] ~= nil
end

local healthstn = function()
	return E('player.health <= ' .. F('Healthstone'))
end

local HealingElixir = function()
	return E('player.health <= ' .. F('Healing Elixir'))
end

local effuse = function()
	return E('player.health <= ' .. F('effuse'))
end



local _OOC = {
	{ "Effuse", { "player.health < 90", "player.lastmoved >= 1", "!player.combat" }, "player" },

	-- Automatic res of dead party members
	{ "@NOC.resDeadFriends('Resuscitate')", (function() return F('auto_res') end) },

	-- TODO: Add support for (optional) automatic potion use w/pull timer
}

local _All = {
	-- Keybinds
	{ "Leg Sweep", "modifier.lcontrol" },
  { "Touch of Karma", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget\n/nep mt", { "player.time >= 300", (function() return F('dpstest') end) }},

	-- Cancel CJL when we're in melee range and having cast at least 1 second (delta < 2)- to help with controlling Hit Combo stuff.
	{"!/stopcasting", { "target.range <= 5", "player.casting(Crackling Jade Lightning)", "player.casting.delta < 2" }},

	-- FREEDOOM!
	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841
}

local _Cooldowns = {
	{ "Touch of Death", "!player.spell.usable(Gale Burst)" },
	{ "Touch of Death", { "player.spell.usable(Gale Burst)", "player.spell(Strike of the Windlord).cooldown <= 8", "player.spell(Fists of Fury).cooldown <= 3", "player.spell(Rising Sun Kick).cooldown < 8" }},
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
	-- Use Xuen only while hero or potion is active
	{ "Invoke Xuen, the White Tiger", "player.hashero" },
	{ "Invoke Xuen, the White Tiger", "player.buff(156423)" }, -- Draenic Agility Potion (WoD)
	{ "Invoke Xuen, the White Tiger", "player.buff(188027)" }, -- Potion of Deadly Grace (Legion)
}

local _Survival = {
	{ "Effuse", { "player.energy >= 60", "player.lastmoved >= 0.5", effuse }, "player" },
	{ "Healing Elixir", { "player.spell(Healing Elixir).charges >= 2", "or", { "player.spell(Healing Elixir).charges = 1", "player.spell(Healing Elixir).cooldown < 3" }, "!lastcast(Healing Elixir)", HealingElixir }, "player" },

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
		{ "Storm, Earth, and Fire", { '!modifier.multitarget', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Strike of the Windlord).cooldown <= 8", "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
	{{
		{ "Storm, Earth, and Fire", { '!modifier.multitarget', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
}

local _Ranged = {
	{ "116841", { "player.movingfor > 0.5", "target.alive" }},
	{ "Crackling Jade Lightning", { (function() return F('auto_cjl') end), "!player.moving", "player.time > 4" }},
	{ "Chi Wave", { (function() return F('auto_cw') end), "player.time <= 4", "target.range > 8" }},
}

local _Openner = {
	--{ (function() print('in openner: '..GetTime()); end) },
	{ "Fists of Fury", { "player.buff(Serenity)", "player.buff(Serenity).duration < 1.5" }},
	{ "Rising Sun Kick" },

	-- This should 'constrain' BoK to be only casted once during the opener
	{{
		{ "Blackout Kick", "player.buff(Serenity)" },
		{ "Blackout Kick", "player.spell(Chi Brew).charges = 2" },
	}, { "player.chidiff <= 1", "player.spell(Blackout Kick).casted = 0" }},
	{ 'Serenity', "player.chidiff >= 2" },
	{ "Tiger Palm", { "player.chidiff >= 2", "!player.buff(Serenity)", "!lastcast(Tiger Palm)", "player.spell(Blackout Kick).casted = 0" }},
}

local _AoE = {
	{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', goodLastCast, "player.spell(Spinning Crane Kick).count >= 2" }},
	{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
	{ "Rising Sun Kick" },
	{ "Rushing Jade Wind", { "player.chi >= 1", "!lastcast(Rushing Jade Wind)", goodLastCast }},
	{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', goodLastCast, "player.spell(Spinning Crane Kick).count >= 4" }},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "!player.buff(Serenity)", "player.timetomax > 2" }},
	{{
		{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { "player.buff(Blackout Kick!)", (function() return F('auto_dot') end) }},
		{ "Blackout Kick", "player.buff(Blackout Kick!)" },
  	{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { "player.chi > 1", (function() return F('auto_dot') end) }},
		{ "Blackout Kick", "player.chi > 1" },
	}, { "!lastcast(Blackout Kick)", goodLastCast }},

	{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)", { "!player.buff(Serenity)", "player.chidiff > 1", (function() return F('auto_dot') end), "!lastcast(Tiger Palm)", goodLastCast }},
	{ "Tiger Palm", { "!player.buff(Serenity)", "player.chidiff > 1", "!lastcast(Tiger Palm)", goodLastCast }},

}

local _ST = {
	{ 'Spinning Crane Kick', { (function() return F('smart_rjw') end), '!lastcast(Spinning Crane Kick)', goodLastCast, { "player.spell(Spinning Crane Kick).count >= 6", "or", { "player.spell(Spinning Crane Kick).count >= 2", "player.area(8).enemies >= 2" }}}},
	{ "Rising Sun Kick" },
	{ "Rushing Jade Wind", { "player.chi > 1", "!lastcast(Rushing Jade Wind)", goodLastCast }},
	{ 'Spinning Crane Kick', { (function() return F('smart_rjw') end), '!lastcast(Spinning Crane Kick)', goodLastCast, { "player.spell(Spinning Crane Kick).count >= 4", "or", "player.area(8).enemies >= 2" }}},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "!player.buff(Serenity)" }},
	{{
  	{ "Blackout Kick", "player.buff(Blackout Kick!)" },
  	{ "Blackout Kick", "player.chi > 1" },
	}, { "!player.buff(Serenity)", "!lastcast(Blackout Kick)", goodLastCast }},
	{ "Tiger Palm", { "!player.buff(Serenity)", "player.chi <= 2", "!lastcast(Tiger Palm)", goodLastCast }},
}

local _Melee = {
	{ 'Serenity', { "player.spell(Strike of the Windlord).cooldown <= 8", "player.spell(Rising Sun Kick).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 3" }},
	{ 'Serenity', { "player.spell(Rising Sun Kick).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 3" }},
	{ "Energizing Elixir", { "player.energydiff > 0", "player.chi <= 1", "!player.buff(Serenity)" }},
	{ "Rushing Jade Wind", { "player.buff(Serenity)", "!lastcast(Rushing Jade Wind)", goodLastCast }},
	{ "Strike of the Windlord" },
	{ 'Spinning Crane Kick', { (function() return F('smart_rjw') end), '!lastcast(Spinning Crane Kick)', goodLastCast, { "player.spell(Spinning Crane Kick).count >= 17" }}},
	{ "Whirling Dragon Punch" },
	{ 'Spinning Crane Kick', { (function() return F('smart_rjw') end), '!lastcast(Spinning Crane Kick)', goodLastCast, { "player.spell(Spinning Crane Kick).count >= 12" }}},
	{ "Fists of Fury" },

	{ _AoE, { 'player.area(8).enemies >= 3', 'modifier.multitarget' }},
	{ _ST },

	-- Last resort to keep using abilitites
	-- { "Blackout Kick", { "!lastcast(Blackout Kick)", goodLastCast }},
	-- { "Tiger Palm", { "!lastcast(Tiger Palm)", goodLastCast }},
	-- {{
	-- 	{ "Blackout Kick" },
	-- 	{ "Tiger Palm" },
	-- }, "!player.buff(Hit Combo)" },

	-- CJL when we're using Hit Combo as a last resort, and perhaps with other constraints like "GoodLastCast"
	--{ "Crackling Jade Lightning", { "!lastcast(Crackling Jade Lightning)", goodLastCast }},

	--{ (function() print('I have nothing to do ('..GetTime()..')'); end) },
}

NeP.Engine.registerRotation(269, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Windwalker',
	{ -- In-Combat
		{'pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, { 'target.interruptAt(55)', 'target.inMelee' }},
		{_Cooldowns, 'modifier.cooldowns' },
		{_SEF, { "target.range <= 5", (function() return F('SEF') end) }},
		--{_Openner, { (function() return F('opener') end), "player.time < 10" }},
		{_Melee, { "target.range <= 5" }},
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _OOC, exeOnLoad)
