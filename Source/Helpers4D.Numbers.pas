unit Helpers4D.Numbers;

interface

uses
  System.SysUtils,
  System.Math;

type
  THelpers4DCurrency = record helper for Currency
  public
    function Format: string; overload;
    function Format(AFormat: string): string; overload;
  end;

implementation

{ THelpers4DCurrency }

function THelpers4DCurrency.Format: string;
begin
  if Self < 0 then
    Result := 'R$ ' + Format(',0.00')
  else
    Result := Format('R$ ,0.00');
end;

function THelpers4DCurrency.Format(AFormat: string): string;
begin
  Result := FormatCurr(AFormat, Self);
end;

end.

