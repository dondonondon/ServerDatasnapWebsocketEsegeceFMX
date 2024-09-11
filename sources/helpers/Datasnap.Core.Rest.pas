unit Datasnap.Core.Rest;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  System.JSON, FMX.Dialogs, Data.Win.ADODB,
  DBClient, FMX.Forms, System.StrUtils;

type
  TExecFunc = function(Connection : TFDConnection; ARequestDetail, ARequestData : TFDMemTable; const RawData : TStringList = nil): string of object;
  TExecFuncAPI = function(Connection : TFDConnection; AData : TFDMemTable; out AStatusCode : Integer) : String of Object;

  TClassHelper = class
  private
    FData: TStringList;
    FGUID: String;
    FIP: String;
    FStatusCode: Integer;
    FConnection: TFDConnection;
    FRequestMethod: String;
    FRequestClass: String;

  published
    function CallMethod(JSON : String) : String;
    function CallMethodAPI(JSON : String) : String;
    function CallMethodAPIRPC(JSON : String) : String;
    function FillJSONError (Code : Integer; FMessage : String) : String;
  public
    property Connection : TFDConnection read FConnection write FConnection;
    property Data : TStringList read FData write FData;
    property GUID : String read FGUID write FGUID;
    property IP : String read FIP write FIP;
    property StatusCode : Integer read FStatusCode write FStatusCode;

    property RequestClass : String read FRequestClass write FRequestClass;
    property RequestMethod : String read FRequestMethod write FRequestMethod;

    constructor Create;
    destructor Destroy; override;
  end;

procedure RegisterClassAPI;

implementation

{ TClassHelper }

uses BFA.Helper.MemoryTable, RestAPI.Sample, Datasnap.Core.Response,
  RestAPI.Radio, RPC.Radio, RestAPI.Category, RestAPI.Product, RestAPI.Stock,
  RestAPI.Transaction, RestAPI.User;

function TClassHelper.CallMethod(JSON: String): String;
var
  Routine : TMethod;
  Exec : TExecFunc;
begin
  Data.AddPair('guid', GUID);
  Data.AddPair('ip', IP);

  var FRequest := TFDMemTable.Create(nil);
  var FDetailRequest := TFDMemTable.Create(nil);
  var FDataRequest := TFDMemTable.Create(nil);
  var FQuery := TFDQuery.Create(nil);
  try
    Result := FillJSONError(400, 'No Messages');
    try
      FQuery.Connection := Connection;

      FRequest.FillDataFromString(JSON);

      if not Assigned(FRequest.FindField('request_data')) then begin
        Result := FQuery.toJSON(409, 'Invalid Body Request. Please Update Application!');
        Exit;
      end;

      if not Assigned(FRequest.FindField('request_detail')) then begin
        Result := FQuery.toJSON(409, 'Invalid Body Request. Please Update Application!');
        Exit;
      end;

      FDetailRequest.FillDataFromString(FRequest.FieldByName('request_detail').AsString);
      FDataRequest.FillDataFromString(FRequest.FieldByName('request_data').AsString);

      Data.AddPair('classname', FDetailRequest.FieldByName('classname').AsString);
      Data.AddPair('methodname', FDetailRequest.FieldByName('rpc').AsString);

      Data.AddPair('params', JSON);

      if Assigned(FDetailRequest.FindField('GUID')) then
        Data.Values['guid'] := FDetailRequest.FieldByName('GUID').AsString;

      var LClass := FindClass(FDetailRequest.FieldByName('classname').AsString);

      Routine.Data := Pointer(LClass);    //ClassPasien
      Routine.Code := LClass.MethodAddress(FDetailRequest.FieldByName('rpc').AsString);
      if not Assigned(Routine.Code) then
        Exit;

      Exec := TExecFunc(Routine);

      Result := Exec(Connection, FDetailRequest, FDataRequest, Data);
    except on E : Exception do Result := FillJSONError(400, E.Message); end;
  finally
    FQuery.DisposeOf;
    FRequest.DisposeOf;
    FDetailRequest.DisposeOf;
    FDataRequest.DisposeOf;
  end;
end;

function TClassHelper.CallMethodAPI(JSON: String): String;
var
  Routine : TMethod;
  Exec : TExecFuncAPI;
  AStatusCode : Integer;
