float orig_random(entity this);
void CorpseThink(entity this);
.float motd_time;
.float motd_count;
.bool impaled;
//.float lightningmodel
.float exptime;
.float bounced;
.float silencer;

.vector finaldest, finalangle; 		//plat.qc stuff
.void(entity this) think1;
.float state;

.float delay;
.float wait;
.float lip;
.float speed;
.float sounds;

.string killtarget;

.int cnt;

.float attack_finished;

// TODO
void SUB_AttackFinished(entity this, float normal);
void SUB_CheckRefire(entity this, void(entity) thinkst);
bool visible(entity this, entity targ);


//=============================================================================

void SUB_UseTargets(entity this, entity actor, entity trigger);
void DelayThink(entity this)
{
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If this.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any this.message to the activator.

Removes all entities with a targetname that match this.killtarget,
and removes them, so some events can remove other triggers.

Search for(string)targetname in all entities that
match(string)this.target and call their .use function

==============================
*/
void SUB_UseTargets(entity this, entity actor, entity trigger)
{
//
// check for a delay
//
	if(this.delay)
	{
	// create a temp object to fire at a later time
		entity t = new(DelayedUse);
		t.nextthink = time + this.delay;
		setthink(t, DelayThink);
		t.enemy = actor;
		t.message = this.message;
		t.killtarget = this.killtarget;
		t.target = this.target;
		return;
	}
	
	
//
// print the message
//
	if(IS_PLAYER(actor) && this.message != "")
	{
		centerprint(actor, this.message);
		if(!this.noise)
			_sound(actor, CH_INFO, QUAKE_TALKSOUND, 1, ATTN_NORM);
	}

//
// kill the killtagets
//

	string s;
	s = this.killtarget;
	if (s != "")
	{
		for(entity t = NULL; (t = find(t, targetname, s)); )
			delete(t);
	}
	
//
// fire targets
//

	s = this.target;
	if(s && s != "")
	{
		for(entity t = NULL; (t = find(t, targetname, s)); )
		{
			if(t.use)
				t.use(t, actor, this);
		}
	}
}
