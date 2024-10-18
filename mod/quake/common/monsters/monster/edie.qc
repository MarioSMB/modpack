#include "edie.qh"

#ifdef SVQC
const int anim_edie_run = 0; //'0 15 0'
const int anim_edie_runfire = 16; //'16 31 0'
const int anim_edie_firesitstart = 32; //'32 39 0'
const int anim_edie_firesit = 40; //'40 55 0'
const int anim_edie_firesitend = 56; //'56 59 0'
const int anim_edie_pain = 60; //'60 71 0'
const int anim_edie_painb = 72; //'72 76 0'
const int anim_edie_fswing = 77; //'77 87 0'
const int anim_edie_fswingend = 88; //'88 97 0'
const int anim_edie_bswing = 98; //'98 111 0'
const int anim_edie_death = 112; //'112 146 0'

//=============================================================================

void edie_run1(entity this);
void edie_run2(entity this);
void edie_run3(entity this);
void edie_run4(entity this);
void edie_run5(entity this);
void edie_run6(entity this);
void edie_run7(entity this);
void edie_run8(entity this);
void edie_run9(entity this);
void edie_run10(entity this);
void edie_run11(entity this);
void edie_run12(entity this);
void edie_run13(entity this);
void edie_run14(entity this);
void edie_run15(entity this);
void edie_run16(entity this);

float edieCheckLoS(entity this);

void edie_SpikeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float damg = 10;
	
	if(toucher.health)
	{
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
		spawn_touchblood(this, 18, toucher);
	}
	else
	{
		setorigin(this, this.origin - 8 * normalize(this.velocity));
		te_superspike(this.origin);
	}

	delete(this);
}


void breakToNormalRun(entity this, int frm)
{
	switch(frm)
	{
		case 1: setthink(this, edie_run2); break;
		case 2: setthink(this, edie_run3); break;
		case 3: setthink(this, edie_run4); break;
		case 4: setthink(this, edie_run5); break;
		case 5: setthink(this, edie_run6); break;
		case 6: setthink(this, edie_run7); break;
		case 7: setthink(this, edie_run8); break;
		case 8: setthink(this, edie_run9); break;
		case 9: setthink(this, edie_run10); break;
		case 10: setthink(this, edie_run11); break;
		case 11: setthink(this, edie_run12); break;
		case 12: setthink(this, edie_run13); break;
		case 13: setthink(this, edie_run14); break;
		case 14: setthink(this, edie_run15); break;
		case 15: setthink(this, edie_run16); break;
		case 16: setthink(this, edie_run1); break;
	}
}

void edie_Fire(entity this, float valx, float valy, float valz, bool moving)
{
	makevectors(this.angles);
	vector org = this.origin - v_right * valx + v_forward * valy + v_up * valz;

	bool noLoS = !((edieCheckLoS(this) > 0.6));

	if(!moving)
	{
		if(noLoS)
		{
			setthink(this, edie_run1);
			this.endtime = time + 2;
			return;
		}
	}

	if(moving)
	{
		this.endtime = this.endtime + 1;
			
		int frm = this.frame - 16;

		traceline(org, this.enemy.origin, false, this);
		
		if(this.endtime > (random() * 6 + 10))
		{
			breakToNormalRun(this, frm); //break out of run-fire
			this.endtime = time + 2;
			return;
		}	
		else if(trace_ent != this.enemy)
		{
			if(this.count > 10)
			{
				breakToNormalRun(this, frm);  //break out of run-fire
				this.endtime = time + 2;
				return;
			}
			this.count = this.count + 1;
		}
		else if(noLoS == 1)
		{
			breakToNormalRun(this, frm);  //break out of run-fire
			this.endtime = time + 2;
			return;
		}

		if(visible(this, this.enemy) && this.count != 0)
			this.count = 0;
	}

	//got passed all the checks, let's actually shoot now...

	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.classname = "edie_nail";
	missile.projectiledeathtype = DEATH_MONSTER_EDIE.m_id;
	_sound(this, CH_WEAPON_SINGLE, "weapons/spike2.wav", 0.8, 1.2);

	if(!moving && random() < 0.2) //randomly make him shoot badly sometimes, even when stopped and aiming.
		moving = true;

	if(!moving)  //not moving, shoot accurately
	{
		if(visible(this, this.enemy))
		{
			vector vec = this.enemy.origin - org; // set missile speed

			float fly = vlen(vec) / 800; // calc aproximate time for missile to reach vec

			vector move = this.enemy.velocity; // get the entities xy velocity
			move.z = 0; //so a jumping player can't cheat and make him miss

			vec = vec + move * fly;	// project the target forward in time
			vec = normalize(vec);
			
			//makevectors (this.angles);
			//vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5); //commented out, make it always accurate (edie's hardcore!)
			
			missile.velocity = vec * 800;
		}
	

		else
		{
			missile.velocity = (this.enemy.origin + '0 0 8');
			missile.velocity = normalize (missile.velocity - org);
			missile.velocity = missile.velocity * 800;
		}




//		missile.velocity = (this.enemy.origin - org);  //old dumb-fire nails
//		missile.velocity = normalize(missile.velocity);
//		missile.velocity = missile.velocity * 800;
		missile.angles = vectoangles(missile.velocity);
	}
	else //moving, so shoot a bit randomly
	{
		missile.velocity = (this.enemy.origin - org);
		missile.velocity = normalize(missile.velocity);
		missile.velocity = missile.velocity * 800;

		float dist = 50;//vlen(this.enemy.origin - org);
		missile.velocity_x = missile.velocity_x + (((random() * dist * 2) - (dist)) * 1);
		missile.velocity_y = missile.velocity_y + (((random() * dist * 2) - (dist)) * 1);
		missile.velocity_z = missile.velocity_z + (((random() * dist * 2) - (dist)) * 0.5);

		missile.velocity = normalize(missile.velocity);
		missile.velocity = missile.velocity * 800;

		missile.angles = vectoangles(missile.velocity);	
	}
	
	settouch(missile, edie_SpikeTouch);
	
// set missile duration
	missile.nextthink = time + 5;
	setthink(missile, SUB_Remove);

	_setmodel(missile, "progs/s_spike.mdl");
	setsize(missile, '0 0 0', '0 0 0');		

	setorigin(missile, org);
}

