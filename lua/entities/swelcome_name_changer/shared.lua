ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName		= sWelcome:Translate( "ChangeName" )
ENT.Category		= "SWelcome" 
ENT.Author 			= "Seefox"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end