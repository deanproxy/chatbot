create table reminders(
    id integer primary key autoincrement,
    jid varchar(100),
    text varchar(255),
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
