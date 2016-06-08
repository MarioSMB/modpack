vector get_model_parameters_hat_height;
float get_model_parameters_hat_scale;
vector get_model_parameters_hat_angles;

#ifdef SVQC
void hats_Precache(string pattern);

AUTOCVAR(g_hats, bool, false, _("Allow clients to use hats"));

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
		remove(this);
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

bool hats_Customize()
{
	if(other.cvar_cl_nohats) { return false; }
	return true;
}

void hats_SpawnHat()
{SELFPARAM();
	self.hatentity = spawn();
	self.hatentity.classname = "hatentity";
	self.hatentity.solid = SOLID_NOT;
	self.hatentity.owner = self;
	self.hatentity.hatentity = self.hatentity;
	setorigin(self.hatentity, '0 0 0');
	self.hatentity.angles = '0 0 0';
	setthink(self.hatentity, hat_Think);
	self.hatentity.nextthink = time;
	self.hatentity.customizeentityforclient = hats_Customize;

	CSQCMODEL_AUTOINIT(self.hatentity);
}

MUTATOR_HOOKFUNCTION(hats, PutClientInServer)
{SELFPARAM();
	hats_SpawnHat();
	self.hatentity.alpha = default_weapon_alpha;
	self.hatname = strzone(self.cvar_cl_hat);
	return false;
}

MUTATOR_HOOKFUNCTION(hats, GetCvars)
{
	GetCvars_handleString(get_cvars_s, get_cvars_f, cvar_cl_hat, "cl_magical_hax");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_nohats, "cl_nohats");
	return false;
}

MUTATOR_HOOKFUNCTION(hats, ClientDisconnect)
{SELFPARAM();
	self.hatentity = world;
	self.hatname = "";
	return false;
}

MUTATOR_HOOKFUNCTION(hats, MakePlayerObserver)
{SELFPARAM();
	self.hatentity = world;
	self.hatname = "";
	return false;
}

MUTATOR_HOOKFUNCTION(hats, ClearModelParams)
{
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;
	get_model_parameters_hat_angles = '0 0 0';
	return false;
}

MUTATOR_HOOKFUNCTION(hats, GetModelParams)
{
	if(checkmodel_input == "hat_height")
		get_model_parameters_hat_height = stov(checkmodel_command);
	if(checkmodel_input == "hat_scale")
		get_model_parameters_hat_scale = stof(checkmodel_command);
	if(checkmodel_input == "hat_angles")
		get_model_parameters_hat_angles = stov(checkmodel_command);
	return false;
}

#elif defined(CSQC)

REGISTER_MUTATOR(mod_hats, true);

AUTOCVAR_SAVE(cl_nohats,                    bool,   false,      _("Disable hats completely, requires reconnect or sendcvar"));
AUTOCVAR_SAVE(cl_magical_hax,               string, "",      	_("Magical hax, use at your own risk"));

string get_model_parameters_bone_head;

class(Skeleton) .int bone_hat;
class(Skeleton) .vector hat_height;
class(Skeleton) .float hat_scale;

MUTATOR_HOOKFUNCTION(mod_hats, TagIndex_Apply)
{SELFPARAM();
	if(substring(self.model, 0, 12) == "models/hats/")
	{
		if(substring(self.tag_entity.model, 0, 12) == "models/hats/")
		{
			self.tag_index = gettagindex(self.tag_entity, "tag_head");
			if(!self.tag_index)
				self.tag_index = gettagindex(self.tag_entity, "head");
			if(!self.tag_index)
			{
				// we need to prevent this from 'appening
				self.tag_entity = world;
				self.drawmask = 0;
			}
		}
		else if(self.tag_entity.isplayermodel)
		{
			skeleton_loadinfo(self.tag_entity);
			self.tag_index = self.tag_entity.bone_hat;
		}
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, ClearModelParams)
{
	get_model_parameters_bone_head = string_null;
	get_model_parameters_hat_height = '0 0 0';
	get_model_parameters_hat_scale = 0;
	get_model_parameters_hat_angles = '0 0 0';
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, GetModelParams)
{
	if(checkmodel_input == "bone_head")
		get_model_parameters_bone_head = checkmodel_command;
	if(checkmodel_input == "hat_height")
		get_model_parameters_hat_height = stov(checkmodel_command);
	if(checkmodel_input == "hat_scale")
		get_model_parameters_hat_scale = stof(checkmodel_command);
	if(checkmodel_input == "hat_angles")
		get_model_parameters_hat_angles = stov(checkmodel_command);
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckBones)
{SELFPARAM();
	self.bone_hat = gettagindex(self, "head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "tag_head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "bip01 head");
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckModel)
{SELFPARAM();
	if(get_model_parameters_bone_head)
		self.bone_hat = gettagindex(self, get_model_parameters_bone_head);
	return false;
}

#endif
