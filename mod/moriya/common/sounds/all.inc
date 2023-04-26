// Global list of sounds

SOUND(WATERFALL_AMBIENT, "waterfall_ambient");
SOUND(SPLASH, "splash");
SOUND(SPLASH2, "splash2");
SOUND(STEP, "step");

SOUND(BONK, "bonk");
SOUND(WAI, "wai");
SOUND(SIGH, "sigh");
SOUND(YAHOO, "yahoo");
SOUND(YEHEY, "yehey");
SOUND(EH1, "eh1");
SOUND(UWEH, "uweh");

SOUND(WAH1, "wah1");
SOUND(WAH2, "wah2");
SOUND(WAH3, "wah3");
SOUND(WAH4, "wah4");
Sound SND_WAH_RANDOM() {
    return REGISTRY_GET(Sounds, SND_WAH1.m_id + floor(prandom() * 4));
}

SOUND(WOW1, "wow1");
SOUND(WOW2, "wow2");
Sound SND_WOW_RANDOM() {
    return REGISTRY_GET(Sounds, SND_WOW1.m_id + floor(prandom() * 2));
}

SOUND(YATTA1, "yatta1");
SOUND(YATTA2, "yatta2");
SOUND(YATTA3, "yatta3");
Sound SND_YATTA_RANDOM() {
    return REGISTRY_GET(Sounds, SND_YATTA1.m_id + floor(prandom() * 3));
}
