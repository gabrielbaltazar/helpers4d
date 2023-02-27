unit Helpers4D.Strings;

interface

uses
  System.MaskUtils,
  System.SysUtils;

type
  THelpers4DStrings = record helper for string
  public
    function FormatCpfCnpj: string;
    function FormatCpf: string;
    function FormatCnpj: string;
  end;

implementation

{ THelpers4DStrings }

function THelpers4DStrings.FormatCnpj: string;
var
  LOnlyNumbers: string;
  I: Integer;
begin
  Result := Self;
  for I := 1 to Length(Self) do
  begin
    if CharInSet(Self[I], ['0'..'9']) then
      LOnlyNumbers := LOnlyNumbers + Self[I];
  end;

  if Length(LOnlyNumbers) = 14 then
    Result := FormatMaskText('00\.000\.000\/0000\-00;0;', LOnlyNumbers);
end;

function THelpers4DStrings.FormatCpf: string;
var
  LOnlyNumbers: string;
  I: Integer;
begin
  Result := Self;
  for I := 1 to Length(Self) do
  begin
    if CharInSet(Self[I], ['0'..'9']) then
      LOnlyNumbers := LOnlyNumbers + Self[I];
  end;

  if Length(LOnlyNumbers) = 11 then
    Result := FormatMaskText('000\.000\.000\-00;0;', LOnlyNumbers);
end;

function THelpers4DStrings.FormatCpfCnpj: string;
var
  LOnlyNumbers: string;
  I: Integer;
begin
  Result := Self;
  for I := 1 to Length(Self) do
  begin
    if CharInSet(Self[I], ['0'..'9']) then
      LOnlyNumbers := LOnlyNumbers + Self[I];
  end;

  if Length(LOnlyNumbers) = 11 then
    Result := FormatCpf
  else
  if Length(LOnlyNumbers) = 14 then
    Result := FormatCnpj;
end;

end.
