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
	{ "Crackling Jade Lightning", { (function() return F('auto_cjl') end), "!player.moving", "player.combat.time > 4", "!lastcast(Crackling Jade Lightning)", "@NOC.hitcombo('Crackling Jade Lightning')" }},
	{ "Chi Wave", { (function() return F('auto_cw') end), "target.range > 8" }},
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
		{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)", (function() return F('auto_dot') end) },
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
		{ "@NOC.AoEMissingDebuff('Tiger Palm', 'Mark of the Crane', 5)", { (function() return F('auto_dot') end) }},
		{ "Tiger Palm" },
	}, { "player.chi <= 2", "!lastcast(Tiger Palm)", "@NOC.hitcombo('Tiger Palm')" }},
}

local _Melee = {
	{ _Serenity, { "player.buff(Serenity)" }},
	{ "Energizing Elixir", { "player.energydiff > 0", "player.chi <= 1", "!player.buff(Serenity)" }},
	{ "Strike of the Windlord", { "talent(7,3)", "or", "player.area(9).enemies < 6" }},
	{ "Fists of Fury" },
	{ "@NOC.AoEMissingDebuff('Rising Sun Kick', 'Mark of the Crane', 5)", { (function() return F('auto_dot') end) }},
	{ "Rising Sun Kick" },
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 17" }}},
	{ "Whirling Dragon Punch" },
	--{ 'Spinning Crane Kick', { '!lastcast(Spinning Crane Kick)', "@NOC.hitcombo('Spinning Crane Kick')", { "player.spell(Spinning Crane Kick).count >= 12" }}},

	{ _AoE, { 'player.area(8).enemies >= 3', 'toggle(AoE)' }},
	{ _ST },

	-- CJL when we're using Hit Combo as a last resort filler, and it's toggled on
	-- TODO: remove this in 7.1 or add a big energy buffer to the check since it is no longer free to cast
	{ "Crackling Jade Lightning", { (function() return F('auto_cjl_hc') end), "!lastcast(Crackling Jade Lightning)", "@NOC.hitcombo('Crackling Jade Lightning')" }},
}

NeP.Engine.registerRotation(269, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Windwalker',
	{ -- In-Combat
		{'%pause', 'keybind(shift)'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, { 'target.interruptAt(55)', 'target.inMelee' }},
		{_Cooldowns, { 'toggle(cooldowns)', "target.range <= 5", "!player.casting(Fists of Fury)" }},
		{_SEF, { "target.range <= 5", (function() return F('SEF') end), "!player.casting(Fists of Fury)" }},
		{_Melee, { "target.range <= 5", "!player.casting(Fists of Fury)" }},
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _OOC, exeOnLoad)


-- 	# Executed every time the actor is available.
-- actions=auto_attack
-- actions+=/potion,name=old_war,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
-- actions+=/call_action_list,name=serenity,if=talent.serenity.enabled&((artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<=14&cooldown.rising_sun_kick.remains<=4)|buff.serenity.up)
-- actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&((artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&cooldown.rising_sun_kick.remains<=6)|buff.storm_earth_and_fire.up)
-- actions+=/call_action_list,name=serenity,if=(!artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<14&cooldown.fists_of_fury.remains<=15&cooldown.rising_sun_kick.remains<7)|buff.serenity.up
-- actions+=/call_action_list,name=sef,if=!talent.serenity.enabled&((!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5)|buff.storm_earth_and_fire.up)
-- actions+=/call_action_list,name=st
--
-- actions.cd=invoke_xuen
-- actions.cd+=/blood_fury
-- actions.cd+=/berserking
-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=!artifact.gale_burst.enabled&equipped.137057&!prev_gcd.touch_of_death
-- actions.cd+=/touch_of_death,if=!artifact.gale_burst.enabled&!equipped.137057
-- actions.cd+=/touch_of_death,cycle_targets=1,max_cycle_targets=2,if=artifact.gale_burst.enabled&equipped.137057&cooldown.strike_of_the_windlord.remains<8&cooldown.fists_of_fury.remains<=4&cooldown.rising_sun_kick.remains<7&!prev_gcd.touch_of_death
-- actions.cd+=/touch_of_death,if=artifact.gale_burst.enabled&!equipped.137057&cooldown.strike_of_the_windlord.remains<8&cooldown.fists_of_fury.remains<=4&cooldown.rising_sun_kick.remains<7
--
-- actions.sef=energizing_elixir
-- actions.sef+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
-- actions.sef+=/call_action_list,name=cd
-- actions.sef+=/storm_earth_and_fire
-- actions.sef+=/call_action_list,name=st
--
-- actions.serenity=energizing_elixir
-- actions.serenity+=/call_action_list,name=cd
-- actions.serenity+=/serenity
-- actions.serenity+=/strike_of_the_windlord
-- actions.serenity+=/rising_sun_kick,cycle_targets=1,if=active_enemies<3
-- actions.serenity+=/fists_of_fury
-- actions.serenity+=/spinning_crane_kick,if=active_enemies>=3&!prev_gcd.spinning_crane_kick
-- actions.serenity+=/rising_sun_kick,cycle_targets=1,if=active_enemies>=3
-- actions.serenity+=/blackout_kick,cycle_targets=1,if=!prev_gcd.blackout_kick
-- actions.serenity+=/spinning_crane_kick,if=!prev_gcd.spinning_crane_kick
-- actions.serenity+=/rushing_jade_wind,if=!prev_gcd.rushing_jade_wind
--
-- actions.st=call_action_list,name=cd
-- actions.st+=/arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
-- actions.st+=/energizing_elixir,if=energy<energy.max&chi<=1
-- actions.st+=/strike_of_the_windlord,if=talent.serenity.enabled|active_enemies<6
-- actions.st+=/fists_of_fury
-- actions.st+=/rising_sun_kick,cycle_targets=1
-- actions.st+=/whirling_dragon_punch
-- actions.st+=/spinning_crane_kick,if=active_enemies>=3&!prev_gcd.spinning_crane_kick
-- actions.st+=/rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.rushing_jade_wind
-- actions.st+=/blackout_kick,cycle_targets=1,if=(chi>1|buff.bok_proc.up)&!prev_gcd.blackout_kick
-- actions.st+=/chi_wave,if=energy.time_to_max>=2.25
-- actions.st+=/chi_burst,if=energy.time_to_max>=2.25
-- actions.st+=/tiger_palm,cycle_targets=1,if=!prev_gcd.tiger_palm
-- actions.st+=/crackling_jade_lightning,interrupt=1,if=talent.rushing_jade_wind.enabled&chi.max-chi=1&prev_gcd.blackout_kick&cooldown.rising_sun_kick.remains>1&cooldown.fists_of_fury.remains>1&cooldown.strike_of_the_windlord.remains>1&cooldown.rushing_jade_wind.remains>1
-- actions.st+=/crackling_jade_lightning,interrupt=1,if=!talent.rushing_jade_wind.enabled&chi.max-chi=1&prev_gcd.blackout_kick&cooldown.rising_sun_kick.remains>1&cooldown.fists_of_fury.remains>1&cooldown.strike_of_the_windlord.remains>1
