AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

--[[

	["ValveBiped.Bip01_L_Hand"]=HAND_LEFT,
	["ValveBiped.Bip01_R_Hand"]=HAND_RIGHT,
	
	["ValveBiped.Bip01_L_Finger4"]=true,
	["ValveBiped.Bip01_L_Finger41"]=true,
	["ValveBiped.Bip01_L_Finger42"]=true,
	
	["ValveBiped.Bip01_L_Finger3"]=true,
	["ValveBiped.Bip01_L_Finger31"]=true,
	["ValveBiped.Bip01_L_Finger32"]=true,
	
	["ValveBiped.Bip01_L_Finger2"]=true,
	["ValveBiped.Bip01_L_Finger21"]=true,
	["ValveBiped.Bip01_L_Finger22"]=true,
	
	["ValveBiped.Bip01_L_Finger1"]=true,
	["ValveBiped.Bip01_L_Finger11"]=true,
	["ValveBiped.Bip01_L_Finger12"]=true,
	
	["ValveBiped.Bip01_L_Finger0"]=true,
	["ValveBiped.Bip01_L_Finger01"]=true,
	["ValveBiped.Bip01_L_Finger02"]=true,
	
	["ValveBiped.Bip01_R_Finger4"]=true,
	["ValveBiped.Bip01_R_Finger41"]=true,
	["ValveBiped.Bip01_R_Finger42"]=true,
	
	["ValveBiped.Bip01_R_Finger3"]=true,
	["ValveBiped.Bip01_R_Finger31"]=true,
	["ValveBiped.Bip01_R_Finger32"]=true,
	
	["ValveBiped.Bip01_R_Finger2"]=true,
	["ValveBiped.Bip01_R_Finger21"]=true,
	["ValveBiped.Bip01_R_Finger22"]=true,
	
	["ValveBiped.Bip01_R_Finger1"]=true,
	["ValveBiped.Bip01_R_Finger11"]=true,
	["ValveBiped.Bip01_R_Finger12"]=true,
	
	["ValveBiped.Bip01_R_Finger0"]=true,
	["ValveBiped.Bip01_R_Finger01"]=true,
	["ValveBiped.Bip01_R_Finger02"]=true,
]]

	
--	["ValveBiped.Bip01_R_Wrist"]=true,
--	["ValveBiped.Bip01_L_Wrist"]=true,

--[[
local FINGER_TYPE_THUMB 	= 1
local FINGER_TYPE_INDEX		= 2
local FINGER_TYPE_MIDDLE	= 3
local FINGER_TYPE_RING		= 4
local FINGER_TYPE_PINKY		= 5

local BONE_TYPE_METACARPAL			= 1
local BONE_TYPE_PROXIMAL			= 2
local BONE_TYPE_INTERMEDIATE		= 3
local BONE_TYPE_DISTAL				= 4
]]

ENT.LeapToValveBipedBones = {
	
	[HAND_LEFT] = {
		bone = "ValveBiped.Bip01_L_Hand",
		Fingers = {
			[FINGER_TYPE_THUMB] = {
				Bones = {
					[BONE_TYPE_METACARPAL] = {
					}
				}
			},
						
		}
	},
	
	[HAND_RIGHT] = {
		bone = "ValveBiped.Bip01_R_Hand",
		Fingers = {
			Bones = {
				
			}
		}		
	}

}

