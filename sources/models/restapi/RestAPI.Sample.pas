unit RestAPI.Sample;

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
  ClassSample = class(TPersistent)
  published
    function HelloWorld(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassSample }

function ClassSample.HelloWorld(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  Result := 'Hello World';
  AStatusCode := 200;
end;

end.
