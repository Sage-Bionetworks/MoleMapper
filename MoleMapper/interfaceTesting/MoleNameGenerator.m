//
//  MoleNameGenerator.m
//
//  Created by Dan Webster on 7/16/13.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import "MoleNameGenerator.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface MoleNameGenerator()

@property (nonatomic, strong) NSMutableArray *maleFamous;
@property (nonatomic, strong) NSMutableArray *femaleFamous;


@property (nonatomic, strong) NSArray *femaleFirstname18thCentury;
@property (nonatomic, strong) NSArray *maleFirstname18thCentury;
@property (nonatomic, strong) NSArray *lastNameMilitaryPhoenetic;

/*
@property (nonatomic, strong) NSArray *maleFirstnameHonorific;
@property (nonatomic, strong) NSArray *maleFirstnameEndInY;
@property (nonatomic, strong) NSArray *femaleFirstnameEndInY;
@property (nonatomic, strong) NSArray *lastNameUSStates;
*/

@end

@implementation MoleNameGenerator

-(NSMutableArray *)maleFamous
{
    if (!_maleFamous)
    {
        _maleFamous = [NSMutableArray arrayWithArray:
        @[@"Michael Jackson",
          @"Albert Einstein",
          @"William Shakespeare",
          @"Abraham Lincoln",
          @"Leonardo Da Vinci",
          @"Elvis Presley",
          @"Walt Disney",
          @"Ben Franklin",
          @"George Washington",
          @"Napoleon Moleaparte",
          @"John Lennon",
          @"Christopher Columbus",
          @"Thomas Edison",
          @"Neil Armstrong",
          @"Bill Gates",
          @"Isaac Newton",
          @"Molehammad Ali",
          @"Tom Hanks",
          @"Michael Jordan",
          @"Ludwig van Beethoven",
          @"Paul McCartney",
          @"Pablo Piccasmole",
          @"Thomas Jefferson",
          @"Mark Twain",
          @"Ronald Reagan",
          @"Vincent Van Mole",
          @"Bill Clinton",
          @"Mick Jagger",
          @"Tom Cruise",
          @"Clint Eastwood",
          @"Charles Dickens",
          @"Eddie Murphy",
          @"Harrison Ford",
          @"Harry Houdini",
          @"Jim Carrey",
          @"Darth Vader",
          @"Stephen Hawking",
          @"Bob Dylan",
          @"Alfred Hitchcock",
          @"Justin Timberlake",
          @"Robin Williams",
          @"Vladimir Putin",
          @"John Travolta",
          @"Dwight Eisenhower",
          @"Jack Nicholson",
          @"Edgar Allen Mole",
          @"Denzel Washington",
          @"Ray Charles",
          @"Sean Connery",
          @"Bill Cosby",
          @"Ernest Hemingway",
          @"David Letterman",
          @"Steve Martin",
          @"Magic Johnson",
          @"James Dean",
          @"Sigmund Freud",
          @"Paul Newman",
          @"Bob Hope",
          @"Fred Astaire",
          @"Keith Richards",
          @"Louis Pasteur",
          @"Steve Irwin",
          @"Neil Diamond",
          @"Andy Griffith",
          @"James Taylor",
          @"Frank Lloyd Wright",
          @"Peyton Manning",
          @"Lewis Carrol",
          @"Chevy Chase",
          @"Miles Davis",
          @"Howard Stern",
          @"Roy Rogers",
          @"Billy Crystal",
          @"Hank Aaron",
          @"Henry Kissinger",
          @"John Candy",
          @"Norman Rockwell",
          @"Carl Sagan",
          @"Danny Glover",
          @"Willey Mays",
          @"Andy Rooney",
          @"Bob Newhart",
          @"George Carlin",
          @"Benny Goodman",
          @"Phil Donahue",
          @"Terry Bradshaw",
          @"Walter Cronkite",
          @"Chuck Yeager",
          @"Yogi Berra",
          @"Nathaniel Hawthorne",
          @"Norman Schwarzkopf",
          @"Tom Brokaw",
          @"Arthur Ashe",
          @"Peter Jennings",
          @"Charles Darwin",
          @"Karl Marx",
          @"Julius Caesar",
          @"Christopher Columbus",
          @"Isaac Newton",
          @"Teddy Molesvelt",
          @"Wolfgang Amadeus Molezart",
          @"Ulysses S. Grant",
          @"Leonardo da Vinci",
          @"Winston Churchill",
          @"Genghis Khan",
          @"Friedrich Nietzsche",
          @"Franklin D. Molesevelt",
          @"Sigmund Freud",
          @"Alexander Hamilton",
          @"Woodmole Wilson",
          @"Galileo Galilei",
          @"Oliver Cromwell",
          @"James Madison",
          @"Mark Twain",
          @"Adam Smith",
          @"Immanuel Kant",
          @"John Adams",
          @"Moletaire  ",
          @"Andrew Jackson",
          @"Nicolaus Copernicus",
          @"Vladimir Lenin",
          @"Robert E. Lee",
          @"Oscar Wilde",
          @"Francis Bacon",
          @"Richard Nixon",
          @"King Arthur",
          @"Thomas Aquinas",
          @"Rene Descartes",
          @"Nikmola Tesla",
          @"Harry Truman",
          @"Dante Alighieri",
          @"John Locke",
          @"Frank Sinatra",
          @"Akira Kurosawa",
          @"Sid Vicious",
          @"Don Draper"
          ]];
    }
    return _maleFamous;
}

