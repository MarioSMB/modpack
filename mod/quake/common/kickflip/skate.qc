#include "skate.qh"

#ifdef SVQC

void switch_skating(entity this)
{
	if(STAT(SKATING, this))
		STAT(SKATING, this) = false;
	else
		STAT(SKATING, this) = true;

	_setmodel(this, get_playermodel(this));
	this.modelindex_player = this.modelindex;
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
}

void push_off_anim(entity this)
{
	if(!(STAT(TRICK, this) == TRICK_GRIND) && IS_ONGROUND(this) && !STAT(BOARD_FALLING, this))
	{
		_sound(this, CHAN_BODY, "player/skaterol.wav", 1, ATTN_NORM);
		this.walkframe = 20;
		this.push_time = time;
	}
}

void skate_walkframes(entity this)
{
	int new_trick = 0;

						//	 1-12 stand
						//	13-19 jump
						//	20-26 push
						//	27-32 kickflip
						//	33-36 grind
						//	37-43 olliegrap
						//	44-50 frontside 180
						//	51-61 360 flip
						//	62-97 fall
						//	98-104 damage
						//	105-108 backside boardslide
						//	109-119 backside 360 rotation

	if(this.walkframe == 12 || this.walkframe == 19)
	{
		this.walkframe = 0;
	}
	if(this.walkframe == 26 || this.walkframe == 32)
	{
		this.walkframe = 0;
	}
	if(this.walkframe == 43 || this.walkframe == 50)
	{
		this.walkframe = 0;
	}
	if(this.walkframe == 61 || this.walkframe == 119)
	{
		this.walkframe = 0;
	}

	if(this.walkframe == 31)
	{
		new_trick = TRICK_KICKFLIP;
		this.busting = false;				//finished stunt
	}
	if(this.walkframe == 41)		//41:42
	{
		new_trick = TRICK_GRAP;
		this.busting = false;				//finished stunt
	}
	if(this.walkframe == 48)		//48:49
	{
		new_trick = TRICK_FRONTONEEIGHTY;
		this.busting = false;				//finished stunt
	}
	
	if(this.walkframe == 60)		//
	{
		new_trick = TRICK_THREESIXFLIP;			//test code
		this.busting = false;				//finished stunt
	}
	if(this.walkframe < 60 && this.walkframe >= 51)	//
	{
		this.nextthink = time + 0.07;			//play animation faster
	}
	
	if(this.walkframe == 118)
	{
		new_trick = TRICK_BACKROT;
		this.busting = false;				//finished stunt
	}
	if(this.walkframe < 119 && this.walkframe >= 109)	//
	{
		this.nextthink = time + 0.07;			//play animation faster
	}

	if(new_trick != 0)
	{
		if(STAT(TRICK, this))
			this.second_trick = new_trick;		//.trick or .second_trick ?
		else
			STAT(TRICK, this) = new_trick;
	}

	if(this.walkframe == 36)
		this.walkframe = 33;		//replay grind animation

	if(this.walkframe == 108)
		this.walkframe = 105;		//replay grind animation

	if(this.walkframe <= 97 && this.walkframe >= 62)
	{
		this.nextthink = time + 0.06;			//play falling animation faster
	}

	if(this.walkframe == 97 || this.walkframe == 104)		//falling
	{
		this.walkframe = 0;
		this.pausetime = 0;
		STAT(BOARD_FALLING, this) = false;		// player can turn again
	}
}

