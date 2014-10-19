#include "GMod_LeapFrame.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapFrame::TYPE = 99; //random


void LeapFrame::DefineMeta( lua_State * state )
{
	LUA->CreateMetaTableType( "LeapFrame" , LeapFrame::TYPE );
		LUA->Push( -1 );
		LUA->SetField( -2 , "__index" );

		LUA->PushCFunction( LeapFrame::tostring );
		LUA->SetField( -2 , "__tostring" );

		LUA->PushString( "LeapFrame" );
		LUA->SetField( -2 , "__type" );

		LUA->PushCFunction( LeapFrame::Serialize );
		LUA->SetField( -2 , "Serialize" );

		LUA->PushCFunction( LeapFrame::IsValid );
		LUA->SetField( -2 , "IsValid" );
	LUA->Pop();
}


Frame * LeapFrame::Get( lua_State * state , int pos )
{
	if ( !LUA->IsType( pos , LeapFrame::TYPE ) ) return nullptr;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->GetUserdata();

	if ( !ud ) return nullptr;

	Frame *frame = ( Frame * ) ud->data;
	if ( !frame ) return nullptr;

	return frame;
}

void LeapFrame::Push( lua_State * state , Leap::Frame * frame )
{
	if ( !frame ) return;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = frame;
	ud->type = LeapFrame::TYPE;

	LUA->CreateMetaTableType( "LeapFrame" , LeapFrame::TYPE );
	LUA->SetMetaTable( -2 );
}

int LeapFrame::tostring( lua_State *state ) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	LUA->PushString( frame->toString().c_str() );

	return 1;
}

int LeapFrame::CurrentFramesPerSecond( lua_State *state ) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	LUA->PushNumber( frame->currentFramesPerSecond() );

	return 1;
}

int LeapFrame::Finger( lua_State *state) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	//TODO

	return 1;
}

int LeapFrame::Fingers(lua_State* state) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	//TODO

	return 1;
}

int LeapFrame::IsValid(lua_State* state) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	LUA->PushBool( frame->isValid() );
	return 1;
}

int LeapFrame::Serialize(lua_State* state) {
	Frame *frame = Get( state );
	if ( !frame ) return 0;

	LUA->PushString( frame->serialize().c_str() );
	return 1;
}

