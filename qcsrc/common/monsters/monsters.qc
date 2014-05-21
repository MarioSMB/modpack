#include "all.qh"

// MONSTER PLUGIN SYSTEM
entity monster_info[MON_MAXCOUNT];
entity dummy_monster_info;

void register_monster(float id, float(float) func, float monsterflags, vector min_s, vector max_s, string modelname, string shortname, string mname)
{
	entity e;
	monster_info[id - 1] = e = spawn();
	e.classname = "monster_info";
	e.monsterid = id;
	e.netname = shortname;
	e.monster_name = mname;
	e.monster_func = func;
	e.mdl = modelname;
	e.spawnflags = monsterflags;
	e.mins = min_s;
	e.maxs = max_s;
	e.model = strzone(strcat("models/monsters/", modelname));
}
float m_null(float dummy) { return 0; }
void register_monsters_done()
{
	dummy_monster_info = spawn();
	dummy_monster_info.classname = "monster_info";
	dummy_monster_info.monsterid = 0; // you can recognize dummies by this
	dummy_monster_info.netname = "";
	dummy_monster_info.monster_name = "Monster";
	dummy_monster_info.monster_func = m_null;
	dummy_monster_info.mdl = "";
	dummy_monster_info.mins = '-0 -0 -0';
	dummy_monster_info.maxs = '0 0 0';
	dummy_monster_info.model = "";
}
entity get_monsterinfo(float id)
{
	entity m;
	if(id < MON_FIRST || id > MON_LAST)
		return dummy_monster_info;
	m = monster_info[id - 1];
	if(m)
		return m;
	return dummy_monster_info;
}
