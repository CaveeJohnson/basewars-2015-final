-- easylua.StartEntity("bw_weapon_assembler")

AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"

ENT.PrintName = "Assembly Station"
ENT.Model = "models/props_c17/substation_transformer01a.mdl"

ENT.PowerRequired = 25000
ENT.PowerCapacity = 1e8

ENT.PresetMaxHealth = 50000

local craftables = {
	tfa_cso_desperado = {
		mat = Material("entities/tfa_cso_desperado.png"),
		legendary = 50,
		rare = 1000,
		common = 5000,
	},
	tfa_cso_anaconda = {
		mat = Material("entities/tfa_cso_anaconda.png"),
		legendary = 0,
		rare = 10,
		common = 55,
	},
	tfa_cso_automagv = {
		mat = Material("entities/tfa_cso_automagv.png"),
		legendary = 0,
		rare = 12,
		common = 60,
	},
	tfa_cso_avalanche = {
		mat = Material("entities/tfa_cso_avalanche.png"),
		legendary = 1,
		rare = 150,
		common = 250,
	},
	tfa_cso_batista = {
		mat = Material("entities/tfa_cso_batista.png"),
		legendary = 5,
		rare = 250,
		common = 500,
	},
	tfa_cso_beam_sword = {
		mat = Material("entities/tfa_cso_beam_sword.png"),
		legendary = 3,
		rare = 350,
		common = 600,
	},
	tfa_cso_arx160 = {
		mat = Material("entities/tfa_cso_arx160.png"),
		legendary = 0,
		rare = 0,
		common = 500,
	},
	tfa_cso_arx160_master = {
		mat = Material("entities/tfa_cso_arx160_master.png"),
		legendary = 2,
		rare = 0,
		common = 500,
	},
	tfa_cso_blaster = {
		mat = Material("entities/tfa_cso_blaster.png"),
		legendary = 1,
		rare = 200,
		common = 500,
	},
	tfa_cso_brickpiecev2 = {
		mat = Material("entities/tfa_cso_brickpiecev2.png"),
		legendary = 4,
		rare = 500,
		common = 1000,
	},
	tfa_cso_crow1 = {
		mat = Material("entities/tfa_cso_crow1.png"),
		legendary = 2,
		rare = 400,
		common = 800,
	},
	tfa_cso_crow5 = {
		mat = Material("entities/tfa_cso_crow5.png"),
		legendary = 2,
		rare = 500,
		common = 900,
	},
	tfa_cso_darkknight = {
		mat = Material("entities/tfa_cso_darkknight.png"),
		legendary = 10,
		rare = 750,
		common = 1500,
	},
	-- tfa_cso_darkknight_overlord = {
	-- 	mat = Material("entities/tfa_cso_darkknight_overlord.png"),
	-- 	legendary = 20,
	-- 	rare = 750,
	-- 	common = 1500,
	-- },
	tfa_cso_divinelock = {
		mat = Material("entities/tfa_cso_divinelock.png"),
		legendary = 2,
		rare = 150,
		common = 400,
	},
	tfa_cso_dualinfinityfinal = {
		mat = Material("entities/tfa_cso_dualinfinityfinal.png"),
		legendary = 7,
		rare = 700,
		common = 1200,
	},
	-- tfa_cso_dualkrisscustom = {
	-- 	mat = Material("entities/tfa_cso_dualkrisscustom.png"),
	-- 	legendary = 10,
	-- 	rare = 700,
	-- 	common = 1200,
	-- },
	tfa_cso_dualsword = {
		mat = Material("entities/tfa_cso_dualsword.png"),
		legendary = 70,
		rare = 5000,
		common = 15000,
	},
	tfa_cso_dualuzi = {
		mat = Material("entities/tfa_cso_dualuzi.png"),
		legendary = 7,
		rare = 700,
		common = 1200,
	},
	tfa_cso_elvenranger = {
		mat = Material("entities/tfa_cso_elvenranger.png"),
		legendary = 500,
		rare = 9999,
		common = 9999,
	},
	tfa_cso_ethereal = {
		mat = Material("entities/tfa_cso_ethereal.png"),
		legendary = 2,
		rare = 150,
		common = 250,
	},
	tfa_cso_mk48 = {
		mat = Material("entities/tfa_cso_mk48.png"),
		legendary = 0,
		rare = 0,
		common = 2000,
	},
	tfa_cso_mk48_master = {
		mat = Material("entities/tfa_cso_mk48_master.png"),
		legendary = 2,
		rare = 0,
		common = 2000,
	},
	tfa_cso_dragonblade = {
		mat = Material("entities/tfa_cso_dragonblade.png"),
		legendary = 2,
		rare = 2000,
		common = 5000,
	},
	tfa_cso_dragonblade_expert = {
		mat = Material("entities/tfa_cso_dragonblade_expert.png"),
		legendary = 2,
		rare = 2000,
		common = 5000,
	},
	tfa_cso_laserminigun = {
		mat = Material("entities/tfa_cso_laserminigun.png"),
		legendary = 15,
		rare = 5000,
		common = 5000,
	},
	tfa_cso_lycanthrope = {
		mat = Material("entities/tfa_cso_lycanthrope.png"),
		legendary = 20,
		rare = 5000,
		common = 5000,
	},
	tfa_cso_lycanthrope_expert = {
		mat = Material("entities/tfa_cso_lycanthrope_expert.png"),
		legendary = 50,
		rare = 5000,
		common = 5000,
	},
	tfa_cso_magnumdrill = {
		mat = Material("entities/tfa_cso_magnumdrill.png"),
		legendary = 20,
		rare = 15000,
		common = 15000,
	},
	tfa_cso_magnumdrill_expert = {
		mat = Material("entities/tfa_cso_magnumdrill_expert.png"),
		legendary = 50,
		rare = 15000,
		common = 15000,
	},
	tfa_cso_magnum_lancer = {
		mat = Material("entities/tfa_cso_magnum_lancer.png"),
		legendary = 70,
		rare = 18000,
		common = 15000,
	},
	tfa_cso_plasmagun = {
		mat = Material("entities/tfa_cso_plasmagun.png"),
		legendary = 3,
		rare = 500,
		common = 1200,
	},
	tfa_cso_railcannon = {
		mat = Material("entities/tfa_cso_railcannon.png"),
		legendary = 15,
		rare = 1000,
		common = 2000,
	},
	tfa_cso_runebreaker = {
		mat = Material("entities/tfa_cso_runebreaker.png"),
		legendary = 15,
		rare = 3000,
		common = 5000,
	},
	tfa_cso_runebreaker_expert = {
		mat = Material("entities/tfa_cso_runebreaker_expert.png"),
		legendary = 35,
		rare = 3000,
		common = 5000,
	},
	tfa_cso_sapientia = {
		mat = Material("entities/tfa_cso_sapientia.png"),
		legendary = 0,
		rare = 220,
		common = 300,
	},
	tfa_cso_starchasersr = {
		mat = Material("entities/tfa_cso_starchasersr.png"),
		legendary = 50,
		rare = 999,
		common = 999,
	},
	tfa_cso_stormgiant = {
		mat = Material("entities/tfa_cso_stormgiant.png"),
		legendary = 25,
		rare = 3000,
		common = 5000,
	},
	tfa_cso_stormgiant_tw = {
		mat = Material("entities/tfa_cso_stormgiant_tw.png"),
		legendary = 100,
		rare = 3000,
		common = 5000,
	},
	tfa_cso_thanatos9 = {
		mat = Material("entities/tfa_cso_thanatos9.png"),
		legendary = 10,
		rare = 3000,
		common = 5000,
	},
	tfa_cso_thunderbolt = {
		mat = Material("entities/tfa_cso_thunderbolt.png"),
		legendary = 5,
		rare = 999,
		common = 999,
	},
	-- tfa_cso2_awp_ss = {
	-- 	mat = Material("entities/tfa_cso2_awp_ss.png"),
	-- 	legendary = 50,
	-- 	rare = 9999,
	-- 	common = 9999,
	-- },
	-- tfa_cso2_m3dragon = {
	-- 	mat = Material("entities/tfa_cso2_m3dragon.png"),
	-- 	legendary = 30,
	-- 	rare = 9999,
	-- 	common = 9999,
	-- },
	-- tfa_cso2_awp_tan = {
	-- 	mat = Material("entities/tfa_cso2_awp_tan.png"),
	-- 	legendary = 999,
	-- 	rare = 9999,
	-- 	common = 9999,
	-- },
}

