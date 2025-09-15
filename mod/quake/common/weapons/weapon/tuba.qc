#include "tuba.qh"

#ifdef SVQC
PRECACHE(Tuba)
{
	precache_model("progs/v_tuba.mdl");
	precache_model("progs/g_tuba.mdl");
}

.float tuba_smoketime;

void tubasound_remove(entity this)
{
	sound(this, CH_TUBA_SINGLE, SND_Null, 0, 0);
	delete(this);
}

void tuba_note_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float mydmg = 30;
	float damg = mydmg + random() * (mydmg * 0.2);
	
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		if(toucher.resist_rockets != 0)
		{
			damg = Resist_Damage(toucher, IT_ROCKETS, damg);
			Resist_Rockets(toucher, this.origin);
		}
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, mydmg * 1.2, this.projectiledeathtype, toucher);

	//sound(this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	//this.origin = this.origin - 8 * normalize(this.velocity);
	setorigin(this, findbetterlocation(this.origin, 8));

	BecomeCartoonExplosion(this);
}

vector tuba_calc_arc(vector org, vector tgt, float ht)
{
    float grav, sdist, zdist, vs, vz, jumpheight;
    vector sdir;

    grav  = autocvar_sv_gravity;
    zdist = tgt_z - org_z;
    sdist = vlen(tgt - org - zdist * '0 0 1');
    sdir  = normalize(tgt - org - zdist * '0 0 1');

    // how high do we need to go?
    jumpheight = fabs(ht);
    if(zdist > 0)
        jumpheight = jumpheight + zdist;

    // push so high...
    vz = sqrt(2 * grav * jumpheight); // NOTE: sqrt(positive)!

    // we start with downwards velocity only if it's a downjump and the jump apex should be outside the jump!
    if(ht < 0)
        if(zdist < 0)
            vz = -vz;

    vector solution;
    solution = solve_quadratic(0.5 * grav, -vz, zdist); // equation "z(ti) = zdist"
    // ALWAYS solvable because jumpheight >= zdist
    if(!solution_z)
        solution_y = solution_x; // just in case it is not solvable due to roundoff errors, assume two equal solutions at their center (this is mainly for the usual case with ht == 0)
    if(zdist == 0)
        solution_x = solution_y; // solution_x is 0 in this case, so don't use it, but rather use solution_y (which will be sqrt(0.5 * jumpheight / grav), actually)

    float tuba_calcarc_flighttime = 1;
    if(zdist < 0)
    {
        // down-jump
        if(ht < 0)
        {
            // almost straight line type
            // jump apex is before the jump
            // we must take the larger one
            tuba_calcarc_flighttime = solution_y;
        }
        else
        {
            // regular jump
            // jump apex is during the jump
            // we must take the larger one too
            tuba_calcarc_flighttime = solution_y;
        }
    }
    else
    {
        // up-jump
        if(ht < 0)
        {
            // almost straight line type
            // jump apex is after the jump
            // we must take the smaller one
            tuba_calcarc_flighttime = solution_x;
        }
        else
        {
            // regular jump
            // jump apex is during the jump
            // we must take the larger one
            tuba_calcarc_flighttime = solution_y;
        }
    }
    vs = sdist / tuba_calcarc_flighttime;

    // finally calculate the velocity
    return sdir * vs + '0 0 1' * vz;
}

vector tuba_calc_velocity(entity actor, entity note)
{
	vector oldvel = v_forward * 200 + v_up * 600;
	RandomSelection_Init();
	FOREACH_ENTITY_RADIUS(actor.origin, 1000, it.health > 0 && (normalize(it.origin - actor.origin) * v_forward) > 0.1 && Damage_ValidTarget(it, actor),
	{
		if(!checkpvs(actor.origin + actor.view_ofs, it))
			continue;
		RandomSelection_AddEnt(it, 1, 1);
	});

	entity targ = RandomSelection_chosen_ent;
	if(!targ)
		return oldvel;

	vector tpos1 = targ.origin;
	vector v = note.origin;

	traceline(v, v + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h1 = 0.75 * vlen(v - trace_endpos);

	traceline(v, tpos1 + '0 0 1' * 65535, MOVE_WORLDONLY, actor);
	float h2 = 0.75 * vlen(tpos1 - v);

	return tuba_calc_arc(v, tpos1, ((h1 < h2) ? h1 : h2));
}

void W_FireTuba(entity this, .entity weaponentity)
{
	this.punchangle_x = -2;
	W_TakeMana(this, 8);

	T_RadiusDamage(this, this, 110, WEP_TUBA.m_id, this);

	//vector org = gettaginfo(this.(weaponentity), 0);
	vector org = this.origin + this.view_ofs;
	vector offset = org + v_up * 10 + v_right * 5 + v_forward * 14;
	if(time > this.(weaponentity).tuba_smoketime)
	{
		// FIXME gettaginfo(this.(weaponentity), 0) doesn't return the real origin of the weapon
		Send_Effect(EFFECT_SMOKE_RING, offset, v_up * 100, 1);
		this.(weaponentity).tuba_smoketime = time + 0.25;
	}

	// copied from piano
	entity musicnote = spawn();
	musicnote.flags = FL_PROJECTILE;
	musicnote.owner = this;
	set_movetype(musicnote, MOVETYPE_TOSS);
	//musicnote.solid = SOLID_BBOX;
	musicnote.solid = SOLID_CORPSE;
	musicnote.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	musicnote.classname = "tubanote";
	musicnote.projectiledeathtype = WEP_TUBA.m_id;
	musicnote.clipgroup = this.clipgroup;
	musicnote.effects = EF_FULLBRIGHT;

	musicnote.angles = vectoangles(musicnote.velocity);
	settouch(musicnote, MusicNoteTouch);

	musicnote.nextthink = time + 2.5; // Remove/Explode Time
	//musicnote.think = SUB_Remove; 
	setthink(musicnote, BecomeCartoonExplosion);
	_setmodel(musicnote, "progs/piano_musicnote_yellow.mdl");
	setsize(musicnote, '-3 -3 -3', '3 3 3');
	musicnote.avelocity = '0 90 0'; // Roll

	tracebox(this.origin, musicnote.mins, musicnote.maxs, offset, MOVE_NORMAL, this);

	setorigin(musicnote, trace_endpos);
	settouch(musicnote, tuba_note_touch);

	musicnote.velocity = tuba_calc_velocity(this, musicnote);

	float r = W_Music_PitchFromAngles(this.v_angle_x, max(0.5, random() * 3));
	sound7(this, CH_WEAPON_SINGLE, SND(TUBA_FIRE), 1, ATTN_NORM, r, 0);
}

METHOD(Tuba, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
	if(fire & 1)
	if(!(time < ATTACK_FINISHED(actor, weaponentity)))
	if(thiswep.wr_checkammo1(thiswep, actor, weaponentity) && STAT(MANA, actor) >= 8)
	{
		if(IS_PLAYER(actor))
			player_shot1(actor);
		wep_generic_shot1(actor.(weaponentity));
		W_FireTuba(actor, weaponentity);
		weapon_prepareattack(thiswep, actor, weaponentity, 0.5);
	}
}
METHOD(Tuba, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
	return true; // doesn't use ammo in the traditional sense
}
METHOD(Tuba, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Tuba, wr_killmessage, Notification(entity thiswep))
{
	return WEAPON_FRAG;
}
#endif
