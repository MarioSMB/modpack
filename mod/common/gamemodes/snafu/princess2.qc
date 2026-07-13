#ifdef GAMEQC
MODEL(SNAFU_PRINCESS, "models/snafu/princess.dpm");
#endif

CLASS(Princess, Gai)
    ATTRIB(Princess, m_mins, vector, '-16 -16 0');
    ATTRIB(Princess, m_maxs, vector, '16 16 75');
#ifdef GAMEQC
    ATTRIB(Princess, m_model, Model, MDL_SNAFU_PRINCESS);
#endif
    ATTRIB(Princess, deadmins, vector, '-32 -32 0');
    ATTRIB(Princess, deadmaxs, vector, '32 32 0');
    ATTRIB(Princess, netname, string, "princess");
    ATTRIB(Princess, monster_name, string, _("Princess"));
ENDCLASS(Princess)

REGISTER_GAI(PRINCESS, NEW(Princess));

#ifdef SVQC

void snafu_princess_die(entity this)
{
	if(this.deadflag == DEAD_DYING)
	{
		if(this.frame == princess_die1)
			this.frame = princess_dead1;
		else
			this.frame = princess_dead2;            
		
		this.deadflag = DEAD_DEAD;
		SUB_SetFade(this, time + 5, 1);
	}
	else
	{        
		++snafu_zombie_killed;
		--snafu_zombie_alive;
		
		this.deadflag = DEAD_DYING;
		this.solid    = SOLID_CORPSE;
		set_movetype(this, MOVETYPE_TOSS);
		
		if(random() < 0.5)
		{
			sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_DEATH1, VOL_BASEVOICE, ATTN_NORM);    
			this.frame = princess_die1;
			this.nextthink = time + 1.533333333333333;
		}            
		else
		{
			sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_DEATH2, VOL_BASEVOICE, ATTN_NORM);    
			this.frame = princess_die2;
			this.nextthink = time + 1.766666666666667;
		}
	}
}

void snafu_princess_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(vdist(hitloc - this.origin, >, 256))
	{
		LOG_DEBUG("^1WARNING:^7 got fubar hitloc in damage()\n");
		Violence_GibSplash_At(this.origin + '0 0 0.5' * this.maxs_z, force, 2, bound(0, damage, 200) / 8, this, attacker);
	}
	else
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 8, this, attacker);    
	
	TakeResource(this, RES_HEALTH, damage);
	//this.velocity += force * 3;
	
	snafu_damageswitch(this, attacker);
	
	if(GetResource(this, RES_HEALTH) <= 0)
	{
		if(this.deadflag == DEAD_NO)
		{
			if(IS_PLAYER(attacker))
				GameRules_scoring_add_team(attacker, SCORE, 1);
			
			Gai info = REGISTRY_GET(Gais, this.gaid);
			setsize(this, info.deadmins, info.deadmaxs);
			setthink(this, snafu_princess_die);
			this.nextthink = time;            
			snafu_deathalert(this, attacker);
		}
	}
	else
	{
		if(this.attack_finished_single[0] < time)
		if(this.pain_finished + 0.5 < time)
		{
			this.pain_finished = time + 0.5;
			if(random() < 0.5)
			{
				this.frame = princess_pain1;
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN1, VOL_BASEVOICE, ATTN_NORM);   
			}
			else
			{                
				this.frame = princess_pain2;
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN2, VOL_BASEVOICE, ATTN_NORM); 
			}
		}
	}
}

