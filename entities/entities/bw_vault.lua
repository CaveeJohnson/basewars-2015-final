AddCSLuaFile()

ENT.Base            = "bw_base_electronics"
ENT.Type            = "anim"

ENT.PrintName       = "Money Vault"
ENT.Author          = "Q2F2"

ENT.Model           = "models/props_c17/furnituredrawer001a.mdl"
ENT.Sound           = Sound("HL1/fvox/blip.wav")

ENT.Radius          = 600
ENT.PowerRequired   = 15

ENT.PowerCapacity   = 25000
ENT.PresetMaxHealth = 1000

ENT.CollectInterval = 10 -- also interest interval for sake of simplicity
ENT.InterestRate    = 0.001

ENT.CollectSound    = Sound("mvm/mvm_money_pickup.wav")

function ENT:TakeMoneyFrom(printer)
	local money = printer:GetMoney()
	printer:TakeMoney(money)

	self.money = self.money + money
end

function ENT:ThinkFunc()
	if self.nextCollect and self.nextCollect > CurTime() then return end
	self.nextCollect = CurTime() + self.CollectInterval

	self.money = self.money and math.floor(self.money * (1 + self.InterestRate)) or 0

	local Ents = ents.FindInSphere(self:GetPos(), self.Radius)

	self:EmitSound(self.Sound, 100, 60)

	local owner = self:CPPIGetOwner()
	if not IsValid(owner) then return end

	for _, v in ipairs(Ents) do
		if not BaseWars.Ents:Valid(v) then continue end
		if v:IsPlayer() then continue end
		if not v.TakeMoney then continue end
		if v:CPPIGetOwner() ~= owner then continue end
		
		self:TakeMoneyFrom(v)
	end

	self.CurrentValue = self.money
	self:SetNW2String("money", tostring(self.money))
end

function ENT:CheckUsable()
	return self.money and self.money > 0
end

function ENT:UseFunc(activator, caller, usetype, value)
	if activator:IsPlayer() and caller:IsPlayer() and self.money > 0 then
		self:PlayerTakeMoney(activator)
	end
end

function ENT:PlayerTakeMoney(ply)
	local money = self.money
	local Res, Msg = hook.Run("BaseWars_PlayerCanEmptyPrinter", ply, self, money)

	if Res == false then
		if Msg then
			ply:Notify(Msg, BASEWARS_NOTIFICATION_ERROR)
		end
	return end

	self:EmitSound(self.CollectSound)

	ply:GiveMoney(money)
	hook.Run("BaseWars_PlayerEmptyPrinter", ply, self, money)

	self.CurrentValue = 0
	self.money = 0
	self:SetNW2String("money", "0")
end

if SERVER then return end

function ENT:GetMoney()
	local money = self:GetNW2String("money")
	return tonumber(money) or 0
end

do
	local color1, color2 = Color(255, 255, 21), Color(128, 255, 0)
	local color3 = Color(255, 0, 0)

	LookEnt:RegisterEnt("bw_vault", input.LookupBinding("+use"), function(aimEnt)
		return BaseWars.LANG.Collect, BaseWars.LANG.Money
	end,
	function(aimEnt)
		return aimEnt:GetMoney() > 0 and color1 or color3, color2
	end)
end

surface.CreateFont("vault_font", {
	font = "Roboto",
	size = 120,
	weight = 800,
})

surface.CreateFont("vault_font2", {
	font = "Roboto",
	size = 40,
	weight = 800,
})

ENT.FontColor = Color(255, 255, 255)
ENT.FontColor2 = Color(200, 255, 200)

function ENT:DrawDisplay(pos, ang, scale)
	local w, h = 216 * 2, 136 * 2

	local money = self:GetMoney()
	local text = string.format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(money))
	draw.DrawText(text, "vault_font", w / 2, h / 2, self.FontColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local interest = string.format("Interest: %s%% | Next Gain: %s", self.InterestRate * 100, string.format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(math.floor(money * self.InterestRate))))
	draw.DrawText(interest, "vault_font2", w / 2, h / 2 + 120, self.FontColor2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function ENT:Calc3D2DParams()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	pos = pos + ang:Up() * 13.09
	pos = pos + ang:Forward() * 12.55
	pos = pos + ang:Right() * 10.82

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	return pos, ang, 0.1 / 2
end

function ENT:Draw()
	self:DrawModel()

	if CLIENT then
		local pos, ang, scale = self:Calc3D2DParams()

		cam.Start3D2D(pos, ang, scale)
			pcall(self.DrawDisplay, self, pos, ang, scale)
		cam.End3D2D()
	end
end
