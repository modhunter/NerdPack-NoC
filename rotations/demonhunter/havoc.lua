local config = {
	key = 'NoC_DH_Havoc',
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Demon Hunter Havoc Settings',
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
	NePCR.Splash()
	NeP.Interface.CreateSetting('Class Settings', function() NeP.Interface.ShowGUI('NoC_DH_Havoc') end)
end

local _All = {
	-- Keybinds
	{ 'pause', 'modifier.shift' },
  { "Chaos Nova", "modifier.lcontrol" },
  { "Darkness", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return NeP.Interface.fetchKey('NoC_DH_Havoc', 'dsptest') end) }},

	-- AutoTarget
	--{ "/targetenemy [noexists]", "!target.exists" },
	--{ "/targetenemy [dead]", { "target.exists", "target.dead" } },

  {{
    { "Eye Beam", "!talent(3,2)" },
    { "Eye Beam", "player.fury >= 80" },
    { "Eye Beam", "player.furydiff < 30" },
  }, { "talent(7,3)", "!player.buff(Momentum)" }},

  { "Demon's Bite", { "player.spell(Metamorphosis).cooldown < 1.5", "player.furydiff >= 25", "target.range <= 5" }},

  --{ "Eye Beam", { "!talent(5,1)", "toggle.multitarget", "modifier.enemies >= 2", "target.range <= 20" }},

  { "Nemsis" },

  { "Chaos Blades", { "player.spell(Metamorphosis).cooldown > 100" }},
  { "Chaos Blades", "player.buff(Metamorphosis)" },
}

