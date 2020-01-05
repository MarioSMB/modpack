// main file for the impel mission pack

PRECACHE(Impel)
{
	if(!MP_IMPEL)
		return;

	precache_sound2("zombie/z_shot1.wav");

	precache_model2("progs/v_implr.mdl");

	precache_model2("progs/impaler.mdl");
	precache_model2("progs/impwall.mdl");
	precache_model2("progs/impstuck.mdl");
	precache_model2("progs/impdef.mdl");

	precache_model2("progs/v_light2.mdl");
	precache_model2("progs/firesprk.mdl");
	precache_model2("progs/flameo.mdl");
	precache_model2("progs/flameo2.mdl");
	precache_model2("progs/v_srock.mdl");
	precache_model2("progs/bone.mdl");
	precache_model2("progs/bone2.mdl");
	precache_model2("progs/rawbone.mdl");
	precache_model2("progs/grenbone.mdl");
	precache_model2("progs/rawbone2.mdl");
	precache_model2("progs/nbomb.mdl");
	precache_model2("progs/xtragib.mdl");
	precache_model2("progs/bldfall.mdl");
	precache_model2("progs/null.mdl");
	precache_model2("progs/pulse.mdl");
	precache_model2("progs/blpulse.mdl");
	precache_model2("progs/wlpulse.mdl");
	precache_sound2("ambience/thunder1.wav");
	precache_sound2("ambience/thunder2.wav");
	precache_sound2("ambience/rain1.wav");
	precache_sound2("ambience/pixels.wav");

	if(cvar("nomonsters") & 1)
		angry_monsters = true;
	if(cvar("nomonsters") & 2)
		corpse_removal = true;

	// W_Precache
	precache_sound2("items/inv1.wav");
	precache_sound2("items/inv2.wav");
	precache_sound2("items/inv3.wav");
	precache_sound2("items/protect.wav");
	precache_sound2("items/protect2.wav");
	precache_sound2("items/protect3.wav");
	precache_sound2("items/damage.wav");
	precache_sound2("items/damage2.wav");
	precache_sound2("items/damage3.wav");
	precache_sound2("items/suit.wav");
	precache_sound2("items/suit2.wav");
	precache_sound2("monsters/juggers/jbent.wav");
	precache_sound2("enviro/physics/axecut1.wav");
	precache_sound2("enviro/physics/axecut2.wav");
	precache_sound2("enviro/physics/trcut.wav");
	precache_sound2("enviro/physics/axemet1.wav");
	precache_sound2("enviro/physics/axemet2.wav");
	precache_sound2("enviro/physics/axemet3.wav");
	precache_sound2("weapons/light2/lgstart1.wav");
	precache_sound2("weapons/light2/lgstart2.wav");
	precache_sound2("weapons/light2/lgstart3.wav");
	precache_sound2("weapons/light2/lghit.wav");
	precache_sound2("weapons/light2/lghit2.wav");
	precache_sound2("weapons/light2/lgdis1.wav");
	precache_sound2("weapons/light2/lgdis2.wav");
	precache_sound2("weapons/light2/lgdis3.wav");
	precache_sound2("weapons/lstart.wav");
	precache_sound2("weapons/lhit.wav");
	precache_sound2("weapons/light2/lhit2.wav");
	precache_sound2("items/inv1.wav");
	precache_sound2("misc/power.wav");
	precache_sound2("weapons/pulse/install.wav");
	precache_sound2("weapons/pulse/pulshot1.wav");
	precache_sound2("weapons/pulse/pulshot2.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enviro/pinhead/pinfire.wav");
	precache_sound2("enviro/pinhead/pinsuck.wav");
	precache_sound2("enviro/physics/bonexpl.wav");
	precache_sound2("enviro/physics/wallexpl.wav");
	precache_sound2("weapons/pkup.wav");
	precache_sound2("weapons/lock4.wav");
	precache_sound2("weapons/impaler/shaft1.wav");
	precache_sound2("weapons/impaler/shaft2.wav");
	precache_sound2("weapons/impaler/shaft3.wav");
	precache_sound2("weapons/impaler/impload.wav");
	precache_sound2("weapons/impaler/impwall.wav");
	precache_sound2("weapons/impaler/impdef1.wav");
	precache_sound2("weapons/impaler/impdef2.wav");
	precache_sound2("weapons/impaler/impdef3.wav");
	precache_sound2("weapons/impaler/impale.wav");
	precache_sound2("weapons/impaler/mimpale.wav");
	precache_sound2("weapons/impaler/pimpale.wav");
	precache_sound2("weapons/impaler/impfire.wav");
	precache_sound2("weapons/impaler/impex.wav");
	precache_sound2("weapons/field/genactiv.wav");
	precache_sound2("weapons/field/genstop.wav");
	precache_sound2("weapons/field/genpulse.wav");
	precache_sound2("weapons/field/genlev.wav");
	precache_sound2("weapons/field/genhit1.wav");
	precache_sound2("weapons/field/genhit2.wav");
	precache_sound2("weapons/field/genhit3.wav");
	precache_sound2("player/walk1.wav");
	precache_sound2("player/walk2.wav");
	precache_sound2("player/walk3.wav");
	precache_sound2("player/walk4.wav");
	precache_sound2("player/walk5.wav");
	precache_sound2("player/walk6.wav");
	precache_sound2("player/walkh2o1.wav");
	precache_sound2("player/walkh2o2.wav");
	precache_sound2("misc/h2ohit1.wav");
	precache_sound2("misc/trigger1.wav");
	precache_sound2("monsters/spider/sactiv.wav");
}
