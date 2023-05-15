// subs
void (entity attacker, entity targ, float dam) LightningDamage;
void (entity attacker, entity targ, float dam) PoisonDamage;
void (entity attacker, entity targ, float dam) ColdDamage;
void (entity attacker, entity targ, float dam) FireDamage;
float(vector it, float start, float check) inv_hasitem;
vector(entity e, float slot) GetSlot;
void(entity e, float slot, vector it) SetSlot;
void(void() func, entity e) call;

// Quests
float(entity e) getstorylevel;
void(float lv, string name, string storage) spawnstory;
float (string n) getstorybyname;
void(entity e) rq_accept; // initiate
void() rq_cancel; // cancel / death trigger for rescues
void() rq_mondie; // death trigger for beast quests
void(entity e) rq_rescue; // for rescue quests
void(entity e) rq_reward; // for returning for reward
void(entity e) rq_recieve; // 


// Player
void() SetParms;
entity () find_body;
entity() find_spawn;
void () donothing;

// Menu
void (vector it, float eq) inven; // menu.qc
void(entity who, void() menufunc, entity subj) openmenu;
void(entity who) closemenu;
void(entity who, string text, entity subj, float expire) prompt;
void() m_sell;
void() m_repair;
void() m_identify;
void() m_invenlst;
void() m_spells1;
void() m_spells2;
void() m_mainmenu;
void() m_deposit;
void() m_withdraw;
void() m_stats;
void() m_restock;
void() m_recharge;
void() m_skill;
void() m_buy;
void(string h) mstring_add;

// Item stats
entity(float num) get_questitem;
float (vector it) canuse;
string(float it) itemmodel;
string(float it) it_itemicon;

void(entity e) itemapplyeffects; // sets up visuals for item. (skin/model/effects)
string(float it) itemsound;
void(vector it) it_simplestat;
void() it_itemstat;
vector (float it) it_itemsize;
float(float it) itemcount;
vector() it_setstat;
void() it_clearstats;
vector (float base, float val, float shop) randitem;
float (vector it, entity e) hassomething;
void() PrintItemName;

// Item control
vector(vector it) pickupitem;
void (vector it) dropitem;
void(float g) dropgold;
float(float sign) UseItem 
float(float slot, float recheck) Unequip;
float(float slot) Equip;
float(float slot) AutoEquip;
float(float slot) Use;
float(float it) takeammo;
float(vector it, entity e) takesomething;
void(entity who, float weps) DamageEquipment;
void() item;
void(vector it) pushitem;

// Inventory
float (entity e, vector it, vector sz) inv_autoplace;

// Stats
void() Restat;
void() Unstat;
void(float sign) GenStat;
void(entity e) boundstats;
float(entity att, entity targ, float expu) GiveExp;
void() titleupdate;
void(vector cl) BprintClass;
void(vector cl) TitleStat;
void(vector it, float eq) stats_report;
float(float exponent) LvlForExp;

// Spells
float(entity e, float spell) GetSpellLevel;
void(entity e, float espell, float l) SetSpellLevel;
void(entity e, float spell, float level) AddSpellLevel;
float (float sp, float lv) mana_for_spell;
float(float g) spell_range;
float(float sp) cast_aground;
void(float sp) spell_fire;
void() evile_1;
float (float sp) SelectSpell;

// Shops/Gold
float(float it, float pref, float suf, float howmuch) takeamount;
void(float howmuch) givegold;
float(float howmuch) getgold; // it's baaaaack!

// Shell
void() dovis;
void() precaches;
void() LightStyles_setup;
void() DecodeLevelParms;
void () gamestate_load;
void() savedata;

// Animation
float(float yaw, float run) moveit;
void(entity e) set_frames;
void() AnimatePlayer;
void() bowattack1;
void() cbowattack1;
void() attack1;
void() throw1;
void() chakram1;
void() jump1;
void() brawl1;
void() frenzy1;
void(float bodydeath) PlayerDie;
void() updateskins;
void(string gibmodel) spawngib;


// Generic
float(float s1, float s2, float s3) encode;
float(float parm, float which) decode;
float (float parm, float which, float set) recode;
vector(float it) legacy_itemv1;

// Monsters/Npcs
void() monster_scarite;
void() monster_guanite;
void() monster_drak;
void() monster_horror;
void() monster_spawn_go;
void() npc;

// Day and Night
void() QueryDayNight;

// Random Quests
string (float f) rq_npcname;
string (float n) rq_npcmodel;

// What's this?
vector() decodeitem;