#include "duke.qh"

#ifdef SVQC
void duke_playersound(entity this, int chan, string sample, float atten)
{
	if(this.duke_taunt_timer > time)
		return;
	if(this.waterlevel > 2)
		return;
	this.duke_taunt_timer = time + 6;
	player_sound(this, chan, sample, atten);
}

METHOD(Duke, m_activate, void(Duke this, entity actor))
{
	string s = "";
	float r = random() * 9;
	if(r < 1)
		s = "letsrk.wav";
	else if(r < 2)
		s = "wherami.wav";
	else if(r < 3)
		s = "hell90s.wav";
	else if(r < 4)
		s = "romero.wav";
	else if(r < 5)
		s = "betduke.wav";
	else if(r < 6)
		s = "chew.wav";
	else if(r < 7)
		s = "blowshitup.wav";
	else if(r < 8)
		s = "cokrok.wav";
	else
		s = "wansom.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_playerspawn, void(Duke this, entity actor))
{
	string s = "";
	float r = random() * 8;
	if(r < 1)
		s = "cry.wav";
	else if(r < 2)
		s = "kicka.wav";
	else if(r < 3)
		s = "pissin.wav";
	else if(r < 4)
		s = "rip.wav";
	else if(r < 5)
		s = "smackdb.wav";
	else if(r < 6)
		s = "yohoho2.wav";
	else if(r < 7)
		s = "nothink.wav";
	else
		s = "mthrfkr.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_killed, void(Duke this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	string s = "";
	float r = random();

	if(targ == attacker)
	{
		if(r < 0.333)
			s = "myself.wav";
		else if(r < 0.666)
			s = "realthing.wav";
		else
			s = "kickmyass.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
		return;
	}

	if(deathtype == WEP_AXE.m_id)
	{
		if(r < 0.25)
			s = "footface.wav";
		else if(r < 0.5)
			s = "stomped.wav";
		else if(r < 0.75)
			s = "bug.wav";
		else
			s = "bloodboot.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
	}
	else
	{
		r = random() * 30;
		if(r < 1)
			s = "aisle.wav";
		else if(r < 2)
			s = "amess.wav";
		else if(r < 3)
			s = "bitchn.wav";
		else if(r < 4)
			s = "blowit.wav";
		else if(r < 5)
			s = "bookem.wav";
		else if(r < 6)
			s = "cool.wav";
		else if(r < 7)
			s = "damn.wav";
		else if(r < 8)
			s = "getsom.wav";
		else if(r < 9)
			s = "gmeovr.wav";
		else if(r < 10)
			s = "gothrt.wav";
		else if(r < 11)
			s = "groovy.wav";
		else if(r < 12)
			s = "hail.wav";
		else if(r < 13)
			s = "holysh.wav";
		else if(r < 14)
			s = "imgood.wav";
		else if(r < 15)
			s = "inhell.wav";
		else if(r < 16)
			s = "letsrk.wav";
		else if(r < 17)
			s = "lookin.wav";
		else if(r < 18)
			s = "meat.wav";
		else if(r < 19)
			s = "name.wav";
		else if(r < 20)
			s = "nobody.wav";
		else if(r < 21)
			s = "piece.wav";
		else if(r < 22)
			s = "slacker.wav";
		else if(r < 23)
			s = "sukitdn.wav";
		else if(r < 24)
			s = "rokrol.wav";
		else if(r < 25)
			s = "betduke2.wav";
		else if(r < 26)
			s = "huckleberry.wav";
		else if(r < 27)
			s = "itsgood.wav";
		else if(r < 28)
			s = "ripieces.wav";
		else if(r < 29)
			s = "oneking.wav";
		else
			s = "fragged.wav";
		duke_playersound(attacker, CH_VOICE, s, ATTN_NORM);
	}
}

METHOD(Duke, m_pickup_weapon, void(Duke this, entity actor, entity item))
{
	Weapon wep = REGISTRY_GET(Weapons, item.weapon);
	string s = "";
	float r = random();

	if(wep.ammo_type == IT_SHELLS || wep.ammo_type == IT_NAILS)
	{
		if(r < 0.25)
			s = "wansom.wav";
		else if(r < 0.5)
			s = "cool.wav";
		else if(r < 0.75)
			s = "groovy.wav";
		else
			s = "getsom.wav";
		duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
	}
	else
	{
		if(r < 0.333)
			s = "hehehe.wav";
		else if(r < 0.666)
			s = "letsrk.wav";
		else
			s = "timetokill.wav";
		duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
	}
}

METHOD(Duke, m_pickup_powerup, void(Duke this, entity actor, entity item))
{
	string s = "";
	float r = random();

	if(r < 0.333)
		s = "timetokill.wav";
	else if(r < 0.666)
		s = "bos.wav";
	else
		s = "groovy.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_pickup_key, void(Duke this, entity actor, entity item))
{
	string s = "";
	float r = random();

	if(r < 0.333)
		s = "stormgates.wav";
	else if(r < 0.666)
		s = "lookin.wav";
	else
		s = "groovy.wav";
	duke_playersound(actor, CH_VOICE, s, ATTN_NORM);
}

METHOD(Duke, m_pickup_sigil, void(Duke this, entity actor, entity item))
{
	duke_playersound(actor, CH_VOICE, "imgood.wav", ATTN_NORM);
}
#endif

#if 0
METHOD(Duke, m_physics, bool(Duke this, entity actor, float dt))
{
#ifdef CSQC
	if(viewmodels[0].activeweapon != WEP_AXE)
		return false;
#endif
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon != WEP_AXE)
		return false;
#endif
	if(actor.waterlevel > 0)
		return false;
	if(IS_ONGROUND(actor))
	{
		if(PHYS_INPUT_BUTTON_JUMP(actor))
			actor.velocity_z += 540;
		else
			actor.velocity_z += 270;
	#ifdef SVQC
		player_sound(actor, CH_VOICE, "pogo.wav", ATTN_NORM);
	#endif
		UNSET_ONGROUND(actor);
	}
	else
	{
		makevectors(PHYS_WORLD_ANGLES(actor));
		vector vel = vec2(actor.velocity);
		float spd = vlen(vel);
		if(spd < 320)
			spd += 5;
		vel = v_forward * spd;
		actor.velocity_x = vel.x;
		actor.velocity_y = vel.y;
	}
	// fix for waterjump
	if(time > actor.teleport_time || actor.waterlevel == 0)
	{
		actor.flags &= ~FL_WATERJUMP;
		actor.teleport_time = 0;
	}
	return true;
}
#endif
