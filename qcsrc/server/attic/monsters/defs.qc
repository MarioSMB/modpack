.entity movetarget;
.float pausetime;

.void()         th_stand;
.void()         th_walk;
.void()         th_run;
.float()        th_missile; // LordHavoc: changed from void() to float(), returns true if attacking
.void()         th_melee;
//.void(entity attacker, float damage, float damgtype, string dethtype)           th_pain; // TODO Xonotic uses event_damage
//.void()         th_die; // TODO never called directly by Xonotic
.entity         oldenemy;               // mad at this player before taking damage
entity  newmis;                 // launch_spike sets this after spawning it

// range values
float   RANGE_MELEE                             = 0;
float   RANGE_NEAR                              = 1;
float   RANGE_MID                               = 2;
float   RANGE_FAR                               = 3;

float DMG_KNIGHT_MELEE_BASE           =    0;
float DMG_KNIGHT_MELEE_RANDOM1        =    3;
float DMG_KNIGHT_MELEE_RANDOM2        =    3;
float DMG_KNIGHT_MELEE_RANDOM3        =    3;

.float          show_hostile; 
	// set to time+0.2 whenever a client fires a
	// weapon or takes damage.  Used to alert
	// monsters that otherwise would let the player go

float movedist;
.float lefty;
.float search_time;
.float attack_state;

float   AS_STRAIGHT             = 1;
float   AS_SLIDING              = 2;
float   AS_MELEE                = 3;
float   AS_MISSILE              = 4;

float SKILL4_MINALPHA         = 0.4;

float monsterwander;
//#NO AUTOCVARS START
/*
        monsterwander = cvar("monsterwander");
        // monsterwander is always on in skill 5
        if (skill >= 5)
                monsterwander = TRUE;
*/
//#NO AUTOCVARS END

.float candrown;

.void(vector org, float bodydamage, float armordamage, vector vel, float damgtype) bleedfunc;
void(vector org, float bodydamage, float armordamage, vector vel, float damgtype) genericbleedfunc;
