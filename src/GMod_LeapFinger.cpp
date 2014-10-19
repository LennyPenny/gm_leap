#include "Leap.h"
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

		LUA->PushCFunction( LeapFinger::IsValid );
		LUA->SetField( -2 , "IsValid" );
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


int LeapFinger::IsValid( lua_State *state ) {
	Finger *finger = Get( state );
	if ( !finger ) return 0;

	LUA->PushBool( finger->isValid() );

	return 1;
}