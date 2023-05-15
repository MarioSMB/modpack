string rq1_ca = "I've lost my overdue library\nbook in ";
string rq1_cb = ". Will you\nplease find it?\n";
string rq1_qa = "Locate a missing book in ";
string rq1_qb = " and\nreturn it to it's owner";
string rq1_cc = "Thank you so much for returning\nthe book!\n";

string rq2_ca = "Our town healer is missing!\n He's in ";
string rq2_cb = "! Please\nrescue him!";
string rq2_qa = "Find the lost healer in ";
string rq2_qb = " and\nreturn him home";
string rq2_cc = "Many thanks for rescuing\nthe healer\n";

string rq3_ca = "We need a healer to come\nto our town, quickly. There's\none in ";
string rq3_cb = " that may help.\nWill you please bring him here?";
string rq3_qa = "Ask a healer in ";
string rq3_qb = " to\nhelp the needy";
string rq3_cc = "The healer can now treat\nthe injured! Thank you\n";

string rq4_ca = "An evile wizard has been\nterrorizing the town for days\nHe's hiding in ";
string rq4_cb = ". Will you\nplease save us from him?";
string rq4_qa = "Destroy the evile wizard in ";
string rq4_qb = ".";
string rq4_cc = "With the evile wizard gone,\nperhaps the town will return to peace.\n";

string rq5_ca = "I need to go to ";
string rq5_cb = " and\n require an escort to make it\nthere safely. Will you help?";
string rq5_qa = "Escort the villager to ";
string rq5_qb = ".";
string rq5_cc = "Thanks for escorting me\nYou are indeed a great adventurer.\n";

string rq6_ca = "I borrowed this book from someone\nin ";
string rq6_cb = ". If you return it to him for me,\nhe will most certainly reward you.";
string rq6_qa = "Return the borrowed book to a\ncollector in ";
string rq6_qb = ".";
string rq6_cc = "Thanks for giving me back this book\nIt's my favorite one.";

string rq7_ca = "There's an evile wizard in ";
string rq7_cb = "\nthat killed my son. Take me to him so I\n can exact my revenge!";
string rq7_qa = "Bring the villager to destroy the\nevile wizard located in ";
string rq7_qb = ".";
string rq7_cc = "We did it! My son is avenged!\n";

string rq8_ca = "An evile wizard stole my favorite\nbook! How unlucky is that? He's\nprobably reading it in ";
string rq8_cb = "\nright now. Will you please go get it\nback?";
string rq8_qa = "Recover the stolen book from an evile\nwizard in ";
string rq8_qb = " and return\nit to it's owner.";
string rq8_cc = "Thank you so much for returning\nthe book!\n";

string rq9_ca = "My daughter has been kidnapped by\na hideous goblin who took her to\n";
string rq9_cb = ". Please, will you\nrescue her?";
string rq9_qa = "Rescue the kidnapped daughter in\n";
string rq9_qb = " from the hideous\ngoblin.";
string rq9_cc = "I don't have much to offer\nbut you saved my baby, I thank you\neternally.\n";

string rq10_ca = "I have a mild case of the plague.\nThere's an alchemist in ";
string rq10_cb = "\nthat has created a special elixir to\ncure me. Will you please go retrieve it\nfor me? ";
string rq10_qa = "Retrieve the elixir from an alchemist in\n";
string rq10_qb = " to cure\nthe plague victim.";
string rq10_cc = "I'm cured! Thank you so much!\n";

string rq11_ca = "My friends and I were out\npartying in ";
string rq11_cb = "\nand we sorta left our ale out there.\nCan you *hick* go get at least 3\nbottles back here?";
string rq11_qa = "Find three bottles of ale in ";
string rq11_qb = "\nand return it to a drunk in town";
string rq11_cc = "Thanks for hooking me up with the brew!\n";

string rq12_ca = "My brother left his compass and map\nhere when he went out for a walk in\n";
string rq12_cb = ". I'm afraid he's gotten lost. Will\nyou please go look for him?";
string rq12_qa = "Find the lost brother in ";
string rq12_qb = "\nand return him home.";
string rq12_cc = "Thanks for finding my brother. He's\nnot too bright, you know.";

string rq13_ca = "I need a blacksmith to make me new\nhinges. There's one in ";
string rq13_cb = "\nthat can help. Will you go ask him for\nme?";
string rq13_qa = "Locate a blacksmith in ";
string rq13_qb = " and\nask him to make hinges.";
string rq13_cc = "Excellent work! Now my cabinet doors\nwon't fall off!"

string rq14_ca = "I am on a pilgrimage to\n";
string rq14_cb = ". If you aid me\nin my journey, I will reward you";
string rq14_qa = "Escort a pilgrim to ";
string rq14_qb = ".";
string rq14_cc = "Bless you for your help.\nYou will not be forgotten in my prayers.\n";

float MAX_RQ = 13;

/* Add strings, add info below, add index to questlog, add index to dialog */


float RQ_ITEMS = 4;
float RQ_MONSTERS = 8;
float RQ_GIVE_NPC = 16;
float RQ_PICKUP_NPC = 32;
float RQ_RESCUE_NPC = 64;
float RQ_OBJECTIVES = 252;
float RQ_FIGHT = 256;
float RQ_ESCORT = 512; // doesn't add objectives
float RQ_ALT = 1024;
float RQ_GIVE_ITEM = 2048;
float RQ_DEADGUY = 4096;

// scavenger hunt?
// trade?
float MT_HOSTILE = 2;
float MT_FRIENDLY = 1;
float MT_BOTH = 3;

nosave float rq_objquan;