-(NSMutableArray *)femaleFamous
{
    if (!_femaleFamous)
    {
        _femaleFamous = [NSMutableArray arrayWithArray:
        @[@"Marilyn Monroe",
          @"Britney Spears",
          @"Oprah Winfrey",
          @"Elizabeth Taylor",
          @"Hillary Clinton",
          @"Beyonce Knowles",
          @"Margaret Thatcher",
          @"Whoopi Moleberg",
          @"Julia Roberts",
          @"Meryl Streep",
          @"Lucille Ball",
          @"Tyra Banks",
          @"Susan B. Anthony",
          @"Jane Austen",
          @"Carrie Fisher",
          @"Michele Pfeiffer",
          @"Carol Burnett",
          @"Shirley MacLaine",
          @"Julia Child",
          @"Sigourney Weaver",
          @"Mae West",
          @"Queen Elizabeth",
          @"Queen Victoria",
          @"Joan of Arc",
          @"Lady Gaga",
          @"Gloria Steinham",
          @"Jane Goodall",
          @"Margaret Thatcher",
          @"Amoleia Earhart",
          @"Georgia O'Keefe",
          @"Eleanor Molesvelt",
          @"Marie Curie",
          @"Annie Oakley",
          @"Emily Dickinson",
          @"Clara Barton",
          @"Florence Nightengale",
          @"Harriet Beecher Mole",
          @"Abigail Adams",
          @"Catherine the Great",
          @"Molecahontas ",
          @"Queen Isabella",
          @"Calamity Jane",
          @"Ida Tarbell",
          @"Sally Ride",
          @"Rosie Riveter",
          @"Moley, Queen of Scots",
          @"Lady Godiva",
          @"Barbara Walters",
          @"Katherine Hepburn",
          @"Mary Shelley",
          @"Coco Chanel",
          @"Marie Antoinette",
          @"Joan Baez",
          @"Eva Peron",
          @"Lizzie Borden",
          @"Virginia Woolf",
          @"Ayn Rand",
          @"Jane Fonda",
          @"Shirley Temple",
          @"Lucille Ball",
          @"Frida Kahlo",
          @"Clemolepatra ",
          @"Moledonna ",
          @"Grace Kelly",
          @"Ingrid Bergman",
          @"Rita Hayworth",
          @"Janis Joplin",
          @"Jayne Mansfield",
          @"Bette Davis",
          @"Bettie Page",
          @"Mae West",
          @"Emily Bronte",
          @"Eartha Kitt",
          @"Sylvia Plath",
          @"Mary Poppins",
          @"Joan Crawford",
          @"Lois Lane",
          @"Daisy Duke",
          @"Betty Draper",
          ]];
    }
    return _femaleFamous;
}


