//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

#import <Foundation/Foundation.h>
#import "DBXValue.h"


/**
 * 
 * @brief Wraps the TimeStamp type and allows it to be null
 *
 */

@interface TDBXTimeStampValue : DBXValue {
@protected bool ValueNull;
@private NSDate* DBXInternalValue;
}


@end

