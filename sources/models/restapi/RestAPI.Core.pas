unit RestAPI.Core;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  System.JSON, FMX.Dialogs, System.NetEncoding,
  DBClient, System.StrUtils, System.DateUtils;

type
  TRestCore = class(TPersistent)
  published
    class function GetData(ASQL : String; Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    class function InsertData(ASQL : String; Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    class function UpdateData(ASQL : String; Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ TRestCore }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages;

class function TRestCore.GetData(ASQL: String; Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  AStatusCode := TRestStatus.NOT_FOUND;

  var FQuery := TFDQuery.Create(nil);
  try
    FQuery.FetchOptions.RowsetSize := 10000;
    try
      FQuery.Connection := Connection;

      var SQLAdd := ASQL;
      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnSQLOpen(FQuery);

      if FQuery.IsEmpty then begin
        Result := HelperResponse.CreateResponse(AStatusCode, TRestMessage.NOT_FOUND_MESSAGE, FQuery, ADataRequest);
        Exit;
      end;

      AStatusCode := TRestStatus.OK;
      Result := HelperResponse.CreateResponse(AStatusCode, TRestMessage.OK_MESSAGE, FQuery, ADataRequest);
    except on E: Exception do Result := HelperResponse.CreateResponse(AStatusCode, E.Message, FQuery, ADataRequest); end;
  finally
    FQuery.DisposeOf;
  end;
end;

class function TRestCore.InsertData(ASQL: String; Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  AStatusCode := TRestStatus.NOT_FOUND;

  var FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := Connection;
    FQuery.FetchOptions.RowsetSize := 10000;

    Connection.StartTransaction;
    try
      var SQLAdd := ASQL;

      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnExecSQL(FQuery);

      Connection.Commit;

      AStatusCode := TRestStatus.OK;
      Result := HelperResponse.CreateResponse(AStatusCode, TRestMessage.OK_MESSAGE, FQuery, ADataRequest);
    except on E: Exception do
      begin
        Connection.Rollback;
        Result := HelperResponse.CreateResponse(AStatusCode, E.Message, FQuery, ADataRequest);
      end;
    end;
  finally
    FQuery.DisposeOf;
  end;
end;

class function TRestCore.UpdateData(ASQL: String; Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin

end;

end.
