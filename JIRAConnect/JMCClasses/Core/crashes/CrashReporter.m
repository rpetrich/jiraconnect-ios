/*
 * Author: Andreas Linde <mail@andreaslinde.de>
 *         Kent Sutherland
 *
 * Copyright (c) 2009 Andreas Linde & Kent Sutherland. All rights reserved.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <CrashReporter/CrashReporter.h>
#import "CrashReporter.h"
#import "JMC.h"
#import "JMCMacros.h"
#import "sys/sysctl.h"

static CrashReporter *crashReportSender = nil;

@interface CrashReporter ()

- (void)handleCrashReport;

- (NSString *)_crashLogStringForReport:(PLCrashReport *)report;

@end


@implementation CrashReporter

+ (void)enableCrashReporter
{

    if (crashReportSender == nil)
    {
        crashReportSender = [[CrashReporter alloc] init];
    }
}

/**
* If Crash Reports are enabled, this will return the sharedCrashReporter instance.
* Else, it returns nil.
*/
+ (CrashReporter *)sharedCrashReporter
{
    return crashReportSender;
}

- (id)init
{
    self = [super init];

    if (self != nil)
    {

        NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kCrashReportAnalyzerStarted];
        if (testValue == nil)
        {
            _crashReportAnalyzerStarted = 0;
        } else
        {
            _crashReportAnalyzerStarted = [[NSUserDefaults standardUserDefaults] integerForKey:kCrashReportAnalyzerStarted];
        }

        testValue = nil;
        testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kCrashReportActivated];
        if (testValue == nil)
        {
            _crashReportActivated = YES;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kCrashReportActivated];
        } else
        {
            _crashReportActivated = [[NSUserDefaults standardUserDefaults] boolForKey:kCrashReportActivated];
        }

        if (_crashReportActivated)
        {
            _crashFiles = [[NSMutableArray alloc] init];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            _crashesDir = [[NSString stringWithFormat:@"%@", [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/crashes/"]] retain];

            NSFileManager *fm = [NSFileManager defaultManager];

            if (![fm fileExistsAtPath:_crashesDir])
            {
                NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0755] forKey:NSFilePosixPermissions];
                NSError *theError = NULL;

                [fm createDirectoryAtPath:_crashesDir withIntermediateDirectories:YES attributes:attributes error:&theError];
            }

            PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
            NSError *error;

            // Check if we previously crashed
            if ([crashReporter hasPendingCrashReport])
                    [self handleCrashReport];

            // Enable the Crash Reporter
            if (![crashReporter enableCrashReporterAndReturnError:&error])
                JMCALog(@"Warning: Could not enable crash reporter: %@", error);

            JMCDLog(@"Crash reporter enabled.");
        }
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
    [_crashesDir release];
    [_crashFiles release];
}


- (BOOL)hasPendingCrashReport
{

    if (_crashReportActivated)
    {
        NSFileManager *fm = [NSFileManager defaultManager];

        if ([_crashFiles count] == 0 && [fm fileExistsAtPath:_crashesDir])
        {
            NSString *file;
            NSError *error = nil;

            NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:_crashesDir];

            for(file in dirEnum)
            {
                NSDictionary *fileAttributes = [fm attributesOfItemAtPath:[_crashesDir stringByAppendingPathComponent:file] error:&error];
                if ([[fileAttributes objectForKey:NSFileSize] intValue] > 0)
                {
                    [_crashFiles addObject:file];
                }
            }
        }

        if ([_crashFiles count] > 0)
        {
            return YES;
        }
        else
                return NO;
    } else
            return NO;
}


#pragma mark -
#pragma mark Private

- (void)cleanCrashReports
{
    NSError *error;

    NSFileManager *fm = [NSFileManager defaultManager];

    for (NSUInteger i = 0; i < [_crashFiles count]; i++)
    {
        [fm removeItemAtPath:[_crashesDir stringByAppendingPathComponent:[_crashFiles objectAtIndex:i]] error:&error];
    }
    [_crashFiles removeAllObjects];
}

- (NSArray *)crashReports
{
    NSError *error;

    NSMutableArray *crashReports = [NSMutableArray arrayWithCapacity:[_crashFiles count]];

    for (NSUInteger i = 0; i < [_crashFiles count]; i++)
    {
        NSString *filename = [_crashesDir stringByAppendingPathComponent:[_crashFiles objectAtIndex:i]];


        NSData *crashData = [NSData dataWithContentsOfFile:filename];

        if ([crashData length] > 0)
        {
            // crashData here is simply a protobuf! could also attach that?

            PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];

            NSString *crashLogString = [self _crashLogStringForReport:report];

            [crashReports addObject:crashLogString];
            [report release];
        }
    }
    return crashReports;
}

