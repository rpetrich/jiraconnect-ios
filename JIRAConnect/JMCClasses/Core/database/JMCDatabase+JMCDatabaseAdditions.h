// Based on FMDB. License see Licenses/FMDB.txt.

#import <Foundation/Foundation.h>
@interface JMCDatabase (JMCDatabaseAdditions)


- (int)intForQuery:(NSString*)objs, ...;
- (long)longForQuery:(NSString*)objs, ...; 
- (BOOL)boolForQuery:(NSString*)objs, ...;
- (double)doubleForQuery:(NSString*)objs, ...;
- (NSString*)stringForQuery:(NSString*)objs, ...; 
- (NSData*)dataForQuery:(NSString*)objs, ...;
- (NSDate*)dateForQuery:(NSString*)objs, ...;

// Notice that there's no dataNoCopyForQuery:.
// That would be a bad idea, because we close out the result set, and then what
// happens to the data that we just didn't copy?  Who knows, not I.


- (BOOL)tableExists:(NSString*)tableName;
- (JMCResultSet*)getSchema;
- (JMCResultSet*)getTableSchema:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)tableName columnName:(NSString*)columnName;

- (BOOL)validateSQL:(NSString*)sql error:(NSError**)error;

@end
