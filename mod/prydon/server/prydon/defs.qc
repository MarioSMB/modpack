.void() think1, nextframe;
.string map, message;
.float worldtype, delay, wait, lip, light_lev, speed, style, skill;
.vector finalangle;
.string wad, voice;
.string killtarget;
.vector pos1, pos2, mangle, dest1;
.string theme;
nosave string music;

// ----------
// game variables
.entity camera, player;
.float attack_finished, pausetime;
.entity m_targ, drawonlytoclient, spellprop;
.float misc, options;
.float oldskin;

.string bkup_model;
.vector rightarm, leftarm;
// ************************
// *                      *
// *        System        *
// *                      *
// ************************

.float button3, button4, button5, button6, button7;
.float scale;
.entity vmodel, viewmodelforclient;

nosave string string_null;    // null string, nothing should be held here
nosave var void() nullfunc;
nosave float mplayer;
nosave float netplay;

float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;
float   EF_NODRAW       = 16;
float   EF_ADDITIVE     = 32;
float   EF_BLUE         = 64;
float   EF_RED          = 128;
float   EF_FULLBRIGHT   = 512;
float   EF_FLAME        = 1024;
float   EF_STARDUST     = 2048;
float   EF_NODEPTHTEST       = 8192;
float MISC_EFFECT_FLAGS = 4095;

// ************************
// *                      *
// *      Map Stats       *
// *                      *
// ************************
nosave float itemvalue;
nosave float monsvalue;
var float saveversion;
nosave var float gameload = 1;
nosave var float numplayers;
nosave var float averagelvl;
nosave var float cache = 1;
nosave var float nomusic;
float SAVE_VERSION = 2;


// ************************
// *                      *
// *        Menu          *
// *                      *
// ************************

.float menu, m_refresh, m_expire, m_num;
.entity m_subject;
.void() m_func, use, action;

// REORGANIZE PLEASE

// ************************
// *                      *
// *        Print         *
// *                      *
// ************************

nosave float red, chars, lines; 

float RED_ON = 128;
float RED_OFF = 0;
float RED_GOLD = -30;
float WIDTH = 30;

// ************************
// *                      *
// *      Inventory       *
// *                      *
// ************************

nosave entity stashent;

// LEGACY
.vector slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8;
.vector slot9, slot10, slot11, slot12, slot13, slot14, slot15, slot16;
.float equip, droprandom;

float TOTAL_SLOTS = 16;

float QI_SLOT1 = 1;
float QI_SLOT2 = 2;
float QI_SLOT3 = 4;
float QI_SLOT4 = 8;
float QI_SLOT5 = 16;
float QI_SLOT6 = 32;
float QI_SLOT7 = 64;
float QI_SLOT8 = 131072;

//float	QI_FIRE = 256; // shells
//float	QI_COLD = 512; // nails
//float	QI_POISON = 1024; // rockets
//float	QI_LIT = 2048; // cells
//float	QI_KNIVES = 8192; // green armor
//float	QI_SPEARS = 16384; // yellow
//float	QI_ARROWS = 32768; // red

//float	IT_KEY2	= 262144;
float QI_POISON = 2097152;
float QI_FROZEN = 4194304;

vector INV_PLAYERSIZE = '8 6 0';
vector INV_GFX_START = '5 75 0'; // where it starts on the inv.spr pic
float INV_ICON_SIZE = 11; // dimensions of 1 slot.
vector INV_INVALID = '-1 -1 -1';


nosave vector inv_loc;

nosave float inv_rebuild;
// do we really need all this info?
float INV_MASK = 255;
float INV_MASTER = 256;
float INV_SLAVE = 512;
float INV_MICRO = 128;


.float inv_0_0, inv_0_1, inv_0_2, inv_0_3, inv_0_4, inv_0_5;
.float inv_1_0, inv_1_1, inv_1_2, inv_1_3, inv_1_4, inv_1_5;
.float inv_2_0, inv_2_1, inv_2_2, inv_2_3, inv_2_4, inv_2_5;
.float inv_3_0, inv_3_1, inv_3_2, inv_3_3, inv_3_4, inv_3_5;
.float inv_4_0, inv_4_1, inv_4_2, inv_4_3, inv_4_4, inv_4_5;
.float inv_5_0, inv_5_1, inv_5_2, inv_5_3, inv_5_4, inv_5_5;
.float inv_6_0, inv_6_1, inv_6_2, inv_6_3, inv_6_4, inv_6_5;
.float inv_7_0, inv_7_1, inv_7_2, inv_7_3, inv_7_4, inv_7_5;


