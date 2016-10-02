NOC = {
	Version = '1.6',
	Branch = 'master',
	Interface = {
		addonColor = 'A330C9',
		Logo = NeP.Interface.Logo -- Temp until i get a logo
	},
}

local Parse = NeP.DSL.Parse
local Fetch = NeP.Interface.fetchKey


function NOC.ClassSetting(key)
	local name = '|cff'..NeP.Core.classColor('player')..'Class Settings'
	NeP.Interface.CreateSetting(name, function() NeP.Interface.ShowGUI(key) end)
end

function NOC.dynEval(condition, spell)
	return Parse(condition, spell or '')
end

function NOC.Splash()
	return true
end

function NOC.tt()
	if NeP.Protected.Unlocker and UnitAffectingCombat('player') then
		NeP.Engine.Cast_Queue('Transcendence: Transfer', 'player')
	end
end

function NOC.ts()
	if NeP.Protected.Unlocker and UnitAffectingCombat('player') then
		NeP.Engine.Cast_Queue('Transcendence', 'player')
	end
end


--math.randomseed( os.time() )
local function shuffleTable( t )
    local rand = math.random
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

local MasterySpells = {
	[100784] = '', -- Blackout Kick
	[113656] = '', -- Fists of Fury
	[101545] = '', -- Flying Serpent Kick
	[107428] = '', -- Rising Sun Kick
	[101546] = '', -- Spinning Crane Kick
	[205320] = '', -- Strike of the Windlord
	[100780] = '', -- Tiger Palm
	[115080] = '', -- Touch of Death
	[115098] = '', -- Chi Wave
	[123986] = '', -- Chi Burst
	[116847] = '', -- Rushing Jade Wind
	[152175] = '', -- Whirling Dragon Punch
	[117952] = '', -- Crackling Jade Lightning
}
local HitComboLastCast = ''

NeP.Timer.Sync("windwalker_sync", 0.11, function()
	local Running = NeP.DSL.Get('toggle')(nil, 'mastertoggle')
	if Running then
		if NeP.Interface.GetSelectedCR() then
			if not NeP.Engine.forcePause then
				local _, _, _, _, _, _, spellID = GetSpellInfo(NeP.Engine.lastCast)
				if spellID then
					if MasterySpells[spellID] ~= nil then
						-- If NeP.Engine.lastCast is in the MasterySpells list, set HitComboLastCast to this spellID
						HitComboLastCast = spellID
						--print("windwalker_sync flagging "..NeP.Engine.lastCast);
					end
				end
			end
		end
	end
end, 99)

NeP.library.register('NOC', {

	AoEMissingDebuff = function(spell, debuff, range)
		if spell == nil or range == nil then return false end
		local spell = select(1,GetSpellInfo(spell))
		if not IsUsableSpell(spell) then return false end
		local enemies = NeP.OM['unitEnemie']
		for i=1,#enemies do
			local Obj = enemies[i]
			if Obj.distance <= range and (UnitAffectingCombat(Obj.key) or isDummy(Obj.key)) then
				local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
				if not debuffDuration or debuffDuration - GetTime() < 1.5 then
					local skillType = GetSpellBookItemInfo(spell)
					local isUsable, notEnoughMana = IsUsableSpell(spell)
					if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
						local GCD = NeP.DSL.Get('gcd')()
						if GetSpellCooldown(spell) <= GCD then
							if NeP.Engine.LineOfSight('player', Obj.key) then
								--print("AoEMissingDebuff: casting "..spell.." against "..Obj.name.." ("..Obj.key.." - "..time()..") - TTD="..NeP.CombatTracker.TimeToDie(Obj.key));
								NeP.Engine.Cast_Queue(spell, Obj.key)
								return true
							end
						end
					end
				end
			end
		end
		return false
	end,

	-- getGCD = function()
	-- 	local CDTime, CDValue = 0, 0;
	--   CDTime, CDValue = GetSpellCooldown(61304);
	--   if CDTime == 0 or module.GetTime()-module.GetLatency() >= CDTime+CDValue then
	--     return true;
	--   else
	--     return false;
	--   end
	-- end,

	hitcombo = function(spell)
		--return true
		local spell = spell
		if spell then
			local _, _, _, _, _, _, spellID = GetSpellInfo(spell)
			if Parse('player.buff(Hit Combo)') then
				-- we're using hit combo and need to check if the spell we've passed-in is in the list
				if HitComboLastCast == spellID then
					-- If the passed-spell is in the list as flagged, we need to exit false
					--print('hitcombo('..spell..') and it is was flagged ('..HitComboLastCast..'), returning false');
					return false
				end
			end
			return true
		else
			return true
		end
		return false
	end,

})


NeP.DSL.RegisterConditon("castwithin", function(target, spell)
	local SpellID = select(7, GetSpellInfo(spell))
	for k, v in pairs( NeP.ActionLog.log ) do
		local id = select(7, GetSpellInfo(v.description))
		if (id and id == SpellID and v.event == "Spell Cast Succeed") or tonumber( k ) == 20 then
			return tonumber( k )
		end
	end
	return 20
end)
