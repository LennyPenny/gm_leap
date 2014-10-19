#include "Leap.h"
#include "util.h"

using namespace GarrysMod;

void GModLeap::PushSourceVector( lua_State *state, Leap::Vector *vector ) {
	if ( !vector ) return;

	LUA->PushSpecial( Lua::SPECIAL_GLOB );

	LUA->GetField( -1, "Vector" );
	LUA->PushNumber( vector->x );
	LUA->PushNumber( vector->y );
	LUA->PushNumber( vector->z );
	LUA->Call( 3, 1 );
	LUA->Remove( -2 );
}