void edie_stand1(entity this);
void edie_stand8(entity this) { set_anim(this, 156, edie_stand1); ai_stand(this); }
void edie_stand7(entity this) { set_anim(this, 155, edie_stand8); ai_stand(this); }
void edie_stand6(entity this) { set_anim(this, 154, edie_stand7); ai_stand(this); }
void edie_stand5(entity this) { set_anim(this, 153, edie_stand6); ai_stand(this); }
void edie_stand4(entity this) { set_anim(this, 152, edie_stand5); ai_stand(this); }
void edie_stand3(entity this) { set_anim(this, 151, edie_stand4); ai_stand(this); }
void edie_stand2(entity this) { set_anim(this, 150, edie_stand3); ai_stand(this); }
void edie_stand1(entity this)
{
	set_anim(this, 149, edie_stand2);
	ai_stand(this);
	if((this.waitmin < time))
	{
		if(random() < 0.15)
		{
			_sound(this, CH_VOICE, "edie/idle1.wav", 1, ATTN_IDLE);
			this.waitmin = (time + 3);
		}
	}
}

void edie_walk1(entity this);
void edie_walk16(entity this) { set_animofs(this, anim_edie_run, 16, edie_walk1); ai_walk(this, 16); }
void edie_walk15(entity this) { set_animofs(this, anim_edie_run, 15, edie_walk16); ai_walk(this, 4); }
void edie_walk14(entity this) { set_animofs(this, anim_edie_run, 14, edie_walk15); ai_walk(this, 8); }
void edie_walk13(entity this) { set_animofs(this, anim_edie_run, 13, edie_walk14); ai_walk(this, 4); }
void edie_walk12(entity this) { set_animofs(this, anim_edie_run, 12, edie_walk13); ai_walk(this, 2); }
void edie_walk11(entity this) { set_animofs(this, anim_edie_run, 11, edie_walk12); ai_walk(this, 1); }
void edie_walk10(entity this) { set_animofs(this, anim_edie_run, 10, edie_walk11); ai_walk(this, 16); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_walk9(entity this) { set_animofs(this, anim_edie_run, 9, edie_walk10); ai_walk(this, 20); }
void edie_walk8(entity this) { set_animofs(this, anim_edie_run, 8, edie_walk9); ai_walk(this, 16); }
void edie_walk7(entity this) { set_animofs(this, anim_edie_run, 7, edie_walk8); ai_walk(this, 4); }
void edie_walk6(entity this) { set_animofs(this, anim_edie_run, 6, edie_walk7); ai_walk(this, 8); }
void edie_walk5(entity this) { set_animofs(this, anim_edie_run, 5, edie_walk6); ai_walk(this, 4); }
void edie_walk4(entity this) { set_animofs(this, anim_edie_run, 4, edie_walk5); ai_walk(this, 2); }
void edie_walk3(entity this) { set_animofs(this, anim_edie_run, 3, edie_walk4); ai_walk(this, 1); }
void edie_walk2(entity this) { set_animofs(this, anim_edie_run, 2, edie_walk3); ai_walk(this, 16); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_walk1(entity this) { set_animofs(this, anim_edie_run, 1, edie_walk2); ai_walk(this, 20); }

void ai_edie_run_firing(entity this, float dist, float frm)
{
	this.state = 1;
	ai_face(this);

	ai_forward(this, dist);
}

void edie_run_fire1(entity this);
void edie_run_fire16(entity this) { set_animofs(this, anim_edie_runfire, 16, edie_run_fire1); ai_edie_run_firing(this, this.multiplier * 4 ,16); edie_Fire(this, 16, 44, 34, 1); }
void edie_run_fire15(entity this) { set_animofs(this, anim_edie_runfire, 15, edie_run_fire16); ai_edie_run_firing(this, this.multiplier * 4 ,15); edie_Fire(this, 16, 52, 34, 1); }
void edie_run_fire14(entity this) { set_animofs(this, anim_edie_runfire, 14, edie_run_fire15); ai_edie_run_firing(this, this.multiplier * 8 ,14); edie_Fire(this, 16, 46, 37, 1); }
void edie_run_fire13(entity this) { set_animofs(this, anim_edie_runfire, 13, edie_run_fire14); ai_edie_run_firing(this, this.multiplier * 4 ,13); edie_Fire(this, 15, 53, 35, 1); }
void edie_run_fire12(entity this) { set_animofs(this, anim_edie_runfire, 12, edie_run_fire13); ai_edie_run_firing(this, this.multiplier * 2 ,12); edie_Fire(this, 16, 44, 36, 1); }
void edie_run_fire11(entity this) { set_animofs(this, anim_edie_runfire, 11, edie_run_fire12); ai_edie_run_firing(this, this.multiplier * 1 ,11); edie_Fire(this, 13, 52, 35, 1); }
void edie_run_fire10(entity this) { set_animofs(this, anim_edie_runfire, 10, edie_run_fire11); ai_edie_run_firing(this, this.multiplier * 16,10); edie_Fire(this, 15, 42, 37, 1); _sound(this, CH_VOICE, "edie/step.wav", 1, ATTN_IDLE); }
void edie_run_fire9(entity this) { set_animofs(this, anim_edie_runfire, 9, edie_run_fire10); ai_edie_run_firing(this, this.multiplier * 20,9); edie_Fire(this, 12, 50, 34, 1); }
void edie_run_fire8(entity this) { set_animofs(this, anim_edie_runfire, 8, edie_run_fire9); ai_edie_run_firing(this, this.multiplier * 4 ,8); edie_Fire(this, 15, 42, 40, 1); }
void edie_run_fire7(entity this) { set_animofs(this, anim_edie_runfire, 7, edie_run_fire8); ai_edie_run_firing(this, this.multiplier * 4 ,7); edie_Fire(this, 14, 53, 37, 1); }
void edie_run_fire6(entity this) { set_animofs(this, anim_edie_runfire, 6, edie_run_fire7); ai_edie_run_firing(this, this.multiplier * 8 ,6); edie_Fire(this, 18, 44, 40, 1); }
void edie_run_fire5(entity this) { set_animofs(this, anim_edie_runfire, 5, edie_run_fire6); ai_edie_run_firing(this, this.multiplier * 4 ,5); edie_Fire(this, 16, 53, 34, 1); }
void edie_run_fire4(entity this) { set_animofs(this, anim_edie_runfire, 4, edie_run_fire5); ai_edie_run_firing(this, this.multiplier * 2 ,4); edie_Fire(this, 19, 43, 35, 1); }
void edie_run_fire3(entity this) { set_animofs(this, anim_edie_runfire, 3, edie_run_fire4); ai_edie_run_firing(this, this.multiplier * 1 ,3); edie_Fire(this, 17, 53, 31, 1); }
void edie_run_fire2(entity this) { set_animofs(this, anim_edie_runfire, 2, edie_run_fire3); ai_edie_run_firing(this, this.multiplier * 16,2); edie_Fire(this, 18, 43, 33, 1); _sound(this, CH_VOICE, "edie/step.wav", 1, ATTN_IDLE); }
void edie_run_fire1(entity this) { set_animofs(this, anim_edie_runfire, 1, edie_run_fire2); ai_edie_run_firing(this, this.multiplier * 20,1); edie_Fire(this, 20, 50, 32, 1); }

void ai_edie_run(entity this, float dist, int frm)
{
	this.state = 0;

	traceline(this.origin, this.enemy.origin, false, this);

	if(trace_ent == this.enemy && edieCheckLoS(this) > 0.6 && random() < 0.15 && time > this.endtime)
	{
		switch(frm)
		{
			case 1: setthink(this, edie_run_fire2); break;
			case 2: setthink(this, edie_run_fire3); break;
			case 3: setthink(this, edie_run_fire4); break;
			case 4: setthink(this, edie_run_fire5); break;
			case 5: setthink(this, edie_run_fire6); break;
			case 6: setthink(this, edie_run_fire7); break;
			case 7: setthink(this, edie_run_fire8); break;
			case 8: setthink(this, edie_run_fire9); break;
			case 9: setthink(this, edie_run_fire10); break;
			case 10: setthink(this, edie_run_fire11); break;
			case 11: setthink(this, edie_run_fire12); break;
			case 12: setthink(this, edie_run_fire13); break;
			case 13: setthink(this, edie_run_fire14); break;
			case 14: setthink(this, edie_run_fire15); break;
			case 15: setthink(this, edie_run_fire16); break;
			case 16: setthink(this, edie_run_fire1); break;
		}

		this.endtime = 0;
	}
	
	ai_run(this, dist);
}

void edie_firesit1(entity this);
void edie_run16(entity this) { set_animofs(this, anim_edie_run, 16, edie_run1); ai_edie_run(this, this.multiplier * 4, 16); }
void edie_run15(entity this) { set_animofs(this, anim_edie_run, 15, edie_run16); ai_edie_run(this, this.multiplier * 4, 15); }
void edie_run14(entity this) { set_animofs(this, anim_edie_run, 14, edie_run15); ai_edie_run(this, this.multiplier * 8, 14); }
void edie_run13(entity this) { set_animofs(this, anim_edie_run, 13, edie_run14); ai_edie_run(this, this.multiplier * 4, 13); }
void edie_run12(entity this) { set_animofs(this, anim_edie_run, 12, edie_run13); ai_edie_run(this, this.multiplier * 2, 12); }
void edie_run11(entity this) { set_animofs(this, anim_edie_run, 11, edie_run12); ai_edie_run(this, this.multiplier * 1, 11); }
void edie_run10(entity this) { set_animofs(this, anim_edie_run, 10, edie_run11); ai_edie_run(this, this.multiplier * 16, 10); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_run9(entity this) { set_animofs(this, anim_edie_run, 9, edie_run10); ai_edie_run(this, this.multiplier * 20, 9); }
void edie_run8(entity this) { set_animofs(this, anim_edie_run, 8, edie_run9); ai_edie_run(this, this.multiplier * 4, 8); }
void edie_run7(entity this) { set_animofs(this, anim_edie_run, 7, edie_run8); ai_edie_run(this, this.multiplier * 4, 7); }
void edie_run6(entity this) { set_animofs(this, anim_edie_run, 6, edie_run7); ai_edie_run(this, this.multiplier * 8, 6); }
void edie_run5(entity this) { set_animofs(this, anim_edie_run, 5, edie_run6); ai_edie_run(this, this.multiplier * 4, 5); }
void edie_run4(entity this) { set_animofs(this, anim_edie_run, 4, edie_run5); ai_edie_run(this, this.multiplier * 2, 4); }
void edie_run3(entity this) { set_animofs(this, anim_edie_run, 3, edie_run4); ai_edie_run(this, this.multiplier * 1, 3); }
void edie_run2(entity this) { set_animofs(this, anim_edie_run, 2, edie_run3); ai_edie_run(this, this.multiplier * 16, 2); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_run1(entity this) { set_animofs(this, anim_edie_run, 1, edie_run2); ai_edie_run(this, this.multiplier * 20, 1); }

void edie_firesit_start8(entity this) { set_animofs(this, anim_edie_firesitstart, 8, edie_firesit1); ai_face(this); }
void edie_firesit_start7(entity this) { set_animofs(this, anim_edie_firesitstart, 7, edie_firesit_start8); ai_face(this); }
void edie_firesit_start6(entity this) { set_animofs(this, anim_edie_firesitstart, 6, edie_firesit_start7); ai_face(this); }
void edie_firesit_start5(entity this) { set_animofs(this, anim_edie_firesitstart, 5, edie_firesit_start6); ai_face(this); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_firesit_start4(entity this) { set_animofs(this, anim_edie_firesitstart, 4, edie_firesit_start5); ai_face(this); }
void edie_firesit_start3(entity this) { set_animofs(this, anim_edie_firesitstart, 3, edie_firesit_start4); ai_face(this); }
void edie_firesit_start2(entity this) { set_animofs(this, anim_edie_firesitstart, 2, edie_firesit_start3); ai_face(this); }
void edie_firesit_start1(entity this) { set_animofs(this, anim_edie_firesitstart, 1, edie_firesit_start2); ai_face(this); _sound(this, CH_VOICE, "edie/stfire.wav", 1, ATTN_IDLE); }


void edie_firesit_end1(entity this);

void check_edie_fire(entity this)
{
	if(visible(this, this.enemy))
		this.count = 0;
	else
	{
		this.count = this.count + 1;
		if(this.count > 6)
			setthink(this, edie_firesit_end1);
	}
}

void edie_firesit16(entity this) { set_animofs(this, anim_edie_firesit, 16, edie_firesit_end1); check_edie_fire(this); ai_face(this); edie_Fire(this, 18, 27, 27, 0); }
void edie_firesit15(entity this) { set_animofs(this, anim_edie_firesit, 15, edie_firesit16); check_edie_fire(this); ai_face(this); edie_Fire(this, 18, 27, 27, 0); }
void edie_firesit14(entity this) { set_animofs(this, anim_edie_firesit, 14, edie_firesit15); check_edie_fire(this); ai_face(this); edie_Fire(this, 18, 32, 25, 0); }
void edie_firesit13(entity this) { set_animofs(this, anim_edie_firesit, 13, edie_firesit14); check_edie_fire(this); ai_face(this); edie_Fire(this, 18, 32, 25, 0); }
void edie_firesit12(entity this) { set_animofs(this, anim_edie_firesit, 12, edie_firesit13); check_edie_fire(this); ai_face(this); edie_Fire(this, 17, 38, 27, 0); }
void edie_firesit11(entity this) { set_animofs(this, anim_edie_firesit, 11, edie_firesit12); check_edie_fire(this); ai_face(this); edie_Fire(this, 17, 38, 27, 0); }
void edie_firesit10(entity this) { set_animofs(this, anim_edie_firesit, 10, edie_firesit11); check_edie_fire(this); ai_face(this); edie_Fire(this, 17, 42, 26, 0); }
void edie_firesit9(entity this) { set_animofs(this, anim_edie_firesit, 9, edie_firesit10); check_edie_fire(this); ai_face(this); edie_Fire(this, 17, 42, 26, 0); }
void edie_firesit8(entity this) { set_animofs(this, anim_edie_firesit, 8, edie_firesit9); check_edie_fire(this); ai_face(this); edie_Fire(this, 14, 49, 23, 0); }
void edie_firesit7(entity this) { set_animofs(this, anim_edie_firesit, 7, edie_firesit8); check_edie_fire(this); ai_face(this); edie_Fire(this, 14, 49, 23, 0); }
void edie_firesit6(entity this) { set_animofs(this, anim_edie_firesit, 6, edie_firesit7); check_edie_fire(this); ai_face(this); edie_Fire(this, 12, 47, 23, 0); }
void edie_firesit5(entity this) { set_animofs(this, anim_edie_firesit, 5, edie_firesit6); check_edie_fire(this); ai_face(this); edie_Fire(this, 12, 47, 23, 0); }
void edie_firesit4(entity this) { set_animofs(this, anim_edie_firesit, 4, edie_firesit5); check_edie_fire(this); ai_face(this); edie_Fire(this, 10, 50, 22, 0); }
void edie_firesit3(entity this) { set_animofs(this, anim_edie_firesit, 3, edie_firesit4); check_edie_fire(this); ai_face(this); edie_Fire(this, 10, 50, 22, 0); }
void edie_firesit2(entity this) { set_animofs(this, anim_edie_firesit, 2, edie_firesit3); check_edie_fire(this); ai_face(this); edie_Fire(this, 10, 50, 20, 0); }
void edie_firesit1(entity this) { set_animofs(this, anim_edie_firesit, 1, edie_firesit2); check_edie_fire(this); ai_face(this); edie_Fire(this, 10, 50, 20, 0); }

void edie_firesit_end4(entity this) { set_animofs(this, anim_edie_firesitend, 4, edie_run1); }
void edie_firesit_end3(entity this) { set_animofs(this, anim_edie_firesitend, 3, edie_firesit_end4); }
void edie_firesit_end2(entity this) { set_animofs(this, anim_edie_firesitend, 2, edie_firesit_end3); }
void edie_firesit_end1(entity this) { set_animofs(this, anim_edie_firesitend, 1, edie_firesit_end2); }

//============================================ [ START MELEE ] ==================================================
void edie_fswing_end1(entity this);

void edie_melee_hit(entity this, float dist, float kickback, float dmg)
{
	entity e = findradius(this.origin, dist);
	while (e)
	{
		if(e != this && e.health > 0)
		{
			makevectors(this.angles);
			vector dist_front = (this.origin + (v_forward * 100) - (this.origin + normalize(e.origin - this.origin) * 100));

			if(vdist(dist_front, <, 100) && visible(this, e))
			{		
				if(e == this.enemy) 
					T_Damage(e, this, this, dmg, DEATH_MONSTER_EDIE.m_id);
				else
					T_Damage(e, this, this, dmg * 0.25, DEATH_MONSTER_EDIE.m_id);

				if(!this.gug_slapped)
				{
					_sound(this, CH_WEAPON_SINGLE, "edie/mangle.wav", 1, ATTN_NORM);
					this.gug_slapped = true;
				}

				// large targets don't get kicked back
				if(e.size_x <= 32 && (IS_MONSTER(e) || IS_PLAYER(e)))
				{
					UNSET_ONGROUND(e);
					
					e.velocity = e.velocity + '0 0 24' * dmg;
					e.velocity = e.velocity*0.5 + ((normalize(e.origin - this.origin)) * kickback);

					if(e.velocity_z > 400)
						e.velocity_z = 400;
				}
			}	
		}
		e = e.chain;
	}
	this.gug_slapped = false;
}

void edie_bswing1(entity this);
void edie_fswing11(entity this)
{
	set_animofs(this, anim_edie_fswing, 11, edie_bswing1); 
	traceline (this.origin, this.enemy.origin, false, this);

	if(vdist(this.origin - this.enemy.origin, >, 150) || trace_ent != this.enemy || !visible(this, this.enemy)) //don't have a shot, break melee chain
		setthink(this, edie_fswing_end1);

	ai_face(this);
	ai_forward(this, 2);
}
void edie_fswing10(entity this) { set_animofs(this, anim_edie_fswing, 10, edie_fswing11); ai_face(this); ai_forward(this, 2); }
void edie_fswing9(entity this) { set_animofs(this, anim_edie_fswing, 9, edie_fswing10); ai_face(this); ai_forward(this, 2); }
void edie_fswing8(entity this) { set_animofs(this, anim_edie_fswing, 8, edie_fswing9); this.nextthink = time + 0.05; ai_face(this); ai_forward(this, 2); edie_melee_hit(this, 100, 30, 20); }
void edie_fswing7(entity this) { set_animofs(this, anim_edie_fswing, 7, edie_fswing8); this.nextthink = time + 0.06; ai_face(this); ai_forward(this, 1); }
void edie_fswing6(entity this) { set_animofs(this, anim_edie_fswing, 6, edie_fswing7); this.nextthink = time + 0.07; ai_face(this); ai_forward(this, 1); }
void edie_fswing5(entity this) { set_animofs(this, anim_edie_fswing, 5, edie_fswing6); this.nextthink = time + 0.07; ai_face(this); ai_forward(this, 2); }
void edie_fswing4(entity this) { set_animofs(this, anim_edie_fswing, 4, edie_fswing5); this.nextthink = time + 0.08; ai_face(this); ai_forward(this, 4); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_fswing3(entity this) { set_animofs(this, anim_edie_fswing, 3, edie_fswing4); this.nextthink = time + 0.09; ai_face(this); ai_forward(this, 10); }
void edie_fswing2(entity this) { set_animofs(this, anim_edie_fswing, 2, edie_fswing3); this.nextthink = time + 0.1; ai_face(this); ai_forward(this, 16); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_fswing1(entity this) { set_animofs(this, anim_edie_fswing, 1, edie_fswing2); this.nextthink = time + 0.1; ai_face(this); ai_forward(this, 8); _sound(this, CH_VOICE, "edie/sawstart.wav", 1, ATTN_IDLE); }

void edie_fswing_end10(entity this) { set_animofs(this, anim_edie_fswingend, 10, edie_run1); ai_face(this); ai_forward(this, 16); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_fswing_end9(entity this) { set_animofs(this, anim_edie_fswingend, 9, edie_fswing_end10); ai_face(this); ai_forward(this, 16); }
void edie_fswing_end8(entity this) { set_animofs(this, anim_edie_fswingend, 8, edie_fswing_end9); ai_face(this); ai_forward(this, 12); }
void edie_fswing_end7(entity this) { set_animofs(this, anim_edie_fswingend, 7, edie_fswing_end8); ai_face(this); ai_forward(this, 16); }
void edie_fswing_end6(entity this) { set_animofs(this, anim_edie_fswingend, 6, edie_fswing_end7); ai_face(this); ai_forward(this, 12); }
void edie_fswing_end5(entity this) { set_animofs(this, anim_edie_fswingend, 5, edie_fswing_end6); ai_face(this); ai_forward(this, 8); }
void edie_fswing_end4(entity this) { set_animofs(this, anim_edie_fswingend, 4, edie_fswing_end5); ai_face(this); ai_forward(this, 4); }
void edie_fswing_end3(entity this) { set_animofs(this, anim_edie_fswingend, 3, edie_fswing_end4); ai_face(this); ai_forward(this, 3); }
void edie_fswing_end2(entity this) { set_animofs(this, anim_edie_fswingend, 2, edie_fswing_end3); ai_face(this); ai_forward(this, 2); }
void edie_fswing_end1(entity this) { set_animofs(this, anim_edie_fswingend, 1, edie_fswing_end2); ai_face(this); ai_forward(this, 2); }

void edie_bswing14(entity this) { set_animofs(this, anim_edie_bswing, 14, edie_run1); ai_face(this); ai_forward(this, 10); }
void edie_bswing13(entity this) { set_animofs(this, anim_edie_bswing, 13, edie_bswing14); ai_face(this); ai_forward(this, 10); }
void edie_bswing12(entity this) { set_animofs(this, anim_edie_bswing, 12, edie_bswing13); ai_face(this); ai_forward(this, 12); }
void edie_bswing11(entity this) { set_animofs(this, anim_edie_bswing, 11, edie_bswing12); ai_face(this); ai_forward(this, 8); }
void edie_bswing10(entity this) { set_animofs(this, anim_edie_bswing, 10, edie_bswing11); ai_face(this); ai_forward(this, 8); }
void edie_bswing9(entity this) { set_animofs(this, anim_edie_bswing, 9, edie_bswing10); ai_face(this); ai_forward(this, 8); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_bswing8(entity this) { set_animofs(this, anim_edie_bswing, 8, edie_bswing9); ai_face(this); ai_forward(this, 8); }
void edie_bswing7(entity this) { set_animofs(this, anim_edie_bswing, 7, edie_bswing8); ai_face(this); ai_forward(this, 4); }
void edie_bswing6(entity this) { set_animofs(this, anim_edie_bswing, 6, edie_bswing7); ai_face(this); ai_forward(this, 4); }
void edie_bswing5(entity this) { set_animofs(this, anim_edie_bswing, 5, edie_bswing6); ai_face(this); ai_forward(this, 6); edie_melee_hit(this, 100, 12, 20); }
void edie_bswing4(entity this) { set_animofs(this, anim_edie_bswing, 4, edie_bswing5); ai_face(this); ai_forward(this, 2); _sound(this, CHAN_BODY, "edie/step.wav", 1, ATTN_IDLE); }
void edie_bswing3(entity this) { set_animofs(this, anim_edie_bswing, 3, edie_bswing4); ai_face(this); ai_forward(this, 4); }
void edie_bswing2(entity this) { set_animofs(this, anim_edie_bswing, 2, edie_bswing3); ai_face(this); ai_forward(this, 12); }
void edie_bswing1(entity this) { set_animofs(this, anim_edie_bswing, 1, edie_bswing2); ai_face(this); ai_forward(this, 20);  _sound(this, CH_VOICE, "edie/sawstart.wav", 1, ATTN_IDLE); }


//=================================================== [ END MELEE ] ==================================================


void edie_pain12(entity this) { set_animofs(this, anim_edie_pain, 12, edie_run1); }
void edie_pain11(entity this) { set_animofs(this, anim_edie_pain, 11, edie_pain12); }
void edie_pain10(entity this) { set_animofs(this, anim_edie_pain, 10, edie_pain11); }
void edie_pain9(entity this) { set_animofs(this, anim_edie_pain, 9, edie_pain10); }
void edie_pain8(entity this) { set_animofs(this, anim_edie_pain, 8, edie_pain9); }
void edie_pain7(entity this) { set_animofs(this, anim_edie_pain, 7, edie_pain8); }
void edie_pain6(entity this) { set_animofs(this, anim_edie_pain, 6, edie_pain7); }
void edie_pain5(entity this) { set_animofs(this, anim_edie_pain, 5, edie_pain6); }
void edie_pain4(entity this) { set_animofs(this, anim_edie_pain, 4, edie_pain5); ai_pain(this, 4); }
void edie_pain3(entity this) { set_animofs(this, anim_edie_pain, 3, edie_pain4); ai_pain(this, 9); }
void edie_pain2(entity this) { set_animofs(this, anim_edie_pain, 2, edie_pain3); ai_pain(this, 10); }
void edie_pain1(entity this) { set_animofs(this, anim_edie_pain, 1, edie_pain2); }

void edie_painb5(entity this) { set_animofs(this, anim_edie_painb, 5, edie_run1); }
void edie_painb4(entity this) { set_animofs(this, anim_edie_painb, 4, edie_painb5); }
void edie_painb3(entity this) { set_animofs(this, anim_edie_painb, 3, edie_painb4); }
void edie_painb2(entity this) { set_animofs(this, anim_edie_painb, 2, edie_painb3); }
void edie_painb1(entity this) { set_animofs(this, anim_edie_painb, 1, edie_painb2); }

void edie_pain(entity this, entity attacker, float damage, int deathtype)
{
// don't make multiple pain sounds right after each other
	if(this.pain_finished > time)
		return;

	if(damage > 55)
	{
		if(random() < 0.4)
		{
			_sound(this, CH_VOICE, "edie/pain.wav", 1, ATTN_NORM);
			edie_pain1(this);
			this.pain_finished = time + 3 + random() * 2;
		}
		else
		{
			_sound(this, CH_VOICE, "edie/painshrt.wav", 1, ATTN_NORM);
			edie_painb1(this);
			this.pain_finished = time + 1 + random() * 2;
		}
	}
	else
	{
		if(random() < 0.1)
		{
			_sound(this, CH_VOICE, "edie/pain.wav", 1, ATTN_NORM);
			edie_pain1(this);
			this.pain_finished = time + 3 + random() * 2;
		}
		else
		{
			_sound(this, CH_VOICE, "edie/painshrt.wav", 1, ATTN_NORM);
			edie_painb1(this);
			this.pain_finished = time + 1 + random() * 2;
		}	
	}
}

void edie_death34(entity this) { set_animofs(this, anim_edie_death, 35, edie_death34); CorpseThink(this); }
void edie_death33(entity this) { set_animofs(this, anim_edie_death, 34, edie_death34); }
void edie_death32(entity this) { set_animofs(this, anim_edie_death, 33, edie_death33); }
void edie_death31(entity this) { set_animofs(this, anim_edie_death, 32, edie_death32); }
void edie_death30(entity this) { set_animofs(this, anim_edie_death, 31, edie_death31); }
void edie_death29(entity this) { set_animofs(this, anim_edie_death, 30, edie_death30); }
void edie_death28(entity this) { set_animofs(this, anim_edie_death, 29, edie_death29); }
void edie_death27(entity this) { set_animofs(this, anim_edie_death, 28, edie_death28); }
void edie_death26(entity this) { set_animofs(this, anim_edie_death, 27, edie_death27); }
void edie_death25(entity this) { set_animofs(this, anim_edie_death, 26, edie_death26); }
void edie_death24(entity this) { set_animofs(this, anim_edie_death, 25, edie_death25); }
void edie_death23(entity this) { set_animofs(this, anim_edie_death, 24, edie_death24); }
void edie_death22(entity this) { set_animofs(this, anim_edie_death, 23, edie_death23); }
void edie_death21(entity this) { set_animofs(this, anim_edie_death, 22, edie_death22); }
void edie_death20(entity this) { set_animofs(this, anim_edie_death, 21, edie_death21); }
void edie_death19(entity this) { set_animofs(this, anim_edie_death, 20, edie_death20); }
void edie_death18(entity this) { set_animofs(this, anim_edie_death, 19, edie_death19); }
void edie_death17(entity this) { set_animofs(this, anim_edie_death, 18, edie_death18); }
void edie_death16(entity this) { set_animofs(this, anim_edie_death, 17, edie_death17); }
void edie_death15(entity this) { set_animofs(this, anim_edie_death, 16, edie_death16); }
void edie_death14(entity this) { set_animofs(this, anim_edie_death, 15, edie_death15); }
void edie_death13(entity this) { set_animofs(this, anim_edie_death, 14, edie_death14); }
void edie_death12(entity this) { set_animofs(this, anim_edie_death, 13, edie_death13); }
void edie_death11(entity this) { set_animofs(this, anim_edie_death, 12, edie_death12); }
void edie_death10(entity this) { set_animofs(this, anim_edie_death, 11, edie_death11); }
void edie_death9(entity this) { set_animofs(this, anim_edie_death, 9, edie_death10); }
void edie_death8(entity this) { set_animofs(this, anim_edie_death, 8, edie_death9); }
void edie_death7(entity this) { set_animofs(this, anim_edie_death, 7, edie_death8); }
void edie_death6(entity this) { set_animofs(this, anim_edie_death, 6, edie_death7); }
void edie_death5(entity this) { set_animofs(this, anim_edie_death, 5, edie_death6); }
void edie_death4(entity this) { set_animofs(this, anim_edie_death, 4, edie_death5); }
void edie_death3(entity this) { set_animofs(this, anim_edie_death, 3, edie_death4); }
void edie_death2(entity this) { set_animofs(this, anim_edie_death, 2, edie_death3); this.nextthink = time + 0.2; }
void edie_death1(entity this) { set_animofs(this, anim_edie_death, 1, edie_death2); this.nextthink = time + 0.2; this.solid = SOLID_TRIGGER; setorigin(this, this.origin); _sound(this, CH_VOICE, "edie/death.wav", 1, 1); }

void edie_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -80)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_ogre.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}
	_sound(this, CH_VOICE, "edie/death.wav", 1, ATTN_NORM);

	edie_death1(this);
}

void edie_ranged(entity this)
{
	if(this.state == 1)
		return;
	edie_firesit_start1(this);
}

float edieCheckLoS(entity this)
{
	makevectors(this.angles);
	
	//check if player is in a cone in front of edie
	//vec = normalize (this.enemy.origin - this.origin);
		
	vector vec = this.enemy.origin - this.origin;
	vec.z = 0;
				
	float fly = vlen(vec) / 800;
				
	vector move = this.enemy.velocity;
	//move_z = 0;
				
	vec = vec + move * fly;	// project the target forward in time
	vec = normalize(vec);

	float dot = (vec * v_forward);
	
	return dot;
}

float EdieCheckAttack(entity this)
{
	entity targ = this.enemy;
	float chance = 0;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
		return false;		// don't have a clear shot
			
	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(this.enemy_range == RANGE_MELEE)
	{	// melee attack
		if(this.th_melee)
		{
			this.th_melee(this);
			return true;
		}
	}
	
// missile attack
	if(!this.th_missile)
		return false;
		
	if(time < this.attack_finished)
		return false;
		
	if(this.enemy_range == RANGE_FAR)
		return false;

	if(this.enemy_range == RANGE_MELEE)
	{
		if(edieCheckLoS(this) <= 0.6)
			return false;
		chance = 0.3;
		this.attack_finished = 0;
	}
	else if(this.enemy_range == RANGE_NEAR)
	{
		if(edieCheckLoS(this) <= 0.2)
			return false;
		chance = 0.2;
	}
	else if(this.enemy_range == RANGE_MID)
		chance = 0.1;
	else
		chance = 0;

	if(random() < chance)
	{
		this.th_missile(this);
		this.attack_finished = 2 * random();
		return true;
	}

	return false;
}

/*QUAKED monster_edie(1 0 0)(-32 -32 -24)(32 32 64)
*/
spawnfunc(monster_edie) { monster_start(this, true, MON_EDIE); }

// alkaline
spawnfunc(monster_banshee) { monster_start(this, true, MON_EDIE); }
#endif // SVQC

#ifdef SVQC
METHOD(Edie, mr_setup, bool(Edie this, entity actor))
{
    TC(Edie, this);

    precache_sound("edie/death.wav");
	
	precache_sound("edie/pain.wav");
	precache_sound("edie/painshrt.wav");
	
	precache_sound("edie/idle1.wav");
	precache_sound("edie/step.wav");
	precache_sound("edie/mangle.wav");
	
	precache_sound("edie/stfire.wav");
	precache_sound("edie/sawstart.wav");

	actor.th_stand = edie_stand1;
	actor.th_walk = edie_walk1;
	actor.th_run = edie_run1;
	actor.th_die = edie_die;
	actor.th_melee = edie_fswing1;
	actor.th_missile = edie_firesit_start1;
	actor.th_pain = edie_pain;
	actor.checkattack = EdieCheckAttack;

	actor.yaw_speed = 16;
	actor.health = 500;
	actor.multiplier = 1.2;

    return true;
}
#endif
