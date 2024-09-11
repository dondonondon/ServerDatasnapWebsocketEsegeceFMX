unit RestAPI.Product;

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
  ClassProduct = class(TPersistent)
  published
    function GetData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function InsertData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function UpdateData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassProduct }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages, RestAPI.Core;

function ClassProduct.GetData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
begin
  var SQLAdd := 'SELECT * FROM products ORDER BY product_name ASC';
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassProduct.InsertData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'INSERT INTO products (category_id, product_name, product_sku, description, price) VALUES(''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
    [
      ADataRequest.FieldByName('category_id').AsString,
      ADataRequest.FieldByName('product_name').AsString,
      ADataRequest.FieldByName('product_sku').AsString,
      ADataRequest.FieldByName('description').AsString,
      ADataRequest.FieldByName('price').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassProduct.UpdateData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := Format(
    'UPDATE products SET ' + sLineBreak +
    'category_id = ''%s'', ' + sLineBreak +
    'product_name = ''%s'', ' + sLineBreak +
    'product_sku = ''%s'', ' + sLineBreak +
    'description = ''%s'', ' + sLineBreak +
    'price = ''%s'' ' + sLineBreak +
    'WHERE product_id = ''%s''',
    [
      ADataRequest.FieldByName('category_id').AsString,
      ADataRequest.FieldByName('product_name').AsString,
      ADataRequest.FieldByName('product_sku').AsString,
      ADataRequest.FieldByName('description').AsString,
      ADataRequest.FieldByName('price').AsString,
      ADataRequest.FieldByName('product_id').AsString
    ]);

  Result := TRestCore.InsertData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

end.
