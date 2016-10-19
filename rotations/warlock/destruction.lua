local config = {
		-- General
			{type = 'header',text = 'General', align = 'center'},
			{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 35},
}

local exeOnLoad = function()
end

local _Pets = {

}

local _OOC = {
	{_Pets},
}

local _All = {
	-- Keybinds

	-- TODO: turn off engine
	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", 'UI(dpstest)'}},
}

local _Cooldowns = {
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },
}

local _Survival = {
	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ "#109223", 'player.health <= UI(Healthstone)', "player" }, -- Healing Tonic
	{ '#5512', 'player.health <= UI(Healthstone)', "player" }, -- Healthstone
}

local _Interrupts = {
}

local _Ranged = {
}

local _AoE = {
}

local _ST = {
}

local _Melee = {
}

NeP.CR:Add(267, '[NoC] Warlock - Destruction',
	{ -- In-Combat
		{'pause', 'keybinds(shift)'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, {'target.interruptAt(40)', "target.infront" }},
		{_Cooldowns, 'toggle(cooldowns)'},
		{_Melee, { "target.range <= 5" }},
		{_Ranged, { "target.range > 8", "target.range <= 40", "target.infront" }},
	}, _OOC, exeOnLoad)
