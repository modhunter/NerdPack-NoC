-- Syncronized with simc APL as of simc commit f5fa6c7e95dc496ec391112ccfc4821bf228897c (from a32b6ff633e8ab4f1b9d3cd2c7deb079a318cf52)

local config = {
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
	{type = 'spinner', text = 'Healing Elixir', key = 'Healing Elixir', default = 50},

	-- Offensive
	{type = 'spacer'},{type = 'rule'},
	{type = 'header', text = 'Offensive', align = 'center'},
	{type = 'checkbox', text = 'SEF usage', key = 'sef_toggle', default = true},
	{type = 'checkbox', text = 'Automatic CJL at range', key = 'auto_cjl', default = false},
	{type = 'checkbox', text = 'Automatic Chi Wave at pull', key = 'auto_cw', default = true},
	{type = 'checkbox', text = 'Automatic Mark of the Crane Dotting', key = 'auto_dot', default = true},
	{type = 'checkbox', text = 'Automatic CJL in melee to maintain Hit Combo', key = 'auto_cjl_hc', default = false},
}

local exeOnLoad = function()
end

local SEF_Fixate_Casted = false
local sef = function()
	if NeP.DSL:Get('buff')('player', 'Storm, Earth, and Fire') then
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


local OutOfCombat = {
	{ "Effuse", { "player.health <= 50", "player.lastmoved >= 1" }, "player" },

	-- Automatic res of dead party members
	{ "%ressdead(Resuscitate)", 'UI(auto_res)' },

	-- TODO: Add support for (optional) automatic potion use w/pull timer
}

local _All = {
	-- keybind
	{ "Leg Sweep", "keybind(lcontrol)" },
  { "Touch of Karma", "keybind(lalt)" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget\n/nep mt", { "player.combat.time >= 300", 'UI(dpstest)' }},

	-- Cancel CJL when we're in melee range
	{ "!/stopcasting", { "target.inMelee", "player.casting(Crackling Jade Lightning)" }},

	-- FREEDOOM!
	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841
}

local _Cooldowns = {
	{{
		-- TODO: add logic to handle ToD interaction with legendary item 137057
		{ "Touch of Death", "!player.spell.usable(Gale Burst)" },
		{ "Touch of Death", { "player.spell.usable(Gale Burst)", "player.spell(Strike of the Windlord).cooldown < 8", "player.spell(Fists of Fury).cooldown <= 4", "player.spell(Rising Sun Kick).cooldown < 7" }},
	}, "target.inMelee" },

	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
	{ "#trinket1", { "player.buff(Serenity)", "or", "player.buff(Storm, Earth, and Fire)" }},
	{ "#trinket2", { "player.buff(Serenity)", "or", "player.buff(Storm, Earth, and Fire)" }},
	-- Use Xuen only while hero or potion (WOD: 156423, Legion: 188027) is active
	{ "Invoke Xuen, the White Tiger", { "player.hashero", "or", "player.buff(156423)", "or", "player.buff(188027)" }},
}

local _Survival = {
	{ "Healing Elixir", { 'player.health <= UI(Healing Elixir)' }, "player" },

	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ '#5512', 'player.health <= UI(Healthstone)', "player" }, -- Healthstone
	{ "#109223", 'player.health <= UI(Healthstone)', "player" }, -- Healing Tonic
	{ "Effuse", { "player.energy >= 60", "player.lastmoved >= 0.5", 'player.health <= UI(effuse)' }, "player" },
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
     "target.inMelee",
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
		{ "Energizing Elixir" },
		{ _Cooldowns, 'toggle(cooldowns)' },
		{ "Storm, Earth, and Fire", { '!toggle(AoE)', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "player.spell(Strike of the Windlord).exists", "player.spell(Strike of the Windlord).cooldown <= 14", "player.spell(Fists of Fury).cooldown <= 6", "player.spell(Rising Sun Kick).cooldown <= 6"  }},
	{{
		{ "Energizing Elixir" },
		{ _Cooldowns, 'toggle(cooldowns)' },
		{ "Storm, Earth, and Fire", { '!toggle(AoE)', sef }},
		{ "Storm, Earth, and Fire", "!player.buff(Storm, Earth, and Fire)" },
	}, { "!player.spell(Strike of the Windlord).exists", "player.spell(Fists of Fury).cooldown <= 9", "player.spell(Rising Sun Kick).cooldown <= 5"  }},
}

