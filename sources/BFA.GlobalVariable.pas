unit BFA.GlobalVariable;

interface

uses
  Windows, Web.WebReq,
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
  System.Generics.Collections, System.IniFiles;


procedure SaveConfig(Name, Value : String);
function LoadConfig(Name, Value : String) : String;

const
  DBName = 'serverapps.db';

var
  WebSocketServer : TsgcWSHTTPWebBrokerBridgeServer;
  CountHit : Integer;

implementation

uses BFA.Global.Func;

procedure SaveConfig(Name, Value : String);
var
  ini: TIniFile;
  FDir : String;
begin
  FDir := GlobalFunction.GetBaseDirectory + 'configapps';
  if not DirectoryExists(FDir) then
    ForceDirectories(FDir);

  FDir := FDir + PathDelim;

  ini := TIniFile.Create(FDir + 'config.ini');
  try
    ini.WriteString('config_server', Name, Value);
  finally
    ini.DisposeOf;
  end;

//  GlobalFunction.SaveSettingString('config_server', Name, Value);
end;

function LoadConfig(Name, Value : String) : String;
var
  ini: TIniFile;
  FDir : String;
begin
  FDir := GlobalFunction.GetBaseDirectory + 'configapps';
  if not DirectoryExists(FDir) then
    ForceDirectories(FDir);

  FDir := FDir + PathDelim;

  ini := TIniFile.Create(FDir + 'config.ini');
  try
    Result := ini.ReadString('config_server', Name, Value);
  finally
    ini.DisposeOf;
  end;

//  Result := GlobalFunction.LoadSettingString('config_server', Name, Value);
end;

end.
