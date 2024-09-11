unit frMain;

interface

uses
  Web.WebReq,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  sgcBase_Classes, sgcTCP_Classes, sgcWebSocket_Classes,System.JSON,
  FMX.Memo.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.StdCtrls, FMX.Edit,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.Mime,
  System.Threading, FMX.Layouts, FMX.Objects, FMX.TabControl,
  System.Rtti, FMX.Grid.Style, FMX.Grid, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, FMX.ListBox, sgcJSON, Data.Win.ADODB,
  FMX.QRCode, FMX.Platform, REST.Authenticator.Basic, REST.Authenticator.OAuth, REST.Types,
  REST.Client, Data.Bind.ObjectScope, FMX.SearchBox, FMX.Platform.Win, ShellAPI, Data.DB, Winapi.Messages,
  sgcWebSocket_Server_WebBrokerBridge, Web.HTTPApp, DateUtils, FMX.Menus, System.Win.Registry,
  System.Generics.Collections, FMX.Effects, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.FMXUI.Wait, FireDAC.DApt, sgcSocket_Classes, sgcWebSocket_Types,
  Winapi.Windows, sgcWebSocket_Server, sgcWebSocket;


  const
    WM_ICONTRAY = WM_USER + 1;

type
  TFMain = class(TForm)
    tcMain: TTabControl;
    SB: TStyleBook;
    tiMain: TTabItem;
    tiDatabase: TTabItem;
    background: TRectangle;
    loOption: TLayout;
    reOption: TRectangle;
    edHost: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnStart: TCornerButton;
    btnStop: TCornerButton;
    loIndicator: TLayout;
    reIndicator: TRectangle;
    btnIndicatorDB: TCornerButton;
    btnIndicatorWS: TCornerButton;
    Label8: TLabel;
    btnOnline: TCornerButton;
    btnDBLocal: TCornerButton;
    btnHitToday: TCornerButton;
    btnActive: TCornerButton;
    cbSSL: TCheckBox;
    PM: TPopupMenu;
    miShow: TMenuItem;
    miStopStart: TMenuItem;
    miExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure cbSSLChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miExitClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
    procedure miStopStartClick(Sender: TObject);
  private

    TrayWnd: HWND;
    TrayIconData: TNotifyIconData;
    TrayIconAdded: Boolean;

    procedure StartServer;

    procedure TrayWndProc(var Message: TMessage);
    procedure ShowAppOnTaskbar (AMainForm : TForm);
    procedure HideAppOnTaskbar (AMainForm : TForm);
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses BFA.GlobalVariable, uDM, Datasnap.Core.Rest, BFA.Global.Func;

procedure TFMain.btnStartClick(Sender: TObject);
begin
  StartServer;
end;

procedure TFMain.btnStopClick(Sender: TObject);
begin
  WebSocketServer.Active := False;
  WebSocketServer.Bindings.Clear;
  DM.DBConnection.Connected := False;

  if not WebSocketServer.Active then begin
    edHost.Enabled := True;
    edPort.Enabled := True;
    btnStart.Enabled := True;
    btnStop.Enabled := False;

    btnIndicatorWS.StyleLookup := 'btnRed';
  end;
end;

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if WebSocketServer.Active then begin
    Action := TCloseAction.caNone;
    HideAppOnTaskbar(Self);
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  FormatBr: TFormatSettings;
begin
  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  try
    FormatBr                     := TFormatSettings.Create;
    FormatBr.DecimalSeparator    := '.';
    FormatBr.ThousandSeparator   := ',';
    FormatBr.DateSeparator       := '-';
    FormatBr.TimeSeparator       := ':';
    FormatBr.ShortDateFormat     := 'yyyy-mm-dd';
    FormatBr.LongDateFormat      := 'yyyy-mm-dd hh:nn:ss';

    System.SysUtils.FormatSettings := FormatBr;
  except

  end;

  CountHit := 0;

  TrayWnd := AllocateHWnd(TRayWndProc);
  with TrayIconData do begin
    cbSize := SizeOf;
    Wnd := TrayWnd;
    uID := 1;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
    StrPCopy(szTip, 'Server ERM');
  end;

  if not  TrayIconAdded then
    TrayIconAdded := Shell_NotifyIcon(NIM_ADD, @TrayIconData) ;

  WebSocketServer := TsgcWSHTTPWebBrokerBridgeServer.Create(Self);

  WebSocketServer.HeartBeat.Interval := 10;
  WebSocketServer.ThreadPool := True;
  WebSocketServer.HeartBeat.Enabled := False;
  WebSocketServer.KeepAlive := False;
  WebSocketServer.WatchDog.Enabled := False;

  RegisterClassAPI;

  edHost.Text := LoadConfig('hostip', '127.0.0.1');
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  DM.wsProtocol.Server := WebSocketServer;

  cbSSL.IsChecked := LoadConfig('ssl_status', '0') = '1';

  StartServer;
end;

procedure TFMain.HideAppOnTaskbar(AMainForm: TForm);
begin
  Hide();
  WindowState := TWindowState.wsMinimized;

  var AppHandle := ApplicationHWND;
  ShowWindow(AppHandle, SW_HIDE);
  SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE) and (not WS_EX_TOOLWINDOW));
end;

