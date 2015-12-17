//
//  main.m
//  ProfileViewer
//
//  Created by Naveen Shan on 21/09/15.
//  Copyright (c) 2015 Nanusoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProfileParser.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Start Parsing Profiles.....!");
        ProfileParser *profileParser = [[ProfileParser alloc] init];
        [profileParser parseProfile];
        NSLog(@"End Parsing Profiles.....!");
    }
    return 0;
}
