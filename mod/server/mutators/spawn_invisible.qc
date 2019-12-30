//FEATURE: Spawn Invisible mutator, to give spawning players a chance without making them completely invulnerable

AUTOCVAR(g_spawn_invisible, bool, false, "Spawn invisible instead of shielded");
AUTOCVAR(g_spawn_invisible_transparency, float, 0.05, "Opacity of players when spawning");
REGISTER_MUTATOR(si, autocvar_g_spawn_invisible);

.bool si_invis_check;

MUTATOR_HOOKFUNCTION(si, PlayerPowerups)
{
	entity player = M_ARGV(0, entity);

	if(time < player.spawnshieldtime)
	{
		if(!player.si_invis_check)
		{
			player.alpha = autocvar_g_spawn_invisible_transparency;
			player.exteriorweaponentity.alpha = autocvar_g_spawn_invisible_transparency;
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