// ************************
// *                      *
// *          AI          *
// *                      *
// ************************

.float ai;
.float finddist;
.float altaction, follow_npcs;
nosave var .float obs_angle = light_lev;
nosave var .float obs_count = lip;
.float gotstuff;

// ************************
// *                      *
// *      Animation       *
// *                      *
// ************************

.float walkframes, runframes, deathframes, attackframes, poseframes, castframes, jumpframes, bowframes;
.float throwframes, doubleattack, cbowframes;
.float attackscenes, dblattkscenes, castscenes, deathscenes;

.float hitframe;
.float walkframe;
.void(float bodydeath) die;
.void() pain;

// ************************
// *                      *
// *       Triggers       *
// *                      *
// ************************

nosave entity activator, s_player;

.string subject, requirements;
..float req_field, mod_field;
.float req_value;
.float req_lvl, req_str, req_mag, req_dex, req_vit, req_luck, req_agil;
.vector req_class, req_item;
.float rand_sel, rand_trig;
.string target1, target2, target3, target4, target5, target6, target7, target8;
.string message1, message2, message3, message4, message5, message6, message7, message8;

// ************************
// *                      *
// *   Player Interface   *
// *                      *
// ************************

.float quest_time;
.vector cursorpos;
.vector rotang;
.vector testorg;
.entity cursor, wayp, sbarsub;
.float dbltime;
.void(float alt) ui_clicked;
.void() ui_hover;

.entity ui, ui_parent;
.float ui_panels;

// ************************
// *                      *
// *        Quests        *
// *                      *
// ************************
float mainstory, opt1, opt2, opt3, opt4, opt5, opt6;
vector rndquest, rq_vars;

.float story_min, story_max;
.string story_name;

// ************************
// *                      *
// *        Stats         *
// *                      *
// ************************
.float max_health, max_mana;
nosave var .float mana = currentammo;
.float ac, tohit, dodge, dama, daml;
.float exp;
.float spell, spec;
nosave var .float lvl = frags;
.float str, dex, vit, mag;
.float luck, agil, ptd;
.float lit, fire, poidam, cold, magic;
.float cold_factor, cold_time, shield_time, shield_factor;
.float poison_count, poison_factor, mortal_factor;
.entity poison_inflictor;
.float daze_time, frenzy_time, frenzy_factor;
.float summon_count, bribe_count, bribe_time;
.float critical, piercing, visibility;
.float attacker_dam, attacker_fire, attacker_lit, attacker_cold, attacker_poison;
.float regen_time;
.float health_regen;
.float mana_regen, magic_reduced, damage_reduced;
.float aspeed;
.float spells1, spells2, spells3, spells4, spells5, spells6,
spells7, spells8, spells9, spells10, spells11, spells12,
spells13, spells14, spells15, spells16;
.float res_poison, res_fire, res_mag, res_lit, res_cold;
.float block;
.vector title;

float MISC_UPDATE_BLINK = 1;
float MISC_SAVE_INVENTORY = 2;
float MISC_SPRINT_DONE = 4;
// 8
float MISC_FULL_SKINS = 16; //human.mdl only so far.
float MISC_NO_SKINS = 32; // no effects skins
float MISC_MORTAL_WOUND = 4096;
float MISC_MAIMED = 8192;
float MISC_BAD_EFFECTS = 12288;
float MISC_DOUBLEATTACK = 16384;
float MISC_CHAKRAM = 32768;
// 65536
float MISC_RESPAWN = 131072;

float OPT_HIDESPELLS = 1;
float OPT_NOMOUSE_CAM = 2;
float OPT_NOQUEST_UPDATE = 4;
float OPT_VERBOSE = 8;
float OPT_SEEN_PTD = 16;

