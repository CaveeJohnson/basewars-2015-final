--☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣
--HIGHLY TOXIC
--HANDLE WITH CARE
--WEAR BIOHAZARD PROTECTION
--☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣☣


--local ENT = {}
--ENT.ClassName = "bw_bank_exper"


AddCSLuaFile()

ENT.Base            = "bw_base_electronics"
ENT.PrintName       = "Cash Cab"

ENT.Model           = "models/props/de_nuke/nuclearcontainerboxclosed.mdl"
ENT.Color           = Color(0,0,0,255)
ENT.PowerCapacity   = 100000
ENT.Material        = "models/props/cs_assault/metal_stairs1"
ENT.MaxStorage      = 1500000
ENT.IsVault         = true
ENT.IsPrinter       = false

ENT.Sound =  "mvm/mvm_money_pickup.wav"

ENT.ShieldMax = 1500
ENT.ShieldRate = 2

local UpgradeCost = {500000, 2500000, 12500000, 500000000, 0}

function ENT:StableNetwork()
	self:NetworkVar("Float", 2, "Money")
	self:NetworkVar("Int", 3, "Upgrades")
	self:NetworkVar("Int", 4, "UpgradeCost")
	self:NetworkVar("Float", 5, "Rate")
	self:NetworkVar("Int", 6, "Shield")
end

function ENT:GetUsable()
	return true
end

function ENT:Init()

	self:SetRenderMode(RENDERMODE_TRANSALPHA)	
	self:SetMaterial(self.Material)

	self.Time=CurTime()
	self.Delay = 5.5

	self.Radius = 250

	self.MoneyStored = 0
	self.CurrentValue = 1
	self:SetUpgradeCost(UpgradeCost[1])
	self.UpgradeValue = 0

	self:SetShield(0)


end

if SERVER then

	function ENT:ThinkFunc()

		

		if self.Time + self.Delay > CurTime() then return end

		if self:GetPower() < 500 then return end

		local owner=self:CPPIGetOwner()

		local Upgrades=self:GetUpgrades()

		local oldMoney = self:GetMoney()

		if not owner:InRaid() then 

			if Upgrades >= 4 then 
				self:SetShield(math.min(self:GetShield() + self.ShieldRate, self.ShieldMax))
			end

		end

		for k,v in pairs(ents.FindInSphere(self:GetPos(), self.Radius)) do

			if not v.IsPrinter then continue end

			if v:CPPIGetOwner() == owner then 

				v.Vault = self
				self:SetMoney(self:GetMoney() + v:GetMoney())
				v:SetMoney(0)

				self:DrainPower( math.min(math.sqrt(v:GetMoney()), 15000) )	

				if Upgrades >= 1 then
					if v:GetPaper() + 5 <= v.MaxPaper then 
						v:SetPaper(v:GetPaper() + 5)
					end
				end

				if owner:InRaid() and Upgrades == 4 and not self.Exhausted and v.SetDisabled then 

					v:SetDisabled(true)

				end

				if (not owner:InRaid() or self.Exhausted) and v.SetDisabled then 
					v:SetDisabled(false) 
				end

			end

		end

		local newMoney = self:GetMoney()

		self:SetRate( math.floor( (newMoney - oldMoney) / self.Delay ) )

		if Upgrades >= 2 then
			self.CurrentValue = (self.UpgradeValue or 0) + self:GetMoney() * 1.4
		end
		
		self.Time=CurTime()

	end


	function ENT:TakeVaultDamage(dmg)
		if self.Exhausted then return end 

		if self:GetShield() - dmg < 1 then 
			self:SetShield(0)
			self.Exhausted = true 
		return end

		self:SetShield(self:GetShield() - dmg)
		
		
	end



	function ENT:CollectMoney(ply)
		if self:GetMoney() <= 0 then return end

		hook.Run("BaseWars_PlayerEmptyPrinter", ply, self, self:GetMoney())

		ply:GiveMoney(self:GetMoney())
		self.CurrentValue = self.UpgradeValue
		self:SetMoney(0)
		ply:EmitSound(self.Sound or "")
	end
		
	function ENT:Use(act, call)
		if not act:IsPlayer() or not call:IsPlayer() then return end
		if self:CPPIGetOwner() ~= act then return end
		self:CollectMoney(act)
	end

	function ENT:Upgrade(ply)
		if not ply:IsPlayer() then return end
		if ply:GetMoney() < self:GetUpgradeCost() then ply:Notify(BaseWars.LANG.UpgradeNoMoney, BASEWARS_NOTIFICATION_ERROR) return end
		if self:GetUpgrades() + 1 > 4 then ply:Notify(BaseWars.LANG.UpgradeMaxLevel, BASEWARS_NOTIFICATION_ERROR) return end

			ply:TakeMoney(self:GetUpgradeCost())
			self.CurrentValue = (self.CurrentValue or 0) + self:GetUpgradeCost()
			self.UpgradeValue = self.UpgradeValue + self:GetUpgradeCost()
			self:SetUpgrades(self:GetUpgrades()+1)
			self:SetUpgradeCost(UpgradeCost[self:GetUpgrades()+1])

		if self:GetUpgrades() >= 3 then
			self.Radius=500
		end

	end

	function ENT:OnRemove()

		 for k,v in pairs(ents.FindInSphere(self:GetPos(), 1500)) do

			if v.IsPrinter then
				if v:CPPIGetOwner()==self:CPPIGetOwner() and v.SetDisabled then
					v:SetDisabled(false)
				end
			end

		 end

	end

	hook.Add("EntityTakeDamage", "NoDamageDisabled", function(ent, dmg)
		if not ent.IsPrinter then return end

		if not (ent.Disabled and IsValid(ent.Vault)) then return end
		if ent:CPPIGetOwner() == dmg:GetAttacker() then return end

		local vault = ent.Vault
		if vault.Exhausted then return end

		vault:TakeVaultDamage(dmg:GetDamage())
		dmg:ScaleDamage(0)
		return true
	end)

