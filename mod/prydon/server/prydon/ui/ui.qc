#include "ui.qh"

void hovertest(entity this, entity actor)
{
	WriteString(msg_mode, this.model);
}

entity ui_create(entity this, string spr, void(entity, entity, float) clickfunc, vector sz, vector org, entity p)
{
	entity e = spawn();
	_setmodel(e, spr);
	sz = sz * 0.5;
	e.mins = '0 0 0' - sz;
	e.maxs = sz;
	
	e.ui_clicked = clickfunc;
	e.ui_parent = p;
	
	if(p)
	{
		e.testorg = org + p.mins - e.mins;
		e.testorg_z = p.testorg_z - 2;
		
	}
	else
	{
		e.testorg = UI_TOPLEFT - e.mins + org;
		e.testorg_z = 2;
	}
	//e.testorg_z = 0;
	// find the last ui element
	entity m = this;
	
	while(m.ui)
		m = m.ui;
	m.ui = e;
	if(vmfc)
		e.viewmodelforclient = this;
		
	if(clickfunc)
		m.effects |= EF_SELECTABLE;
	e.ui_hover = hovertest;
	return e;
}

void ui_destroy(entity this, entity e)
{
	entity m = this;
	
	while(m.ui && m.ui != e)
	{
		 m = m.ui;
	}

	m.ui = e.ui;
	m = this.ui;
	while(m)
	{
		entity n = m.ui;
		if(m.ui_parent == e)
			ui_destroy(this, m);
		m = n;
	}

	delete(e);	
}

void ui_clear(entity this)
{
	entity e = this.ui;
	
	while(e)
	{
		entity s = e;
		e = e.ui;
		delete(s);
	}
	this.ui = NULL;
}

void ui_setposition(entity this, entity e, vector v)
{
	vector view;
	entity t = e.ui_parent;
	while(t)
	{
		v = v + e.ui_parent.testorg;
		t = t.ui_parent;
	}
		
	if(vmfc)
	{
		view_x = v.z + 96; view_y = v.x * -1; view_z = v.y * -1;
		setorigin(e, view);
		e.viewmodelforclient = this;
		//e.effects = e.effects | EF_NODEPTHTEST;

	}
	else
	{
		view = (v_forward * (96 + v.z)) + (v_right * v.x) + (v_up * (0 - v.y));
		traceline(this.origin, this.origin + view, true, this);
		setorigin(e, trace_endpos);
		e.scale = trace_fraction;
		e.angles = this.camera.angles;
	}
}

void ui_update(entity this)
{
	if(this.cursor)
		ui_setposition(this, this.cursor, this.cursorpos);
		
	entity e = this.ui;	
	while(e)
	{
		ui_setposition(this, e, e.testorg);
		e = e.ui;
	}
}

entity ui_over(entity this)
{
	entity defval = NULL;

	entity r = this.ui;
	while(r)
	{
		entity e = r.ui_parent;
		vector org = r.testorg;
		while(e)
		{
			org = org + e.testorg;
			e = e.ui_parent;
		}
		vector cabsmin = org + r.mins;
		vector cabsmax = org + r.maxs;
		if((this.cursorpos_x > cabsmin_x) && (this.cursorpos_x < cabsmax_x))
		{
			if((this.cursorpos_y > cabsmin_y) && (this.cursorpos_y < cabsmax_y))
			{
				if(r.ui_clicked)
					return r;
				defval = r;
			}
		}
		r = r.ui;
	}
	return defval;
}

vector inv_ui_to_inv(entity this, entity targ)
{
	entity e = this;
	if(e.ui_parent)
		e = e.ui_parent;
	vector v = targ.cursorpos - e.testorg - INV_GFX_START;
	if(v.x < 0)
		return INV_INVALID;
	if(v.y < 0)
		return INV_INVALID; // FIXME, what about the top slots?
	if(v.x > INV_PLAYERSIZE_x * INV_ICON_SIZE)
		return INV_INVALID;
	if(v.y > INV_PLAYERSIZE_y * INV_ICON_SIZE)
		return INV_INVALID;
	v = v * (1/INV_ICON_SIZE);
	v.x = floor(v.x);
	v.y = floor(v.y);
	v.z = 0;
	return v;
	
}

void buttontest(entity this, entity targ, float alt)
{
	bprint("Ha! it works!\n");
	this.testorg = targ.cursorpos - this.ui_parent.testorg;
}

#if 0
void ui_showinventory(entity this)
{
	vector v = '0 0 0';
	ui_clear();
	this.ui_panels = 1;
	entity inv = ui_create("gfx/inv.spr", func_null, '96 144 0','0 0 0', NULL);
	for(v.x = 0; v.x < INV_PLAYERSIZE_x; v.x = v.x + 1)
	{
		for (v.y = 0; v.y < INV_PLAYERSIZE_y; v.y = v.y + 1)
		{
			if(inv_getitem(this, v.x, v.y))
			{
				vector sz = stat_size;
				sz = sz * 11;
				sz.z = 0;
				ui_create(it_itemicon(stat_it), buttontest, sz, INV_GFX_START + v * INV_ICON_SIZE, inv);
			}
		}
	}
}
#endif
// quick bar  LARGE 266x54   SMALL 40 x 8
