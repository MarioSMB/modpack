#ifdef SVQC

/// Some default stacks.
.entity verbs_idle;
.entity verbs_attack;
.entity verbs_move;
//.entity vchain;

//.entity current_verb;
//.float verb_done;

/// Execure this verb
const int VCM_DO = 0;
/// Return the value of this verb. Return VS_CALL_REMOVE to delete it.
const int VCM_EVAL = 1;
/// This verb is beeing removed NOW (not sent when verb_call returns VS_CALL_REMOVE)
const int VCM_REMOVE = 2;

/// Verb callback
.int(entity verb, entity own, int msg) verb_call;

/// Points to this verb's stack.
.entity  verbstack;

/// Static value of this verb
.float verb_static_value;

const int VS_EBASE_LOW     = 100;
const int VS_EBASE_NORMAL  = 500;
const int VS_EBASE_HIGH    = 1000;
const int VS_EBASE_NUDGE   = 10;
const int VS_EBASE_BUMP    = 50;
/// verb_call(VCM_EVAL) returns this when a verb must be executed
const int VS_EBASE_MODAL   = 10000;

/// verb_call returns this when a verb in not doable
const int VS_CALL_NO       = 0;
/// verb_call(VCM_DO) returns this when a verb is executing
const int VS_CALL_YES_DOING = -1;
/// verb_call(VCM_DO) returns this when a verb did execure and is done
const int VS_CALL_YES_DONE  = -2;
/// verb_call(VCM_DO) returns this when a verb should be deleted by the stack manager
const int VS_CALL_REMOVE    = -3;
/// Unknown / unexspected message or bad input data
const int VS_CALL_WTF       = -100;

/**
    Push a new verb onto the specified stack. Set vrb_life to make it time-limited.
**/
entity verbstack_push(entity stack, float(entity, entity, int) vrb_call, float val_static, float vrb_life, entity verb_owner)
{
    entity vrb;

    if(!stack)
        return NULL;

    if(!vrb_call)
        return NULL;

    vrb                   = spawn();
    vrb.owner             = verb_owner;
    vrb.verbstack         = stack;
    vrb.verb_call         = vrb_call;
    vrb.verb_static_value = val_static;

    vrb.classname         = "verb";
    stack.classname       = "verbstack";

    if(vrb_life)
    {
        setthink(vrb, SUB_Remove);
        vrb.nextthink = time + vrb_life;
    }

    //verbstack_updatechain(stack);

    return vrb;
}

/**
    Find the best verb in this stack and execurte it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL or VCM_DO
**/
int verbstack_pop(entity stack)
{
    entity bestverb = NULL;
    int value = 0, bestvalue = 0;

    entity vrb = findchainentity(verbstack,stack);
    //vrb = stack.vchain;
    //dprint("owner:", stack.owner.classname, " vsn:", stack.classname,"\n");
    while(vrb)
    {
        //dprint("vn:", vrb.classname,"\n");
        entity verb  = vrb;
        vrb   = vrb.chain;
        value = verb.verb_call(verb, verb.owner, VCM_EVAL);

        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                delete(verb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb  = verb;
                bestvalue = value;
            }
        }
    }

    if(bestverb)
    {
        entity theverb  = bestverb;
        value = theverb.verb_call(theverb, theverb.owner, VCM_DO);

        if(value == VS_CALL_REMOVE)
            delete(bestverb);
    }

    return value;
}

/**
    Find the best verb in this stack and return it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL.
**/
entity verbstack_pull(entity stack)
{
    entity bestverb = NULL;
    int value = 0, bestvalue = 0;

    entity vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        entity verb = vrb;
        vrb = vrb.chain;
        value = verb.verb_call(verb, verb.owner, VCM_EVAL);

        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                delete(verb);
        }
        else
        {
            if(value > bestvalue)
            {
                bestverb = verb;
                bestvalue = value;
            }
        }
    }

    return bestverb;
}

/**
    Delete every verb on this stack, signaling them with VCM_REMOVE first.
**/
void verbstack_flush(entity stack)
{
    entity vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        entity verb = vrb;
        vrb  = vrb.chain;
        verb.verb_call(verb, verb.owner, VCM_REMOVE);
        delete(verb);
    }

    //stack.vchain = NULL;
}

void verbstack_doverb(entity vrb)
{
    int value = vrb.verb_call(vrb, vrb.owner, VCM_DO);

    if(value == VS_CALL_REMOVE)
        delete(vrb);
}

#endif
