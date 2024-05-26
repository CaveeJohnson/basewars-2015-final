AddCSLuaFile()
ENT.Base = "bw_base_moneyprinter"

ENT.Model = "models/props_lab/reciever01a.mdl"
ENT.Skin = 0

ENT.Capacity 		= 70000000
ENT.PrintInterval 	= 1
ENT.PrintAmount		= 40125

ENT.PrintName = "VIP Printer 2"

ENT.FontColor = color_white
ENT.BackColor = color_black
function ENT:Draw()
	self.FontColor = HSVToColor(CurTime() % 6 * 60, 1, 1)
	self:DrawModel()

	if CLIENT then
		local pos, ang, scale = self:Calc3D2DParams()

		cam.Start3D2D(pos, ang, scale)
			pcall(self.DrawDisplay, self, pos, ang, scale)
		cam.End3D2D()
	end
end

ENT.IsValidRaidable = true

ENT.PresetMaxHealth = 4250
ENT.PowerRequired = 25
