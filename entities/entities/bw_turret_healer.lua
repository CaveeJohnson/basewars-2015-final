AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"
DEFINE_BASECLASS(ENT.Base)


ENT.PrintName    = "Healing Tower"
ENT.Model        = "models/props_c17/utilityconnecter006c.mdl"
ENT.Material     = "phoenix_storms/wire/pcb_red"

--[[game.AddParticles("particles/item_fx.pcf")
game.AddParticles("particles/item_fx_dx80.pcf")
ENT.Particle     = "healthgained_red"]]

ENT.ShootOffset  = Vector(0, 0, 25)
ENT.HealAmount   = 2
ENT.Range        = 300
ENT.SoundData    = {Sound("ambient/energy/weld1.wav"), 75, 150, 0.4}
ENT.MaxLevel     = 4
ENT.IsPrinter    = true
ENT.UpgradeSound = Sound("replay/rendercomplete.wav")
ENT.PresetMaxHealth = 1000

ENT.FireDelay   = 1 / 3
ENT.ScanDelay   = 1 / 2

function ENT:customTest(v)

	if not IsValid( v ) then return false end
	if not (v:GetMaxHealth() > 0 and v:Health() < v:GetMaxHealth()) then return false end

	local owner = self:CPPIGetOwner()
	if IsValid( owner ) and IsValid( v ) and owner:IsPlayer() and v:IsPlayer() and owner:IsEnemy(v) then return false end

	return true
end

function ENT:hitTarget(target)
	target:SetHealth(math.min(target:Health() + self.HealAmount, target:GetMaxHealth()))
	target:EmitSound("items/smallmedkit1.wav", 75, 110, 0.2)
end

function ENT:getUpgradeCost(lvl)
	return tonumber( self:GetUpgradeCost() * 40 * lvl )
end


ENT.PowerRequired = 10
ENT.PowerMin = 500
ENT.PowerCapacity = 2500
ENT.IsAbleToSetRange = true

ENT.Drain = 35

ENT.nextShot    = -1
ENT.nextScan    = -1
ENT.entList     = {}
ENT.n_entList   = 0

function ENT:testTarget(v)
	local tr = {}
		tr.start  = self:LocalToWorld(self.ShootOffset)
		tr.endpos = v:LocalToWorld(v:OBBCenter())
	tr = util.TraceLine(tr)

	return IsValid(tr.Entity) and not tr.HitWorld
end

function ENT:doEffect(target)
	local effectdata = EffectData()
		effectdata:SetOrigin(target:LocalToWorld(target:OBBCenter()))
		effectdata:SetStart(self:LocalToWorld(self.ShootOffset))
		effectdata:SetAttachment(0)
		effectdata:SetEntity(self)
	util.Effect("ToolTracer", effectdata)

	self:EmitSound(unpack(self.SoundData))
end

function ENT:fireAt(target)
	if IsValid(target) and self:testTarget(target) then
		if target ~= self then
			self:doEffect(target)
		end
		self:hitTarget(target)
		self:DrainPower(self.Drain)
	end
end

function ENT:ThinkFunc()
	if CLIENT then return end
	local ct = CurTime()

	if self.nextScan <= ct then
		self.nextScan = ct + self.ScanDelay

		local entList   = {}
		local n_entList = 0

		if self:GetRadius() >= 1 then

			self.Range = self:GetRadius()

		else

			self:SetRadius( self.Range )

		end

		for _, v in ipairs(ents.FindInSphere(self:GetPos(), self.Range)) do

			if IsValid( v ) and self:customTest(v) and self:testTarget(v) then
				n_entList = n_entList + 1
				entList[n_entList] = v
			end

		end

		self.entList   = entList
		self.n_entList = n_entList
	end

	if self.nextShot > ct then return end
	self.nextShot = ct + self.FireDelay

	local amt = math.max(1, self:GetLevel())
	if amt == 1 then
		local target = self.entList[math.random(1, self.n_entList)]
		self:fireAt(target)
	else
		local targs = table.Copy(self.entList)

		local total = self.n_entList
		local max = math.min(total, amt)

		for n = 0, max - 1 do
			self:fireAt(table.remove(targs, math.random(1, total - n))) -- remove compacts indexs down so we have total - n indexs
		end
	end
end

do
	function ENT:StableNetwork()
		self:NetworkVar("Int", 4, "Level")
		self:NetworkVar("String", 2, "UpgradeCost")

		self._SetUpgradeCost = self._SetUpgradeCost or self.SetUpgradeCost
		function self:SetUpgradeCost(val)
			self:_SetUpgradeCost(tostring(val))
		end
	end

	function ENT:Upgrade(ply, supress)
		local lvl = self:GetLevel()
		local calcM = self:getUpgradeCost(lvl)

		if ply then
			local plyM = ply:GetMoney()

			if plyM < calcM then
				if not supress then ply:Notify(BaseWars.LANG.UpgradeNoMoney, BASEWARS_NOTIFICATION_ERROR) end
			return false end

			if lvl >= self.MaxLevel then
				if not supress then ply:Notify(BaseWars.LANG.UpgradeMaxLevel, BASEWARS_NOTIFICATION_ERROR) end
			return false end

			ply:TakeMoney(calcM)
		end

		self.CurrentValue = (self.CurrentValue or 0) + calcM

		self:SetLevel(lvl + 1)
		self:EmitSound(self.UpgradeSound)

		return true
	end

	function ENT:Init()
		self:SetLevel(1)
		self:SetMaterial(self.Material)

		if self:GetRadius() >= 1 then

			self.Range = self:GetRadius()

		else

			self:SetRadius( self.Range )

		end

	end
end

if CLIENT then
	surface.CreateFont("bw_towerturret_big", {
		font = "Roboto",
		size = 32,
		weight = 800,
	})

	surface.CreateFont("bw_towerturret_small", {
		font = "Roboto",
		size = 24,
		weight = 800,
	})

	function ENT:DrawDisplay(pos, ang, scale)
		local lvl = self:GetLevel()

		local upg
		if self:GetLevel() >= self.MaxLevel then
			upg = BaseWars.LANG.MaxLevel
		else
			upg = string.format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(self:getUpgradeCost(lvl)))
		end

		draw.SimpleTextOutlined(string.format("Level %s %s", lvl, self.PrintName), "bw_towerturret_big", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined(string.format("Upgrade: %s", upg), "bw_towerturret_small", 0, 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	end

	local offset = Vector(0, 0, 5)
	function ENT:Calc3D2DParams()
		local render_pos = self:LocalToWorld(self.ShootOffset + offset)

		local render_ang = Angle()
		render_ang.p = 0
		render_ang.y = (render_pos - EyePos()):Angle().y
		render_ang.r = 0
		render_ang:RotateAroundAxis(render_ang:Up(), -90)
		render_ang:RotateAroundAxis(render_ang:Forward(), 90)

		return render_pos, render_ang, 0.1 / 2
	end

	function ENT:Draw()
		self:DrawModel()

		local pos, ang, scale = self:Calc3D2DParams()

		cam.Start3D2D(pos, ang, scale)
			pcall(self.DrawDisplay, self, pos, ang, scale)
		cam.End3D2D()
	end

	--[[function ENT:Initialize()
		BaseClass.Initialize(self)
		ParticleEffectAttach(self.Particle, PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end]]
end