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


//LeapFrame Metamethods

int LeapFrame_tostring(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();
	Frame* frame = (Frame*)ud->data;

	LUA->PushString(frame->toString().c_str());

	return 1;
}

int LeapFrame_Serialize(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();
	Frame* frame = (Frame*)ud->data;

	LUA->PushString(frame->serialize().c_str());

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

		LUA->CreateMetaTableType("LeapFrame", Lua::Type::USERDATA);
			LUA->Push(-1);
			LUA->SetField(-2, "__index");

			LUA->PushCFunction(LeapFrame_tostring);
			LUA->SetField(-2, "__tostring");

			LUA->PushString("LeapFrame");
			LUA->SetField(-2, "__type");

			LUA->PushCFunction(LeapFrame_Serialize);
			LUA->SetField(-2, "Serialize");
		
		LUA->Pop();

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