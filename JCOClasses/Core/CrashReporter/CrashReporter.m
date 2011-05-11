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

#define USER_AGENT @"CrashReportSender/1.0"

@interface CrashReporter ()


- (void)handleCrashReport;

- (NSString *)_crashLogStringForReport:(PLCrashReport *)report;

@end

@implementation CrashReporter

+ (CrashReporter *)sharedCrashReportSender
{
	static CrashReporter *crashReportSender = nil;
	
	if (crashReportSender == nil) {
		crashReportSender = [[CrashReporter alloc] init];
	}
	
	return crashReportSender;
}

- (id) init
{
	self = [super init];

	if ( self != nil)
	{
		_amountCrashes = 0;
		_crashIdenticalCurrentVersion = YES;
		
		NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kCrashReportAnalyzerStarted];
		if (testValue == nil)
		{
			_crashReportAnalyzerStarted = 0;		
		} else {
			_crashReportAnalyzerStarted = [[NSUserDefaults standardUserDefaults] integerForKey:kCrashReportAnalyzerStarted];
		}
		
		testValue = nil;
		testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kCrashReportActivated];
		if (testValue == nil)
		{
			_crashReportActivated = YES;
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kCrashReportActivated];
		} else {
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
				NSDictionary *attributes = [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedLong: 0755] forKey: NSFilePosixPermissions];
				NSError *theError = NULL;
				
				[fm createDirectoryAtPath:_crashesDir withIntermediateDirectories: YES attributes: attributes error: &theError];
			}
			
			PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
			NSError *error;

			// Check if we previously crashed
			if ([crashReporter hasPendingCrashReport])
				[self handleCrashReport];

			// Enable the Crash Reporter
			if (![crashReporter enableCrashReporterAndReturnError: &error])
				NSLog(@"Warning: Could not enable crash reporter: %@", error);
		}
	}
	return self;
}


- (void) dealloc
{
	[super dealloc];
	[_crashesDir release];
	[_crashFiles release];
}


- (BOOL)hasPendingCrashReport
{
	NSLog(@"crashReportActivated: %d", _crashReportActivated);
	if (_crashReportActivated)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		
		if ([_crashFiles count] == 0 && [fm fileExistsAtPath:_crashesDir])
		{
			NSString *file;
            NSError *error = nil;
            
			NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath: _crashesDir];
			
			while (file = [dirEnum nextObject])
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
			_amountCrashes = [_crashFiles count];
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
	
	for (int i=0; i < [_crashFiles count]; i++)
	{		
		[fm removeItemAtPath:[_crashesDir stringByAppendingPathComponent:[_crashFiles objectAtIndex:i]] error:&error];
	}
	[_crashFiles removeAllObjects];	
}

- (NSArray*)crashReports
{
	NSError *error;
	
	NSMutableArray* crashReports = [NSMutableArray arrayWithCapacity:[_crashFiles count]];

	for (int i=0; i < [_crashFiles count]; i++)
	{
		NSString *filename = [_crashesDir stringByAppendingPathComponent:[_crashFiles objectAtIndex:i]];
		NSData *crashData = [NSData dataWithContentsOfFile:filename];
		
		if ([crashData length] > 0)
		{
			// crashData here is simply a protobuf!

			PLCrashReport *report = [[[PLCrashReport alloc] initWithData:crashData error:&error] autorelease];
			
			NSString *crashLogString = [self _crashLogStringForReport:report];

			
			if ([report.applicationInfo.applicationVersion compare:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] != NSOrderedSame)
			{
				_crashIdenticalCurrentVersion = NO;
			}
			
			NSMutableDictionary* crashDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												  report.applicationInfo.applicationIdentifier, @"appId",
												  [[UIDevice currentDevice] systemVersion], @"systemVersion",
												  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], @"senderVersion", 
												  report.applicationInfo.applicationVersion, @"appVersion",
												  crashLogString, @"crashLog",
												  nil];
			
			NSLog(@"CrashLogStringLen: %d, ProtoBufLen: %d", [crashLogString length], [crashData length]);
			
			[crashReports addObject:crashDataDict];
		}
	}
	return crashReports;
}


