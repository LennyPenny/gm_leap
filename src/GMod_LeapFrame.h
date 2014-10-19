#ifndef GMOD_LEAPFRAME_INCLUDE
#define GMOD_LEAPFRAME_INCLUDE

#include "GarrysMod\Lua\Interface.h"
#include "Leap.h"

namespace GModLeap 
{
	namespace LeapFrame
	{
		extern int TYPE;

		void DefineMeta( lua_State *state );

		Leap::Frame * Get( lua_State *state , int pos = -1 );
		void Push( lua_State *state , Leap::Frame *frame );

		int tostring( lua_State *state );
		int CurrentFramesPerSecond( lua_State *state );
		int Gestures( lua_State *state );
		int Hands( lua_State *state );
		int Id( lua_State *state );
		int Images( lua_State *state );
		int InteractionBox( lua_State *state );
		int Invalid( lua_State *state );
		int IsValid( lua_State *state );
		int pointable( lua_State *state );
		int pointables( lua_State *state );
		int RotationAngle( lua_State *state );
		int RotationAxis( lua_State *state );
		int RotationMatrix( lua_State *state );
		int RotationProbability( lua_State *state );
		int ScaleFactor( lua_State *state );
		int ScaleProbability( lua_State *state );
		int ScaleProbability( lua_State *state );
		int Serialize( lua_State *state );
		int TimeStamp( lua_State *state );
		int Tool( lua_State *state );
		int Tools( lua_State *state );
		int Translation( lua_State *state );
		int TranslationProbability( lua_State *state );
	}
}

#endif