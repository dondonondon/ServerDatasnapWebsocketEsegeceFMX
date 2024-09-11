unit RestAPI.User;

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
  ClassUser = class(TPersistent)
  published
    function GetData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function GetPartnerTypeData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function InsertData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function UpdateData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassUser }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages, RestAPI.Core;

function ClassUser.GetData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  var SQLAdd :=
    'SELECT' + sLineBreak +
    'up.*, pt.type_name' + sLineBreak +
    'FROM' + sLineBreak +
    'user_partner up' + sLineBreak +
    'LEFT JOIN partner_type pt ON pt.partner_type_id = up.partner_type_id' + sLineBreak +
    'ORDER BY' + sLineBreak +
    'partner_name ASC';
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassUser.GetPartnerTypeData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  var SQLAdd :=
    'SELECT * FROM partner_type ORDER BY partner_type_id ASC';
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassUser.InsertData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'INSERT INTO user_partner (partner_name, contact_info, partner_type_id) VALUES(''%s'', ''%s'', ''%s'')',
    [
      ADataRequest.FieldByName('partner_name').AsString,
      ADataRequest.FieldByName('contact_info').AsString,
      ADataRequest.FieldByName('partner_type_id').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassUser.UpdateData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'UPDATE user_partner SET ' + sLineBreak +
    'partner_name = ''%s'', ' + sLineBreak +
    'contact_info = ''%s'', ' + sLineBreak +
    'partner_type_id = ''%s'' ' + sLineBreak +
    'WHERE user_partner_id = ''%s''',
    [
      ADataRequest.FieldByName('partner_name').AsString,
      ADataRequest.FieldByName('contact_info').AsString,
      ADataRequest.FieldByName('partner_type_id').AsString,
      ADataRequest.FieldByName('user_partner_id').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

end.
