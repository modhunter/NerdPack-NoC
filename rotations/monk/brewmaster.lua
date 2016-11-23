local GUI = {
	-- General
	{type = 'spacer'},{type = 'rule'},
	{type = 'header', text = 'General', align = 'center' },
	{type = 'checkbox', text = 'Automatic Res', key = 'auto_res', default = true},
	--{type = "checkbox", text = "Automated Taunts", key = "canTaunt", default = false },
	{type = 'checkbox', text = 'Automatic CJL at range', key = 'auto_cjl', default = false},

	-- Survival
	{type = 'spacer'},{type = 'rule'},
	{type = 'header', text = 'Survival', align = 'center'},
	{type = 'spinner', text = 'Healthstone or Healing Potion', key = 'Health Stone', default = 45},
	{type = 'spinner', text = 'Healing Elixir', key = 'Healing Elixir', default = 70},
	{type = 'spinner', text = 'Expel Harm', key = 'Expel Harm', default = 100},
	{type = 'spinner', text = 'Fortifying Brew', key = 'Fortifying Brew', default = 20},
	{type = 'spinner', text = 'Ironskin Brew', key = 'Ironskin Brew', default = 80},
}

local exeOnLoad = function()
end


local _All = {
	-- keybind
	{'Summon Black Ox Statue', 'keybind(lalt)', "cursor.ground"},
	{ "Leg Sweep", "keybind(lcontrol)" },

	-- Nimble Brew if pvp talent taken
	{'Nimble Brew', 'player.state.disorient'},
	{'Nimble Brew', 'player.state.stun'},
	{'Nimble Brew', 'player.state.fear'},
	{'Nimble Brew', 'player.state.horror'},

	{ "Tiger's Lust", 'player.state.disorient' }, -- Tiger's Lust = Tiger's Lust
	{ "Tiger's Lust", 'player.state.stun' }, -- Tiger's Lust = Tiger's Lust
	{ "Tiger's Lust", 'player.state.root' }, -- Tiger's Lust = Tiger's Lust
	{ "Tiger's Lust", 'player.state.snare' }, -- Tiger's Lust = Tiger's Lust


}

local outCombat = {
	-- TODO: Add support for (optional) automatic potion use w/pull timer
	{'Summon Black Ox Statue', 'keybind(lalt)', "cursor.ground"},

	-- Automatic res of dead party members
	{ "%ressdead(Resuscitate)", 'UI(auto_res)' },

	{ "Effuse", "player.health <= 50 & player.lastmoved >= 1", "player" },
}

local _Cooldowns = {
}

local _Mitigation = {
	{ "Black Ox Brew", "player.spell(Purifying Brew).charges < 1 & player.spell(purifying brew).recharge > 2" },

	-- Active Mitigation
	{ "Purifying Brew", "@NOC.staggered(nil) & player.spell(Purifying Brew).charges >= 1" },

	-- Ironskin if we have Light / No Stagger
	-- TODO: add check to determine if we've lost 25% health over the last 5 seconds
	{ "Ironskin Brew", "player.health <= UI(Ironskin Brew) & player.spell(Purifying Brew).charges >= 2 & !player.buff(Ironskin Brew)" },

	-- Prevent Capping
	{ "Ironskin Brew", "@NOC.purifyingCapped(nil) & player.health < 100 & !player.buff(Ironskin Brew)" },
}

local _Survival = {
	{ "Healing Elixir", "player.spell(Healing Elixir).charges >= 2 || {player.spell(Healing Elixir).charges = 1 & player.spell(Healing Elixir).cooldown < 3} & !lastcast(Healing Elixir) & player.health <= UI(Healing Elixir)", "player" },

	--{ '#5512', 'player.health <= UI(Health Stone)', "player" }, -- Healthstone
	{ "#127834", 'player.health <= UI(Healthstone)', "player" }, -- Ancient Healing Potion

	{'Fortifying Brew', 'player.health <= UI(Fortifying Brew)', "player" },

	-- Cast when there is at least one orb on the ground
	{'Expel Harm', "player.health <= UI(Expel Harm) & player.spell(Expel Harm).count >= 1", "player" },
}

