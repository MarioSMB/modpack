//FEATURE: Hats!

vector get_model_parameters_hat_height;
float get_model_parameters_hat_scale;
vector get_model_parameters_hat_angles;

#ifdef SVQC
.string cvar_cl_hat;
.bool cvar_cl_nohats;
#elif defined(CSQC)
string cvar_cl_hat;
bool cvar_cl_nohats;
#endif
#ifdef GAMEQC
REPLICATE(cvar_cl_hat, string, "cl_magical_hax");
REPLICATE(cvar_cl_nohats, bool, "cl_nohats");
#endif

#ifdef SVQC
void hats_Precache(string pattern);

AUTOCVAR(g_hats, bool, false, "Allow clients to use hats");
AUTOCVAR(g_hats_default, string, "", "Default hat when player has none on");
AUTOCVAR(g_hats_nolegacy, bool, false, "Use new default offsets (not recommended yet)");
AUTOCVAR(g_hats_randomize, bool, false, "Pick a random hat from the hats folder as a default");

REGISTER_MUTATOR(hats, autocvar_g_hats && !cvar("g_overkill"))
{
	MUTATOR_ONADD
	{
		hats_Precache("models/hats/*.md3");
		hats_Precache("models/hats/*.obj");
		hats_Precache("models/hats/*.iqm");
	}
}

.entity hatentity;
.string hatname; // only update when the player spawns

//ATTRIB(Client, cvar_cl_hat, string, this.cvar_cl_hat);
//ATTRIB(Client, cvar_cl_nohats, bool, this.cvar_cl_nohats);

void hats_Precache(string pattern)
{
	float globhandle, i, n;
	string f;

	globhandle = search_begin(pattern, true, false);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		f = search_getfilename(globhandle, i);
		precache_model(f);
	}
	search_end(globhandle);
}

float hats_getscale(entity e)
{
	float s;
	get_model_parameters(e.model, e.skin);
	s = get_model_parameters_hat_scale;
	get_model_parameters(string_null, 0);
	
	return s;
}

vector hats_getheight(entity e)
{
	vector s, hat_offset = '0 0 0';
	float myscale;
	get_model_parameters(e.model, e.skin);
	s = get_model_parameters_hat_height;
	myscale = get_model_parameters_hat_scale;
	get_model_parameters(string_null, 0);

	if(autocvar_g_hats_nolegacy)
	{
		// attempt to get default height
		hat_offset = '0 10 -1' * ((myscale) ? myscale : 1); // legacy models are offset by a margin that varies depending on their size
	}

	return hat_offset + s;
}

vector hats_getangles(entity e)
{
	vector s, hat_offset = '0 0 0';
	get_model_parameters(e.model, e.skin);
	s = get_model_parameters_hat_angles;
	get_model_parameters(string_null, 0);

	if(autocvar_g_hats_nolegacy)
	{
		// attempt to get default angle
		hat_offset = '90 0 0';
	}

	return hat_offset + s;
}

string hat_exists(string pattern)
{
	string try;
	try = strcat(pattern, ".md3");
	if(fexists(try))
		return try;
	try = strcat(pattern, ".obj");
	if(fexists(try))
		return try;
	try = strcat(pattern, ".iqm");
	if(fexists(try))
		return try;

	return string_null;
}

void hat_Think(entity this)
{
	entity player = this.owner;
	float tag_found;
	this.nextthink = time;
	if (player.hatentity != this || !player)
	{
		delete(this);
		return;
	}
	if(STAT(FROZEN, player) || IS_DEAD(player))
	{
		this.model = "";
		return;
	}
	if (this.hatname != player.hatname || this.dmg != player.modelindex || this.deadflag != player.deadflag)
	{
		this.hatname = player.hatname;
		this.dmg = player.modelindex;
		this.deadflag = player.deadflag;
		string exists = ((player.hatname && player.hatname != "") ? hat_exists(strcat("models/hats/", player.hatname)) : string_null);
		if (player.hatname && player.hatname != "" && exists)
			_setmodel(this, exists); // precision set below
		else
			this.model = "";

		if((tag_found = gettagindex(player, "tag_head")))
		{
			this.tag_index = tag_found;
			this.tag_entity = player;
			setorigin(this, hats_getheight(player));
			this.scale = hats_getscale(player);
			this.angles = hats_getangles(player);
		}
		else
		{
			setattachment(this, player, "head");
			setorigin(this, hats_getheight(player));
			this.scale = hats_getscale(player);
			this.angles = hats_getangles(player);
		}
	}
	this.effects = player.effects;
	this.effects |= EF_LOWPRECISION;
	this.effects = this.effects & EFMASK_CHEAP; // eat performance
	if(this.scale < -1)
		this.alpha = -1;
	else if(player.alpha == default_player_alpha)
		this.alpha = default_weapon_alpha;
	else if(player.alpha != 0)
		this.alpha = player.alpha;
	else
		this.alpha = 1;

	this.glowmod = player.glowmod;
	this.colormap = player.colormap;

	CSQCMODEL_AUTOUPDATE(this);
}

bool hats_Customize(entity this, entity client)
{
	if(CS_CVAR(client).cvar_cl_nohats) { return false; }
	return true;
}

