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

-(void) SetNull {
	ValueNull = YES;
	DBXStringValue = @"";
}

-(bool) isNull {
	return ValueNull;
}

-(void) SetAsString:(NSString*) value{
	ValueNull = NO;
	DBXStringValue = value;
}

-(NSString*) GetAsString {
	return DBXStringValue;
}

@end
