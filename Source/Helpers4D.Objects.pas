unit Helpers4D.Objects;

interface

uses
  Helpers4D.RTTI,
  System.Rtti,
  System.JSON,
  System.SysUtils,
  System.TypInfo,
  System.Classes;

type THelpers4DObject = class helper for TObject
  private

  public
    function invokeMethod(const MethodName: string; const Parameters: array of TValue): TValue;
    function GetProperties: TArray<TRttiProperty>;
    function GetPropertyValue(Name: String): TValue;
    function GetPropertyCount: Integer;
    function GetProperty(Index: Integer): TRttiProperty; overload;
    function GetProperty(Name: String): TRttiProperty; overload;
    function GetType: TRttiType;
    procedure SetPropertyValue(Name, Value: String);

    function ToJSONObject: TJSONObject;
    procedure FromJSONObject(Value: TJSONObject);

    procedure CopyFrom(ASourceObject: TObject);

    class function GetAttribute<T: TCustomAttribute>: T;
end;

implementation

{ THelpers4DObject }

uses
  Helpers4D.JSON;

procedure THelpers4DObject.CopyFrom(ASourceObject: TObject);
var
  i: Integer;
  rProp: TRttiProperty;
  rSourceProp: TRttiProperty;
  listType: TRttiType;
  lValue: TValue;
  AObject: TObject;
begin
  for rProp in Self.GetProperties do
  begin
    rSourceProp := ASourceObject.GetProperty(rProp.Name);
    if not Assigned(rSourceProp) then
      Continue;

    if not rProp.IsWritable then
      Continue;

    try
      if rProp.IsEnum then
        rProp.SetValueEnum(Self, rSourceProp.GetEnumValue(ASourceObject))
      else
      if rProp.IsObject then
      begin
        if rSourceProp.IsObject then
        begin
          AObject := rProp.GetValue(Self).AsObject;
          AObject.CopyFrom(rSourceProp.GetValue(ASourceObject).AsObject);
        end;
      end
      else
      if rProp.IsList then
      begin
        if rSourceProp.IsList then
        begin
          listType := rProp.GetListType(Self);
          lValue   := rSourceProp.GetListArray(ASourceObject);
          for i := 0 to Pred(lValue.GetArrayLength) do
          begin
            if lValue.GetArrayElement(i).IsObject then
            begin
              AObject := listType.AsInstance.MetaclassType.Create;
              AObject.invokeMethod('create', []);
              AObject.CopyFrom(lValue.GetArrayElement(i).AsObject);
              rProp.GetValue(Self).AsObject.InvokeMethod('Add', [AObject]);
            end;
          end;
        end;
      end
      else
        rProp.SetValue(Self, rSourceProp.GetValue(ASourceObject));
    except
    end;
  end;
end;

procedure THelpers4DObject.FromJSONObject(Value: TJSONObject);
begin
  Value.ToObject(Self);
end;

class function THelpers4DObject.GetAttribute<T>: T;
var
  i: Integer;
  rType: TRttiType;
begin
  result := nil;
  rType  := THelpers4DRTTI.GetInstance.GetType(Self);

  for i := 0 to Pred(Length(rType.GetAttributes)) do
    if rType.GetAttributes[i].ClassNameIs(T.className) then
      Exit(T( rType.GetAttributes[i]));
end;

function THelpers4DObject.GetProperties: TArray<TRttiProperty>;
begin
  result := GetType.GetProperties;
end;

function THelpers4DObject.GetProperty(Name: String): TRttiProperty;
begin
  result := GetType.GetProperty(Name);
end;

function THelpers4DObject.GetProperty(Index: Integer): TRttiProperty;
begin
  result := GetType.GetProperties[Index];
end;

function THelpers4DObject.GetPropertyCount: Integer;
begin
  result := Length(GetType.GetProperties);
end;

function THelpers4DObject.GetPropertyValue(Name: String): TValue;
var
  rttiProp: TRttiProperty;
begin
  rttiProp := THelpers4DRTTI.GetInstance.GetType(Self.ClassType)
                .GetProperty(Name);

  if Assigned(rttiProp) then
    result := rttiProp.GetValue(Self);
end;

function THelpers4DObject.GetType: TRttiType;
begin
  result := THelpers4DRTTI.GetInstance.GetType(Self.ClassType);
end;

function THelpers4DObject.invokeMethod(const MethodName: string; const Parameters: array of TValue): TValue;
var
  rttiType: TRttiType;
  method  : TRttiMethod;
begin
  rttiType := THelpers4DRTTI.GetInstance.GetType(Self.ClassType);
  method   := rttiType.GetMethod(MethodName);

  if not Assigned(method) then
    raise ENotImplemented.CreateFmt('Cannot find method %s in %s', [MethodName, Self.ClassName]);

  result := method.Invoke(Self, Parameters);
end;

procedure THelpers4DObject.SetPropertyValue(Name, Value: String);
var
  rProp: TRttiProperty;
begin
  rProp := GetProperty(Name);
  if Assigned(rProp) then
    rProp.SetValue(Self, TValue.From<String>(Value));
end;

function THelpers4DObject.ToJSONObject: TJSONObject;
begin
  result := TJSONObject.FromObject(Self);
end;

end.
