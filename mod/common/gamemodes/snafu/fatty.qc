#ifdef SVQC

const vector FATONE_MIN = '-30 -30 0';
const vector FATONE_MAX = '30 30 90';
const vector FATONE_DEAD_MIN = '-60 -60 0';
const vector FATONE_DEAD_MAX = '60 60 60';

const int fatone_idle = 0;
const int fatone_run = 1;
const int fatone_walkheadless = 2;
const int fatone_fallonass = 3;
const int fatone_throw = 4;
const int fatone_stab1 = 5;
const int fatone_stab2 = 6;
const int fatone_pain1 = 7;
const int fatone_pain2 = 8;
const int fatone_pain3 = 9;
const int fatone_die1 = 10;
const int fatone_dead1 = 11;
const int fatone_die2 = 12;
const int fatone_dead2 = 13;

void snafu_fatty_die(entity this)
{
	if(this.deadflag == DEAD_DYING)
	{
		if(this.frame == fatone_die1)
			this.frame = fatone_dead1;
		else
			this.frame = fatone_dead2;
		
		this.deadflag = DEAD_DEAD;
		
		SUB_SetFade(this, time + 5, 1);
	}
	else
	{        
		++snafu_zombie_killed;
		--snafu_zombie_alive;

		if(this.zombie_projectile)
			SUB_SetFade(this.zombie_projectile, time + 2.5, 1);
		
		if(this.zombie_head)
			SUB_SetFade(this.zombie_head, time + 2.5, 1);

		this.deadflag = DEAD_DYING;
		this.solid    = SOLID_CORPSE;
		set_movetype(this, MOVETYPE_TOSS);
		
		if(random() < 0.5)
		{
			sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_DEATH1, VOL_BASEVOICE, ATTN_NORM);    
			this.frame = fatone_die1;
			this.nextthink = time + 1.5;
		}            
		else
		{
			sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_DEATH2, VOL_BASEVOICE, ATTN_NORM);    
			this.frame = fatone_die2;
			this.nextthink = time + 1.766666666666667;
		}
	}
}

