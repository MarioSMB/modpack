/*

CORE    laser   nex     lg      rl      cry     gl      elec    hagar   fireb   hook
									minsta  porto
									tuba

NEW             rifle   hlac    minel                           seeker   
IDEAS                                   OPEN    flak    OPEN            FUN FUN FUN FUN



How this mutator works:
 =======================

When a gun tries to spawn, this mutator is called. It will provide alternate
weaponreplace lists.

Entity:

{
"classname" "weapon_nex"
"new_toys" "rifle"
}
-> This will spawn as Rifle in this mutator ONLY, and as Nex otherwise.

{
"classname" "weapon_nex"
"new_toys" "nex rifle"
}
-> This will spawn as either Nex or Rifle in this mutator ONLY, and as Nex otherwise.

{
"classname" "weapon_nex"
"new_toys" "nex"
}
-> This is always a Nex.

If the map specifies no "new_toys" argument

There will be two default replacements selectable: "replace all" and "replace random".
In "replace all" mode, e.g. Nex will have the default replacement "rifle".
In "replace random" mode, Nex will have the default replacement "nex rifle".

This mutator's replacements run BEFORE regular weaponreplace!

The New Toys guns do NOT get a spawn function, so they can only ever be spawned
when this mutator is active.

Likewise, warmup, give all, give ALL and impulse 99 will not give them unless
this mutator is active.

Outside this mutator, they still can be spawned by:
- setting their start weapon cvar to 1
- give weaponname
- weaponreplace
- weaponarena (but all and most weapons arena again won't include them)

This mutator performs the default replacements on the DEFAULTS of the
start weapon selection.

These weapons appear in the menu's priority list, BUT get a suffix
"(Mutator weapon)".

Picking up a "new toys" weapon will not play standard weapon pickup sound, but
roflsound "New toys, new toys!" sound.

*/

.string new_toys;

float autocvar_g_new_toys_autoreplace;
#define NT_AUTOREPLACE_NEVER 0
#define NT_AUTOREPLACE_ALWAYS 1
#define NT_AUTOREPLACE_RANDOM 2

MUTATOR_HOOKFUNCTION(nt_SetModname)
{
	modname = "NewToys";
	return 0;
}

float nt_IsNewToy(float w)
{
	switch(w)
	{
		case WEP_SEEKER:
		case WEP_MINE_LAYER:
		case WEP_HLAC:
		case WEP_RIFLE:
			return TRUE;
		default:
			return FALSE;
	}
}

string nt_GetFullReplacement(string w)
{
	switch(w)
	{
		case "hagar": return "seeker";
		case "rocketlauncher": return "minelayer";
		case "uzi": return "hlac";
		case "nex": return "rifle";
		default: return string_null;
	}
}

string nt_GetReplacement(string w, float m)
{
	if(m == NT_AUTOREPLACE_NEVER)
		return w;
	string s = nt_GetFullReplacement(w);
	if not(s)
		return w;
	if(m == NT_AUTOREPLACE_RANDOM)
		s = strcat(w, " ", s);
	return s;
}

MUTATOR_HOOKFUNCTION(nt_SetStartItems)
{
	// rearrange start_weapon_default
	// apply those bits that are set by start_weapon_defaultmask
	// same for warmup

	float i, j, k, n;

	WepSet newdefault;
	WepSet warmup_newdefault;
	
	newdefault = '0 0 0';
	warmup_newdefault = '0 0 0';

	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		entity e = get_weaponinfo(i);
		if(!e.weapon)
			continue;

		n = tokenize_console(nt_GetReplacement(e.netname, autocvar_g_new_toys_autoreplace));

		for(j = 0; j < n; ++j)
			for(k = WEP_FIRST; k <= WEP_LAST; ++k)
				if(get_weaponinfo(k).netname == argv(j))
				{
					if(start_weapons & WepSet_FromWeapon(i))
						newdefault |= WepSet_FromWeapon(k);
					if(warmup_start_weapons & WepSet_FromWeapon(i))
						warmup_newdefault |= WepSet_FromWeapon(k);
				}
	}

	newdefault &= start_weapons_defaultmask;
	start_weapons &= ~start_weapons_defaultmask;
	start_weapons |= newdefault;

	warmup_newdefault &= warmup_start_weapons_defaultmask;
	warmup_start_weapons &= ~warmup_start_weapons_defaultmask;
	warmup_start_weapons |= warmup_newdefault;

	return 0;
}

MUTATOR_HOOKFUNCTION(nt_SetWeaponreplace)
{
	// otherwise, we do replace
	if(self.new_toys)
	{
		// map defined replacement:
		ret_string = self.new_toys;
	}
	else
	{
		// auto replacement:
		ret_string = nt_GetReplacement(other.netname, autocvar_g_new_toys_autoreplace);
	}

	// apply regular weaponreplace
	ret_string = W_Apply_Weaponreplace(ret_string);

	return 0;
}

MUTATOR_HOOKFUNCTION(nt_FilterItem)
{
	if(nt_IsNewToy(self.weapon))
		self.item_pickupsound = "weapons/weaponpickup_new_toys.wav";
	return 0;
}

MUTATOR_DEFINITION(mutator_new_toys)
{
	MUTATOR_HOOK(SetModname, nt_SetModname, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, nt_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetWeaponreplace, nt_SetWeaponreplace, CBC_ORDER_LAST);
	MUTATOR_HOOK(FilterItem, nt_FilterItem, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This cannot be added at runtime\n");

		precache_sound("weapons/weaponpickup_new_toys.wav");

		// mark the guns as ok to use by e.g. impulse 99
		float i;
		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			if(nt_IsNewToy(i))
				get_weaponinfo(i).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		float i;
		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			if(nt_IsNewToy(i))
				get_weaponinfo(i).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
	}

	MUTATOR_ONREMOVE
	{
		print("This cannot be removed at runtime\n");
		return -1;
	}

	return 0;
}
