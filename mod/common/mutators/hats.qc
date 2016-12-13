vector get_model_parameters_hat_height;
float get_model_parameters_hat_scale;
vector get_model_parameters_hat_angles;

#ifdef SVQC
void hats_Precache(string pattern);

AUTOCVAR_NOREF(g_hats, bool, false, "Allow clients to use hats");

REGISTER_MUTATOR(hats, cvar("g_hats") && !cvar("g_overkill"))
{
	MUTATOR_ONADD
	{
		hats_Precache("models/hats/*.md3");
	}
}

.entity hatentity;
.string cvar_cl_hat;
.bool cvar_cl_nohats;
.string hatname; // only update when the player spawns

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
	vector s;
	get_model_parameters(e.model, e.skin);
	s = get_model_parameters_hat_height;
	get_model_parameters(string_null, 0);
	
	return s;
}

vector hats_getangles(entity e)
{
	vector s;
	get_model_parameters(e.model, e.skin);
	s = get_model_parameters_hat_angles;
	get_model_parameters(string_null, 0);
	
	return s;
}

void hat_Think(entity this)
{
	float tag_found;
	this.nextthink = time;
	if (this.owner.hatentity != this)
	{
		delete(this);
		return;
	}
	if(STAT(FROZEN, this.owner) || IS_DEAD(this.owner))
	{
		this.model = "";
		return;
	}
	if (this.hatname != this.owner.hatname || this.dmg != this.owner.modelindex || this.deadflag != this.owner.deadflag)
	{
		this.hatname = this.owner.hatname;
		this.dmg = this.owner.modelindex;
		this.deadflag = this.owner.deadflag;
		if (this.owner.hatname != "" && fexists(strcat("models/hats/", this.owner.hatname, ".md3")))
			_setmodel(this, strcat("models/hats/", this.owner.hatname, ".md3")); // precision set below
		else
			this.model = "";

		if((tag_found = gettagindex(this.owner, "tag_head")))
		{
			this.tag_index = tag_found;
			this.tag_entity = this.owner;
			setorigin(this, hats_getheight(this.owner));
			this.scale = hats_getscale(this.owner);
			this.angles = hats_getangles(this.owner);
		}
		else
		{
			setattachment(this, this.owner, "head");
			setorigin(this, hats_getheight(this.owner));
			this.scale = hats_getscale(this.owner);
			this.angles = hats_getangles(this.owner);
		}
	}
	this.effects = this.owner.effects;
	this.effects |= EF_LOWPRECISION;
	this.effects = this.effects & EFMASK_CHEAP; // eat performance
	if(this.scale < -1)
		this.alpha = -1;
	else if(this.owner.alpha == default_player_alpha)
		this.alpha = default_weapon_alpha;
	else if(this.owner.alpha != 0)
		this.alpha = this.owner.alpha;
	else
		this.alpha = 1;

	this.glowmod = this.owner.glowmod;
	this.colormap = this.owner.colormap;

	CSQCMODEL_AUTOUPDATE(this);
}

bool hats_Customize(entity this, entity client)
{
	if(client.cvar_cl_nohats) { return false; }
	return true;
}

REPLICATE(cvar_cl_hat, string, "cl_magical_hax");
REPLICATE(cvar_cl_nohats, bool, "cl_nohats");

void hats_SpawnHat(entity this)
{
	this.hatentity = spawn();
	this.hatentity.classname = "hatentity";
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

MUTATOR_HOOKFUNCTION(hats, PutClientInServer)
{
	entity player = M_ARGV(0, entity);

	hats_SpawnHat(player);
	player.hatentity.alpha = default_weapon_alpha;
	player.hatname = strzone(player.cvar_cl_hat);
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

class(Skeleton) .int bone_hat;
class(Skeleton) .vector hat_height;
class(Skeleton) .float hat_scale;

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
