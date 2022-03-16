unit Helpers4D.Horse;

interface

uses
  Horse,
  Horse.Commons,
  Helpers4D.DateTime,
  Helpers4D.JSON,
  System.Generics.Collections,
  System.JSON,
  System.StrUtils,
  System.SysUtils;

type
  THelpers4DHorseRequest = class helper for THorseRequest
  private
    function RaiseHorseException(Message: string; Args: array of const): EHorseException;

  public
    function QueryAsString   (Name: String; bRequired: Boolean = True): string;
    function QueryAsInteger  (Name: String; bRequired: Boolean = True): Integer;
    function QueryAsFloat    (Name: String; bRequired: Boolean = True): Double;
    function QueryAsDate     (Name: String; bRequired: Boolean = True): TDateTime;

    function PathAsString (Name: String; bRequired: Boolean = True): string;
    function PathAsInteger(Name: String; bRequired: Boolean = True): Integer;
    function PathAsFloat  (Name: String; bRequired: Boolean = True): Double;
    function PathAsDate   (Name: String; bRequired: Boolean = True): TDateTime;

    function HeaderAsString (Name: String; bRequired: Boolean = True): string;
    function HeaderAsInteger(Name: String; bRequired: Boolean = True): Integer;
    function HeaderAsFloat  (Name: String; bRequired: Boolean = True): Double;
    function HeaderAsDate   (Name: String; bRequired: Boolean = True): TDateTime;

    function BodyAsObject<T: class, constructor>: T; overload;
    procedure BodyAsObject(AObject: TObject); overload;

    function BodyAsJSONObject: TJSONObject;
    function BodyAsJSONArray: TJSONArray;

    function BodyAsObjectList<T: class, constructor>: TObjectList<T>;
  end;

  THelpers4DHorseResponse = class helper for THorseResponse
  public
    function AddOrSetHeader(Name: string; Value: String): THorseResponse; overload;
    function AddOrSetHeader(Name: string; Value: Integer): THorseResponse; overload;
    function AddOrSetHeader(Name: string; Value: Double): THorseResponse; overload;
    function AddOrSetHeader(Name: string; Value: TDateTime): THorseResponse; overload;

    procedure NotFound  (AMessage: string; const Args: array of const);
    procedure BadRequest(AMessage: string; const Args: array of const);

    function Send(Value: TObject; AOwner: Boolean = False; NotFoundMessage: String = 'Not Found'): THorseResponse; overload;
    function Send<M: class, constructor>(Value: TObjectList<M>; AOwner: Boolean = False): THorseResponse; overload;
  end;

  EHelpers4DHorse = class(Exception)
  private
    FstatusCode: Integer;
  public
    property statusCode: Integer read FstatusCode;

    constructor create(AStatusCode: Integer; AMessage: String);
  end;

  THelpers4DHorseError = class
  private
    Ferror: String;
    Fdescription: String;
  public
    property error: String read Ferror write Ferror;
    property description: String read Fdescription write Fdescription;
  end;

implementation

{ THelpers4DHorseRequest }

function THelpers4DHorseRequest.BodyAsJSONArray: TJSONArray;
begin
  result := Self.Body<TJSONArray>;
end;

function THelpers4DHorseRequest.BodyAsJSONObject: TJSONObject;
begin
  Result := Self.Body<TJSONObject>;
end;

procedure THelpers4DHorseRequest.BodyAsObject(AObject: TObject);
begin
  TJSONObject.ToObject(Body, AObject);
end;

function THelpers4DHorseRequest.BodyAsObject<T>: T;
begin
  Result := TJSONObject.ToObject<T>(Body);
end;

function THelpers4DHorseRequest.BodyAsObjectList<T>: TObjectList<T>;
begin
  result := TJSONArray.ToObjectList<T>(Body);
end;

function THelpers4DHorseRequest.HeaderAsDate(Name: String; bRequired: Boolean): TDateTime;
var
  str: string;
begin
  str := HeaderAsString(Name, bRequired);

  try
    result.fromIso8601ToDateTime( str );
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be date type.', [Name])
  end;
end;

function THelpers4DHorseRequest.HeaderAsFloat(Name: String; bRequired: Boolean): Double;
var
  str: string;
begin
  result := 0;
  str := HeaderAsString(Name, bRequired);

  try
    result := str.ToDouble;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be numeric type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.HeaderAsInteger(Name: String; bRequired: Boolean): Integer;
var
  str: string;
begin
  result := 0;
  str := HeaderAsString(Name, bRequired);

  try
    result := str.ToInteger;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be integer type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.HeaderAsString(Name: String; bRequired: Boolean): string;
begin
  Result := Headers[Name];

  if (bRequired) and (Result.Trim.IsEmpty) then
    RaiseHorseException('Set the parameter %s in header.', [Name]);
end;

function THelpers4DHorseRequest.PathAsDate(Name: String; bRequired: Boolean): TDateTime;
var
  str: string;