void hats_SpawnHat(entity this)
{
	this.hatentity = new(hatentity);
	this.hatentity.solid = SOLID_NOT;
	this.hatentity.owner = this;
	this.hatentity.hatentity = this.hatentity;
	setorigin(this.hatentity, '0 0 0');
	this.hatentity.angles = '0 0 0';
	setthink(this.hatentity, hat_Think);
	this.hatentity.nextthink = time;
	setcefc(this.hatentity, hats_Customize);

	CSQCMODEL_AUTOINIT(this.hatentity);
}

string hats_GetRandom()
{
	int glob = search_begin("models/hats/*", true, true);
	if(glob >= 0)
	{
		bool found = false;
		RandomSelection_Init();
		for (int i = 0, n = search_getsize(glob); i < n; ++i)
		{
			string file = search_getfilename(glob, i);
			string ext = substring(file, -3, 3);
			// TODO: proper format support? not sure what that would look like!
			if(ext == "obj" || ext == "md3" || ext == "iqm")
			{
				RandomSelection_AddString(file, 1, 1);
				found = true;
			}
		}
		search_end(glob);
		if(found)
		{
			string foundfile = substring(RandomSelection_chosen_string, 12, -5);
			return foundfile;
		}
	}

	return autocvar_g_hats_default; // fall back to default anyway
}

MUTATOR_HOOKFUNCTION(hats, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	hats_SpawnHat(player);
	player.hatentity.alpha = default_weapon_alpha;
	if(CS_CVAR(player).cvar_cl_hat != "")
		player.hatname = strzone(CS_CVAR(player).cvar_cl_hat);
	else if(!autocvar_g_hats_randomize)
		player.hatname = strzone(autocvar_g_hats_default);
	else if(player.hatname == "")
		player.hatname = strzone(hats_GetRandom());
}

MUTATOR_HOOKFUNCTION(hats, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	player.hatentity = NULL;
	player.hatname = "";
}

MUTATOR_HOOKFUNCTION(hats, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	player.hatentity = NULL;
	player.hatname = "";
}

MUTATOR_HOOKFUNCTION(hats, ClearModelParams)
{
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;
	get_model_parameters_hat_angles = '0 0 0';
}

MUTATOR_HOOKFUNCTION(hats, GetModelParams)
{
	string checkmodel_input = M_ARGV(0, string);
	string checkmodel_command = M_ARGV(1, string);

	if(checkmodel_input == "hat_height")
		get_model_parameters_hat_height = stov(checkmodel_command);
	if(checkmodel_input == "hat_scale")
		get_model_parameters_hat_scale = stof(checkmodel_command);
	if(checkmodel_input == "hat_angles")
		get_model_parameters_hat_angles = stov(checkmodel_command);
}

#elif defined(CSQC)

REGISTER_MUTATOR(mod_hats, true);

AUTOCVAR_NOREF_SAVE(cl_nohats,                    bool,   false,      "Disable hats completely, requires reconnect or sendcvar");
AUTOCVAR_NOREF_SAVE(cl_magical_hax,               string, "",      	"Magical hax, use at your own risk");

string get_model_parameters_bone_head;

classfield(Skeleton) .int bone_hat;
classfield(Skeleton) .vector hat_height;
classfield(Skeleton) .float hat_scale;

STATIC_INIT(hats)
{
	localcmd("\nalias cl_hat \"seta cl_magical_hax ${* ?}; sendcvar cl_magical_hax\"\n");
}

MUTATOR_HOOKFUNCTION(mod_hats, TagIndex_Apply)
{
	entity ent = M_ARGV(0, entity);

	if(substring(ent.model, 0, 12) == "models/hats/")
	{
		if(substring(ent.tag_entity.model, 0, 12) == "models/hats/")
		{
			ent.tag_index = gettagindex(ent.tag_entity, "tag_head");
			if(!ent.tag_index)
				ent.tag_index = gettagindex(ent.tag_entity, "head");
			if(!ent.tag_index)
			{
				// we need to prevent this from 'appening
				ent.tag_entity = NULL;
				ent.drawmask = 0;
			}
		}
		else if(ent.tag_entity.isplayermodel)
		{
			skeleton_loadinfo(ent.tag_entity);
			ent.tag_index = ent.tag_entity.bone_hat;
		}
	}
}

MUTATOR_HOOKFUNCTION(mod_hats, ClearModelParams)
{
	get_model_parameters_bone_head = string_null;
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;
	get_model_parameters_hat_angles = '0 0 0';
}

MUTATOR_HOOKFUNCTION(mod_hats, GetModelParams)
{
	string checkmodel_input = M_ARGV(0, string);
	string checkmodel_command = M_ARGV(1, string);

	if(checkmodel_input == "bone_head")
		get_model_parameters_bone_head = checkmodel_command;
	if(checkmodel_input == "hat_height")
		get_model_parameters_hat_height = stov(checkmodel_command);
	if(checkmodel_input == "hat_scale")
		get_model_parameters_hat_scale = stof(checkmodel_command);
	if(checkmodel_input == "hat_angles")
		get_model_parameters_hat_angles = stov(checkmodel_command);
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckBones)
{
	entity ent = M_ARGV(0, entity);

	ent.bone_hat = gettagindex(ent, "head");
	if(!ent.bone_hat)
		ent.bone_hat = gettagindex(ent, "tag_head");
	if(!ent.bone_hat)
		ent.bone_hat = gettagindex(ent, "bip01 head");
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckModel)
{
	entity ent = M_ARGV(0, entity);

	if(get_model_parameters_bone_head)
		ent.bone_hat = gettagindex(ent, get_model_parameters_bone_head);
}

#endif
