//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

#import "TDBXDateValue.h"


@implementation TDBXDateValue
-(id)init{
	self = [super init];
	if (self) {
		[self setDBXType:DateType];
	}
	return self;
}
-(void) dealloc{
	[super dealloc];
}
-(void) SetNull {
	ValueNull = YES;
	DBXInternalValue = 0;
}
-(bool) isNull {
	return ValueNull;
}

-(void) SetAsTDBXDate:(long) value{
	ValueNull = NO;
	DBXInternalValue = value;
}

-(long) GetAsTDBXDate {
	return DBXInternalValue;
}


@end
