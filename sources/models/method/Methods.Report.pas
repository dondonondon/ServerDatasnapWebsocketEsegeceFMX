unit Methods.Report;

interface

uses System.SysUtils, System.Classes, Datasnap.DSServer, Datasnap.DSAuth, System.JSON;

type
{$METHODINFO ON}
  TReportMethods = class(TComponent)
  private
    { Private declarations }
  public
    { Public declarations }
    function EchoString(Value: string): string;
  end;
{$METHODINFO OFF}

implementation

uses Data.DBXPlatform;

{ TReportMethods }

function TReportMethods.EchoString(Value: string): string;
begin
  Result := Value;
end;

end.
