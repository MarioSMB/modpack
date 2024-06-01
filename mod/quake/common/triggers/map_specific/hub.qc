#ifdef SVQC

spawnfunc(hub_trigger_changelevel)
{
    if(!MP_MG) { delete(this); return; }
    if((serverflags & SIGIL_ALL) != SIGIL_ALL)
    {
        delete(this);
        return;
    }

    spawnfunc_trigger_changelevel(this);
}

#endif
