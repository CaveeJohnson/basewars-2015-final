-- easylua.StartEntity("bw_weapon_assembler_precharger")

AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"

ENT.PrintName = "Assembler Pre-Charger"
ENT.Model = "models/props_c17/substation_transformer01b.mdl"

ENT.PowerRequired = 25000
ENT.PowerCapacity = 1e9

ENT.PresetMaxHealth = 20000

ENT.charge_points = {
	Vector(36.061951,  43.864014, 2.224852),
	Vector(36.061958, -43.245605, 2.224852),
}

ENT.charge_ang = Angle(0, 0, 0)

local beam_mat = Material("trails/laser")

local trace_result = {}
local trace_data = {output = trace_result}

local color_precharge = Color(120, 180, 220)

function ENT:doTrace(i)
	trace_data.start  = self:LocalToWorld(self.charge_points[i])
	trace_data.endpos = trace_data.start + self:LocalToWorldAngles(self.charge_ang):Forward() * 512
	trace_data.filter = self

	util.TraceLine(trace_data)
end

function ENT:Draw()
	self:DrawModel()

	render.SetMaterial(beam_mat)
	for i = 1, #self.charge_points do
		self:doTrace(i)
		render.DrawBeam(trace_result.StartPos, trace_result.HitPos, 16, 1, 0, color_precharge)
	end
end

if CLIENT then return end -- easylua.EndEntity() end

function ENT:Init()
	self:SetModel(self.Model)
	self:SetMaterial(self.Material)
end

function ENT:ThinkFunc()
	for i = 1, #self.charge_points do
		self:doTrace(i)

		local ent = trace_result.Entity
		if IsValid(ent) and ent:GetClass() == "bw_weapon_assembler" then
			ent:AddPrechargeLevel(1)
		end
	end
end

-- easylua.EndEntity()
