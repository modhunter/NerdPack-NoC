NOC = {
	Version = '1.5',
	Branch = 'master',
	Interface = {
		addonColor = 'A330C9',
		Logo = NeP.Interface.Logo -- Temp until i get a logo
	},
}

--NeP.Core.DebugMode = true

local Parse = NeP.DSL.parse
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


-- function NOC.getGCD()
-- 	local CDTime, CDValue = 0, 0;
--   CDTime, CDValue = GetSpellCooldown(61304);
--   if CDTime == 0 or module.GetTime()-module.GetLatency() >= CDTime+CDValue then
--     return true;
--   else
--     return false;
--   end
-- end


NeP.library.register('NOC', {

-- Place custom functions here???

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