local _Ranged = {
	{ "116841", { "player.movingfor > 0.5", "target.alive" }}, -- Tiger's Lust
	{ "Crackling Jade Lightning", { 'UI(auto_cjl)', "!player.moving", "player.combat.time > 4", "!lastgcd(Crackling Jade Lightning)", "@NOC.hitcombo(Crackling Jade Lightning)" }},
	{ "Chi Wave", { 'UI(auto_cw)', "target.inRanged" }},
}

local _Serenity = {
	{ "Energizing Elixir" },
	{ _Cooldowns, { 'toggle(cooldowns)', "target.inMelee" }},
	{ "Serenity" },
	{ "Strike of the Windlord" },
	{{
		{ 'Rising Sun Kick', "UI(auto_dot)", 'NOC_sck(Mark of the Crane)'},
		{ "Rising Sun Kick" },
	}, { 'player.area(5).enemies < 3' }},
	{ "Fists of Fury" },
	{ 'Spinning Crane Kick', { 'player.area(8).enemies >= 3', 'toggle(AoE)', '!lastgcd(Spinning Crane Kick)', "@NOC.hitcombo(Spinning Crane Kick)" }},
	{{
		{ 'Rising Sun Kick', "UI(auto_dot)", 'NOC_sck(Mark of the Crane)'},
		{ "Rising Sun Kick" },
	}, { 'player.area(5).enemies >= 3' }},
	{{
		{ 'Blackout Kick', "UI(auto_dot)", 'NOC_sck(Mark of the Crane)'},
		{ "Blackout Kick" },
	}, { "!lastgcd(Blackout Kick)", "@NOC.hitcombo(Blackout Kick)" }},
	{ "Rushing Jade Wind", { "!lastgcd(Rushing Jade Wind)", "@NOC.hitcombo(Rushing Jade Wind)" }},
}

