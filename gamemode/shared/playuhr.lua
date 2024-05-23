PlayTime = PlayTime or {}
local tag = "BaseWars.Time"

local PLAYER = debug.getregistry().Player

if SERVER then
	PlayTime.LastThink = CurTime() + 1

	function PlayTime:Init(ply) -- init
		BaseWars.MySQL.InitPlayer(ply, "time", "0")
	end

	function PlayTime:LoadGlobalTimeFile(ply) -- load
		self:Init(ply)

		BaseWars.MySQL.LoadVar(ply, "time", function(ply, var, val)
			if not IsValid(ply) then return end

			ply:SetNWString(tag, tostring(val))
		end)
	end

	function PlayTime:SetGlobalTimeFile(ply, time) -- save
		BaseWars.MySQL.SaveVar(ply, "time", time or "0", function(ply, var, val)
			ply:SetNWString(tag, tostring(val))
		end)
	end

	hook.Add("Initialize", "PlayTime.Initialize", function()
		PlayTime.LastThink = CurTime() + 1	--Not needed? Don't know
	end)

	hook.Add("Think", "PlayTime.Think", function()
		if not (CurTime() > PlayTime.LastThink) then return end
		PlayTime.LastThink = CurTime() + 1

		for _, ply in next, player.GetAll() do
			ply:SetNW2String("SessionTime", tostring(ply:GetSessionTime()))
			ply:SetNW2String("GlobalTime", tostring(ply:GetPlayTime()))
		end
	end)

	hook.Add("PlayerInitialSpawn", "PlayTime.Connect", function(ply)
		ply.JoinTime = CurTime()
	end)

	hook.Add("LoadData", "PlayTime.Connect", function(ply)
		PlayTime:Init(ply)
		PlayTime:LoadGlobalTimeFile(ply)
	end)

	hook.Add("PlayerDisconnected", "PlayTime.Disconnect", function(ply)
		PlayTime:SetGlobalTimeFile(ply, (tonumber(ply:GetNWString(tag)) or 0) + ply:GetSessionTime())
	end)

	hook.Add("ShutDown", "PlayTime.ShutDown", function()
		for _, ply, next in pairs( player.GetAll() ) do
			PlayTime:SetGlobalTimeFile(ply, (tonumber(ply:GetNWString(tag)) or 0) + ply:GetSessionTime())
		end
	end)
end

function PLAYER:GetPlayTime()
	if SERVER then
		return math.Round((tonumber(self:GetNWString(tag)) or 0) + self:GetSessionTime())
	else
		return tonumber(self:GetNW2String("GlobalTime", "0")) or 0
	end
end

function PLAYER:GetPlayTimeTable()
	local tbl = {}
	local time = self:GetPlayTime() or 0

	tbl.h = math.floor(time / 60 / 60)
	tbl.m = math.floor(time / 60) % 60
	tbl.s = math.floor(time) % 60

	return tbl
end

function PLAYER:GetSessionTime()
	if SERVER then
		self.JoinTime = self.JoinTime or CurTime()
		return math.Round(CurTime() - self.JoinTime)
	else
		return tonumber(self:GetNW2String("SessionTime", "0"))
	end
end

function PLAYER:GetSessionTable()
	local tbl = {}
	local time = self:GetSessionTime() or 0

	tbl.h = math.floor(time / 60 / 60)
	tbl.m = math.floor(time / 60) % 60
	tbl.s = math.floor(time) % 60

	return tbl
end
