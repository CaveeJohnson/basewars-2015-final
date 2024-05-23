AddCSLuaFile()

ENT.Base = "bw_turret_healer"
ENT.Type = "anim"
DEFINE_BASECLASS(ENT.Base)


ENT.PrintName    = "Acid Tower"
ENT.Model        = "models/props_c17/utilityconnecter006c.mdl"
ENT.Material     = "phoenix_storms/wire/pcb_green"

ENT.Range        = 300

ENT.FireDelay    = 2
ENT.ScanDelay    = 1

ENT.PoisonDuration  = 13

function ENT:customTest(v)
	if not v:IsPlayer() then return false end

	local owner = self:CPPIGetOwner()
	if (owner:IsPlayer() and owner:IsEnemy(v)) then return true end

	return false
end

function ENT:hitTarget(target)
	target:ApplyDrug("Poison", self.PoisonDuration, self:CPPIGetOwner(), self:CPPIGetOwner())
	target:EmitSound("ambient/water/water_splash3.wav", 75, 120, 0.5)
end