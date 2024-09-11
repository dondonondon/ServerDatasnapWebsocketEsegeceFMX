unit RPC.Radio;

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
  RPCRadio = class(TPersistent)
  published
    function GetDataRadio(Connection : TFDConnection; ARequestDetail, ARequestData : TFDMemTable;
      const ARawData : TStringList = nil) : String;
    function GetRadioName(Connection : TFDConnection; ARequestDetail, ARequestData : TFDMemTable;
      const ARawData : TStringList = nil) : String;
  end;

implementation

{ ClassRadio }

uses BFA.Global.Func, Datasnap.Core.Response;

function RPCRadio.GetDataRadio(Connection: TFDConnection; ARequestDetail,
  ARequestData: TFDMemTable; const ARawData: TStringList): String;
begin
  var FQuery := TFDQuery.Create(nil);
  try
    try
      FQuery.Connection := Connection;

      var SQLAdd := 'SELECT * FROM tbl_radio ORDER BY RANDOM() LIMIT 25';
      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnSQLOpen(FQuery);

      if FQuery.IsEmpty then begin
        Result := HelperResponse.CreateResponse(404, 'Tidak ada data ditemukan', FQuery, ARequestDetail);
        Exit;
      end;

      Result := HelperResponse.CreateResponse(200, 'Ok!', FQuery, ARequestDetail);
    except on E: Exception do Result := HelperResponse.CreateResponse(404, E.Message, FQuery, ARequestDetail); end;
  finally
    FQuery.DisposeOf;
  end;
end;

function RPCRadio.GetRadioName(Connection: TFDConnection; ARequestDetail,
  ARequestData: TFDMemTable; const ARawData: TStringList): String;
begin
  var FQuery := TFDQuery.Create(nil);
  try
    try
      FQuery.Connection := Connection;

      var SQLAdd := 'SELECT * FROM tbl_radio WHERE radio_name LIKE '+
        QuotedStr('%' + ARequestData.FieldByName('value').AsString + '%') +' ORDER BY radio_name ASC LIMIT 25';
      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnSQLOpen(FQuery);

      if FQuery.IsEmpty then begin
        Result := HelperResponse.CreateResponse(404, 'Tidak ada data ditemukan', FQuery, ARequestDetail);
        Exit;
      end;

      Result := HelperResponse.CreateResponse(200, 'Ok!', FQuery, ARequestDetail);
    except on E: Exception do Result := HelperResponse.CreateResponse(404, E.Message, FQuery, ARequestDetail); end;
  finally
    FQuery.DisposeOf;
  end;
end;

end.
