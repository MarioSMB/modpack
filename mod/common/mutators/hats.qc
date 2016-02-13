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

void hat_Think()
{
	float tag_found;
	self.nextthink = time;
	if (self.owner.hatentity != self)
	{
		remove(self);
		return;
	}
	if(STAT(FROZEN, self.owner) || IS_DEAD(self.owner))
	{
		self.model = "";
		return;
	}
	if (self.hatname != self.owner.hatname || self.dmg != self.owner.modelindex || self.deadflag != self.owner.deadflag)
	{
		self.hatname = self.owner.hatname;
		self.dmg = self.owner.modelindex;
		self.deadflag = self.owner.deadflag;
		if (self.owner.hatname != "" && fexists(strcat("models/hats/", self.owner.hatname, ".md3")))
			_setmodel(self, strcat("models/hats/", self.owner.hatname, ".md3")); // precision set below
		else
			self.model = "";

		if((tag_found = gettagindex(self.owner, "tag_head")))
		{
			self.tag_index = tag_found;
			self.tag_entity = self.owner;
			setorigin(self, hats_getheight(self.owner));
			self.scale = hats_getscale(self.owner);
			self.angles = hats_getangles(self.owner);
		}
		else
		{
			setattachment(self, self.owner, "head");
			setorigin(self, hats_getheight(self.owner));
			self.scale = hats_getscale(self.owner);
			self.angles = hats_getangles(self.owner);
		}
	}
	self.effects = self.owner.effects;
	self.effects |= EF_LOWPRECISION;
	self.effects = self.effects & EFMASK_CHEAP; // eat performance
	if(self.scale < -1)
		self.alpha = -1;
	else if(self.owner.alpha == default_player_alpha)
		self.alpha = default_weapon_alpha;
	else if(self.owner.alpha != 0)
		self.alpha = self.owner.alpha;
	else
		self.alpha = 1;

	self.glowmod = self.owner.glowmod;
	self.colormap = self.owner.colormap;

	CSQCMODEL_AUTOUPDATE(self);
}

bool hats_Customize()
{
	if(other.cvar_cl_nohats) { return false; }
	return true;
}

void hats_SpawnHat()
{
	self.hatentity = spawn();
	self.hatentity.classname = "hatentity";
	self.hatentity.solid = SOLID_NOT;
	self.hatentity.owner = self;
	self.hatentity.hatentity = self.hatentity;
	setorigin(self.hatentity, '0 0 0');
	self.hatentity.angles = '0 0 0';
	self.hatentity.think = hat_Think;
	self.hatentity.nextthink = time;
	self.hatentity.customizeentityforclient = hats_Customize;

	CSQCMODEL_AUTOINIT(self.hatentity);
}

MUTATOR_HOOKFUNCTION(hats, PutClientInServer)
{
	hats_SpawnHat();
	self.hatentity.alpha = default_weapon_alpha;
	self.hatname = strzone("heart");
	//self.hatname = strzone(self.cvar_cl_hat);
	return false;
}

MUTATOR_HOOKFUNCTION(hats, GetCvars)
{
	GetCvars_handleString(get_cvars_s, get_cvars_f, cvar_cl_hat, "cl_magical_hax");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_nohats, "cl_nohats");
	return false;
}

MUTATOR_HOOKFUNCTION(hats, ClientDisconnect)
{
	self.hatentity = world;
	self.hatname = "";
	return false;
}

MUTATOR_HOOKFUNCTION(hats, MakePlayerObserver)
{
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
{
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
{
	self.bone_hat = gettagindex(self, "head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "tag_head");
	if(!self.bone_hat)
		self.bone_hat = gettagindex(self, "bip01 head");
	return false;
}

MUTATOR_HOOKFUNCTION(mod_hats, Skeleton_CheckModel)
{
	if(get_model_parameters_bone_head)
		self.bone_hat = gettagindex(self, get_model_parameters_bone_head);
	return false;
}

#endif
