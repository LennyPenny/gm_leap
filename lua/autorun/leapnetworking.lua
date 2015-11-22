if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "leap" )
end

--TODO: add these defines to the leap table on the server, and merge them on the leap module table on the client

SHADOWTYPE_PALM = 0
SHADOWTYPE_FINGERBONE = 1
SHADOWTYPE_ARM = 2

HAND_LEFT = 0
HAND_RIGHT = 1

FINGER_TYPE_THUMB 		= 0
FINGER_TYPE_INDEX		= 1
FINGER_TYPE_MIDDLE		= 2
FINGER_TYPE_RING		= 3
FINGER_TYPE_PINKY		= 4

BONE_TYPE_METACARPAL		= 0
BONE_TYPE_PROXIMAL			= 1
BONE_TYPE_INTERMEDIATE		= 2
BONE_TYPE_DISTAL			= 3

GESTURE_TYPE_INVALID		= 0
GESTURE_TYPE_SWIPE			= 1
GESTURE_TYPE_CIRCLE			= 2
GESTURE_TYPE_SCREEN_TAP		= 3
GESTURE_TYPE_KEY_TAP		= 4


--this function takes a table, not the actual frame userdata
local function LeapWriteNetFrame( frame )
	net.WriteUInt( frame.HandsNumber , 8 )	--a byte is fine
	
	for i = 1 , frame.HandsNumber do
		
		net.WriteBit( frame.Hands[i].IsValid )
		if frame.Hands[i].IsValid then
			net.WriteBit( frame.Hands[i].IsLeft )
			net.WriteVector( frame.Hands[i].PalmPosition )
			net.WriteNormal( frame.Hands[i].PalmDirection )
			net.WriteVector( frame.Hands[i].PalmVelocity )
			net.WriteFloat( frame.Hands[i].PinchStrength )
			net.WriteFloat( frame.Hands[i].GrabStrength )
			net.WriteFloat( frame.Hands[i].PalmWidth )
			
			net.WriteBit( frame.Hands[i].Arm.IsValid )
			if frame.Hands[i].Arm.IsValid then
				net.WriteVector( frame.Hands[i].Arm.ArmPosition )
				net.WriteNormal( frame.Hands[i].Arm.ArmDirection )
				net.WriteVector( frame.Hands[i].Arm.ElbowPosition )
				net.WriteVector( frame.Hands[i].Arm.WristPosition )
				net.WriteFloat( frame.Hands[i].Arm.ArmWidth )
			end			
			
			net.WriteUInt( frame.Hands[i].FingersNumber , 8 )
			for j = 1 , frame.Hands[i].FingersNumber do
				net.WriteUInt( frame.Hands[i].Fingers[j].BonesNumber , 8 )
				
				for k=1,frame.Hands[i].Fingers[j].BonesNumber do
					net.WriteVector( frame.Hands[i].Fingers[j].Bones[k].BonePosition )
					net.WriteNormal( frame.Hands[i].Fingers[j].Bones[k].BoneDirection )
					net.WriteFloat( frame.Hands[i].Fingers[j].Bones[k].BoneLength )
					net.WriteFloat( frame.Hands[i].Fingers[j].Bones[k].BoneWidth )
				end
			end
		end
	end	

end

local function LeapReadNetFrame()
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
			
			--TODO:enable once we have arms support
			
			frame.Hands[i].Arm = {}
			frame.Hands[i].Arm.IsValid = tobool( net.ReadBit() )
			if frame.Hands[i].Arm.IsValid then
				frame.Hands[i].Arm.ArmPosition = net.ReadVector()
				frame.Hands[i].Arm.ArmDirection = net.ReadNormal()
				frame.Hands[i].Arm.ElbowPosition = net.ReadVector()
				frame.Hands[i].Arm.WristPosition = net.ReadVector()
				frame.Hands[i].Arm.ArmWidth = net.ReadFloat()
			end
			
			
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
					--debugoverlay.BoxAngles( bone.BonePosition , Vector(bone.BoneLength * .5, bone.BoneWidth *.5, bone.BoneWidth*.5), Vector(-bone.BoneLength*.5, -bone.BoneWidth*.5, -bone.BoneWidth*.5), bone.BoneDirection:Angle() , 0.05 )
				end
			end
		end
	end
	
	return frame
end