begin
  str := PathAsString(Name, bRequired);

  try
    result.fromIso8601ToDateTime( str );
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be date type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.PathAsFloat(Name: String; bRequired: Boolean): Double;
var
  str: string;
begin
  result := 0;
  str := PathAsString(Name, bRequired);

  try
    result := str.ToDouble;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be numeric type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.PathAsInteger(Name: String; bRequired: Boolean): Integer;
var
  str: string;
begin
  result := 0;
  str := PathAsString(Name, bRequired);

  try
    result := str.ToInteger;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be integer type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.PathAsString(Name: String; bRequired: Boolean): string;
begin
  result := EmptyStr;
  if Params.ContainsKey(Name) then
    Result := Params[Name];

  if (bRequired) and (Result.Trim.IsEmpty) then
    RaiseHorseException('Set the parameter %s in path', [Name]);
end;

function THelpers4DHorseRequest.QueryAsDate(Name: String; bRequired: Boolean): TDateTime;
var
  str: string;
begin
  str := QueryAsString(Name, bRequired);

  try
    result.fromIso8601ToDateTime(str);
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be date type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.QueryAsFloat(Name: String; bRequired: Boolean): Double;
var
  str: string;
begin
  result := 0;
  str := QueryAsString(Name, bRequired);

  try
    result := str.ToDouble;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be numeric type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.QueryAsInteger(Name: String; bRequired: Boolean): Integer;
var
  str: string;
begin
  result := 0;
  str := QueryAsString(Name, bRequired);

  try
    result := str.ToInteger;
  except
    on E: EConvertError do
      RaiseHorseException('The parameter %s must be integer type.', [Name]);
  end;
end;

function THelpers4DHorseRequest.QueryAsString(Name: String; bRequired: Boolean): string;
begin
  result := EmptyStr;
  if Query.ContainsKey(Name) then
    Result := Query[Name];

  if (bRequired) and (Result.Trim.IsEmpty) then
    RaiseHorseException('Set the parameter %s in query request.', [Name]);
end;

function THelpers4DHorseRequest.RaiseHorseException(Message: string; Args: array of const): EHorseException;
begin
  raise EHorseException.New
    .Status(THTTPStatus.BadRequest)
    .Title('Bad Request')
    .Error(Format(Message, Args))
    .&Unit(Self.UnitName)
    .&Type(TMessageType.Error);
end;

{ THelpers4DHorseResponse }

function THelpers4DHorseResponse.AddOrSetHeader(Name, Value: String): THorseResponse;
begin
  result := Self;
  Self.RawWebResponse.SetCustomHeader(Name, Value);
end;

function THelpers4DHorseResponse.AddOrSetHeader(Name: string; Value: Integer): THorseResponse;
begin
  result := AddOrSetHeader(Name, Value.ToString);
end;

function THelpers4DHorseResponse.AddOrSetHeader(Name: string; Value: Double): THorseResponse;
begin
  result := AddOrSetHeader(Name, Value.ToString);
end;

function THelpers4DHorseResponse.AddOrSetHeader(Name: string; Value: TDateTime): THorseResponse;
begin
  result := AddOrSetHeader(Name, Value.DateTimeToIso8601);
end;

procedure THelpers4DHorseResponse.BadRequest(AMessage: string; const Args: array of const);
var
  msg: string;
begin
  msg := IfThen(AMessage.IsEmpty, 'Bad Request', Format(AMessage, Args));
  Self.Status(THTTPStatus.BadRequest);
  raise EHelpers4DHorse.Create(400, msg);
end;

procedure THelpers4DHorseResponse.NotFound(AMessage: string; const Args: array of const);
var
  msg: string;
begin
  msg := IfThen(AMessage.IsEmpty, 'Not Found', Format(AMessage, Args));
  Self.Status(THTTPStatus.NotFound);
  raise EHelpers4DHorse.Create(404, msg);

end;

function THelpers4DHorseResponse.Send<M>(Value: TObjectList<M>; AOwner: Boolean): THorseResponse;
begin
  result := Self;
  if not Assigned(Value) then
  begin
    Self.Send<TJSONArray>(TJSONArray.Create);
    exit;
  end;

  Self.Send<TJSONArray>(TJSONArray.FromObjectList<M>(Value));
  if AOwner then
    FreeAndNil(Value);
end;

function THelpers4DHorseResponse.Send(Value: TObject; AOwner: Boolean; NotFoundMessage: String): THorseResponse;
begin
  result := Self;
  if not Assigned(value) then
    NotFound(NotFoundMessage, []);

  Self.Send<TJSONObject>(TJSONObject.FromObject(Value));
  if AOwner then
    FreeAndNil(Value);
end;

{ EHelpers4DHorse }

constructor EHelpers4DHorse.create(AStatusCode: Integer; AMessage: String);
begin
  inherited create(AMessage);
  FstatusCode := AStatusCode;
end;

end.