void skate_fire(entity this)
{
	if(this.spawn_time + 1 > time)		//player just respawned, exit
		return;

	if(this.button5 && this.push_fast_time < time && IS_ONGROUND(this) && (this.velocity_x || this.velocity_y))
	{
		if(STAT(STAMINA, this) > PUSH_STAMINA_COST && !STAT(BOARD_FALLING, this) && STAT(TRICK, this) != TRICK_GRIND)//don't push while falling
		{
			STAT(STAMINA, this) -= PUSH_STAMINA_COST;
			_sound(this, CHAN_BODY, "player/skaterol.wav", 1, ATTN_NORM);
			this.push_fast_time = time + 2;
			this.walkframe = 20;
			this.attack_finished = time + 0.2;			//don't mess up, hehe (?)
		}
	}

	if(!PHYS_INPUT_BUTTON_JUMP(this))
	{
		this.buttonjump_held = false;
		return;
	}
	//if(IS_JUMP_HELD(this))
		//this.buttonjump_held = true;
	if(this.buttonjump_held)
		return;
	this.buttonjump_held = true;
	//player must be onground and not standing

	if(!IS_ONGROUND(this) && !(this.busting))	//player in air making stunt !!!
	{							//use the normal jumping sound for stunts
		_sound(this, CH_VOICE, "player/plyrjmp8.wav", 1, ATTN_NORM);
		
		//check key combinations first...
		if(this.button3 && this.button0)
			this.walkframe = 109;			//backside rotation
		else if(this.button3)
			this.walkframe = 37;			//ollie grap
		else if(this.button0)
			this.walkframe = 44;			//front 180
		else if(this.button5)
			this.walkframe = 51;			//360 flip
		else
			this.walkframe = 27;			//Kickflip
		
		this.busting = true;
	}
}
#endif

//Checks if this is on a rail
//only one side (right or left) has to be empty
bool onrail(entity this)
{
	vector spot;
	makevectors(this.angles);

//check the right side
	spot = this.origin - '0 0 36' + (v_right * 16);		//grinding ?
	traceline(this.origin, spot, true, this);
	if(trace_fraction == 1.0 && pointcontents(trace_endpos) == CONTENT_EMPTY)
		return true;

//check the left side
	spot = this.origin - '0 0 36' - (v_right * 16);		//grinding ?
	traceline(this.origin, spot, true, this);
	if(trace_fraction == 1.0 && pointcontents(trace_endpos) == CONTENT_EMPTY)
		return true;

	return false;
}

void skate_fall(entity this)
{
#ifdef SVQC
	float rand_dmg = random() * 5 + 15;
	T_Damage(this, NULL, NULL, rand_dmg, DEATH_FALL.m_id); 
	_sound(this, CH_VOICE, "player/land2.wav", 1, ATTN_NORM);

	this.pausetime = time + 4;
	if(this.jump_flag <= -750)
	{
		this.walkframe = 62;
		T_Damage(this, NULL, NULL, 5, DEATH_FALL.m_id);
	} 
	else
	{
		this.walkframe = 98;
	}
	this.mangle = this.angles;
	this.busting = false;
	this.jump_flag = 0;
	STAT(BOARD_FALLING, this) = true;		// turn this way immediately
	STAT(TRICK, this) = 0;			//no grinds
	this.second_trick = 0;
	STAT(SKATESPEED, this) = 0;
#endif
}

bool check_wrong_direction(entity this)
{
#ifdef SVQC
	if(this.spawn_time + 1 > time)		//player just respawned, exit
		return false; 	
#endif

	vector spot = this.origin + (this.velocity * 0.15); //a spot where player will be in a short time
	makevectors(this.angles);
	vector vec = normalize(spot - this.origin);
	float dot = vec * v_forward;
	
	if(dot > -0.3)	//-0.1 : 0.3 the higher the number, the lower the degree spectrum
		return false;		//player looks in right direction
#ifdef SVQC
	sprint(this, "You have to look in the direction you are moving !\n");
#endif
	return true;
}

