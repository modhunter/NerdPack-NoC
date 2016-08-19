local addonColor = '|cff'..NeP.Interface.addonColor

local mKey = 'NoC_Monk_BrM'
local config = {
	key = mKey,
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
			--{type = 'text', text = 'Summon Black Ox Statue', align = 'right', size = 11, offset = 0 },
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
			{type = 'spinner', text = 'Healthstone or Healing Potion', key = 'Health Stone', default = 45},
			{type = 'spinner', text = 'Healing Elixir', key = 'Healing Elixir', default = 70},
			{type = 'spinner', text = 'Expel Harm', key = 'Expel Harm', default = 100},
			{type = 'spinner', text = 'Fortifying Brew', key = 'Fortifying Brew', default = 20},
			{type = 'spinner', text = 'Ironskin Brew', key = 'Ironskin Brew', default = 80},

			--{type = 'spinner', text = 'Chi Wave', key = 'ChiWave', default = 70},
			--{type = 'spinner', text = 'Ironskin Brew', key = 'IronskinBrew', default = 80},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local HealthStone = function()
	return E('player.health <= ' .. F('Health Stone'))
end

local HealingElixir = function()
	return E('player.health <= ' .. F('Healing Elixir'))
end

local FortifyingBrew = function()
	return E('player.health <= ' .. F('Fortifying Brew'))
end

local ExpelHarm = function()
	return E('player.health <= ' .. F('Expel Harm'))
end

local IronskinBrew = function()
	return E('player.health <= ' .. F('Ironskin Brew'))
end

local staggered = function()
	-- if Player:DebuffAny(HeavyStagger) then
	-- 	return math.floor(Player:DebuffValue(HeavyStagger)*2/Player:MaxHealth()*10000)/100;
	-- elseif Player:DebuffAny(ModerateStagger) then
	-- 	return math.floor(Player:DebuffValue(ModerateStagger)*2/Player:MaxHealth()*10000)/100;
	-- elseif Player:DebuffAny(LightStagger) then
	-- 	return math.floor(Player:DebuffValue(LightStagger)*2/Player:MaxHealth()*10000)/100;
	-- else
	-- 	return 0;
	-- end
	-- Use this instead?
	--UnitStagger("player")/UnitHealthMax("player")
	local staggerLight, _, iconLight, _, _, remainingLight, _, _, _, _, _, _, _, _, valueStaggerLight, _, _ = UnitAura("player", GetSpellInfo(124275), "", "HARMFUL")
	local staggerModerate, _, iconModerate, _, _, remainingModerate, _, _, _, _, _, _, _, _, valueStaggerModerate, _, _ = UnitAura("player", GetSpellInfo(124274), "", "HARMFUL")
	local staggerHeavy, _, iconHeavy, _, _, remainingHeavy, _, _, _, _, _, _, _, _, valueStaggerHeavy, _, _ = UnitAura("player", GetSpellInfo(124273), "", "HARMFUL")
	local staggerTotal= (remainingLight or remainingModerate or remainingHeavy or 0) * (valueStaggerLight or valueStaggerModerate or valueStaggerHeavy or 0)
	local percentOfHealth=(100/UnitHealthMax("player")*staggerTotal)
	return percentOfHealth;
end

local PurifyingCapped = function()
	local MaxBrewCharges = 3;
	if E('talent(3,1)') then
		MaxBrewCharges = MaxBrewCharges + 1;
	end
	local PurifyingCapped = E("player.spell(Purifying Brew).charges") ==  MaxBrewCharges or (E("player.spell(Purifying Brew).charges") == MaxBrewCharges - 1 and E("player.spell(Purifying Brew).recharge < 3")) or false;
	return PurifyingCapped
end



local _All = {
	-- Keybinds

	-- Nimble Brew if pvp talent taken
	{'137648', 'player.state.disorient'},
	{'137648', 'player.state.stun'},
	{'137648', 'player.state.fear'},
	{'137648', 'player.state.horror'},

	{ "116841", 'player.state.disorient' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.stun' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.root' }, -- Tiger's Lust = 116841
	{ "116841", 'player.state.snare' }, -- Tiger's Lust = 116841
}

local _OOC = {
}

local _Cooldowns = {
}

local _Mitigation = {
	{ "Black Ox Brew", { "player.spell(Purifying Brew).charges < 1", "player.spell(purifying brew).recharge > 2" }},

	-- Active Mitigation
	{ "Purifying Brew", { staggered, "player.spell(Purifying Brew).charges >= 1" }},

	-- Ironskin if we have Light / No Stagger
	{ "Ironskin Brew", { IronskinBrew, "player.spell(Purifying Brew).charges >= 2", "!player.buff(Ironskin Brew)" }},

	-- Prevent Capping
	{ "Ironskin Brew", { PurifyingCapped, "player.health < 100", "!player.buff(Ironskin Brew)" }},

	-- Ironskin Brew
	--{'115308', {'player.buff(215479).duration <= 1', 'player.debuff(124275)',(function() return E('player.health <= '..PeFetch('NoC_Monk_BrM', 'IronskinBrew')) end)}},
	-- Purifying Brew
	--{'119582', {'player.debuff(124274)',(function() return E('player.health <= '..PeFetch('NoC_Monk_BrM', 'PurifyingBrew')) end)}},
}

local _Survival = {
	{ "Healing Elixir", { "player.spell(Healing Elixir).charges >= 1", "player.spell(Healing Elixir).cooldown < 3", "!lastcast(Healing Elixir)", HealingElixir }, "player" },

	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ "#109223", HealthStone, "player" }, -- Healing Tonic
	{ '#5512', HealthStone, "player" }, -- Healthstone

	{'Fortifying Brew', { FortifyingBrew }, "player" },

	-- Cast when there is at least one orb on the ground
	{'Expel Harm', { ExpelHarm, "player.spell(Expel Harm).count >= 1" }, "player" },

	-- Chi Wave
	--{'115098', (function() return E('player.health <= '..PeFetch('NoC_Monk_BrM', 'ChiWave')) end)},
	-- Ironskin Brew
	--{'115308', {'player.buff(215479).duration <= 1', 'player.debuff(124275)',(function() return E('player.health <= '..PeFetch('NoC_Monk_BrM', 'IronskinBrew')) end)}},
	-- Purifying Brew
	--{'119582', {'player.debuff(124274)',(function() return E('player.health <= '..PeFetch('NoC_Monk_BrM', 'PurifyingBrew')) end)}},
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

local _Ranged = {
	-- Crackling Jade Lightning
	{'117952'},
}

local _Taunts = {
	-- TODO: Provoke (on a toggle) any valid unit within 30 yards ("player.area(30).enemies") that we're not already tanking ("player.threat < 100"), that a pet is not tanking (???), and that maintank ("tank.threat < 100") or offtank ((tank2.threat < 100)) aren't already tanking too
	--{'Provoke', 'target.range <= 35'},
}

local _Melee = {
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

local _AoE = {
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

NeP.Engine.registerRotation(268, '[|cff'..NeP.Interface.addonColor..'NoC|r] Monk - Brewmaster',
	{-- In-Combat
		{'pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(55)'},
		{_Mitigation, { 'target.inMelee', { "!talent(7,2)", "or", "!player.buff(Blackout Combo)", "or", "player.spell(Keg Smash).cooldown >= 2.5" }}},
		{_Cooldowns, 'modifier.cooldowns'},
		{_AoE, {
			'player.area(8).enemies >= 3', (function() return F('canTaunt') end)
		}},
		{_Melee, {'target.inMelee', 'target.infront'}},
		{_Ranged, { "target.range > 8", "target.range <= 40", "target.infront" }},
	}, _OOC, exeOnLoad)
