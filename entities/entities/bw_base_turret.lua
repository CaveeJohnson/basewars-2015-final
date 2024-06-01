AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"

ENT.PrintName = "Turret"
ENT.Model = "models/Combine_turrets/Floor_turret.mdl"

ENT.PowerRequired = 10
ENT.PowerMin = 1000
ENT.PowerCapacity = 2500

ENT.Drain = 35

ENT.Damage = 2
ENT.Radius = 750
ENT.ShootingDelay = 0.08
ENT.Ammo = -1
ENT.Angle = math.rad(45)
ENT.LaserColor = Color(0, 255, 0)

ENT.EyePosOffset 	= Vector(0, 0, 0)
ENT.Sounds 			= Sound("npc/turret_floor/shoot1.wav")
ENT.NoAmmoSound		= Sound("weapons/pistol/pistol_empty.wav")

ENT.PresetMaxHealth = 500

ENT.AlwaysRaidable = true

if CLIENT then return end

ENT.Spread = 15
ENT.NextShot = 0

function ENT:Init()

	self:SetModel(self.Model)

end

function ENT:SpawnBullet(target)

	if not self:IsPowered(self.PowerMin) then return end
	if self.beingPhysgunned and #self.beingPhysgunned > 0 then return end

	local Pos = target:LocalToWorld(target:OBBCenter()) + Vector(0, 0, 10)

	local tr = {}
		tr.start = self.EyePosOffset
		tr.endpos = Pos
		tr.filter = function(ent)

			if ent:IsPlayer() or ent:IsNPC() or ent:GetClass():find("prop_") then return true end

		end
	tr = util.TraceLine(tr)

	if tr.Entity == target then

		local Bullet = self:GetBulletInfo(target, Pos)

		self:FireBullets(Bullet)

		self:DrainPower(self.Drain)
		self:EmitSound(self.Sounds)

		self.Ammo = self.Ammo - 1

	end

end

function ENT:GetBulletInfo(target, pos)

	local bullet = {}
		bullet.Num = 1
		bullet.Damage = self.Damage
		bullet.Force = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Spread = Vector(self.Spread, self.Spread, 0)
		bullet.Src = self.EyePosOffset
		bullet.Dir = pos - self.EyePosOffset

	return bullet

end

local function findPlayersInCone(cone_origin, cone_direction, cone_radius_sqr, cone_angle)
	cone_direction:Normalize()
	local cos = math.cos(cone_angle)

	local result = {}
	local i = 0

	local radius = math.sqrt(cone_radius_sqr)

	for _, entity in ipairs(ents.FindInSphere(cone_origin, radius)) do
		-- local entity_class = entity:GetClass()
		if entity:IsPlayer() or entity:IsNPC() then 
			local pos = entity:GetPos()
			local dir = pos - cone_origin
			dir:Normalize()

			local dot = cone_direction:Dot(dir)

			if dot > cos then -- and cone_origin:DistToSqr(pos) <= cone_radius_sqr then
				i = i + 1
				result[i] = entity
			end
		end
	end

	return result, i
end

function ENT:ThinkFunc()

	if self.NextShot > CurTime() then return end
	self.NextShot = CurTime() + self.ShootingDelay

	if self.Ammo == 0 then

		self:EmitSound(self.NoAmmoSound)

	return end

	local Owner = BaseWars.Ents:ValidOwner(self)
	if not Owner then return end

	local Forward = self:GetForward()
	local SelfPos = self:GetPos()

	self.EyePosOffset = SelfPos + (self:GetUp() * 58 + Forward * 7 + self:GetRight() * 2)

	self.RadiusSqr = self.RadiusSqr or (self.Radius*self.Radius)
	local find, count = findPlayersInCone(self.EyePosOffset, Forward, self.RadiusSqr, self.Angle)

	local closest, dist = nil, math.huge
	for i = 1, count do
		local v = find[i]
		if not v:IsPlayer() or Owner:IsEnemy(v) then
			local d = SelfPos:DistToSqr(v:GetPos())

			if d < dist then
				closest = v
				dist = d
			end
		end
	end

	if not closest then
		return
	end

	self:SpawnBullet(closest)

end
