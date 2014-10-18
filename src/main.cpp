#include "GarrysMod\Lua\Interface.h"

#include "Leap.h"

using namespace GarrysMod;
using namespace Leap;

Controller controller;

int leap_IsConnected(lua_State *state) {
	LUA->PushBool(controller.isConnected());

	return 1;
}

GMOD_MODULE_OPEN() {
	LUA->PushSpecial(Lua::SPECIAL_GLOB);

		LUA->CreateTable();

			LUA->PushCFunction(leap_IsConnected);
			LUA->SetField(-2, "IsConnected");

		LUA->SetField(-2, "leap");

	LUA->Pop();

	return 0;
}

GMOD_MODULE_CLOSE() {
	return 0;
}