unit Helpers4D.StringList;

interface

uses
  System.Classes,
  System.SysUtils;

type TStringsHelper = class helper for TStrings

  public
    function Add(const Value: String; const Args: array of const): TStrings; overload;

    class function CreateFromFile(AFileName: string): TStrings;
    class procedure SaveLogFile(AFileName: string; const S: String; bOverride: Boolean = False); overload;
    class procedure SaveLogFile(AFileName: string; const S: String; const Args: array of const; bOverride: Boolean = False); overload;
end;

implementation

{ TStringsHelper }

function TStringsHelper.Add(const Value: String; const Args: array of const): TStrings;
begin
  result := Self;
  Add(Format(Value, Args));
end;

class function TStringsHelper.CreateFromFile(AFileName: string): TStrings;
begin
  Result := TStringList.Create;
  if FileExists(AFileName) then
    Result.LoadFromFile(AFileName);
end;

class procedure TStringsHelper.SaveLogFile(AFileName: string; const S: String; const Args: array of const; bOverride: Boolean);
begin
  SaveLogFile(AFileName, Format(S, Args), bOverride);
end;

class procedure TStringsHelper.SaveLogFile(AFileName: string; const S: String; bOverride: Boolean);
var
  list: TStrings;
begin
  list := TStringList.CreateFromFile(AFileName);
  try
    if bOverride then
      list.Clear;
    list.Add(S);
    list.SaveToFile(AFileName);
  finally
    list.Free;
  end;
end;

end.
