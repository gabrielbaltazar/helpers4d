unit Helpers4D.Horse.Exception;

interface

uses
  Horse,
  Horse.Commons,
  Helpers4D.Horse,
  System.SysUtils,
  System.JSON;

procedure Helpers4DHorseException(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure Helpers4DHorseException(Req: THorseRequest; Res: THorseResponse; Next: TProc);

  function JSONError(Error: Exception; AMessage: String): TJSONObject;
  var
    errorClass: string;
  begin
    errorClass := 'Exception';
    if Assigned(Error) then
      errorClass := Error.ClassName;
    result := TJSONObject.Create
                .AddPair('error', errorClass)
                .AddPair('description', AMessage);
  end;
begin
  try
    Next();
  except
    on E: EHorseCallbackInterrupted do
      raise;

    on E: EAccessViolation do
    begin
      Res.Send<TJSONObject>(JSONError(nil, 'Internal server error, please try again.'));
      Res.Status(500);
    end;

    on E: EArgumentNilException do
    begin
      Res.Status(404);
      Res.Send<TJSONObject>(JSONError(E, E.Message));
    end;

    on E: EHelpers4DHorse do
    begin
      Res.Send<TJSONObject>(JSONError(E, E.Message));
      Res.Status(E.statusCode);
    end;

    on E: Exception do
    begin
      Res.Send<TJSONObject>(JSONError(E, E.Message));
      Res.Status(400);
    end;
  end;
end;

end.
