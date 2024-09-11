unit RestAPI.Radio;

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
  ClassRadio = class(TPersistent)
  published
    function GetDataRadio(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function GetRadioName(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassRadio }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable;

function ClassRadio.GetDataRadio(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  AStatusCode := 404;

  var FQuery := TFDQuery.Create(nil);
  try
    try
      FQuery.Connection := Connection;

      var SQLAdd := 'SELECT * FROM tbl_radio ORDER BY RANDOM() LIMIT 25';
      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnSQLOpen(FQuery);

      if FQuery.IsEmpty then begin
        Result := HelperResponse.CreateResponse(AStatusCode, 'Tidak ada data ditemukan', FQuery, ADataRequest);
        Exit;
      end;

      AStatusCode := 200;
      Result := HelperResponse.CreateResponse(AStatusCode, 'Ok!', FQuery, ADataRequest);
    except on E: Exception do Result := HelperResponse.CreateResponse(AStatusCode, E.Message, FQuery, ADataRequest); end;
  finally
    FQuery.DisposeOf;
  end;
end;

function ClassRadio.GetRadioName(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  AStatusCode := 404;
  var FQuery := TFDQuery.Create(nil);
  try
    try
      FQuery.Connection := Connection;

      if not ADataRequest.FillDataFromString(ADataRequest.FieldByName('request_data').AsString) then begin
        AStatusCode := 500;
        Result := HelperResponse.CreateResponse(AStatusCode, 'Invalid body JSON', FQuery, ADataRequest);
        Exit;
      end;

      var SQLAdd := 'SELECT * FROM tbl_radio WHERE radio_name LIKE '+
        QuotedStr('%' + ADataRequest.FieldByName('radio_name').AsString + '%') +' ORDER BY radio_name ASC LIMIT 25';
      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnSQLOpen(FQuery);

      if FQuery.IsEmpty then begin
        Result := HelperResponse.CreateResponse(AStatusCode, 'Tidak ada data ditemukan', FQuery, ADataRequest);
        Exit;
      end;

      AStatusCode := 200;
      Result := HelperResponse.CreateResponse(AStatusCode, 'Ok!', FQuery, ADataRequest);
    except on E: Exception do Result := HelperResponse.CreateResponse(AStatusCode, E.Message, FQuery, ADataRequest); end;
  finally
    FQuery.DisposeOf;
  end;
end;

end.