- (NSString *)_crashLogStringForReport:(PLCrashReport *)report
{
	NSMutableString *xmlString = [NSMutableString string];

	/* Header */
    boolean_t lp64;
	
	/* Map to apple style OS nane */
	const char *osName;
	switch (report.systemInfo.operatingSystem) {
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
	switch (report.systemInfo.architecture) {
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
	
	[xmlString appendString:@"Incident Identifier: [TODO]\n"];
	[xmlString appendString:@"CrashReporter Key:   [TODO]\n"];
    
    /* Application and process info */
    {
        NSString *unknownString = @"???";
        
        NSString *processName = unknownString;
        NSString *processId = unknownString;
        NSString *processPath = unknownString;
        NSString *parentProcessName = unknownString;
        NSString *parentProcessId = unknownString;
        
        /* Process information was not available in earlier crash report versions */
        if (report.hasProcessInfo) {
            /* Process Name */
            if (report.processInfo.processName != nil)
                processName = report.processInfo.processName;
            
            /* PID */
            processId = [[NSNumber numberWithUnsignedInteger: report.processInfo.processID] stringValue];
            
            /* Process Path */
            if (report.processInfo.processPath != nil)
                processPath = report.processInfo.processPath;
            
            /* Parent Process Name */
            if (report.processInfo.parentProcessName != nil)
                parentProcessName = report.processInfo.parentProcessName;
            
            /* Parent Process ID */
            parentProcessId = [[NSNumber numberWithUnsignedInteger: report.processInfo.parentProcessID] stringValue];
        }
        
        [xmlString appendFormat: @"Process:         %@ [%@]\n", processName, processId];
        [xmlString appendFormat: @"Path:            %@\n", processPath];
        [xmlString appendFormat: @"Identifier:      %@\n", report.applicationInfo.applicationIdentifier];
        [xmlString appendFormat: @"Version:         %@\n", report.applicationInfo.applicationVersion];
        [xmlString appendFormat: @"Code Type:       %@\n", codeType];
        [xmlString appendFormat: @"Parent Process:  %@ [%@]\n", parentProcessName, parentProcessId];
    }
    
	[xmlString appendString:@"\n"];
	
	/* System info */
	[xmlString appendFormat:@"Date/Time:       %s\n", [[report.systemInfo.timestamp description] UTF8String]];
	[xmlString appendFormat:@"OS Version:      %s %s\n", osName, [report.systemInfo.operatingSystemVersion UTF8String]];
	[xmlString appendString:@"Report Version:  104\n"];
	
	[xmlString appendString:@"\n"];
	
	/* Exception code */
	[xmlString appendFormat:@"Exception Type:  %s\n", [report.signalInfo.name UTF8String]];
    [xmlString appendFormat:@"Exception Codes: %@ at 0x%" PRIx64 "\n", report.signalInfo.code, report.signalInfo.address];

    for (PLCrashReportThreadInfo *thread in report.threads) {
        if (thread.crashed) {
            [xmlString appendFormat: @"Crashed Thread:  %ld\n", (long) thread.threadNumber];
            break;
        }
    }
	
	[xmlString appendString:@"\n"];
	
    if (report.hasExceptionInfo) {
        [xmlString appendString:@"Application Specific Information:\n"];
        [xmlString appendFormat: @"*** Terminating app due to uncaught exception '%@', reason: '%@'\n",
         report.exceptionInfo.exceptionName, report.exceptionInfo.exceptionReason];
        [xmlString appendString:@"\n"];
    }
    
	/* Threads */
    PLCrashReportThreadInfo *crashed_thread = nil;
    for (PLCrashReportThreadInfo *thread in report.threads) {
        if (thread.crashed) {
            [xmlString appendFormat: @"Thread %ld Crashed:\n", (long) thread.threadNumber];
            crashed_thread = thread;
        } else {
            [xmlString appendFormat: @"Thread %ld:\n", (long) thread.threadNumber];
        }
        for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex: frame_idx];
            PLCrashReportBinaryImageInfo *imageInfo;
            
            /* Base image address containing instrumention pointer, offset of the IP from that base
             * address, and the associated image name */
            uint64_t baseAddress = 0x0;
            uint64_t pcOffset = 0x0;
            NSString *imageName = @"\?\?\?";
            
            imageInfo = [report imageForAddress: frameInfo.instructionPointer];
            if (imageInfo != nil) {
                imageName = [imageInfo.imageName lastPathComponent];
                baseAddress = imageInfo.imageBaseAddress;
                pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
            }
            
            [xmlString appendFormat: @"%-4ld%-36s0x%08" PRIx64 " 0x%" PRIx64 " + %" PRId64 "\n", 
             (long) frame_idx, [imageName UTF8String], frameInfo.instructionPointer, baseAddress, pcOffset];
        }
        [xmlString appendString: @"\n"];
    }
    
    /* Registers */
    if (crashed_thread != nil) {
        [xmlString appendFormat: @"Thread %ld crashed with %@ Thread State:\n", (long) crashed_thread.threadNumber, codeType];
        
        int regColumn = 1;
        for (PLCrashReportRegisterInfo *reg in crashed_thread.registers) {
            NSString *reg_fmt;
            
            /* Use 32-bit or 64-bit fixed width format for the register values */
            if (lp64)
                reg_fmt = @"%6s:\t0x%016" PRIx64 " ";
            else
                reg_fmt = @"%6s:\t0x%08" PRIx64 " ";
            
            [xmlString appendFormat: reg_fmt, [reg.registerName UTF8String], reg.registerValue];
            
            if (regColumn % 4 == 0)
                [xmlString appendString: @"\n"];
            regColumn++;
        }
        
        if (regColumn % 3 != 0)
            [xmlString appendString: @"\n"];
        
        [xmlString appendString: @"\n"];
    }
	
	/* Images */
	[xmlString appendFormat:@"Binary Images:\n"];

    for (PLCrashReportBinaryImageInfo *imageInfo in report.images) {
		NSString *uuid;
		/* Fetch the UUID if it exists */
		if (imageInfo.hasImageUUID)
			uuid = imageInfo.imageUUID;
		else
			uuid = @"???";
		
        NSString *device = @"\?\?\? (\?\?\?)";
        
#ifdef _ARM_ARCH_6
        device = @"armv6";
#endif
                
#ifdef _ARM_ARCH_7 
        device = @"armv7";
#endif
        
		/* base_address - terminating_address file_name identifier (<version>) <uuid> file_path */
		[xmlString appendFormat:@"0x%" PRIx64 " - 0x%" PRIx64 "  %@ %@ <%@> %@\n",
					 imageInfo.imageBaseAddress,
					 imageInfo.imageBaseAddress + imageInfo.imageSize,
					 [imageInfo.imageName lastPathComponent],
					 device,
					 uuid,
					 imageInfo.imageName];
	}
	
	return xmlString;
}

#pragma mark PLCrashReporter

//
// Called to handle a pending crash report.
//
- (void) handleCrashReport
{
	PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
	NSError *error;
	
	// Try loading the crash report
	NSData *crashData = [NSData dataWithData:[crashReporter loadPendingCrashReportDataAndReturnError: &error]];
	
	NSString *cacheFilename = [NSString stringWithFormat: @"%.0f", [NSDate timeIntervalSinceReferenceDate]];
	
	if (crashData == nil) {
		NSLog(@"Could not load crash report: %@", error);
		goto finish;
	} else {
		[crashData writeToFile:[_crashesDir stringByAppendingPathComponent: cacheFilename] atomically:YES];
	}
	
	// check if the next call ran successfully the last time
	if (_crashReportAnalyzerStarted == 0)
	{
		// mark the start of the routine
		_crashReportAnalyzerStarted = 1;
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_crashReportAnalyzerStarted] forKey:kCrashReportAnalyzerStarted];
		
		// We could send the report from here, but we'll just print out
		// some debugging info instead
		PLCrashReport *report = [[[PLCrashReport alloc] initWithData: [crashData retain] error: &error] autorelease];
		if (report == nil) {
			NSLog(@"Could not parse crash report");
			goto finish;
		}
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