local _Cooldowns = {
  { "Lifeblood" },
  { "Berserking" },
  { "Blood Fury" },
  --metamorphosis,if=buff.metamorphosis.down&(!talent.demonic.enabled|!cooldown.eye_beam.ready)&(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
	-- Look at this example for ideas:
	--function Rubim.DnD()
	--  CastSpellByName(GetSpellInfo(43265))
	--  if SpellIsTargeting() then CameraOrSelectOrMoveStart() CameraOrSelectOrMoveStop() end
	--  return true
	--end
  --{ "Death and Decay" , { "modifier.lalt" , "modifier.lcontrol" , "@Rubim.DnD()"}},

	-- function Rubim.DnD()
	-- 	if UnitExists("mouseover") == false and UnitCanAttack("player", "mousever") == false and UnitIsDeadOrGhost("mouseover") == false then return false elseif UnitExists("mouseover") == true then
	-- 		CastSpellByName(GetSpellInfo(43265))
	-- 		if SpellIsTargeting() then CameraOrSelectOrMoveStart() CameraOrSelectOrMoveStop() end
	-- 		return true
	-- 	end
	-- end


  --{{
    --{ "Metamorphosis", { "player.spell(Chaos Blades).cooldown < 1" }, "ground" },
    --{ "Metamorphosis", { "player.buff(Chaos Blades)" }, "ground" },
    --{ "Metamorphosis", { "!talent(6,3)" }, "ground" },
    -- TODO: Handle demonic talent and eye beam
  --}, { "!player.buff(Metamorphosis)" }},
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
	--{ "Throw Glaive" },

  {{
    { "Fel Barrage", "player.buff(Momentum)" },
    { "Fel Barrage", "!talent(5,1)" },
  }, { "player.spell(Fel Barrage).charges >= 5" }},

  {{
    { "Throw Glaive", "!talent(6,1)" },
    { "Throw Glaive", "!talent(5,1)" },
    { "Throw Glaive", "player.buff(Momentum)" },
  }, { "talent(3,3)", "toggle.multitarget", "modifier.enemies >= 2" }},

  {{
    { "Throw Glaive", "!talent(6,1)" },
    { "Throw Glaive", "!talent(5,1)" },
    { "Throw Glaive", "player.buff(Momentum)" },
  }, { "talent(3,3)" }},

  {{
    { "Eye Beam", { "toggle.multitarget", "modifier.enemies >= 2" }},
    { "Eye Beam", "!player.buff(Metamorphosis)" },
  }, { "!talent(7,3)" }},

}

local _Melee = {
	-- Rotation
	{{ -- infront
    { "Fury of the Illidari" }, -- Fury of the Illidari

    --death_sweep,if=death_sweep_worth_using ?????
    { "Death Sweep" },
    { "Death Sweep", { "talent(1,2)", "toggle.multitarget", "modifier.enemies >= 2" }},
    { "Demon's Bite", { "player.buff(Metamorphosis).duration > 1.5", "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 70" }},
    { "Blade Dance" },

    {{
      { "Fel Barrage", "player.buff(Momentum)" },
      { "Fel Barrage", "!talent(5,1)" },
    }, { "player.spell(Fel Barrage).charges >= 5" }},

    {{
      { "Throw Glaive", "!talent(6,1)" },
      { "Throw Glaive", "!talent(5,1)" },
      { "Throw Glaive", "player.buff(Momentum)" },
    }, { "talent(3,3)", "toggle.multitarget", "modifier.enemies >= 2" }},

    { "Fel Erruption" },

    { "Felblade", { "player.furydiff >= 30", "!player.buff(Prepared)" }},
    { "Felblade", { "player.furydiff >= 42", "player.buff(Prepared)" }},

    { "Annihilation", "!talent(5,1)" },
    { "Annihilation", "player.buff(Momentum)" },
    { "Annihilation", { "player.furydiff >= 30", "!player.buff(Prepared)" }},
    { "Annihilation", { "player.furydiff >= 42", "player.buff(Prepared)" }},
    { "Annihilation", "player.buff(Metamorphosis).duration < 2" },

    {{
      { "Throw Glaive", "!talent(6,1)" },
      { "Throw Glaive", "!talent(5,1)" },
      { "Throw Glaive", "player.buff(Momentum)" },
    }, { "talent(3,3)" }},

    {{
      { "Eye Beam", { "toggle.multitarget", "modifier.enemies >= 2" }},
      { "Eye Beam", "!player.buff(Metamorphosis)" },
    }, { "!talent(7,3)" }},

    {{
      { "Demon's Bite", { "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 55" }},
      { "Demon's Bite", { "talent(7,3)", "player.spell(Eye Beam).cooldown < 1.5", "player.furydiff >= 20" }},
      { "Demon's Bite", { "talent(7,3)", "player.spell(Eye Beam).cooldown < 3", "player.furydiff >= 45" }},
    }, { "!player.buff(Metamorphosis)", "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 70" }},

    { "Throw Glaive", { "!player.buff(Metamorphosis)", "toggle.multitarget", "modifier.enemies >= 3" }},

    { "Chaos Strike", "talent(5,1)" },
    { "Chaos Strike", "player.buff(Momentum)" },
    { "Chaos Strike", { "player.furydiff >= 30", "!player.buff(Prepared)" }},
    { "Chaos Strike", { "player.furydiff >= 42", "player.buff(Prepared)" }},

    {{
      { "Fel Barrage", "player.buff(Momentum)" },
      { "Fel Barrage", "!talent(5,1)" },
    }, { "player.spell(Fel Barrage).charges >= 4", "!player.buff(Metamorphosis)" }},

    { "Demon's Bite" },
	}, 'target.infront' },
}

local _AoE = {
}

NeP.Engine.registerRotation(577, '[|cff'..NeP.Interface.addonColor..'[NoC]|r] Demon Hunter - Havoc',
	{ -- In-Combat
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Cooldowns, 'modifier.cooldowns'},
		{{ -- Conditions
			{_Melee, "target.range <= 5" },
			{_Ranged, { "target.range > 8", "target.range <= 40" }},
		}, {'target.range <= 40', 'target.exists'} }
	}, _All, exeOnLoad)
