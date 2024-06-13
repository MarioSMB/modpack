#ifdef SVQC

/*QUAKED info_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 Stuffs a command into the console to allow map designers
 to set server variables.

 "message" is the command to send to the console.
*/
spawnfunc(info_command)
{
	// TODO: this is extremely dangerous, see if maps actually use it and disable it otherwise
	if(this.message && this.message != "")
		localcmd(strcat("\n", MakeConsoleSafe(this.message), "\n"));
}

#endif
