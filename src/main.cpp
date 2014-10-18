#include "GarrysMod\Lua\Interface.h"

#include "Leap.h"

using namespace GarrysMod;
using namespace Leap;

Controller *controller = nullptr;
void *fake_heap[sizeof(Controller)];

int leap_IsConnected(lua_State *state) {
	LUA->PushBool(controller->isConnected());

	return 1;
}

int leap_Frame(lua_State *state) {
	Frame frame;

	if (LUA->Top() > 0) {
		frame = controller->frame(LUA->CheckNumber());
	}
	else {
		frame = controller->frame();
	}

	Lua::UserData* ud = (Lua::UserData*)LUA->NewUserdata(sizeof(Lua::UserData));
	ud->data = &frame;
	ud->type = Lua::Type::USERDATA;

	LUA->CreateMetaTableType("LeapFrame", Lua::Type::USERDATA);
	LUA->SetMetaTable(-2);

	return 1;
}

GMOD_MODULE_OPEN() {
	
	controller = new (fake_heap) Controller;

	LUA->PushSpecial(Lua::SPECIAL_GLOB);

		LUA->CreateTable();

			LUA->PushCFunction(leap_IsConnected);
			LUA->SetField(-2, "IsConnected");

			LUA->PushCFunction(leap_Frame);
			LUA->SetField(-2, "Frame");

		LUA->SetField(-2, "leap");

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