// taken from http://stackoverflow.com/questions/4857195/how-to-get-programmatically-ioss-alphanumeric-version-string
- (NSString *)osVersionBuild {
     int mib[2] = {CTL_KERN, KERN_OSVERSION};
     size_t size = 0;

     // Get the size for the buffer
     sysctl(mib, 2, NULL, &size, NULL, 0);

     char *answer = malloc(size);
     int result = sysctl(mib, 2, answer, &size, NULL, 0);

    NSString *versionStr;
    if (result >= 0) {
        versionStr = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    } else {
        versionStr = @"-";
    }
    free(answer);
    return versionStr;
 }

- (NSString *)_crashLogStringForReport:(PLCrashReport *)report
{
    NSMutableString *reportString = [NSMutableString string];

    /* Header */
    boolean_t lp64;

    /* Map to apple style OS nane */
    const char *osName;
    switch (report.systemInfo.operatingSystem)
    {
        case PLCrashReportOperatingSystemiPhoneOS:
            osName = "iPhone OS";
            break;
        case PLCrashReportOperatingSystemiPhoneSimulator:
            osName = "Mac OS X";
            break;
        default:
            osName = "iPhone OS";
            break;
    }

    /* Map to Apple-style code type */
    NSString *codeType;
    switch (report.systemInfo.architecture)
    {
        case PLCrashReportArchitectureARM:
            codeType = @"ARM (Native)";
            lp64 = false;
            break;
        case PLCrashReportArchitectureX86_32:
            codeType = @"X86";
            lp64 = false;
            break;
        case PLCrashReportArchitectureX86_64:
            codeType = @"X86-64";
            lp64 = true;
            break;
        case PLCrashReportArchitecturePPC:
            codeType = @"PPC";
            lp64 = false;
            break;
        default:
            codeType = @"ARM (Native)";
            lp64 = false;
            break;
    }

    /* Application and process info */
    {
        NSString *unknownString = @"???";

        NSString *processName = unknownString;
        NSString *processId = unknownString;
        NSString *processPath = unknownString;
        NSString *parentProcessName = unknownString;
        NSString *parentProcessId = unknownString;

        /* Process information was not available in earlier crash report versions */
        if (report.hasProcessInfo)
        {
            /* Process Name */
            if (report.processInfo.processName != nil)
                    processName = report.processInfo.processName;

            /* PID */
            processId = [[NSNumber numberWithUnsignedInteger:report.processInfo.processID] stringValue];

            /* Process Path */
            if (report.processInfo.processPath != nil)
                    processPath = report.processInfo.processPath;

            /* Parent Process Name */
            if (report.processInfo.parentProcessName != nil)
                    parentProcessName = report.processInfo.parentProcessName;

            /* Parent Process ID */
            parentProcessId = [[NSNumber numberWithUnsignedInteger:report.processInfo.parentProcessID] stringValue];
        }

        NSString *uuid = nil;
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            CFRelease(theUUID);
        }
        
        [reportString appendFormat:@"Incident Identifier: %@\n", uuid];

        if (uuid) {
            CFRelease(uuid);
        }
        
        [reportString appendFormat:@"CrashReporter Key:   %@\n", [[JMC sharedInstance] getUUID]];
        [reportString appendFormat:@"Hardware Model:       %@,%@\n", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];

        [reportString appendFormat:@"Process:         %@ [%@]\n", processName, processId];
        [reportString appendFormat:@"Path:            %@\n", processPath];
        [reportString appendFormat:@"Identifier:      %@\n", report.applicationInfo.applicationIdentifier];
        [reportString appendFormat:@"Version:         %@\n", report.applicationInfo.applicationVersion];
        [reportString appendFormat:@"Code Type:       %@\n", codeType];
        [reportString appendFormat:@"Parent Process:  %@ [%@]\n", parentProcessName, parentProcessId];
    }

    [reportString appendString:@"\n"];

    /* System info */
    [reportString appendFormat:@"Date/Time:       %s\n", [[report.systemInfo.timestamp description] UTF8String]];
    // OS Version must match: /\s([0-9\.]+)\s+\((\w+)/ e.g. iPhone OS 4.3.3 (8J2)
    [reportString appendFormat:@"OS Version:      %s %s (%@)\n", osName, [report.systemInfo.operatingSystemVersion UTF8String], [self osVersionBuild]];
    [reportString appendString:@"Report Version:  104\n"];

    [reportString appendString:@"\n"];

    /* Exception code */
    [reportString appendFormat:@"Exception Type:  %s\n", [report.signalInfo.name UTF8String]];
    [reportString appendFormat:@"Exception Codes: %@ at 0x%" PRIx64 "\n", report.signalInfo.code, report.signalInfo.address];

    for (PLCrashReportThreadInfo *thread in report.threads)
    {
        if (thread.crashed)
        {
            [reportString appendFormat:@"Crashed Thread:  %ld\n", (long)thread.threadNumber];
            break;
        }
    }

    [reportString appendString:@"\n"];

    if (report.hasExceptionInfo)
    {
        [reportString appendString:@"Application Specific Information:\n"];
        [reportString appendFormat:@"*** Terminating app due to uncaught exception '%@', reason: '%@'\n",
                report.exceptionInfo.exceptionName, report.exceptionInfo.exceptionReason];
        [reportString appendString:@"\n"];
    }

    /* Threads */
    PLCrashReportThreadInfo *crashed_thread = nil;
    for (PLCrashReportThreadInfo *thread in report.threads)
    {
        if (thread.crashed)
        {
            [reportString appendFormat:@"Thread %ld Crashed:\n", (long)thread.threadNumber];
            crashed_thread = thread;
        } else
        {
            [reportString appendFormat:@"Thread %ld:\n", (long)thread.threadNumber];
        }
        for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++)
        {
            PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex:frame_idx];
            PLCrashReportBinaryImageInfo *imageInfo;

            /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
            uint64_t baseAddress = 0x0;
            uint64_t pcOffset = 0x0;
            NSString *imageName = @"\?\?\?";

            imageInfo = [report imageForAddress:frameInfo.instructionPointer];
            if (imageInfo != nil)
            {
                imageName = [imageInfo.imageName lastPathComponent];
                baseAddress = imageInfo.imageBaseAddress;
                pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
            }

            [reportString appendFormat:@"%-4ld%-36s0x%08" PRIx64 " 0x%" PRIx64 " + %" PRId64 "\n",
                    (long)frame_idx, [imageName UTF8String], frameInfo.instructionPointer, baseAddress, pcOffset];
        }
        [reportString appendString:@"\n"];
    }

    /* Registers */
    if (crashed_thread != nil)
    {
        [reportString appendFormat:@"Thread %ld crashed with %@ Thread State:\n", (long)crashed_thread.threadNumber, codeType];

        int regColumn = 1;
        for (PLCrashReportRegisterInfo *reg in crashed_thread.registers)
        {
            NSString *reg_fmt;

            /* Use 32-bit or 64-bit fixed width format for the register values */
            if (lp64)
                    reg_fmt = @"%6s:\t0x%016" PRIx64 " ";
            else
                    reg_fmt = @"%6s:\t0x%08" PRIx64 " ";

            [reportString appendFormat:reg_fmt, [reg.registerName UTF8String], reg.registerValue];

            if (regColumn % 4 == 0)
                    [reportString appendString:@"\n"];
            regColumn++;
        }

        if (regColumn % 3 != 0)
                [reportString appendString:@"\n"];

        [reportString appendString:@"\n"];
    }

    /* Images */
    [reportString appendFormat:@"Binary Images:\n"];

    for (PLCrashReportBinaryImageInfo *imageInfo in report.images)
    {
        NSString *uuid;
        /* Fetch the UUID if it exists */
        if (imageInfo.hasImageUUID)
                uuid = imageInfo.imageUUID;
        else
                uuid = @"???";

        NSString *device = @"\?\?\? (\?\?\?)";
      
#ifdef _ARM_ARCH_7 
        device = @"armv7";
#else
#ifdef _ARM_ARCH_6
        device = @"armv6";
#endif
#endif

        /* base_address - terminating_address file_name identifier (<version>) <uuid> file_path */
        [reportString appendFormat:@"0x%" PRIx64 " - 0x%" PRIx64 "  %@ %@ <%@> %@\n",
                imageInfo.imageBaseAddress,
                imageInfo.imageBaseAddress + imageInfo.imageSize,
                [imageInfo.imageName lastPathComponent],
                device,
                uuid,
                imageInfo.imageName];
    }

    return reportString;
}

