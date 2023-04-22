#ifdef SVQC

/*QUAKED ambient_suck_wind(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_suck_wind)
{
	precache_sound("ambience/suck1.wav");
	ambientsound(this.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
}

/*QUAKED ambient_drone(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drone)
{
	precache_sound("ambience/drone6.wav");
	ambientsound(this.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
}

/*QUAKED ambient_flouro_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_flouro_buzz)
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(this.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_drip(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_drip)
{
	precache_sound("ambience/drip1.wav");
	ambientsound(this.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_comp_hum(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_comp_hum)
{
	precache_sound("ambience/comp1.wav");
	ambientsound(this.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
}
/*QUAKED ambient_thunder(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_thunder)
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(this.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_light_buzz(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_light_buzz)
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(this.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp1(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp1)
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(this.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
}
/*QUAKED ambient_swamp2(0.3 0.1 0.6)(-10 -10 -8)(10 10 8)
*/
spawnfunc(ambient_swamp2)
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(this.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
}

#endif
