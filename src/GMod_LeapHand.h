#ifndef GMOD_LEAPHAND_INCLUDE
#define GMOD_LEAPHAND_INCLUDE

#include "GarrysMod\Lua\Interface.h"

namespace GModLeap
{
	namespace LeapHand
	{
		extern int TYPE;

		void DefineMeta( lua_State *state );

		Leap::Hand *Get( lua_State *state, int pos = -1 );
		void Push( lua_State *state, Leap::Hand *hand );

		int tostring( lua_State *state );

		int Arm( lua_State *state );
		int Basis( lua_State *state );
		int Confidence( lua_State *state );
		int Direction( lua_State *state );
		int Finger( lua_State *state );
		int Fingers( lua_State *state );
		int Frame( lua_State *state );
		int GrabStrength( lua_State *state );
		int ID( lua_State *state );
		int Invalid( lua_State *state );
		int IsLeft( lua_State *state );
		int IsRight( lua_State *state );
		int IsValid( lua_State *state );
		int PalmNormal( lua_State *state );
		int PalmPosition( lua_State *state );
		int PalmVelocity( lua_State *state );
		int PalmWidth( lua_State *state );
		int PinchStrength( lua_State *state );
		int Pointable( lua_State *state );
		int Pointables( lua_State *state );
		int RotationAngle( lua_State *state );
		int RotationAxis( lua_State *state );
		int RotationMatrix( lua_State *state );
		int RotationProbability( lua_State *state );
		int ScaleFactor( lua_State *state );
		int ScaleProbability( lua_State *state );
		int SphereCenter( lua_State *state );
		int SphereRadius( lua_State *state );
		int StabilizedPalmPosition( lua_State *state );
		int TimeVisible( lua_State *state );
		int Tool( lua_State *state );
		int Tools( lua_State *state );
		int Translation( lua_State *state );
		int TranslationProbability( lua_State *state );
		int WristPosition( lua_State *state );
	}
}

#endif