// ************************
// *                      *
// *        Items         *
// *                      *
// ************************
// basic
nosave float stat_price, stat_dur, stat_loc, stat_pref, stat_suf, stat_it;
nosave float stat_max_dur;
// requirements
nosave float stat_req_str, stat_req_mag, stat_req_dex, stat_req_vit, stat_req_luck;
nosave float stat_req_agil, stat_req_lvl;
nosave vector stat_req_class;
// granted stats
nosave float stat_str, stat_mag, stat_dex, stat_vit, stat_luck, stat_agil;
nosave float stat_toall;
// resistances
nosave float stat_resist_fire, stat_resist_lit, stat_resist_poison, stat_resist_cold, stat_resist_magic, stat_resist_all;
// newer granted stuff
nosave float stat_block, stat_aspeed, stat_mana_regen, stat_critical;
// special feature (mostly for quest items)
nosave entity stat_target;
// weapon damage..l = low end, a = amount of variation
nosave float stat_daml, stat_dama;
// modifiers for generated stats 
nosave float stat_tohit, stat_dodge, stat_mana, stat_health;
// armor defense & spell stuff
nosave float stat_def, stat_spell;
// magic damage
nosave float stat_fire, stat_poison, stat_lit, stat_cold, stat_magic, stat_spec;
// is it identified? action when equipped
nosave float stat_id, stat_action;
// misc flags (see below, MISC_), skill flags (see below, SKILL_)
nosave float stat_misc, stat_skill;
// spell level modifier (use with stat_spell)
nosave float stat_spell_level;
// health regen 
nosave float stat_health_regen;
// special effects modifier
nosave float stat_magic_quality; // ugh?
// attacker takes..
nosave float stat_attacker_dam, stat_attacker_fire, stat_attacker_lit, stat_attacker_cold, stat_attacker_poison;
// more effects
nosave float stat_magic_reduced, stat_damage_reduced, stat_piercing, stat_visibility;
nosave vector stat_size;

float PLAYER_SKINS = 6;
float MAX_CHAR_LEVEL = 100;

float EQUIPABLE = 1;
float STACKABLE = 2;
float USABLE = 4;
float DURABILITY = 8;

float LOC = 2032;
float BODY = 16;
float HEAD = 32;
float RIGHTARM = 64;
float LEFTARM = 128;
float TWO_HAND = 192;
float NECK = 256;
float SPELL = 512;
float FEET = 1024;
float USE_ON_ITEM = 2048;
float AMMO = 4096;
float INFINITE = 8192;
float CHARGES = 16384;

float SPEC_SPEED = 1; // replaced with .aspeed
float SPEC_STEAL_LIFE = 2;
//4
float SPEC_STEAL_MANA = 8;
float SPEC_KNOCKBACK = 16;
float SPEC_INDESTRUCTIBLE = 32;
//64
// 128
float SPEC_REPLENISH = 256;
float SPEC_DAZE = 512;
float SPEC_MORTAL_WOUND = 1024;
float SPEC_TWO_HITS = 2048;
float SPEC_MAIM = 4096;
float SPEC_CRUSHING = 8192;
float SPEC_MELEE_IMMUNE = 16384;
float SPEC_MISSILE_IMMUNE = 32768;

float SKILL_EXPERIENCE = 1; // 8
float SKILL_REPAIR = 2; // warriors
float SKILL_IDENTIFY = 4; // mages
float SKILL_SPRINT = 8; // rogues
float SKILL_BRAWL = 16; // 16 warriors
float SKILL_RELOAD = 32; //17 archers
float SKILL_FLAME_ARROW = 64; //18 archers
float SKILL_DISCOUNT = 128; // 19 rogues
float SKILL_BRIBE = 256; // 20 rogues
float SKILL_POTION = 512; // umm
float SKILL_MELEE = 1024; // 9
float SKILL_BOW = 2048;
float SKILL_THROW = 4096;
float SKILL_SPELLS = 8192;
float SKILL_JUMP = 16384;
float SKILL_FRENZY = 32768;

.vector colormod;
.string noise4;
.float value;

.float fade, fadetime;
.float monnum;
.float questlog;
float lastmap;
nosave string nextmap;
float runtime;
.float fallz;
.float gp;
.string group;


float BIG_DISTANCE = 1200;

// ************************
// *                      *
// *       Security       *
// *                      *
// ************************
.float pin, authed;
.string username;

nosave float secure;
nosave float skillm;

float AUTH_NO = 0;
float AUTH_SIGNUP = 1;
float AUTH_YES = 2;
float AUTH_NAMECHANGED = 3;