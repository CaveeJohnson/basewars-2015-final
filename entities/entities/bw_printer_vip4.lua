AddCSLuaFile()
ENT.Base = "bw_base_moneyprinter"

ENT.Model = "models/props_lab/reciever01a.mdl"
ENT.Skin = 0

ENT.Capacity 		= 10000000000
ENT.PrintInterval 	= 1
ENT.PrintAmount		= 9750000

ENT.PrintName = "VIP Printer 4"

ENT.FontColor = color_white
ENT.BackColor = color_black
function ENT:Draw()
	self.FontColor = HSVToColor(CurTime() % 6 * 60, 1, 1)
	self:DrawModel()
	self:BaseScreenDraw()
end

ENT.IsValidRaidable = true

ENT.PresetMaxHealth = 4500
ENT.PowerRequired = 35