local _Interrupts = {
	-- Ring of Peace when SHS is on CD
	{ "Ring of Peace", "!target.debuff(Spear Hand Strike) & player.spell(Spear Hand Strike).cooldown > 1 & !lastcast(Spear Hand Strike)" },
	-- Leg Sweep when SHS is on CD
  { "Leg Sweep", "player.spell(Spear Hand Strike).cooldown > 1 & target.inMelee & !lastcast(Spear Hand Strike)" },
	-- Quaking Palm when SHS is on CD
  { "Quaking Palm", "!target.debuff(Spear Hand Strike) & player.spell(Spear Hand Strike).cooldown > 1 & !lastcast(Spear Hand Strike)" },
  { "Spear Hand Strike" }, -- Spear Hand Strike
}

local _Ranged = {
	{ "Crackling Jade Lightning", "!player.moving & UI(auto_cjl)" },
}

local _Taunts = {
	-- TODO: Provoke (on a toggle) any valid unit within 30 yards ("player.area(30).enemies") that we're not already tanking ("player.threat < 100"), that a pet is not tanking (???), and that maintank ("tank.threat < 100") or offtank ((tank2.threat < 100)) aren't already tanking too
	--{'Provoke', 'target.range <= 35'},
}

local _Melee = {
	-- If Blackout Combo talent enabled
	{ "Blackout Strike", "target.inMelee & talent(7,2) & !player.buff(Blackout Combo) & {player.spell(Keg Smash).cooldown > 3 || player.spell(Keg Smash).cooldown < 1.5}" },
	{ "Keg Smash", "talent(7,2) & {player.buff(Blackout Combo) || @NOC.purifyingCapped(nil)}" },

	{ "Keg Smash", "!talent(7,2)" },

	-- Keg Smash Wait - Wait longer for Blackout Combo if not capped
	{{
		{ "Blackout Strike", "target.inMelee & !player.buff(Blackout Combo) & talent(7,2) & player.area(10).enemies >= 1" },
		{ "Breath of Fire", "player.buff(Blackout Combo) & talent(7,2) & player.area(10).enemies >= 1" },

		{ "Blackout Strike", "target.inMelee & talent(7,2) & !player.buff(Blackout Combo) & {player.energy >= 45 || player.spell(Keg Smash).cooldown > 3}" },
		{ "Tiger Palm", "target.inMelee & talent(7,2) & player.buff(Blackout Combo)" },

		{ "Blackout Strike", "target.inMelee" },

		{ "Breath of Fire", "target.inMelee & target.debuff(Keg Smash) & !talent(7,2) & player.area(10).enemies >= 1" },

		{ "Chi Burst", 'player.area(40).enemies >= 1' },

		{ "Chi Wave" },

		{ "Rushing Jade Wind", "player.area(8).enemies >= 2 & toggle(AoE)" },

		-- required ground cast?
		--{ "Flaming Keg" },

		{ "Tiger Palm", "target.inMelee & !talent(7,2) || { target.inMelee & player.energy >= 70 & { player.energy >= 55 || player.spell(Keg Smash).cooldown > 3}}" },
	}, { "player.spell(Keg Smash).cooldown >= 0.5 || { !talent(7,2) & !player.buff(Blackout Combo) & player.spell(Keg Smash).cooldown >= 2 & @NOC.purifyingCapped(nil) }" }},
}

local inCombat = {
	{ '%pause', 'keybind(shift)' },
	{_All},
	{_Survival, 'player.health < 100' },
	{_Interrupts, 'target.interruptAt(55) & target.inMelee' },
	{_Mitigation, 'target.inMelee & {!talent(7,2) || !player.buff(Blackout Combo) || player.spell(Keg Smash).cooldown >=2.5}' },
	{_Cooldowns, 'toggle(cooldowns)' },
	{_Melee },
	{_Ranged, "!target.inMelee & target.inRanged" },
}

NeP.CR:Add(268, {
	name = '[NoC] Monk - Brewmaster',
	  ic = inCombat,
	 ooc = outCombat,
	 gui = GUI,
	load = exeOnLoad
})
