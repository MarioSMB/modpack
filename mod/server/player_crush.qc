REGISTER_MUTATOR(pc, true);

AUTOCVAR(g_player_crush, bool, false, _("Allow crushing players by jumping on their head"));
AUTOCVAR(g_player_crush_simple, bool, true, _("Use simple height checking"));
AUTOCVAR(g_player_crush_damage, float, 200, "");
AUTOCVAR(g_player_crush_headheight, float, 0.9, "");
AUTOCVAR(g_player_crush_bounce, float, 300, _("Bounce height in advanced trace mode"));
AUTOCVAR(g_player_crush_bounce_jump, float, 600, _("Bounce height while holding jump in advanced trace mode"));

void pc_PlayerTouch()
{
	if(other == world)
		return;

	bool and_monster = IS_MONSTER(other);
	if(and_monster && !((Monsters_from(other.monsterid)).spawnflags & MON_FLAG_CRUSH))
		and_monster = false;

	if(!autocvar_g_player_crush && !and_monster)
		return;

	if(!IS_PLAYER(self))
		return;

	if(!IS_PLAYER(other) && !and_monster)
		return;

	if(IS_DEAD(self) || IS_DEAD(other))
		return;

	if(!self.iscreature || !other.iscreature)
		return;

	if(forbidWeaponUse(self))
		return;

	if(autocvar_g_player_crush_simple && IS_PLAYER(other))
	{
		vector vdir = normalize(other.origin - self.origin);

		if(vdir_z > autocvar_g_player_crush_headheight) // adjust this to set how sharp from above players need to hit the player to crush them. 
			Damage (self, other, other, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, self.origin, '0 0 0');
	}
	else
	{
		tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * (self.maxs_z + 5)), MOVE_NORMAL, self);

		if(trace_ent == other)
		{
			float mjumpheight = autocvar_g_player_crush_bounce;

			setorigin(self, self.origin + '0 0 2');

			if(PHYS_INPUT_BUTTON_JUMP(self))
			{
				mjumpheight = autocvar_g_player_crush_bounce_jump;
				self.flags &= ~FL_JUMPRELEASED;
			}

			self.flags &= ~FL_ONGROUND;

			self.velocity_z = mjumpheight;
			self.oldvelocity_z = self.velocity_z;

			animdecide_setaction(self, ANIMACTION_JUMP, true);

			Damage (other, self, self, autocvar_g_player_crush_damage, DEATH_VH_CRUSH.m_id, other.origin, '0 0 0');
		}
	}
}

MUTATOR_HOOKFUNCTION(pc, PlayerSpawn)
{
	self.touch = pc_PlayerTouch;
	return false;
}
