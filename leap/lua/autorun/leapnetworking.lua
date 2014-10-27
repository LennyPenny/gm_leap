if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "leap" )
end

local INT_BITS = 8

HAND_LEFT = 0
HAND_RIGHT = 1

FINGER_TYPE_THUMB 	= 0
FINGER_TYPE_INDEX		= 1
FINGER_TYPE_MIDDLE	= 2
FINGER_TYPE_RING		= 3
FINGER_TYPE_PINKY		= 4

BONE_TYPE_METACARPAL			= 0
BONE_TYPE_PROXIMAL			= 1
BONE_TYPE_INTERMEDIATE		= 2
BONE_TYPE_DISTAL				= 3


GESTURE_TYPE_INVALID			= 0
GESTURE_TYPE_SWIPE			= 1
GESTURE_TYPE_CIRCLE			= 2
GESTURE_TYPE_SCREEN_TAP		= 3
GESTURE_TYPE_KEY_TAP			= 4

if CLIENT then
	local leap_scale = CreateConVar( "cl_leap_scale" , 0.1 , FCVAR_ARCHIVE + FCVAR_USERINFO )
	local leap_updaterate = CreateConVar( "cl_leap_updaterate" , 0.1 , FCVAR_ARCHIVE + FCVAR_USERINFO )
	
	local leap_fakebothand = CreateConVar( "cl_leap_fakebotid" , -1 , FCVAR_USERINFO )
	
	local leap_updatethrottle = 0
	--Code to send and debug the leap motion to the server here
	
	if file.Exists( "lua/bin/gmcl_leap_win32.dll" , "GAME" ) then 
		require( "leap" )
	end
	
	local function HasLeapMotion()
		return leap and leap.IsConnected()
	end
	
	
	--[[
		
		FINGER_TYPE_THUMB
		FINGER_TYPE_INDEX
		FINGER_TYPE_MIDDLE
		FINGER_TYPE_RING
		FINGER_TYPE_PINKY
		
		BONE_TYPE_METACARPAL
		BONE_TYPE_PROXIMAL
		BONE_TYPE_INTERMEDIATE
		BONE_TYPE_DISTAL

		GESTURE_TYPE_INVALID
		GESTURE_TYPE_SWIPE
		GESTURE_TYPE_CIRCLE
		GESTURE_TYPE_SCREEN_TAP
		GESTURE_TYPE_KEY_TAP
	]]
	
	local function LeapWriteFrameData( frame )
		--net.WriteInt( frame:GetFrameNumber() , INT_BITS ) --write frame number
		
		local hands = frame:GetHands()
		local handsnumber = math.Clamp( #hands , 0 , 2 )--write number of hands, clamp it first though so we don't send extra hands
		
		net.WriteInt( handsnumber, INT_BITS )
		
		for i , v in pairs( hands ) do
			
			--ignore extra hands! we don't care if vinh wants to interfere with it when we're playing in front of him ( hot wordplay )
			if i > 2 then continue end
			
			--write if it's valid
			net.WriteBit( IsValid( v ) )
			
			if IsValid( v ) then
				net.WriteBit( v:IsLeft() ) --write if it's right
				net.WriteVector( v:PalmPosition() )--write position
				net.WriteNormal( v:PalmNormal() )--write direction
				net.WriteVector( v:PalmVelocity() )--write velocity
				net.WriteFloat( v:PinchStrength() )--write pinch strength
				net.WriteFloat( v:GrabStrength() )--write grab strength
				net.WriteFloat( v:PalmWidth() )	--write palm width
				
				local fingers = v:GetFingers()
				net.WriteInt( #fingers, INT_BITS ) --write finger numbers, 5 usually
				
				
				for j,k in pairs( fingers ) do
					
					local bones = k:GetBones()
					
					net.WriteInt( #bones , INT_BITS )
					
					for _ , _k in pairs( bones ) do
						
						net.WriteVector( _k:Center() )
						net.WriteNormal( _k:Direction() )
						net.WriteFloat( _k:Length() )
						net.WriteFloat( _k:Width() )
					end
								
				end
				
			
			end

		end
	end
	
	local function LeapMotionThink()
		if not IsValid( LocalPlayer() ) then
			return
		end
		
		if leap_updatethrottle > CurTime() then
			return
		end
		
		leap_updatethrottle = CurTime() + math.Clamp( leap_updaterate:GetFloat() , 0.01 , 1 )
		if not HasLeapMotion() then
			return
		end
		
		
		
		--this way if the updaterate is 0 or the same as CurTime it will still go trough
		
		local frame = leap.Frame()
		
		if not IsValid( frame ) then return end
		
		net.Start( "leap" , true )--do the net start shit here
		local botid = leap_fakebothand:GetInt()
		local botent = Player( botid )
		
		if IsValid( botent ) then
			net.WriteEntity( botent )
		else
			net.WriteEntity( NULL )
		end
		
		LeapWriteFrameData( frame )
		
		net.SendToServer()

	end
	
	
	hook.Add( "Think" , "LeapMotionThink" , LeapMotionThink )
	
else

	util.AddNetworkString( "LeapMotion" )
	
	--Receive the client messages about the leap motion here
	--Try to lerp the values the client gave you 
	local function CreateLeapController( ply )
		local controller = ents.Create( "sent_leap_controller" )
		if not IsValid( controller ) then return end
		
		controller:SetParent( ply )
		controller:SetTransmitWithParent( true )
		controller:SetOwner( ply )
		controller:SetPos( ply:EyePos() )
		controller:SetScale( ply:GetInfoNum( "cl_leap_scale" , 0.25 ) )
		controller:Spawn()
		ply._LeapController = controller
	end
	
	local function HasLeapController( ply )
		return IsValid( ply._LeapController )
	end
	
	local function AnalyzeLeapData( ply , data )
		
		if HasLeapController( ply ) then
			ply._LeapController:AnalyzeLeapData( data )
		end
	end
	
	local function LeapMotionReceive( len , ply )
		local overrideply = net.ReadEntity()
		
		if IsValid( overrideply ) and ply:IsBot() then
			ply = overrideply
		end
		
		if not IsValid( ply ) then
			return
		end
		
		if not HasLeapController( ply ) then
			CreateLeapController( ply )
		end
		
		local frame = {}
		--frame.FrameNumber = net.ReadInt( INT_BITS )
		frame.HandsNumber = net.ReadInt( INT_BITS )
		frame.Hands = {}
		
		for i=1,frame.HandsNumber do
			frame.Hands[i] = {}
			frame.Hands[i].IsValid = tobool( net.ReadBit() )
			if frame.Hands[i].IsValid then
				frame.Hands[i].IsLeft = tobool( net.ReadBit() )
				frame.Hands[i].IsRight = not frame.Hands[i].IsLeft
				frame.Hands[i].PalmPosition = net.ReadVector()
				frame.Hands[i].PalmDirection = net.ReadNormal()
				frame.Hands[i].PalmVelocity = net.ReadVector()
				frame.Hands[i].PinchStrength = net.ReadFloat()
				frame.Hands[i].GrabStrength = net.ReadFloat()
				frame.Hands[i].PalmWidth = net.ReadFloat()
				
				frame.Hands[i].FingersNumber = 	net.ReadInt( INT_BITS )
				frame.Hands[i].Fingers = {}
				for j = 1 , frame.Hands[i].FingersNumber do
					frame.Hands[i].Fingers[j] = {}
					frame.Hands[i].Fingers[j].BonesNumber = net.ReadInt( INT_BITS )
					frame.Hands[i].Fingers[j].Bones = {}
					
					for k=1,frame.Hands[i].Fingers[j].BonesNumber do
						frame.Hands[i].Fingers[j].Bones[k] = {}
						frame.Hands[i].Fingers[j].Bones[k].BonePosition = net.ReadVector()
						frame.Hands[i].Fingers[j].Bones[k].BoneDirection = net.ReadNormal()
						frame.Hands[i].Fingers[j].Bones[k].BoneLength = net.ReadFloat()
						frame.Hands[i].Fingers[j].Bones[k].BoneWidth = net.ReadFloat()
						
						local bone = frame.Hands[i].Fingers[j].Bones[k]
						--debugoverlay.BoxAngles( bone.BonePosition , Vector(bone.BoneLength * .5, bone.BoneWidth *.5, bone.BoneWidth*.5), Vector(-bone.BoneLength*.5, -bone.BoneWidth*.5, -bone.BoneWidth*.5), bone.BoneDirection:Angle() , 0.15 )
					end
				
				end
			end
		end
		
		AnalyzeLeapData( ply , frame )
		
	end
	net.Receive( "leap" , LeapMotionReceive)
end