#include "Leap.h"

#include "util.h"

#include "GMod_LeapFrame.h"
#include "GMod_LeapHand.h"
#include "GMod_LeapFinger.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapFinger::TYPE = 101; //random


void LeapFinger::DefineMeta( lua_State *state )
{
	LUA->CreateMetaTableType( "LeapFinger" , LeapFinger::TYPE );
		LUA->Push( -1 );
		LUA->SetField( -2 , "__index" );

		LUA->PushCFunction( LeapFinger::tostring );
		LUA->SetField( -2 , "__tostring" );

		LUA->PushString( "LeapFinger" );
		LUA->SetField( -2 , "__type" );

		LUA->PushCFunction(LeapFinger::Bone);
		LUA->SetField( -2, "GetBone" );

		LUA->PushCFunction( LeapFinger::Direction );
		LUA->SetField( -2, "Direction" );

		LUA->PushCFunction( LeapFinger::Frame );
		LUA->SetField( -2, "GetFrame" );

		LUA->PushCFunction( LeapFinger::Hand );
		LUA->SetField( -2, "GetHand" );

		LUA->PushCFunction( LeapFinger::ID );
		LUA->SetField( -2, "ID" );

		LUA->PushCFunction( LeapFinger::IsExtended );
		LUA->SetField( -2, "IsExtended" );

		LUA->PushCFunction( LeapFinger::IsFinger );
		LUA->SetField( -2, "IsFinger" );

		LUA->PushCFunction( LeapFinger::IsTool );
		LUA->SetField( -2, "IsTool" );

		LUA->PushCFunction( LeapFinger::IsValid );
		LUA->SetField( -2, "IsValid" );

		LUA->PushCFunction( LeapFinger::JointPosition );
		LUA->SetField( -2, "JoinPosition" );

		LUA->PushCFunction( LeapFinger::Length );
		LUA->SetField( -2, "Length" );

		LUA->PushCFunction( LeapFinger::StabilizedTipPosition );
		LUA->SetField( -2, "StabilizedTipPosition" );

		LUA->PushCFunction( LeapFinger::TimeVisible );
		LUA->SetField( -2, "TimeVisible" );

		LUA->PushCFunction( LeapFinger::TipPosition );
		LUA->SetField( -2, "TipPosition" );

		LUA->PushCFunction( LeapFinger::TipVelocity );
		LUA->SetField( -2, "TipVelocity" );

		LUA->PushCFunction( LeapFinger::TouchDistance );
		LUA->SetField( -2, "TouchDistance" );

		LUA->PushCFunction( LeapFinger::TouchZone );
		LUA->SetField( -2, "TouchZone" );

		LUA->PushCFunction( LeapFinger::Type );
		LUA->SetField( -2, "Type" );

		LUA->PushCFunction( LeapFinger::Width );
		LUA->SetField( -2, "Width" );

	LUA->Pop();
}

Finger *LeapFinger::Get( lua_State *state , int pos )
{
	if ( !LUA->IsType( pos , LeapFinger::TYPE ) ) return nullptr;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->GetUserdata();

	if ( !ud ) return nullptr;

	Finger *finger = ( Finger * ) ud->data;
	if ( !finger ) return nullptr;

	return finger;
}

void LeapFinger::Push( lua_State * state, Leap::Finger *finger )
{
	if ( !finger ) return;

	Lua::UserData *ud = ( Lua::UserData * )LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = finger;
	ud->type = LeapFinger::TYPE;

	LUA->CreateMetaTableType( "LeapFinger" , LeapFinger::TYPE );
	LUA->SetMetaTable( -2 );
}

int LeapFinger::tostring( lua_State *state) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushString( finger->toString().c_str() );

	return 1;
}


int LeapFinger::Bone( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	//TODO

	return 1;
}

int LeapFinger::Direction( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	PushSourceVector( state, new Vector( finger->direction() ) );

	return 1;
}

int LeapFinger::Frame( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LeapFrame::Push( state, new Leap::Frame( finger->frame() ) );

	return 1;
}

int LeapFinger::Hand( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LeapHand::Push( state, new Leap::Hand( finger->hand() ) );

	return 1;
}

int LeapFinger::ID( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushNumber( finger->id() );

	return 1;
}

int LeapFinger::IsExtended( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushBool( finger->isExtended() );

	return 1;
}

int LeapFinger::IsFinger( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushBool( finger->isFinger() );

	return 1;
}

int LeapFinger::IsTool( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushBool( finger->isTool() );

	return 1;
}

int LeapFinger::IsValid( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushBool( finger->isValid() );

	return 1;
}

int LeapFinger::JointPosition( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	//TODO

	return 1;
}

int LeapFinger::Length( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushNumber( finger->length() );

	return 1;
}

int LeapFinger::StabilizedTipPosition( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	PushSourceVector( state, new Vector( finger->stabilizedTipPosition() ) );

	return 1;
}

int LeapFinger::TimeVisible( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushNumber( finger->timeVisible() );

	return 1;
}

int LeapFinger::TipPosition( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	PushSourceVector( state, new Vector( finger->tipPosition() ) );

	return 1;
}

int LeapFinger::TipVelocity( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	PushSourceVector( state, new Vector( finger->tipVelocity() ) );

	return 1;
}

int LeapFinger::TouchDistance( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushNumber( finger->touchDistance() );

	return 1;
}

int LeapFinger::TouchZone( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	//TODO

	return 1;
}

int LeapFinger::Type( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	//TODO

	return 1;
}

int LeapFinger::Width( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushNumber(finger->width());

	return 1;
}