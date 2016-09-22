-- Syncronized with simc APL as of simc commit a32b6ff633e8ab4f1b9d3cd2c7deb079a318cf52 (from 8c5f29f1c1df44a70b183b08b158ecc7469d77cd)

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
		{type = 'checkbox', text = 'Automatic Res', key = 'auto_res', default = false},
		--{type = 'checkbox', text = 'Automatic Pre-Pot', key = 'auto_pot', default = false},
		{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 35},
		{type = 'spinner', text = 'Effuse', key = 'effuse', default = 30},
		{type = 'spinner', text = 'Healing Elixir', key = 'Healing Elixir', default = 0},

		-- Offensive
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Offensive', align = 'center'},
		{type = 'checkbox', text = 'Opener', key = 'opener', default = true},
		{type = 'checkbox', text = 'SEF usage', key = 'SEF', default = true},
		{type = 'checkbox', text = 'Automatic CJL at range', key = 'auto_cjl', default = false},
		{type = 'checkbox', text = 'Automatic Chi Wave at pull', key = 'auto_cw', default = true},
		{type = 'checkbox', text = 'Automatic Mark of the Crane Dotting', key = 'auto_dot', default = true},
		{type = 'checkbox', text = 'Automatic CJL in melee to maintain Hit Combo', key = 'auto_cjl_hc', default = true},

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
	{ "Effuse", { "player.health < 50", "player.lastmoved >= 1" }, "player" },

	-- Automatic res of dead party members
	{ "%ressdead('Resuscitate')", (function() return F('auto_res') end) },

	-- TODO: Add support for (optional) automatic potion use w/pull timer
}