#ifdef SVQC
void skate_land(entity this)
{
	int trick_points = 0;
	string trick_name = "";
	bool fell = false;

	if(STAT(TRICK, this) == TRICK_GRIND && (STAT(GRIND_STOP_TIME, this) + 0.2 > time))
		return;		//just a little gap in the reel. No landing

	if(this.watertype == CONTENT_WATER)
		_sound(this, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
	else if(this.jump_flag < -650) //fell down
	{
		//sprint(this, sprintf("%s fell down.\n", this.netname));	
		STAT(TRICK, this) = 0;			//no good landing no trick points !
		this.second_trick = 0;
		fell = true;
	}
	else if(check_wrong_direction(this) || this.busting || (STAT(GRIND_STOP_TIME, this) + 0.4 > time && !onrail(this)))
	{
		STAT(TRICK, this) = 0;			//no good landing no trick points !
		this.second_trick = 0;
		fell = true;
	}
	else
	{
		_sound(this, CH_VOICE, "player/skatelnd.wav", 1, ATTN_NORM);		
	}
	
	if(STAT(TRICK, this))					//player busted a trick !
	{
		if(STAT(TRICK, this) == TRICK_KICKFLIP)
		{
			trick_points = 1;
			trick_name = "Kickflip";
			if(this.second_trick)
			{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Double Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Kickflip to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Kickflip to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Kickflip to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Kickflip to Backside 360";
				}
			}
		}
		else if(STAT(TRICK, this) == TRICK_GRIND)//also used for boardslide
		{
			trick_points = 1;
			if(this.diff_grinds == GRIND_NORMAL)
			{
				trick_name = "Grind";
				if(this.second_trick)
				{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Grind to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Grind to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Grind to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Grind to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Grind to Backside 360";
				}
				}
			}
			else if(this.diff_grinds == GRIND_BOARDSLIDE)
			{
				trick_name = "Boardslide";
				if(this.second_trick)
				{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Boardslide to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Boardslide to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Boardslide to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Boardslide to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Boardslide to Backside 360";
				}
				}
			}
			else if(this.diff_grinds == GRIND_BACKBOARDSLIDE)
			{
				trick_name = "Backside Boardslide";
					if(this.second_trick)
				{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Backside Boardslide to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Backside Boardslide to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Backside Boardslide to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Backside Boardslide to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Backside Boardslide to Backside 360";
				}
				}
			}
		}
		else if(STAT(TRICK, this) == TRICK_GRAP)
		{
			trick_points = 1;
			trick_name = "Indy Grap";
			if(this.second_trick)
			{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 3;
					trick_name = "Indy Grap to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 2;
					trick_name = "Double Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Indy Grap to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Indy Grap to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Indy Grap to Backside 360";
				}
			}
		}
		else if(STAT(TRICK, this) == TRICK_FRONTONEEIGHTY)
		{
			trick_points = 1;
			trick_name = "Pop Shoveit";
			if(this.second_trick)
			{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 3;
					trick_name = "Pop Shoveit to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Pop Shoveit to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 2;
					trick_name = "Double Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Pop Shoveit to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Pop Shoveit to Backside 360";
				}
			}
		}
		else if(STAT(TRICK, this) == TRICK_THREESIXFLIP)
		{
			trick_points = 2;
			trick_name = "Shoveit 360";
			if(this.second_trick)
			{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 4;
					trick_name = "Shoveit 360 to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 4;
					trick_name = "Shoveit 360 to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 4;
					trick_name = "Shoveit 360 to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 5;
					trick_name = "Double Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 5;
					trick_name = "Shoveit 360 to Backside 360";
				}
			}
		}
		else if(STAT(TRICK, this) == TRICK_BACKROT)
		{
			trick_points = 2;
			trick_name = "Backside 360";
			if(this.second_trick)
			{
				if(this.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Kickflip";
				}
				else if(this.second_trick == TRICK_GRAP)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Indy Grap";
				}
				else if(this.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Pop Shoveit";
				}
				else if(this.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 5;
					trick_name = "Backside 360 to Shoveit 360";
				}
				else if(this.second_trick == TRICK_BACKROT)
				{
					trick_points = 5;
					trick_name = "Double Backside 360";
				}
			}
		}

		if(comp_started)
			this.frags += trick_points;
	
		STAT(TRICK, this) = 0;			//reset
		this.second_trick = 0;		//		
	}			//end if(STAT(TRICK, this))

	this.walkframe = 0;
	this.busting = false;
	this.skatespeed = 0;

	//landed on a rail, don't stand and grind:
	if(onrail(this) && (this.velocity_x || this.velocity_y) && !fell)
	{
		if(this.button3)
		{
			this.diff_grinds = GRIND_NORMAL;
		}
		else if(this.button0)
		{
			this.diff_grinds = GRIND_BACKBOARDSLIDE;
			this.walkframe = 105;				//start backside boardsliding frames
		}
		else if(this.button5)
		{
			this.diff_grinds = GRIND_BOARDSLIDE;
			this.walkframe = 33;				//start boardsliding frames
		}
		else
		{
			this.diff_grinds = 0;
		}

		if(this.diff_grinds != 0)	//if no trick key is pressed nothing should happen
		{
			STAT(TRICK, this) = TRICK_GRIND;
			this.grind_start_time = time;	
		}
	}

	if(trick_points != 0)				//If the player busted a trick, print it !
	{
		string random_sentence;
		//init the random sentence
		if(random() < 0.5)
			random_sentence = "You busted a ";
		else
			random_sentence = "You did a ";

		sprint(this, random_sentence);	
		sprint(this, trick_name);			//print the trick
		if(STAT(TRICK, this))			//trick is set again because of grind
		{
			if(this.diff_grinds == GRIND_NORMAL)
			{
				sprint(this, " to Grind");		//also print...
			}
			else if(this.diff_grinds == GRIND_BOARDSLIDE)
			{	
				sprint(this, " to Boardslide");	//...grind or boardslide
			}
			else if(this.diff_grinds == GRIND_BACKBOARDSLIDE)
			{	
				sprint(this, " to Backside Boardslide");	//......
			}
		}
		sprint(this, " !\n");

		if(trick_points > 1)
		{
			if(random() < 0.5)
				_sound(this, CH_VOICE, "player/yeah1.wav", 1, ATTN_NORM);		
			else
				_sound(this, CH_VOICE, "player/yeah2.wav", 1, ATTN_NORM);		
		}
	}

	if(fell)
		skate_fall(this);

	this.jump_flag = 0;
}
#endif

