create table reminders(
    id integer primary key autoincrement,
    jid varchar(100),
    text varchar(255),
    room varchar(100),
    time datetime
);

create table aliases(
    id integer primary key autoincrement,
    alias_key varchar(100),
    alias_val varchar(100)
);

create table jokes(
    id integer primary key autoincrement,
    text blob
);

create table quotes(
    id integer primary key autoincrement, 
    text blob
);

insert into jokes(text) values('Why was the robot angry? ...because someone kept pushing his buttons!');
insert into jokes(text) values("What's a robots favorite type of music?... Heavy Metal!");
insert into jokes(text) values("What do you get when you cross a robot and a tractor?... A Trans-Farmer! Get it? GET IT?!");
insert into jokes(text) values("I can't believe I was once fired from the calendar factory.  All I did was take a day off.");
insert into jokes(text) values("I'd tell you a chemistry joke, but I know I wouldn't get a reaction.");
insert into jokes(text) values("My first job was working in an orange juice factory, but I got canned: couldn't concentrate.");
insert into jokes(text) values("I want to make a joke about sodium... But Na..");
insert into jokes(text) values("I hate insect puns, they really bug me.");
insert into jokes(text) values("Why did the bee get married? ...because he found his honey.");
insert into jokes(text) values("What do sea monsters eat for lunch? Fish and ships.");
insert into jokes(text) values("I got caught stealing a calender once. I got 12 months.");
insert into jokes(text) values("Never trust atoms. They make up everything.");
insert into jokes(text) values("If Apple made car, would it have Windows?");
insert into jokes(text) values("How does Moses make his tea?  Hebrews it.");
insert into jokes(text) values("A ham sandwich walks into a bar and orders a beer. The Bartender says, 'Sorry, we don't serve food here.'");
insert into jokes(text) values("How do you make holy water?  You boil the hell out of it.");
insert into jokes(text) values("Two guys walk into a bar, the third one ducks.");
insert into jokes(text) values("I had a dream I was a muffler last night. I woke up exhausted!");
insert into jokes(text) values("What is Beethoven's favorite fruit? A Ba-na-na-na.");
insert into jokes(text) values("Did you know that 5/4 people admit they're bad with fractions?");

insert into quotes(text) values("What is this? A center for ants? How can we be expected to teach children to learn how to read... if they can't even fit inside the building?");
insert into quotes(text) values("There was a moment last night, when she was sandwiched between the two Finnish dwarves and the Maori tribesmen, where I thought, 'Wow, I could really spend the rest of my life with this woman.'");
insert into quotes(text) values("But why male models?");
insert into quotes(text) values("They're in the computer... It's so simple!");
insert into quotes(text) values("I'm not an ambi-turner.");
insert into quotes(text) values("It's a walk-off!");
insert into quotes(text) values("Han-sell-out is about to have his Han-sell-ass handed to him on a platter. With french-fried potatoes!");
insert into quotes(text) values("I think I'm getting the black lung, Pa..");
