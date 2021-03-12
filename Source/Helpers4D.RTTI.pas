unit Helpers4D.RTTI;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  IHelpers4DRTTI = interface
    ['{E18C1875-5D69-4651-8ED8-ECDC4D814EB7}']
    function GetType(AClass: TClass): TRttiType;
    function FindType(ATypeName: String): TRttiType;
  end;

  THelpers4DRTTI = class(TInterfacedObject, IHelpers4DRTTI)
  private
    class var FInstance: IHelpers4DRTTI;

  private
    FContext: TRttiContext;

    constructor createPrivate;
  public
    function GetType (AClass: TClass): TRttiType;
    function FindType(ATypeName: string): TRttiType;

    class function GetInstance: IHelpers4DRTTI;
    constructor create;
    destructor  Destroy; override;
  end;

  THelpers4DTypeHelper = class helper for TRttiType
  public
    function IsList: Boolean;
  end;

  THelpers4DPropertyHelper = class helper for TRttiProperty
  public
    function IsList     : Boolean;
    function IsString   : Boolean;
    function IsInteger  : Boolean;
    function IsEnum     : Boolean;
    function IsArray    : Boolean;
    function IsObject   : Boolean;
    function IsFloat    : Boolean;
    function IsDateTime : Boolean;
    function IsBoolean  : Boolean;
    function IsVariant  : Boolean;

    function GetAttribute<T: TCustomAttribute>: T;

    function IsEmpty(AObject: TObject): Boolean;

    function GetListType(AObject: TObject): TRttiType;
    function GetListCount(AObject: TObject): Integer;
    function GetListArray(AObject: TObject): TValue;

    function GetEnumValue(AObject: TObject): Integer;

    procedure SetValue(AObject: TObject; Value: String); overload;
    procedure SetValue(AObject: TObject; Value: Integer); overload;
    procedure SetValue(AObject: TObject; Value: Double); overload;
    procedure SetValue(AObject: TObject; Value: Boolean); overload;
    procedure SetValueDate(AObject: TObject; Value: TDateTime);
    procedure SetValueEnum(AObject: TObject; Value: Integer);
    procedure SetValueVariant(AObject: TObject; Value: Variant);
  end;

implementation

{ THelpers4DRTTI }

uses
  Helpers4D.Objects;

constructor THelpers4DRTTI.create;
begin
  raise Exception.Create('Use the GetInstance constructor.');
end;

constructor THelpers4DRTTI.createPrivate;
begin
  FContext := TRttiContext.Create;
end;

destructor THelpers4DRTTI.Destroy;
begin
  FContext.Free;
  inherited;
end;

function THelpers4DRTTI.FindType(ATypeName: string): TRttiType;
begin
  Result := FContext.FindType(ATypeName);
end;

class function THelpers4DRTTI.GetInstance: IHelpers4DRTTI;
begin
  if not Assigned(FInstance) then
    FInstance := THelpers4DRTTI.createPrivate;
  result := FInstance;
end;

function THelpers4DRTTI.GetType(AClass: TClass): TRttiType;
begin
  result := FContext.GetType(AClass);
end;

{ THelpers4DTypeHelper }

function THelpers4DTypeHelper.IsList: Boolean;
begin
  result := False;

  if Self.AsInstance.Name.ToLower.StartsWith('tobjectlist<') then
    Exit(True);

  if Self.AsInstance.Name.ToLower.StartsWith('tlist<') then
    Exit(True);
end;

{ THelpers4DPropertyHelper }

function THelpers4DPropertyHelper.GetAttribute<T>: T;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to Pred(Length(Self.GetAttributes)) do
    if Self.GetAttributes[i].ClassNameIs(T.className) then
      Exit(T( Self.GetAttributes[i]));
end;

function THelpers4DPropertyHelper.GetEnumValue(AObject: TObject): Integer;
begin
  result := GetValue(AObject).AsOrdinal;
end;

function THelpers4DPropertyHelper.GetListArray(AObject: TObject): TValue;
var
  rttiType: TRttiType;
  method  : TRttiMethod;
  value   : TValue;
begin
  value := GetValue(AObject);

  if value.AsObject = nil then
    Exit('[]');

  rttiType := value.AsObject.GetType;

  method := rttiType.GetMethod('ToArray');
  Result := method.Invoke(value.AsObject, []);
end;

function THelpers4DPropertyHelper.GetListCount(AObject: TObject): Integer;
var
  rttiType: TRttiType;
  method  : TRttiMethod;
  value   : TValue;
begin
  value := GetValue(AObject);

  if value.AsObject = nil then
    Exit(0);

  rttiType := value.AsObject.GetType;

  method := rttiType.GetMethod('ToArray');
  value  := method.Invoke(value.AsObject, []);

  Result := value.GetArrayLength;
end;

function THelpers4DPropertyHelper.GetListType(AObject: TObject): TRttiType;
var
  ListType     : TRttiType;
  ListTypeName : string;
