#include "Leap.h"
#include "GMod_LeapHand.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapHand::TYPE = 100; //random


void LeapHand::DefineMeta( lua_State *state)
{
	LUA->CreateMetaTableType( "LeapHand" , LeapHand::TYPE );
		LUA->Push( -1 );
		LUA->SetField( -2 , "__index" );

		LUA->PushCFunction( LeapHand::tostring );
		LUA->SetField( -2 , "__tostring" );

		LUA->PushString( "LeapHand" );
		LUA->SetField( -2 , "__type" );

		LUA->PushCFunction( LeapHand::IsValid );
		LUA->SetField( -2 , "IsValid" );
	LUA->Pop();
}

Hand *LeapHand::Get( lua_State *state , int pos )
{
	if ( !LUA->IsType( pos , LeapHand::TYPE ) ) return nullptr;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->GetUserdata();

	if ( !ud ) return nullptr;

	Hand *hand = ( Hand * ) ud->data;
	if ( !hand ) return nullptr;

	return hand;
}

void LeapHand::Push( lua_State * state, Leap::Hand *Hand )
{
	if ( !Hand ) return;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = Hand;
	ud->type = LeapHand::TYPE;

	LUA->CreateMetaTableType( "LeapHand" , LeapHand::TYPE );
	LUA->SetMetaTable( -2 );
}

int LeapHand::tostring( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushString( hand->toString().c_str() );

	return 1;
}


int LeapHand::IsValid( lua_State *state ) {
	Hand *hand = Get(state);
	if ( !hand ) return 0;

	LUA->PushBool( hand->isValid() );

	return 1;
}