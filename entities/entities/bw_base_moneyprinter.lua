local fontName = "BaseWars.MoneyPrinter"

ENT.Base = "bw_base_electronics"

ENT.Model = "models/props_lab/reciever01a.mdl"
ENT.Skin = 0

ENT.Capacity 		= 10000
ENT.Money 			= 0
ENT.MaxPaper		= 2500
ENT.PrintInterval 	= 1
ENT.PrintAmount		= 8
ENT.MaxLevel 		= 25
ENT.UpgradeCost 	= 1000

ENT.PrintName 		= "Basic Printer"

ENT.IsPrinter 		= true
ENT.IsValidRaidable = false

ENT.MoneyPickupSound = Sound("mvm/mvm_money_pickup.wav")
ENT.UpgradeSound = Sound("replay/rendercomplete.wav")

local Clamp = math.Clamp
function ENT:GSAT(vartype, slot, name, min, max)
	self:NetworkVar(vartype, slot, name)

	local getVar = function(minMax)
		if self[minMax] and isfunction(self[minMax]) then return self[minMax](self) end
		if self[minMax] and isnumber(self[minMax]) then return self[minMax] end
		return minMax or 0
	end

	self["Get" .. name] = function(self)
		return tonumber(self.dt[name])
	end

	self["Set" .. name] = function(self, var)
		if isstring(self.dt[name]) then
			self.dt[name] = tostring(var)
		else
			self.dt[name] = var
		end
	end

	self["Add" .. name] = function(_, var)
		local Val = self["Get" .. name](self) + var

		if min and max then
			Val = Clamp(Val or 0, getVar(min), getVar(max))
		end

		if isstring(self["Get" .. name](self)) then
			self["Set" .. name](self, Val)
		else
			self["Set" .. name](self, Val)
		end
	end

	self["Take" .. name] = function(_, var)
		local Val = self["Get" .. name](self) - var

		if min and max then
			Val = Clamp(Val or 0, getVar(min), getVar(max))
		end

		if isstring(self["Get" .. name](self)) then
			self["Set" .. name](self, Val)
		else
			self["Set" .. name](self, Val)
		end
	end
end

function ENT:StableNetwork()
	self:GSAT("String", 2, "Capacity")
	self:SetCapacity("0")
	self:GSAT("String", 3, "Money", 0, "GetCapacity")
	self:SetMoney("0")
	self:GSAT("Int", 4, "Paper", 0, "MaxPaper")
	self:GSAT("Int", 5, "Level", 0, "MaxLevel")
end

if SERVER then
	AddCSLuaFile()

	function ENT:Init()
		self.time = CurTime()
		self.time_p = CurTime()

		self:SetCapacity(self.Capacity)
		self:SetPaper(self.MaxPaper)

		self:SetHealth(self.PresetMaxHealth or 100)

		self.rtb = 0

		self.FontColor = color_white
		self.BackColor = color_black

		self:SetNWInt("UpgradeCost", self.UpgradeCost)

		self:SetLevel(1)
	end

	function ENT:SetUpgradeCost(val)
		self.UpgradeCost = val
		self:SetNWInt("UpgradeCost", val)
	end

	function ENT:Upgrade(ply, supress)
		local lvl = self:GetLevel()
		local calcM = self:GetNWInt("UpgradeCost") * lvl

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

		self:AddLevel(1)
		self:EmitSound(self.UpgradeSound)

		return true
	end

	function ENT:ThinkFunc()
		if self.Disabled or self:BadlyDamaged() then return end
		local added

		local level = self:GetLevel() ^ 1.45

		if CurTime() >= self.PrintInterval + self.time and self:GetPaper() > 0 then
			local m = self:GetMoney()
			self:AddMoney(math.Round(self.PrintAmount * level))
			self.time = CurTime()
			added = m ~= self:GetMoney()
		end

		if CurTime() >= self.PrintInterval * 2 + self.time_p and added then
			self.time_p = CurTime()
			self:TakePaper(1)
		end
	end

	function ENT:PlayerTakeMoney(ply)
		local money = self:GetMoney()

		local Res, Msg = hook.Run("BaseWars_PlayerCanEmptyPrinter", ply, self, money)

		if Res == false then
			if Msg then
				ply:Notify(Msg, BASEWARS_NOTIFICATION_ERROR)
			end

		return end

		self:TakeMoney(money)

		ply:GiveMoney(money)
		ply:EmitSound(self.MoneyPickupSound)

		hook.Run("BaseWars_PlayerEmptyPrinter", ply, self, money)
	end

	function ENT:UseFuncBypass(activator, caller, usetype, value)
		if self.Disabled then return end
		if activator:IsPlayer() and caller:IsPlayer() and self:GetMoney() > 0 then
			self:PlayerTakeMoney(activator)
		end
	end

	function ENT:SetDisabled(a)
		self.Disabled = a and true or false
		self:SetNWBool("printer_disabled", a and true or false)
	end

