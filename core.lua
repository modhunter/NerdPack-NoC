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

NeP.FakeUnits:Add('NOC_sck', function(debuff)
	for GUID, Obj in pairs(NeP.OM:Get('Enemy')) do
		if UnitExists(Obj.key) then
			if (NeP.DSL:Get('combat')(Obj.key) or Obj.isdummy) then
				if (NeP.DSL:Get('infront')(Obj.key) and NeP.DSL:Get('inMelee')(Obj.key)) then
					local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
					if not debuffDuration or debuffDuration - GetTime() < 1.5 then
						--print("NOC_sck: returning "..Obj.name.." ("..Obj.key.." - "..Obj.guid..' :'..time()..")");
						return Obj.key
					end
				end
			end
		end
	end
end)

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
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and InCombatLockdown() then
			--local LastCast = NeP.CombatTracker:LastCast('player')
			local _, LastCast = NeP.DSL:Get('lastgcd')('player')
			local _, _, _, _, _, _, spellID = GetSpellInfo(LastCast)
			if spellID then
				if MasterySpells[spellID] then
					-- If NeP.Engine.lastCast is in the MasterySpells list, set HitComboLastCast to this spellID
					HitComboLastCast = spellID
					--print("windwalker_sync flagging "..LastCast);
				end
			end
		end
	end
end), nil)

NeP.Library:Add('NOC', {
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

	-- for future use, call it via {"@NOC.synclast"}, at the TOP of the combat section
	-- synclast = function()
	-- 	local _, LastCast = NeP.DSL:Get('lastcast')('player')
	-- 	local _, _, _, _, _, _, spellID = GetSpellInfo(LastCast)
	-- 	if spellID then
	-- 		if MasterySpells[spellID] then
	-- 			-- If NeP.Engine.lastCast is in the MasterySpells list, set HitComboLastCast to this spellID
	-- 			HitComboLastCast = spellID
	-- 			--print("windwalker_sync flagging "..LastCast);
	-- 		end
	-- 	end
	-- 	return false
	-- end,

})
