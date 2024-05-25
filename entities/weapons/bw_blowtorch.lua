AddCSLuaFile()

SWEP.PrintName 				= "Blowtorch"
SWEP.Author 				= "Q2F2"
SWEP.Instructions 			= "Break peoples props during a raid"
SWEP.Purpose 				= "Destroys Props"

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= false

SWEP.ViewModelFOV 			= 65
SWEP.ViewModel 				= "models/weapons/v_irifle.mdl"
SWEP.WorldModel 			= "models/weapons/w_irifle.mdl"

SWEP.AutoSwitchTo 			= true
SWEP.AutoSwitchFrom 		= false

SWEP.Slot 					= 5
SWEP.SlotPos 				= 1

SWEP.HoldType 				= "smg"
SWEP.FiresUnderwater 		= true
SWEP.Weight 				= 20
SWEP.DrawCrosshair 			= true
SWEP.Category 				= "BaseWars"
SWEP.DrawAmmo 				= false
SWEP.Base 					= "weapon_base"

SWEP.Primary.Damage     	= 30
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Spread 		= 0.25
SWEP.Primary.NumberofShots 	= 1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Recoil 		= 0.01
SWEP.Primary.Delay 			= 0.20
SWEP.Primary.Force 			= 1

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"

SWEP.Sounds 					= {"ambient/energy/spark1.wav", "ambient/energy/spark2.wav", "ambient/energy/spark3.wav", "ambient/energy/spark4.wav", "ambient/energy/spark5.wav", "ambient/energy/spark6.wav"}
SWEP.Range					= 80

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	if not BaseWars.Raid:IsOnGoing() or (self.Owner and not self.Owner:InRaid()) then return false end

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
		filter = self.Owner
	})

	local ent = tr.Entity
	if not IsValid(ent) or ent:GetClass() ~= "prop_physics" then return end

	local Attacker = self.Owner
	local Owner = BaseWars.Ents:ValidOwner(ent)
	if not IsValid(Attacker) or not IsValid(Owner) then return end

	local RaidLogic 	= (Attacker == Owner and Owner:InRaid()) or (Owner:InFaction() and (not Attacker == Owner and Attacker.InFaction and Attacker:InFaction(Owner:GetFaction())))
	local RaidLogic2 	= Attacker ~= Owner and (not Owner:InRaid() or not (Attacker.InRaid and Attacker:InRaid()))

	if not Attacker:InRaid() or (RaidLogic or RaidLogic2) then return false end

	self:ShootEffects()
	if SERVER and IsFirstTimePredicted() then
		ent:SetHealth(ent:Health() - (ent:GetMaxHealth() * 0.1))

		if ent:Health() < 1 then
			ent:Remove()
		end

		local c = (ent:Health() / ent:GetMaxHealth()) * 255
		ent:SetColor(Color(c, c, c, 255))

		self.Owner:EmitSound(table.Random(self.Sounds), 60)
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	return false
end

local shade = Color(0, 0, 0, 140)
local trans = Color(255, 255, 255, 150)
local textc = Color(100, 150, 200, 255)
local hpbck = Color(255, 0  , 0  , 100)
local red	= Color(255, 0  , 0	 , 245)

function SWEP:DrawHUD()
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
		filter = self.Owner
	})

	local ent = tr.Entity
	if not IsValid(ent) or ent:GetClass() ~= "prop_physics" then return end

	local Pos = ent:GetPos()
	Pos.z = Pos.z + 14

	Pos = Pos:ToScreen()

	local model = ent:GetModel()
	local name = model:gsub(".+/", ""):gsub("%.mdl", ""):Trim()
	local W = BaseWars.Config.HUD.EntW
	local H = BaseWars.Config.HUD.EntH

	local oldx, oldy = Pos.x, Pos.y
	local curx, cury = Pos.x, Pos.y
	local w, h
	local Font = BaseWars.Config.HUD.EntFont
	local Font2 = BaseWars.Config.HUD.EntFont2
	local Padding = 5
	local EndPad = -Padding * 2

	curx = curx - W / 2
	cury = cury - H / 2

	surface.SetDrawColor(shade)
	surface.DrawRect(curx, cury, W, H)

	surface.SetFont(Font)
	w, h = surface.GetTextSize(name)

	draw.DrawText(name, Font, oldx - w / 2, cury, shade)
	draw.DrawText(name, Font, oldx - w / 2, cury, textc)

	if ent:Health() > 0 then
		cury = cury + H + 1

		surface.SetDrawColor(shade)
		surface.DrawRect(curx, cury, W, H)

		local MaxHealth = ent:GetMaxHealth() or 100
		local HealthStr = ent:Health() .. "/" .. MaxHealth .. " HP"

		local HPLen = W * (ent:Health() / MaxHealth)

		draw.RoundedBox(0, curx + Padding, cury + Padding, HPLen + EndPad, H + EndPad, hpbck)

		surface.SetFont(Font2)
		w, h = surface.GetTextSize(HealthStr)

		draw.DrawText(HealthStr, Font2, oldx - w / 2, cury + Padding, shade)
		draw.DrawText(HealthStr, Font2, oldx - w / 2, cury + Padding, color_white)
	end
end
