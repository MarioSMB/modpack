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

SOUND(ROCKET_EXPLOSION, "weapons/r_exp3");

SOUND(TALK2, "misc/talk2");

SOUND(RUNE_CAST, "weapons/rune_cast");

SOUND(TUBA_FIRE, "weapons/tuba_fire");

SOUND(DOOT_FIRE, "weapons/fastdoot");

//----------------------------------------------------------------------
// Footstep sounds
SOUND(FS_SLOW1, "steps/slow1");
SOUND(FS_SLOW2, "steps/slow2");
SOUND(FS_SLOW3, "steps/slow3");
SOUND(FS_SLOW4, "steps/slow4");
SOUND(FS_SLOW5, "steps/slow5");
Sound SND_FS_SLOW(int index) {
    return REGISTRY_GET(Sounds, SND_FS_SLOW1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_DRAG1, "steps/drag1");
SOUND(FS_DRAG2, "steps/drag2");
SOUND(FS_DRAG3, "steps/drag3");
SOUND(FS_DRAG4, "steps/drag4");
SOUND(FS_DRAG5, "steps/drag5");
Sound SND_FS_DRAG(int index) {
    return REGISTRY_GET(Sounds, SND_FS_DRAG1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_LIGHT1, "steps/light1");
SOUND(FS_LIGHT2, "steps/light2");
SOUND(FS_LIGHT3, "steps/light3");
SOUND(FS_LIGHT4, "steps/light4");
SOUND(FS_LIGHT5, "steps/light5");
Sound SND_FS_LIGHT(int index) {
    return REGISTRY_GET(Sounds, SND_FS_LIGHT1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_MEDIUM1, "steps/medium1");
SOUND(FS_MEDIUM2, "steps/medium2");
SOUND(FS_MEDIUM3, "steps/medium3");
SOUND(FS_MEDIUM4, "steps/medium4");
SOUND(FS_MEDIUM5, "steps/medium5");
Sound SND_FS_MEDIUM(int index) {
    return REGISTRY_GET(Sounds, SND_FS_MEDIUM1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_HEAVY1, "steps/heavy1");
SOUND(FS_HEAVY2, "steps/heavy2");
SOUND(FS_HEAVY3, "steps/heavy3");
SOUND(FS_HEAVY4, "steps/heavy4");
SOUND(FS_HEAVY5, "steps/heavy5");
Sound SND_FS_HEAVY(int index) {
    return REGISTRY_GET(Sounds, SND_FS_HEAVY1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_LARGE1, "steps/large1");
SOUND(FS_LARGE2, "steps/large2");
SOUND(FS_LARGE3, "steps/large3");
SOUND(FS_LARGE4, "steps/large4");
SOUND(FS_LARGE5, "steps/large5");
Sound SND_FS_LARGE(int index) {
    return REGISTRY_GET(Sounds, SND_FS_LARGE1.m_id + bound(0, index - 1, 4));
}

SOUND(FS_GIANT1, "steps/giant1");
SOUND(FS_GIANT2, "steps/giant2");
SOUND(FS_GIANT3, "steps/giant3");
SOUND(FS_GIANT4, "steps/giant4");
SOUND(FS_GIANT5, "steps/giant5");
Sound SND_FS_GIANT(int index) {
    return REGISTRY_GET(Sounds, SND_FS_GIANT1.m_id + bound(0, index - 1, 4));
}
