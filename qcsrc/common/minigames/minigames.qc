entity minigame_get_descriptor(string id)
{
	entity e;
	for ( e = minigame_descriptors; e != world; e = e.list_next )
		if ( e.netname == id )
			return e;
	return world;
}

// Get letter index of a tile name
float minigame_tile_letter(string id)
{
	return str2chr(substring(id,0,1),0)-'a';
}

// Get number index of a tile name
// Note: this is 0 based, useful for mathematical operations
// Note: Since the tile notation starts from the bottom left, 
//	you may want to do number_of_rows - what_this_function_returns or something
float minigame_tile_number(string id)
{
	return stof(substring(id,1,-1)) -1 ;
}

// Get relative position of the center of a given tile
vector minigame_tile_pos(string id, float rows, float columns)
{
	return eX*(minigame_tile_letter(id)+0.5)/columns + 
	       eY - eY*(minigame_tile_number(id)+0.5)/rows;
}

// Get a tile name from indices
string minigame_tile_buildname(float letter, float number)
{
	return strcat(chr2str('a'+letter),ftos(number+1));
}

// Get the id of a tile relative to the given one
string minigame_relative_tile(string start_id, float dx, float dy, float rows, float columns)
{
	float letter = minigame_tile_letter(start_id);
	float number = minigame_tile_number(start_id);
	letter = (letter+dx) % columns;
	number = (number+dy) % rows;
	if ( letter < 0 )
		letter = columns + letter;
	if ( number < 0 )
		number = rows + number;
	return minigame_tile_buildname(letter, number);
}

// Get tile name from a relative position (matches the tile covering a square area)
string minigame_tile_name(vector pos, float rows, float columns)
{
	if ( pos_x < 0 || pos_x > 1 || pos_y < 0 || pos_y > 1 )
		return ""; // no tile
		
	float letter = floor(pos_x * columns);
	float number = floor((1-pos_y) * rows);
	return minigame_tile_buildname(letter, number);
}

// Get the next team number (note: team numbers are between 1 and n_teams, inclusive)
float minigame_next_team(float curr_team, float n_teams)
{
	return curr_team % n_teams + 1;
}

// set send flags only when on server
// (for example in game logic which can be used both in client and server
void minigame_server_sendflags(entity ent, float mgflags)
{
	#ifdef SVQC
		ent.SendFlags |= mgflags;
	#endif
}

// Spawn linked entity on the server or local entity on the client
// This entity will be removed automatically when the minigame ends
entity msle_spawn(entity minigame_session, string class_name)
{
	entity e = spawn();
	e.classname = class_name;
	e.owner = minigame_session;
	e.minigame_autoclean = 1;
	#ifdef SVQC
		e.customizeentityforclient = minigame_CheckSend;
		Net_LinkEntity(e, FALSE, 0, minigame_SendEntity);
	#endif
	return e;
}

const float msle_base_id = 2;
float msle_id(string class_name)
{
	if ( class_name == "minigame" ) return 1;
	if ( class_name == "minigame_player" ) return 2;
	float i = msle_base_id;
#define MSLE(Name, Fields) i++; if ( class_name == #Name ) return i;
	MINIGAME_SIMPLELINKED_ENTITIES
#undef MSLE
	return 0;
}

string msle_classname(float id)
{
	if ( id == 1 ) return "minigame";
	if ( id == 2 ) return "minigame_player";
	float i = msle_base_id;
#define MSLE(Name, Fields) i++; if ( id == i ) return #Name;
	MINIGAME_SIMPLELINKED_ENTITIES
#undef MSLE
	return "";
}