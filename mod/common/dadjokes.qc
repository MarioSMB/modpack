//FEATURE: Dad jokes on join, can be enabled with sv_dadjokes 1

REPLICATE_INIT(bool, cvar_cl_nodad);
REPLICATE(cvar_cl_nodad, bool, "cl_nodad");

#ifdef SVQC
AUTOCVAR(sv_dadjokes, bool, false, "Provide players with wisdom when joining");
AUTOCVAR(sv_dadjokes_server, string, "", "Pulls dad jokes from this website if provided, otherwise an internal list is used");
//AUTOCVAR(sv_dadjokes_onjoin, bool, true, "Sends players a dad joke when they get back with milk");

int dadjokes_buffer = -1;

void dadjokes_internal(entity this);

void dadjokes_process_url(entity this, entity fh)
{
	RandomSelection_Init();

	string s;
	while((s = url_fgets(fh)))
	{
		// should just be a dad joke, but who knows... pick a random one if multiple
		RandomSelection_AddString(s, 1, 1);
	}

	if(RandomSelection_chosen_string)
		Send_Notification(NOTIF_ONE_ONLY, this, MSG_INFO, INFO_DADJOKE, RandomSelection_chosen_string);

	url_fclose(fh);
}

void dadjokes_url_onget(entity fh, entity this, int status)
{
	switch(status)
	{
		case URL_READY_CLOSED:
		{
			break;
		}
		case URL_READY_ERROR:
		{
			//sprint(this, "No dad jokes for you\n");
			dadjokes_internal(this); // fall back to internal version
			break;
		}
		case URL_READY_CANREAD:
		{
			dadjokes_process_url(this, fh);
			break;
		}
		default:
		{
			break;
		}
	}
}

void dadjokes_openurl(entity this, string url)
{
	url_single_fopen(url, FILE_READ, dadjokes_url_onget, this);
}

void dadjokes_internal(entity this)
{
	RandomSelection_Init();
	for(int j = 0; j < dadjokes_buffer; ++j)
	{
		string joke = bufstr_get(dadjokes_buffer, j);
		RandomSelection_AddString(joke, 1, 1);
	}

	if(RandomSelection_chosen_string)
		Send_Notification(NOTIF_ONE_ONLY, this, MSG_INFO, INFO_DADJOKE, RandomSelection_chosen_string);
}

void dadjokes_AddPlayer(entity this)
{
	if(!autocvar_sv_dadjokes)
		return;
	if(!IS_REAL_CLIENT(this))
		return; // NOTE: bots shouldn't receive cvars anyway

	if(this.cvar_cl_nodad)
		return;

	if(autocvar_sv_dadjokes_server != "")
	{
		dadjokes_openurl(this, autocvar_sv_dadjokes_server);
		return;
	}

	dadjokes_internal(this);
}

// do it on cvar apply so that we can tell if the player disabled them
REPLICATE_APPLYCHANGE("cl_nodad", { dadjokes_AddPlayer(this); });