void snafu_princess_think(entity this)
{    
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

	if(IS_DEAD(this.enemy))
		this.enemy = NULL;
	
	if(this.snafu_ai_enemy_select_timer < time || this.enemy == NULL)
		snafu_zombie_localtarget(this, autocvar_g_snafu_princess_range_target);

	// Modal states: pain, fly, attack
			
	// Need to check flying first since we dont want to apply friction in-air
	tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 16', MOVE_NORMAL, this);
	if(trace_fraction == 1.0)
	{
		if(this.pain_finished < time)
		if(this.attack_finished_single[0] < time)
			this.frame = princess_falling;
		
		return;
	}
	
	this.velocity -= (this.velocity * (autocvar_g_snafu_princess_friction * _delta));
	
	if(this.attack_finished_single[0] > time)
	{
		if(this.cnt < time && this.cnt != 0)
		{
			this.cnt = 0;
			snafu_zombie_domelee(this, 32 , 64, 10, 150);
		}
		return;        
	}            

	if(this.pain_finished > time)
		return;    
	
	// End modal states

	if(this.snafu_ai_unstick_done < time && 
	   this.snafu_ai_unstick_check < time)
	{
		this.snafu_ai_unstick_check = time + 1;
		tracebox(this.origin + '0 0 32', this.mins, this.maxs, '0 0 32' + this.origin + v_forward * 32, MOVE_NORMAL, this);
		if(trace_fraction != 1.0)
		{
			if(trace_ent && trace_ent.takedamage && !trace_ent.snafu_ai_flags)
			{   // Blocked by something we can kill
				//LOG_DEBUG("Kill-able blockade dist: ", ftos(vlen(this.origin - trace_ent.origin)));
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
				this.snafu_ai_unstick_done = time + 5;
			}
		}
	}
	
	if(this.snafu_ai_unstick_done > time)
	{
		this.frame = princess_walk;
		this.moveto = this.origin + this.pos1 * 128;        
	}
	else
		this.moveto = this.enemy.origin;
	
	// Move?
	//if(this.enemy)// != snafu_tadpole)
	if(vdist(NearestPointOnBox(this.enemy, this.origin) - this.origin, >, autocvar_g_snafu_princess_range_walk))
		this.frame = princess_run;
	else
		this.frame = princess_walk;
	
	// Attack?
	if(vdist(NearestPointOnBox(this.enemy, this.origin) - this.origin, <=, autocvar_g_snafu_princess_range_attack))
	{
		this.attack_finished_single[0] = time + 1.5;                
		this.frame = princess_slap1 + rint(random() * 4);
		this.cnt = time + 0.5;
		_sound(this, CH_PAIN_SINGLE, SND(SNAFU_ZOMBIE_ATTACK_FRAME(this.frame - 2)), VOL_BASEVOICE, ATTN_NORM);            
		return;
	}
	
	// Growl?
	if(this.wait < time)
	{
		if(random() > 0.5)
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_GROWL1, VOL_BASEVOICE, ATTN_NORM);
			else
				sound(this, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_GROWL2, VOL_BASEVOICE, ATTN_NORM);
		this.wait = time + 3 + random() * 3;
	}
	
	/*
	if(!this.frame)
	{
		if(random() < 0.5)
			this.frame = princess_run;
		else
			this.frame = princess_walk;
	}
	*/
	
	if(this.frame == princess_run)
		this.velocity += v_forward * autocvar_g_snafu_princess_speed_run * _delta;
		
	if(this.frame == princess_walk)
		this.velocity += v_forward * autocvar_g_snafu_princess_speed_walk * _delta;
}

void snafu_princess_create(entity own)
{
	Gai info = GAI_PRINCESS;
	entity zom = spawn();
	zom.gaid = info.gaid;

	setmodel(zom, info.m_model);    
	setsize(zom, info.m_mins, info.m_maxs);
	
	vector _where = own.origin;
	_where_x += random() * own.mins_x;
	_where_x += random() * own.maxs_x;
	_where_y += random() * own.mins_y;
	_where_y += random() * own.maxs_y;
	
	tracebox(_where + '0 0 64', info.m_mins, info.m_maxs, _where - '0 0 1' * max_shot_distance, MOVE_NORMAL, own);    
	setorigin(zom, trace_endpos);

	set_movetype(zom, MOVETYPE_WALK);
	zom.solid = SOLID_BBOX;
	zom.deadflag = DEAD_NO;
	zom.takedamage = DAMAGE_AIM;
	zom.damagedbycontents = true;
	IL_PUSH(g_damagedbycontents, zom);
	SetResourceExplicit(zom, RES_HEALTH, autocvar_g_snafu_princess_health);
	setthink(zom, snafu_princess_think);
	zom.nextthink = time;
	zom.event_damage = snafu_princess_damage;    
	zom.snafu_ai_flags = SAF_ZOMBIE;
	zom.damageforcescale = 3;
	zom.classname       = "zombie";
	zom.netname         = "Princess";
		
	++snafu_zombie_spawned;
	++snafu_zombie_alive;
}

#endif
