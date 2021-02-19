unit Helpers4D.StringList;

interface

uses
  System.Classes,
  System.SysUtils;

type TStringsHelper = class helper for TStrings

  public
    function Add(const Value: String; const Args: array of const): TStrings; overload;

    class function CreateFromFile(AFileName: string): TStringList;

end;

implementation

{ TStringsHelper }

function TStringsHelper.Add(const Value: String; const Args: array of const): TStrings;
begin
  result := Self;
  Add(Format(Value, Args));
end;

class function TStringsHelper.CreateFromFile(AFileName: string): TStringList;
begin
  Result := TStringList.Create;
  if FileExists(AFileName) then
    Result.LoadFromFile(AFileName);
end;

end.
