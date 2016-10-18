NOC = {
	Version = '1.6',
	Branch = 'master',
	Interface = {
		addonColor = 'A330C9',
		Logo = ''
	},
}

function NOC.Splash()
end

function NOC.tt()
	if NeP.Unlocked and UnitAffectingCombat('player') and not NeP.DSL:Get('casting')('player', 'Fists of Fury') then
		NeP:Queue('Transcendence: Transfer', 'player')
	end
end

function NOC.ts()
	if NeP.Unlocked and UnitAffectingCombat('player') and not NeP.DSL:Get('casting')('player', 'Fists of Fury') then
		NeP:Queue('Transcendence', 'player')
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

C_Timer.NewTicker(0.1, (function()
	-- do something awesome
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
				local LastCast = NeP.CombatTracker:LastCast('player')
				local _, _, _, _, _, _, spellID = GetSpellInfo(LastCast)
				if spellID then
					if MasterySpells[spellID] then
						-- If NeP.Engine.lastCast is in the MasterySpells list, set HitComboLastCast to this spellID
						HitComboLastCast = spellID
						--print("windwalker_sync flagging "..LastCast);
					end
				end
	end
end), nil)


NeP.Library:Add('NOC', {

	AoEMissingDebuff = function(spell, debuff, range)
		--if spell == nil or range == nil then return false end
		--local spell = select(1,GetSpellInfo(spell))
		--if not IsUsableSpell(spell) then return false end
		--local enemies = NeP.OM['unitEnemie']
		--for i=1,#enemies do
		--	local Obj = enemies[i]
		--	local isDummy = NeP.DSL:Get('isDummy')(Obj.key)
		--	if Obj.distance <= range and (UnitAffectingCombat(Obj.key) or isDummy) then
		--		local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
		--		if not debuffDuration or debuffDuration - GetTime() < 1.5 then
		--			local skillType = GetSpellBookItemInfo(spell)
		--			local isUsable, notEnoughMana = IsUsableSpell(spell)
		--			if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		--				local GCD = NeP.DSL:Get('gcd')()
		--				if GetSpellCooldown(spell) <= GCD then
		--					if NeP.Protected.LineOfSight('player', Obj.key) then
		--						--print("AoEMissingDebuff: casting "..spell.." against "..Obj.name.." ("..Obj.key.." - "..time()..") - TTD="..NeP.CombatTracker.TimeToDie(Obj.key));
		--						NeP_Queue(spell, Obj.key)
		--						return true
		--					end
		--				end
		--			end
		--		end
		--	end
		--end
		return false
	end,


	hitcombo = function(spell)
		if not spell then return true end
		local _, _, _, _, _, _, spellID = GetSpellInfo(spell)
		if NeP.DSL:Get('buff')('player', 'Hit Combo') then
			-- we're using hit combo and need to check if the spell we've passed-in is in the list
			if HitComboLastCast == spellID then
				-- If the passed-spell is in the list as flagged, we need to exit false
				--print('hitcombo('..spell..') and it is was flagged ('..HitComboLastCast..'), returning false');
				return false
			end
		end
		return true
	end,

})
