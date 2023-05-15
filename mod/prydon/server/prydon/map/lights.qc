void(string soundfile, float volume) doambient; // Definition from Ambient.qc

void() light =                       // Basic Light
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	remove(self);
}; 

void() light_fluoro =                // Light with hum ambient
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	doambient("ambience/fl_hum1.wav", 0.5); // Spawn Ambient hum sound
	remove(self);
};

void() light_fluorospark =           // Light with buzz ambient
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	doambient("ambience/buzz1.wav", 0.5); // Spawn ambient buzz sound
	remove(self);
}; 

void() light_torchere =
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);

	Precache_Set("progs/candlabr.mdl"); 
	makestatic(self);                       // Static entity. Never changes.

};

void() light_globe =                 // Light with visible globe
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	Precache_Set("progs/s_light.spr");      // Set model
	makestatic(self);                       // Static entity. Never changes.
};

void() light_torch_small_walltorch = // Light with visible wall torch
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	doambient("ambience/fire1.wav", 0.5); // Spawn fire ambient sound
	Precache_Set("progs/flame.mdl");        // Set model
	makestatic(self);                       // Static entity. Never changes.

};
                                      
void() light_flame_small_yellow =    // Light with small flame & fire sound
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	doambient("ambience/fire1.wav", 0.5); // Spawn fire ambient sound
	Precache_Set("progs/flame2.mdl");       // Set model
	makestatic(self);                       // Static entity. Never changes.

};

void() light_flame_large_yellow =    // Light with larger flame & fire sound
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	if (self.wad)
		lightstyle(self.style, self.wad);
	Precache_Set("progs/flame2.mdl");       // Set model
	self.frame = 1;                         // Switch to second frame (large)
	doambient("ambience/fire1.wav", 0.5); // Spawn fire ambient sound
	makestatic(self);                       // Static entity. Never changes.

};

void() light_flame_small_white =     // Light with small flame & fire sound
{
	if (CheckStory(self))
	{
		remove(self);
		return;
	}
	Precache_Set("progs/flame2.mdl");       // Set model
	doambient("ambience/fire1.wav", 0.5); // Spawn fire ambient sound
	makestatic(self);                       // Static entity. Never changes.

};

void() LightStyles_setup =
{
	 // Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
	
	lightstyle(0,"m");                                   // Style 0: Normal
	lightstyle(1,"mmnmmommommnonmmonqnmmo");             // Style 1: Flicker
	                                                     // Style 2: Slow Strong
	                                                     //          Pulse
	lightstyle(2,"abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(3,"mmmmmaaaaammmmmaaaaaabcdefgabcdefg");  // Style 3: Candle
	lightstyle(4,"mamamamamama");                        // Style 4: Fast Strobe
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");    // Style 5: Gentle Pulse
	lightstyle(6,"nmonqnmomnmomomno");                   // Style 6: Flicker 2
	lightstyle(7,"mmmaaaabcdefgmmmmaaaammmaamm");        // Style 7: Candle 2
	                                                     // Style 8: Candle 3
	lightstyle(8,"mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"); 
	lightstyle(9,"aaaaaaaazzzzzzzz");                    // Style 9: Slow Strobe
	lightstyle(10,"m");          // Style 10: Fluro
	                                                     // Style 11: Slow Pulse
	                                                     //           (no black)
	lightstyle(11,"abcdefghijklmnopqrrqponmlkjihgfedcba"); 
	
	// 12 sunlight
	// 13 night lamps
	// 14 moonlight (inverse sunlight)
};