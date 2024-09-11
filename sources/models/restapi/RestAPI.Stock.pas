unit RestAPI.Stock;

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
  ClassStock = class(TPersistent)
  published
    function GetData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function GetStock(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassStock }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages, RestAPI.Core;

function ClassStock.GetData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := '';

  if Assigned(ADataRequest.FindField('page')) then
    if ADataRequest.FieldByName('page').AsInteger > 0 then
      SQLAdd := 'LIMIT ' + ((ADataRequest.FieldByName('page').AsInteger - 1) * 1000).ToString + ', 1000';

  SQLAdd :=
    'SELECT' + sLineBreak +
    'stocks.*,' + sLineBreak +
    'products.product_name,' + sLineBreak +
    'products.product_sku product_sku_main,' + sLineBreak +
    'products.price,' + sLineBreak +
    'user_partner.partner_name,' + sLineBreak +
    'user_partner.contact_info,' + sLineBreak +
    'categories.category_name' + sLineBreak +
    'FROM' + sLineBreak +
    'stocks' + sLineBreak +
    'INNER JOIN products ON stocks.product_id = products.product_id' + sLineBreak +
    'INNER JOIN user_partner ON stocks.user_partner_id = user_partner.user_partner_id' + sLineBreak +
    'INNER JOIN categories ON products.category_id = categories.category_id' + sLineBreak +
    'ORDER BY user_partner.partner_name ASC, products.product_name ASC, categories.category_name ASC ' + SQLAdd;

  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassStock.GetStock(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  var SQLAdd := 
    'SELECT' + sLineBreak +
    'st.*, pr.product_name, pr.product_sku product_sku_main, pr.description, ct.category_name, ''false'' status_check, 0 AS qty_send' + sLineBreak +
    'FROM' + sLineBreak +
    'stocks st' + sLineBreak +
    'LEFT JOIN products pr ON pr.product_id = st.product_id' + sLineBreak +
    'LEFT JOIN categories ct ON ct.category_id = pr.category_id' + sLineBreak +
    'WHERE' + sLineBreak +
    'user_partner_id = ' + ADataRequest.FieldByName('user_partner_id').AsString;
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

end.