local Clamp = math.Clamp
function ENT:GSAT(vartype, slot, name, min, max)
	self:NetworkVar(vartype, slot, name)

	local getVar = function(minMax)
		if self[minMax] and isfunction(self[minMax]) then return self[minMax](self) end
		if self[minMax] and isnumber(self[minMax]) then return self[minMax] end
		return minMax or 0
	end

	self["Get" .. name] = function(self)
		return self.dt[name]
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
	self:GSAT("String", 2, "SelectedClass")

	self:GSAT("Int", 4, "PrechargeLevel",  0, 100)
	self:GSAT("Int", 5, "CraftPercentage", 0, 100)

	self:GSAT("Int", 6, "CommonComponentCount",    0, 999999)
	self:GSAT("Int", 7, "RareComponentCount",      0, 999999)
	self:GSAT("Int", 8, "LegendaryComponentCount", 0, 999999)
end

function ENT:containsComponents()
	local class = self:GetSelectedClass()

	local data = craftables[class]
	if not data then return end

	return  self:GetCommonComponentCount() >= data.common
		and self:GetRareComponentCount() >= data.rare
		and self:GetLegendaryComponentCount() >= data.legendary
end

if CLIENT then

local title_font = "assembler.title"
surface.CreateFont(title_font, {
	font = "Roboto",
	size = 64,
	weight = 800,
})