function ENT:Initialize()
	if SERVER then
		self:SetNoDraw( true )
		self.LastFrame = nil
		self.LastFrameReceiveTime = 0
		self.OlderFrameReceiveTime = 0
		self.LastShadow = 0
		
		self.CurrentFrame = nil
		--the motion controller crap needs a valid physobj, because garry, it usually doesn't even need to
		
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetScale( math.Clamp( self:GetScale() , 0.1 , 3 ) )
		self.LeapShadowControllers = {}
		local conv = self.LeapToValveBipedBones
		for i = HAND_LEFT , HAND_RIGHT do
			self.LeapShadowControllers[i] = {}
			--self.LeapShadowControllers[i].Hand = self:CreatePhysShadow( nil , nil , conv[i].bone )
			
			if IsValid( self.LeapShadowControllers[i].Hand ) then
				self.LeapShadowControllers[i].Hand:SetIsLeft( i == HAND_LEFT )
			end
			
			self.LeapShadowControllers[i].Fingers = {}
			
			for j = FINGER_TYPE_THUMB , FINGER_TYPE_PINKY do
				self.LeapShadowControllers[i].Fingers[j] = {}
				self.LeapShadowControllers[i].Fingers[j].Bones = {}
				for k = BONE_TYPE_METACARPAL , BONE_TYPE_DISTAL do
					--local minb , maxb = 
					self.LeapShadowControllers[i].Fingers[j].Bones[k] = {}
					--self.LeapShadowControllers[i].Fingers[j].Bones[k].Bone = self:CreatePhysShadow( nil , nil , "" )--conv[i].Fingers[j].Bones[k].bone )
					
					if IsValid( self.LeapShadowControllers[i].Fingers[j].Bones[k].Bone ) then
						self.LeapShadowControllers[i].Fingers[j].Bones[k].Bone:SetIsLeft( i == HAND_LEFT )
						
					end
					
				end
			end
		end
		
		local hands = ents.Create( "sent_leap_hands" )
		--hands:SetParent( self:GetParent() )
		hands:SetOwner( self:GetParent() )
		--hands:SetTransmitWithParent( true )
		hands:SetController( self )
		hands:SetLocalPos( vector_origin )
		hands:Spawn()
		
		self:SetHandsEnt( hands )
	else
		--create the hands clientside model with the base c_hands
		--it'd probably be better if we actually hook in the buildbonepositions callback on the hands entity
		--although now that clientside models are garbage collected, they're not reliable anymore.
		--[[
		self:AddCallback("BuildBonePositions",function (self)
			self:BuildBonePositions()
		end)
		]]
		
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Scale" )
	self:NetworkVar( "Entity" , 0 , "HandsEnt" )
	--loop through the bone table, create a NetworkVar( "Entity" , id , "" ) with the name tied to the bone name itself
	--so on the client we can get the entity by the bone name
	
	for i = 1 , GMOD_MAXDTVARS - 1 do
		self:NetworkVar( "Entity" , i , "LeapBone"..i )
	end
end

function ENT:Draw()
end

if SERVER then
	function ENT:Think()
		local frame = self.CurrentFrame
		if not frame then return end
		
		for i = 1 , frame.HandsNumber do
			if frame.Hands[i].IsValid then
				
				local plypos = self:GetOwner():EyePos()
				local plyang = self:GetOwner():EyeAngles() 
				
				plypos , plyang = LocalToWorld( Vector( 50 , 0, -30 ) , Angle( 0 , 90 , 0 ) , plypos , plyang )
				
				local palmpos = frame.Hands[i].PalmPosition * self:GetScale()
				local palmang = frame.Hands[i].PalmDirection:Angle()
				local palmwith = frame.Hands[i].PalmWidth
				local palment = self.LeapShadowControllers[i - 1].Hand
				
				if not IsValid( palment ) then
					local minb = Vector( 2 * 0.5, palmwith * 0.5, palmwith * 0.5)
					local maxbb = minb * -1
					
					--palment = self:CreatePhysShadow( minb , maxbb )
					self.LeapShadowControllers[i - 1].Hand = palment
				end
				
				--these are local positions, move them to the player position, for now it's not needed
				palmpos , palmang = LocalToWorld( palmpos , palmang  , plypos , plyang )

				if IsValid( palment ) then
					palment:SetIsLeft( ( i - 1 ) == HAND_LEFT )
					palment:Update( palmpos , palmang , FrameTime() , self.OlderFrameReceiveTime , self.LastFrameReceiveTime )
				end
				
				for j=1, frame.Hands[i].FingersNumber do
					for k=1,frame.Hands[i].Fingers[j].BonesNumber do
						local bonepos = frame.Hands[i].Fingers[j].Bones[k].BonePosition * self:GetScale()
						local boneang = frame.Hands[i].Fingers[j].Bones[k].BoneDirection:Angle()
						local boneent = self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone
						local length = frame.Hands[i].Fingers[j].Bones[k].BoneLength * self:GetScale()
						local width = frame.Hands[i].Fingers[j].Bones[k].BoneWidth * self:GetScale()
						--localtoworld these to the palm position
						bonepos , boneang = LocalToWorld( bonepos , boneang  , plypos , plyang )
						

						if not IsValid( boneent ) then
							local minb = Vector(length * .5, width *.5, width*.5)
							local maxb = minb * -1
							--debugoverlay.BoxAngles( bonepos , minb, maxb, boneang , 0.15 )
							
							local maxbb = Vector( frame.Hands[i].Fingers[j].Bones[k].BoneLength * 0.5 , frame.Hands[i].Fingers[j].Bones[k].BoneWidth * 0.5 , frame.Hands[i].Fingers[j].Bones[k].BoneWidth * 0.5 )
							local minbb = maxbb * -1
							
							--if j == 1 and ( k - 1 ) == BONE_TYPE_INTERMEDIATE then
							
							--else
							if length ~= 0 and width ~= 0 then
								self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone = self:CreatePhysShadow( maxbb , minbb )
							end
							boneent = self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone
						end
						
						--frame.Hands[i].Fingers[j].Bones[k].BonePosition
						--frame.Hands[i].Fingers[j].Bones[k].BoneDirection
						--self.LeapShadowControllers[i].Fingers[j].Bones[k].Bone
						if IsValid( boneent ) then
							boneent:SetGrabStrength( frame.Hands[i].GrabStrength )
							boneent:SetIsLeft( ( i - 1 ) == HAND_LEFT )
							boneent:Update( bonepos , boneang , FrameTime() , self.OlderFrameReceiveTime , self.LastFrameReceiveTime )
							
							--debugoverlay.BoxAngles( boneent:GetPos() , boneent:GetMinSize(), boneent:GetMaxSize(), boneent:GetAngles() , 0.15 )
						end
					end
				end
			end
		end
		self:NextThink( CurTime() + engine.TickInterval() )
		return true
	end
