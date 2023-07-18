// Global list of sounds
// TODO: remove uses of _sound

SOUND(TELE1, "misc/r_tele1");
SOUND(TELE2, "misc/r_tele2");
SOUND(TELE3, "misc/r_tele3");
SOUND(TELE4, "misc/r_tele4");
SOUND(TELE5, "misc/r_tele5");
Sound SND_TELE_RANDOM() {
    return REGISTRY_GET(Sounds, SND_TELE1.m_id + floor(prandom() * 5));
}

SOUND(ROCKET_EXPLOSION, "weapons/r_exp3");

SOUND(TALK2, "misc/talk2");

SOUND(RUNE_CAST, "weapons/rune_cast");

SOUND(TUBA1, "weapons/tuba_loopnote0");
SOUND(TUBA2, "weapons/tuba_loopnote6");
SOUND(TUBA3, "weapons/tuba_loopnote-6");
SOUND(TUBA4, "weapons/tuba_loopnote12");
SOUND(TUBA5, "weapons/tuba_loopnote-12");
SOUND(TUBA6, "weapons/tuba_loopnote18");
SOUND(TUBA7, "weapons/tuba_loopnote-18");
SOUND(TUBA8, "weapons/tuba_loopnote24");
Sound SND_TUBA_RANDOM() {
    return REGISTRY_GET(Sounds, SND_TUBA1.m_id + floor(prandom() * 8));
}