local component_font = "assembler.component"
surface.CreateFont(component_font, {
	font = "Roboto",
	size = 80,
	weight = 800,
})

local charge_font = "assembler.charge"
surface.CreateFont(charge_font, {
	font = "Roboto",
	size = 52,
	weight = 800,
})

local color_common    = Color(200, 200, 200)
local color_rare      = Color(138, 43 , 226)
local color_legendary = Color(218, 165, 32 )

local color_precharge = Color(120, 180, 220)
local color_craft     = Color(255, 127, 80 )

local color_red       = Color(255, 0  , 0  )

do
	local frame

	local function openSelectionGUI()
		if IsValid(frame) then return end

		local assembler = net.ReadEntity()
		if not IsValid(assembler) then return end

		frame = vgui.Create("DFrame")
			frame:SetSize(600, 800)
			frame:Center()
			frame:SetTitle(string.format("Weapon Assembler [%d]", assembler:EntIndex()))

		local scroll = vgui.Create("DScrollPanel", frame)
			scroll:Dock(FILL)

		do
			local class = assembler:GetSelectedClass()
			local data = craftables[class]

			if data then
				local p = vgui.Create("DButton", scroll)
					p:Dock(TOP)
					p:SetHeight(32)
					p:SetText("Cancel")

				function p:DoClick()
					net.Start("bw_weapon_assembler")
						net.WriteEntity(assembler)
						net.WriteString("")
					net.SendToServer()

					frame:Close()
				end
			end
		end

		for class, data in SortedPairsByMemberValue(craftables, "legendary", true) do
			local p = vgui.Create("DButton", scroll)
				p:Dock(TOP)
				p:SetHeight(64)
				p:SetText("")

			local wep = weapons.Get(class)
			print(class, wep)
			function p:Paint(w, h)
				DButton.Paint(self, w, h)

				surface.SetMaterial(data.mat)
				surface.DrawTexturedRect(0, 0, h, h)

				local x, y = h + 8, 4
				draw.SimpleTextOutlined(wep.PrintName, "Default", x, y, color_white, nil, nil, 1, color_black)

				x = x + 4
				y = y + 12 + 2
				draw.SimpleTextOutlined(data.common, "Default", x, y, color_common, nil, nil, 1, color_black)
				y = y + 12 + 2
				draw.SimpleTextOutlined(data.rare, "Default", x, y, color_rare, nil, nil, 1, color_black)
				y = y + 12 + 2
				draw.SimpleTextOutlined(data.legendary, "Default", x, y, color_legendary, nil, nil, 1, color_black)
			end

			function p:DoClick()
				net.Start("bw_weapon_assembler")
					net.WriteEntity(assembler)
					net.WriteString(class)
				net.SendToServer()

				frame:Close()
			end
		end

		frame:MakePopup()
	end
	net.Receive("bw_weapon_assembler", openSelectionGUI)
