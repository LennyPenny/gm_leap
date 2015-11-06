#include "Leap.h"

#include "util.h"

#include "GMod_LeapFrame.h"
#include "GMod_LeapHand.h"
#include "GMod_LeapFinger.h"
#include "GMod_LeapBone.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapBone::TYPE = 102; //random

void LeapBone::DefineMeta( lua_State *state ) {
	LUA->CreateMetaTableType( "LeapBone", LeapBone::TYPE );

		LUA->Push( -1 );
		LUA->SetField( -2, "__index" );

		LUA->PushCFunction( LeapBone::tostring );
		LUA->SetField( -2, "__tostring" );

		LUA->PushString( "LeapBone" );
		LUA->SetField( -2, "__type" );

		LUA->PushCFunction( LeapBone::gc );
		LUA->SetField( -2, "__gc" );

		LUA->PushCFunction( LeapBone::Basis );
		LUA->SetField( -2, "Basis" );

		LUA->PushCFunction( LeapBone::Center );
		LUA->SetField( -2, "Center" );

		LUA->PushCFunction( LeapBone::Direction );
		LUA->SetField( -2, "Direction" );

		LUA->PushCFunction( LeapBone::IsValid );
		LUA->SetField( -2, "IsValid" );

		LUA->PushCFunction( LeapBone::Length );
		LUA->SetField( -2, "Length" );

		LUA->PushCFunction( LeapBone::NextJoint );
		LUA->SetField( -2, "NextJoint" );

		LUA->PushCFunction( LeapBone::PrevJoint );
		LUA->SetField( -2, "PrevJoint" );

		LUA->PushCFunction( LeapBone::Type );
		LUA->SetField( -2, "Type" );

		LUA->PushCFunction( LeapBone::Width );
		LUA->SetField( -2, "Width" );

	LUA->Pop();
}

Bone *LeapBone::Get( lua_State *state, int pos ) {
	if ( !LUA->IsType( pos, LeapBone::TYPE ) ) return nullptr;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->GetUserdata();

	if ( !ud ) return nullptr;

	Bone *bone = ( Bone * ) ud->data;
	if ( !bone ) return nullptr;

	return bone;
}

void LeapBone::Push( lua_State * state, Leap::Bone *bone ) {
	if ( !bone ) return;

	Lua::UserData *ud = ( Lua::UserData * )LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = bone;
	ud->type = LeapBone::TYPE;

	LUA->CreateMetaTableType( "LeapBone", LeapBone::TYPE );
	LUA->SetMetaTable( -2 );
}

int LeapBone::tostring( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	LUA->PushString( bone->toString().c_str() );

	return 1;
}

int LeapBone::gc( lua_State *state ) {
	Bone *bone= Get( state );
	if ( !bone ) return 0;

	delete[] bone;

	return 1;
};

int LeapBone::Basis( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	//TODO

	return 1;
}

int LeapBone::Center( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	PushSourceVector( state, &bone->center() );

	return 1;
}

int LeapBone::Direction( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	PushSourceVector( state, &bone->direction() );

	return 1;
}

int LeapBone::IsValid( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	LUA->PushBool( bone->isValid() );

	return 1;
}

int LeapBone::Length( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	LUA->PushNumber( bone->length() );

	return 1;
}

int LeapBone::NextJoint( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	PushSourceVector( state, &bone->nextJoint() );

	return 1;
}

int LeapBone::PrevJoint( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	PushSourceVector( state, &bone->prevJoint() );

	return 1;
}

int LeapBone::Type( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	LUA->PushNumber( ( int ) bone->type() );

	return 1;
}

int LeapBone::Width( lua_State *state ) {
	Bone *bone = Get( state );
	if ( !bone ) return 0;

	LUA->PushNumber( bone->width() );

	return 1;
}