end

function ENT:CreatePhysShadow( minb, maxb , handindex , fingertype , bonetype )
	
	local shadow = ents.Create( "sent_leap_physhadow" )
	if not shadow then
		return
	end
	
	local bipedbone = nil
	
	--Find the bone name from the hand index and bonetype
	
	if not fingertype or not bonetype then
		if self.LeapToValveBipedBones[handindex] then
			bipedbone = self.LeapToValveBipedBones[handindex].bone
		end
	else
		if self.LeapToValveBipedBones[handindex].Fingers[fingertype] and self.LeapToValveBipedBones[handindex].Fingers[fingertype].Bones[bonetype] then
			bipedbone = self.LeapToValveBipedBones[handindex].Fingers[fingertype].Bones[bonetype].bone
		end
	end
	
	--self["SetLeapBone"..self.LastShadow + 1]( self , shadow )
	shadow:SetOwner( self:GetOwner() )
	shadow:SetMinBounds( minb )
	shadow:SetMaxBounds( maxb )
	--shadow:SetOwner( self:GetOwner() )
	shadow:SetPos( self:GetOwner():GetPos() )
	shadow:SetScale( self:GetScale() )
	shadow:SetController( self )
	if bipedbone then
		shadow:SetAssociatedBone( bipedbone )
	end
	shadow:Spawn()
	
	--[[
	self.LastShadow = self.LastShadow + 1
	
	if self.LastShadow >= GMOD_MAXDTVARS then
		self.LastShadow = 0
	end
	]]
	
	return shadow
end

function ENT:AnalyzeLeapData( leapdata )
	self.LastFrame = self.CurrentFrame
	
	self.CurrentFrame = leapdata
	
	self.OlderFrameReceiveTime = self.LastFrameReceiveTime
	self.LastFrameReceiveTime = CurTime()
end


function ENT:GetAllPhysBones()
	local tb = {}
	
	for i = 1 , GMOD_MAXDTVARS - 1 do
		tb[1] = self["GetLeapBone"..i]( self )
	end
	
	return tb
end

function ENT:CanGrab( hitdata , askingbone )
	
	if hitdata.HitEntity:GetClass() == "sent_leap_physhadow" then
		return false
	end
	
	for i ,v in pairs( self:GetAllPhysBones() ) do
		if v ~= askingbone and v.TouchingPhysobj == hitdata.HitObject then
			return false
		end
	end
	
	return true
end


function ENT:PhysicsSimulate( physobj , delta )
end