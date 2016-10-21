local config = {
	-- General
	{type = 'header',text = 'General', align = 'center'},
	{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

	-- Survival
	{type = 'spacer'},{type = 'rule'},
	{type = 'header', text = 'Survival', align = 'center'},
	{type = 'spinner', text = 'Healthstone', key = 'Healthstone', default = 75},
}

local exeOnLoad = function()

end

local _All = {
	-- keybind
  { "Infernal Strike", "keybind(lalt)", 'mouseover.ground' },
  { "Sigil of Flame", "keybind(lcontrol)", 'mouseover.ground' },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", 'player.combat.time>=300&UI(dpstest)'},
}

local _Cooldowns = {
  { "Lifeblood" },
  { "Berserking" },
  { "Blood Fury" },
}

local _Survival = {
	{ "Fracture", { "player.pain >= 80", "player.buff(Soul Fragments).count >= 5", "player.pain >= 80" }},
	{ "Soul Cleave", "player.pain >= 80" },
	{ "Fel Devastation", "player.health <= 75" },
	{ "Metamorphosis", { "!player.buff(Demon Spikes)", "!target.debuff(Fiery Brand)", "!player.buff(Metamorphosis)", "player.health <= 70" }},

  { "#109223", "player.health < 40" }, -- Healing Tonic
  { "#5512", "player.health < 40" }, -- Healthstone
}

local _Interrupts = {
	{ "Consume Magic" },
}

local _Ranged = {
	{ "Throw Glaive" },
}

local _Melee = {
	-- Rotation
	{{ -- infront
		{ "Fiery Brand", { "!player.buff(Demon Spikes)", "!player.buff(Metamorphosis)" }},

		{{
			{ "Demon Spikes", "player.spell(Demon Spikes).charges >= 2" },
			{ "Demon Spikes", "!player.buff(Demon Spikes)" },
		}, { "!target.debuff(Fiery Brand)", "!player.buff(Metamorphosis)" }},

		{ "Empower Wards", "target.casting.time < 2" },

		{ "Spirit Bomb", "!target.debuff(Frailty)" },

		{ "Soul Carver", "target.debuff(Fiery Brand)" },

		{ "Immolation Aura", "player.pain <= 80" },

		{ "Felblade", "player.pain <= 70" },

		{ "Soul Barrier" },

		{ "Soul Cleave", "player.buff(Soul Fragments).count >= 5" }, -- <-- Don't use this automatically

		{ "Fel Erruption" },

		{ "Soul Cleave", "player.pain >= 80" },

		{ "Shear" },
	}, 'target.infront' },
}

local _AoE = {
}

local InCombat = {
	{ '%pause', 'keybind(shift)'},
	{_All},
	{_Survival, 'player.health < 100'},
	{_Interrupts, 'target.interruptAt(40)'},
	{_Cooldowns, 'toggle(cooldowns)'},
	{_Melee, "target.range <= 5" },
	{_Ranged, { "target.range > 8", "target.range <= 40" }},
}

NeP.CR:Add(581, '[NoC] Demon Hunter - Vengeance', InCombat, _All, exeOnLoad, config)
