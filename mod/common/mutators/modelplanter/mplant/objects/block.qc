void mplant_block_explode(entity this)
{
    RadiusDamage(this, this, 100, 0, 300, this, NULL, 500, DEATH_GENERIC.m_id, DMG_NOWEP, NULL);
    sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_MIN);
    Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
    mplant_block_delete(this);
}

void mplant_block_damage(entity this, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    if (cvar("g_mplant_explodingblocks"))
    {
        if (GetResourceAmount(this, RESOURCE_HEALTH) == 1) {
            this.effects = EF_FLAME;
            setthink(this, mplant_block_explode);
            this.nextthink = time + 0.25 + (random() * 2);
            SetResourceAmountExplicit(this, RESOURCE_HEALTH, 0);
            this.takedamage = DAMAGE_NO;
            this.event_damage = func_null;
            this.movetype = MOVETYPE_TOSS;
            this.velocity += vforce;
            return;
        }
    }
    mplant_block_delete(this);
}

void mplant_block_rotate(entity _what, vector _how_much, float _absolute)
{
    mplant_rotate(_what, _how_much, _absolute);
    _what.SendFlags |= MPSF_ANGLES;
    _what.SendFlags |= MPSF_SIZE;
}

void mplant_block_delete(entity _block)
{
    if (_block.mdl && _block.mdl != "")
        strunzone(_block.mdl);

    _block.mdl = "";

    delete(_block);
}

float mplant_block_setprop(entity _e, string _prop_name, string _prop_val)
{
    _prop_name = strtolower(_prop_name);

    if (_prop_name == "origin") {
        setorigin(_e, stov(_prop_val));
        mplant_block_rotate(_e, _e.angles, true);
        _e.SendFlags |= MPSF_ORIGIN;
        return true;
    }

    if (_prop_name == "model") {
        _SETMODEL(_e, _prop_val);
        _e.solid           = SOLID_BSP;
        _e.mplant_org_mins = _e.mins;
        _e.mplant_org_maxs = _e.maxs;
        mplant_block_rotate(_e, _e.angles, true);
        _e.SendFlags |= MPSF_MODEL;
        return true;
    }

    if (_prop_name == "angles") {
        _e.angles = stov(_prop_val);
        mplant_block_rotate(_e, _e.angles, true);
        return true;
    }

    if (_prop_name == "scale") {
        _e.scale = stof(_prop_val);
        mplant_block_rotate(_e, _e.angles, true);
        _e.SendFlags |= MPSF_SCALE;
        return true;
    }

    return false;
}

float mplant_block_write(entity _e, float _fh)
{
    fputs(_fh, sprintf("create %s\n", _e.mplant_object_type));
    if (_e.model) fputs(_fh, sprintf("\tmodel \"%s\"\n", _e.model));
    if (_e.mplant_object_uid != "") fputs(_fh, sprintf("\tuid \"%s\"\n", _e.mplant_object_uid));
    fputs(_fh, sprintf("\tangles \"%v\"\n", _e.angles));
    fputs(_fh, sprintf("\torigin \"%v\"\n", _e.origin));
    fputs(_fh, sprintf("\tscale \"%d\"\n", _e.scale));

    return true;
}

#define _MPLANT_CSQCOBJECTS
entity mplant_block_create(entity this, string _uid)
{
    entity _block = spawn();
    _block.angles					= this.mplant_cursorobject.angles;
    _block.scale					= 1;
    _block.mdlplant_object_flags	= MPOF_ISMPLANTOBJECT | MPOF_SAVEABLE | MPOF_SELECTABLE;
    _block.mplant_object_create		= mplant_block_create;
    _block.mplant_object_setprop	= mplant_block_setprop;
    _block.mplant_object_rotate		= mplant_block_rotate;
    _block.mplant_object_write		= mplant_block_write;
    _block.mplant_object_type		= "block";
    _block.mplant_object_uid		= _uid;
    _block.mplant_object_delete		= mplant_block_delete;

    //SetResourceAmountExplicit(_block, RESOURCE_HEALTH, 1);
    //_block.takedamage     = DAMAGE_YES;
    //_block.event_damage   = mplant_block_damage;

#ifdef _MPLANT_CSQCOBJECTS
    Net_LinkEntity(_block, true, 0, mplant_block_send);
#else
    _block.effects        = EF_SELECTABLE;
#endif
    return _block;
}
