AUTOCVAR(g_rocketcam, bool, false, _("Enable rocket cam (view follows the fired rocket), doesn't work in jailbreak"));

REGISTER_MUTATOR(rocketcam, autocvar_g_rocketcam && !g_jailbreak);

MUTATOR_HOOKFUNCTION(rocketcam, EditProjectile)
{
	if(!autocvar_g_rocketcam)
		return;

	entity player = M_ARGV(0, entity);
	entity proj = M_ARGV(1, entity);

	if(proj.classname != "rocket" || !IS_REAL_CLIENT(player)) // || player.clientcamera.classname == "rocket") // only view the controlled rocket
		return;

	player.clientcamera = proj;
}

MUTATOR_HOOKFUNCTION(rocketcam, PlayerPreThink)
{
	if(!autocvar_g_rocketcam)
		return;

	entity player = M_ARGV(0, entity);

	if(!IS_REAL_CLIENT(player))
		return; // nope

	if(player.clientcamera.classname != "rocket")
		return;

	if(wasfreed(player.clientcamera))
	{
		player.clientcamera = player; // we gotta reset it so as to not leave the player hanging (rocket explosion doesn't have a hook)
		return;
	}
	entity rocket = player.clientcamera;
	.entity weaponentity = rocket.weaponentity_fld;
	if(player.(weaponentity) && player.(weaponentity).rl_release)
		player.clientcamera = player;
}
