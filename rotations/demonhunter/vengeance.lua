local mKey = 'NoC_DH_Vengeance'
local config = {
	key = mKey,
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Demon Hunter Vengeance Settings',
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		-- General
		{type = 'header',text = 'General', align = 'center'},
			{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
			{type = 'spinner', text = 'Healthstone', key = 'Healthstone', default = 75},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local _All = {
	-- Keybinds
  { "Infernal Strike", "modifier.lalt" },
  { "Sigil of Flame", "modifier.lcontrol" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.combattime >= 300", (function() return F('dpstest') end) }},
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

NeP.Engine.registerRotation(581, '[|cff'..NeP.Interface.addonColor..'NoC|r] Demon Hunter - Vengeance',
	{ -- In-Combat
		{ '%pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Cooldowns, 'modifier.cooldowns'},
		{_Melee, "target.range <= 5" },
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _All, exeOnLoad)
