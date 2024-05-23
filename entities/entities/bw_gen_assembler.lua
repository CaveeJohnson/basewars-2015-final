-- easylua.StartEntity("bw_gen_assembler")

AddCSLuaFile()

ENT.Base 			= "bw_base_generator"
ENT.PrintName 		= "Assembler Power-Core"

ENT.Model 			= "models/props/de_nuke/powerplanttank.mdl"

ENT.PowerGenerated 	= 30000
ENT.PowerCapacity 	= 1e8

ENT.TransmitRadius 	= 150
ENT.TransmitRate 	= 30000

ENT.PresetMaxHealth = 1500

-- easylua.EndEntity()
