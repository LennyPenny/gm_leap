#include "GarrysMod\Lua\Interface.h"

namespace GModLeap 
{
	namespace LeapFrame
	{
		extern int TYPE;

		int tostring(lua_State* state);

		int CurrentFramesPerSecond(lua_State* state);
		int Finger(lua_State* state);
		int Fingers(lua_State* state);
		int Gestures(lua_State* state);
		int Hand(lua_State* state);
		int Hands(lua_State* state);
		int Id(lua_State* state);
		int Images(lua_State* state);
		int InteractionBox(lua_State* state);
		int Invalid(lua_State* state);
		int IsValid(lua_State* state);
		int pointable(lua_State* state);
		int pointables(lua_State* state);
		int RotationAngle(lua_State* state);
		int RotationAxis(lua_State* state);
		int RotationMatrix(lua_State* state);
		int RotationProbability(lua_State* state);
		int ScaleFactor(lua_State* state);
		int ScaleProbability(lua_State* state);
		int ScaleProbability(lua_State* state);
		int Serialize(lua_State* state);
		int TimeStamp(lua_State* state);
		int Tool(lua_State* state);
		int Tools(lua_State* state);
		int Translation(lua_State* state);
		int TranslationProbability(lua_State* state);
	}
}