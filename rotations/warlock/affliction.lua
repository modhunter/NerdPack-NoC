local mKey = 'NoC_Warlock_Aff'
local config = {
	key = mKey,
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Warlock Affliction Settings',
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
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 35},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end


local _OOC = {
}

local _All = {
	-- Keybinds


	-- TODO: turn off engine
	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return F('dpstest') end) }},

}

local _Cooldowns = {
	{ "Lifeblood" },
	{ "Berserking" },
	{ "Blood Fury" },

}

local _Survival = {
	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ "#109223", healthstn, "player" }, -- Healing Tonic
	{ '#5512', healthstn, "player" }, -- Healthstone
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

NeP.Engine.registerRotation(265, '[|cff'..NeP.Interface.addonColor..'NoC|r] Warlock - Affliction',
	{ -- In-Combat
		{'pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, {'target.interruptAt(40)', "target.infront" }},
		{_Cooldowns, 'modifier.cooldowns'},
		{_Melee, { "target.range <= 5" }},
		{_Ranged, { "target.range > 8", "target.range <= 40", "target.infront" }},
	}, _OOC, exeOnLoad)