local _Melee = {
	{ _Cooldowns, { 'toggle(cooldowns)', "target.inMelee" }},
	{ "Energizing Elixir", { "player.energydiff > 0", "player.chi <= 1", "target.inMelee" }},
	{ "Strike of the Windlord", { "talent(7,3)", "or", "player.area(9).enemies < 6" }},
	{ "Fists of Fury", "target.inMelee" },
	{{
		{ 'Rising Sun Kick', "UI(auto_dot)", 'NOC_sck(Mark of the Crane)'},
		{ "Rising Sun Kick" },
	}, { "target.inMelee" }},
	{ 'Spinning Crane Kick', { '!lastgcd(Spinning Crane Kick)', "@NOC.hitcombo(Spinning Crane Kick)", { "player.spell(Spinning Crane Kick).count >= 17" }}},
	{ "Whirling Dragon Punch" },
	{ 'Spinning Crane Kick', { '!lastgcd(Spinning Crane Kick)', "@NOC.hitcombo(Spinning Crane Kick)", { "player.spell(Spinning Crane Kick).count >= 12" }}},
	{ 'Spinning Crane Kick', { 'player.area(8).enemies >= 3', 'toggle(AoE)', '!lastgcd(Spinning Crane Kick)', "@NOC.hitcombo(Spinning Crane Kick)" }},
	{ "Rushing Jade Wind", { "player.chidiff > 1", "!lastgcd(Rushing Jade Wind)", "@NOC.hitcombo(Rushing Jade Wind)" }},
	{{
		{'Blackout Kick', { "UI(auto_dot)", "player.buff(Blackout Kick!)", }, 'NOC_sck(Mark of the Crane)'},
  	{ "Blackout Kick", "player.buff(Blackout Kick!)" },
		{'Blackout Kick', { "UI(auto_dot)", "player.chi > 1", }, 'NOC_sck(Mark of the Crane)'},
  	{ "Blackout Kick", "player.chi > 1" },
	}, { "!lastgcd(Blackout Kick)", "@NOC.hitcombo(Blackout Kick)", "target.inMelee" }},
	{{
		{ "Chi Wave" }, -- 40 yard range 0 energy, 0 chi
		{ "Chi Burst", "!player.moving" },
	}, { "player.timetomax >= 2.25" }},
	{{
		{'Tiger Palm', "UI(auto_dot)", 'NOC_sck(Mark of the Crane)'},
		{ "Tiger Palm" },
	}, { "player.energy > 50", "!lastgcd(Tiger Palm)", "@NOC.hitcombo(Tiger Palm)", "target.inMelee" }},

	{{
		{ "Crackling Jade Lightning", "talent(6,1)" },
		{ "Crackling Jade Lightning", "!talent(6,1)" },
	}, { "player.chidiff = 1", "player.spell(Rising Sun Kick).cooldown > 1", "player.spell(Fists of Fury).cooldown > 1", "player.spell(Strike of the Windlord).cooldown > 1", "!lastgcd(Crackling Jade Lightning)", "@NOC.hitcombo(Crackling Jade Lightning)" }},

	-- CJL when we're using Hit Combo as a last resort filler, and it's toggled on
	-- TODO: remove this in 7.1 or add a big energy buffer to the check since it is no longer free to cast
	{ "Crackling Jade Lightning", { "UI(auto_cjl_hc)", "!lastgcd(Crackling Jade Lightning)", "@NOC.hitcombo(Crackling Jade Lightning)" }},

	-- Last resort BoK when we only have 1 chi and no hit combo
	{ "Blackout Kick", "player.chi = 1 & !player.buff(Hit Combo) & target.inMelee" },
	-- Last resort TP when we don't have hit combo up
	{ "Tiger Palm", "!player.buff(Hit Combo) & target.inMelee" },
	-- Last resrt TP when at 100 energy - doing this because it's sometimes
	-- getting parried/missed and we're stuck thinking it was latcast and
	-- don't do anything, so as a fallthrough we'll cast when at 100 energy
	-- no mamtter what. May replace with CJL when @ 100 energy instead
	{ "Tiger Palm", "player.energy >= 100 & target.inMelee" },
}

local InCombat = {
	{ '%pause', 'keybind(shift)'},
	{ _All},
	{ _Survival, 'player.health < 100'},
	{ _Interrupts, { 'target.interruptAt(55)', 'target.inMelee' }},
	{ _Serenity, { "target.inMelee", "talent(7,3)", "!player.casting(Fists of Fury)", {{ "player.spell(Strike of the Windlord).exists", "player.spell(Strike of the Windlord).cooldown <= 14", "player.spell(Rising Sun Kick).cooldown <= 4" }, "or", "player.buff(Serenity)" }}},
	{ _Serenity, { "target.inMelee", "talent(7,3)", "!player.casting(Fists of Fury)", {{ "!player.spell(Strike of the Windlord).exists", "player.spell(Fists of Fury).cooldown <= 15", "player.spell(Rising Sun Kick).cooldown < 7" }, "or", "player.buff(Serenity)" }}},
	{ _SEF, { "target.inMelee", 'UI(sef_toggle)', "!talent(7,3)", "!player.casting(Fists of Fury)" }},
	{ _Melee, { "target.range <= 9", "!player.casting(Fists of Fury)" }},
	{ _Ranged, { "!target.inMelee", "target.inRanged" }},
}

NeP.CR:Add(269, '[NoC] Monk - Windwalker', InCombat, OutOfCombat, exeOnLoad, config)