// internal dadabase
STATIC_INIT(dadjokes)
{
	int buf = buf_create();
	if(buf < 0)
	{
		// better luck with mom
		return;
	}

	int j = 0;

#define DADJOKE(s) bufstr_set(buf, j++, s)

	DADJOKE("How do you know when you are going to drown in milk? When its past your eyes!");
	DADJOKE("Milk is also the fastest liquid on earth – its pasteurized before you even see it");
	DADJOKE("A steak pun is a rare medium well done.");
	DADJOKE("Did you hear that the police have a warrant out on a midget psychic ripping people off? It reads \"Small medium at large.\"");
	DADJOKE("A panda walks into a bar and says to the bartender \"I'll have a Scotch and . . . . . . . . . . . . . . Coke thank you\".");
	DADJOKE("\"Sure thing\" the bartender replies and asks \"but what's with the big pause?\"");
	DADJOKE("The panda holds up his hands and says \"I was born with them\"");
	DADJOKE("A man was caught stealing in a supermarket today while balanced on the shoulders of a couple of vampires. He was charged with shoplifting on two counts.");
	DADJOKE("I heard there was a new store called Moderation. They have everything there");
	DADJOKE("Our wedding was so beautiful, even the cake was in tiers.");
	DADJOKE("Did you hear about the new restaurant on the moon? The food is great, but there's just no atmosphere.");
	DADJOKE("I went to a book store and asked the saleswoman where the Self Help section was, she said if she told me it would defeat the purpose.");
	DADJOKE("What did the mountain climber name his son? Cliff.");
	DADJOKE("I was thinking about moving to Moscow but there is no point Russian into things.");
	DADJOKE("My New Years resolution is to stop leaving things so late.");
	DADJOKE("If you're struggling to think of what to get someone for Christmas. Get them a fridge and watch their face light up when they open it.");
	DADJOKE("\"What's ET short for? Because he's only got little legs.\"");
	DADJOKE("People are making apocalypse jokes like there's no tomorrow.");
	DADJOKE("Why do crabs never give to charity? Because they're shellfish.");
	DADJOKE("What do you call an Argentinian with a rubber toe? Roberto");
	DADJOKE("What do you call a Mexican man leaving the hospital? Manuel");
	DADJOKE("I cut my finger chopping cheese, but I think that I may have grater problems.");
	DADJOKE("Today a girl said she recognized me from vegetarian club, but I'm sure I've never met herbivore.");
	DADJOKE("I went to the doctor today and he told me I had type A blood but it was a type O.");
	DADJOKE("When you have a bladder infection, urine trouble.");
	DADJOKE("My cat was just sick on the carpet, I don't think it's feline well.");
	DADJOKE("I dreamed about drowning in an ocean made out of orange soda last night. It took me a while to work out it was just a Fanta sea.");
	DADJOKE("Without geometry life is pointless.");
	DADJOKE("A termite walks into a bar and asks \"Is the bar tender here?\"");
	DADJOKE("What's Forest Gump's Facebook password? 1forest1");
	DADJOKE("I gave all my dead batteries away today... Free of charge.");
	DADJOKE("I needed a password eight characters long so I picked Snow White and the Seven Dwarfs.");
	DADJOKE("I am terrified of elevators. I'm going to start taking steps to avoid them.");
	DADJOKE("Tea is for mugs.");
	DADJOKE("What's the advantage of living in Switzerland? Well, the flag is a big plus.");
	DADJOKE("Why did the octopus beat the shark in a fight? Because it was well armed.");
	DADJOKE("A red and a blue ship have just collided in the Caribbean. Apparently the survivors are marooned.");
	DADJOKE("I've deleted the phone numbers of all the Germans I know from my mobile phone. Now it's Hans free.");
	DADJOKE("Last night me and my girlfriend watched three DVDs back to back. Luckily I was the one facing the TV.");
	DADJOKE("How do you organize a space party? You planet.");
	DADJOKE("How much does a hipster weigh? An instagram.");
	DADJOKE("What do you call a group of killer whales playing instruments? An Orca-stra.");
	DADJOKE("Why was the big cat disqualified from the race? Because it was a cheetah.");
	DADJOKE("A man walked in to a bar with some asphalt on his arm. He said \"Two beers please, one for me and one for the road.\"");
	DADJOKE("Just watched a documentary about beavers... It was the best damn program I've ever seen.");
	DADJOKE("Breaking news! Energizer Bunny arrested – charged with battery.");
	DADJOKE("Conjunctivitis.com – now that's a site for sore eyes.");
	DADJOKE("A Sandwich walks into a bar, the bartender says \"Sorry, we don't serve food here\"");
	DADJOKE("\"Doctor, I've broken my arm in several places\" Doctor \"Well don't go to those places.\"");
	DADJOKE("I'm on a whiskey diet. I've lost three days already.");
	DADJOKE("I fear for the calendar, it's days are numbered.");
	DADJOKE("There's a new type of broom out, it's sweeping the nation.");
	DADJOKE("Atheism is a non-prophet organisation.");
	DADJOKE("Slept like a log last night ... woke up in the fireplace.");
	DADJOKE("What did the fish say when it swam into a wall? Damn!");
	DADJOKE("They laughed when I said I wanted to be a comedian – they're not laughing now.");
	DADJOKE("What cheese can never be yours? Nacho cheese.");
	DADJOKE("A police officer caught two kids playing with a firework and a car battery. He charged one and let the other one off.");
	DADJOKE("Velcro... What a rip-off.");
	DADJOKE("I'm reading a book on the history of glue – can't put it down.");
	DADJOKE("Where does Napoleon keep his armies? In his sleevies.");
	DADJOKE("I went to the zoo the other day, there was only one dog in it. It was a shitzu.");
	DADJOKE("Why can't you hear a pterodactyl go to the bathroom? The p is silent.");
	DADJOKE("Q: What's 50 Cent's name in Zimbabwe? A: 400 Million Dollars.");
	DADJOKE("\"My Dog has no nose.\" \"How does he smell?\" \"Awful\"");
	DADJOKE("What do you call a cow with no legs? Ground beef.");
	DADJOKE("What did the Buffalo say to his little boy when he dropped him off at school? Bison.");
	DADJOKE("So a duck walks into a pharmacy and says \"Give me some chap-stick... and put it on my bill\"");
	DADJOKE("Why did the scarecrow win an award? Because he was outstanding in his field.");
	DADJOKE("Why did the girl smear peanut butter on the road? To go with the traffic jam.");
	DADJOKE("Why does a chicken coop only have two doors? Because if it had four doors it would be a chicken sedan.");
	DADJOKE("Why don't seagulls fly over the bay? Because then they'd be bay-gulls!");
	DADJOKE("What do you call a fly without wings? A walk.");
	DADJOKE("What do you do when a blonde throws a grenade at you? Pull the pin and throw it back.");
	DADJOKE("What's brown and sounds like a bell? Dung!");
	DADJOKE("How do you make a hankie dance? Put a little boogie in it.");
	DADJOKE("Where does batman go to the bathroom? The batroom.");
	DADJOKE("What's the difference between an African elephant and an Indian elephant? About 5000 miles.");
	DADJOKE("Two muffins were sitting in an oven, and the first looks over to the second, and says, \"man, it's really hot in here\". The second looks over at the first with a surprised look, and answers, \"WHOA, a talking muffin!\"");
	DADJOKE("A man walks into a bar and orders helicopter flavor chips. The barman replies \"sorry mate we only do plain\"");
	DADJOKE(" Sgt.: Commissar! Commissar! The troops are revolting! Commissar: Well, you're pretty repulsive yourself.");
	DADJOKE("What do you call a sheep with no legs? A cloud.");
	DADJOKE("I knew i shouldn't have ate that seafood. Because now i'm feeling a little... Eel");
	DADJOKE("What did the late tomato say to the early tomato? I'll ketch up");
	DADJOKE("What did the 0 say to the 8? Nice belt.");
	DADJOKE("Why didn't the skeleton cross the road? Because he had no guts.");
	DADJOKE("Why don't skeletons ever go trick or treating? Because they have nobody to go with.");
	DADJOKE("Why do scuba divers fall backwards into the water? Because if they fell forwards they'd still be in the boat.");
	DADJOKE("Have you ever heard of a music group called Cellophane? They mostly wrap.");
	DADJOKE("What kind of magic do cows believe in? MOODOO.");
	DADJOKE("Wife: Honey I'm pregnant. Me: Well.... what do we do now? Wife: Well, I guess we should go to a baby doctor. Me: Hm.. I think I'd be a lot more comfortable going to an adult doctor.");
	DADJOKE("At what time does the soldier go to the dentist? 1430.");
	DADJOKE("\"Hold on, I have something in my shoe\"  \"I'm pretty sure it's a foot\"");
	DADJOKE("Why does it take longer to get from 1st to 2nd base, than it does to get from 2nd to 3rd base? Because there's a Shortstop in between!");
	DADJOKE("Dad I'm hungry' ... Hi hungry I'm dad");
	DADJOKE("When phone ringing Dad says 'If it's for me don't answer it.'");
	DADJOKE("Put the cat out ... I didn't realize it was on fire");
	DADJOKE("Where's the bin? Dad: I haven't been anywhere!");
	DADJOKE("Can I watch the TV? Dad: Yes, but don't turn it on.");
	DADJOKE("When Dad drops a pea off of his plate 'oh dear I've pee'd on the table!'");
	DADJOKE("I've been addicted to cold turkey for 2 years. I keep telling people I'm trying to quit cold turkey but nobody is taking me seriously.");
	DADJOKE("Old yachtsmen don't die... They just keel over.");
	DADJOKE("3.14% of sailors are pi-rates.");
	DADJOKE("Bad at golf? Join the club.");
	DADJOKE("I just ate a frozen apple. Hardcore.");
	DADJOKE("Have you met my friend Annette? She's married to a fisherman.");
	DADJOKE("Why is Irish whiskey triple distilled? To be sure, to be sure, to be sure.");
	DADJOKE("I just read a book about Stockholm syndrome. It was pretty bad at first, but by the end I liked it.");
	DADJOKE("RIP boiled water. You will be mist.");
	DADJOKE("Archaeology really is a career in ruins...");
	DADJOKE("I don't trust stairs. They're always up to something.");
	DADJOKE("If you want a job in the moisturiser industry, the best advice I can give is to apply daily.");
	DADJOKE("A big cat escaped it's cage at the zoo yesterday. If I saw that I'd puma pants.");
	DADJOKE("My Czech mate is surprisingly bad at chess.");
	DADJOKE("Why are Lada's so bad? Because the keep Stalin.");
	DADJOKE("What do you get hanging off banana trees? Sore arms.");
	DADJOKE("I made my wife a cocktail with fairy liquid in it.... She was foaming at the mouth when she tasted it.");
	DADJOKE("What do you call a fat psychic? A four-chin teller.");
	DADJOKE("Found out I was colour blind the other day... That one came right out the purple.");
	DADJOKE("I hate perforated lines, they're tearable.");
	DADJOKE("A man tried to sell me a coffin today... I told him that's the last thing I need.");
	DADJOKE("Whenever I want to start eating healthy, a chocolate bar looks at me and Snickers.");
	DADJOKE("Don't kiss your wife with a runny nose. You might think it's funny, but it's snot.");
	DADJOKE("My friend keeps telling me I'm in the closet. I just say it's Narnia business. @WillFerreI");
	DADJOKE("I burnt my Hawaiian pizza last night... I should've put it on aloha setting.");
	DADJOKE("Dad: Where can I get a potato clock? Son: Why a potato clock?!? Dad: I've got a new job and my boss said I need to get-a-potato-clock");
	DADJOKE("My son asked me to stop singing oasis songs in public. I said maybe.");
	DADJOKE("When my wife told me to stop impersonating a flamingo I had to put my foot down.");
	DADJOKE("What's the difference between a hippo and a zippo? One is really heavy, the other is a little lighter.");
	DADJOKE("To the man in the wheelchair that stole my camouflage jacket... You can hide but you can't run.");
	DADJOKE("They don't watch the flintstones in Dubai. But Abu Dhabi do.");
	DADJOKE("Lone Ranger sees Tonto riding with a dustbin. LR: \"Where are you going Tonto?\" T: \"to-the-dump-to-the dump-to-the-dump-dump dump...\"");
	DADJOKE("Why can't you hear a pterodactyl using the bathroom? Because the P is silent");
	DADJOKE("Happy Father's Day! Did you hear about the crazy Mexican train thief? He had loco motives");
	DADJOKE("Singing in the shower is all fun and games until you get shampoo in your mouth.... Then it's a soap opera");
	DADJOKE("The rotation of earth really makes my day.");
	DADJOKE("You can't run through a camp site. You can only ran, because it's past tents.");
	DADJOKE("\"Does this uniform make me look fat\" - insecurity guard");
	DADJOKE("How do you tell the difference between a crocodile and an alligator? You will see one later and one in a while.");
	DADJOKE("I told my wife she drew her eyebrows too high. She seemed surprised.");
	DADJOKE("Why do trees seem suspicious on sunny days? Dunno, they're just a bit shady.");
	DADJOKE("You know what they say about cliffhangers...");
	DADJOKE("Want to hear a joke about construction? Nah, I'm still working on it.");
	DADJOKE("Ever noticed that glass tastes like blood?");
	DADJOKE("A classic from who's line is it anyway.");
	DADJOKE("You heard the rumor going around about butter? Nevermind, I shouldn't spread it.");
	DADJOKE("I have the heart of a lion and a lifetime ban from London zoo. @zsllondonzoo");
	DADJOKE("What did the Buddhist ask the hot dog vendor? \"Make me one with everything.\"");
	DADJOKE("How does the moon cut his hair? Eclipse it!");
	DADJOKE("What do you call an elephant that doesn't matter? An irrelephant");
	DADJOKE("What happened to the cow that jumped over the barbed wire fence? Udder destruction.");
	DADJOKE("I thought about going on an all-almond diet..... But that's just nuts");
	DADJOKE("What's a duck's favourite dip? Quackamole");
	DADJOKE("What do you call a fake noodle? An Impasta");
	DADJOKE("I hate it when people ask me what I will be doing in 5 years time. Come on, I don't have 2020 vision.");
	DADJOKE("Steak puns... They're a rare medium, well done");
	DADJOKE("The shovel was a ground-breaking invention.");
	DADJOKE("Past, present, and future walked into a bar.... It was tense.");
	DADJOKE("Comedians who tell one too many lightbulb jokes soon burn out.");
	DADJOKE("Look! I'm wearing a Thai.");
	DADJOKE("What do you call a Mexican who has lost his car? Carlos.");
	DADJOKE("How does a penguin build it's house? Igloos it together.");
	DADJOKE("Knock knock. Who's there? To. To Who? To whom.");
	DADJOKE("Why do you never see elephants hiding in trees? Because they're so good at it.");
	DADJOKE("I went out with a girl called Simile, I don't know what I metaphor.");
	DADJOKE("I went on a two week holiday to the south of France. It was Toulon.");
	DADJOKE("A pirate walks into a bar with a ship's wheel on his belt buckle. Bartender: What's that on your belt? Pirate: Arrr, It's drivin' me nuts!");
	DADJOKE("Plateaus are the highest form of flattery.");
	DADJOKE("Me: Doctor you've got to help me, I'm addicted to Twitter. Doctor: I don't follow you.");
	DADJOKE("There's no I in denial.");
	DADJOKE("My computer sings, it's a Dell.");
	DADJOKE("It's time to rock around the Christmas tree.");
	DADJOKE("I got a reversible jacket for Christmas, I can't wait to see how it turns out.");
	DADJOKE("I ate a clock yesterday, it was so time consuming.");
	DADJOKE("I'm tired of following my dreams. I'm just going to ask them where they are going and meet up with them later.");
	DADJOKE("What's brown and sticky? A stick.");
	DADJOKE("How do you find Will Smith in the snow? You look for the fresh prints.");
	DADJOKE("Did you hear about the kidnapping at school? Its ok, he woke up.");
	DADJOKE("What's the best thing about elevator jokes? They work on so many levels.");
	DADJOKE("How do you make antifreeze? Steal her blanket.");
	DADJOKE("What's the difference between beer nuts and deer nuts? Beer nuts are about 49cents and deer nuts are just under a buck.");
	DADJOKE("Did you hear about the guy who jumped off a bridge in Paris? He was in Seine.");
	DADJOKE("There are only two types of people in the world, those who can extrapolate from incomplete data...");
	DADJOKE("What did the buffalo say to his son as he left for college? Bison");
	DADJOKE("A truck of Terrapins crashed into a truck of tortoises. It was a turtle disaster.");
	DADJOKE("What does a house wear? A dress.");
	DADJOKE("I asked a Frenchman if he played video games. He said \"wii\".");
	DADJOKE("Full Meal Jacket");
	DADJOKE("A furniture store keeps calling me. But all I wanted was one night stand.");
	DADJOKE("What did the dog say after a long day at work? \"Today was Ruff\"");
	DADJOKE("Where are average things built? In the satisfactory.");
	DADJOKE("I've eaten too much Middle Eastern food. Now I falafel.");
	DADJOKE("A pet store had a bird contest. No perches necessary.");
	DADJOKE("What's the worst thing about ancient history class? The teachers tend to Babylon.");
	DADJOKE("Yesterday a clown held a door open for me. I thought it was a nice jester.");
	DADJOKE("How many optometrists does it take to change a light bulb?... 1 or 2? 1... or 2?");
	DADJOKE("My son asked me to take him to the hospital because he had a large red mark on his face. I said \"Let's not make any rash decisions.\"");
	DADJOKE("Just read a few facts about frogs. They were ribbiting.");
	DADJOKE("Sean Connery famously said he would leave The Bahamas and return to Scotland, if it ever gained independence. He must be shitting himself.");
	DADJOKE("I used to work in a shoe recycling shop. It was sole destroying.");
	DADJOKE("The universe implodes. No matter.");
	DADJOKE("I can give you the cause of an anaphylactic shock in a nutshell.");
	DADJOKE("I just swapped our bed for a trampoline. My wife hit the roof.");
	DADJOKE("I heard a rumour that Cadbury is bringing out an oriental chocolate bar. Could be a Chinese Wispa.");
	DADJOKE("My dog Minton ate a shuttlecock... Bad Minton.");
	DADJOKE("Astronomers got tired of watching the moon go round the earth for 24 hours. So the decided to call it a day.");
	DADJOKE("I've got an addiction to water, I think I'm an aquaholic.");
	DADJOKE("What did the hungry clock do? Went back four seconds!");
	DADJOKE("My sea sickness comes in waves.");
	DADJOKE("I play triangle for a reggae band. It's pretty casual. I just stand at the back and ting.");
	DADJOKE("I'm afraid I've caught poetry. Don't worry, I used to suffer from short stories. Really?When? Once upon a time");
	DADJOKE("I asked the checkout girl for a date. She said \"They're in the fruit aisle next to the bananas.\"");
	DADJOKE("What did the chicken say about the scrambled egg? There goes my crazy, mixed up kid.");
	DADJOKE("Why do so many people with laser hair want to get it removed?");
	DADJOKE("What's the difference between a well dressed man on a a bicycle and a poorly dressed man on a tricycle? Attire!");
	DADJOKE("Why does Peter pan always fly?Because he neverlands!");
	DADJOKE("For all American Dads, this is all you need today.");
	DADJOKE("What did the pirate say on his 80th birthday? Aye matey");
	DADJOKE("I jumped into the sea today. My friends pier pressured me into it.");
	DADJOKE("What do you call a sketchy Italian neighbourhood? The Spaghetto.");
	DADJOKE("I have kleptomania, but when it gets bad, I take something for it.");
	DADJOKE("Why can't you have a nose 12 inches long? Because then it would be a foot.");
	DADJOKE("Why do bears have hairy coats? Fur protection.");
	DADJOKE("Someone said my clothes were gay. I said \"Yeah, they came out of the closet this morning.\"");
	DADJOKE("I just misspelt Armageddon, it's not the end of the world.");
	DADJOKE("Volunteering in America is absurd, it just makes no cents.");
	DADJOKE("Jonny Wilkinson is announcing his retirement from rugby. You can't say he didn't try.");
	DADJOKE("Why don't you want to taco bout it? 'Cause i'm nacho friend anymore.");
	DADJOKE("Doorbells, don't knock 'em.");
	DADJOKE("I'm back from holiday in the South Pacific. I wish I had Samoa time off.");
	DADJOKE("\"I'm on a whiskey diet, I've lost 4 days already.\" Tommy Cooper What's your favorite Cooperism?");
	DADJOKE("My wife is on a tropical food diet, the house is full of the stuff. It's enough to make a mango crazy.");
	DADJOKE("Whiteboards are remarkable.");
	DADJOKE("Sweet dreams are made of cheese, who am I to dis a Brie.");
	DADJOKE("Happy Easter! What's your best egg yolk? Mine is: A boiled egg is hard to beat.");
	DADJOKE("What do you call an Alligator wearing a vest? An investigator.");
	DADJOKE("Did you hear about the magic tractor? It turned into a field.");
	DADJOKE("Can February march? No, but April May.");
	DADJOKE("Full credit to the whoever made this for Putin in the effort.");
	DADJOKE("What does a grape say when it is stepped on? Nothing, it just lets out a little wine.");
	DADJOKE("What do you call a dinosaur with an extensive vocabulary? A thesaurus.");
	DADJOKE("I swallowed some Tippex last night. I woke up this morning with a massive correction.");
	DADJOKE("Just got a text from Snoop Dogg. No biggy.");
	DADJOKE("What do you get when you cross a rhetorical question with a joke?");
	DADJOKE("Pink Panthers to do list: To do To do To do, to do, to do To do, to doooo");
	DADJOKE("What did the bra say to the hat? You go on ahead, I'll give these two a lift.");
	DADJOKE("What did one eye say to the other? Something smells between us.");
	DADJOKE("Two elephants fall off a cliff... Boom boom!");
	DADJOKE("How many tickles does it take to make an octopus laugh? Tentacles.");
	DADJOKE("I don't like atoms, they're liars. They make up everything.");
	DADJOKE("If you want to set up a company and run it, then that's your own business.");
	DADJOKE("My friend is going on holiday to the Middle East. Oman, that sounds fun...");
	DADJOKE("Whoever invented the door knocker deserves a no-bell prize!");
	DADJOKE("Why did the elf push his bed into the fireplace? He wanted to sleep like a log.");
	DADJOKE("I can't stand Russian dolls.... They're so full of themselves.");
	DADJOKE("I remember the first time I saw a universal remote controller. I thought to myself \"well, this changes everything...\"");
	DADJOKE("I got this extra electron I didn't want. My friend said \"don't be so negative.\"");
	DADJOKE("A boat builder is showing his son one of his forests. He turns to him and says, \"Son, one day this will all be oars\"");
	DADJOKE("Molestation is a touchy subject.");
	DADJOKE("I’ve decided to put up a marquee in my garden with some funky music and flashing lights. Now is the winter of my disco tent.");
	DADJOKE("I was thinking about moving to Moscow but there is no point Russian into things.");
	DADJOKE("I met a Dutch girl with inflatable shoes last week, I phoned her up for a date but she'd popped her clogs.");
	DADJOKE("My New Years resolution is to stop leaving things so late.");
	DADJOKE("Did you hear about the man who gave up making haggis? He didn't have the guts for it anymore.");
	DADJOKE("Retrospective baddadjoke: Why are there no pain killers in the jungle? Because parrots-eat-em-all");
	DADJOKE("Sometimes I squat on the floor, put my arms around my legs and lean forward. That's how I roll.");
	DADJOKE("Got lost in a corn field today, it was a-maize-ing.");
	DADJOKE("I needed a password eight characters long so I picked Snow White and the Seven Dwarves.");
	DADJOKE("Just out buying some new chairs for the house, sofa so good.");
	DADJOKE("My wife told me I was average, I think she's mean.");
	DADJOKE("I was going to tell a dairy joke, but it was too cheesy.");
	DADJOKE("Just had my first round of golf. I'm not very good, in fact I've got a fairway to go.");
	DADJOKE("My daughter just lost her mood ring, really don't know how she feels about it.");
	DADJOKE("I told a friend I was off to California this summer. He told me to be more pacific... so I went to Hawaii instead...");
	DADJOKE("I gave all my dead batteries away today... Free of charge.");
	DADJOKE("Why is there a long line at the cemetery? Because people are dying to get in.");
	DADJOKE("Why did the can crusher quit his job? Because it was soda pressing.");
	DADJOKE("I'm starting a band called 1023mb We'll never get a gig.");
	DADJOKE("What's Forest Gump's Facebook password? 1forest1");
	DADJOKE("A photon checks into a hotel. Receptionist: \"May I take your bags sir?\" Photon: \"I don't have any bags, I'm travelling light.\"");
	DADJOKE("Melon 1: \"Let's run away and get married.\" Melon 2: \"Sorry but I Cantaloupe.\"");
	DADJOKE("Did you hear about the Italian chef who died? He pasta way.");
	DADJOKE("I lost my job last week. Unemployment is not working for me.");
	DADJOKE("A termite walks into a bar and asks \"Is the bar tender here?\"");
	DADJOKE("Hitler was surprised by the Invasion of Normandy. He did nazi that coming.");
	DADJOKE("A Freudian slip is when you say one thing but mean your mother.");
	DADJOKE("So, I asked my North Korean mate how his life was going? He said \"can't complain\"");
	DADJOKE("Just quit my job at Starbucks because day after day it was the same old grind.");
	DADJOKE("I went to the zoo the other day, there was only one dog in it, it was a shitzu.");
	DADJOKE("Why is Saudi Arabia free of mental illness? Because No-mad people live there.");
	DADJOKE("Without geometry life is pointless.");
	DADJOKE("I broke my guitar string last night. Don't fret, I had another.");
	DADJOKE("Had a new beaver curry last night. It's like a normal curry, just a bit 'otter.");
	DADJOKE("Went to the corner shop today... Bought four corners.");
	DADJOKE("Have you heard the conspiracy about Russian allotments. It's all just a communist plot.");
	DADJOKE("My uncle works with Digital radios. You could say he’s a DAB hand.");
	DADJOKE("I dreamt about drowning in an ocean made out of orange soda last night. It took me a while to work out it was just a Fanta sea.");
	DADJOKE("My cat was just sick on the carpet, I don't think it's feline well.");
	DADJOKE("Why do the French only put one egg in an omelette? Because one egg is un oeuf.");
	DADJOKE("The other day someone left plasticine in my house. I didn't know what to make of it.");
	DADJOKE("What happens when you tell an egg a joke? It cracks up.");
	DADJOKE("How do you make holy water? Boil the hell out of it.");
	DADJOKE("Sorry I've been away for a while, I was at the fabric shop looking for new material.");
	DADJOKE("I've just been to a very emotional wedding. Even the cake was in tiers.");
	DADJOKE("When you have a bladder infection, urine trouble.");
	DADJOKE("I stayed up all night to find out where the sun went, then it dawned on me...");
	DADJOKE("I went to the doctor today and he told me I had type A blood but it was a type O.");
	DADJOKE("Today a girl said she recognised me from vegetarian club, but I'm sure I've never met herbivore.");
	DADJOKE("Jokes about German sausages are the wurst.");
	DADJOKE("I tried to throw a ball at a cloud. I mist.");
	DADJOKE("I woke up with a face full of rice. I must've fallen asleep as soon as my head hit the pilau.");
	DADJOKE("I couldn't pay for my coffee because my wallet was in my other pair of moccachinos. I got it for free. Thanks a latté @lashingsbristol!");
	DADJOKE("I cut my finger chopping cheese, but I think that I may have grater problems.");
	DADJOKE("First rule of Thesaurus Club. You don't talk, converse, discuss, speak, chat, deliberate, confer, gab, gossip or natter about Thesaurus Club");
	DADJOKE("Don't have a Findus lasagne before bed. You'll have a nightMARE.");
	DADJOKE("How does a muppet die? Apparently, it kermits suicide.");
	DADJOKE("What did the Mexican say to his chicken? Oh-lay!");
	DADJOKE("A pet shop was ransacked last week... ...there are currently no leads.");
	DADJOKE("How do you drown a hipster? In the mainstream.");
	DADJOKE("Sleeping comes naturally to me. I can do it with my eyes closed.");
	DADJOKE("I ate some rotten chicken last night. Now I feel fowl.");
	DADJOKE("There is a new disease found in margarine... Apparently it spreading very easily.");
	DADJOKE("What do you call an Italian with a rubber toe? Roberto");
	DADJOKE("Why do crabs never give to charity? Because they're shellfish.");
	DADJOKE("What is Santa's favourite pizza? One that's deep pan, crisp and even.");
	DADJOKE("People are making apocalypse jokes like there's no tomorrow.");
	DADJOKE("Someone called me pretentious the other day... I almost choked on my latte.");
	DADJOKE("My mate dug a hole in the garden and filled it with water....I think he meant well.");
	DADJOKE("What's your favourite Christmas Cracker Joke? Here's one of mine: \"What's ET short for? Because he's only got little legs.\"");
	DADJOKE("If you're struggling to think of what to get someone for Christmas. Get them a fridge and watch their face light up when they open it.");
	DADJOKE("A mate of mine has admitted to being addicted to break fluid. I'm worried but he says he can stop whenever he wants.");
	DADJOKE("Start a new job in Seoul next week. I thought it was a good Korea move.");
	DADJOKE("Soya Milk. Looked in your fridge.");
	DADJOKE("A book just fell on my head. I've only got myshelf to blame.");
	DADJOKE("Bloody thespians, always making a scene.");
	DADJOKE("My dad fought in the war and survived mustard gas and pepper spray. He is now classed as a seasoned veteran.");
	DADJOKE("Tea is for mugs.");
	DADJOKE("This thesaurus isn't just terrible, it is also terrible.");
	DADJOKE("I am terrified of elevators. I'm going to start taking steps to avoid them.");
	DADJOKE("Need an ark to save two of every animal? I Noah guy.");
	DADJOKE("What did the father say to the son who was going fishing? Let minnow when you get there.");
	DADJOKE("I am delighted with the corn crop this year. It's A-maize-ing.");
	DADJOKE("How does Moses make his tea? Hebrews it.");
	DADJOKE("I think rowing is oarsome.");
	DADJOKE("What's the advantage of living in Switzerland? Well, the flag is a big plus.");
	DADJOKE("Nostalgia isn't what it used to be.");
	DADJOKE("Why do accountants look so good in heels? Because they never lose their balance.");
	DADJOKE("I'll stop at nothing to avoid using negative numbers.");
	DADJOKE("Wind turbines. I'm a big fan!");
	DADJOKE("What's the definition o a good farmer? A man outstanding in his field.");
	DADJOKE("Why did the octopus beat the shark in a fight? Because it was well armed.");
	DADJOKE("Why does a Moon-rock taste better than an Earth-rock? Because it's a little meteor.");
	DADJOKE("I fired my masseuse today. She rubbed me up the wrong way.");
	DADJOKE("A red and a blue ship have just collided in the Caribbean. Apparently the survivors are marooned.");
	DADJOKE("Breaking news! A hurricane has just hit the the main cheese factory in France. All that's left is de-Brie.");
	DADJOKE("I'm glad I know sign language, it's pretty handy.");
	DADJOKE("I like sea food. I often just have it for the halibut.");
	DADJOKE("A girl walks into a bar and asked for a double entendre. So the barman gave her one.");
	DADJOKE("I took the shell off of my racing snail to see if it went any faster. If anything though, it just made it more sluggish.");
	DADJOKE("I've deleted the phone numbers of all the Germans I know from my mobile phone. Now it's Hans free.");
	DADJOKE("Was kept awake last night by someone flashing a light in my face. It was torch-ure.");
	DADJOKE("My wife said to me \"Your lack of originality is pathetic.\"I said \"Yeah, well your lack of originality is pathetic.\"");
	DADJOKE("It was really hard overcoming my addiction to the hokey cokey. But I turned myself around and that’s what it’s all about.");
	DADJOKE("\"I saw a documentary on how ships are kept together. Riveting!\" Stewart Francis");
	DADJOKE("Last night me and my girlfriend watched three DVDs back to back. Luckily I was the one facing the telly.");
	DADJOKE("My wife just split up with me because I've got a pasta fetish. I'm feeling cannelloni right now.");
	DADJOKE("I'm thinking about getting a new haircut... I'm going to mullet over.");
	DADJOKE("Had a bowl of scotch broth for lunch today... It was souper hot.");
	DADJOKE("I got really quick service at the fish and chip shop. It was very e-fish-ent");
	DADJOKE("How do you organise a space party? You planet.");
	DADJOKE("What did one bird say to the other cheating parrot? Toucan play at that game.");
	DADJOKE("What's wrong with the Southern French's trousers? They're Toulouse.");
	DADJOKE("How much does a hipster weigh? An instagram.");
	DADJOKE("A photon enters a hotel. Porter: 'Need any help with your luggage?' Photon: 'No thanks, I'm travelling light'");
	DADJOKE("Give me ambiguity or give me something else.");
	DADJOKE("A banker came home from work today worried about his job. He said its in the balance.");
	DADJOKE("sorry \"a *pod* of killer whales\"");
	DADJOKE("What do you call a group of killer whales playing instruments? An Orca-stra.");
	DADJOKE("The only thing that can survive a");
	DADJOKE("A man has taken @British_Airways to court after they misplaced his luggage. He lost his case.");
	DADJOKE("Did you hear about the guy whose whole left side was cut off? He's all right now.");
	DADJOKE("Why was the big cat disqualified from the race? Because it was a cheetah.");
	DADJOKE("What do you call a man with rabbits living in his bum? Warren");
	DADJOKE("Just been fishing... It was reely good.");
	DADJOKE("A man walked in to a bar with some asphalt on his arm. He said \"Two beers please, one for me and one for the road.\"");
	DADJOKE("It's so hard to think of another chemistry joke... All the good ones Argon.");
	DADJOKE("Why do people dislike mushrooms? Because they're made from Toads Stools...");
	DADJOKE("There was so much fighting on our Easter camping trip... it was in-tents.");
	DADJOKE("It's easter already?!");
	DADJOKE("I'm off to Nairobi in the Summer. Kenya believe it?");
	DADJOKE("My first girlfriend's name was Ivy... she was all over me.");
	DADJOKE("I've just voted for Charlie's odyssey by Charlie Denholm as the funniest film");
	DADJOKE("Helvetica walks into a bar. The barman says \"We don't serve your type around here.\"");
	DADJOKE("Argon walks into a bar. The barman says \"Get the hell out!\" Argon doesn't react.");
	DADJOKE("Just watched a documentary about beavers... It was the best damn program I've ever seen.");
	DADJOKE("Last night it was raining cats and dogs... I stepped in a poodle.");
	DADJOKE("I thought about being a juggler, but I didn't have the balls.");
	DADJOKE("My mate got a job as a lion's hairdresser at the zoo today. He is literally the mane man.");
	DADJOKE("I'm not as think as you drunk I am.");
	DADJOKE("I'm thinking about moving to France... I've got nothing Toulouse.");
	DADJOKE("Went surfing the other day, it was swell.");
	DADJOKE("Watershed joke: A baker was caught bonking his bread loaves. They say he was inbread.");
	DADJOKE("The only thing that can survive a double dip is a hobnob. Osborne, call McVities.");
	DADJOKE("I enjoy using the comedy technique of self-deprecation – but I’m not very good at it.");
	DADJOKE("My wife... its difficult to say what she does... She sells seashells on the seashore.");
	DADJOKE("A poker player loses his arm in a nasty accident. He's now got a prosthetic replacement. He just can't deal with it.");
	DADJOKE("A girl invited me back to her place last night for champagne... It turned out it was real pain.");
	DADJOKE("Theres a new type of pillow made from corduroy... Its making headlines.");
	DADJOKE("What did the father say to his crying son at his Indian themed birthday party? It's chapatti and you can cry if you want to.");
	DADJOKE("Breaking news! Energizer Bunny arrested - charged with battery.");
	DADJOKE("Wow who saw that coming? Harry Potter and News of the World two of the Biggest selling modern fiction publications ending in the same week.");
	DADJOKE("I went in to a pet shop. I said 'Can I buy a goldfish?' The guy said, 'Do you want an aquarium?' I said 'I don't care what star sign it is.'");
	DADJOKE("A man was found today vacuum cleaning the top of nelsons column without any safety equipment. Police say he was Dyson with death.");
	DADJOKE("A man went to A&E at the weekend who swallowed 12 plastic horses. Don't worry the doctors describe his condition as stable.");
	DADJOKE("Conjunctivitis.com - now that's a site for sore eyes.");
	DADJOKE("A guy walks into the psychiatrist wearing only clingfilm for shorts. The shrink says, \"Well, I can clearly see you're nuts.\"");
	DADJOKE("WIMBLEDON SPECIAL Why should you never fall in love with a tennis player? To them, \"Love\" means nothing.");
	DADJOKE("I went to the doctor the other day I said 'have you got anything for wind' so he gave me a kite.");
	DADJOKE("A sandwich walks into a bar. The barman says \"we don't serve food here.\"");
	DADJOKE("The recruitment consultant asked me \"What do you think of voluntary work?\" I said \"I wouldn't do it if you paid me.\"");
	DADJOKE("An ice cream man was found lying on the floor of his van covered with hundreds and thousands. Police say that he topped himself.");
	DADJOKE("\"Doctor, I've broken my arm in several places\" Doctor \"Well don't go to those places.\"");
	DADJOKE("A boiled egg in the morning is hard to beat.");
	DADJOKE("I'm on a whiskey diet. I've lost three days already.");
	DADJOKE("What do you do with chemists when they die? We barium.");
	DADJOKE("Pretty appropriate. Seven days without a pun makes one weak.");
	DADJOKE("Hand me my Mondeo, my semidetached house, my unloved wife, my unfulfilling job, my xbox kids. Twitter, I am your dad and I tell bad jokes.");
	DADJOKE("What type of onion is the best painkiller? A-sprin' onion...");
	DADJOKE("Just passed a manicurist and a dentist quarreling in the street- they were fighting tooth and nail.");
	DADJOKE("I fear for the calendar, it's days are numbered.");
	DADJOKE("What's the definition of 'A Will'? (I'll give you a clue, it's a dead giveaway.)");
	DADJOKE("I buy a different brand of cling flim every time I go to the shops. Just to keep things fresh.");
	DADJOKE("The advantages of origami are twofold.");
	DADJOKE("There's a new type of broom out, it's sweeping the nation.");
	DADJOKE("Atheism is a non-prophet organisation.");
	DADJOKE("I went to a seafood disco last night and pulled a muscle.");
	DADJOKE("My friend drowned in a bowl of muesli. A strong currant pulled him in.");
	DADJOKE("Sometimes I drink my whiskey neat. Other times I take off my tie and untuck my shirt.");
	DADJOKE("I don't want to sound big headed but I wear extra large hats.");
	DADJOKE("My friend said \"You remind me of a ketchup bottle\", I said \"I'll take that as a condiment\".");
	DADJOKE("Slept like a log last night ... woke up in the fireplace.");
	DADJOKE("Exit signs - they're on the way out aren't they.");
	DADJOKE("What did the fish say when it swam into a wall? Damn!");
	DADJOKE("A cat hijacked a plane, stuck a pistol to the pilots ribs and said \"TAKE ME TO THE CANARIES!\"");
	DADJOKE("They laughed when I said I wanted to be a comedian - they're not laughing now.");
	DADJOKE("One arm butlers - they can take it, but they can't dish it out.");
	DADJOKE("A shark will only attack you if you're wet");
	DADJOKE("Beware of alphabet grenades, they might spell disaster.");
	DADJOKE("What cheese can never be yours? Nacho cheese.");
	DADJOKE("Last night I saw this guy chatting up a cheetah at the bar. I thought 'he's trying to pull a fast one.'");
	DADJOKE("My housemate opened the fridge last night and threw a block of cheese at me. I said \"That's mature.\"");
	DADJOKE("A police officer caught two kids playing with a firework and a car battery. He charged one and let the other one off.");
	DADJOKE("I used to be indecisive, but now I'm not quite sure.");
	DADJOKE("Why are there no pain killers in the jungle? Because parrots-eat-em-all");
	DADJOKE("I'm reading a book on the history of glue - can't put it down.");
	DADJOKE("Albinos - can't say fairer than that.");
	DADJOKE("Velcro... What a rip-off.");
	DADJOKE("A man walks into a butcher. The butcher bets him £5 he can't guess a shelf of meat's weight. Man replies \"I cant, the steaks are too high.\"");
	DADJOKE("Two aerials meet on a roof, fall in love and get married... The ceremony was rubbish but the reception was excellent.");
	DADJOKE("Black beauty... He's a dark horse.");

#undef DADJOKE

	dadjokes_buffer = buf;
}
#endif
