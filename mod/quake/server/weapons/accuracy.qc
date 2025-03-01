#include "accuracy.qh"

int accuracy_byte(float n, float d)
{
	if (n <= 0) return 0;
	if (n > d) return 255;
	return 1 + rint(n * 100.0 / d);
}

#if 0
bool accuracy_send(entity this, entity to, int sf)
{
	WriteHeader(MSG_ENTITY, ENT_CLIENT_ACCURACY);

	entity a = this.owner;
	if (IS_SPEC(a)) a = a.enemy;
	a = CS(a).accuracy;

	if (to != a.owner)
		if (!autocvar_sv_accuracy_data_share && !CS_CVAR(a.owner).cvar_cl_accuracy_data_share)
			sf = 0;
	// note: zero sendflags can never be sent... so we can use that to say that we send no accuracy!
	WriteInt24_t(MSG_ENTITY, sf);
	if (sf == 0) return true;
	// note: we know that client and server agree about SendFlags...
	int f = 1;
	for (int w = 0; w <= WEP_LAST - WEP_FIRST; ++w) {
		if (sf & f) WriteByte(MSG_ENTITY, accuracy_byte(a.accuracy_hit[w], a.accuracy_fired[w]));
		f = (f == 0x800000) ? 1 : f * 2;
	}
	return true;
}
#endif

// init/free
void accuracy_init(entity e)
{
	entity a = e.accuracy = new_pure(accuracy);
	a.owner = e;
	a.drawonlytoclient = e;
	//Net_LinkEntity(a, false, 0, accuracy_send);
}

void accuracy_free(entity e)
{
	delete(e.accuracy);
}

// update accuracy stats
.float hit_time;
.float fired_time;

void accuracy_add(entity this, Weapon w, float fired, float hit)
{
	entity a = this.accuracy;
	if (!a) return;
	if (!hit && !fired) return;
	if (w == WEP_Null) return;
	int wepid = w.m_id;
	wepid -= WEP_FIRST;
	//int b = accuracy_byte(a.accuracy_hit[wepid], a.accuracy_fired[wepid]);
	if (hit)    a.accuracy_hit  [wepid] += hit;
	if (fired)  a.accuracy_fired[wepid] += fired;

    if (hit && a.hit_time != time) { // only run this once per frame
        a.accuracy_cnt_hit[wepid] += 1;
        a.hit_time = time;
    }

    if (fired && a.fired_time != time) { // only run this once per frame
        a.accuracy_cnt_fired[wepid] += 1;
        a.fired_time = time;
    }
}

bool accuracy_isgooddamage(entity attacker, entity targ)
{
	if (gameover || intermission_running) return false;

	// damage to dead/frozen players is good only if it happens in the frame they get killed / frozen
	// so that stats for weapons that shoot multiple projectiles per shot are properly counted
	if (targ.health <= 0 && time > targ.death_time) return false;
	if (coop && IS_PLAYER(attacker) && IS_PLAYER(targ)) return false;

	// we allow accuracy against monsters
	if (!IS_MONSTER(targ) && !IS_CLIENT(attacker)) return false;

	return true;
}

bool accuracy_canbegooddamage(entity attacker)
{
	return IS_CLIENT(attacker);
}
