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

	if target:GetPrestige( "perk", "speedperk" ) >= 2 then

		target:SetWalkSpeed( BaseWars.Config.DefaultWalk + BaseWars.Config.Perks["speedperk"]["WalkAdditions"] * target:GetPrestige( "perk", "speedperk" ) / ( self:GetLevel() * 2 ) )
		target:SetRunSpeed( BaseWars.Config.DefaultWalk + BaseWars.Config.Perks["speedperk"]["WalkAdditions"] * target:GetPrestige( "perk", "speedperk" ) / ( self:GetLevel() * 2 ) )

	else

		target:SetWalkSpeed(BaseWars.Config.DefaultWalk * 2.5 / ( self:GetLevel() * 2 ) )
		target:SetRunSpeed(BaseWars.Config.DefaultWalk * 2.5 / ( self:GetLevel() * 2 ) )

	end

	timer.Create("tower_freeze_" .. tostring(target), self.FreezeTime, 1, function()
		if not IsValid(target) then return end

		target:RemoveDrug("steroid") -- bad! no buy drug

		if target:GetPrestige( "perk", "speedperk" ) >= 1 then

			target:SetWalkSpeed( BaseWars.Config.DefaultWalk + BaseWars.Config.Perks["speedperk"]["WalkAdditions"] * target:GetPrestige( "perk", "speedperk" ) )
			target:SetRunSpeed( BaseWars.Config.DefaultRun + BaseWars.Config.Perks["speedperk"]["RunAdditions"] * target:GetPrestige( "perk", "speedperk" ) )

		else

			target:SetWalkSpeed(BaseWars.Config.DefaultWalk)
			target:SetRunSpeed(BaseWars.Config.DefaultRun)

		end

	end)

	target:EmitSound("physics/surfaces/underwater_impact_bullet3.wav", 75, 110, 0.3)
end