-(NSArray *)femaleFirstname18thCentury
{
    if (!_femaleFirstname18thCentury)
    {
        _femaleFirstname18thCentury =
        @[@"Abigail",
          @"Adelaide",
          @"Eunice",
          @"Isabella",
          @"Bridgette",
          @"Sybrina",
          @"Cassandra",
          @"Lucinda",
          @"Clarissa",
          @"Clementine",
          @"Constance",
          @"Cordelia",
          @"Tabitha",
          @"Edith",
          @"Eleanore",
          @"Louetta",
          @"Marietta",
          @"Henrietta",
          @"Florence",
          @"Genevieve",
          @"Gertrude",
          @"Augusta",
          @"Harriet",
          @"Madeleine",
          @"Olivia",
          @"Malvina",
          @"Amelia",
          @"Millicent",
          @"Mildred",
          @"Jemima",
          @"Wilhelmina",
          @"Elmira",
          @"Agnes",
          @"Cornelia",
          @"Antoinette",
          @"Leonora",
          @"Penelope",
          @"Prudence",
          @"Lorraine",
          @"Alexanderina",
          @"Marguerite",
          @"Cecilia",
          @"Sophia",
          @"Temperance",
          @"Matilda",
          @"Lavinia",
          @"Winifred",
          @"Luciana",
          @"Virginia",
          @"Duchess",
          @"Lady",
          @"Dame",
          @"Madame"];
    }
    return _femaleFirstname18thCentury;
}
-(NSArray *)maleFirstname18thCentury
{
    if (!_maleFirstname18thCentury)
    {
        _maleFirstname18thCentury =
        @[@"Abraham",
          @"Alexander",
          @"Archibald",
          @"Albert",
          @"Cuthbert",
          @"Chauncey",
          @"Cornelius",
          @"Obediah",
          @"Ebenezer",
          @"Edmund",
          @"Nathaniel",
          @"Phineas",
          @"Francis",
          @"Frederick",
          @"Winifred",
          @"Eugene",
          @"Hamilton",
          @"Jedediah",
          @"Jeremiah",
          @"Gerald",
          @"Lawrence",
          @"Malachi",
          @"Edwin",
          @"Obediah",
          @"Oliver",
          @"Zachariah",
          @"Thaddeus",
          @"Theodore",
          @"Franco"];
    }
    return _maleFirstname18thCentury;
}
-(NSArray *)lastNameMilitaryPhoenetic
{
    if (!_lastNameMilitaryPhoenetic)
    {
        _lastNameMilitaryPhoenetic =
        @[@"Alpha",
          @"Bravo",
          @"Charlie",
          @"Delta",
          @"Echo",
          @"Foxtrot",
          @"Golf",
          @"Hotel",
          @"India",
          @"Juliett",
          @"Kilo",
          @"Lima",
          @"Mike",
          @"November",
          @"Oscar",
          @"Papa",
          @"Quebec",
          @"Romeo",
          @"Sierra",
          @"Tango",
          @"Uniform",
          @"Victor",
          @"Whiskey",
          @"X-ray",
          @"Yankee",
          @"Zulu",
          @"Able",
          @"Baker",
          @"Cast",
          @"Dog",
          @"Easy",
          @"Fox",
          @"George",
          @"Hypo",
          @"Item",
          @"Jig",
          @"King",
          @"Love",
          @"Mike",
          @"Nan",
          @"Oboe",
          @"Pup",
          @"Quack",
          @"Rush",
          @"Sail",
          @"Tare",
          @"Unit",
          @"Vice",
          @"Watch",
          @"Yoke"];
        
    }
    return _lastNameMilitaryPhoenetic;
}

