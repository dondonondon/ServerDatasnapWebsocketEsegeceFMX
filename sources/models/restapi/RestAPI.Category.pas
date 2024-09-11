unit RestAPI.Category;

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
  ClassCategory = class(TPersistent)
  published
    function GetData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function InsertData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function UpdateData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassCategory }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages, RestAPI.Core;

function ClassCategory.GetData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  var SQLAdd := 'SELECT * FROM categories ORDER BY category_name ASC';
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassCategory.InsertData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'INSERT INTO categories (category_name, description) VALUES(''%s'', ''%s'')',
    [
      ADataRequest.FieldByName('category_name').AsString,
      ADataRequest.FieldByName('description').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassCategory.UpdateData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'UPDATE categories SET category_name = ''%s'', description = ''%s'' WHERE category_id = ''%s''',
    [
      ADataRequest.FieldByName('category_name').AsString,
      ADataRequest.FieldByName('description').AsString,
      ADataRequest.FieldByName('category_id').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

end.
