#ifndef GMOD_UTIL_INCLUDE
#define GMOD_UTIL_INCLUDE

#include "GarrysMod\Lua\Interface.h"

#include "Leap.h"

namespace GModLeap 
{
	void PushSourceVector( lua_State *state, Leap::Vector *vector );
}

#endif