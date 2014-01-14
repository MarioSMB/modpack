// spawner entity
// "classname" "target_spawn"
// "message" "fieldname value fieldname value ..."
// "spawnflags"
//   1 = call the spawn function
//   2 = trigger on map load

float target_spawn_initialized;
.void() target_spawn_spawnfunc;
float target_spawn_spawnfunc_field;
.entity target_spawn_activator;
.float target_spawn_id;
float target_spawn_count;

void target_spawn_helper_setmodel()
{
	setmodel(self, self.model);
}

void target_spawn_helper_setsize()
{
	setsize(self, self.mins, self.maxs);
}

void target_spawn_edit_entity(entity e, string msg, entity kt, entity t2, entity t3, entity t4, entity act)
{
	float i, n, valuefieldpos;
	string key, value, valuefield, valueoffset, valueoffsetrandom;
	entity valueent;
	vector data, data2;
	entity oldself;
	entity oldactivator;

	n = tokenize_console(msg);

	for(i = 0; i < n-1; i += 2)
	{
		key = argv(i);
		value = argv(i+1);
		if(key == "$")
		{
			data_x = -1;
			data_y = FIELD_STRING;
		}
		else
		{
			data = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", key)));
			if(data_y == 0) // undefined field, i.e., invalid type
			{
				print("target_spawn: invalid/unknown entity key ", key, " specified, ignored!\n");
				continue;
			}
		}
		if(substring(value, 0, 1) == "$")
		{
			value = substring(value, 1, strlen(value) - 1);
			if(substring(value, 0, 1) == "$")
			{
				// deferred replacement
				// do nothing
				// useful for creating target_spawns with this!
			}
			else
			{
				// replace me!
				valuefieldpos = strstrofs(value, "+", 0);
				valueoffset = "";
				if(valuefieldpos != -1)
				{
					valueoffset = substring(value, valuefieldpos + 1, strlen(value) - valuefieldpos - 1);
					value = substring(value, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(valueoffset, "+", 0);
				valueoffsetrandom = "";
				if(valuefieldpos != -1)
				{
					valueoffsetrandom = substring(valueoffset, valuefieldpos + 1, strlen(valueoffset) - valuefieldpos - 1);
					valueoffset = substring(valueoffset, 0, valuefieldpos);
				}

				valuefieldpos = strstrofs(value, ".", 0);
				valuefield = "";
				if(valuefieldpos != -1)
				{
					valuefield = substring(value, valuefieldpos + 1, strlen(value) - valuefieldpos - 1);
					value = substring(value, 0, valuefieldpos);
				}

				if(value == "self")
				{
					valueent = self;
					value = "";
				}
				else if(value == "activator")
				{
					valueent = act;
					value = "";
				}
				else if(value == "other")
				{
					valueent = other;
					value = "";
				}
				else if(value == "pusher")
				{
					if(time < act.pushltime)
						valueent = act.pusher;
					else
						valueent = world;
					value = "";
				}
				else if(value == "target")
				{
					valueent = e;
					value = "";
				}
				else if(value == "killtarget")
				{
					valueent = kt;
					value = "";
				}
				else if(value == "target2")
				{
					valueent = t2;
					value = "";
				}
				else if(value == "target3")
				{
					valueent = t3;
					value = "";
				}
				else if(value == "target4")
				{
					valueent = t4;
					value = "";
				}
				else if(value == "time")
				{
					valueent = world;
					value = ftos(time);
				}
				else
				{
					print("target_spawn: invalid/unknown variable replacement ", value, " specified, ignored!\n");
					continue;
				}

				if(valuefield == "")
				{
					if(value == "")
						value = ftos(num_for_edict(valueent));
				}
				else
				{
					if(value != "")
					{
						print("target_spawn: try to get a field of a non-entity, ignored!\n");
						continue;
					}
					data2 = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", valuefield)));
					if(data2_y == 0) // undefined field, i.e., invalid type
					{
						print("target_spawn: invalid/unknown entity key replacement ", valuefield, " specified, ignored!\n");
						continue;
					}
					value = getentityfieldstring(data2_x, valueent);
				}

				if(valueoffset != "")
				{
					switch(data_y)
					{
						case FIELD_STRING:
							value = strcat(value, valueoffset);
							break;
						case FIELD_FLOAT:
							value = ftos(stof(value) + stof(valueoffset));
							break;
						case FIELD_VECTOR:
							value = vtos(stov(value) + stov(valueoffset));
							break;
						default:
							print("target_spawn: only string, float and vector fields can do calculations, calculation ignored!\n");
							break;
					}
				}

				if(valueoffsetrandom != "")
				{
					switch(data_y)
					{
						case FIELD_FLOAT:
							value = ftos(stof(value) + random() * stof(valueoffsetrandom));
							break;
						case FIELD_VECTOR:
							data2 = stov(valueoffsetrandom);
							value = vtos(stov(value) + random() * data2_x * '1 0 0' + random() * data2_y * '0 1 0' + random() * data2_z * '0 0 1');
							break;
						default:
							print("target_spawn: only float and vector fields can do random calculations, calculation ignored!\n");
							break;
					}
				}
			}
		}
		if(key == "$")
		{
			if(substring(value, 0, 1) == "_")
				value = strcat("target_spawn_helper", value);
			putentityfieldstring(target_spawn_spawnfunc_field, e, value);

			oldself = self;
			oldactivator = activator;

			self = e;
			activator = act;

			self.target_spawn_spawnfunc();

			self = oldself;
			activator = oldactivator;
		}
		else
		{
			if(data_y == FIELD_VECTOR)
				value = strreplace("'", "", value); // why?!?
			putentityfieldstring(data_x, e, value);
		}
	}
}

void target_spawn_useon(entity e)
{
	self.target_spawn_activator = activator;
	target_spawn_edit_entity(
		e,
		self.message,
		find(world, targetname, self.killtarget),
		find(world, targetname, self.target2),
		find(world, targetname, self.target3),
		find(world, targetname, self.target4),
		activator
	);
}

float target_spawn_cancreate()
{
	float c;
	entity e;

	c = self.count;
	if(c == 0) // no limit?
		return 1;

	++c; // increase count to not include MYSELF
	for(e = world; (e = findfloat(e, target_spawn_id, self.target_spawn_id)); --c)
		;

	// if c now is 0, we have AT LEAST the given count (maybe more), so don't spawn any more
	if(c == 0)
		return 0;
	return 1;
}

void target_spawn_use()
{
	entity e;

	if(self.target == "")
	{
		// spawn new entity
		if(!target_spawn_cancreate())
			return;
		e = spawn();
		target_spawn_useon(e);
		e.target_spawn_id = self.target_spawn_id;
	}
	else if(self.target == "*activator")
	{
		// edit entity
		if(activator)
			target_spawn_useon(activator);
	}
	else
	{
		// edit entity
		for(e = world; (e = find(e, targetname, self.target)); )
			target_spawn_useon(e);
	}
}

void target_spawn_spawnfirst()
{
	activator = self.target_spawn_activator;
	if(self.spawnflags & 2)
		target_spawn_use();
}

void initialize_field_db()
{
	if(!target_spawn_initialized)
	{
		float n, i;
		string fn;
		vector prev, new;
		float ft;

		n = numentityfields();
		for(i = 0; i < n; ++i)
		{
			fn = entityfieldname(i);
			ft = entityfieldtype(i);
			new = i * '1 0 0' + ft * '0 1 0' + '0 0 1';
			prev = stov(db_get(TemporaryDB, strcat("/target_spawn/field/", fn)));
			if(prev_y == 0)
			{
				db_put(TemporaryDB, strcat("/target_spawn/field/", fn), vtos(new));
				if(fn == "target_spawn_spawnfunc")
					target_spawn_spawnfunc_field = i;
			}
		}

		target_spawn_initialized = 1;
	}
}

void spawnfunc_target_spawn()
{
	initialize_field_db();
	self.use = target_spawn_use;
	self.message = strzone(strreplace("'", "\"", self.message));
	self.target_spawn_id = ++target_spawn_count;
	InitializeEntity(self, target_spawn_spawnfirst, INITPRIO_LAST);
}


void trigger_relay_if_use()
{
	float n;
	n = self.count;

	// TODO make this generic AND faster than nextent()ing through all, if somehow possible
	n = (cvar_string(self.netname) == cvar_string(self.message));
	if(self.spawnflags & 1)
		n = !n;

	if(n)
		SUB_UseTargets();
}

void spawnfunc_trigger_relay_if()
{
	self.use = trigger_relay_if_use;
}
