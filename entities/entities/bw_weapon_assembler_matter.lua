-- easylua.StartEntity("bw_weapon_assembler_matter")

AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"

ENT.PrintName = "Assembler Matter-Constructor"
ENT.Model = "models/props_combine/combine_generator01.mdl"

ENT.PowerRequired = 25000
ENT.PowerCapacity = 1e9

ENT.PresetMaxHealth = 20000

ENT.charge_points = {
	Vector(-11.292788, 21.555759, 59.700977),
}

ENT.charge_ang = Angle(0, 90, 0)

local beam_mat = Material("trails/laser")

local trace_result = {}
local trace_data = {output = trace_result}

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
		render.DrawBeam(trace_result.StartPos, trace_result.HitPos, 24, 1, 0, HSVToColor(CurTime() * 10 % 360, 1, 1))
	end
end

if CLIENT then return end -- easylua.EndEntity() end

function ENT:Init()
	self:SetModel(self.Model)
	self:SetMaterial(self.Material)
end

function ENT:ThinkFunc()
	if self.next_create and self.next_create > CurTime() then return end

	for i = 1, #self.charge_points do
		self:doTrace(i)

		local ent = trace_result.Entity
		if IsValid(ent) and ent:GetClass() == "bw_weapon_assembler" then
			local chance = math.random()
			self:EmitSound("weapons/mortar/mortar_fire1.wav")

			if chance > 0.94 then
				ent:AddLegendaryComponentCount(1)
				self:EmitSound("weapons/Irifle/irifle_fire2.wav")
			elseif chance > 0.70 then
				ent:AddRareComponentCount(math.random(1, 5))
				self:EmitSound("npc/roller/mine/rmine_shockvehicle2.wav")
			else
				ent:AddCommonComponentCount(math.random(1, 20))
				self:EmitSound("npc/roller/mine/rmine_shockvehicle1.wav")
			end
		end
	end

	self.next_create = CurTime() + math.random(60, 200)
end

-- easylua.EndEntity()
