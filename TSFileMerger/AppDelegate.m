//
//  AppDelegate.m
//  TSFileMerger
//
//  Created by Jorrit van Asselt on 29-09-13.
//  Copyright (c) 2013 KerrelInc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


#define kPath @"/Users/Jorrit/Desktop/iTunes Festival/Aloe Blacc/"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self mergeFiles];
}

- (void) mergeFiles{
    NSArray * fileNames = [self fileList];
    if (fileNames == nil) {
        NSLog(@"Something went wrong");
        return;
    }
    
    NSInteger processedItems = 0;
    CGFloat progression = 0.0f;
    
    NSString * currentFilePath = nil;
    NSMutableData * mergedData = [[NSMutableData alloc] init];
    for (NSString * aFileName in  fileNames) {
        @autoreleasepool {
            currentFilePath = [kPath stringByAppendingPathComponent: aFileName];
            NSData * currentFile = [NSData dataWithContentsOfFile: currentFilePath];
            [mergedData appendData: currentFile];
            
            processedItems++;
            progression = (processedItems * 1.0f) / (fileNames.count * 1.0f);
            
            NSLog(@"Appended %@ - %2.2f", aFileName, (progression*100.0f));
        }
        
    }
    
    NSError * error = nil;
    NSLog(@"Now saving merged file...");
    if (![mergedData writeToFile: [kPath stringByAppendingPathComponent: @"mergedFile.ts"]
                         options: NSDataWritingAtomic
                           error: &error]) {
        NSLog(@"ERROR: could not write file: %@, %@", error, [error localizedDescription]);
    } else{
        NSLog(@"SUCCES!");
    }
}

- (NSArray *) fileList{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    __block NSError * error = nil;
    NSArray * contentOfDirectory = [fileManager contentsOfDirectoryAtPath: kPath error: &error];
    if (contentOfDirectory == nil) {
        NSLog(@"ERROR LIST CONTENT OF DIR:\n%@, %@", error, [error localizedDescription]);
        return nil;
    }
    NSPredicate * containsDotTs = [NSPredicate predicateWithFormat: @"self CONTAINS %@", @".ts"];
    NSArray * filteredArray = [contentOfDirectory filteredArrayUsingPredicate: containsDotTs];
    
    NSArray * sortedArray = [filteredArray sortedArrayUsingSelector: @selector(compare:)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        NSString * verifyList = [sortedArray componentsJoinedByString: @"\n"];
        if (![verifyList writeToFile: [kPath stringByAppendingString: @"verifyList.txt"]
                          atomically: YES
                            encoding: NSUTF8StringEncoding
                               error: &error]){
            NSLog(@"ERROR: could not write verification list: %@, %@", error, [error localizedDescription]);
        }
    });
    
    return sortedArray;
}

@end
