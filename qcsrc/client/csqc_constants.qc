#define world world

// Mask Constants (set .drawmask on entities; use R_AddEntities to add all entities based on mask)
const float		MASK_ENGINE						= 1;
const float		MASK_ENGINEVIEWMODELS			= 2;
const float		MASK_NORMAL						= 4;

// Renderflag Constants (used for CSQC entities)
const float		RF_VIEWMODEL					= 1;
const float		RF_EXTERNALMODEL				= 2;
const float		RF_DEPTHHACK					= 4;
const float		RF_ADDITIVE						= 8;
const float		RF_USEAXIS						= 16;

// Viewflag Constants (use with R_SetView)
const float		VF_MIN							= 1;	//(vector)
const float		VF_MIN_X						= 2;	//(float)
const float		VF_MIN_Y						= 3;	//(float)
const float		VF_SIZE							= 4;	//(vector) (viewport size)
const float		VF_SIZE_Y						= 5;	//(float)
const float		VF_SIZE_X						= 6;	//(float)
const float		VF_VIEWPORT						= 7;	//(vector, vector)
const float		VF_FOV							= 8;	//(vector)
const float		VF_FOVX							= 9;	//(float)
const float		VF_FOVY							= 10;	//(float)
const float		VF_ORIGIN						= 11;	//(vector)
const float		VF_ORIGIN_X						= 12;	//(float)
const float		VF_ORIGIN_Y						= 13;	//(float)
const float		VF_ORIGIN_Z						= 14;	//(float)
const float		VF_ANGLES						= 15;	//(vector)
const float		VF_ANGLES_X						= 16;	//(float)
const float		VF_ANGLES_Y						= 17;	//(float)
const float		VF_ANGLES_Z						= 18;	//(float)
const float		VF_DRAWWORLD					= 19;	//(float)
const float		VF_DRAWENGINEHUD				= 20;	//(float)
const float		VF_DRAWCROSSHAIR				= 21;	//(float)
const float		VF_PERSPECTIVE					= 200;	//(float)

const float		VF_CL_VIEWANGLES				= 33;	//(vector)
const float		VF_CL_VIEWANGLES_X				= 34;	//(float)
const float		VF_CL_VIEWANGLES_Y				= 35;	//(float)
const float		VF_CL_VIEWANGLES_Z				= 36;	//(float) 

// Server Autosent Stat Constants
const float		STAT_HEALTH						= 0;
const float		STAT_WEAPONMODEL				= 2;
const float		STAT_AMMO						= 3;
const float		STAT_ARMOR						= 4;
const float		STAT_WEAPONFRAME				= 5;
const float		STAT_SHELLS						= 6;
const float		STAT_NAILS						= 7;
const float		STAT_ROCKETS					= 8;
const float		STAT_CELLS						= 9;
const float		STAT_ACTIVEWEAPON				= 10;
const float		STAT_TOTALSECRETS				= 11;
const float		STAT_TOTALMONSTERS				= 12;
const float		STAT_SECRETS					= 13;
const float		STAT_MONSTERS					= 14;
const float		STAT_ITEMS						= 15;
const float		STAT_VIEWHEIGHT					= 16;
const float		STAT_MOVEVARS_TICRATE           = 240;
const float		STAT_MOVEVARS_TIMESCALE         = 241;
const float		STAT_FRAGLIMIT					= 235;
const float		STAT_TIMELIMIT					= 236;
const float     STAT_MOVEVARS_GRAVITY           = 242;

// Quake-style Point Contents
const float		CONTENT_EMPTY					= -1;
const float		CONTENT_SOLID					= -2;
const float		CONTENT_WATER					= -3;
const float		CONTENT_SLIME					= -4;
const float		CONTENT_LAVA					= -5;
const float		CONTENT_SKY						= -6;

// Boolean Constants
const float		true							= 1;
const float		false							= 0;
const float 	TRUE							= 1;
const float 	FALSE							= 0;

