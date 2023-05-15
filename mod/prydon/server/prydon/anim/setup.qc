void(entity e) set_frames =
{
	local float w, r, d, a, p, c, j, t, b, da, cb;
	if (e.model == "progs/human.mdl")
	{
		// Chillo Model defaults
		self.player.attackscenes = 4;
		self.player.doubleattack = 7;
		self.player.cbowframes = 7;
		self.player.deathscenes = 3;
		self.player.dblattkscenes = 2;
		self.player.castscenes = 2;
		e.misc = e.misc | MISC_NO_SKINS;
	}
	if (!e.attackscenes)
		e.attackscenes = 1;
	if (!e.castscenes)
		e.castscenes = 1;
	if (!e.deathscenes)
		e.deathscenes = 1;
	if (!e.dblattkscenes)
		e.dblattkscenes = 1;
		
	if (!e.walkframes)
		e.walkframes = 6;
	if (!e.runframes)
		e.runframes = 6;
	if (!e.deathframes)
		e.deathframes = 6;
	if (!e.attackframes)
		e.attackframes = 7;
	if (!e.poseframes)
		e.poseframes = 6;
	if (!e.castframes)
		e.castframes = 8;
	if (!e.jumpframes)
		e.jumpframes = 6;
	if (!e.bowframes)
		e.bowframes = 7;
	if (!e.throwframes)
		e.throwframes = 4;
	// convert to a more usable form
	if (!e.hitframe)
		e.hitframe = e.attackframes - 2;
	e.attackframes = e.attackframes * e.attackscenes;
	e.deathframes = e.deathframes * e.deathscenes;
	e.castframes = e.castframes * e.castscenes;
	e.doubleattack = e.doubleattack * e.dblattkscenes;
	
	w = e.walkframes;
	r = w + e.runframes;
	d = r + e.deathframes;
	a = d + e.attackframes;
	p = a + e.poseframes;
	c = p + e.castframes;
	j = c + e.jumpframes;
	b = j + e.bowframes;
	t = b + e.throwframes;
	da = t + e.doubleattack;
	cb = da + e.cbowframes;
	
	e.walkframes = w;
	e.runframes = r;
	e.deathframes = d;
	e.attackframes = a;
	e.poseframes = p;
	e.castframes = c;
	e.jumpframes = j;
	e.bowframes = b;
	e.throwframes = t;
	e.doubleattack = da;
	e.cbowframes = cb;
	
	if (!e.finddist)
		e.finddist = 256;
};