MODULE.Name 	= "PlayerLevel"
MODULE.Author 	= "Q2F2 and Trixter"

local tag = "BaseWars.PlayerLevel"
local PLAYER = debug.getregistry().Player

local function isPlayer(ply)

	return (IsValid(ply) and ply:IsPlayer())
	
end

function MODULE:GetLevel(ply)

	return tonumber(ply:GetNWString(tag .. ".Level")) or 0
	
end
PLAYER.GetLevel = Curry(MODULE.GetLevel)

function MODULE:GetXP(ply)

	return tonumber(ply:GetNWString(tag .. ".XP")) or 0
	
end
PLAYER.GetXP = Curry(MODULE.GetXP)

function MODULE:GetXPNextLevel(ply)
	local n = ply:GetLevel()
	return (n + 1) * 250
end
PLAYER.GetXPNextLevel = Curry(MODULE.GetXPNextLevel)

function MODULE:HasLevel(ply, level)
	local plylevel = ply:GetLevel()
	return (plylevel >= level)
end
PLAYER.HasLevel = Curry(MODULE.HasLevel)

if SERVER then

	function MODULE:Init(ply)
	
		BaseWars.MySQL.InitPlayer(ply, "xp", "0")
		BaseWars.MySQL.InitPlayer(ply, "level", "1")
		
	end
	PLAYER.InitLevel = Curry(MODULE.Init)

	for k, v in next, player.GetAll() do
		
		MODULE:Init(v)
	
	end

	function MODULE:Save(ply)
		
		BaseWars.MySQL.SaveVar(ply, "level", amount or self:GetLevel(ply))
		BaseWars.MySQL.SaveVar(ply, "xp", amount or self:GetXP(ply))
		
	end
	PLAYER.SaveLevels = Curry(MODULE.Save)
	
	function MODULE:Load(ply)
		
		self:Init(ply)
		
		BaseWars.MySQL.LoadVar(ply, "level", function(ply, var, val)
			if not IsValid(ply) then return end
			
			local val = tostring(val)
			ply:SetNWString(tag .. ".Level", val)
			ply.level = val
		end)
	
		BaseWars.MySQL.LoadVar(ply, "xp", function(ply, var, val)
			if not IsValid(ply) then return end
			
			local val = tostring(val)
			ply:SetNWString(tag .. ".XP", val)
			ply.xp = val
		end)
	
	end
	PLAYER.LoadLevels = Curry(MODULE.Load)

	function MODULE:CheckLevels(ply)

		local neededxp = ply:GetXPNextLevel()
		local xp = ply:GetXP()
		local starting = xp

		local addedLevels = 0

		while xp >= neededxp do
			if ply:GetLevel() == BaseWars.Config.LevelSettings.MaxLevel then
				ply:SetLevel( BaseWars.Config.LevelSettings.MaxLevel )
				ply:SetXP( 0 )
				return
			end
		
			addedlevels = addedlevels + 1
			xp = xp - neededxp
			xp = ply:GetXP()
		end
		if xp ~= starting then
			ply:AddLevel(addedlevels)
			ply:SetXP(xp)
		end

	end
	
	function MODULE:Set(ply, amount)

		if not isnumber(amount) or amount < 0 then amount = 0 end
		if amount > BaseWars.Config.LevelSettings.MaxLevel then amount = BaseWars.Config.LevelSettings.MaxLevel end
		
		amount = math.Round(amount)
		
		ply.level = amount
		self:Save(ply)
		
		ply:SetNWString(tag .. ".Level", tostring(amount))
		
	end
	PLAYER.SetLevel = Curry(MODULE.Set)

	function MODULE:AddLevel(ply, amount)
		
		local Value = ply:GetLevel()
		
		ply:SetLevel(Value + amount)
		
	end
	PLAYER.AddLevel = Curry(MODULE.AddLevel)
	
	function MODULE:SetXP(ply, amount)

		if not isnumber(amount) or amount < 0 then amount = 0 end
		
		amount = math.Round(amount)
		
		ply.xp = amount
		self:Save(ply)
		
		ply:SetNWString(tag .. ".XP", tostring(amount))
		
		self:CheckLevels( ply )
		
	end
	PLAYER.SetXP = Curry(MODULE.SetXP)

	function MODULE:AddXP(ply, amount)
		
		local Value = ply:GetXP()
		
		ply:SetXP(Value + amount)
		
	end
	PLAYER.AddXP = Curry(MODULE.AddXP)
	
	hook.Add("LoadData", tag .. ".Load", Curry(MODULE.Load))
	hook.Add("PlayerDisconnected", tag .. ".Save", Curry(MODULE.Save))
	
end