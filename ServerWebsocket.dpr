program ServerWebsocket;
{$APPTYPE GUI}

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  frMain in 'frMain.pas' {FMain},
  BFA.GlobalVariable in 'sources\BFA.GlobalVariable.pas',
  uDM in 'uDM.pas' {DM: TDataModule},
  sContainerMain in 'sources\datasnap\sContainerMain.pas' {ServerContainer1: TDataModule},
  sMethodMain in 'sources\datasnap\sMethodMain.pas' {ServerMethods1: TDataModule},
  webModuleMain in 'sources\datasnap\webModuleMain.pas' {WM: TWebModule},
  BFA.Global.Func in 'sources\BFA.Global.Func.pas',
  Datasnap.Core.Response in 'sources\helpers\Datasnap.Core.Response.pas',
  Datasnap.Core.Rest in 'sources\helpers\Datasnap.Core.Rest.pas',
  BFA.Helper.MemoryTable in 'sources\helpers\BFA.Helper.MemoryTable.pas',
  RestAPI.Core in 'sources\models\restapi\RestAPI.Core.pas',
  Methods.Report in 'sources\models\method\Methods.Report.pas',
  Methods.Sample in 'sources\models\method\Methods.Sample.pas',
  RestAPI.Radio in 'sources\models\restapi\RestAPI.Radio.pas',
  RPC.Radio in 'sources\models\rpc\RPC.Radio.pas',
  RestAPI.Stock in 'sources\models\restapi\RestAPI.Stock.pas',
  Datasnap.Core.Messages in 'sources\helpers\Datasnap.Core.Messages.pas',
  RestAPI.Category in 'sources\models\restapi\RestAPI.Category.pas',
  RestAPI.Product in 'sources\models\restapi\RestAPI.Product.pas',
  RestAPI.Transaction in 'sources\models\restapi\RestAPI.Transaction.pas',
  RestAPI.User in 'sources\models\restapi\RestAPI.User.pas',
  RestAPI.Sample in 'sources\models\restapi\RestAPI.Sample.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;

  WebRequestHandler.MaxConnections := 100;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
