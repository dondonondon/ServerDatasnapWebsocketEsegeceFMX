unit webModuleMain;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Web.HTTPApp, Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker, Datasnap.DSServer,
  Web.WebFileDispatcher, Web.HTTPProd,
  DataSnap.DSAuth,
  Datasnap.DSProxyJavaScript, IPPeerServer, Datasnap.DSMetadata,
  Datasnap.DSServerMetadata, Datasnap.DSClientMetadata, Datasnap.DSCommonServer,
  Datasnap.DSHTTP, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.DSProxyDispatcher;

type
  TWM = class(TWebModule)
    DSRESTWebDispatcher1: TDSRESTWebDispatcher;
    ServerFunctionInvoker: TPageProducer;
    ReverseString: TPageProducer;
    WebFileDispatcher1: TWebFileDispatcher;
    DSProxyGenerator1: TDSProxyGenerator;
    DSServerMetaDataProvider1: TDSServerMetaDataProvider;
    DSProxyDispatcher1: TDSProxyDispatcher;
    procedure WebModuleDefaultAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebFileDispatcher1BeforeDispatch(Sender: TObject;
      const AFileName: string; Request: TWebRequest; Response: TWebResponse;
      var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModule1ClassSampleAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WMCoreRPCAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    FServerFunctionInvokerAction: TWebActionItem;
    function AllowServerFunctionInvoker: Boolean;


    function SendToCoreAPI(WebAction : TWebActionItem; Request: TWebRequest; Response: TWebResponse) : String;
    function SendToCoreAPIRPC(Request: TWebRequest; Response: TWebResponse; RequestAction : string) : String;
    function CheckHeader(Request: TWebRequest) : Boolean;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses sMethodMain, sContainerMain, Web.WebReq, Datasnap.Core.Rest, uDM,
  BFA.Global.Func, BFA.GlobalVariable;

function TWM.CheckHeader(Request: TWebRequest): Boolean;
begin
  Result := False;

  if Request.GetFieldByName('x-api-key') = LoadConfig('key', 'blangkonfa') then begin
    Result := True;
  end;
end;

function TWM.SendToCoreAPI(WebAction: TWebActionItem;
  Request: TWebRequest; Response: TWebResponse): String;
var
  FResponses : String;
  FPath : String;
  FPathArray : TArray<String>;
  CoreAPI : TClassHelper;
  FCheck : TFDMemTable;
  FCon : TFDConnection;
begin
  Inc(CountHit);

  Response.StatusCode := 404;
  Response.ContentType := 'application/json';
  Response.ContentEncoding := 'utf-8';

  FCon := TFDConnection(DM.DBConnection.CloneConnection);
  CoreAPI := TClassHelper.Create;
  try
    FPathArray := SplitString(Request.RawPathInfo, '/');
    try
      if not CheckHeader(Request) then begin
        Response.StatusCode := 400;
        Response.Content := CoreAPI.FillJSONError(Response.StatusCode, 'Invalid Access');
        Exit;
      end;

      if FCon.Connected then
        FCon.Connected := True;

      CoreAPI.Connection := FCon;
      CoreAPI.RequestClass := FPathArray[1];
      CoreAPI.RequestMethod := FPathArray[2];

      FResponses := CoreAPI.CallMethodAPI(Request.Content);

      Response.StatusCode := CoreAPI.StatusCode;
      Response.Content := FResponses;
    except
      on E : Exception do begin
        Response.StatusCode := 500;
        Response.Content := CoreAPI.FillJSONError(Response.StatusCode, E.Message);
      end;
    end;
  finally
    FCon.DisposeOf;
    CoreAPI.DisposeOf;
  end;
end;

function TWM.SendToCoreAPIRPC(Request: TWebRequest;
  Response: TWebResponse; RequestAction: string): String;
var
  FResponses : String;
begin
  Inc(CountHit);

  var CoreAPI := TClassHelper.Create;
  try
    try
      if not CheckHeader(Request) then begin
        Response.StatusCode := 400;
        Response.Content := CoreAPI.FillJSONError(Response.StatusCode, 'Invalid Access');
        Exit;
      end;

      var GUID : String;
      GUID := RequestAction;     //%0D%0A
      try
        if Request.GetFieldByName('ID') <> '' then
          GUID := GlobalFunction.DecodeCrypt(GlobalFunction.ReplaceStr(Request.GetFieldByName('ID'), '%0D%0A', ''));
      except
        GUID := 'Unknown ID';
        GUID := Request.GetFieldByName('ID');
      end;

      CoreAPI.GUID := GUID;
      CoreAPI.IP := Request.RemoteIP;
      CoreAPI.Connection := DM.DBConnection;

      FResponses := CoreAPI.CallMethodAPIRPC(Request.Content);

      Response.ContentType := 'application/json';
      Response.ContentEncoding := 'utf-8';
      Response.StatusCode := CoreAPI.StatusCode;
      Response.Content := FResponses;
    except
      on E : Exception do begin
        Response.StatusCode := 500;
        Response.Content := CoreAPI.FillJSONError(Response.StatusCode, E.Message);
      end;
    end;
  finally
    CoreAPI.DisposeOf;
  end;
end;

procedure TWM.WebModuleDefaultAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if Request.RawPathInfo = '/' then begin
    Response.StatusCode := 200;
    Response.Content :=
      '<html>' +
      '<head><title>DataSnap Server</title></head>' +
      '<body>DataSnap Server</body>' +
      '</html>';
  end else begin
    SendToCoreAPI(TWebActionItem(Sender), Request, Response);
  end;
end;

procedure TWM.WMCoreRPCAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
begin
  SendToCoreAPIRPC(Request, Response, 'WMRPCCoreAction');
end;

procedure TWM.WebModule1ClassSampleAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  SendToCoreAPI(TWebActionItem(Sender), Request, Response);
end;

procedure TWM.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if FServerFunctionInvokerAction <> nil then
    FServerFunctionInvokerAction.Enabled := AllowServerFunctionInvoker;
end;

function TWM.AllowServerFunctionInvoker: Boolean;
begin
  Result := (Request.RemoteAddr = '127.0.0.1') or
    (Request.RemoteAddr = '0:0:0:0:0:0:0:1') or (Request.RemoteAddr = '::1');
end;

procedure TWM.WebFileDispatcher1BeforeDispatch(Sender: TObject;
  const AFileName: string; Request: TWebRequest; Response: TWebResponse;
  var Handled: Boolean);
var
  D1, D2: TDateTime;
begin
  Handled := False;
  if SameFileName(ExtractFileName(AFileName), 'serverfunctions.js') then
    if not FileExists(AFileName) or (FileAge(AFileName, D1) and FileAge(WebApplicationFileName, D2) and (D1 < D2)) then
    begin
      DSProxyGenerator1.TargetDirectory := ExtractFilePath(AFileName);
      DSProxyGenerator1.TargetUnitName := ExtractFileName(AFileName);
      DSProxyGenerator1.Write;
    end;
end;

procedure TWM.WebModuleCreate(Sender: TObject);
begin
  FServerFunctionInvokerAction := ActionByName('ServerFunctionInvokerAction');
  DSServerMetaDataProvider1.Server := DSServer;
  DSRESTWebDispatcher1.Server := DSServer;
  if DSServer.Started then
  begin
    DSRESTWebDispatcher1.DbxContext := DSServer.DbxContext;
    DSRESTWebDispatcher1.Start;
  end;
  DSRESTWebDispatcher1.AuthenticationManager := DSAuthenticationManager;
end;

initialization
finalization
  Web.WebReq.FreeWebModules;

end.

