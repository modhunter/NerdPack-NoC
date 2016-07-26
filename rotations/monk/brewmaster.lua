local dynEval = NOC.dynEval
local PeFetch = NeP.Interface.fetchKey
local addonColor = '|cff'..NeP.Interface.addonColor

local config = {
	key = 'NePConfigMonkBM',
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Monk Brewmaster Settings',
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		-- Keybinds
		{type = 'header', text = addonColor..'Keybinds:', align = 'center'},
			-- Control
			{type = 'text', text = addonColor..'Control: ', align = 'left', size = 11, offset = -11},
			{type = 'text', text = 'Summon Black Ox Statue', align = 'right', size = 11, offset = 0 },
			-- Shift
			{type = 'text', text = addonColor..'Shift:', align = 'left', size = 11, offset = -11},
			{type = 'text', text = 'Placeholder', align = 'right', size = 11, offset = 0 },
			-- Alt
			{type = 'text', text = addonColor..'Alt:',align = 'left', size = 11, offset = -11},
			{type = 'text', text = 'Pause Rotation', align = 'right', size = 11, offset = 0 },

		-- General
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = addonColor..'General', align = 'center' },
			{ type = "checkbox", text = "Automated Taunts", key = "canTaunt", default = false },

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = addonColor..'Survival', align = 'center'},
			{type = 'spinner', text = 'Healthstone', key = 'Healthstone', default = 45},
			{type = 'spinner', text = 'Expel Harm', key = 'ExpelHarm', default = 50},
			{type = 'spinner', text = 'Chi Wave', key = 'ChiWave', default = 70},
			{type = 'spinner', text = 'Fortifying Brew', key = 'FortifyingBrew', default = 36},
			{type = 'spinner', text = 'Ironskin Brew', key = 'IronskinBrew', default = 90},
			{type = 'spinner', text = 'Purifying Brew', key = 'PurifyingBrew', default = 60},


	}
}

NeP.Interface.buildGUI(config)

local exeOnLoad = function()
	NOC.Splash()
	NeP.Interface.CreateSetting('Class Settings', function() NeP.Interface.ShowGUI('NePConfigMonkBM') end)
end

local All = {
-- Keybinds
	-- Pause
	{'pause', 'modifier.alt'},
	-- Summon Black Ox Statue
	{'115315', 'modifier.control', 'mouseover.ground'},

}

local FREEDOOM = {
	-- Nimble Brew if pvp talent taken
	{'137648', 'player.state.disorient'},
	{'137648', 'player.state.stun'},
	{'137648', 'player.state.fear'},
	{'137648', 'player.state.horror'},

	-- Tiger's Lust if cd taken
	{'116841', 'player.state.root'},
	{'116841', 'player.state.snare'},
}

local Cooldowns = {

}

local Survival = {
	-- Expel Harm
	{'115072', (function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'ExpelHarm')) end)},
		-- Chi Wave
	{'115098', (function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'ChiWave')) end)},
	--Healthstone
	{'#5512', (function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'Healthstone')) end)},
	-- Fortifying Brew
	{'115203', (function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'FortifyingBrew')) end)},
	-- Ironskin Brew
	{'115308', {'player.buff(215479).duration <= 1', 'player.debuff(124275)',(function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'IronskinBrew')) end)}},
	-- Purifying Brew
	{'119582', {'player.debuff(124274)',(function() return dynEval('player.health <= '..PeFetch('NePConfigMonkBM', 'PurifyingBrew')) end)}},



}

local Interrupts = {
	-- Spear Hand Strike
	{'116705'},
}

local Ranged = {
	-- Crackling Jade Lightning
	{'117952'},
}

local Taunts = {
	-- Provoke
	{'115546', 'target.range <= 35'},
}

local Melle = {
	--[[Use Blackout Strike first due to blackout combo talent this is priority over keg smash]]
	{'205523'},

	--[[Use Keg Smash on cooldown ]]
	{'121253'},

	--[[Use Tiger Palm to fill any spare global cooldowns.
	This should only be used each time the monk is above 65 energy and keg smash is currently on cd.]]
	{'100780', 'player.energy >= 65'},

	--[[Use Breath of Fire on cooldown ]]
	{'115181'},

	-- Use Rushing Jade Wind, if you have taken this talent.
	{'116847'},

}

local AoE = {
	--[[Use Blackout Strike first due to blackout combo talent this is priority over keg smash]]
	{'205523'},

	-- Cast Keg Smash on cd.
	{'121253'},

	-- Use Rushing Jade Wind, if you have taken this talent.
	{'116847'},


	--[[If you have taken Chi burst]]
	{'123986'},

	--[[Breath of Fire ]]
	{'115181'},

	--[[Use Tiger Palm to fill any spare global cooldowns.
	This should only be used each time the monk is above 65 energy and keg smash is currently on cd.]]
	{'100780', 'player.energy >= 65'},

}

NeP.Engine.registerRotation(268, '[|cff'..NeP.Interface.addonColor..'NeP|r] Monk - Brewmaster',
	{-- In-Combat
		{All},
		{Survival, 'player.health < 100'},
		{Interrupts, 'target.interruptAt(80)'},
		{FREEDOOM},
		{Cooldowns, 'modifier.cooldowns'},


		{{-- Conditions
			{AoE, {
				'player.area(8).enemies >= 3',
				(function() return PeFetch('NePConfigMonkBM', 'canTaunt') end)
			}},
			{Melle, {'target.inMelee', 'target.infront'}},
			--{Ranged, '!target.inMelee'}
		}, {'target.range <= 40', 'target.exists'}}
	}, All, exeOnLoad)
