//*******************************************************
//
//               Delphi DataSnap Framework
//
// Copyright(c) 1995-2023 Embarcadero Technologies, Inc.
//
//*******************************************************

package com.embarcadero.javaandroid;

/**
 * 
 * Wraps the Int8 type and allows it to be null
 *
 */

public class TDBXInt8Value extends DBXValue {

	protected boolean ValueNull = false;
	private int DBXIntValue;
	
	public TDBXInt8Value() {
		super();
		setDBXType(DBXDataTypes.Int8Type);
	}
	
	@Override
	public void setNull() {
		ValueNull = true;
		DBXIntValue = 0;
	}

	public boolean isNull() {
		return ValueNull;
	}
	
	@Override
	public void SetAsInt8(int Value) throws DBXException {
		DBXIntValue = Value;
		ValueNull = false;
	}

	@Override
	public int GetAsInt8() throws DBXException {
		return DBXIntValue;
	}

}
