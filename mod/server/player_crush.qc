REGISTER_MUTATOR(pc, true);

AUTOCVAR(g_player_crush, bool, false, _("Allow crushing players by jumping on their head"));
AUTOCVAR(g_player_crush_simple, bool, true, _("Use simple height checking"));
AUTOCVAR(g_player_crush_damage, float, 200, "");
AUTOCVAR(g_player_crush_headheight, float, 0.9, "");
AUTOCVAR(g_player_crush_bounce, float, 300, _("Bounce height in advanced trace mode"));
AUTOCVAR(g_player_crush_bounce_jump, float, 600, _("Bounce height while holding jump in advanced trace mode"));

void pc_PlayerTouch(entity this)
{
	if(other == world)
		return;

	bool and_monster = IS_MONSTER(other);
	if(and_monster && !((Monsters_from(other.monsterid)).spawnflags & MON_FLAG_CRUSH))
		and_monster = false;

	if(!autocvar_g_player_crush && !and_monster)
		return;

	if(!IS_PLAYER(this))
		return;

	if(!IS_PLAYER(other) && !and_monster)
		return;

	if(IS_DEAD(this) || IS_DEAD(other))
		return;

	if(!this.iscreature || !other.iscreature)
		return;

	if(forbidWeaponUse(this))
		return;

	if(autocvar_g_player_crush_simple && IS_PLAYER(other))
	{
		vector vdir = normalize(other.origin - this.origin);

		if(vdir_z > autocvar_g_player_crush_headheight) // adjust this to set how sharp from above players need to hit the player to crush them. 
			Damage (this, other, other, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, this.origin, '0 0 0');
	}
	else
	{
		tracebox(this.origin, this.mins, this.maxs, this.origin - ('0 0 1' * (this.maxs_z + 5)), MOVE_NORMAL, this);

		if(trace_ent == other)
		{
			float mjumpheight = autocvar_g_player_crush_bounce;

			setorigin(this, this.origin + '0 0 2');

			if(PHYS_INPUT_BUTTON_JUMP(this))
			{
				mjumpheight = autocvar_g_player_crush_bounce_jump;
				this.flags &= ~FL_JUMPRELEASED;
			}

			this.flags &= ~FL_ONGROUND;

			this.velocity_z = mjumpheight;
			this.oldvelocity_z = this.velocity_z;

			animdecide_setaction(this, ANIMACTION_JUMP, true);

			Damage (other, this, this, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, other.origin, '0 0 0');
		}
	}
}

MUTATOR_HOOKFUNCTION(pc, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	settouch(player, pc_PlayerTouch);
}