else

	function ENT:Initialize()
		if not self.FontColor then self.FontColor = color_white end
		if not self.BackColor then self.BackColor = color_black end
	end

	surface.CreateFont(fontName, {
		font = "Roboto",
		size = 20,
		weight = 800,
	})

	local fontNameHuge = fontName .. ".Huge"
	surface.CreateFont(fontNameHuge, {
		font = "Roboto",
		size = 64,
		weight = 800,
	})

	local fontNameBig = fontName .. ".Big"
	surface.CreateFont(fontNameBig, {
		font = "Roboto",
		size = 32,
		weight = 800,
	})

	local fontNameMedBig = fontName .. ".MedBig"
	surface.CreateFont(fontNameMedBig, {
		font = "Roboto",
		size = 24,
		weight = 800,
	})

	local fontNameMed = fontName .. ".Med"
	surface.CreateFont(fontNameMed, {
		font = "Roboto",
		size = 18,
		weight = 800,
	})

	do
		local w, h = 216 * 2, 136 * 2
		local color_red = Color(255,0,0)

		local time_cache = {}
		local function getTime(timeRemaining)
			if not time_cache[timeRemaining] then
				local PrettyHours = math.floor(timeRemaining/3600)
				local PrettyMinutes = math.floor(timeRemaining/60) - PrettyHours*60
				local PrettySeconds = timeRemaining - PrettyMinutes*60 - PrettyHours*3600
				local PrettyTime =
					(PrettyHours   > 0 and PrettyHours   .. BaseWars.LANG.HoursShort   or "")
				..  (PrettyMinutes > 0 and PrettyMinutes .. BaseWars.LANG.MinutesShort or "")
				..   PrettySeconds .. BaseWars.LANG.SecondsShort

				local ret = string.format(BaseWars.LANG.UntilFull, PrettyTime)
				time_cache[timeRemaining] = ret
			end

			return time_cache[timeRemaining]
		end

		local lv_cache = {}
		local function getLv(Lv)
			if not lv_cache[Lv] then
				lv_cache[Lv] = string.format(BaseWars.LANG.LevelText, Lv):upper()
			end

			return lv_cache[Lv]
		end

		local font_heights = {}
		local function fontHeight(font)
			if not font_heights[font] then
				font_heights[font] = draw.GetFontHeight(font)
			end

			return font_heights[font]
		end

		local function upgradeCache(self, Lv)
			self._upgrade_cache = self._upgrade_cache or {}

			if not self._upgrade_cache[Lv] then
				local NextCost
				if Lv >= self.MaxLevel then
					NextCost = BaseWars.LANG.MaxLevel
				else
					NextCost = string.format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(Lv * self:GetNWInt("UpgradeCost")))
				end

				self._upgrade_cache[Lv] = string.format(BaseWars.LANG.NextUpgrade, NextCost)
			end

			return self._upgrade_cache[Lv]
		end

		local surface_SetDrawColor = surface.SetDrawColor
		local surface_DrawRect = surface.DrawRect
		local draw_DrawText = draw.DrawText
		local surface_DrawLine = surface.DrawLine
		local math_Round = math.Round
		local math_floor = math.floor
		local surface_GetTextSize = surface.GetTextSize
		local string_format = string.format
		local math_huge = math.huge

		local sep = " / "
		local StrW_sep, StrH_sep = surface.GetTextSize(sep)

		function ENT:DrawDisplay(pos, ang, scale)
			local BackColor = self.BackColor
			local FontColor = self.FontColor

			local Pw = self:IsPowered()
			surface_SetDrawColor(Pw and BackColor or color_black)
			surface_DrawRect(0, 0, w, h)

			if not Pw then return end

			local disabled = self:GetNWBool("printer_disabled")
			if disabled then
				draw_DrawText(BaseWars.LANG.PrinterBeen, fontName, w / 2, h / 2 - 48, FontColor, TEXT_ALIGN_CENTER)
				draw_DrawText(BaseWars.LANG.Disabled, fontNameHuge, w / 2, h / 2 - 32, color_red, TEXT_ALIGN_CENTER)
			return end
			draw_DrawText(self.PrintName, fontName, w / 2, 4, FontColor, TEXT_ALIGN_CENTER)

			if disabled then return end

			local Lv = self:GetLevel()

			--Level
			surface_SetDrawColor(FontColor)
			surface_DrawLine(0, 30, w, 30)--draw.RoundedBox(0, 0, 30, w, 1, self.FontColor)
			draw_DrawText(getLv(Lv), fontNameBig, 4, 32, FontColor, TEXT_ALIGN_LEFT)
			surface_DrawLine(0, 68, w, 68)--draw.RoundedBox(0, 0, 68, w, 1, self.FontColor)

			draw_DrawText(BaseWars.LANG.Cash, fontNameBig, 4, 72, FontColor, TEXT_ALIGN_LEFT)
			-- draw.RoundedBox(0, 0, 72 + 32, w, 1, self.FontColor)

			local money = self:GetMoney() or 0
			local cap = tonumber(self:GetCapacity()) or 0

			local moneyPercentage = math_Round(money / cap * 100, 1)
			--Percentage done
			draw_DrawText(moneyPercentage .."%" , fontNameBig,	w - 4, 71, FontColor, TEXT_ALIGN_RIGHT)

			--Money/Maxmoney
			local currentMoney = string_format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(money))
			local maxMoney = string_format(BaseWars.LANG.CURFORMER, BaseWars.NumberFormat(cap))
			local font = fontNameBig

			local money_length = #currentMoney
			if money_length > 20 then
				font = fontNameMed
			elseif money_length > 16 then
				font = fontNameMedBig
			end

			local fh = fontHeight(font)

			local StrW, StrH = StrW_sep, StrH_sep
			draw_DrawText(sep, font,
				w/2 - StrW/2 , (font == fontNameBig and 106 or 105 + fh / 4), FontColor, TEXT_ALIGN_LEFT)

			local moneyW, moneyH = surface_GetTextSize(currentMoney)
			draw_DrawText(currentMoney , font,
				w/2 - StrW/2 - moneyW , (font == fontNameBig and 106 or 105 + fh / 4), FontColor, TEXT_ALIGN_LEFT)

			draw_DrawText(maxMoney, font,
				w/2 + StrW/2 , (font == fontNameBig and 106 or 105 + fh / 4), FontColor, nil)

			--Paper
			local paper = math.floor(self:GetPaper())
			draw_DrawText(string_format(BaseWars.LANG.Paper, paper), fontNameMedBig, 4, 94 + 49, FontColor, TEXT_ALIGN_LEFT)
			--draw.RoundedBox(0, 0, 102 + 37, w, 1, self.FontColor)
			surface_DrawLine(0, 102 + 37, w, 102 + 37)

			surface_DrawLine(0, 142 + 25, w, 142 + 25)--draw.RoundedBox(0, 0, 142 + 25, w, 1, self.FontColor)
			draw_DrawText(upgradeCache(self, Lv), fontNameMedBig, 4, 84 + 78 + 10, FontColor, TEXT_ALIGN_LEFT)
			surface_DrawLine(0, 142 + 25, w, 142 + 25)--draw.RoundedBox(0, 0, 142 + 55, w, 1, self.FontColor)

			--Time remaining counter
			local timeRemaining = 0
			local moneyRatio = money / cap
			local roomInPrinter = cap - money
			timeRemaining = math_Round(roomInPrinter / (self.PrintAmount * Lv / self.PrintInterval))
			
			if timeRemaining > 0 then
				draw_DrawText(getTime(timeRemaining), fontNameBig, w-4 , 32, FontColor, TEXT_ALIGN_RIGHT)
			else
				draw_DrawText(BaseWars.LANG.Full, fontNameBig, w-4 , 32, FontColor, TEXT_ALIGN_RIGHT)
			end

			--Money bar BG
			local BoxX = 88
			local BoxW = 265
			surface_SetDrawColor(FontColor)
			surface_DrawRect(BoxX, 74, BoxW , 24)

			--Money bar gap
			if cap > 0 and cap ~= math_huge and moneyRatio < 0.99999 then 
				local maxWidth = math_floor(BoxW - 6)
				local curWidth = maxWidth * (1 - moneyRatio)

				surface_SetDrawColor(BackColor)
				surface_DrawRect(w - BoxX - curWidth + 6 , 76, curWidth , 24 - 4)
			end
		end
	end

	function ENT:Calc3D2DParams()
		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Up() * 3.09
		pos = pos + ang:Forward() * -7.35
		pos = pos + ang:Right() * 10.82

		ang:RotateAroundAxis(ang:Up(), 90)

		return pos, ang, 0.1 / 2
	end

	local render_dist = 300 * 300
	function ENT:Draw()
		self:DrawModel()

		if CLIENT and LocalPlayer():GetPos():DistToSqr(self:GetPos()) < render_dist then
			local pos, ang, scale = self:Calc3D2DParams()

			cam.Start3D2D(pos, ang, scale)
				pcall(self.DrawDisplay, self, pos, ang, scale)
			cam.End3D2D()
		end
	end
end