begin
  AStatusCode := 404;

  var FRequest := TFDMemTable.Create(nil);
  try
    Result := FillJSONError(404, 'No Messages');
    try
      if JSON <> '' then begin
        if not FRequest.FillDataFromString(JSON) then begin
          Result := FillJSONError(400, 'Invalid Body JSON');
          Exit;
        end;
      end;

      var LClass := FindClass(RequestClass);

      Routine.Data := Pointer(LClass);
      Routine.Code := LClass.MethodAddress(RequestMethod);
      if not Assigned(Routine.Code) then begin
        Result := FillJSONError(404, 'Method not found!');
        Exit;
      end;

      Exec := TExecFuncAPI(Routine);
      Result := Exec(Connection, FRequest, AStatusCode);
    except on E : Exception do Result := FillJSONError(500, E.Message); end;
  finally
    StatusCode := AStatusCode;
    FRequest.DisposeOf;
  end;
end;

function TClassHelper.CallMethodAPIRPC(JSON: String): String;
var
  Routine : TMethod;
  Exec : TExecFunc;
begin
  Data.AddPair('guid', GUID);
  Data.AddPair('ip', IP);

  var FRequest := TFDMemTable.Create(nil);
  var FDetailRequest := TFDMemTable.Create(nil);
  var FDataRequest := TFDMemTable.Create(nil);
  var FQuery := TFDQuery.Create(nil);
  try
    Result := FillJSONError(400, 'No Messages');
    try
      FQuery.Connection := Connection;

      FRequest.FillDataFromString(JSON);

      if not Assigned(FRequest.FindField('request_data')) then begin
        Result := FQuery.toJSON(409, 'Invalid Body Request. Please Update Application!');
        Exit;
      end;

      if not Assigned(FRequest.FindField('request_detail')) then begin
        Result := FQuery.toJSON(409, 'Invalid Body Request. Please Update Application!');
        Exit;
      end;

      FDetailRequest.FillDataFromString(FRequest.FieldByName('request_detail').AsString);
      FDataRequest.FillDataFromString(FRequest.FieldByName('request_data').AsString);

      Data.AddPair('classname', FDetailRequest.FieldByName('classname').AsString);
      Data.AddPair('methodname', FDetailRequest.FieldByName('rpc').AsString);

      Data.AddPair('params', JSON);

      if Assigned(FDetailRequest.FindField('GUID')) then
        Data.Values['guid'] := FDetailRequest.FieldByName('GUID').AsString;

      var LClass := FindClass(FDetailRequest.FieldByName('classname').AsString);

      Routine.Data := Pointer(LClass);
      Routine.Code := LClass.MethodAddress(FDetailRequest.FieldByName('rpc').AsString);
      if not Assigned(Routine.Code) then
        Exit;

      Exec := TExecFunc(Routine);

      Result := Exec(Connection, FDetailRequest, FDataRequest, Data);  StatusCode := 200;

      try
        FRequest.FillDataFromString(Result);
        if Assigned(FRequest.FindField('STATUS')) then StatusCode := StrToIntDef(FRequest.FieldByName('STATUS').AsString, 200);
      except on E : Exception do Result := FillJSONError(400, E.Message); end;
    except on E : Exception do Result := FillJSONError(400, E.Message); end;
  finally
    FQuery.DisposeOf;
    FRequest.DisposeOf;
    FDetailRequest.DisposeOf;
    FDataRequest.DisposeOf;
  end;
end;

constructor TClassHelper.Create;
begin
  FData := TStringList.Create;
end;

destructor TClassHelper.Destroy;
begin
  FData.DisposeOf;
  inherited;
end;

function TClassHelper.FillJSONError(Code: Integer; FMessage: String): String;
begin
  StatusCode := Code;

  Result :=
    '{'#13 +
    ' "status": ' + Code.toString + ','#13 +
    ' "message": "' + FMessage + '"'#13 +
    '}';
end;

procedure RegisterClassAPI;
begin
  RegisterClasses(
    [
      ClassSample, ClassRadio,
      RPCRadio,
      ClassUser,
      ClassTransaction,
      ClassProduct,
      ClassCategory,
      ClassStock
    ]
  );
end;

end.
