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
 * TDataSet is the base class for all dataset components that represent data in rows and columns.
 *
 */

public class TDataSet extends TDBXReader {
	public TDataSet(TParams params, TJSONObject value) {
		super(params, value);
	}

	/**
	 *  Returns a TDataSet created by the information contained in the JSONObject
	 * 
	 * @param value a TJSONObject that contains the parameters for create the TDataSet  
	 * @return return the TDataSet object created
	 * @throws DBXException
	 */
	
	public static TDataSet createFrom(TJSONObject value) throws DBXException{
		TParams params = TParams.CreateParametersFromMetadata(value
				.getJSONArray("table"));
		TDataSet dst = new TDataSet(params, value);
		return dst;
	}
}
