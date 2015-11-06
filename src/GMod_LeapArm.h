#ifndef GMOD_LEAPARM_INCLUDE
#define GMOD_LEAPARM_INCLUDE

#include "GarrysMod\Lua\Interface.h"

namespace GModLeap
{
	namespace LeapArm
	{
		extern int TYPE;

		void DefineMeta(lua_State *state);

		Leap::Arm *Get(lua_State * state, int pos = -1);
		void Push(lua_State *state, Leap::Arm *bone);

		int tostring(lua_State *state);
		int gc(lua_State *state);

		int Width( lua_State *state );
		int Direction( lua_State *state );
		int ElbowPosition( lua_State *state );
		int WristPosition( lua_State *state );
		int Center( lua_State *state );
		int IsValid( lua_State *state );

	}
}

#endif