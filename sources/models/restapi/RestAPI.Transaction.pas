unit RestAPI.Transaction;

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
  ClassTransaction = class(TPersistent)
  published
    function GetData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
    function InsertData(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
  end;

implementation

{ ClassTransaction }

uses BFA.Global.Func, Datasnap.Core.Response, BFA.Helper.MemoryTable,
  Datasnap.Core.Messages, RestAPI.Core;

function ClassTransaction.GetData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
begin
  SQLAdd := '';

  if Assigned(ADataRequest.FindField('page')) then
    if ADataRequest.FieldByName('page').AsInteger > 0 then
      SQLAdd := 'LIMIT ' + ((ADataRequest.FieldByName('page').AsInteger - 1) * 1000).ToString + ', 1000';

  SQLAdd :=
    ' SELECT'+ sLineBreak +
    ' tr.*, trd.transaction_type, pr.product_name, trd.product_id, trd.quantity, trd.status_transaction '+ sLineBreak +
    ' FROM'+ sLineBreak +
    ' ( SELECT trsub.transaction_id, trsub.user_partner_id, trsub.invoice, trsub.description, trsub.created_at, trsub.updated_at FROM transactions trsub GROUP BY trsub.invoice '+ SQLAdd +' ) tr'+ sLineBreak +
    ' LEFT JOIN transaction_detail trd ON trd.invoice = tr.invoice'+ sLineBreak +
    ' LEFT JOIN products pr ON pr.product_id = trd.product_id'+ sLineBreak +
    ' ORDER BY tr.invoice ASC, tr.created_at';
  Result := TRestCore.GetData(SQLAdd, Connection, ADataRequest, AStatusCode);
end;

function ClassTransaction.InsertData(Connection: TFDConnection;
  ADataRequest: TFDMemTable; out AStatusCode: Integer): String;
var
  SQLAdd : String;
  FInvoice, FDescription, FReference, FTransDate : String;
  IsAvailableDataToInsert : Boolean;
  FOriginID, FDestinationID : String;
begin
  AStatusCode := TRestStatus.CONFLICT;
  IsAvailableDataToInsert := False;

  var FData := TFDMemTable.Create(nil);
  var FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := Connection;
    FQuery.FetchOptions.RowsetSize := 10000;

    if not FData.FillDataFromString(GlobalFunction.DecodeBase64(ADataRequest.FieldByName('data').AsString)) then begin
      Result := HelperResponse.CreateResponse(AStatusCode, TRestMessage.CONFLICT_MESSAGE, FQuery, ADataRequest);
      Exit;
    end;

    if not FData.FillDataFromString(FData.FieldByName('data').AsString) then begin
      Result := HelperResponse.CreateResponse(AStatusCode, 'Invalid format data!', FQuery, ADataRequest);
      Exit;
    end;

    Connection.StartTransaction;
    try
      FOriginID := ADataRequest.FieldByName('origin_id').AsString;
      FDestinationID := ADataRequest.FieldByName('destination_id').AsString;
      FInvoice := ADataRequest.FieldByName('invoice').AsString;
      FDescription := GlobalFunction.DecodeBase64(ADataRequest.FieldByName('description').AsString);

      FReference := ADataRequest.FieldByName('reference').AsString;
      FTransDate := ADataRequest.FieldByName('date').AsString;

      SQLAdd := Format('INSERT INTO transactions (invoice, transaction_reference, transaction_date, transaction_type, description, user_partner_id) VALUES(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
        [FInvoice, FReference, FTransDate, 'in', FDescription, FDestinationID]);

      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnExecSQL(FQuery);

      SQLAdd := Format('INSERT INTO transactions (invoice, transaction_reference, transaction_date, transaction_type, description, user_partner_id) VALUES(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
        [FInvoice, FReference, FTransDate, 'out', FDescription, FOriginID]);

      QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
      QueryFunction.fnExecSQL(FQuery);

      FData.First;
      for var i := 0 to FData.RecordCount - 1 do begin
        IsAvailableDataToInsert := True;
        SQLAdd := Format(
          'INSERT INTO transaction_detail (product_id, invoice, quantity, transaction_type, status_transaction, user_partner_id) ' + sLineBreak +
          'VALUES(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
          [
            FData.FieldByName('product_id').AsString,
            FInvoice,
            FData.FieldByName('qty_send').AsString,
            'in',
            'Approve',
            FDestinationID
          ]);

        QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
        QueryFunction.fnExecSQL(FQuery);
        FData.Next;
      end;

      FData.First;
      for var i := 0 to FData.RecordCount - 1 do begin
        IsAvailableDataToInsert := True;
        SQLAdd := Format(
          'INSERT INTO transaction_detail (product_id, invoice, quantity, transaction_type, status_transaction, user_partner_id) ' + sLineBreak +
          'VALUES(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
          [
            FData.FieldByName('product_id').AsString,
            FInvoice,
            FData.FieldByName('qty_send').AsString,
            'out',
            'Approve',
            FOriginID
          ]);

        QueryFunction.fnSQLAdd(FQuery, SQLAdd, True);
        QueryFunction.fnExecSQL(FQuery);

        FData.Next;
      end;

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
    FData.DisposeOf;
    FQuery.DisposeOf;
  end;
end;

end.
