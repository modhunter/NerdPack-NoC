local mKey = 'NoC_DH_Havoc'
local config = {
	key = mKey,
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..NeP.Info.Nick..' Config',
	subtitle = 'Demon Hunter Havoc Settings',
	color = NeP.Core.classColor('player'),
	width = 250,
	height = 500,
	config = {
		-- General
		{type = 'header',text = 'General', align = 'center'},
		{type = 'checkbox', text = 'Automatic Throw Glaive', key = 'auto_glaive', default = true},
		{type = 'checkbox', text = '5 min DPS test', key = 'dpstest', default = false},

		-- Survival
		{type = 'spacer'},{type = 'rule'},
		{type = 'header', text = 'Survival', align = 'center'},
		{type = 'spinner', text = 'Healthstone & Healing Tonic', key = 'Healthstone', default = 45},
		{type = 'spinner', text = 'Blur', key = 'blur', default = 70},
		{type = 'spinner', text = 'Desperate Instincts', key = 'desperate', default = 40},
		{type = 'spinner', text = 'Netherwalk', key = 'netherwalk', default = 70},
	}
}

local E = NOC.dynEval
local F = function(key) return NeP.Interface.fetchKey(mKey, key, 100) end

local exeOnLoad = function()
	NeP.Interface.buildGUI(config)
	NOC.ClassSetting(mKey)
end

local healthstn = function()
	return E('player.health <= ' .. F('Healthstone'))
end

local blur_check = function()
	return E('player.health <= ' .. F('blur'))
end

local desperate_check = function()
	return E('player.health <= ' .. F('desperate'))
end

local netherwalk_check = function()
	return E('player.health <= ' .. F('netherwalk'))
end

local _meta = function()
	local result = false
	--buff.metamorphosis.down&
	--(!talent.demonic.enabled|!cooldown.eye_beam.ready)&
	--(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&
	--(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
	if E('!player.buff(Metamorphosis)') and (E('!talent(7,3)') or E('player.spell(Eye Beam).cooldown < 0.5')) and (E('!talent(7,1)') or E('player.spell(Chaos Blades).cooldown < 0.5')) and (E('!talent(5,3)') or E('target.debuff(Nemesis)') or E('player.spell(Nemesis).cooldown < 0.5')) then
		result = true
	end
	return result
end

local _All = {
	-- Keybinds
	--{ 'pause', 'modifier.shift' },
  { "Chaos Nova", "modifier.lcontrol" },
  --{ "Darkness", "modifier.lalt" }, -- reserve alt for Metamorphosis instead

	{ "/stopcasting\n/stopattack\n/cleartarget\n/stopattack\n/cleartarget", { "player.combattime >= 300", (function() return F('dpstest') end) }},

	-- Vengeful Retreat backwards through the target to minimize downtime.
  --vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
  -- Fel Rush for Momentum and for fury from Fel Mastery.
  --fel_rush,animation_cancel=1,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&raid_event.movement.in>charges*10

}

local _Cooldowns = {
  { "Lifeblood" },
  { "Berserking" },
  { "Blood Fury" },

	{ "Metamorphosis", { "modifier.lalt", (function() return _meta() end) }, "mouseover.ground" },

	-- Just cast it #YOLO
	--{ "Metamorphosis", { "modifier.lalt" }, "mouseover.ground" },
}

local _Survival = {
  { "Blur", { blur_check }},
  { "Desperate Instincts", { desperate_check }},
  { "Netherwalk", { netherwalk_check }},

	{ "#109223", healthstn, "player" }, -- Healing Tonic
	{ '#5512', healthstn, "player" }, -- Healthstone
}

local _Interrupts = {
	{ "Consume Magic" },
}

local _AoE = {
}

local _Ranged = {
	-- Throw Glaive range: 30
	-- Fel Barrage range: 30
	-- Eye Beam range: 20
	-- Felblade: 15
	-- Fel Erruption: 20

	-- Auto-cast Throw Glaive when outside of range
	{ "Throw Glaive", (function() return F('auto_glaive') end), "target.range <= 30" },
}

local _Melee = {
	-- Rotation
  { "Fury of the Illidari" }, -- Fury of the Illidari

	-- TODO: figure out how to handle the wierd 'worth using' crap from the simc APL
	-- TODO: implement true gcd checking instead of assuming 1.5s everywhere
  { "Death Sweep" },
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
  }, { "talent(3,3)", "toggle.multitarget", "player.area(10).enemies >= 2" }},

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

	{ "Eye Beam", { "!talent(7,3)", { "toggle.multitarget", "player.area(15).enemies >= 2", "or", "!player.buff(Metamorphosis)" }, { "toggle.multitarget", "player.area(15).enemies >= 2", "or", "player.level = 100" }}},
	--{ "Eye Beam", { "!talent(7,3)", "toggle.multitarget", "player.area(15).enemies >= 2", }},
	--{ "Eye Beam", { "!talent(7,3)", "!player.buff(Metamorphosis)", "player.level = 100" }},

  {{
    { "Demon's Bite", { "player.spell(Blade Dance).cooldown < 1.5", "player.fury < 55" }},
    { "Demon's Bite", { "talent(7,3)", "player.spell(Eye Beam).cooldown < 1.5", "player.furydiff >= 20" }},
    { "Demon's Bite", { "talent(7,3)", "player.spell(Eye Beam).cooldown < 3", "player.furydiff >= 45" }},
  }, { "!player.buff(Metamorphosis)" }},

  { "Throw Glaive", { "!player.buff(Metamorphosis)", "toggle.multitarget", "player.area(10).enemies >= 3" }},

  { "Chaos Strike", "!talent(5,1)" },
  { "Chaos Strike", "player.buff(Momentum)" },
  { "Chaos Strike", { "player.furydiff >= 30", "!player.buff(Prepared)" }},
  { "Chaos Strike", { "player.furydiff >= 42", "player.buff(Prepared)" }},

  {{
    { "Fel Barrage", "player.buff(Momentum)" },
    { "Fel Barrage", "!talent(5,1)" },
  }, { "player.spell(Fel Barrage).charges >= 4", "!player.buff(Metamorphosis)" }},

	{ "Throw Glaive" },

  { "Demon's Bite" },
}

