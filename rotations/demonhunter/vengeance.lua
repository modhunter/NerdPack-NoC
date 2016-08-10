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
      -- TODO: add toggle for auto CJL

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
	--{ 'pause', 'modifier.shift' },
  { "Chaos Nova", "modifier.lcontrol" },
  { "Darkness", "modifier.lalt" },

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.time >= 300", (function() return F('dpstest') end) }},

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
		{ "Fiery Brand", { "!player.buff(Demon Spikes)", "!player.buff(Metamorphosis)" }},

		{{
			{ "Demon Spikes", "player.spell(Demon Spikes).charges >= 2" },
			{ "Demon Spikes", "!player.buff(Demon Spikes)" },
		}, { "!target.debuff(Fiery Brand)", "!player.buff(Metamorphosis)" }},


	-- actions+=/empower_wards,if=debuff.casting.up
	--
	--
	-- actions+=/infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&artifact.fiery_demise.enabled&dot.fiery_brand.ticking
	-- actions+=/infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&(!artifact.fiery_demise.enabled|(max_charges-charges_fractional)*recharge_time<cooldown.fiery_brand.remains+5)&(cooldown.sigil_of_flame.remains>7|charges=2)
	-- actions+=/spirit_bomb,if=debuff.frailty.down
	-- actions+=/soul_carver,if=dot.fiery_brand.ticking
	-- actions+=/immolation_aura,if=pain<=80
	-- actions+=/felblade,if=pain<=70
	-- actions+=/soul_barrier
	-- actions+=/soul_cleave,if=soul_fragments=5
	-- actions+=/metamorphosis,if=buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down&incoming_damage_5s>health.max*0.70
	-- actions+=/fel_devastation,if=incoming_damage_5s>health.max*0.70
	-- actions+=/soul_cleave,if=incoming_damage_5s>=health.max*0.70
	-- actions+=/fel_eruption
	-- actions+=/sigil_of_flame,if=remains-delay<=0.3*duration
	-- actions+=/fracture,if=pain>=80&soul_fragments<4&incoming_damage_4s<=health.max*0.20
	-- actions+=/soul_cleave,if=pain>=80
	-- actions+=/shear

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
