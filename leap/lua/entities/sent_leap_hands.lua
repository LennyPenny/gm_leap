AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		local plyhands = self:GetOwner():GetHands()
		local mdl = "models/weapons/c_arms_citizen.mdl"
		self:SetModelScale( 25 * self:GetController():GetScale() , 0 )
		
		if IsValid( plyhands ) then
			mdl = plyhands:GetModel()
		end
		
		self:SetModel( mdl )
	else
		self:AddCallback("BuildBonePositions", 
		function( self , nbones )
			self:BuildHands( nbones )
		end)
	end
end

function ENT:BuildHands( bonesnumber )
	local ctrl = self:GetController()
	local ply = self:GetParent()
	
	for i = 0 , bonesnumber - 1 do
		local mybonename = self:GetBoneName( i )
		
		local mybm = self:GetBoneMatrix( i )
		if mybm then
			debugoverlay.Text( mybm:GetTranslation() , mybonename , 0.5 )
		end
		
		--[[
		if not mybonename then
			continue
		end
		
		ply:SetupBones()
		
		local hisbone = ply:LookupBone( mybonename )
		
		if not hisbone then
			continue
		end
		
		local hisbm = ply:GetBoneMatrix( hisbone )
		
		self:SetBoneMatrix( i , hisbm )
		]]
	end
	
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Controller" )
end