local _All = {
	-- keybind
	{ "Leg Sweep", "keybind(lcontrol)" },
  { "Touch of Karma", "keybind(lalt)" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget\n/nep mt", { "player.combat.time >= 300", (function() return F('dpstest') end) }},

	-- Cancel CJL when we're in melee range
	{ "!/stopcasting", { "target.range <= 5", "player.casting(Crackling Jade Lightning)" }},

	-- FREEDOOM!
	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841
}

local _Cooldowns = {
	{{
		{ 'Serenity', { "player.spell(Strike of the Windlord).cooldown < 14", "player.spell(Rising Sun Kick).cooldown < 7", "player.spell(Fists of Fury).cooldown <= 15" }},
		-- TODO: add logic to handle ToD interaction with legendary item 137057
		{ "Touch of Death", "!player.spell.usable(Gale Burst)" },
		{ "Touch of Death", { "player.spell.usable(Gale Burst)", "player.spell(Strike of the Windlord).cooldown <= 8", "player.spell(Fists of Fury).cooldown <= 4", "player.spell(Rising Sun Kick).cooldown < 7" }},
	}, "target.range <= 5" },

	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
	{ "#trinket1", { "player.buff(Serenity)", "or", "player.buff(Storm, Earth, and Fire)" }},
	{ "#trinket2", { "player.buff(Serenity)", "or", "player.buff(Storm, Earth, and Fire)" }},
	-- Use Xuen only while hero or potion (WOD: 156423, Legion: 188027) is active
	{ "Invoke Xuen, the White Tiger", "player.hashero", "or", "player.buff(156423)", "or", "player.buff(188027)" },
}

local _Survival = {
	{ "Effuse", { "player.energy >= 60", "player.lastmoved >= 0.5", effuse }, "player" },
	{ "Healing Elixir", { HealingElixir }, "player" },

	-- TODO: Update for legion's equivillant to healing tonic 109223
	-- TODO: Item usage may still be broken in NeP, consider commenting-out
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
		{ "Storm, Earth, and Fire", { '!toggle(AoE)', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Strike of the Windlord).exists", "player.spell(Strike of the Windlord).cooldown < 13", "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
	{{
		{ "Storm, Earth, and Fire", { '!toggle(AoE)', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "!player.spell(Strike of the Windlord).exists", "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
}

local _Ranged = {
	{ "116841", { "player.movingfor > 0.5", "target.alive" }}, -- Tiger's Lust
	{ "Crackling Jade Lightning", { (function() return F('auto_cjl') end), "!player.moving", "player.combat.time > 4" }},
	{ "Chi Wave", { (function() return F('auto_cw') end), "target.range > 8" }},
}

local _Openner = {
	{ "Invoke Xuen, the White Tiger", { "player.hashero", "or", "player.buff(156423)", "or", "player.buff(188027)" }},
	-- actions.opener=blood_fury
	-- actions.opener+=/berserking
	-- actions.opener+=/energizing_elixir
	{ "Energizing Elixir" },

	-- actions.opener+=/serenity
	{ "Serenity" },

	-- actions.opener+=/storm_earth_and_fire
	{ "Storm, Earth, and Fire", { '!toggle(AoE)', sef }},
	{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },

	-- actions.opener+=/rising_sun_kick,cycle_targets=1,if=buff.serenity.up
	{{
		{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
		{ "Rising Sun Kick" },
	}, { "player.buff(Serenity)" }},

	-- actions.opener+=/strike_of_the_windlord,if=talent.serenity.enabled|active_enemies<6
	{ "Strike of the Windlord", { "talent(7,3)", "or", "player.area(9).enemies < 6" }},

	-- actions.opener+=/fists_of_fury
	{ "Fists of Fury" },

	-- actions.opener+=/rising_sun_kick,cycle_targets=1
	{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
	{ "Rising Sun Kick" },

	-- actions.opener+=/whirling_dragon_punch
	{ "Whirling Dragon Punch" },

	-- actions.opener+=/spinning_crane_kick,if=buff.serenity.up&cooldown.rising_sun_kick.remains>1&!prev_gcd.spinning_crane_kick
	{ 'Spinning Crane Kick', { "player.buff(Serenity)", "player.spell(Rising Sun Kick).cooldown > 1", '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')" }},

	-- actions.opener+=/rushing_jade_wind,if=(buff.serenity.up|chi>1)&cooldown.rising_sun_kick.remains>1&!prev_gcd.rushing_jade_wind
	{{
		{ "Rushing Jade Wind", { "player.buff(Serenity)", "or", "player.chi > 1" }},
	}, { "player.spell(Rising Sun Kick).cooldown > 1", "!lastcast(Rushing Jade Wind)", "@NOC.hitcombo('Rushing Jade Wind')" }},

	-- actions.opener+=/blackout_kick,cycle_targets=1,if=chi>1&cooldown.rising_sun_kick.remains>1&!prev_gcd.blackout_kick
	{{
		{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { (function() return F('auto_dot') end) }},
		{ "Blackout Kick" },
	}, { "player.chi > 1", "player.spell(Rising Sun Kick).cooldown > 1", "!lastcast(Blackout Kick)", "@NOC.hitcombo('Blackout Kick')" }},

	-- actions.opener+=/chi_wave
	{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi

	-- actions.opener+=/chi_burst
	{ "Chi Burst", "!player.moving" },

	-- actions.opener+=/tiger_palm,cycle_targets=1,if=chi.max-chi>=2&!prev_gcd.tiger_palm
	{{
		{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)"},
		{ "Tiger Palm" },
	}, { "player.chidiff >= 2", "!lastcast(Tiger Palm)", "@NOC.hitcombo('Tiger Palm')" }},

	-- actions.opener+=/arcane_torrent,if=chi.max-chi>=1

}

local _Serenity = {
	-- actions.serenity=strike_of_the_windlord
	{ "Strike of the Windlord" },
	-- actions.serenity+=/rising_sun_kick,cycle_targets=1
	{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
	{ "Rising Sun Kick" },
	-- actions.serenity+=/fists_of_fury
	{ "Fists of Fury" },
	-- actions.serenity+=/spinning_crane_kick,if=cooldown.rising_sun_kick.remains>1&!prev_gcd.spinning_crane_kick
	{ 'Spinning Crane Kick', { "player.spell(Rising Sun Kick).cooldown > 1", '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')" }},
	-- actions.serenity+=/rushing_jade_wind,if=cooldown.rising_sun_kick.remains>1&!prev_gcd.rushing_jade_wind
	{ "Rushing Jade Wind", { "player.spell(Rising Sun Kick).cooldown > 1", "!lastcast(Rushing Jade Wind)", "@NOC.hitcombo('Rushing Jade Wind')" }},
	-- actions.serenity+=/blackout_kick,cycle_targets=1,if=cooldown.rising_sun_kick.remains>1&!prev_gcd.blackout_kick
	{{
		{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { (function() return F('auto_dot') end) }},
		{ "Blackout Kick" },
	}, { "player.spell(Rising Sun Kick).cooldown > 1", "!lastcast(Blackout Kick)", "@NOC.hitcombo('Blackout Kick')" }},
}

local _AoE = {
	{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", "player.spell(Spinning Crane Kick).count >= 2" }},
	{ "Rushing Jade Wind", { "player.chi > 1", "!lastcast(Rushing Jade Wind)", "@NOC.hitcombo('Rushing Jade Wind')" }},
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", "player.spell(Spinning Crane Kick).count >= 4" }},
	{{
		{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { "player.buff(Blackout Kick!)", (function() return F('auto_dot') end) }},
		{ "Blackout Kick", "player.buff(Blackout Kick!)" },
		{ "@NOC.AoEMissingDebuff('Blackout Kick', 'Mark of the Crane', 5)", { "player.chi > 1", (function() return F('auto_dot') end) }},
		{ "Blackout Kick", "player.chi > 1" },
	}, { "!lastcast(Blackout Kick)", "@NOC.hitcombo('Blackout Kick')" }},

	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "player.timetomax > 2" }},
	{{
		{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)"},
		{ "Tiger Palm" },
	}, { "player.chidiff > 1", "!lastcast(Tiger Palm)", "@NOC.hitcombo('Tiger Palm')" }},
}

local _ST = {
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 6", "or", { "player.spell(Spinning Crane Kick).count >= 2", "player.area(8).enemies >= 2" }}}},
	{ "Rushing Jade Wind", { "player.chi > 1", "!lastcast(Rushing Jade Wind)", "@NOC.hitcombo('Rushing Jade Wind')" }},
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 4", "or", "player.area(8).enemies >= 2" }}},
	{{
  	{ "Blackout Kick", "player.buff(Blackout Kick!)" },
  	{ "Blackout Kick", "player.chi > 1" },
	}, { "!lastcast(Blackout Kick)", "@NOC.hitcombo('Blackout Kick')" }},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "player.timetomax > 2" }},
	{{
		{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)"},
		{ "Tiger Palm" },
	}, { "player.chi <= 2", "!lastcast(Tiger Palm)", "@NOC.hitcombo('Tiger Palm')" }},
}

local _Melee = {
	{ _Serenity, { "player.buff(Serenity)" }},
	{ "Energizing Elixir", { "player.energydiff > 0", "player.chi <= 1", "!player.buff(Serenity)" }},
	{ "Strike of the Windlord", { "talent(7,3)", "or", "player.area(9).enemies < 6" }},
	{ "Fists of Fury" },
	{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
	{ "Rising Sun Kick" },
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 17" }}},
	{ "Whirling Dragon Punch" },
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 12" }}},

	{ _AoE, { 'player.area(8).enemies >= 3', 'toggle(AoE)' }},
	{ _ST },

	-- CJL when we're using Hit Combo as a last resort filler, and it's toggled on
	-- TODO: remove this or add a big energy buffer to the check since it is no longer free to cast
	{ "Crackling Jade Lightning", { (function() return F('auto_cjl_hc') end), "!lastcast(Crackling Jade Lightning)", "@NOC.hitcombo('Crackling Jade Lightning')" }},
}

NeP.Engine.registerRotation(269, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Windwalker',
	{ -- In-Combat
		{'%pause', 'keybind(shift)'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, { 'target.interruptAt(55)', 'target.inMelee' }},
		{_Openner, { (function() return F('opener') end), "player.combat.time < 15", "target.range <= 5" }},
		{_Cooldowns, { 'toggle(cooldowns)', "target.range <= 5" }},
		{_SEF, { "target.range <= 5", (function() return F('SEF') end) }},
		{_Melee, { "target.range <= 5" }},
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _OOC, exeOnLoad)
