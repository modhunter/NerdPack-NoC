local config = {
	key = 'NoC_DH_Vengeance',
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Demon Hunter Vengeance Settings',
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		-- General
		{type = 'header',text = 'General', align = 'center'},
			{type = 'checkbox', text = '5 min DPS test', key = 'dsptest', default = false},
      -- TODO: add toggle for auto CJL

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
			{type = 'spinner', text = 'Healthstone', key = 'Healthstone', default = 75},
	}
}

NeP.Interface.buildGUI(config)

local exeOnLoad = function()
	NOC.Splash()
	NeP.Interface.CreateSetting('Class Settings', function() NeP.Interface.ShowGUI('NoC_DH_Vengeance') end)
end

local _All = {
	-- Keybinds
	--{ 'pause', 'modifier.shift' },
  { "Chaos Nova", "modifier.lcontrol" },
  { "Darkness", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return NeP.Interface.fetchKey('NoC_DH_Vengeance', 'dsptest') end) }},

	-- AutoTarget
	--{ "/targetenemy [noexists]", "!target.exists" },
	--{ "/targetenemy [dead]", { "target.exists", "target.dead" } },

  {{
    { "Eye Beam", "!talent(3,2)" },
    { "Eye Beam", "player.fury >= 80" },
    { "Eye Beam", "player.furydiff < 30" },
  }, { "talent(5,1)", "!player.buff(Momentum)", "target.range <= 20" }},
  { "Eye Beam", { "!talent(5,1)", "toggle.multitarget", "modifier.enemies >= 2", "target.range <= 20" }},

  { "Throw Glaive", { "talent(3,3)", "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},
  { "Throw Glaive", { "!player.buff(Metamorphosis)", "talent(3,3)" }},
  { "Throw Glaive", { "!player.buff(Metamorphosis)", "toggle.multitarget", "modifier.enemies >= 3" }},

  -- { "Nemsis", "target.ttd < 60" },
  { "Nemsis" },
}

local _Cooldowns = {
  { "Lifeblood" },
  { "Berserking" },
  { "Blood Fury" },
  {{
    { "Metamorphosis", { "player.spell(Chaos Blades).cooldown < 1" }, "player" },
    { "Metamorphosis", { "player.buff(Chaos Blades)" }, "player" },
    { "Metamorphosis", { "!talent(6,3)" }, "player" },
    -- TODO: Handle demonic talent and eye beam
  }, { "!player.buff(Metamorphosis)" }},
}

local _Survival = {
  { "Blur", { "player.health <= 70" }},
  { "Desperate Instincts", { "player.health <= 70" }},
  { "Netherwalk", { "player.health <= 70" }},

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
  { "Chaos Blades", { "!player.buff(Chaos Blades)", "player.spell(Metamorphosis).cooldown > 100" }},
  { "Chaos Blades", "player.buff(Metamorphosis)" },

  { "Death Sweep", "talent(3,2)" },
  { "Death Sweep", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},

  {{
    { "Demon's Bite", "talent(3,2)" },
    { "Demon's Bite", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},
  }, { "player.buff(Metamorphosis).duration > 1.5", "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 70" }},

  { "Blade Dance", "talent(3,2)" },
  { "Blade Dance", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},
  { "Fel Barrage", "player.spell(Fel Barrage).charges >= 5" },

  { "Fury of the Illidari", "!player.buff(Momentum)" },
  { "Fury of the Illidari", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},

  { "Felblade", { "player.furydiff >= 30", "!player.buff(Prepared)" }},
  { "Felblade", { "player.furydiff >= 42", "player.buff(Prepared)" }},

  { "Annihilation" },
  { "Fel Erruption" },

  {{
    { "Demon's Bite", "talent(3,2)" },
    { "Demon's Bite", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},
  }, { "!player.buff(Metamorphosis)", "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 55" }},
  {{
    { "Demon's Bite", { "player.spell(Eye Beam).cooldown < 1.5", "player.furydiff >= 30" }},
    { "Demon's Bite", { "player.spell(Eye Beam).cooldown < 3", "player.furydiff >= 55" }},
  }, { "!player.buff(Metamorphosis)", "talent(7,3)" }},

  { "Chaos Strike" },
  { "Fel Barrage", { "player.spell(Fel Barrage).charges >= 4", "!player.buff(Metamorphosis)" }},
  { "Demon's Bite" },
	}, 'target.infront' },
}

local _AoE = {
}

NeP.Engine.registerRotation(581, '[|cff'..NeP.Interface.addonColor..'NoC|r] Demon Hunter - Vengeance',
	{ -- In-Combat
		{'pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Cooldowns, 'modifier.cooldowns'},
		{{ -- Conditions
			{_Melee, 'target.inMelee'},
			{_Ranged, { "target.range > 8", "target.range <= 40" }},
		}, {'target.range <= 40', 'target.exists'} }
	}, _All, exeOnLoad)
