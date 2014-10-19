#include "Leap.h"
#include "GMod_LeapHand.h"

#include "GMod_LeapFinger.h"
#include "GMod_LeapFrame.h"

using namespace GarrysMod;
using namespace Leap;

using namespace GModLeap;

int LeapHand::TYPE = 100; //random


void LeapHand::DefineMeta( lua_State *state)
{
	LUA->CreateMetaTableType( "LeapHand" , LeapHand::TYPE );
		LUA->Push( -1 );
		LUA->SetField( -2 , "__index" );

		LUA->PushCFunction( LeapHand::tostring );
		LUA->SetField( -2 , "__tostring" );

		LUA->PushString( "LeapHand" );
		LUA->SetField( -2 , "__type" );

		LUA->PushCFunction( LeapHand::IsValid );
		LUA->SetField( -2 , "IsValid" );
	LUA->Pop();
}

Hand *LeapHand::Get( lua_State *state , int pos )
{
	if ( !LUA->IsType( pos , LeapHand::TYPE ) ) return nullptr;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->GetUserdata();

	if ( !ud ) return nullptr;

	Hand *hand = ( Hand * ) ud->data;
	if ( !hand ) return nullptr;

	return hand;
}

void LeapHand::Push( lua_State * state, Leap::Hand *Hand )
{
	if ( !Hand ) return;

	Lua::UserData *ud = ( Lua::UserData * ) LUA->NewUserdata( sizeof( Lua::UserData ) );
	ud->data = Hand;
	ud->type = LeapHand::TYPE;

	LUA->CreateMetaTableType( "LeapHand" , LeapHand::TYPE );
	LUA->SetMetaTable( -2 );
}

int LeapHand::tostring( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushString( hand->toString().c_str() );

	return 1;
}

int LeapHand::Arm( lua_State *state ) {
	Hand *hand = Get(state);
	if (!hand) return 0;

	Leap::Arm *arm = new Leap::Arm( hand->arm() );

	//TODO

	return 1;
}

int LeapHand::Basis( lua_State *state ) {
	Hand *hand = Get(state);
	if (!hand) return 0;

	Matrix *matrix = new Matrix( hand->basis() );

	//TODO

	return 1;
}

int LeapHand::Confidence( lua_State *state) {
	Hand *hand = Get(state);
	if (!hand) return 0;

	LUA->PushNumber( hand->confidence() );

	return 1;
}

int LeapHand::Direction( lua_State *state ) {
	Hand *hand = Get(state);
	if ( !hand ) return 0;

	Vector *dir = new Vector( hand->direction() );

	//TODO

	return 1;
}

int LeapHand::Finger( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Leap::Finger *finger = new Leap::Finger( hand->finger( LUA->CheckNumber() ) );

	LeapFinger::Push( state, finger );

	return 1;
}

int LeapHand::Fingers( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	FingerList *flist = new FingerList( hand->fingers() );

	//TODO

	return 1;
}

int LeapHand::Frame( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LeapFrame::Push( state, new Leap::Frame( hand->frame() ) );

	return 1;
}

int LeapHand::GrabStrength( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->grabStrength() );

	return 1;
}

int LeapHand::ID( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->id() );

	return 1;
}

int LeapHand::IsLeft( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushBool( hand->isLeft() );

	return 1;
}

int LeapHand::IsRight( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushBool( hand->isRight() );

	return 1;
}

int LeapHand::IsValid( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushBool( hand->isValid() );

	return 1;
}

int LeapHand::PalmNormal( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *pnormal = new Vector( hand->palmNormal() );

	//TODO

	return 1;
}

int LeapHand::PalmPosition( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *pnormal = new Vector( hand->palmPosition() );

	return 1;
}

int LeapHand::PalmVelocity( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *pnormal = new Vector( hand->palmVelocity() );

	//TODO

	return 1;
}

int LeapHand::PalmWidth( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->palmWidth() );

	return 1;
}

int LeapHand::PinchStrength( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->pinchStrength() );

	return 1;
}

int LeapHand::Pointable( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Leap::Pointable *pointable = new Leap::Pointable( hand->pointable( LUA->CheckNumber() ) );

	//TODO

	return 1;
}

int LeapHand::Pointables( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Leap::PointableList *plist = new Leap::PointableList( hand->pointables() );

	//TODO

	return 1;
}

int LeapHand::RotationAngle( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	//TODO

	return 1;
}

int LeapHand::RotationAxis( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	Vector *raxis = new Vector ( hand->rotationAxis( *LeapFrame::Get( state ) ) );

	//TODO

	return 1;
}

int LeapHand::RotationMatrix( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	Matrix *rmatrix = new Matrix( hand->rotationMatrix( *LeapFrame::Get( state ) ) );

	//TODO

	return 1;
}

int LeapHand::RotationProbability( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	LUA->PushNumber( hand->rotationProbability( *LeapFrame::Get( state ) ) );

	return 1;
}

int LeapHand::ScaleFactor( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	LUA->PushNumber( hand->scaleFactor( *LeapFrame::Get( state ) ) );

	return 1;
}

int LeapHand::ScaleProbability( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	LUA->PushNumber( hand->scaleProbability( *LeapFrame::Get( state ) ) );

	return 1;
}

int LeapHand::SphereCenter( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *center = new Vector( hand->sphereCenter() );

	//TODO

	return 1;
}

int LeapHand::SphereRadius( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->sphereRadius() );

	return 1;
}

int LeapHand::StabilizedPalmPosition( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *center = new Vector( hand->stabilizedPalmPosition() );

	//TODO

	return 1;
}

int LeapHand::TimeVisible( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->PushNumber( hand->timeVisible() );

	return 1;
}

int LeapHand::Tool( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	//TODO

	return 1;
}

int LeapHand::Tools( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	ToolList *tools = new ToolList( hand->tools() );

	//TODO

	return 1;
}

int LeapHand::Translation( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;
	
	LUA->CheckType( -1, LeapFrame::TYPE );
	Vector *translation = new Vector( hand->translation( *LeapFrame::Get( state ) ) );

	//TODO

	return 1;
}

int LeapHand::TranslationProbability( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	LUA->CheckType( -1, LeapFrame::TYPE );
	LUA->PushNumber( hand->translationProbability( *LeapFrame::Get( state ) ) );

	return 1;
}

int LeapHand::WristPosition( lua_State *state ) {
	Hand *hand = Get( state );
	if ( !hand ) return 0;

	Vector *wristpos = new Vector( hand->wristPosition() );

	//TODO

	return 1;
}