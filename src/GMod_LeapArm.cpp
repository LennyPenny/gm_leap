#include "Leap.h"

#include "util.h"

#include "GMod_LeapHand.h"
#include "GMod_LeapArm.h"
#include "GMod_LeapFinger.h"
#include "GMod_LeapFrame.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapArm::TYPE = 103; //random

void LeapArm::DefineMeta(lua_State *state) {
	LUA->CreateMetaTableType("LeapArm", LeapArm::TYPE);

	LUA->Push(-1);
	LUA->SetField(-2, "__index");

	LUA->PushCFunction(LeapArm::tostring);
	LUA->SetField(-2, "__tostring");

	LUA->PushString("LeapArm");
	LUA->SetField(-2, "__type");

	LUA->PushCFunction(LeapArm::gc);
	LUA->SetField(-2, "__gc");

	LUA->PushCFunction( LeapArm::Width );
	LUA->SetField( -2, "Width" );

	LUA->PushCFunction( LeapArm::Direction );
	LUA->SetField( -2, "Direction" );

	LUA->PushCFunction( LeapArm::ElbowPosition );
	LUA->SetField( -2, "ElbowPosition" );

	LUA->PushCFunction( LeapArm::WristPosition );
	LUA->SetField( -2, "WristPosition" );

	LUA->PushCFunction( LeapArm::Center );
	LUA->SetField( -2, "Center" );

	LUA->PushCFunction( LeapArm::IsValid );
	LUA->SetField( -2, "IsValid" );


	LUA->Pop();
}

Arm *LeapArm::Get(lua_State *state, int pos) {
	if (!LUA->IsType(pos, LeapArm::TYPE)) return nullptr;

	Lua::UserData *ud = (Lua::UserData *) LUA->GetUserdata();

	if (!ud) return nullptr;

	Arm *arm = (Arm *)ud->data;
	if (!arm) return nullptr;

	return arm;
}

void LeapArm::Push(lua_State * state, Leap::Arm *arm) {
	if (!arm) return;

	Lua::UserData *ud = (Lua::UserData *)LUA->NewUserdata(sizeof(Lua::UserData));
	ud->data = arm;
	ud->type = LeapArm::TYPE;

	LUA->CreateMetaTableType("LeapArm", LeapArm::TYPE);
	LUA->SetMetaTable(-2);
}

int LeapArm::tostring(lua_State *state) {
	Arm *arm = Get(state);
	if (!arm) return 0;

	LUA->PushString(arm->toString().c_str());

	return 1;
}

int LeapArm::gc(lua_State *state) {
	Arm *arm = Get(state);
	if (!arm) return 0;

	delete[] arm;

	return 1;
};

int LeapArm::Width( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;
	
	LUA->PushNumber( arm->width() );
	return 1;
}

int LeapArm::Direction( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;

	PushSourceVector( state, &arm->direction() );
	return 1;
}


int LeapArm::ElbowPosition( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;

	PushSourceVector( state, &arm->elbowPosition() );
	return 1;
}

int LeapArm::WristPosition( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;

	PushSourceVector( state, &arm->wristPosition() );
	return 1;
}

int LeapArm::Center( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;

	PushSourceVector( state, &arm->center() );
	return 1;
}

int LeapArm::IsValid( lua_State *state )
{
	Arm *arm = Get( state );
	if( !arm ) return 0;

	LUA->PushBool( arm->isValid() );
	return 1;
}