end--server end


if CLIENT then

	local fontName = "VaultFont"
	surface.CreateFont(fontName..".Title", {
		font = "Roboto",
		size = 96,
		weight = 800,
	})

	surface.CreateFont(fontName, {
		font = "Roboto",
		size = 64,
		weight = 800,
	})

	surface.CreateFont(fontName..".Small", {
		font = "Roboto Light",
		size = 48,
		weight = 600,
	})

	local function ValGoTo(val, destval, mult, smooth)
		if not mult then mult=0.05 else mult=mult/20 end
		if CLIENT then mult=mult*(FrameTime()*150) end

		if not smooth then smooth=false end
		local mult2=mult
		if val==destval then return val end

		if IsColor(val)&&IsColor(destval) then
			local cr=val.r or 0
			local cg=val.g or 0
			local cb=val.b or 0
			local dr=destval.r or 0
			local dg=destval.g or 0
			local db=destval.b or 0
			cr = cr + (mult * (dr-cr))
			cg = cg + (mult * (dg-cg))
			cb = cb + (mult * (db-cb))
			return Color(cr,cg,cb)

		elseif isnumber(val)&&isnumber(destval) then

			if smooth==true then
				local ret=val + (mult2*(destval-val))
				mult2=(destval/ret) * (FrameTime()*150)
				return ret
			end
			if smooth==false then
			return val + (mult*(destval-val))

			end

		elseif istable(val)&&istable(destval) then

			local result={}

			for i=1,#val do

				if isnumber(val[i])&&isnumber(destval[i]) then

					local num1=val[i]
					local num2=destval[i]

					if not smooth then
						num1=num1 + (mult* (num2-num1))
					result[i]=num1
					else
						num1=num1 + (num2-num1)*(num2-num1)
					result[i]=num1
					end

				end
			end
			return result
		end
	end

	local SlotColor, UpgDesc = {}, {}


	UpgDesc[1]="Increases pickup range."
	UpgDesc[2]="When destroyed, returns it's contents\nto you."
	UpgDesc[3]="Automatically refills your printers'\npaper supply."
	UpgDesc[4]="During a raid, your printers become\ninvincible as long as the bank is alive."
	UpgDesc[5]="Max upgrades reached!"

		local textalpha = 0
		local textanim = 0

	function ENT:DrawDisplay(pos, ang, scale, alpha)
			
		local anim = self.anim
			
		if alpha < 1 then return end

		
		draw.RoundedBox(0,0,-80,800,1125,Color(0,0,0,alpha))

		if self:GetPower() < 10 then return end

		local font=fontName

		draw.DrawText("Bank", font..".Title", 400, -50+anim, Color(255,0,0, alpha-20), TEXT_ALIGN_CENTER)


		local money = BaseWars.LANG.CURRENCY .. BaseWars.NumberFormat(tonumber(self:GetMoney()) or 0)
		local rate =  BaseWars.LANG.CURRENCY .. BaseWars.NumberFormat(tonumber(self:GetRate()) or 0) .. "/s"

		draw.DrawText(money, font, 400, 150, Color(255,255,255, alpha-50), TEXT_ALIGN_CENTER)
		draw.DrawText(rate, font..".Small", 400, 240, Color(255,255,255, alpha-50), TEXT_ALIGN_CENTER)

		local sizeOuter=60+anim
		local sizeInner=50+anim

		for i=1,4 do

			draw.RoundedBox(8,200 + i * 100 , 355 ,sizeOuter, sizeOuter,Color(255,255,255,alpha))

			if self:GetUpgrades()>=i then 
				SlotColor[i] = Color(0,225,0, alpha-20)
			else
				SlotColor[i]=Color(225,0,0, alpha-20)
			end
				
			draw.RoundedBox(8,205+(i*100) ,360 ,sizeInner, sizeInner,SlotColor[i])

		end

		if self:GetUpgrades() ~= 4 then 
			textalpha = alpha 
			textanim = anim
		else
			textanim = ValGoTo(textanim, 40, 0.8) 
			textalpha = ValGoTo(textalpha, -20, 0.7)
			draw.DrawText("SHIELD: " .. self:GetShield() .. "/" .. tostring(self.ShieldMax), font .. ".Title", 400, 600, Color(60, 60, 230, alpha-20), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		draw.DrawText("Upgrades:", font, 20+anim*2, 350, Color(255,255,255, alpha-50), TEXT_ALIGN_LEFT)

		if not textanim or textanim > 35 then return end

		draw.DrawText("Next upgrade: " .. BaseWars.LANG.CURRENCY .. BaseWars.NumberFormat(self:GetUpgradeCost()), font, 400, 500+textanim*2, Color(255,255,255, textalpha-50), TEXT_ALIGN_CENTER)
		draw.DrawText(UpgDesc[self:GetUpgrades()+1], "VaultFont.Small", 36, 600+textanim*2, Color(230,230,230, textalpha-50), TEXT_ALIGN_LEFT)
	end

	function ENT:Draw()

		self:DrawModel()

		if not self.alpha then self.alpha=50 end 
		if not self.anim then self.anim=-50 end

		self.dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())

		if self.dist > 65536 then
			self.alpha = ValGoTo(self.alpha, -100, 1)
			self.anim = ValGoTo(self.anim, -50, 0.7)
		end
			
		if self.dist < 65536 then 
			self.alpha = ValGoTo(self.alpha, 350, 1) 
			self.anim = ValGoTo(self.anim, 0, 1) 
		end

		local ang = self:GetAngles()
		local pos = self:GetPos()+ang:Forward()*15+ang:Right()*(14)+ang:Up()*17
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 270)
		local scale = 0.035

		cam.Start3D2D(pos, ang, scale)
			self:DrawDisplay(pos, ang, scale, self.alpha)
		cam.End3D2D()

	end

end

--scripted_ents.Register(ENT, ENT.ClassName)