//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

#import "TDBXAnsiStringValue.h"


@implementation TDBXAnsiStringValue
-(id)init{
	self = [super init];
	if (self) {
		[self setDBXType:WideStringType];
	}
	return self;
}
-(void) dealloc{
	[DBXStringValue release];
	[super dealloc];
}
-(void) SetNull {
	ValueNull = YES;
	[DBXStringValue release];
	DBXStringValue = @"";
	[DBXStringValue retain];
}

-(bool) isNull {
	return ValueNull;
}

-(void) SetAsString:(NSString*) value{
	ValueNull = NO;
	[DBXStringValue release];
	DBXStringValue = [value retain];
}

-(NSString*) GetAsString {
	return DBXStringValue;
}

@end