#pragma mark PLCrashReporter

//
// Called to handle a pending crash report.
//
- (void)handleCrashReport
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;

    // Try loading the crash report
    NSData *crashData = [NSData dataWithData:[crashReporter loadPendingCrashReportDataAndReturnError:&error]];

    NSString *cacheFilename = [NSString stringWithFormat:@"%.0f", [NSDate timeIntervalSinceReferenceDate]];

    if (crashData == nil)
    {
        JMCDLog(@"Could not load crash report: %@", error);
        goto finish;
    } else
    {
        [crashData writeToFile:[_crashesDir stringByAppendingPathComponent:cacheFilename] atomically:YES];
    }

    // check if the next call ran successfully the last time
    if (_crashReportAnalyzerStarted == 0)
    {
        // mark the start of the routine
        _crashReportAnalyzerStarted = 1;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_crashReportAnalyzerStarted] forKey:kCrashReportAnalyzerStarted];

        // We could send the report from here, but we'll just print out
        // some debugging info instead
        PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
        if (report == nil)
        {
            JMCDLog(@"Could not parse crash report");
            goto finish;
        }
        [report release];
    }

    // Purge the report
    finish:
            // mark the end of the routine
            _crashReportAnalyzerStarted = 0;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_crashReportAnalyzerStarted] forKey:kCrashReportAnalyzerStarted];

    [crashReporter purgePendingCrashReport];
    return;
}

@end
