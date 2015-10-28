REGISTER_MUTATOR(headshots, cvar("sv_headshot"));

AUTOCVAR(sv_headshot, bool, true, _("Announce headshots and deal extra damage with the rifle"));
AUTOCVAR(sv_headshot_damage, float, 1.5, _("Damage multiplier if hitting the head with a rifle"));

bool Headshot(entity targ, entity ent, vector hitloc, vector start, vector end)
{
	if(!autocvar_sv_headshot)
		return false;
	if(ent.weapon != WEP_RIFLE.m_id && ent.weapon != WEP_VAPORIZER.m_id && ent.weapon != WEP_VORTEX.m_id)
		return false;
	if(!IS_PLAYER(targ))
		return false;
	if(targ.deadflag != DEAD_NO || targ.frozen || !targ.takedamage)
		return false;
	vector headmins, headmaxs, org;
	org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(ent));
	headmins = org + '0.6 0 0' * targ.mins_x + '0 0.6 0' * targ.mins_y + '0 0 1' * (1.3 * targ.view_ofs_z - 0.3 * targ.maxs_z);
	headmaxs = org + '0.6 0 0' * targ.maxs_x + '0 0.6 0' * targ.maxs_y + '0 0 1' * targ.maxs_z;

	return trace_hits_box(start, end, headmins, headmaxs);
}

MUTATOR_HOOKFUNCTION(headshots, FireBullet_Hit)
{
	if(MUTATOR_RETURNVALUE) { return false; }

	if(Headshot(bullet_hit, self, bullet_endpos, bullet_startpos, bullet_endpos))
	{
		frag_damage *= autocvar_sv_headshot_damage; // more damage
		Send_Notification(NOTIF_ONE, self, MSG_MULTI, MULTI_HEADSHOT);
	}
	return false;
}