void snafu_fatty_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{    
	if(vdist(hitloc - this.origin, >, 256))
	{
		dprint("^1WARNING:^7 got fubar hitloc in damage()\n");
		Violence_GibSplash_At(this.origin + '0 0 0.5' * this.maxs_z, force, 2, bound(0, damage, 200) / 8, this, attacker);
	}
	else
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 8, this, attacker);
	
	/*if(this.zombie_head)
	if( (DEATH_ISWEAPON(deathtype, WEP_VORTEX)) ||
		(DEATH_ISWEAPON(deathtype, WEP_VAPORIZER)) ||
		(DEATH_ISWEAPON(deathtype, WEP_RIFLE)))
	{
		vector headmins, headmaxs, org;
		org = this.origin; //antilag_takebackorigin(targ, time - ANTILAG_LATENCY(attacker));
		headmins = org + '-0.5 0 0' * autocvar_g_snafu_fatty_headbox_x + '0 -0.5 0' * autocvar_g_snafu_fatty_headbox_y + '0 0 1' * (this.maxs_z - autocvar_g_snafu_fatty_headbox_z);
		headmaxs = org + '0.5 0 0' * autocvar_g_snafu_fatty_headbox_x + '0 0.5 0' * autocvar_g_snafu_fatty_headbox_y + '0 0 1' * this.maxs_z;
		if(trace_hits_box(railgun_start, railgun_end, headmins, headmaxs))
		{
			//vector l = '0 0 0';
			//l = gettaginfo(this, gettagindex(this, "Bip001 Head"));
			this.frame = fatone_walkheadless;
			setattachment(this.zombie_head, NULL, "");
			setorigin(this.zombie_head, gettaginfo(this, gettagindex(this, "Bip001 Head")));
			this.zombie_head.solid = SOLID_CORPSE;
			this.zombie_head.movetype = MOVETYPE_BOUNCE;
			this.zombie_head.velocity = this.velocity + '0 0 100' + randomvec() * 100 + force;
			this.zombie_head.avelocity = randomvec() * 180;
			this.zombie_head.angles = vectoangles(v_forward);
			this.zombie_head.owner = this;
			SUB_SetFade(this.zombie_head, time + 2.5, 1);
			this.zombie_head = NULL;
		}
	}*/
	
	this.health   -= damage;
	this.velocity += force * 0.75;
	
	if(this.health <= 0)
	{
		if(!IS_DEAD(this))
		{        
			if(this.zombie_projectile)
			{
				vector l = gettaginfo(this, gettagindex(this, "Bip001 L Hand"));
				setattachment(this.zombie_projectile, NULL, "");
				setorigin(this.zombie_projectile, l);
				this.zombie_projectile.solid = SOLID_CORPSE;
				set_movetype(this.zombie_projectile, MOVETYPE_TOSS);
				this.zombie_projectile.velocity = this.velocity + v_forward * (100 + random() * 300);
				this.zombie_projectile.avelocity = randomvec() * 180;
				this.zombie_projectile.owner = this;                
				this.zombie_projectile = NULL;
			}

			if(IS_PLAYER(attacker))
				UpdateFrags(attacker, 1);
				
			setsize(this, FATONE_DEAD_MIN, FATONE_DEAD_MAX);
			setthink(this, snafu_fatty_die);
			this.nextthink = time;       
			snafu_deathalert(this, attacker);
		}
	}
	else
	{
		snafu_damageswitch(this, attacker);

		if(this.attack_finished_single[0] < time)
		if(this.pain_finished + 0.5 < time)
		{
			this.pain_finished = time + 0.5;
			if(damage >= 50)
			{
				this.frame = fatone_fallonass;
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN1, VOL_BASEVOICE, ATTN_NORM);
				this.pain_finished = time + 1;
			}
			else if(random() < 0.5)
			{
				this.frame = fatone_pain1;
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN1, VOL_BASEVOICE, ATTN_NORM);    
			}
			else
			{                
				this.frame = fatone_pain2;
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN2, VOL_BASEVOICE, ATTN_NORM);    
			}
		}
	}    
}

void snafu_fatty_projectile_touch_think(entity this);
void snafu_fatty_projectile_touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	this.event_damage = func_null;
	
	if(!toucher && this.cnt > time)
	{
		this.cnt = time + 0.05 + random() * 0.25;
		setthink(this, snafu_fatty_projectile_touch_think);
		this.nextthink = this.cnt;
		return;
	}
			
	RadiusDamage (this, this.owner, 
				50, 
				25, 
				100, NULL, NULL, 
				150, DEATH_GENERIC.m_id, toucher);
	
	te_bloodshower(this.origin - '-20 -20 -20', this.origin + '20 20 20', 500, 1000);
	
	//void (vector org, vector velocity, float howmany) te_blood = #405;
	//void (vector mincorner, vector maxcorner, float explosionspeed, float howmany) te_bloodshower = #406;
	delete(this);

}

void snafu_fatty_projectile_touch_think(entity this)
{
	snafu_fatty_projectile_touch(this, NULL);
}

