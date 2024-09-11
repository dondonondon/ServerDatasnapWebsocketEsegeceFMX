unit BFA.Global.Func;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Json, System.NetEncoding, Data.DBXJsonCommon,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.DateUtils, System.StrUtils,
  FMX.Objects, System.IniFiles, System.IOUtils, FMX.Grid.Style, FMX.Grid, REST.Json, FMX.ListBox, System.RegularExpressions,
  IdHashMessageDigest, idHash, IdGlobal, System.Hash;

type
  QueryFunction = class
    class procedure fnSQLAdd(Query: TFDQuery; SQL: string; ClearPrior: Boolean = False); overload;
    class procedure fnSQLOpen(Query: TFDQuery; WriteLog : Boolean = True); overload;
    class procedure fnExecSQL(Query: TFDQuery; WriteLog : Boolean = True); overload;
    class procedure fnSQLParamByName(Query: TFDQuery; ParamStr: string; Value: Variant); overload;
  end;

  HelperCheck = class
    class function IsNumber(AValue : String) : Boolean;
    class function IsFloat(AValue : String) : Boolean;
    class function IsInteger(AValue : String) : Boolean;
  end;

  GlobalFunction = class
    class procedure CreateBaseDirectory;
    class function GetBaseDirectory : String;
    class function LoadFile(AFileName : String) : String;

    class procedure ClearStringGrid(FStringGrid : TStringGrid; FRow : Integer = 0);

    class procedure SaveSettingString(Section, Name, Value: string);
    class function LoadSettingString(Section, Name, Value: string): string;

    class function ReplaceStr(strSource, strReplaceFrom, strReplaceWith: string; goTrim: Boolean = true): string;

    class function HashHMAC256(AText : String) : String;

    class function EncodeBase64 (AString : String) : String;
    class function DecodeBase64 (AString : String) : String;
    class function Encrypt(const s: String): String;
    class function Decrypt(const s: String): String;

    class function EncodeCrypt(const s : String) : String;
    class function DecodeCrypt(const s : String) : String;

    class function DownloadFile(AURL, ASaveFile : String) : Boolean;
    class procedure SetFontCombobox(ACombobox : TComboBox; ASize : Single = 12.5);
    class procedure SetIndexCombobox(ACombobox : TCombobox; AValue : String);
  end;

const
  SIGNATUREAPPS = '';
  CTYNTCODE = 123123;

implementation

{ GlobalFunction }

class procedure GlobalFunction.ClearStringGrid(FStringGrid: TStringGrid;
  FRow: Integer);
begin
  for var i := 0 to FStringGrid.RowCount - 1 do
    for var ii := 0 to FStringGrid.ColumnCount - 1 do
      FStringGrid.Cells[ii, i] := '';

  FStringGrid.RowCount := FRow;
end;

class procedure GlobalFunction.CreateBaseDirectory;
begin
  {$IF DEFINED(MSWINDOWS)}
  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files');

  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'image') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'image');

  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'doc') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'doc');

  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'video') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'video');

  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'music') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'music');

  if not DirectoryExists(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'other') then
    CreateDir(ExpandFileName(GetCurrentDir) + System.SysUtils.PathDelim + 'files' + System.SysUtils.PathDelim + 'other');
  {$ENDIF}
end;

class function GlobalFunction.DecodeBase64(AString: String): String;
begin
  Result := TNetEncoding.Base64.Decode(AString);
end;

class function GlobalFunction.DecodeCrypt(const s: String): String;
begin
  Result := Decrypt(DecodeBase64(s));
end;

class function GlobalFunction.Decrypt(const s: String): String;
var
  i: integer;
  s2: string;
begin
  if not (Length(s) = 0) then
    for i := 1 to Length(s) do
      s2 := s2 + Chr(Ord(s[i]) - CTYNTCODE);
  Result := s2;
end;

class function GlobalFunction.EncodeBase64(AString: String): String;
begin
  Result := TNetEncoding.Base64.Encode(AString);
end;

class function GlobalFunction.EncodeCrypt(const s: String): String;
begin
  Result := EncodeBase64(Encrypt(s));
end;

class function GlobalFunction.Encrypt(const s: String): String;
var
  i: integer;
  s2: string;
begin
  if not (Length(s) = 0) then
    for i := 1 to Length(s) do
      s2 := s2 + Chr(Ord(s[i]) + CTYNTCODE);
  Result := s2;
end;

class function GlobalFunction.DownloadFile(AURL, ASaveFile: String): Boolean;
var
  HTTP : TNetHTTPClient;
  IHTTPResponses : IHTTPResponse;
  Stream : TMemoryStream;
begin
  Result := False;

  HTTP := TNetHTTPClient.Create(nil);
  try
    Stream := TMemoryStream.Create;
    try
      IHTTPResponses := HTTP.Get(AURL, Stream);
      if IHTTPResponses.StatusCode = 200 then begin
        Stream.SaveToFile(LoadFile(ASaveFile));

        Result := True;
      end;
    finally
      Stream.DisposeOf;
    end;
  finally
    HTTP.DisposeOf;
  end;
end;

class function GlobalFunction.GetBaseDirectory: String;
begin
  CreateBaseDirectory;

  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := TPath.GetDocumentsPath + PathDelim;
  {$ELSEIF DEFINED(MSWINDOWS)}
    Result := ExpandFileName(GetCurrentDir) + PathDelim;
  {$ENDIF}
