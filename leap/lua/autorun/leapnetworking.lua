if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "leap" )
end

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
	local leap_convars = {
		scale = CreateConVar( "cl_leap_scale" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		updaterate = CreateConVar( "cl_leap_updaterate" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		fakebot = CreateConVar( "cl_leap_fakebotid" , "-1" ),
		posefromfile = CreateConVar( "cl_leap_posefromfile" , "" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
	}
	
	local leap_updatethrottle = 0
	
	local leap_version = ""
	
	if system.IsWindows() then
		leap_version = "win32.dll"
	elseif system.IsOSX() then
		leap_version = ""	--TODO: at some point
	elseif system.IsLinux() then
		leap_version = ""	--TODO: at some point
	else
		error( "OS not recognized by gmod?" )
	end
	
	if file.Exists( "lua/bin/gmcl_leap_" .. leap_version , "GAME" ) then 
		require( "leap" )
	end
	
	local function HasLeapMotion()
		return leap and leap.IsConnected()
	end
	
	local function LeapWriteFrameData( frame )
		
		local hands = frame:GetHands()
		local handsnumber = #hands
		
		net.WriteUInt( handsnumber, 8 )	--a byte is fine
		
		for i , v in pairs( hands ) do
			
			net.WriteBit( IsValid( v ) )
			
			if IsValid( v ) then
				net.WriteBit( v:IsLeft() )
				net.WriteVector( v:PalmPosition() )
				net.WriteNormal( v:PalmNormal() )
				net.WriteVector( v:PalmVelocity() )
				net.WriteFloat( v:PinchStrength() )
				net.WriteFloat( v:GrabStrength() )
				net.WriteFloat( v:PalmWidth() )
				
				--[[
				local arm = v:GetArm()
				net.WriteBit( arm:IsValid() )
				if IsValid( arm ) then
					net.WriteVector( arm:Center() )
					net.WriteNormal( arm:Direction() )
					net.WriteVector( arm:ElbowPosition() )
					net.WriteVector( arm:WristPosition() )
					net.WriteFloat( arm:Width() )
				end
				]]
				
				local fingers = v:GetFingers()
				net.WriteUInt( #fingers, 8 )	--a byte is fine
				
				for j,k in pairs( fingers ) do
					
					local bones = k:GetBones()
					
					net.WriteUInt( #bones , 8 )	-- a byte is fine
					
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
	
	local function LeapGetFrameFromFile( path )
		local frame = nil
		
		return frame
	end
	
	local function LeapMotionThink()
		if not IsValid( LocalPlayer() ) then
			return
		end
		
		if leap_updatethrottle > CurTime() then
			return
		end
		
		leap_updatethrottle = CurTime() + math.Clamp( leap_convars.updaterate:GetFloat() , 0.01 , 1 )
		
		if not HasLeapMotion() then
			return
		end
		
		local frame = nil
		
		local serializedframepath = leap_convars.posefromfile:GetString()
		
		if serializedframepath and #serializedframepath > 1 then
			frame = LeapGetFrameFromFile( serializedframepath )
		else
			frame = leap.Frame()
		end
		
		if not IsValid( frame ) then return end
		
		net.Start( "leap" , true )
			
			--"redirect" the command to the bot, this is also checked serverside
			
			local botid = leap_convars.fakebot:GetInt()
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
	
	local function AnalyzeLeapData( ply , framedata )
		--TODO: clamp all the values we've got from the framedata
		--otherwise people might maliciously exploit it and send their own positions and fuck shit
		
		--there's no other way to go with this, since we're pretty much trusting the client anyway
		
		if HasLeapController( ply ) then
			ply._LeapController:AnalyzeLeapData( framedata )
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
		frame.HandsNumber = net.ReadUInt( 8 )	--a byte is fine
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
				
				--[[
				frame.Hands[i].Arm = {}
				frame.Hands[i].Arm.IsValid = tobool( net.ReadBit() )
				if frame.Hands[i].Arm.IsValid then
					frame.Hands[i].Arm.Center = net.ReadVector()
					frame.Hands[i].Arm.Direction = net.ReadNormal()
					frame.Hands[i].Arm.ElbowPosition = net.ReadVector()
					frame.Hands[i].Arm.WristPosition = net.ReadVector()
					frame.Hands[i].Arm.Width = net.ReadFloat()
				end
				]]
				
				frame.Hands[i].FingersNumber = 	net.ReadUInt( 8 )	--a byte is fine
				frame.Hands[i].Fingers = {}
				for j = 1 , frame.Hands[i].FingersNumber do
					frame.Hands[i].Fingers[j] = {}
					frame.Hands[i].Fingers[j].BonesNumber = net.ReadUInt( 8 )	--a byte is fine
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