procedure TFMain.miExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFMain.miShowClick(Sender: TObject);
begin
  if Self.Active then
    Exit;

  FMain.Show;
  SetForegroundWindow(FmxHandleToHWND(FMain.Handle));
  if TrayIconAdded then begin
    TrayIconAdded := false;
    ShowAppOnTaskbar(FMain);
  end;
end;

procedure TFMain.miStopStartClick(Sender: TObject);
begin
  if btnStart.Enabled then begin
    btnStartClick(Sender);
  end else begin
    btnStopClick(Sender);
  end;
end;

procedure TFMain.ShowAppOnTaskbar(AMainForm: TForm);
begin
  var AppHandle := ApplicationHWND;
  SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE) and (not WS_EX_TOOLWINDOW));
  ShowWindow(AppHandle, SW_SHOW);
end;

procedure TFMain.StartServer;
begin
  try
    sgcJSON.SetJSONClass(TsgcJSON);

    with DM do begin
      DM.DriverLinkMySQL.VendorHome := GlobalFunction.GetBaseDirectory;

      DBConnection.Params.Clear;

      DBConnection.DriverName := LoadConfig('drivername', 'MySQL');
      DBConnection.Params.Values['DriverID'] := LoadConfig('drivername', 'MySQL');

      DBConnection.Params.DriverID := LoadConfig('drivername', 'MySQL');
      DBConnection.Params.UserName := LoadConfig('username', 'inv_malay');
      DBConnection.Params.Password := LoadConfig('password', 'e2XzctfirpHhWnpE');

      DBConnection.Params.Values['Server'] := LoadConfig('host', 'blangkon.net');
      DBConnection.Params.Values['Port'] := LoadConfig('port', '3306');
      DBConnection.Params.Values['UserName'] := LoadConfig('username', 'inv_malay');
      DBConnection.Params.Values['Password'] := LoadConfig('password', 'e2XzctfirpHhWnpE');
      DBConnection.Params.Values['Database'] := LoadConfig('dbname', 'inv_malay');
    end;

    DM.DBConnection.Connected := True;

    if not DM.DBConnection.Connected then begin
      ShowMessage('Database not connected');
      Exit;
    end;

    WebSocketServer.Bindings.Clear;
    WebSocketServer.Port := StrToIntDef(edPort.Text, 5414);
    WebSocketServer.Options.CleanDisconnect := True;

    WebSocketServer.SSL := cbSSL.IsChecked;
    if cbSSL.IsChecked then begin
  //    WebSocketServer.DefaultPort := StrToInt(edPort.Text);
      WebSocketServer.SSLOptions.CertFile := LoadConfig('CertFile', '');
      WebSocketServer.SSLOptions.KeyFile := LoadConfig('KeyFile', '');
      WebSocketServer.SSLOptions.RootCertFile := LoadConfig('RootCertFile', '');
      WebSocketServer.SSLOptions.Port := StrToInt(edPort.Text);
      WebSocketServer.SSLOptions.Version := TwsTLSVersions.tls1_2;
    end;

    WebSocketServer.ThreadPool := True;
    WebSocketServer.NotifyEvents := TwsNotifyEvent.neAsynchronous;

    With WebSocketServer.Bindings.Add do
    begin
      Port := StrToInt(edPort.Text);
      IP := edHost.Text;
    end;

    WebSocketServer.Active := True;
    if WebSocketServer.Active then begin
      edHost.Enabled := False;
      edPort.Enabled := False;

      btnStart.Enabled := False;
      btnStop.Enabled := True;

      SaveConfig('hostip', edHost.Text);

      btnIndicatorWS.StyleLookup := 'btnGreen';
    end;
  except on E: Exception do
    ShowMessage(E.Message);
  end;

end;

procedure TFMain.TrayWndProc(var Message: TMessage);
var
  P : TPoint;
begin
  if Message.MSG = WM_ICONTRAY then begin
    case Message.LParam of
      WM_LBUTTONDOWN: begin
        FMain.Show;
        SetForegroundWindow(FmxHandleToHWND(FMain.Handle));
        if TrayIconAdded then begin
          TrayIconAdded := false;
          ShowAppOnTaskbar(FMain);
        end;
      end;
      WM_RBUTTONDOWN: begin
        if not btnStart.Enabled then
          miStopStart.Text := 'Stop'
        else
          miStopStart.Text := 'Start';

        SetForegroundWindow(FmxHandleToHWND(FMain.Handle));
        GetCursorPos(P);
        PM.Popup(P.X, P.Y - 100);
        PostMessage(FmxHandleToHWND(FMain.Handle), WM_NULL, 0, 0);
      end;
    end;
  end else begin
    Message.Result := DefWindowProc(TrayWnd, Message.Msg, Message.WParam, Message.LParam);
  end;
end;

procedure TFMain.cbSSLChange(Sender: TObject);
begin
  var FSSLStatus : String;
  if cbSSL.IsChecked then FSSLStatus := '1' else FSSLStatus := '0';
  SaveConfig('ssl_status', FSSLStatus);

  if cbSSL.IsChecked then begin
    if LoadConfig('CertFile', '') = '' then
      cbSSL.IsChecked := False;

    if LoadConfig('KeyFile', '') = '' then
      cbSSL.IsChecked := False;

    if LoadConfig('RootCertFile', '') = '' then
      cbSSL.IsChecked := False;
  end;
end;

end.
