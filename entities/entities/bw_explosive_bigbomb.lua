AddCSLuaFile()

ENT.Base = "bw_base_explosive"
ENT.PrintName = "Big Bomb"

ENT.Model = "models/props_c17/oildrum001.mdl"

ENT.ExplodeTime = 80
ENT.ExplodeRadius = 850
ENT.DefuseTime = 25
ENT.ShowTimer = true
ENT.OnlyPlantWorld = true
ENT.UsePlant = true

function ENT:DetonateEffects()
	local pos = self:GetPos()
	ParticleEffect("explosion_huge_b", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_c", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_c", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_g", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("explosion_huge_f", pos + Vector(0, 0, 32), Angle())
	ParticleEffect("hightower_explosion", pos + Vector(0, 0, 32), Angle())
end

ENT.Cluster = true
ENT.ClusterAmt = 7
ENT.ClusterClass = "bw_explosive_bigbomb_fragment"

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

	for _, v in ipairs(ents.FindByClass("bw_explode_bigbomb")) do
		render.SetColorMaterial()
		draw_double_sphere(v, 0.25, 20)
		draw_double_sphere(v, 1.00, 00)
	end
end
hook.Add("PostDrawTranslucentRenderables", "bw_explode_bigbomb", ENT.PostDrawTranslucentRenderables)
