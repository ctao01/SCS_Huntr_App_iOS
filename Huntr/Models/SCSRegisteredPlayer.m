//
//  SCSRegisteredPlayer.m
//  Huntr
//
//  Created by Justin Leger on 7/11/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSRegisteredPlayer.h"

@implementation SCSRegisteredPlayer

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        self.playerName =[json valueForKey:@"name"];
        self.playerID =[json valueForKey:@"_id"];
        self.breadcrumbs = [json valueForKey:@"breadcrumbs"];
        
        self.authToken = [json valueForKey:@"authToken"];
        self.authType = [json valueForKey:@"authType"];
        self.authID = [json valueForKey:@"authID"];
        self.email = [json valueForKey:@"email"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.playerName =[decoder decodeObjectForKey:@"name"];
        self.playerID =[decoder decodeObjectForKey:@"_id"];
        self.breadcrumbs = [decoder decodeObjectForKey:@"breadcrumbs"];
        
        self.authToken = [decoder decodeObjectForKey:@"authToken"];
        self.authType = [decoder decodeObjectForKey:@"authType"];
        self.authID = [decoder decodeObjectForKey:@"authID"];
        self.email = [decoder decodeObjectForKey:@"email"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.playerName forKey:@"name"];
    [encoder encodeObject:self.playerID forKey:@"_id"];
    [encoder encodeObject:self.breadcrumbs forKey:@"breadcrumbs"];
    
    [encoder encodeObject:self.authToken forKey:@"authToken"];
    [encoder encodeObject:self.authType forKey:@"authType"];
    [encoder encodeObject:self.authID forKey:@"authID"];
    [encoder encodeObject:self.email forKey:@"email"];
}

@end
