//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

#import "DSRESTParameterMetaData.h"


@implementation DSRESTParameterMetaData

@synthesize Name;
@synthesize Direction;
@synthesize DBXType;
@synthesize TypeName;

-(void) dealloc {
	//[Name release];
	//[TypeName release];
	[super dealloc];
}

+(id) parameterWithName: (NSString *) aname withDirection:(DSRESTParamDirection)adirection 
			withDBXType: (DBXDataTypes) aDBXType withTypeName:(NSString *) aTypeName{

	return [[[DSRESTParameterMetaData alloc] initWithMetadata:aname withDirection:adirection
												 withDBXType:aDBXType withTypeName:aTypeName] autorelease];
}
-(id) initWithMetadata:(NSString*)aname withDirection:(DSRESTParamDirection)adirection 
		  withDBXType: (DBXDataTypes) aDBXType withTypeName:(NSString *)aTypeName{
	self = [super init];
	if (self) {
		Name = aname;
		Direction = adirection;
		DBXType = aDBXType; 
		TypeName = aTypeName;
	}
	return self;

}





@end
