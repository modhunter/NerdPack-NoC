local config = {
	key = 'NoC_Monk_WW',
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
			{type = 'checkbox', text = '5 min DPS test', key = 'dsptest', default = false},
      -- TODO: cast % (or randomized range) to use for interrupts

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 45},
		{type = 'spinner', text = 'Effuse', key = 'effuse', default = 40},
	}
}

NeP.Interface.buildGUI(config)

local exeOnLoad = function()
	NeP.Interface.CreateSetting('Class Settings', function() NeP.Interface.ShowGUI('NoC_Monk_WW') end)
end

local SEF_Fixate_Casted = false

local _SEF = function()
	if NOC.dynEval('player.buff(Storm, Earth, and Fire)') then
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

local healthstn = function()
	return NOC.dynEval('player.health <= ' .. NeP.Interface.fetchKey('NoC_Monk_WW', 'Healthstone'))
end

local effuse = function()
	return NOC.dynEval('player.health <= ' .. NeP.Interface.fetchKey('NoC_Monk_WW', 'effuse'))
end

local _All = {
	-- Keybinds
	{ 'pause', 'modifier.shift' },
	{ "Leg Sweep", "modifier.lcontrol" },
  { "Touch of Karma", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return NeP.Interface.fetchKey('NoC_Monk_WW', 'dsptest') end) }},

	-- FREEDOOM!
	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841

	-- Use this out of combat
	{ "Effuse", { "player.health < 100", "!player.moving", "!player.combat" }, "player" },
}

local _Cooldowns = {
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
	-- Use Xuen only while hero or potion is active
	{ "Invoke Xuen, the White Tiger", "player.hashero" },
	{ "Invoke Xuen, the White Tiger", "player.buff(156423)" },
}

local _Survival = {
	{ "Effuse", { "player.energy >= 60", "!player.moving", effuse }, "player" },
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
	}, { "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
}

local _Ranged = {
	{ "116841", { "player.movingfor > 0.5", "target.alive" }},
	{ "Crackling Jade Lightning", { "!player.moving", (function() return NeP.Interface.fetchKey('NoC_Monk_WW', 'auto_cjl') end) }},
}

local _Openner = {
	--{ "Fists of Fury", { "player.buff(Serenity).duration < 1.5" }},
	{ "Rising Sun Kick" },
	{ "Fists of Fury", { "player.buff(Serenity)" }},

	-- This should 'constrain' BoK to be only casted once during the opener
	{{
		{ "Blackout Kick", "player.buff(Serenity)" },
		{ "Blackout Kick", "player.spell(Chi Brew).charges = 2" },
	}, { "player.chidiff <= 1", "player.spell(Blackout Kick).casted = 0" }},
	{ 'Serenity', "player.chidiff >= 2" },
	{ "Tiger Palm", { "player.chidiff >= 2", "!player.buff(Serenity)", "!lastcast(Tiger Palm)", "player.spell(Blackout Kick).casted = 0" }},
}

local _AoE = {
	{ 'Spinning Crane Kick', { '!talent(6,1)', '!lastcast(Spinning Crane Kick)' }},
}

local _Melee = {
	{ "Touch of Death" },

	-- Rotation
	{{ -- infront
		{ 'Serenity', { "player.spell(Rising Sun Kick).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 3" }},
		{ "Energizing Elixir", { "player.energy < 100", "player.chi <= 1", "!player.buff(Serenity)" }},
		{ "Rushing Jade Wind", { "player.buff(Serenity)", "!lastcast(Rushing Jade Wind)" }},
		{ "Strike Of The Windlord" },
		{ "Whirling Dragon Punch" },
		{ "Fists of Fury" },

		{_AoE, { 'player.area(8).enemies >= 3', 'modifier.multitarget' }},

  	{ "Rising Sun Kick" },
		{ "Strike Of The Windlord" },
		{ "Rushing Jade Wind", { "player.chi > 1", "!lastcast(Rushing Jade Wind)" }},
		{{
			{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
			{ "Chi Burst", "!player.moving" },
		}, { "!player.buff(Serenity)" }},
		{{
    	{ "Blackout Kick", "player.buff(Blackout Kick!)" },
    	{ "Blackout Kick", "player.chi > 1" },
  	}, { "!player.buff(Serenity)", "!lastcast(Blackout Kick)" }},
		{ "Tiger Palm", { "!player.buff(Serenity)", "player.chi <= 2", "!lastcast(Tiger Palm)" }},
		{ "Blackout Kick", "!lastcast(Blackout Kick)", "!lastcast(Storm, Earth, and Fire)" },
		{ "Tiger Palm", "!lastcast(Tiger Palm)" },
		{ "Tiger Palm", { "player.chi = 0", "lastcast(Tiger Palm)" }},
	}, 'target.infront' },
}



NeP.Engine.registerRotation(269, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Windwalker',
	{ -- In-Combat
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Cooldowns, 'modifier.cooldowns'},
		{{ -- Conditions
			-- Melee
			{{
				{_SEF, (function() return NeP.Interface.fetchKey('NoC_Monk_WW', 'SEF') end) },
				{_Openner, { "player.time < 16", (function() return NeP.Interface.fetchKey('NoC_Monk_WW', 'opener') end) }},
				{_Melee },
			}, "target.range <= 5" },
			{_Ranged, { "target.range > 8", "target.range <= 40" }},
		}, {'target.range <= 40', 'target.exists'} }
	}, _All, exeOnLoad)
