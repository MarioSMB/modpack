


vector UI_TOPLEFT = '-96 -72 0';

void() hovertest =
{
	WriteString(msg_mode, trace_ent.model);
};

entity(string spr, void(float alt) clickfunc, vector sz, vector org, entity p) ui_create =
{
	local entity e, m;
	
	e = spawn();
	setmodel(e, spr);
	sz = sz * 0.5;
	e.mins = '0 0 0' - sz;
	e.maxs = sz;
	
	e.ui_clicked = clickfunc;
	e.ui_parent = p;
	
	if (p)
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
	m = self;
	
	while(m.ui)
		m = m.ui;
	m.ui = e;
	if (vmfc)
		e.viewmodelforclient = self;
		
	if (clickfunc)
		m.effects = m.effects | EF_SELECTABLE;
	e.ui_hover = hovertest;
	return e;

};


void(entity e) ui_destroy =
{
	local entity m, n;
	m = self;
	
	while (m.ui && m.ui != e)
	{
		 m = m.ui;
	}

	m.ui = e.ui;
	m = self.ui;
	while (m)
	{
		n = m.ui;
		if (m.ui_parent == e)
			ui_destroy(m);
		m = n;
	}

	remove(e);	
};

void() ui_clear =
{
	local entity e, s;
	
	e = self.ui;
	
	while (e)
	{
		s = e;
		e = e.ui;
		remove(s);
	}
	self.ui = world;
};
void(entity e, vector v) ui_setposition =
{
	local vector view;
	local entity t;
	
	t = e.ui_parent;
	while(t)
	{
		v = v + e.ui_parent.testorg;
		t = t.ui_parent;
	}
		
	if (vmfc)
	{
		view_x = v_z + 96; view_y = v_x * -1; view_z = v_y * -1;
		setorigin(e, view);
		e.viewmodelforclient = self;
		//e.effects = e.effects | EF_NODEPTHTEST;

	}
	else
	{
		view = (v_forward * (96 + v_z)) + (v_right * v_x) + (v_up * (0 - v_y));
		traceline(self.origin, self.origin + view, TRUE, self);
		setorigin(e, trace_endpos);
		e.scale = trace_fraction;
		e.angles = self.camera.angles;
	}
};
void() ui_update =
{
	local entity e;
	if (self.cursor)
		ui_setposition(self.cursor, self.cursorpos);
		
	e = self.ui;	
	while(e)
	{
		ui_setposition(e, e.testorg);
		e = e.ui;
	}
};
entity() ui_over =
{
	vector cabsmin, cabsmax, org;
	local entity e, r, default;
	default = world;

	r = self.ui;
	while(r)
	{

		e = r.ui_parent;
		org = r.testorg;
		while (e)
		{
			org = org + e.testorg;
			e = e.ui_parent;
		}
		cabsmin = org + r.mins;
		cabsmax = org + r.maxs;
		if ((self.cursorpos_x > cabsmin_x) && (self.cursorpos_x < cabsmax_x))
		{
			if ((self.cursorpos_y > cabsmin_y) && (self.cursorpos_y < cabsmax_y))
			{
				if (r.ui_clicked)
					return r;
				default = r;
			}
		}
		r = r.ui;
	}
	return default;
};
vector() inv_ui_to_inv =
{
	local entity e;
	local vector v;
	e = self;
	if (e.ui_parent)
		e = e.ui_parent;
	v = other.cursorpos - e.testorg - INV_GFX_START;
	if (v_x < 0)
		return INV_INVALID;
	if (v_y < 0)
		return INV_INVALID; // FIXME, what about the top slots?
	if (v_x > INV_PLAYERSIZE_x * INV_ICON_SIZE)
		return INV_INVALID;
	if (v_y > INV_PLAYERSIZE_y * INV_ICON_SIZE)
		return INV_INVALID;
	v = v * (1/INV_ICON_SIZE);
	v_x = floor(v_x);
	v_y = floor(v_y);
	v_z = 0;
	return v;
	
};
void(float alt) buttontest =
{
	bprint("Ha! it works!\n");
	self.testorg = other.cursorpos - self.ui_parent.testorg;
	
};

void() ui_showinventory =
{
	local entity inv;
	local vector v, sz;
	ui_clear();
	self.ui_panels = 1;
	inv = ui_create("gfx/inv.spr", nullfunc, '96 144 0','0 0 0', world);
	for(v_x = 0; v_x < INV_PLAYERSIZE_x; v_x = v_x + 1)
	{
		for (v_y = 0; v_y < INV_PLAYERSIZE_y; v_y = v_y + 1)
		{
			if (inv_getitem(self, v_x, v_y))
			{
				sz = stat_size;
				sz = sz * 11;
				sz_z = 0;
				ui_create(it_itemicon(stat_it), buttontest, sz, INV_GFX_START + v * INV_ICON_SIZE, inv);
			}
		}
	}
};
// quick bar  LARGE 266x54   SMALL 40 x 8
