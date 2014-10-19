#include "Leap.h"
#include "GMod_LeapFrame.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapFrame::TYPE = 99; //random


int LeapFrame::tostring(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();

	if (!ud) return 0;

	Frame* frame = (Frame*)ud->data;
	if (!frame || !frame->isValid())
	{
		return 0;
	}

	LUA->PushString(frame->toString().c_str());
	return 1;
}

int LeapFrame::CurrentFramesPerSecond(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();
	Frame* frame = (Frame*)ud->data;

	LUA->PushNumber(frame->currentFramesPerSecond());

	return 1;
}

int LeapFrame::Finger(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();
	Frame* frame = (Frame*)ud->data;

	//TODO

	return 1;
}

int LeapFrame::Fingers(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();
	Frame* frame = (Frame*)ud->data;

	//TODO

	return 1;
}

int LeapFrame::IsValid(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();

	if (!ud) return 0;

	Frame* frame = (Frame*)ud->data;
	if (!frame)
	{
		return 0;
	}

	LUA->PushBool(frame->isValid());
	return 1;
}

int LeapFrame::Serialize(lua_State* state) {
	Lua::UserData* ud = (Lua::UserData*)LUA->GetUserdata();

	if (!ud) return 0;

	Frame* frame = (Frame*)ud->data;
	if (!frame || !frame->isValid())
	{
		return 0;
	}

	LUA->PushString(frame->serialize().c_str());
	return 1;
}