end

function ENT:DrawDisplay()
	local w, h = 3400, 1500

	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, w, h)

	if not self:IsPowered() then return end

	local x, y = 32, 32
	draw.SimpleText("Hexahedron\xE2\x84\xA2 Weapon Assembler 8999 MK III", title_font, x, y)

	y = y + 256
	draw.SimpleText("Available Components", component_font, x, y, color_white)

	local color_count = color_white

	local class = self:GetSelectedClass()
	local data = craftables[class]

	if data and self:GetCommonComponentCount() < data.common and (CurTime() % 2 < 1) then
		color_count = color_red
	end

	x = 32
	y = y + 128
	draw.SimpleText("Common", component_font, x, y, color_common)
	x = 382
	draw.SimpleText(string.format("%06d", self:GetCommonComponentCount()), component_font, x, y, color_count)

	color_count = color_white

	if data and self:GetRareComponentCount() < data.rare and (CurTime() % 2 < 1) then
		color_count = color_red
	end

	x = 32
	y = y + 80
	draw.SimpleText("Rare", component_font, x, y, color_rare)
	x = 382
	draw.SimpleText(string.format("%06d", self:GetRareComponentCount()), component_font, x, y, color_count)

	color_count = color_white

	if data and self:GetLegendaryComponentCount() < data.legendary and (CurTime() % 2 < 1) then
		color_count = color_red
	end

	x = 32
	y = y + 80
	draw.SimpleText("Legendary", component_font, x, y, color_legendary)
	x = 382
	draw.SimpleText(string.format("%06d", self:GetLegendaryComponentCount()), component_font, x, y, color_count)

	y = h - 32
	x = 32
	surface.SetDrawColor(color_white)
	surface.DrawRect(x, y - 64, w - 64, 64)

	local percent = self:GetCraftPercentage() / 100
	surface.SetDrawColor(color_craft)
	surface.DrawRect(x, y - 64, percent * (w - 64), 64)

	draw.SimpleText("Crafting", charge_font, (w - 64) / 2, y - 32, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	y = y - 64 - 16
	surface.SetDrawColor(color_white)
	surface.DrawRect(x, y - 64, w - 64, 64)

	percent = self:GetPrechargeLevel() / 100
	surface.SetDrawColor(color_precharge)
	surface.DrawRect(x, y - 64, percent * (w - 64), 64)

	draw.SimpleText("Pre-Charger", charge_font, (w - 64) / 2, y - 32, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if not data then return end

	x = w - 32
	y = 32

	local rest_h = h - 64 - 64 - 64 - 32 - 16
	local iw, ih = rest_h, rest_h

	surface.SetMaterial(data.mat)
	surface.DrawTexturedRect(x - iw, y, iw, ih)

	surface.SetDrawColor(color_craft)
	surface.DrawOutlinedRect(x - iw - 1, y - 1, iw + 2, ih + 2)

	local offset = w - iw - 64

	x = offset
	y = 32 + 256
	draw.SimpleText("Required Components", component_font, x, y, color_white, TEXT_ALIGN_RIGHT)

	x = offset
	y = y + 128
	draw.SimpleText("Common", component_font, x, y, color_common, TEXT_ALIGN_RIGHT)
	x = offset - 382 + 32
	draw.SimpleText(string.format("%06d", data.common), component_font, x, y, color_white, TEXT_ALIGN_RIGHT)

	x = offset
	y = y + 80
	draw.SimpleText("Rare", component_font, x, y, color_rare, TEXT_ALIGN_RIGHT)
	x = offset - 382 + 32
	draw.SimpleText(string.format("%06d", data.rare), component_font, x, y, color_white, TEXT_ALIGN_RIGHT)

	x = offset
	y = y + 80
	draw.SimpleText("Legendary", component_font, x, y, color_legendary, TEXT_ALIGN_RIGHT)
	x = offset - 382 + 32
	draw.SimpleText(string.format("%06d", data.legendary), component_font, x, y, color_white, TEXT_ALIGN_RIGHT)

	local wep = weapons.Get(class)

	x = offset
	y = rest_h
	draw.SimpleText(wep.PrintName, component_font, x, y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

ENT.screen_offset = Vector(46.177502, -85.593010, 50.585556)

function ENT:Calc3D2DParams()
	local pos = self:LocalToWorld(self.screen_offset)
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	return pos, ang, 0.1 / 2
end

function ENT:Draw()
	self:DrawModel()

	local pos, ang, scale = self:Calc3D2DParams()

	cam.Start3D2D(pos, ang, scale)
		local ok, err = pcall(self.DrawDisplay, self, pos, ang, scale)
		if not ok then print(err) end
	cam.End3D2D()
end

return end -- easylua.EndEntity() end



util.AddNetworkString("bw_weapon_assembler")

function ENT:Init()
	self:SetModel(self.Model)
	self:SetMaterial(self.Material)
end

ENT.spawn_offset = Vector(58.204693, -1.661758, -33.874352)

function ENT:dipsenseWeapon()
	local class = self:GetSelectedClass()

	local data = craftables[class]
	if not data then return end

	self:TakeCommonComponentCount(data.common)
	self:TakeRareComponentCount(data.rare)
	self:TakeLegendaryComponentCount(data.legendary)

	local spawn_pos = self:LocalToWorld(self.spawn_offset)
	local ent = ents.Create("bw_weapon")
		ent.WeaponClass = class
		ent.Model = weapons.Get(class).WorldModel
		ent:SetPos(spawn_pos)
	ent:Spawn()
	ent:Activate()

	for i = 1, 5 do self:Spark() end
	self:EmitSound("npc/combine_gunship/attack_stop2.wav", 75, 90, 1)
end

function ENT:ThinkFunc()
	if self.next_check and self.next_check > CurTime() then return end
	self.next_check = CurTime() + 1

	local class = self:GetSelectedClass()

	local data = craftables[class]
	if not data then return end

	if self:GetPrechargeLevel() >= 100 then
		if not self:containsComponents() then
			self:EmitSound("Resource/warning.wav")
			return
		end

		self:AddCraftPercentage(1)
		self:SetPrechargeLevel(0)
		self:Spark()
		self:EmitSound("ui/buttonrollover.wav", 75, 70, 1) self:EmitSound("ui/buttonrollover.wav", 75, 90, 1)
	end

	if self:GetCraftPercentage() >= 100 then
		if not self:containsComponents() then
			self:EmitSound("Resource/warning.wav")
			return
		end

		self:SetCraftPercentage(0)
		self:dipsenseWeapon()

		self.next_check = CurTime() + 5

		self:SetSelectedClass("")
	end
end

function ENT:UseFunc(user)
	if user ~= self:CPPIGetOwner() then return end

	net.Start("bw_weapon_assembler")
		net.WriteEntity(self)
	net.Send(user)
end

local sqr_dist = 256 * 256 -- big but who cares

local function receiveRequest(_, ply)
	local ent = net.ReadEntity()
	local class = net.ReadString()

	if not IsValid(ent) or ent:CPPIGetOwner() ~= ply or not ent.SetSelectedClass or ply:GetPos():DistToSqr(ent:GetPos()) > sqr_dist then
		print("assembler received suspicious/broken request, denied: ", ply, ent, class)
		return
	end

	ent:SetSelectedClass(class)
	ent:SetCraftPercentage(0)
end
net.Receive("bw_weapon_assembler", receiveRequest)

-- easylua.EndEntity()
