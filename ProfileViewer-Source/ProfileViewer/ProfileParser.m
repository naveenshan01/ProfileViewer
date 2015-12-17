//
//  ProfileParser.m
//  ProfileViewer
//
//  Created by Naveen Shan on 21/09/15.
//  Copyright (c) 2015 Nanusoft. All rights reserved.
//

#import "ProfileParser.h"

@interface ProfileParser ()

@end

@implementation ProfileParser

- (void)parseProfile {
    NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSString *profileLocation = [libraryDirectory stringByAppendingPathComponent:@"MobileDevice/Provisioning Profiles/"];
    
    NSArray *mobileProvisionFiles = [self findFilesAtPath:[NSURL URLWithString:[profileLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSLog(@"Found : %lu  -- files",(unsigned long)[mobileProvisionFiles count]);
    
    NSLog(@"\n\n");
    
    for(int i = 1; i <= [mobileProvisionFiles count]; i++) {
        NSURL *fileURL = [mobileProvisionFiles objectAtIndex:(i-1)];
//        NSLog(@"Process File : %d - %@",i,[fileURL lastPathComponent]);
        if (! fileURL) {
            NSLog(@"Failed Processing file : %d - %@",i,@"URL Not Found");
            continue;
        }
        
        NSDictionary *provisionPlist = [self parseFile:fileURL];
        //NSLog(@"ProvisionPlist : %@",provisionPlist);
        
        // Application Id
        NSString *applicationId = [self getAppId:provisionPlist];
        NSString *provisionType = [self getProvisionType:provisionPlist];
        NSString *provisionName = [self getValueForOption:@"Name" inPlist:provisionPlist];
        NSString *provisionUUID = [self getValueForOption:@"UUID" inPlist:provisionPlist];
        NSString *expirationDate = [self getValueForOption:@"ExpirationDate" inPlist:provisionPlist];
        
        printf("%d Name : %s AppId : %s -Type: %s \n     UUID : %s -Expiry: %s\n",i,[provisionName UTF8String], [applicationId UTF8String], [provisionType UTF8String],[provisionUUID UTF8String],[expirationDate UTF8String]);
    }
    
    NSLog(@"\n\n");
}

- (NSDictionary *)parseFile:(NSURL *)file {
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    
    @try {
        CMSDecoderCreate(&decoder);
        NSData *fileData = [NSData dataWithContentsOfURL:file];
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
        plist = [plistString propertyList];
    }
    @catch (NSException *exception) {
        printf("Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
    
    return plist;
}

- (NSString *)getAppId:(NSDictionary *)provisionPlist {
    NSString *applicationIdentifier = [provisionPlist valueForKeyPath:@"Entitlements.application-identifier"];
    NSString *prefix = [[[provisionPlist valueForKeyPath:@"ApplicationIdentifierPrefix"] objectAtIndex:0] stringByAppendingString:@"."];
    NSString *applicationId = [applicationIdentifier stringByReplacingOccurrencesOfString:prefix withString:@""];
    return applicationId;
}

- (NSString *)getProvisionType:(NSDictionary *)provisionPlist {
    NSString *type = nil;
    if ([provisionPlist valueForKeyPath:@"ProvisionedDevices"]){
        if ([[provisionPlist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
            type = @"debug";
        }
        else {
            type = @"ad-hoc";
        }
    }
    else if ([[provisionPlist valueForKeyPath:@"ProvisionsAllDevices"] boolValue]) {
        type = @"enterprise";
    }
    else {
        type = @"appstore";
    }
    return type;
}

- (NSString *)getValueForOption:(NSString *)option inPlist:(NSDictionary *)provisionPlist {
    id result = [provisionPlist valueForKeyPath:option];
    if (result) {
        if ([result isKindOfClass:[NSArray class]] && [result count]) {
            result = [result componentsJoinedByString:@"\n"];
        }
        else {
            result = [result description];
        }
    }
    return result;
}

- (void)parseFile:(NSURL *)file option:(NSString *)option {
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    
    @try {
        CMSDecoderCreate(&decoder);
        NSData *fileData = [NSData dataWithContentsOfURL:file];
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
        plist = [plistString propertyList];
    }
    @catch (NSException *exception) {
        printf("Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
    
    if (!option) {
        printf("%s", [plistString UTF8String]);
    }
    if ([option isEqualToString:@"type"]) {
        if ([plist valueForKeyPath:@"ProvisionedDevices"]){
            if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue]) {
                printf("debug\n");
            }
            else {
                printf("ad-hoc\n");
            }
        }
        else if ([[plist valueForKeyPath:@"ProvisionsAllDevices"] boolValue]) {
            printf("enterprise\n");
        }
        else {
            printf("appstore\n");
        }
    }
    else if ([option isEqualToString:@"appid"]) {
        NSString *applicationIdentifier = [plist valueForKeyPath:@"Entitlements.application-identifier"];
        NSString *prefix = [[[plist valueForKeyPath:@"ApplicationIdentifierPrefix"] objectAtIndex:0] stringByAppendingString:@"."];
        printf("%s\n", [[applicationIdentifier stringByReplacingOccurrencesOfString:prefix withString:@""] UTF8String]);
    }
    else {
        id result = [plist valueForKeyPath:option];
        if (result) {
            if ([result isKindOfClass:[NSArray class]] && [result count]) {
                printf("%s\n", [[result componentsJoinedByString:@"\n"] UTF8String]);
            }
            else {
                printf("%s\n", [[result description] UTF8String]);
            }
        }
    }
}

#pragma mark -

- (NSArray *)findFilesAtPath:(NSURL *const)rootPath {
    NSAssert(rootPath != nil, @"Assertion: Root path is nil.");
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSMutableArray *mobileProvisionFiles = [NSMutableArray array];
    NSDirectoryEnumerator *dirEnumerator = [defaultManager enumeratorAtURL:rootPath
                                                includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                   options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants
                                                              errorHandler:nil];
    
    
    for (NSURL * const aFileUrl in dirEnumerator) {
        NSString * const fileName = [aFileUrl lastPathComponent];
        
        if ([fileName hasSuffix:@"mobileprovision"]) {
            [mobileProvisionFiles addObject:aFileUrl];
        }
    }
    
    return [mobileProvisionFiles copy];
}

@end
