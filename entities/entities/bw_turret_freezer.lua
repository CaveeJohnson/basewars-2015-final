AddCSLuaFile()

ENT.Base = "bw_turret_healer"
ENT.Type = "anim"
DEFINE_BASECLASS(ENT.Base)


ENT.PrintName    = "Freezing Tower"
ENT.Model        = "models/props_c17/utilityconnecter006c.mdl"
ENT.Material     = "models/player/shared/ice_player"

ENT.Range        = 300

ENT.FireDelay    = 2
ENT.ScanDelay    = 1

ENT.FreezeTime   = 5

function ENT:customTest(v)
	if not v:IsPlayer() then return false end

	local owner = self:CPPIGetOwner()
	if (owner:IsPlayer() and owner:IsEnemy(v)) then return true end

	return false
end

function ENT:hitTarget(target)

	target:RemoveDrug("steroid")
	target:ApplyDrug("Stun", 25)

	target:SetWalkSpeed(BaseWars.Config.DefaultWalk * 2.5 / ( self:GetLevel() * 2 ) )
	target:SetRunSpeed(BaseWars.Config.DefaultWalk * 2.5 / ( self:GetLevel() * 2 ) )

	timer.Create("tower_freeze_" .. tostring(target), self.FreezeTime, 1, function()
		if not IsValid(target) then return end

		target:RemoveDrug("steroid") -- bad! no buy drug

		target:SetWalkSpeed(BaseWars.Config.DefaultWalk)
		target:SetRunSpeed(BaseWars.Config.DefaultRun)

	end)

	target:EmitSound("physics/surfaces/underwater_impact_bullet3.wav", 75, 110, 0.3)
end