begin
  ListType := THelpers4DRTTI.GetInstance.GetType(Self.GetValue(AObject).AsObject.ClassType);
  ListTypeName := ListType.ToString;

  ListTypeName := ListTypeName.Replace('TObjectList<', EmptyStr);
  ListTypeName := ListTypeName.Replace('TList<', EmptyStr);
  ListTypeName := ListTypeName.Replace('>', EmptyStr);

  result := THelpers4DRTTI.GetInstance.FindType(ListTypeName);
end;

function THelpers4DPropertyHelper.IsArray: Boolean;
begin
  Result := Self.PropertyType.TypeKind in
    [tkSet, tkArray, tkDynArray]
end;

function THelpers4DPropertyHelper.IsBoolean: Boolean;
begin
  result := Self.PropertyType.ToString.ToLower.Equals('boolean');
end;

function THelpers4DPropertyHelper.IsDateTime: Boolean;
begin
  result := (Self.PropertyType.ToString.ToLower.Equals('tdatetime')) or
             (Self.PropertyType.ToString.ToLower.Equals('tdate')) or
             (Self.PropertyType.ToString.ToLower.Equals('ttime'));
end;

function THelpers4DPropertyHelper.IsEmpty(AObject: TObject): Boolean;
var
  objectList : TObject;
begin
  result := False;

  if (Self.IsString) and (Self.GetValue(AObject).AsString.IsEmpty) then
    Exit(True);

  if (Self.IsInteger) and (Self.GetValue(AObject).AsInteger = 0) then
    Exit(True);

  if (Self.IsObject) and (Self.GetValue(AObject).AsObject = nil) then
    Exit(True);

  if (Self.IsArray) and (Self.GetValue(AObject).GetArrayLength = 0) then
    Exit(True);

  if (Self.IsList) then
  begin
    objectList := Self.GetValue(AObject).AsObject;
    if objectList.GetPropertyValue('Count').AsInteger = 0 then
      Exit(True);
  end;

  if (Self.IsFloat) and (Self.GetValue(AObject).AsExtended = 0) then
    Exit(True);

  if (Self.IsDateTime) and (Self.GetValue(AObject).AsExtended = 0) then
    Exit(True);
end;

function THelpers4DPropertyHelper.IsEnum: Boolean;
begin
  result := (not IsBoolean) and (Self.PropertyType.TypeKind = tkEnumeration);
end;

function THelpers4DPropertyHelper.IsFloat: Boolean;
begin
  result := (Self.PropertyType.TypeKind = tkFloat) and (not IsDateTime);
end;

function THelpers4DPropertyHelper.IsInteger: Boolean;
begin
  result := Self.PropertyType.TypeKind in [tkInt64, tkInteger];
end;

function THelpers4DPropertyHelper.IsList: Boolean;
begin
  Result := False;

  if Self.PropertyType.ToString.ToLower.StartsWith('tobjectlist<') then
    Exit(True);

  if Self.PropertyType.ToString.ToLower.StartsWith('tlist<') then
    Exit(True);
end;

function THelpers4DPropertyHelper.IsObject: Boolean;
begin
  result := (not IsList) and (Self.PropertyType.TypeKind = tkClass);
end;

function THelpers4DPropertyHelper.IsString: Boolean;
begin
  result := Self.PropertyType.TypeKind in
    [tkChar,
     tkString,
     tkWChar,
     tkLString,
     tkWString,
     tkUString];
end;

function THelpers4DPropertyHelper.IsVariant: Boolean;
begin
  result := Self.PropertyType.TypeKind = tkVariant;
end;

procedure THelpers4DPropertyHelper.SetValueDate(AObject: TObject; Value: TDateTime);
begin
  Self.SetValue(AObject, TValue.From<TDateTime>(Value));
end;

procedure THelpers4DPropertyHelper.SetValueEnum(AObject: TObject; Value: Integer);
begin
  Self.SetValue(AObject, TValue.FromOrdinal(Self.PropertyType.Handle, Value));
end;

procedure THelpers4DPropertyHelper.SetValueVariant(AObject: TObject; Value: Variant);
begin
  Self.SetValue(AObject, TValue.FromVariant(Value));
end;

procedure THelpers4DPropertyHelper.SetValue(AObject: TObject; Value: Double);
begin
  Self.SetValue(AObject, TValue.From<Double>(Value));
end;

procedure THelpers4DPropertyHelper.SetValue(AObject: TObject; Value: Integer);
begin
  Self.SetValue(AObject, TValue.From<Integer>(Value));
end;

procedure THelpers4DPropertyHelper.SetValue(AObject: TObject; Value: String);
begin
  Self.SetValue(AObject, TValue.From<String>(Value));
end;

procedure THelpers4DPropertyHelper.SetValue(AObject: TObject; Value: Boolean);
begin
  Self.SetValue(AObject, TValue.From<Boolean>(Value));
end;

end.
