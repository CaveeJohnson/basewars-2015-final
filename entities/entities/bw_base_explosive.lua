AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "Generic Explosive"

ENT.Model = "models/weapons/w_c4_planted.mdl"

ENT.ExplodeTime = 20
ENT.ExplodeRadius = 200
ENT.DefuseTime = 15
ENT.ShowTimer = true
ENT.OnlyPlantWorld = false
ENT.UsePlant = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.IsRaidDevice = true
ENT.IsExplosive = true

ENT.Cluster = false
ENT.ClusterAmt = 0
ENT.ClusterClass = ""

local math_floor, math_ceil, math_max, math_min, math_random = math.floor, math.ceil, math.max, math.min, math.random

if SERVER then
	function ENT:Init() end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetUseType(CONTINUOUS_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)

		self:SetNW2Float("DefuseStart", -1)
		self.u = 0

		self:Init()
	end

	function ENT:DetonateEffects()
	end

	function ENT:OnActivated()
	end

	function ENT:StartCountdown()
		self:OnActivated()

		self:SetNW2Float("Start", CurTime())
		self.CountingDown = true

		self:SetNW2Bool("show", true)
	end

	function ENT:StopCountdown()
		self.CountingDown = false

		self:SetNW2Bool("show", false)
	end

	local beep = Sound("weapons/c4/c4_beep1.wav")
	function ENT:Beep()
		self:EmitSound(beep)
	end

	local plant = Sound("weapons/c4/c4_plant.wav")
	function ENT:Plant(ent)
		if not self.OnlyPlantWorld and IsEntity(ent) then self:SetParent(ent) end
		self:SetMoveType(MOVETYPE_NONE)
		self:EmitSound(plant)
		self:StartCountdown()

		self:SetNW2Bool("IsArmed", true)
	end

	function ENT:OnDefuse()
	end

	local defuse = Sound("weapons/c4/c4_disarm.wav")
	function ENT:Defuse()
		self:EmitSound(defuse)
		self:StopCountdown()
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self.Defused = true

		self:OnDefuse()
		self:SetNW2Bool("Defused", true)
	end

	function ENT:Explode()
		self:SetNW2Bool("show", false)

		local exp = ents.Create("env_explosion")
		local selfPos = self:GetPos()

		exp:SetKeyValue("iMagnitude", self.ExplodeRadius)
		exp:SetKeyValue("spawnflags", 64)
		exp:SetPos(selfPos)
		exp:Spawn()
		exp:Activate()
		exp:Fire("explode")
		exp.Owner = self.Owner
		exp:SetOwner(self.Owner)

		-- remove props explicitly
		local sqrRadius = self.ExplodeRadius ^ 2
		for k,v in pairs(ents.FindInSphere(selfPos, self.ExplodeRadius)) do
			if IsValid(v) and v:GetClass() == "prop_physics" then 
				local Attacker = self.Owner
				local Owner = BaseWars.Ents:ValidOwner(v)
				if IsValid(Attacker) and IsValid(Owner) then
					local RaidLogic  = (Attacker == Owner and Owner:InRaid()) or (Owner:InFaction() and (not Attacker == Owner and Attacker.InFaction and Attacker:InFaction(Owner:GetFaction())))
					local RaidLogic2 = Attacker ~= Owner and (not Owner:InRaid() or not (Attacker.InRaid and Attacker:InRaid()))
				
					if not (not Attacker:InRaid() or (RaidLogic or RaidLogic2)) then
						local dmg = self.ExplodeRadius * (1 - (selfPos:DistToSqr(v:GetPos()) / sqrRadius))
						v:SetHealth(v:Health() - dmg)

						if v:Health() < 1 then
							SafeRemoveEntity(v)
						else
							local c = (v:Health() / v:GetMaxHealth()) * 255
							v:SetColor(Color(c, c, c, 255))
						end
					end
				end
			end
		end

		self:ExplodeEffects()

		if self.Cluster then
			for i = 1, self.ClusterAmt do
				local e = ents.Create(self.ClusterClass)
					e:SetPos(self:GetPos() + Vector(math_random(-90, 90), math_random(-90, 90), 32))
				e:Spawn()
				e:Activate()

				e.Owner = self.Owner

				e:SetAngles(AngleRand())
				local p = e:GetPhysicsObject()
				if IsValid(p) then p:AddVelocity(Vector(math_random(-7000, 7000), math_random(-7000, 7000), 4000)) end

				constraint.NoCollide(e, self, 0, 0)
			end
		end

		SafeRemoveEntity(self)
	end

	function ENT:ExplodeEffects()
		local ef = EffectData()
		ef:SetOrigin(self:GetPos())

		util.Effect("Explosion", ef)
		util.Effect("Explosion", ef)
		self:EmitSound("weapons/c4/c4_explode1.wav")
		self:EmitSound("weapons/hegrenade/explode5.wav")

		self:DetonateEffects()
	end

	function ENT:StartUse()
		self:SetNW2Float("DefuseStart", CurTime())
	end

	function ENT:EndUse()
		self:SetNW2Float("DefuseStart", -1)
	end

	function ENT:FadeAway()
		local al = self:GetColor().a
		al = al - 5
		if al <= 0 then
			SafeRemoveEntity(self)
		return end

		self:SetColor(ColorAlpha(self:GetColor(), al))
	end

	function ENT:ThinkFunc() end

	function ENT:Think()
		self:NextThink(CurTime() + 0.01)
		self:ThinkFunc()

		local function o()
			if self.Defused then
				self:FadeAway()
				self:NextThink(CurTime() + 0.005)
			return true end

			if not self.CountingDown then return end

			local f = self.ExplodeTime - (CurTime() - self:GetNW2Float("Start"))

			if f <= 0 then
				self:Explode()
			return end

			self:SetNW2Int("counter", math_ceil(f))

			local wde = self.WasDefusing
			if IsValid(wde) then
				if wde:GetEyeTrace().Entity ~= self then
					self.WasDefusing = nil
					self:EndUse()
				else
					if not wde:KeyDown(IN_USE) then
						if self.used then
							self.used = nil
							self:EndUse()
						end
					else
						if not self.used then
							self.used = true
							self:StartUse()
						end
					end
				end
			else
				if self.used then
					self.used = nil
					self:EndUse()
				end
			end

			local defs = self:GetNW2Float("DefuseStart", -1)
			local d = self:GetNW2Bool("BW_Defuser") and 0.45 or 1
			if defs > 0 then
				local def = math.floor((self.DefuseTime * d) - (CurTime() - defs) + 0.25)
				if def <= 0 then
					self:Defuse()
				return end
			end

			if f <= 5 and (math_floor(f * 100) % 4) == 0 then
				self:Beep()
			else
				if self.last_beep then
					if math_floor(f) ~= self.last_beep then
						self:Beep()
						self.last_beep = math_floor(f)
					end
				else
					self:Beep()
					self.last_beep = math_floor(f)
				end
			end
		end
		o()
		return true
	end

	function ENT:Use(activator, caller, ut, value)
		if self.NextUse and self.NextUse > CurTime() then return end

		if not self:GetNW2Bool("IsArmed") then
			if self.UsePlant then
				self.Owner = activator
				self:Plant()

				self.NextUse = CurTime() + 1
			end
		return end

		if not self.WasDefusing then
			self.WasDefusing = activator
			self:SetNW2Bool("BW_Defuser", activator:GetNW2Bool("BW_Defuser"))
		end
	end