bool check_stairs(entity this)
{
	vector spot;
	vector fake_angles = this.angles;
	fake_angles_x = -10;

	makevectors(fake_angles);

	//check infront right of the feet
	spot = this.origin - '0 0 16' + (v_forward * 26) + (v_right * 16);
	traceline(this.origin, spot, true, this);
	if(trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
		return true;	//stairs infront of player !
	
	//check infront left of the feet
	spot = this.origin - '0 0 16' + (v_forward * 26) - (v_right * 16);
	traceline(this.origin, spot, true, this);
	if(trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
		return true;	//stairs infront of player !

	return false;		//flat ground
}

void adjust_x_angle(entity this)
{
	vector spot;
	makevectors(this.angles);

	//check infront of the feet
	spot = this.origin - '0 0 36' + (v_forward * 16);
	traceline(this.origin, spot, true, this);
	float front_space = trace_fraction;
	
	//check behind the feet
	spot = this.origin - '0 0 36' - (v_forward * 16);
	traceline(this.origin, spot, true, this);
	float back_space = trace_fraction;

	float new_x = back_space - front_space;
	new_x = new_x * 80;
	this.angles_x = new_x;	
}

void skate_drive(entity this)
{
	vector new_vel = '0 0 0';
	if(IS_ONGROUND(this))			//don't drive in air
	{
		this.jump_vel = '0 0 0';		//reset initial jumping velocity		

		makevectors(this.angles);
		new_vel.x = this.velocity_x;				//use new_vel to seperate x and y...
 		new_vel.y = this.velocity_y;				//...from z
		
		if(vdist(new_vel, >, this.skatespeed))
			this.skatespeed = vlen(new_vel);
		if(this.skatespeed > 10)
			this.skatespeed = this.skatespeed - 10;		//slow down
		else
			this.skatespeed = 0;	//stop

		new_vel = this.skatespeed * v_forward;		//only forward
		//new_vel = vlen(new_vel) * v_forward;		//only forward
		if(STAT(PUSH_FAST_TIME, this) - 0.5 > time)			//if player pressed
		{								//fire key. pause for 1 seconds
			new_vel = 460 * v_forward;			//faster forward
		}

		if(onrail(this) && (STAT(TRICK, this) == TRICK_GRIND))
		{
		//check if player is slower than expected-->grinding up-->fall!hahaha		
			if(STAT(GRIND_START_TIME, this) + 0.5 < time && vdist(this.velocity, <, 150))
			{
			#ifdef SVQC
				sprint(this,"You don't have enough speed !\n");
			#endif
				skate_fall(this);
				return;
			}
		//end check

			new_vel = 280 * v_forward;		//grind to the right (with frames)
			this.velocity_z = -280;			//grind down somewhere
		#ifdef SVQC
			STAT(GRIND_STOP_TIME, this) = time;		//update stop time. when in air, it won't be set
			if(this.super_sound < time)		//play grinding sound
			{						//use super_sound for right timing
				this.super_sound = time + 1.2;
				_sound(this, CHAN_BODY, "player/skategnd.wav", 1, ATTN_NORM);
			}
		#endif
		}
		
		if(!onrail(this) && (STAT(TRICK, this) == TRICK_GRIND))
		{
		#ifdef SVQC
			sprint(this,"You skipped a grind !\n");
			this.jump_flag = -1000;
			skate_fall(this);
		#endif
			return;
			//STAT(TRICK, this) = 0;
			//this.walkframe = 0;
		}


		if(check_stairs(this))					//don't drive up stairs
			new_vel = '0 0 0';

		this.velocity_x = new_vel.x;				//don't change up or down movement
		this.velocity_y = new_vel.y;				//
	}
	else if(STAT(TRICK, this) == TRICK_GRIND)		//reset animation when falling
	{									//down after grind
#ifdef SVQC
		if(STAT(GRIND_STOP_TIME, this) + 0.4 < time)//player has to been in air for x(0.4) seconds, if not he falls
		{
			if((this.walkframe >= 33 && this.walkframe <= 36) || (this.walkframe >= 105 && this.walkframe <= 108))
			{
				this.walkframe = 0;
			}
		//	this.busting = false;
		}
		//else
		//{
		//	this.busting = true;
		//}
#endif
	}
	else if(this.jump_vel != '0 0 0')
	{		//realistic jumping movement (player can't change direction)
		this.velocity_x = this.jump_vel_x;				//don't change up or down movement
		this.velocity_y = this.jump_vel_y;				//
	}

#ifdef SVQC
	water_die(this);
#endif
	adjust_x_angle(this);
}

#ifdef SVQC
void Regenerate_Health(entity this)
{
	if(this.health_regen_time < time)
	{
		float old_health = this.health;
		this.health += 1;
		
		if(this.health > 250)
			this.health = 250;
		
		if(old_health <= 100 && this.health > 100)
			this.health = 100;
	
		this.health_regen_time = time + 1;
	}
}

void Regenerate_Stamina(entity this)
{
	if(this.stamina_regen_time < time)
	{
		STAT(STAMINA, this) += 2;
		
		if(STAT(STAMINA, this) > 100)
			STAT(STAMINA, this) = 100;

		this.stamina_regen_time = time + 0.1;
	}
}

void water_die(entity this)
{
	makevectors(this.angles);
	int m = pointcontents(this.origin + v_forward*16);

	if(m == CONTENT_WATER || m == CONTENT_SLIME || m == CONTENT_LAVA)
	{
		float sq_dmg = this.health + 10;
		this.watertype = 0;		//not those drown messages
		STAT(TRICK, this) = 0;			//no good landing no trick points !
		this.second_trick = 0;

		T_Damage(this, NULL, NULL, sq_dmg, DEATH_DROWN.m_id); //always die in water
	}
}

void skate_spawn(entity this)
{
	STAT(SKATING, this) = (world.worldtype == WORLDTYPE_SKATE);
	STAT(STAMINA, this) = 100;
	this.buttonjump_held = false;
	STAT(BOARD_FALLING, this) = false;
	STAT(TRICK, this) = 0;
	this.skatespeed = 0;
	this.push_fast_time = 0;
	this.grind_start_time = 0;
	this.grind_stop_time = 0;
	this.second_trick = 0;
	this.diff_grinds = 0;
	this.spawn_time = time; // checking wrong direction for skate
}

#endif