//Other naming conventions
/*
-(NSArray *)maleFirstnameHonorific
{
    if (!_maleFirstnameHonorific)
    {
        _maleFirstnameHonorific =
        @[@"Duke",
          @"Marquis",
          @"Earl",
          @"Viscount",
          @"Baron",
          @"Sir",
          @"Master",
          @"Lord",
          @"Father",
          @"Reverend",
          @"Monsieur",
          @"Bishop",
          @"Doctor",
          @"Professor",
          @"General",
          @"Colonel",
          @"Major",
          @"Captain",
          @"Cadet",
          @"Sergeant",
          @"Private",
          @"Shaman"];
    }
    return _maleFirstnameHonorific;
}
-(NSArray *)lastNameUSStates
{
    if (!_lastNameUSStates)
    {
        _lastNameUSStates =
        @[];
    }
    return _lastNameUSStates;
}
-(NSArray *)maleFirstnameEndInY
{
    if (!_maleFirstnameEndInY)
    {
        _maleFirstnameEndInY =
        @[@"Andy",
          @"Bobby",
          @"Billy",
          @"Danny",
          @"Davey",
          @"Eddie",
          @"Freddy",
          @"Johnny",
          @"Jimmy",
          @"Lenny",
          @"Mikey",
          @"Randy",
          @"Sammy",
          @"Tommy",
          @"Vinnie",
          @"Willie",
          @"Ziggy",
          ];
    }
    return _maleFirstnameEndInY;
}
-(NSArray *)femaleFirstnameEndInY
{
    if (!_femaleFirstnameEndInY)
    {
        _femaleFirstnameEndInY =
        @[@"Amy",
          @"Annie",
          @"Bonnie",
          @"Bunnie",
          @"Chrissy",
          @"Cathy",
          @"Debbie",
          @"Franny",
          @"Jenny",
          @"Kelly",
          @"Minnie",
          @"Nancy",
          @"Pattie",
          @"Sandy",
          @"Susie",
          ];
    }
    return _femaleFirstnameEndInY;
}
*/
 
-(NSString *)randomUniqueMoleNameWithGenderSpecification:(NSString *)gender
{
    NSString *name = nil;
    NSArray *allCurrentMoleNames = [self arrayOfAllCurrentMoleNames];
    
    //If random gender, choose either male or female
    NSArray *genders = @[@"Male",@"Female"];
    if ([gender isEqualToString:@"Random"])
    {
        NSUInteger randomIndex = arc4random() % [genders count];
        gender = genders[randomIndex];
    }
    
    if ([gender isEqualToString:@"Male"])
    {
        //Get all current names from Core Data, pass through the array and remove any already used
        [self.maleFamous removeObjectsInArray:allCurrentMoleNames];
        
        if ([self.maleFamous count] == 0)//Check to see if the array is empty, if so, then choose from random
        {
            name = [self randomUniqueMoleNameWithGenderSpecification:gender];
        }
        else
        {
            NSUInteger randomNameIndex = arc4random() % [self.maleFamous count];
            name = self.maleFamous[randomNameIndex];
            //Don't remove from the properties array yet, because the user may not officially chose this name and save it back into core data
        }
    }
    else if ([gender isEqualToString:@"Female"])
    {
        //Get all current names from Core Data, pass through the array and remove any already used
        [self.femaleFamous removeObjectsInArray:allCurrentMoleNames];
        
        if ([self.femaleFamous count] == 0)//Check to see if the array is empty, if so, then choose from random
        {
            name = [self randomUniqueMoleNameWithGenderSpecification:gender];
        }
        else
        {
            NSUInteger randomNameIndex = arc4random() % [self.femaleFamous count];
            name = self.femaleFamous[randomNameIndex];
        }
    }
    return name;
}

-(NSString *)randomMoleNamewithGenderSpecification:(NSString *)gender
{
    NSString *name = nil;
    
    NSArray *firstnames = nil;
    NSArray *lastnames = nil;
    
    if ([gender isEqualToString:@"Female"])
    {
        firstnames = self.femaleFirstname18thCentury;
    }
    
    else if ([gender isEqualToString:@"Male"])
    {
        firstnames = self.maleFirstname18thCentury;
    }
    
    lastnames = self.lastNameMilitaryPhoenetic;
    
    NSUInteger randomFirstIndex = arc4random() % [firstnames count];
    NSUInteger randomLastIndex = arc4random() % [lastnames count];
    
    NSArray *firstLast = @[firstnames[randomFirstIndex],lastnames[randomLastIndex]];
        
    name = [firstLast componentsJoinedByString:@" "];
    
    return name;
}

-(NSArray *)arrayOfAllCurrentMoleNames
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    
    if (!matches)
    {
        NSLog(@"Error while trying to get all mole names");
    }
    else if ([matches count] == 0)
    {
        NSLog(@"No moles found when looking for all mole names");
    }
    return matches;
}

@end