void snafu_fatty_think(entity this)
{    
	if(this.frame >= fatone_throw && this.frame <= fatone_stab2)
		this.nextthink = time + 0.05;
	else
		this.nextthink = time + 0.2;    
	
	float _delta = time - this.snafu_ai_lastupdate;
	this.snafu_ai_lastupdate = time;    
	if (_delta > 0.5)
		return;
	
	this.angles = normalize(this.moveto - this.origin);
	//this.angles = steerlib_beamsteer(this.angles, 256, 32, 30, 90);
	this.angles = vectoangles(this.angles);    
	this.angles_x = this.angles_z = 0;    
	//te_lightning1(this, this.origin + '0 0 128', this.moveto + '0 0 128');    
	fixedmakevectors(this.angles);
	
	if(this.enemy.deadflag != DEAD_NO)
		this.enemy = NULL;
	
	if(this.snafu_ai_enemy_select_timer < time || this.enemy == NULL)
		snafu_zombie_localtarget(this, autocvar_g_snafu_fatty_range_target);

	// Modal states: pain, fly, attack
	// Need to check flying first since we dont want to apply friction in-air
	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 16', MOVE_NORMAL, this);
	if(trace_fraction == 1.0)
		return;
	
	this.velocity -= (this.velocity * (autocvar_g_snafu_fatty_friction * _delta));
	float _dist  = vlen(NearestPointOnBox(this.enemy, this.origin) - this.origin);
	
	if(this.attack_finished_single[0] > time)
	{
		if(this.zombie_projectile.cnt < time && this.zombie_projectile.cnt != 0)
		{
			entity p = spawn();
			p.flags = FL_PROJECTILE;
			p.effects = EF_LOWPRECISION;
			_setmodel(p, this.zombie_projectile.model);
			setorigin(p, gettaginfo(this, gettagindex(this, "Bip001 L Hand")));
			PROJECTILE_MAKETRIGGER(p);
			setsize(p, '-1 -1 -1', '1 1 1');
			set_movetype(p, MOVETYPE_BOUNCE);
			p.velocity = v_forward * 2000 + v_up * 500;            
			
			p.cnt = _dist / autocvar_g_snafu_fatty_range_attack2_max;
			p.cnt *= 512;
			p.cnt = bound(32, p.cnt, 512);
			
			p.velocity = trigger_push_calculatevelocity(p.origin , this.enemy, p.cnt) + randomvec() * 64;
			p.avelocity = randomvec() * 180;
			p.owner = this;
			settouch(p, snafu_fatty_projectile_touch);
			setthink(p, SUB_Remove);
			p.nextthink = time + 15;
			p.cnt = time + 14;
			
			this.zombie_projectile.alpha = 0;
			this.zombie_projectile.effects |= EF_NODRAW;
			this.zombie_projectile.cnt = 0;
			_sound(this, CH_PAIN_SINGLE, SND(SNAFU_ZOMBIE_ATTACK_RANDOM()), VOL_BASEVOICE, ATTN_NORM);
		}
	
		if(this.cnt < time && this.cnt != 0 && this.frame != fatone_throw)
		{            
			this.cnt = 0;            
			snafu_zombie_domelee(this, 32, 100, 30, 250);
		}
		return;        
	}            

	if(this.pain_finished > time)
		return;    
	
	// End modal states    
	
	if(this.snafu_ai_unstick_done < time && 
	   this.snafu_ai_unstick_check < time && 
	   _dist > autocvar_g_snafu_fatty_range_attack * 4)
	{        
		this.snafu_ai_unstick_check = time + 4;
		tracebox(this.origin + '0 0 16', this.mins, this.maxs, '0 0 16' + this.origin + v_forward * 8, MOVE_NORMAL, this);
		if(trace_fraction != 1.0)
		{            
			if(trace_ent && trace_ent.takedamage && !trace_ent.snafu_ai_flags)
			{   // Blocked by somethign we can kill
				this.enemy = trace_ent;
				this.snafu_ai_enemy_select_timer = time + 15;
			}
			else
			{                
				if(random() < 0.5)
					this.pos1 = v_right;
				else
					this.pos1 = -v_right;
				this.pos1 += -v_forward * (random() * 0.5);
				this.snafu_ai_unstick_done = time + 6;
			}
		}
	}
	
	if(this.snafu_ai_unstick_done > time)
	{
		this.frame = fatone_run;
		this.moveto = this.origin + this.pos1 * 128;
	}
	else
		this.moveto = this.enemy.origin;
	

	if(this.zombie_head)
	{
		this.frame = fatone_run;
		if(_dist >= autocvar_g_snafu_fatty_range_attack2_min)
		if(_dist <= autocvar_g_snafu_fatty_range_attack2_max)
		if(this.zombie_projectile.attack_finished_single[0] < time)
		{            
			this.zombie_projectile.effects &= ~EF_NODRAW;
			if(this.zombie_projectile.wait < time)
			{ // Ranged attack?
				
				traceline(this.origin + '0 0 1' * this.maxs_z,
						  this.enemy.origin + '0 0 1'  *this.enemy.maxs_z,
						  MOVE_WORLDONLY, this);
				
				if(trace_fraction != 1.0)
				{   // Avoid exsessive tracing
					this.zombie_projectile.wait = time + 0.5;
					return;
				}
				
				this.frame = fatone_throw;
				this.zombie_projectile.attack_finished_single[0] = time + 10;
				this.attack_finished_single[0] = time + 0.64;
				this.zombie_projectile.cnt = time + 0.25;
				return;
			}
		}
		
		// Growl?
		if(this.wait < time)
		{
			if(random() > 0.5)
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_GROWL1, VOL_BASEVOICE, ATTN_NORM);
			else
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_GROWL2, VOL_BASEVOICE, ATTN_NORM);
			this.wait = time + 1 + random() * 4;
		}
	}
	else
	{ // No head, cant throw, bleed to death.
		this.frame = fatone_walkheadless;
		if(this.wait < time)
		{
			te_blood(this.origin + '0 0 80', v_up * 200 + randomvec() * 75, 20 + random() * 20);
			this.health -= 5;
			this.wait = time + 0.2;
			if(this.health <= 0)
			{
				setthink(this, snafu_fatty_die);
				this.nextthink = time;
				return;
			}
		}        
	}
	
	if(_dist <= autocvar_g_snafu_fatty_range_attack && !this.cnt)
	{
		this.attack_finished_single[0] = time + 0.64;
		this.cnt = time + 0.2; // Damage happens at this time;
		this.frame = fatone_stab1 + rint(random());
		_sound(this, CH_PAIN_SINGLE, SND(SNAFU_ZOMBIE_ATTACK_RANDOM()), VOL_BASEVOICE, ATTN_NORM);         
		return;
	}
	
	if(this.frame == fatone_run)
		this.velocity += v_forward * autocvar_g_snafu_fatty_speed_run * _delta;
		
	if(this.frame == fatone_walkheadless)
		this.velocity += v_forward * autocvar_g_snafu_fatty_speed_walk * _delta;
}

