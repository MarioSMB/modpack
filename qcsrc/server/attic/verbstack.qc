/// Some default stacks.
.entity verbs_idle;
.entity verbs_attack;
.entity verbs_move;
//.entity vchain;

/// This global gets set to the verb in question each time the stack manager calls verb_call
entity verb;
//.entity current_verb;
//.float verb_done;

/// Execure this verb
#define VCM_DO     0
/// Return the value of this verb. Return VS_CALL_REMOVE to delete it.
#define VCM_EVAL   1
/// This verb is beeing removed NOW (not sent when verb_call returns VS_CALL_REMOVE)
#define VCM_REMOVE 2

/// Verb callback
.float(float message) verb_call;

/// Points to this verb's stack.
.entity  verbstack;

/// Static value of this verb
.float verb_static_value;

/// verb_call returns this when a verb in not doable
#define VS_CALL_NO        0
/// verb_call(VCM_DO) returns this when a verb is executing
#define VS_CALL_YES_DOING -1
/// verb_call(VCM_DO) returns this when a verb did execure and is done
#define VS_CALL_YES_DONE  -2
/// verb_call(VCM_DO) returns this when a verb should be deleted by the stack manager
#define VS_CALL_REMOVE    -3

/*
void verbstack_updatechain(entity stack)
{
    entity vrb, v;
    if not (stack)
        return;

    dprint("verbstack_updatechain\n");

    vrb = findchainentity(verbstack, stack);
    if not (vrb)
    {
        stack.vchain = world;
        return;
    }

    stack.vchain = vrb;
    v = vrb;

    while(vrb)
    {
        vrb = vrb.chain;


    }
}

void verbstack_remove(entity vverb)
{
    entity vstack;
    dprint("verbstack_remove\n");

    vstack = verb.verbstack;
    remove(vverb);
    vverb.verbstack = world;
    verbstack_updatechain(vstack);

    //vverb.think = SUB_Remove;
    //vverb.nextthink = time;
}

void verbstack_thinkremove()
{
    dprint("verbstack_thinkremove\n");
    verbstack_remove(self);
}
*/

/**
    Push a new verb onto the specified stack. Set vrb_life to make it time-limited.
**/
entity verbstack_push(entity stack, float(float eval) vrb_call, float val_static, float vrb_life,entity verb_owner)
{
    entity vrb;

    if not(stack)
        return world;

    if not(vrb_call)
        return world;

    vrb                   = spawn();
    vrb.owner             = verb_owner;
    vrb.verbstack         = stack;
    vrb.verb_call         = vrb_call;
    vrb.verb_static_value = val_static;

    vrb.classname         = "verb";
    stack.classname       = "verbstack";

    if(vrb_life)
    {
        //vrb.think     = verbstack_thinkremove;
        vrb.think     = SUB_Remove;
        vrb.nextthink = time + vrb_life;
    }

    //verbstack_updatechain(stack);

    return vrb;
}

/**
    Find the best verb in this stack and execurte it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL or VCM_DO
**/
float verbstack_pop(entity stack)
{
    entity vrb, bestverb, oldself;
    float  value, bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    //vrb = stack.vchain;
    //dprint("owner:", stack.owner.classname, " vsn:", stack.classname,"\n");
    while(vrb)
    {
        //dprint("vn:", vrb.classname,"\n");
        verb  = vrb;
        vrb   = vrb.chain;
        self  = verb.owner;
        value = verb.verb_call(VCM_EVAL);

        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(verb);
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
        verb  = bestverb;
        self  = verb.owner;
        value = verb.verb_call(VCM_DO);

        if(value == VS_CALL_REMOVE)
            remove(bestverb);
    }

    self = oldself;

    return value;
}

float verbstack_popfifo(entity stack)
{
    entity oldself;
    float ret;

    oldself = self;
    verb = findentity(stack,verbstack,stack);
    if not (verb)
        ret = 0;
    else
    {
        self = verb.owner;
        ret = verb.verb_call(VCM_DO);

        if(ret == VS_CALL_REMOVE)
            remove(verb);
    }

    self = oldself;
    return ret;
}

/**
    Find the best verb in this stack and return it.
    ALso remove any verbs returning VS_CALL_REMOVE on VCM_EVAL.
**/
entity verbstack_pull(entity stack)
{
    entity vrb;
    entity bestverb, oldself;
    float  value, bestvalue;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        self = vrb.owner;

        verb  = vrb;
        vrb   = vrb.chain;
        value = verb.verb_call(VCM_EVAL);

        if(value < 0)
        {
            if(value == VS_CALL_REMOVE)
                remove(verb);
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

    self = oldself;

    return bestverb;
}

entity verbstack_pullfifo(entity stack)
{
    return findentity(stack,verbstack,stack);
}

/**
    Delete every verb on this stack, signaling them with VCM_REMOVE first.
**/
void verbstack_flush(entity stack)
{
    entity vrb, oldself;

    oldself = self;

    vrb = findchainentity(verbstack,stack);
    while(vrb)
    {
        self = vrb.owner;

        verb = vrb;
        vrb  = vrb.chain;
        verb.verb_call(VCM_REMOVE);
        remove(verb);
    }

    self = oldself;

    //stack.vchain = world;
}

void verbstack_doverb(entity vrb)
{
    float value;

    verb  = vrb;
    self  = verb.owner;
    value = verb.verb_call(VCM_DO);

    if(value == VS_CALL_REMOVE)
        remove(vrb);
}
