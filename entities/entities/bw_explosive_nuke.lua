AddCSLuaFile()

ENT.Base = "bw_base_explosive"
ENT.PrintName = "Nuke"

ENT.Model = "models/props_phx/mk-82.mdl"

ENT.ExplodeTime = 165
ENT.ExplodeRadius = 700
ENT.DefuseTime = 25
ENT.ShowTimer = true
ENT.OnlyPlantWorld = true
ENT.UsePlant = true

ENT.NukeAlarm = Sound("ambient/alarms/alarm_citizen_loop1.wav")

function ENT:OnActivated()
	self.Sound = CreateSound(self, self.NukeAlarm)
	if self.Sound then self.Sound:Play() end
end

function ENT:NukeEffects()
	local owner = self.Owner

	for _, ply in pairs(ents.FindInSphere(self:GetPos(), self.ExplodeRadius)) do
		if not IsValid(ply) then continue end
		if not ply:IsPlayer() then
			ply:TakeDamage(1300, owner, owner) -- maxed prop = ~1200
		continue end
		if not ply:Alive() then continue end
		if ply:GetNWBool("Unrestricted") then continue end

		ply:ScreenFade(SCREENFADE.OUT, color_white, 0.2, 2)
		ply:EmitSound("ambient/explosions/explode_5.wav", 140, 50, 1)
		ply:EmitSound("ambient/explosions/explode_5.wav", 140, 50, 1)
		ply:EmitSound("ambient/explosions/explode_4.wav", 140, 50, 1)
		ply:SetDSP(37)

		timer.Simple(0.4, function()
			if IsValid(ply) then
				ply:TakeDamage(2^12, owner, owner)
			end
		end)
	end
end

function ENT:OnDefuse()
	if self.Sound then self.Sound:Stop() end
end

function ENT:DetonateEffects()
	if self.Sound then self.Sound:Stop() end

	local pos = self:GetPos()
	ParticleEffect("explosion_huge_b", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_c", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_c", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_g", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_f", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("hightower_explosion", pos + Vector(0, 0, 10), Angle())
	ParticleEffect("mvm_hatch_destroy", pos + Vector(0, 0, 32), Angle())

	self:NukeEffects()
end

local base_color = Color(255, 0, 0)

local function draw_double_sphere(v, mult, alpha)
	alpha = math.max(0, alpha - (math.sin(CurTime()) + 1) * alpha) + 10
	base_color.a = alpha
	render.DrawSphere(v:GetPos(),  ent.ExplodeRadius * mult, 25, 25, base_color)
	base_color.a = alpha + 30
	render.DrawSphere(v:GetPos(), -ent.ExplodeRadius * mult, 25, 25, base_color)
end

function ENT.PostDrawTranslucentRenderables(d, s)
	if s then return end
	if not LocalPlayer():InRaid() then return end

	for _, v in ipairs(ents.FindByClass("bw_explode_nuke")) do
		render.SetColorMaterial()
		draw_double_sphere(v, 0.25, 20)
		draw_double_sphere(v, 1.00, 00)
	end
end
hook.Add("PostDrawTranslucentRenderables", "bw_explode_nuke", ENT.PostDrawTranslucentRenderables)
