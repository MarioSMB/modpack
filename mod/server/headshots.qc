//FEATURE: Rifle can once again headshot players, yay

AUTOCVAR(sv_headshot, bool, true, _("Announce headshots and deal extra damage with the rifle"));
AUTOCVAR(sv_headshot_damage, float, 1.5, _("Damage multiplier if hitting the head with a rifle"));

bool Headshot(entity targ, entity ent, entity weapon_ent, vector hitloc, vector start, vector end)
{
	if(!autocvar_sv_headshot)
		return false;
	if(weapon_ent.m_weapon != WEP_RIFLE && weapon_ent.m_weapon != WEP_VAPORIZER && weapon_ent.m_weapon != WEP_VORTEX)
		return false;
	if(!IS_PLAYER(targ))
		return false;
	if(IS_DEAD(targ) || STAT(FROZEN, targ) || !targ.takedamage)
		return false;
	vector headmins, headmaxs, org;
	org = antilag_takebackorigin(targ, CS(targ), time - ANTILAG_LATENCY(ent));
	headmins = org + '0.6 0 0' * targ.mins_x + '0 0.6 0' * targ.mins_y + '0 0 1' * (1.3 * targ.view_ofs_z - 0.3 * targ.maxs_z);
	headmaxs = org + '0.6 0 0' * targ.maxs_x + '0 0.6 0' * targ.maxs_y + '0 0 1' * targ.maxs_z;

	return trace_hits_box(start, end, headmins, headmaxs);
}

MUTATOR_HOOKFUNCTION(mutator_mod, FireBullet_Hit)
{
	if(MUTATOR_RETURNVALUE) { return; }
	if(!autocvar_sv_headshot) { return; }

    entity player = M_ARGV(0, entity);
    entity targ = M_ARGV(1, entity);
    vector bullet_startpos = M_ARGV(2, vector);
    vector bullet_endpos = M_ARGV(3, vector);
    entity wep_ent = M_ARGV(5, entity);

	if(Headshot(targ, player, wep_ent, bullet_endpos, bullet_startpos, bullet_endpos))
	{
		M_ARGV(4, float) *= autocvar_sv_headshot_damage; // more damage
		Send_Notification(NOTIF_ONE, player, MSG_MULTI, HEADSHOT);
	}
}
