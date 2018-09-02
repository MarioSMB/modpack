//FEATURE: Spawn Invisible mutator, to give spawning players a chance without making them completely invulnerable

AUTOCVAR(g_spawn_invisible, bool, false, _("Spawn invisible instead of shielded"));
REGISTER_MUTATOR(si, autocvar_g_spawn_invisible);

.bool si_invis_check;

MUTATOR_HOOKFUNCTION(si, PlayerPowerups)
{
	entity player = M_ARGV(0, entity);

	if(time < player.spawnshieldtime)
	{
		if(!player.si_invis_check)
		{
			player.alpha = 0.1;
			player.exteriorweaponentity.alpha = 0.1;
			player.si_invis_check = true;
		}
	}
	else
	{
		if(player.si_invis_check)
		{
			player.alpha = default_player_alpha;
			player.exteriorweaponentity.alpha = default_weapon_alpha;
			player.si_invis_check = false;
		}
	}
}
