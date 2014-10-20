#ifndef GMOD_LEAPBONE_INCLUDE
#define GMOD_LEAPBONE_INCLUDE

#include "GarrysMod\Lua\Interface.h"
#include "Leap.h"

namespace GModLeap
{
	namespace LeapBone
	{
		extern int TYPE;

		void DefineMeta( lua_State *state );

		Leap::Bone *Get( lua_State * state, int pos = -1 );
		void Push( lua_State *state, Leap::Bone *bone );

		int tostring( lua_State *state );

		int Basis( lua_State *state );
		int Center( lua_State *state );
		int Direction( lua_State *state );
		int IsValid( lua_State *state );
		int Length( lua_State *state );
		int NextJoint( lua_State *state );
		int PrevJoint( lua_State *state );
		int Type( lua_State *state );
		int Width( lua_State *state );
	}
}

#endif