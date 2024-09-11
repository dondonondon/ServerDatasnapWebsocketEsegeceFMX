unit Datasnap.Core.Response;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  System.JSON, FMX.Dialogs, Data.Win.ADODB, System.NetEncoding,
  DBClient, System.StrUtils, System.DateUtils;

type
  HelperQuery = class helper for TFDQuery
    function toJSON(AStatusCode : Integer; AMessage : String) : String; overload;
    function toJSON(AStatusCode : Integer; AMessage : String; AMemoryTable : TFDMemTable) : String; overload;
  end;

  HelperJSON = class
    class function toJSON(AStatusCode : Integer; AMessage : String; AMemoryTable : TFDMemTable) : String; overload;
  end;

  HelperResponse = class
    class function CreateResponse(AStatusCode : Integer; AMessage : String; ADataResponse : TDataset; ARequest : TDataSet = nil) : String; overload;
  end;

implementation

{ HelperUniQuery }

uses BFA.Global.Func;

function HelperQuery.toJSON(AStatusCode: Integer; AMessage: String): String;
var
  FResult, FData : TJSONObject;
  FTemp : TJsonArray;
begin
  Result := HelperResponse.CreateResponse(AStatusCode, AMessage, Self);
end;

{ HelperJSON }

class function HelperJSON.toJSON(AStatusCode: Integer; AMessage: String;
  AMemoryTable: TFDMemTable): String;
begin
  Result := HelperResponse.CreateResponse(AStatusCode, AMessage, AMemoryTable);
end;

function HelperQuery.toJSON(AStatusCode: Integer; AMessage: String;
  AMemoryTable: TFDMemTable): String;
begin
  Result := HelperResponse.CreateResponse(AStatusCode, AMessage, Self, AMemoryTable);
end;

{ HelperResponse }

class function HelperResponse.CreateResponse(AStatusCode: Integer;
  AMessage: String; ADataResponse, ARequest: TDataSet): String;
var
  FResult, FData : TJSONObject;
  FTemp : TJsonArray;
  FValue : String;
begin
  if not ADataResponse.IsEmpty then
    ADataResponse.First;

  FResult := TJSONObject.Create;
  try
    FResult.AddPair('status', TJSONNumber.Create(AStatusCode));
    FResult.AddPair('messages', AMessage);
    FResult.AddPair('servertime', DateTimeToUnix(Now).ToString);

    if Assigned(ARequest) then begin
      FData := TJSONObject.Create;
      for var i := 0 to ARequest.FieldDefs.Count - 1 do
        FData.AddPair(ARequest.FieldDefs[i].Name, ARequest.FieldByName(ARequest.FieldDefs[i].Name).AsString);

      FResult.AddPair('request_detail', FData);
    end;

    FTemp := TJSONArray.Create;
    if not ADataResponse.IsEmpty then begin
      for var i := 0 to ADataResponse.RecordCount - 1 do begin
        FData := TJSONObject.Create;
        for var ii := 0 to ADataResponse.FieldDefs.Count - 1 do begin
          if ADataResponse.FieldDefs[ii].DataType = ftDateTime then begin
            FData.AddPair(ADataResponse.FieldDefs[ii].Name, FormatDateTime('yyyy-mm-dd hh:nn:ss',
              ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsDateTime));
            FData.AddPair(ADataResponse.FieldDefs[ii].Name + '_unix',
              DateTimeToUnix(ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsDateTime).ToString);
          end else if ADataResponse.FieldDefs[ii].DataType = ftDate then begin
            FData.AddPair(ADataResponse.FieldDefs[ii].Name, FormatDateTime('yyyy-mm-dd',
              ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsDateTime));
            FData.AddPair(ADataResponse.FieldDefs[ii].Name + '_unix',
              DateTimeToUnix(ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsDateTime).ToString);
          end else begin
            FValue := ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsString;

            if HelperCheck.IsNumber(FValue) then
              FData.AddPair(ADataResponse.FieldDefs[ii].Name, TJSONNumber.Create(FValue))
            else if ADataResponse.FieldDefs[ii].DataType = ftBoolean then
              FData.AddPair(ADataResponse.FieldDefs[ii].Name, TJSONBool.Create(ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsBoolean))
            else
              FData.AddPair(ADataResponse.FieldDefs[ii].Name, FValue);

//            FData.AddPair(ADataResponse.FieldDefs[ii].Name, ADataResponse.FieldByName(ADataResponse.FieldDefs[ii].Name).AsString);
          end;
        end;
        FTemp.AddElement(FData);
        ADataResponse.Next;
      end;
    end;
    FResult.AddPair('data', FTemp);

    Result := FResult.ToJSON;
  finally
    FResult.DisposeOf;
  end;
end;

end.
