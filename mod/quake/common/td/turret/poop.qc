#include "poop.qh"

// =======
//  POTTY
// =======

#ifdef SVQC
entity Poop_PooSpit(entity this);

METHOD(PoopPotty, tr_precache, void(PoopPotty thistur))
{
	precache_model("progs/s_mayo.mdl");

	precache_sound("blob/land1.wav");

	precache_sound("turrets/potty_poop1.wav");
	precache_sound("turrets/potty_poop2.wav");
	precache_sound("turrets/potty_poop3.wav");
	precache_sound("turrets/potty_poop4.wav");
	precache_sound("turrets/potty_poop5.wav");
	precache_sound("turrets/potty_poop6.wav");
}
METHOD(PoopPotty, tr_think, void(PoopPotty this, entity actor))
{
	// make sure it matches drawn values!
	float myrange = this.target_range; // doesn't get extended by levels
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	if(actor.enemy)
	{
		vector myorg = CENTER_OR_VIEWOFS(actor);
		vector targ_org = (actor.enemy.absmin + actor.enemy.absmax) * 0.5;
		bool isvisible = visible(actor, actor.enemy);
		bool isinfront = turret_infront(actor, actor.enemy, actor.angles, maxpitch, maxrot);
		if(isvisible || isinfront)
			actor.search_time = time + 1;
		if(actor.enemy.health < 1 || actor.enemy.exptime != 0 || time > actor.search_time || vdist(myorg - targ_org, >, myrange * 1.5))
		{
			actor.enemy = NULL;
			return; // won't find a new target this frame
		}

		if(time > actor.attack_finished && isinfront && isvisible)
		{
			actor.attack_finished = time + max(0.03, (0.7 / turret_getpower(actor.tur_level, 0.25)));
			actor.clientframe = TANIM_SHOOT;

			float r = floor(random() * 6);
			string thesound = "";
			switch(r)
			{
				default:
				case 0: thesound = "turrets/potty_poop1.wav"; break;
				case 1: thesound = "turrets/potty_poop2.wav"; break;
				case 2: thesound = "turrets/potty_poop3.wav"; break;
				case 3: thesound = "turrets/potty_poop4.wav"; break;
				case 4: thesound = "turrets/potty_poop5.wav"; break;
				case 5: thesound = "turrets/potty_poop6.wav"; break;
			}

			_sound(actor, CH_WEAPON_SINGLE, thesound, 1, ATTN_NORM);

			vector org = myorg;
			vector dir = normalize(targ_org - org);
			entity newmis = Poop_PooSpit(actor);
			newmis.velocity = dir * 400;
			newmis.velocity_z += 100;
			setorigin(newmis, org);
			newmis.dmg = this.tur_dmg * turret_getpower(actor.tur_level, this.tur_dmgscale);
		}
	}
	
	if(!actor.enemy && time >= actor.idle_finished)
	{
		actor.idle_finished = time + 0.5;
		actor.enemy = turret_findtarget(actor, 0.3, 0.3, myrange);
	}
}
#endif // SVQC
#ifdef CSQC
METHOD(PoopPotty, tr_precache, void(PoopPotty thistur))
{
	precache_sound("turrets/potty_splash.wav");
}
METHOD(PoopPotty, tr_drawselected, void(PoopPotty this, entity actor))
{
	float myrange = this.target_range; // doesn't get extended by levels
	float maxpitch = this.aim_maxpitch * turret_getpower(actor.tur_level, 0.05);
	float maxrot = this.aim_maxrot * turret_getpower(actor.tur_level, 0.05);
	makevectors(actor.angles);
	vector org = actor.origin + ((actor.mins + actor.maxs) * 0.5);

	Draw_Cone(org, v_forward, myrange, maxpitch, maxrot);

	// TODO: cone?
	//Draw_CylindricLine(org, org + v_forward * myrange, 6, "particles/laserbeam", 0.25, -time * 3, '1 0.25 0', 1, DRAWFLAG_NORMAL, view_origin);
}
.float last_stink;
.float last_splash;
METHOD(PoopPotty, tr_think, void(PoopPotty this, entity actor))
{
	if(time >= actor.last_splash)
	{
		actor.last_splash = time + 10 + (random() * 10);
		_sound(actor, CH_WEAPON_SINGLE, "turrets/potty_splash.wav", 1, ATTN_NORM);
	}

	if(time > actor.last_stink)
	{
		vector extra_size = '16 16 16';
		actor.last_stink = time + 2 + (random() * 2);
		if(!SpawnParticles_list_full(strcat("cl_particle_", EFFECT_POOP_STINK.eent_eff_name), actor.absmin - extra_size, actor.absmax + extra_size, actor.velocity, actor.velocity, 3, false, 0))
			boxparticles(particleeffectnum(EFFECT_POOP_STINK), actor, actor.absmin - extra_size, actor.absmax + extra_size, actor.velocity, actor.velocity, 3, 0);
	}
}
METHOD(PoopPotty, tr_setup, void(PoopPotty this, entity actor))
{
	actor.anim_idle = '0 0 0';
	actor.anim_shoot = '61 66 1';

	actor.last_splash = time + 5 + (random() * 5);
}
#endif // CSQC
