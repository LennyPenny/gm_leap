#include "GarrysMod\Lua\Interface.h"

#include "Leap.h"

#include "GMod_LeapFrame.h"
#include "GMod_LeapHand.h"
#include "GMod_LeapFinger.h"
#include "GMod_LeapBone.h"
#include "GMod_LeapArm.h"

using namespace GarrysMod;
using namespace Leap;
using namespace GModLeap;

Controller *controller = nullptr;
void *fake_heap[ sizeof( Controller ) ];

int leap_IsConnected( lua_State *state ) {
	LUA->PushBool( controller->isConnected() );

	return 1;
}

int leap_Frame( lua_State *state ) {
	
	//Jvs:	I'm using the copy constructor due to the controller cleaning up the history after a few ticks
	//		we're gonna have to add a __gc method to the frame, but this also stops the crashing bullshit
	
	Frame *frame;
	
	if ( LUA->Top() > 0 ) {
		frame = new Frame( controller->frame( LUA->CheckNumber() ) );
	}
	else {
		frame = new Frame( controller->frame() );
	}

	LeapFrame::Push( state , frame );

	return 1;
}

int leap_DeserializeFrame( lua_State *state ) {
	
	LUA->CheckType( 1 , Lua::Type::STRING );
	
	unsigned int serializedframelen = 0;
	const char *serializedframe = LUA->GetString( 1 , &serializedframelen );

	std::string stdserializedframe( serializedframe , serializedframelen );

	Frame *newframe = new Frame();
	newframe->deserialize( stdserializedframe );

	LeapFrame::Push( state , newframe );
	
	return 1;
}



GMOD_MODULE_OPEN() {
	
	controller = new ( fake_heap ) Controller;

	LUA->PushSpecial( Lua::SPECIAL_GLOB );

		LUA->CreateTable();

			LUA->PushCFunction( leap_IsConnected );
			LUA->SetField( -2 , "IsConnected" );

			LUA->PushCFunction( leap_Frame );
			LUA->SetField( -2 , "Frame" );

			LUA->PushCFunction( leap_DeserializeFrame );
			LUA->SetField( -2 , "DeserializeFrame" );

		LUA->SetField( -2 , "leap" );

		LeapFrame::DefineMeta( state );

		LeapHand::DefineMeta( state );

		LeapFinger::DefineMeta( state );

		LeapBone::DefineMeta( state );

		LeapArm::DefineMeta( state );

	LUA->Pop();

	return 0;
}

GMOD_MODULE_CLOSE() {
	if ( controller ){
		controller->~Controller();
		controller = nullptr;
	}
	return 0;
}