else
	function ENT:GetCounter()
		return self:GetNW2Int("counter", 0)
	end

	local white = Color(255, 255, 255)
	local grey1 = Color(170, 170, 170)
	local grey2 = Color(100, 100, 100)

	function ENT:Draw()
		self:DrawModel()
		if not (self:GetNW2Bool("IsArmed") and self:GetNW2Bool("show")) then return end

		local pos = self:GetPos()
		if pos:DistToSqr(LocalPlayer():GetPos()) > 1440000 then return end

		local t = pos:ToScreen()
		if not t.visible then return end

		local x, y = t.x, t.y

		cam.Start2D()
			if self:GetNW2Bool("Defused") then
				draw.SimpleText("DEFUSED", "ChatFont", x, y, white, TEXT_ALIGN_CENTER)
			else
				local counter = self:GetCounter() or 0

				local sec, min = counter % 60, math_floor(counter / 60)
				sec = sec < 10 and "0" .. sec or tostring(sec)
				min = min < 10 and "0" .. min or tostring(min)

				draw.SimpleText(min .. ":" .. sec, "ChatFont", x, y, white, TEXT_ALIGN_CENTER)

				local d = self:GetNW2Bool("BW_Defuser") and 0.45 or 1
				local defuse_start = self:GetNW2Int("DefuseStart", -1)
				if defuse_start >= 0 then
					local prog = math_min((CurTime() - defuse_start) / (self.DefuseTime * d), 1)
					local w, h = ScrW() / 12, 24
					local wprog = math_max(w * prog, 4)

					surface.SetDrawColor(grey2)
					surface.DrawRect(x - w / 2, y + 32, w, h)
					surface.SetDrawColor(grey1)
					surface.DrawRect(x - w / 2 + 2, y + 34, wprog - 4, h - 4)
					draw.SimpleText(BaseWars.LANG.Defusing, "ChatFont", x, y + 34, white, TEXT_ALIGN_CENTER)
				end
			end
		cam.End2D()
	end
end
