//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

#import "DSAdminRestClient.h"

@implementation DSAdminRestClient

@synthesize Connection;

-(id) initWithConnection:(DSRESTConnection *) aConnection {
	self  = [self init];
	if (self) {
		self.Connection = aConnection ;
	}
	return self;
	
}
@end