if CLIENT then
	local leap_convars = {
		scale = CreateConVar( "cl_leap_scale" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		updaterate = CreateConVar( "cl_leap_updaterate" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		fakebot = CreateConVar( "cl_leap_fakebotid" , "-1" ),	--this will be removed when I'm done testing the networking
		posefromfile = CreateConVar( "cl_leap_posefromfile" , "" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
	}
	
	local leap_updatethrottle = 0
	local leap_version = ""
	local leap_lastframe = nil
	
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
		
		if not leap then
			return false
		end
		
		--we count the player as having the leap if he's using a serialized frame, the module still needs to be loaded though
		if leap_convars.posefromfile:GetString() and #leap_convars.posefromfile:GetString() > 0 then
			return true
		end
		
		return leap.IsConnected()
	end
	
	--this function puts all the userdata we need into a table
	local function LeapFrameToTable( userdataframe )
		
		local frame = {}
		local hands = userdataframe:GetHands()
		
		frame.HandsNumber = #hands
		frame.Hands = {}
		
		for i , v in pairs( hands ) do
			frame.Hands[i] = {}
			frame.Hands[i].IsValid = IsValid( v )
			if frame.Hands[i].IsValid then
				frame.Hands[i].IsLeft = v:IsLeft()
				frame.Hands[i].IsRight = not frame.Hands[i].IsLeft
				frame.Hands[i].PalmPosition = v:PalmPosition()
				frame.Hands[i].PalmDirection = v:PalmNormal()
				frame.Hands[i].PalmVelocity = v:PalmVelocity()
				frame.Hands[i].PinchStrength = v:PinchStrength()
				frame.Hands[i].GrabStrength = v:GrabStrength()
				frame.Hands[i].PalmWidth = v:PalmWidth()
				
				
				local arm = v:GetArm()
				
				frame.Hands[i].Arm = {}
				frame.Hands[i].Arm.IsValid = arm:IsValid()
				if frame.Hands[i].Arm.IsValid then
					frame.Hands[i].Arm.ArmPosition = arm:Center()
					frame.Hands[i].Arm.ArmDirection = arm:Direction()
					frame.Hands[i].Arm.ElbowPosition = arm:ElbowPosition()
					frame.Hands[i].Arm.WristPosition = arm:WristPosition()
					frame.Hands[i].Arm.ArmWidth = arm:Width()
				end
				
				local fingers = v:GetFingers()
				
				frame.Hands[i].FingersNumber = 	#fingers
				frame.Hands[i].Fingers = {}
				for j, finger in pairs( fingers ) do
					local bones = finger:GetBones()
					
					frame.Hands[i].Fingers[j] = {}
					frame.Hands[i].Fingers[j].BonesNumber = #bones	--a byte is fine
					frame.Hands[i].Fingers[j].Bones = {}
					
					for k , _k in pairs( bones ) do
						frame.Hands[i].Fingers[j].Bones[k] = {}
						frame.Hands[i].Fingers[j].Bones[k].BonePosition = _k:Center()
						frame.Hands[i].Fingers[j].Bones[k].BoneDirection = _k:Direction()
						frame.Hands[i].Fingers[j].Bones[k].BoneLength = _k:Length()
						frame.Hands[i].Fingers[j].Bones[k].BoneWidth = _k:Width()
					end
				end
			end
		end
		
		return frame
	end
	
	local function LeapGetFrameFromFile( path )
		local frame = nil
		-- read the file from "DATA" in binary mode and then feed the string to leap.DeserializeFrame()
		
		local framefile = file.Open( path , "rb" , "DATA" )
		
		if framefile then
			local str = framefile:Read( framefile:Size() )
			frame = leap.DeserializeFrame( str )
			framefile:Close()
		end
		
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
		end
		
		--default back to getting it from the leap
		
		if not IsValid( frame ) then
			frame = leap.Frame()
		end
		
		if not IsValid( frame ) then 
			return
		end
		
		leap_lastframe = frame
		
		local luaframe = LeapFrameToTable( frame )
		
		net.Start( "leap" , true )	--send an unreliable message
			--"redirect" the command to the bot, this is also checked serverside
			
			local botid = leap_convars.fakebot:GetInt()
			local botent = Player( botid )
			
			net.WriteEntity( IsValid( botent ) and botent or NULL )
			
			LeapWriteNetFrame( luaframe )
			
		net.SendToServer()

	end
	hook.Add( "Think" , "LeapMotionThink" , LeapMotionThink )
	
	concommand.Add( "leap_writeframe" , function( ply , cmd , args , fullstr )
		if not HasLeapMotion() then
			return
		end
		
		local path = args[1]
		
		if not path then
			MsgN( "leap_writeframe <filename.txt>" )
			return
		end
			
		local currentframe = leap_lastframe
		
		if not IsValid( currentframe ) then
			return
		end
		
		local serializedframe = currentframe:Serialize()
		
		local framefile = file.Open( path , "wb" , "DATA" )
		if framefile then
			framefile:Write( serializedframe )
			framefile:Close()
		end
		
	end )
	
else
	
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
		--otherwise people might maliciously exploit it and send their own positions and fuck shit up with global positions
		
		--there's no other way to go with this, since we're pretty much trusting the client anyway
		
		if HasLeapController( ply ) then
			ply._LeapController:AnalyzeLeapData( framedata )
		end
		
	end
	
	local function LeapMotionReceive( len , ply )
		local overrideply = net.ReadEntity()
		
		if IsValid( overrideply ) and overrideply:IsPlayer() and overrideply:IsBot() then
			ply = overrideply
		end
		
		if not IsValid( ply ) then
			return
		end
		
		if not HasLeapController( ply ) then
			CreateLeapController( ply )
		end
		
		local frame = LeapReadNetFrame()
		
		AnalyzeLeapData( ply , frame )
		
	end
	net.Receive( "leap" , LeapMotionReceive)
end