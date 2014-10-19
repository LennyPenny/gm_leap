#include "Leap.h"
#include "util.h"

using namespace GarrysMod;

void GModLeap::PushSourceVector( lua_State *state, Leap::Vector *vector ) {
	if ( !vector ) return;

	SourceVector *svector = new SourceVector();
	svector->x = vector->x;
	svector->y = vector->y;
	svector->z = vector->z;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = svector;
	ud->type = Lua::Type::VECTOR;

	LUA->CreateMetaTableType( "Vector", Lua::Type::VECTOR );
	LUA->SetMetaTable( -2 );
}