local config = {
	-- General
	{type = 'header',text = 'General', align = 'center'},
	{type = 'checkbox', text = 'Automatic Throw Glaive', key = 'auto_glaive', default = true},
	{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

	-- Survival
	{type = 'spacer'},{type = 'rule'},
	{type = 'header', text = 'Survival', align = 'center'},
	{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 45},
	{type = 'spinner', text = 'Blur', key = 'blur', default = 70},
	{type = 'spinner', text = 'Desperate Instincts', key = 'desperate', default = 40},
	{type = 'spinner', text = 'Netherwalk', key = 'netherwalk', default = 70},
}

local exeOnLoad = function()

end

local _All = {
	-- keybind
	--{ 'pause', 'keybind(shift)' },
	{ "Chaos Nova", "keybind(lcontrol)" },
	--{ "Darkness", "keybind(lalt)" }, -- reserve alt for Metamorphosis instead

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.combat.time >= 300", (function() return F('dpstest') end) }},

	-- Vengeful Retreat backwards through the target to minimize downtime.
	--vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
	-- Fel Rush for Momentum and for fury from Fel Mastery.
	--fel_rush,animation_cancel=1,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&raid_event.movement.in>charges*10

}

local _Cooldowns = {
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },

	{ "Metamorphosis", 'keybind(lalt)&{!player.buff(Metamorphosis)&!talent(7,3)||player.spell(Eye Beam).cooldown < 0.5&!talent(7,1)||player.spell(Chaos Blades).cooldown < 0.5&!talent(5,3)||target.debuff(Nemesis)||player.spell(Nemesis).cooldown < 0.5}', "mouseover.ground" },

	-- Just cast it #YOLO
	--{ "Metamorphosis", { "keybind(lalt)" }, "mouseover.ground" },
}

local _Survival = {
	{ "Blur", 'player.health <= UI(blur)'},
	{ "Desperate Instincts", 'player.health <= UI(desperate)'},
	{ "Netherwalk",	'player.health <= UI(netherwalk)' },

	{ "#109223", 'player.health <= UI(Healthstone)', "player" }, -- Healing Tonic
	{ '#5512', 'player.health <= UI(Healthstone)', "player" }, -- Healthstone
}

local _Interrupts = {
	{ "Consume Magic" },
}

local _AoE = {
}

local _Ranged = {
	-- Throw Glaive range: 30
	-- Fel Barrage range: 30
	-- Eye Beam range: 20
	-- Felblade: 15
	-- Fel Erruption: 20

	-- Auto-cast Throw Glaive when outside of range
	{ "Throw Glaive", 'UI(auto_glaive)&target.range <= 30' },
}

local _Melee = {
	-- Rotation
	{ "Fury of the Illidari" }, -- Fury of the Illidari

	-- TODO: figure out how to handle the wierd 'worth using' crap from the simc APL
	-- TODO: implement true gcd checking instead of assuming 1.5s everywhere
	{ "Death Sweep" },
	{ "Demon's Bite", "player.buff(Metamorphosis).duration > 1.5&player.spell(Blade Dance).cooldown < 1.5&player.fury < 70" },

	{ "Blade Dance" },

	{ "Fel Barrage", "player.buff(Momentum)&player.spell(Fel Barrage).charges >= 5"  },
	{ "Fel Barrage", "!talent(5,1)&player.spell(Fel Barrage).charges >= 5" },
	{ "Throw Glaive", "{!talent(6,1)||!talent(5,1)||player.buff(Momentum)}&talent(3,3)&toggle(multitarget)&layer.area(10).enemies >= 2" },
	{ "Fel Erruption" },

	{ "Felblade", "player.furydiff >= 30&!player.buff(Prepared)"},
	{ "Felblade", "player.furydiff >= 42&player.buff(Prepared)"},

	{ "Annihilation", "!talent(5,1)" },
	{ "Annihilation", "player.buff(Momentum)" },
	{ "Annihilation", "player.furydiff >= 30&!player.buff(Prepared)"},
	{ "Annihilation", "player.furydiff >= 42&player.buff(Prepared)" },
	{ "Annihilation", "player.buff(Metamorphosis).duration < 2" },
	{ "Throw Glaive", "{!talent(6,1)||!talent(5,1)||player.buff(Momentum)}&talent(3,3)" },

	{ "Eye Beam", "!talent(7,3){toggle(multitarget)&player.area(15).enemies >= 2||!player.buff(Metamorphosis)}&{toggle(multitarget)&player.area(15).enemies >= 2||player.level = 100}"},
	--{ "Eye Beam", { "!talent(7,3)", "toggle(multitarget)", "player.area(15).enemies >= 2", }},
	--{ "Eye Beam", { "!talent(7,3)", "!player.buff(Metamorphosis)", "player.level = 100" }},

	{{
		{ "Demon's Bite", "player.spell(Blade Dance).cooldown < 1.5&player.fury < 55" },
		{ "Demon's Bite", "talent(7,3)&player.spell(Eye Beam).cooldown < 1.5&player.furydiff >= 20" },
		{ "Demon's Bite", "talent(7,3)&player.spell(Eye Beam).cooldown < 3&player.furydiff >= 45" },
	}, "!player.buff(Metamorphosis)" },

	{ "Throw Glaive", "!player.buff(Metamorphosis)&toggle(multitarget)&player.area(10).enemies >= 3" },

	{ "Chaos Strike", "!talent(5,1)" },
	{ "Chaos Strike", "player.buff(Momentum)" },
	{ "Chaos Strike", "player.furydiff >= 30&!player.buff(Prepared)" },
	{ "Chaos Strike", "player.furydiff >= 42&player.buff(Prepared)" },
	{ "Fel Barrage", "{player.buff(Momentum)||!talent(5,1)}&player.spell(Fel Barrage).charges >= 4&!player.buff(Metamorphosis)" },

	{ "Throw Glaive" },

	{ "Demon's Bite" },
}

local _Rotation = {
	{ "Eye Beam", "{!talent(3,2)||player.fury >= 80||player.furydiff < 30}&talent(7,3)&!player.buff(Metamorphosis)&target.range <= 20" },

	-- If Metamorphosis is ready, pool fury
	{ "Demon's Bite", { "player.spell(Metamorphosis).cooldown < 0.5", "player.furydiff >= 25", "target.range <= 5" }},

	{ "Nemesis", { "player.area(8).enemies >= 3", "!target.debuff(Nemesis)", "target.range <= 5" }},
	{ "Nemesis", { "player.area(8).enemies = 1", "player.spell(Metamorphosis).cooldown > 100", "target.range <= 5" }},
	{ "Nemesis", { "player.area(8).enemies = 1", "target.ttd < 70", "target.range <= 5" }},
	{ "Nemesis", { "player.spell(Metamorphosis).cooldown < 0.5", "target.range <= 5", "player.area(8).enemies = 1" }},

	{ "Chaos Blades", "player.spell(Metamorphosis).cooldown > 100||player.buff(Metamorphosis)||target.ttd < 20" },

	{_Cooldowns, 'toggle(cooldowns)'},
}

local InCombat = {
	{ '%pause', 'keybind(shift)'},
	{_All},
	{_Survival, 'player.health < 100'},
	{_Interrupts, 'target.interruptAt(40)'},
	{_Rotation},
	{_Melee, "target.range <= 5" },
	{_Ranged, { "target.range > 8", "target.range <= 40" }},
}

NeP.CR:Add(577, '[NoC] Demon Hunter - Havoc', InCombat, _All, exeOnLoad, config)