// Global list of sounds
// TODO: remove uses of _sound

SOUND(JETPACK_FLY, "misc/jetpack_fly");

SOUND(TELE1, "misc/r_tele1");
SOUND(TELE2, "misc/r_tele2");
SOUND(TELE3, "misc/r_tele3");
SOUND(TELE4, "misc/r_tele4");
SOUND(TELE5, "misc/r_tele5");
Sound SND_TELE_RANDOM() {
    return REGISTRY_GET(Sounds, SND_TELE1.m_id + floor(prandom() * 5));
}
#ifdef SVQC
PRECACHE(TELE)
{
    precache_sound("misc/r_tele1.wav");
    precache_sound("misc/r_tele2.wav");
    precache_sound("misc/r_tele3.wav");
    precache_sound("misc/r_tele4.wav");
    precache_sound("misc/r_tele5.wav");
}
#endif

SOUND(ROCKET_EXPLOSION, "weapons/r_exp3");

SOUND(TALK2, "misc/talk2");
#ifdef SVQC
PRECACHE(TALK2)
{
    precache_sound("misc/talk2.wav");
}
#endif

SOUND(RUNE_CAST, "weapons/rune_cast");

SOUND(TUBA_FIRE, "weapons/tuba_fire");

SOUND(DOOT_FIRE, "weapons/fastdoot");

SOUND(MECHBOSS_HIT, "destroyer/hit");

SOUND(LASER_RICOCHET, "hipweap/laserric");

SOUND(CHEER, "misc/cheer");
#ifdef SVQC
PRECACHE(CHEER)
{
    precache_sound("misc/cheer.wav");
}
#endif

SOUND(BOMB_FUSE, "kirby/bomb_fuse");

SOUND(PLASMA_FLIGHT, "plasma/flight");

SOUND(SWARM_FLIGHT, "turrets/swarmer_swarm");

SOUND(PLAYER_UDEATH, "player/udeath");
SOUND(PLAYER_GIB, "player/gib");
SOUND(PLAYER_TELEDEATH, "player/teledth1");

SOUND(PLAYER_LAND, "player/land");
SOUND(PLAYER_FALL, "player/land2");
SOUND(PLAYER_WATERJUMP, "player/h2ojump");
SOUND(PLAYER_GASP1, "player/gasp1");
SOUND(PLAYER_GASP2, "player/gasp2");
SOUND(PLAYER_JUMP, "player/plyrjmp8");
SOUND(PLAYER_WATERDEATH, "player/h2odeath");
SOUND(PLAYER_AXEHIT, "player/axhit1");

SOUND(PLAYER_PAIN1, "player/pain1");
SOUND(PLAYER_PAIN2, "player/pain2");
SOUND(PLAYER_PAIN3, "player/pain3");
SOUND(PLAYER_PAIN4, "player/pain4");
SOUND(PLAYER_PAIN5, "player/pain5");
SOUND(PLAYER_PAIN6, "player/pain6");
Sound SND_PLAYER_PAIN_RANDOM() {
    return REGISTRY_GET(Sounds, SND_PLAYER_PAIN1.m_id + rint(random() * 5));
}

SOUND(PLAYER_DEATH1, "player/death1");
SOUND(PLAYER_DEATH2, "player/death2");
SOUND(PLAYER_DEATH3, "player/death3");
SOUND(PLAYER_DEATH4, "player/death4");
SOUND(PLAYER_DEATH5, "player/death5");
Sound SND_PLAYER_DEATH_RANDOM() {
    return REGISTRY_GET(Sounds, SND_PLAYER_DEATH1.m_id + rint(random() * 4));
}

SOUND(PLAYER_DROWN1, "player/drown1");
SOUND(PLAYER_DROWN2, "player/drown2");
Sound SND_PLAYER_DROWN_RANDOM() {
    return (random() > 0.5) ? SND_PLAYER_DROWN1 : SND_PLAYER_DROWN2;
}

SOUND(PLAYER_BURN1, "player/lburn1");
SOUND(PLAYER_BURN2, "player/lburn2");
Sound SND_PLAYER_BURN_RANDOM() {
    return (random() > 0.5) ? SND_PLAYER_BURN1 : SND_PLAYER_BURN2;
}

SOUND(SKATE_LAND, "player/skatelnd");
SOUND(SKATE_JUMP, "player/plyrjmp8");
SOUND(SKATE_WATERJUMP, "player/h2ojump");
