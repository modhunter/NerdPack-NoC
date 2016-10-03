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
		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
			{type = 'spinner', text = 'Healthstone', key = 'Healthstone', default = 25},
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
	{ "Infernal Strike", "keybind(lalt)" },
	{ "Sigil of Flame", "keybind(lcontrol)" },
}

local _Cooldowns = {
}

local _Survival = {
	{ "Soul Cleave", "player.pain >= 80" },
	{ "Soul Barrier", "player.health <= 60" },
	{ "Fel Devastation", "player.health <= 70" },
	{ "Metamorphosis", { "!player.buff(Demon Spikes)", "!target.debuff(Fiery Brand)", "!player.buff(Metamorphosis)", "player.health <= 40" }},

	-- Consumables
	{ "#127834", "player.health < 25" }, -- Ancient Healing Potion
	{ "#5512", "player.health < 25" }, -- Warlock conjured Healthstone
}

local _Interrupts = {
	{ "Fel Erruption", { "player.spell(Consume Magic).cooldown > 1", "!lastcast(Consume Magic)" }},
	{ "Arcane Torrent", { "target.range <= 8", "player.spell(Consume Magic).cooldown > 1", "!lastcast(Consume Magic)" }},
	{ "Consume Magic" },
}

local _Ranged = {
	{ "Throw Glaive" },
}

local _Melee = {
	-- Rotation
	{{ -- In front
		{ "Fiery Brand", { "!player.buff(Demon Spikes)", "!player.buff(Metamorphosis)" }},
		{{
			{ "Demon Spikes", "player.spell(Demon Spikes).charges = 2" },
			{ "Demon Spikes", { "!player.buff(Demon Spikes)", "player.health < 85" }}, -- This will prevent DS to be used unnecessarily on CD and possibly save 1 charge for better manual usage
		}, { "!target.debuff(Fiery Brand)", "!player.buff(Metamorphosis)" }},
		{ "Sigil of Flame", "talent(6,1)" },
		{ "Spirit Bomb", { "!target.debuff(Frailty)", "player.buff(Soul Fragments).count >= 1" }}, -- It will only attempt to cast Spirit Bomb if there is at least 1 Soul Fragment around
		{ "Soul Carver", "target.debuff(Fiery Brand)" },
		{ "Immolation Aura", "player.pain <= 80" },
		{ "Felblade", "player.pain <= 70" },
		{ "Soul Barrier" },
		{ "Fracture", { "player.pain >= 60", "player.buff(Soul Fragments).count > 5" }},
		{ "Soul Cleave", "player.buff(Soul Fragments).count >= 5" },
		{ "Soul Cleave", "player.pain >= 80" },
		{ "Shear" },
	}, 'target.infront' },
}

local _AoE = {
}

NeP.Engine.registerRotation(581, '[|cff'..NeP.Interface.addonColor..'NoC|r] Demon Hunter - Vengeance',
	{ -- In-Combat
		{ '%pause', 'keybind(shift)'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Cooldowns, 'toggle(cooldowns)'},
		{_Melee, "target.range <= 5" },
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _All, exeOnLoad)