end;

class function GlobalFunction.HashHMAC256(AText: String): String;
begin
  Result := THashSHA2.GetHMAC(AText, DecodeCrypt(SIGNATUREAPPS), SHA256);
end;

class function GlobalFunction.LoadFile(AFileName: String): String;
var
  FExtension, FPath : String;
begin
  FPath := GetBaseDirectory;
  FExtension := LowerCase(ExtractFileExt(AFileName));

  if (FExtension = '.jpg') or (FExtension = '.jpeg') or (FExtension = '.png') or (FExtension = '.bmp') then
    Result := FPath + 'files' + System.SysUtils.PathDelim + 'image' + System.SysUtils.PathDelim + AFileName

  else if (FExtension = '.doc') or (FExtension = '.pdf') or (FExtension = '.csv') or (FExtension = '.txt') or (FExtension = '.xls') then
    Result := FPath + 'files' + System.SysUtils.PathDelim + 'doc' + System.SysUtils.PathDelim + AFileName

  else if (FExtension = '.mp4') or (FExtension = '.avi') or (FExtension = '.wmv') or (FExtension = '.flv') or (FExtension = '.mov') or (FExtension = '.mkv') or (FExtension = '.3gp') then
    Result := FPath + 'files' + System.SysUtils.PathDelim + 'video' + System.SysUtils.PathDelim + AFileName

  else if (FExtension = '.mp3') or (FExtension = '.wav') or (FExtension = '.wma') or (FExtension = '.aac') or (FExtension = '.flac') or (FExtension = '.m4a') then
    Result := FPath + 'files' + System.SysUtils.PathDelim + 'music' + System.SysUtils.PathDelim + AFileName
  else
    Result := FPath + 'files' + System.SysUtils.PathDelim + 'other' + System.SysUtils.PathDelim + AFileName
end;

class function GlobalFunction.LoadSettingString(Section, Name,
  Value: string): string;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(LoadFile('config.ini'));
  try
    Result := ini.ReadString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

class function GlobalFunction.ReplaceStr(strSource, strReplaceFrom,
  strReplaceWith: string; goTrim: Boolean): string;
begin
  if goTrim then strSource := Trim(strSource);
  Result := StringReplace(strSource, StrReplaceFrom, StrReplaceWith, [rfReplaceAll, rfIgnoreCase]);
end;

class procedure GlobalFunction.SaveSettingString(Section, Name, Value: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(LoadFile('config.ini'));
  try
    ini.WriteString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

class procedure GlobalFunction.SetFontCombobox(ACombobox: TComboBox;
  ASize: Single);
begin
  for var i := 0 to ACombobox.Items.Count - 1 do begin
    ACombobox.ListItems[i].StyledSettings := [];
    ACombobox.ListItems[i].Font.Size := ASize;
  end;

  ACombobox.ItemIndex := 0;
end;

class procedure GlobalFunction.SetIndexCombobox(ACombobox: TCombobox;
  AValue: String);
begin
  var AEventChange := ACombobox.OnChange;
  ACombobox.OnChange := Nil;
  try
    for var i := 0 to ACombobox.Items.Count - 1 do begin
      if LowerCase(AValue) = LowerCase(ACombobox.ListItems[i].Text) then begin
        ACombobox.ItemIndex := i;
        Break;
      end;
    end;
  finally
    ACombobox.OnChange := AEventChange;
  end;
end;

{ QueryFunction }

class procedure QueryFunction.fnExecSQL(Query: TFDQuery; WriteLog: Boolean);
var L: TStringList;
  s: string;
  s1: string;
  TempS: string;
  x1: integer;
  x2: integer;
begin
  L := TStringList.Create;

  s := Query.SQL.Text;

  FreeAndNil(L);

  Query.Prepared;

  Query.ExecSQL;
end;

class procedure QueryFunction.fnSQLAdd(Query: TFDQuery; SQL: string;
  ClearPrior: Boolean);
var s: string;
begin
  if ClearPrior then
    Query.SQL.Clear;

  s := SQL;

  Query.SQL.Add(S);
end;

class procedure QueryFunction.fnSQLOpen(Query: TFDQuery; WriteLog: Boolean);
var L: TStringList;
  s: string;
  s1: string;
  TempS: string;
  x1: integer;
  x2: integer;
begin
  L := TStringList.Create;

  s := Query.SQL.Text;

  FreeAndNil(L);

  Query.Prepared;
  Query.Open;
end;

class procedure QueryFunction.fnSQLParamByName(Query: TFDQuery;
  ParamStr: string; Value: Variant);
begin
  Query.ParamByName(ParamStr).Value := Value
end;

{ HelperCheck }

class function HelperCheck.IsFloat(AValue: String): Boolean;
var
  FDummy : Single;
begin
  Result := TryStrToFloat(AValue, FDummy);
end;

class function HelperCheck.IsInteger(AValue: String): Boolean;
var
  FDummy : Integer;
begin
  Result := TryStrToInt(AValue, FDummy);
end;

class function HelperCheck.IsNumber(AValue: String): Boolean;
begin
  Result := False;

  if IsFloat(AValue) then
    Result := IsInteger(AValue);
end;

end.