local _Rotation = {
	{{
		{ "Eye Beam", "!talent(3,2)" },
		{ "Eye Beam", "player.fury >= 80" },
		{ "Eye Beam", "player.furydiff < 30" },
	}, { "talent(7,3)", "!player.buff(Metamorphosis)", "target.range <= 20" }},

	-- If Metamorphosis is ready, pool fury
	{ "Demon's Bite", { "player.spell(Metamorphosis).cooldown < 0.5", "player.furydiff >= 25", "target.range <= 5" }},

	{ "Nemesis", { "player.area(8).enemies >= 3", "!target.debuff(Nemesis)", "target.range <= 5" }},
	{ "Nemesis", { "player.area(8).enemies = 1", "player.spell(Metamorphosis).cooldown > 100", "target.range <= 5" }},
	{ "Nemesis", { "player.area(8).enemies = 1", "target.ttd < 70", "target.range <= 5" }},
	{ "Nemesis", { "player.spell(Metamorphosis).cooldown < 0.5", "target.range <= 5", "player.area(8).enemies = 1" }},

	{ "Chaos Blades", "player.spell(Metamorphosis).cooldown > 100" },
	{ "Chaos Blades", "player.buff(Metamorphosis)" },
	{ "Chaos Blades", "target.ttd < 20" },

	{_Cooldowns, 'modifier.cooldowns'},
}

NeP.Engine.registerRotation(577, '[|cff'..NeP.Interface.addonColor..'NoC|r] Demon Hunter - Havoc',
	{ -- In-Combat
		{ '%pause', 'modifier.shift'},
		{_All},
		{_Survival, 'player.health < 100'},
		{_Interrupts, 'target.interruptAt(40)'},
		{_Rotation},
		{_Melee, "target.range <= 5" },
		{_Ranged, { "target.range > 8", "target.range <= 40" }},
	}, _All, exeOnLoad)
