unit uDM;

interface

uses
  System.SysUtils, System.Classes, sgcBase_Classes, sgcSocket_Classes,
  sgcTCP_Classes, sgcWebSocket_Classes, sgcWebSocket_Protocol_Base_Server,
  sgcWebSocket_Protocol_sgc_Server, sgcWebSocket_Protocols, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FMX.Dialogs,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, System.Threading, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.Types, Web.WebReq;

type
  TDM = class(TDataModule)
    wsProtocol: TsgcWSPServer_sgc;
    DriverLinkMySQL: TFDPhysMySQLDriverLink;
    DBConnection: TFDConnection;
    QTemp: TFDQuery;
    QPing: TFDQuery;
    tiPing: TTimer;
    procedure DBConnectionBeforeConnect(Sender: TObject);
    procedure DBConnectionAfterConnect(Sender: TObject);
    procedure DBConnectionAfterDisconnect(Sender: TObject);
    procedure wsProtocolRPC(Connection: TsgcWSConnection; const ID, Method,
      Params: string);
    procedure tiPingTimer(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    IsPing : Boolean;
    FTimeCheck : Integer;
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses BFA.Global.Func, BFA.GlobalVariable, frMain, Datasnap.Core.Response,
  Datasnap.Core.Rest;

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FTimeCheck := 0;
end;

procedure TDM.tiPingTimer(Sender: TObject);
begin
  FMain.btnHitToday.Text := CountHit.ToString + ' HIT TDY';
  FMain.btnActive.Text := WebRequestHandler.ActiveCount.ToString + ' / ' + WebRequestHandler.MaxConnections.ToString + ' CON';

  Inc(FTimeCheck);

  if FTimeCheck < 5 then Exit;
  FTimeCheck := 0;

  if IsPing then Exit;
  IsPing := True;

  TTask.Run(procedure begin
    try
      try
        var SQLAdd := 'SELECT ''PING''';
        QueryFunction.fnSQLAdd(QPing, SQLAdd, True);
        QueryFunction.fnSQLOpen(QPing);
      except on E: Exception do
      end;
    finally
      IsPing := False;
    end;
  end).Start;
end;

procedure TDM.DBConnectionAfterConnect(Sender: TObject);
begin
  FMain.btnIndicatorDB.StyleLookup := 'btnGreen';
end;

procedure TDM.DBConnectionAfterDisconnect(Sender: TObject);
begin
  FMain.btnIndicatorDB.StyleLookup := 'btnRed';
end;

procedure TDM.DBConnectionBeforeConnect(Sender: TObject);
begin
  var FFileName := GlobalFunction.LoadFile(DBName);

  if not FileExists(FFileName) then begin
    ShowMessage('database local tidak ditemukan. file ' + DBName + ' harus ada di folder assets/other/');
  end;
end;

procedure TDM.wsProtocolRPC(Connection: TsgcWSConnection; const ID, Method,
  Params: string);
begin
  Inc(CountHit);

  TTask.Run(procedure begin
    try
      var CoreRPC := TClassHelper.Create;
      try
        try
          CoreRPC.GUID := Connection.Guid;
          CoreRPC.IP := Connection.IP;
          CoreRPC.Connection := DBConnection;

          var FResponses := CoreRPC.CallMethod(Params);

          wsProtocol.RPCResult(ID, FResponses);

        except
          on E : Exception do begin

          end;
        end;
      finally
        CoreRPC.DisposeOf;
      end;
    except on E: Exception do
    end;
  end).Start;
end;

end.