void snafu_fatty_create(entity own)
{
	entity zom              = spawn();
	zom.zombie_head         = spawn();
	zom.zombie_projectile   = spawn();
	
	setmodel(zom, MDL_SNAFU_FATTY);
	setmodel(zom.zombie_head, MDL_SNAFU_FATHEAD);
	setmodel(zom.zombie_projectile, MDL_SNAFU_CHICKENLEG);
	setattachment(zom.zombie_head, zom, "Bip001 Head");
	setattachment(zom.zombie_projectile, zom, "Bip001 L Hand");
	zom.zombie_head.owner       = own;
	zom.zombie_projectile.owner = own;
	setsize(zom, FATONE_MIN, FATONE_MAX);
	zom.zombie_head.solid = SOLID_SLIDEBOX;
	vector _where = own.origin;
	_where_x += random() * own.mins_x;
	_where_x += random() * own.maxs_x;
	_where_y += random() * own.mins_y;
	_where_y += random() * own.maxs_y;
	
	tracebox(_where + '0 0 64', zom.mins, zom.maxs, _where - '0 0 1' * MAX_SHOT_DISTANCE, MOVE_NORMAL, own);    
	setorigin(zom, trace_endpos);
	
	set_movetype(zom, MOVETYPE_WALK);
	zom.solid           = SOLID_SLIDEBOX;
	zom.deadflag        = DEAD_NO;
	zom.takedamage      = DAMAGE_AIM;
	zom.event_damage    = snafu_fatty_damage;    
	zom.snafu_ai_flags  = SAF_ZOMBIE;
	zom.health          = autocvar_g_snafu_fatty_health;
	setthink(zom, snafu_fatty_think);
	zom.nextthink       = time;
	zom.classname       = "zombie";
	zom.netname         = "Fatty";
	++snafu_zombie_spawned;
	++snafu_zombie_alive;
}

#endif
