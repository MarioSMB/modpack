#ifdef SVQC

bool set_pose_frame(entity this)
{
	int mystyle = this.style;
	switch(mystyle)
	{
		case 0: this.mdl = "progs/demon.mdl"; this.frame = 53; break;
		case 1: this.mdl = "progs/dog.mdl"; this.frame = 16; break;
		case 2: this.mdl = "progs/dog.mdl"; this.frame = 25; break;
		case 3: this.mdl = "progs/enforcer.mdl"; this.frame = 54; break;
		case 4: this.mdl = "progs/enforcer.mdl"; this.frame = 65; break;
		case 5: this.mdl = "progs/fish.mdl"; this.frame = 35; break;
		case 6: this.mdl = "progs/hknight.mdl"; this.frame = 53; break;
		case 7: this.mdl = "progs/hknight.mdl"; this.frame = 62; break;
		case 8: this.mdl = "progs/knight.mdl"; this.frame = 84; break;
		case 9: this.mdl = "progs/knight.mdl"; this.frame = 95; break;
		case 10: this.mdl = "progs/ogre.mdl"; this.frame = 125; break;
		case 11: this.mdl = "progs/ogre.mdl"; this.frame = 135; break;
		case 12: this.mdl = "progs/shalrath.mdl"; this.frame = 22; break;
		case 13: this.mdl = "progs/shambler.mdl"; this.frame = 93; break;
		case 14: this.mdl = "progs/soldier.mdl"; this.frame = 17; break;
		case 15: this.mdl = "progs/soldier.mdl"; this.frame = 28; break;
		case 16: this.mdl = "progs/wizard.mdl"; this.frame = 53; break;
		case 17: this.mdl = "progs/player.mdl"; this.frame = 49; break;
		case 18: this.mdl = "progs/player.mdl"; this.frame = 60; break;
		case 19: this.mdl = "progs/player.mdl"; this.frame = 69; break;
		case 20: this.mdl = "progs/player.mdl"; this.frame = 84; break;
		case 21: this.mdl = "progs/player.mdl"; this.frame = 102; break;
		case 22: this.mdl = "progs/player.mdl"; this.frame = 102; break;
		// Heads
    	case 23: this.mdl = "progs/h_demon.mdl"; break;
	    case 24: this.mdl = "progs/h_dog.mdl"; break;
	    case 25: this.mdl = "progs/h_guard.mdl"; break;
	    case 26: this.mdl = "progs/h_hellkn.mdl"; break;
	    case 27: this.mdl = "progs/h_knight.mdl"; break;
	    case 28: this.mdl = "progs/h_mega.mdl"; break;
	    case 29: this.mdl = "progs/h_ogre.mdl"; break;
	    case 30: this.mdl = "progs/h_player.mdl"; break;
	    case 31: this.mdl = "progs/h_shal.mdl"; break;
	    case 32: this.mdl = "progs/h_shams.mdl"; break;
	    case 33: this.mdl = "progs/h_wizard.mdl"; break;
	    case 34: this.mdl = "progs/h_zombie.mdl"; break;
	    // Gibs
	    case 35: this.mdl = "progs/gib1.mdl"; break;
	    case 36: this.mdl = "progs/gib2.mdl"; break;
	    case 37: this.mdl = "progs/gib3.mdl"; break;
	    default: return false; // invalid
	}
	return true;
}

spawnfunc(misc_corpse)
{
	if(!set_pose_frame(this))
	{
		objerror(this, "misc_corpse with invalid style.");
		return;
	}
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	precache_model(this.mdl);
	_setmodel(this, this.mdl);
}

#endif
