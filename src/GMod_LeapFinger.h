#ifndef GMOD_LEAPFINGER_INCLUDE
#define GMOD_LEAPFINGER_INCLUDE

#include "GarrysMod\Lua\Interface.h"

namespace GModLeap
{
	namespace LeapFinger
	{
		extern int TYPE;

		void DefineMeta( lua_State *state );

		Leap::Finger *Get( lua_State * state, int pos = -1 );
		void Push(lua_State *state, Leap::Finger *finger );

		int tostring( lua_State *state );
		int gc( lua_State *state );

		int Bone( lua_State *state );
		int Bones( lua_State *state );
		int Direction( lua_State *state );
		int Frame( lua_State *state );
		int Hand( lua_State *state );
		int ID( lua_State *state );
		int IsExtended( lua_State*state );
		int IsFinger( lua_State *state );
		int IsTool( lua_State *state );
		int IsValid( lua_State *state );
		int JointPosition( lua_State *state );
		int Length( lua_State *state );
		int StabilizedTipPosition( lua_State *state );
		int TimeVisible( lua_State *state );
		int TipPosition( lua_State *state );
		int TipVelocity( lua_State *state );
		int TouchDistance( lua_State *state );
		int TouchZone( lua_State *state );
		int Type( lua_State *state );
		int Width( lua_State *state );
	}
}

#endif