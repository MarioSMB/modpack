#ifdef SVQC
void sv_notice_join_think()
{
    //NextLevel();
    float argc = tokenizebyseparator(autocvar_sv_join_notices, "|");
    if(argc > 0)
    {
        float i; 
        for(i = argc - 1; i >= 0; --i)    
            sv_notice_to(self.owner, argv(i), autocvar_sv_join_notices_time, FALSE);
    }    
    remove(self);
}

void sv_notice_join()
{
    // to-do: make sv_join_notices support per-entry times
    if(autocvar_sv_join_notices == "")
        return;

    entity n = spawn();
    n.owner = self;
    n.think = sv_notice_join_think;
    n.nextthink = time + 1;    
}

void sv_notice_to(entity _to, string _notice, float _howlong, float _modal)
{
	msg_entity = _to;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_SVNOTICE);
	WriteString(MSG_ONE, _notice);
	WriteLong(MSG_ONE, _howlong);
	WriteByte(MSG_ONE, _modal);
}

void sv_notice_toall(string _notice, float _howlong, float _modal)
{
    entity _head;
    FOR_EACH_REALCLIENT(_head)
        sv_notice_to(_head, _notice, _howlong, _modal);
    
}

#endif // SVQC

#ifdef CSQC
void SUB_Remove()
{ remove(self); }

void cl_notice_read()
{
    entity _notice;
    //float _done;
    //float _modal;
    _notice = spawn();
    _notice.classname = "sv_notice";
    _notice.netname = strzone(ReadString());
    _notice.alpha = ReadLong() + time;
    _notice.skin = ReadByte();
}

float cl_notice_run()
{
    entity _notes;
    string _notice;
    float m = FALSE;
    
    _notes = findchain(classname, "sv_notice");
    if(!_notes)
        return FALSE;
    #define M1 30
    #define M2 10
    
    vector v1, v2 = '0 0 0', v3;
    v1 = '1 1 0' * M1;
    v2_x = vid_conwidth - (2 * M1);
    v2_y = vid_conheight - (2 * M1);
    
    drawfill(v1, v2, '0 0 0', 0.5, DRAWFLAG_NORMAL);
    v1 = '1 1 0' * (M1 + M2);
    v2_x = vid_conwidth - (2 * (M1 + M2));
    v2_y = vid_conheight - (2 * (M1 + M2));
    drawfill(v1, v2, '0.5 0.5 0.5', 0.5, DRAWFLAG_NORMAL);
    v3 = v1 + '10 10 0';
    
    #define OUT(s,z) drawcolorcodedstring(v3, s, '1 1 0' * z, 1, DRAWFLAG_NORMAL); v3_y += z + 4
    
    OUT(_("^1Server notices:"), 32);
    
    //drawcolorcodedstring(v1 + '5 5 0', "^1Server notices:", '32 32 0', 1, DRAWFLAG_NORMAL);
    while(_notes)
    {
   
        _notice = sprintf(_("^7%s (^3%d sec left)"), _notes.netname , rint(_notes.alpha - time));
        OUT(_notice, 16);

        if(_notes.skin) 
            m = TRUE;
        
        if(_notes.alpha <= time)
        {
            _notes.think = SUB_Remove;
            _notes.nextthink = time;
        }
        
        _notes = _notes.chain;        
    }
    
    #undef OUT
    #undef M1
    #undef M2
    
    return m;
}

#endif // CSQC
