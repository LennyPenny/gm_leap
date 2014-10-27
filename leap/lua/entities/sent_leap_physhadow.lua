AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/props_junk/wood_crate001a.mdl" )
		self:PhysicsInitBox( self:GetMinSize() , self:GetMaxSize() )
		self:SetCollisionBounds( self:GetMinSize() , self:GetMaxSize() )
		self:SetSolid( SOLID_VPHYSICS )
		self:MakePhysicsObjectAShadow( true, true )
		if IsValid( self:GetPhysicsObject() ) then
			self:GetPhysicsObject():SetMaterial( "flesh" )
		end
		
		self.TouchingPhysobj = nil
	else
		self:SetRenderBounds( self:GetMinSize() , self:GetMaxSize() )
	end
	self:SetCustomCollisionCheck( true )
	hook.Add( "ShouldCollide" , self , self.HandleCollisons )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Scale" )
	
	self:NetworkVar( "Vector" , 0 , "MinBounds" )
	self:NetworkVar( "Vector" , 1 , "MaxBounds" )
	
	self:NetworkVar( "String" , 0 , "AssociatedBone" )
	self:NetworkVar( "Entity" , 0 , "Controller" )
	
	self:NetworkVar( "Float" , 1 , "GrabStrength" )
	
	self:NetworkVar( "Bool" , 0 , "IsLeft" )

end

function ENT:HandleCollisons( ent1 , ent2 )
	if self == ent1 then
		if ent1:GetClass() == ent2:GetClass() and IsValid( ent1:GetOwner() ) and ent1:GetOwner() == ent2:GetOwner() then
			return false
		end
		
		if ent2 == self:GetOwner() then
			return false
		end
	end
end

function ENT:IsLeft()
	return self:GetIsLeft()
end

function ENT:IsRight()
	return not self:GetIsLeft()
end

function ENT:GetMinSize()
	return self:GetMinBounds() * self:GetScale()
end

function ENT:GetMaxSize()
	return self:GetMaxBounds() * self:GetScale()
end

function ENT:Update( pos , ang , delta , olderlastframereceivedtime , lastframereceivedtime )
	local physobj = self:GetPhysicsObject()
	
	if not IsValid( physobj ) then return end
	
	physobj:Wake()
	physobj:SetMass( 300 * self:GetScale() )
	physobj:EnableGravity( false )
	physobj:UpdateShadow( pos , ang , delta )
end

function ENT:Think()
	if SERVER then
		if self.TouchingPhysobjForget and self.TouchingPhysobjForget < CurTime() then
			self.TouchingPhysobj = nil
			self.TouchingPhysobjForget = nil
		end
	end
end

function ENT:PhysicsUpdate()
	--[[
	if IsValid( self.TouchingPhysobj ) and self:GetGrabStrength() > 0.3 then
		self.TouchingPhysobj:Wake()
		
		local pos , ang = LocalToWorld( self.TouchingPhysobjLocalpos , self.TouchingPhysobjLocalang , self:GetPos() , self:GetAngles() )
		self.TouchingPhysobj:UpdateShadow( pos , ang , FrameTime() )
	end
	]]
end

function ENT:PhysicsCollide( data , physobj )
	--[[
	local theirphysobj = data.HitObject
	
	self.TouchingPhysobj = data.HitObject
	
	if not self:GetController():CanGrab( data , self ) then
		self.TouchingPhysobj = nil
		return
	end
	--self.TouchingPhysobjForget = CurTime() + 2
	self.TouchingPhysobjLocalpos = self.TouchingPhysobj:WorldToLocal( data.HitPos )
	self.TouchingPhysobjLocalang = self.TouchingPhysobj:GetAngles()
	]]
end

ENT.Mat = Material( "models/wireframe" )
function ENT:Draw()
	local cmin , cmax = self:GetCollisionBounds()
	
	render.SetMaterial( self.Mat )
	render.DrawBox( self:GetPos(), self:GetAngles(), cmin, cmax, color_white, true )
end