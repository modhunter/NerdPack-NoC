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
			{type = 'spinner', text = 'Healthstone or Healing Potion', key = 'healthstn', default = 45},
			{type = 'spinner', text = 'Healing Elixir', key = 'elixir', default = 70},
			{type = 'spinner', text = 'Expel Harm', key = 'expelharm', default = 100},
			{type = 'spinner', text = 'Fortifying Brew', key = 'fortbrew', default = 20},

			--{type = 'spinner', text = 'Chi Wave', key = 'ChiWave', default = 70},
			--{type = 'spinner', text = 'Ironskin Brew', key = 'IronskinBrew', default = 90},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local healthstn = function()
	return E('player.health <= ' .. F('healthstn'))
end

local elixir = function()
	return E('player.health <= ' .. F('elixir'))
end

local fortbrew = function()
	return E('player.health <= ' .. F('fortbrew'))
end

local expelharm = function()
	return E('player.health <= ' .. F('expelharm'))
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
	-- TODO: Implement this below

	-- if Target:Exists() and TigerPalm:Cooldown() < RandomOffGCD and Player:IsWithinCastRange(Target, TigerPalm) then

	-- If not (blackout combo spell exists? AND (option toggle is turned on) AND we have blackoutcombo buff AND keg smash CD < 2.5s)
	-- So, enter this if any of the above are false???
	-- 	if not (BlackoutCombo:Exists() and (module.GetOptionValue("Blackout Combo") == "Keg Smash" or module.GetOptionValue("Blackout Combo") == "Auto") and Player:Buff(BlackoutCombo) and KegSmash:Cooldown() < 2.5) then
	--    cast black ox brew when: option enabled and player.spell.charges(purifying brew) < 1 and player.spell.recharge(purifying brew) > 2
	-- 		-- Active Mitigation
	--		if player.spell.charges(purifying brew) >= 1
	--			collect current stagger
	-- 		if PurifyingBrew:Charges() >= 1 then
	-- 			CurrentStagger = Player:Stagger();
	-- 			-- Purify if we have Moderate / Heavy Stagger
	-- 			if PurifyingBrew:Exists() and module.IsOptionEnabled("Purifying Brew") and PurifyingBrew:TimeSinceCast() >= 5 then
	-- 				Option1 = module.GetOptionValue("Purifying Brew");
	-- 				if CurrentStagger > Option1 and Player:CanCast(PurifyingBrew) then
	-- 					module.Bug("Mitigation via Purifying Brew with "..CurrentStagger.."%.");
	-- 					PurifyingBrew.LastCastTime = module.GetTime();
	-- 					Player:Cast(PurifyingBrew);
	-- 					RandomOffGCD = nil;
	-- 					return;
	-- 				end
	-- 			end
	-- 			-- Ironskin if we have Light / No Stagger
	-- 			if IronskinBrew:Exists() and module.IsOptionEnabled("Ironskin Brew") and PurifyingBrew:Charges() >= 2 and IronskinBrew:TimeSinceCast() >= 5 and not Player:Buff(IronskinBrew) then
	-- 				Option1, Option2 = module.GetOptionValue("Ironskin Brew"), module.GetSecondOptionValue("Ironskin Brew");
	-- 				if Player:RecentDamageTakenPercent(Option2, "Physical") + Player:RecentDamageTakenPercent(Option2, "Spell") > Option1 and Player:CanCast(IronskinBrew) then
	-- 					module.Bug("Mitigation via Ironskin Brew with "..tostring(Player:RecentDamageTakenPercent(Option2, "Physical") + Player:RecentDamageTakenPercent(Option2, "Spell")).." health% damage taken over the last "..tostring(Option2).." seconds.");
	-- 					Player:Cast(IronskinBrew);
	-- 					IronskinBrew.LastCastTime = module.GetTime();
	-- 					RandomOffGCD = nil;
	-- 					return;
	-- 				end
	-- 			end
	-- 		end
	-- 		-- Prevent Capping
	-- 		if module.IsOptionEnabled("Mitigation Dump") and PurifyingCapped and IronskinBrew:Exists() and not Player:Buff(IronskinBrew) then
	-- 			if Player:RecentDamageTakenPercent(5, "Physical") + Player:RecentDamageTakenPercent(5, "Spell") > 0 and Player:CanCast(IronskinBrew) then
	-- 				module.Bug("Mitigation Dump via Ironskin Brew");
	-- 				IronskinBrew.LastCastTime = module.GetTime();
	-- 				Player:Cast(IronskinBrew);
	-- 				RandomOffGCD = nil;
	-- 				return;
	-- 			end
	-- 		end
	-- 	end
	-- end
}

local _Survival = {
	-- First charge of Healing Elixir at 2 charges @ configured health threshold
	{ "Healing Elixir", { "player.spell(Healing Elixir).charges >= 2", "player.spell(Healing Elixir).cooldown < 3", "!lastcast(Healing Elixir)", elixir }, "player" },
	-- Second charge of Healing Elixir when health <= 35%
	{ "Healing Elixir", { "player.spell(Healing Elixir).charges >= 2", "player.spell(Healing Elixir).cooldown < 3", "!lastcast(Healing Elixir)", "player.health <= 35" }, "player" },

	-- TODO: Update for legion's equivillant to healing tonic 109223
	{ "#109223", healthstn, "player" }, -- Healing Tonic
	{ '#5512', healthstn, "player" }, -- Healthstone

	{'Fortifying Brew', { fortbrew }, "player" },

	-- Cast when there is at least one orb on the ground
	{'Expel Harm', { expelharm, "player.spell(Expel Harm).count >= 1" }, "player" },

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
	-- TODO: Provoke (on a toggle) any valid* unit within 30 yards ("player.area(30).enemies") that we're not already tanking ("player.threat < 100"), that a pet is not tanking (???), and that maintank ("tank.threat < 100") or offtank ((tank2.threat < 100)) aren't already tanking too
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
		{_Mitigation, 'target.inMelee'},
		{_Cooldowns, 'modifier.cooldowns'},
		{_AoE, {
			'player.area(8).enemies >= 3', (function() return F('canTaunt') end)
		}},
		{_Melee, {'target.inMelee', 'target.infront'}},
		{_Ranged, { "target.range > 8", "target.range <= 40", "target.infront" }},
	}, _OOC, exeOnLoad)
