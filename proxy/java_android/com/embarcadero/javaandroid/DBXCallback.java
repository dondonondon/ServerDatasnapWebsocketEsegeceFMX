//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

package com.embarcadero.javaandroid;

/**
 * Base class to implement callbacks. The class is used to implement responses
 * for callbacks .
 * 
 */
public abstract class DBXCallback {
	/**
	 * override this method to implement callbacks actions
	 * 
	 * @param params
	 * @return
	 */
	public abstract TJSONValue execute(TJSONValue value, int JSONType);
}
