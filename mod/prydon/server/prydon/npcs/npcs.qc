

void() npc =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	legacy_npc();

	if (self.classname == "npc")
		randomize_inventory(self);
	datacheck();	
	if (self.spawnflags & 1)
		if (music)
			if (!self.theme)
				self.theme = "music/boss.wav";
	if (!self.model)
		self.model = rq_npcmodel(floor(random() * 15));
	self.oldskin = self.skin;
	if (!self.noise)
		self.noise = "player/swing.wav";

	if (cache)
	{
		precache_model(self.model);
		if (self.bkup_model)
			precache_model(self.bkup_model);

		if (self.noise)
			precache_sound(self.noise);
		if (self.noise1)
			precache_sound(self.noise1);
		if (self.noise2)
			precache_sound(self.noise2);
		if (self.noise3)
			precache_sound(self.noise3);
		if (self.noise4)
			precache_sound(self.noise4);
		if (self.voice)
			precache_sound(self.voice);
		if (self.theme)
			precache_sound(self.theme);
	}
	setmodel(self, self.model);


	if (self.size_x > 100)
		setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	else
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	if (!self.netname)
		self.netname = rq_npcname(floor(random() * 256)) ;
	if (!self.ai)
		self.ai = AI_ROAM;

	self.owner = self;
	self.player = self;
	if (!self.max_health)
		self.max_health = 5;
	Restat();
	
	self.health = self.max_health;
//	if (netplay)
//		self.ai = self.ai - (self.ai & AI_ROAM); // no wandering in netplay
	if (self.wad)
		if (!(self.ai & AI_LUMP))
			self.ai = self.ai | AI_STAY_NEAR;
	if (!self.altaction)
		self.altaction = SP_FIGHT_MELEE;
	self.gotstuff 	= self.altaction;
	self.movetype	= MOVETYPE_STEP;
	self.solid	= SOLID_SLIDEBOX;
	self.takedamage	= DAMAGE_AIM;
	self.oldorigin	= self.origin;
	set_frames(self);
	if (!self.speed)
		self.speed = 1;
	self.die = PlayerDie;
	self.use = playertrigger;
	self.mana = self.max_mana;
	self.mana_regen = self.mana_regen + 5;
	if (self.message)
	{
		self.effects = self.effects | EF_SELECTABLE;
		self.action = opendialog;
	}
	else if (self.ai & (AI_HUNT_PLAYER | AI_FOLLOW))
		self.effects = self.effects | EF_SELECTABLE;
	AnimatePlayer();
};