// Vector / Hull Constants
const vector	VEC_1							= '1 1 1';
const vector	VEC_0							= '0 0 0';
const vector	VEC_M1							= '-1 -1 -1';

const vector	VEC_HULL_MIN 					= '-16 -16 -24';
const vector	VEC_HULL_MAX 					= '16 16 32';

// Effect Constants
const float 	EF_NODRAW						= 16;
const float 	EF_ADDITIVE						= 32;
const float 	EF_BLUE							= 64;
const float 	EF_RED							= 128;
const float 	EF_FULLBRIGHT					= 512;
const float 	EF_FLAME						= 1024;
const float 	EF_STARDUST						= 2048;
const float 	EF_NOSHADOW						= 4096;
const float 	EF_NODEPTHTEST					= 8192;

// Quake Player Flag Constants
const float 	PFL_ONGROUND					= 1;
const float 	PFL_CROUCH						= 2;
const float 	PFL_DEAD						= 4;
const float 	PFL_GIBBED						= 8;

// Quake Temporary Entity Constants
const float		TE_SPIKE						= 0;
const float		TE_SUPERSPIKE					= 1;
const float		TE_GUNSHOT						= 2;
const float		TE_EXPLOSION					= 3;
const float		TE_TAREXPLOSION					= 4;
const float		TE_LIGHTNING1					= 5;
const float		TE_LIGHTNING2					= 6;
const float		TE_WIZSPIKE						= 7;
const float		TE_KNIGHTSPIKE					= 8;
const float		TE_LIGHTNING3					= 9;
const float		TE_LAVASPLASH					= 10;
const float		TE_TELEPORT						= 11;
const float 	TE_EXPLOSION2					= 12;
// Darkplaces Additions
const float 	TE_EXPLOSIONRGB					= 53;
const float		TE_GUNSHOTQUAD					= 57;
const float		TE_EXPLOSIONQUAD 				= 70;

// Math Constants
const float 	EXTRA_LOW 						= -99999999;
const float 	EXTRA_HIGH 						= 99999999;

// Frik File Constants
const float		FILE_READ						= 0;
const float		FILE_APPEND						= 1;
const float		FILE_WRITE						= 2;

// Button values used by input_buttons
const float BUTTON_ATTACK = 1;
const float BUTTON_JUMP = 2;
const float BUTTON_3 = 4;
const float BUTTON_4 = 8;
const float BUTTON_5 = 16;
const float BUTTON_6 = 32;
const float BUTTON7 = 64;
const float BUTTON8 = 128;
const float BUTTON_USE = 256;
const float BUTTON_CHAT = 512;
const float BUTTON_PRYDONCURSOR = 1024;
const float BUTTON_9 = 2048;
const float BUTTON_10 = 4096;
const float BUTTON_11 = 8192;
const float BUTTON_12 = 16384;
const float BUTTON_13 = 32768;
const float BUTTON_14 = 65536;
const float BUTTON_15 = 131072;
const float BUTTON_16 = 262144;

#define        SOLID_NOT                               0               // no interaction with other objects
#define        SOLID_TRIGGER                   1               // touch on edge, but not blocking
#define        SOLID_BBOX                              2               // touch on edge, block
#define        SOLID_SLIDEBOX                  3               // touch on edge, but not an onground
#define        SOLID_BSP                               4               // bsp clip, touch on edge, block
#define        SOLID_CORPSE                    5               // same as SOLID_BBOX, except it behaves as SOLID_NOT against SOLID_SLIDEBOX objects (players/monsters)

float MOVE_NORMAL = 0; // same as FALSE
float MOVE_NOMONSTERS = 1; // same as TRUE
float MOVE_MISSILE = 2; // save as movement with .movetype == MOVETYPE_FLYMISSILE
float MOVE_HITMODEL = 4;
float MOVE_WORLDONLY = 3;

float CAMERA_FREE = 1;
float CAMERA_CHASE = 2;

float EF_NOMODELFLAGS = 8388608;
