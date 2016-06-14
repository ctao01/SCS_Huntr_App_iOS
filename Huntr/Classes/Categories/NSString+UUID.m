//
//  NSString+UUID.m
//  Huntr
//
//  Created by Justin Leger on 6/10/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)uuid
{
#if TARGET_OS_IPHONE
    
    NSString * uuidString = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        //        uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        //        CFRelease(uuid);
        
        CFStringRef cfUuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        uuidString = (__bridge NSString *)cfUuidString;
        CFRelease(cfUuidString);
    }
    return uuidString;
    
#elif TARGET_OS_MAC
    
    kern_return_t			 kernResult;
    mach_port_t			   master_port;
    CFMutableDictionaryRef	matchingDict;
    io_iterator_t			 iterator;
    io_object_t			   service;
    CFDataRef				 macAddress = nil;
    
    kernResult = IOMasterPort(MACH_PORT_NULL, &master_port);
    if (kernResult != KERN_SUCCESS) {
        printf("IOMasterPort returned %d\n", kernResult);
        return nil;
    }
    
    matchingDict = IOBSDNameMatching(master_port, 0, "en0");
    if(!matchingDict) {
        printf("IOBSDNameMatching returned empty dictionary\n");
        return nil;
    }
    
    kernResult = IOServiceGetMatchingServices(master_port, matchingDict, &iterator);
    if (kernResult != KERN_SUCCESS) {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        return nil;
    }
    
    while((service = IOIteratorNext(iterator)) != 0)
    {
        io_object_t		parentService;
        
        kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
        if(kernResult == KERN_SUCCESS)
        {
            if(macAddress)
                CFRelease(macAddress);
            macAddress = IORegistryEntryCreateCFProperty(parentService, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
            IOObjectRelease(parentService);
        }
        else {
            printf("IORegistryEntryGetParentEntry returned %d\n", kernResult);
        }
        
        IOObjectRelease(service);
    }
    
    return [[NSString alloc] initWithData:(__bridge NSData*) macAddress encoding:NSASCIIStringEncoding];
    
#endif
}


+ (NSString *)stringWithNewUUID
{
    return [NSString uuid];
}

@end
