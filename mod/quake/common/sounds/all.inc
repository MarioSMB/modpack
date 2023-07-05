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
