unit Helpers4D.JSON;

interface

uses
  System.JSON,
  Helpers4D.DateTime,
  Helpers4D.RTTI,
  Helpers4D.Objects,
  System.Generics.Collections,
  System.Rtti,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.TypInfo,
  System.Variants;

type
  THelpers4DJSONObject = class helper for TJSONObject
  private
    class function IsIgnoreProperty(AObject: TObject; AProp: TRttiProperty): Boolean;

    procedure jsonObjectToObjectList(AObject: TObject; AJSON: TJSONArray; AProp: TRttiProperty);

    class function ValueToJson(AObject: TObject; AProp: TRttiProperty): string;
    class function ValueListToJson(AObject: TObject; AProp: TRttiProperty): string;
    class function ObjectToJSONString(AObject: TObject): string;
  public
    function ValueAsString (Name: string; Default: string = ''): string;
    function ValueAsInteger(Name: string; Default: Integer = 0): Integer;
    function ValueAsFloat  (Name: string; Default: Double = 0): Double;
    function ValueAsDateTime(Name: string; AFormat: String = ''; Default: TDateTime = 0): TDateTime;
    function ValueAsBoolean(Name: string; Default: Boolean = True): Boolean;

    function ValueAsJSONObject(Name: String): TJSONObject;
    function ValueAsJSONArray (Name: String): TJSONArray;

    function AddDt(const Name: string; Value: TDateTime; Format: string = ''): TJSONObject; overload;
    function Add(const Name, Value: string): TJSONObject; overload;
    function Add(const Name: string; Value: Integer): TJSONObject; overload;
    function Add(const Name: string; Value: Double): TJSONObject; overload;
    function Add(const Name: string; Value: Boolean): TJSONObject; overload;
    function Add(const Name: string; Value: TJSONObject): TJSONObject; overload;
    function Add(const Name: string; Value: TJSONArray): TJSONObject; overload;

    procedure ToObject(AObject: TObject); overload;
    function ToObject<T: class, constructor>: T; overload;

    function ClearEmptyValues: TJSONObject;

    function SaveToFile(const AFileName: string): TJSONObject;

    class function FromObject(Value: TObject; bIgnoreEmptyValues: Boolean = True): TJSONObject;
    class function FromString(Value: String; bIgnoreEmptyValues: Boolean = True): TJSONObject;
    class function FromFile(const FileName: String): TJSONObject;
    class procedure ToObject(JSONString: String; AObject: TObject); overload;
    class function ToObject<T: class, constructor>(JSONString: String): T; overload;
  end;

  THelpers4DJSONArray = class helper for TJSONArray
  public
    function ItemAsJSONObject(Index: Integer): TJSONObject;
    function ActiveJSONObject: TJSONObject;

    function ToObjectList<T: class, constructor>: TObjectList<T>; overload;
    procedure ToObjectList<T: class, constructor>(AList: TObjectList<T>); overload;

    class function ToObjectList<T: class, constructor>(JSONString: String): TObjectList<T>; overload;
    class function FromObjectList<T: class>(AList: TObjectList<T>; bIgnoreEmptyValues: Boolean = True): TJSONArray;
    class function FromString(Value: String; bIgnoreEmptyValues: Boolean = True): TJSONArray;
    class function FromFile(const FileName: String): TJSONArray;

    function ClearEmptyValues: TJSONArray;

    function SaveToFile(const AFileName: string): TJSONArray;
  end;

  THelpers4DJSONValue = class helper for TJSONValue
  public
    function AsString(ADefault: String = ''): string;
    function AsInteger(ADefault: Integer = 0): Integer;
    function AsFloat(ADefault: Double = 0): Double;
    function AsBoolean(ADefault: Boolean = False): Boolean;
    function AsVariant: Variant;
    function AsEnumInteger(TypeInfo: PTypeInfo): Integer;
    function AsDateTime: TDateTime;
    function AsJSONObject: TJSONObject;
    function AsJSONArray: TJSONArray;
  end;

implementation

{ THelpers4DJSONObject }

function THelpers4DJSONObject.AddDt(const Name: string; Value: TDateTime; Format: string = ''): TJSONObject;
var
  strDate: string;
begin
  result := Self;
  strDate := Value.DateTimeToIso8601;
  if not Format.Trim.IsEmpty then
    strDate := FormatDateTime(Format, Value);

  AddPair(Name, strDate);
end;

function THelpers4DJSONObject.ClearEmptyValues: TJSONObject;
var
  LPair: TJSONPair;
  LItem: TObject;
  i: Integer;
begin
  result := Self;
  if not assigned(Self) then
    Exit;

  for i := Self.Count -1 downto 0  do
  begin
    LPair := TJSONPair(Self.Pairs[i]);
    if LPair.JsonValue is TJSOnObject then
    begin
      TJSOnObject(LPair.JsonValue).ClearEmptyValues;
      if LPair.JsonValue.ToString.Equals('{}') then
      begin
        Self.RemovePair(LPair.JsonString.Value).DisposeOf;
        Continue;
      end;
    end
    else if LPair.JsonValue is TJSONArray then
    begin
      if (TJSONArray(LPair.JsonValue).Count = 0) then
      begin
        Self.RemovePair(LPair.JsonString.Value).DisposeOf;
      end
      else
        for LItem in TJSONArray(LPair.JsonValue) do
        begin
          if LItem is TJSOnObject then
            TJSOnObject(LItem).ClearEmptyValues;
        end;
    end
    else
    begin
      if (LPair.JsonValue.value = '') or (LPair.JsonValue.ToJSON = '0') then
      begin
        RemovePair(LPair.JsonString.Value).DisposeOf;
      end;
    end;
  end;
end;

class function THelpers4DJSONObject.FromFile(const FileName: String): TJSONObject;
var
  jsonFile: TStrings;
begin
  jsonFile := TStringList.Create;
  try
    jsonFile.LoadFromFile(FileName);
    Result := Self.FromString(jsonFile.Text);
  finally
    jsonFile.Free;
  end;
end;

class function THelpers4DJSONObject.FromObject(Value: TObject; bIgnoreEmptyValues: Boolean = True): TJSONObject;
var
  jsonString: string;
begin
  jsonString := ObjectToJSONString(Value);
  result := TJSONObject.FromString(jsonString, bIgnoreEmptyValues);
end;

class function THelpers4DJSONObject.FromString(Value: String; bIgnoreEmptyValues: Boolean = True): TJSONObject;
var
  json : string;
begin
  json := Value.Replace(#$D, EmptyStr)
               .Replace(#$A, EmptyStr);

  result := TJSONObject.ParseJSONValue(json) as TJSONObject;
  if bIgnoreEmptyValues then
    Result.ClearEmptyValues;
end;

class function THelpers4DJSONObject.IsIgnoreProperty(AObject: TObject; AProp: TRttiProperty): Boolean;
begin
  result := False;
  if (AObject.InheritsFrom(TInterfacedObject)) then
    result := AProp.Name.ToLower.Equals('refcount');
end;

procedure THelpers4DJSONObject.jsonObjectToObjectList(AObject: TObject; AJSON: TJSONArray; AProp: TRttiProperty);
var
  i          : Integer;
  objectItem : TObject;
  listType   : TRttiType;
begin
  if not Assigned(AJSON) then
    Exit;

  listType := AProp.GetListType(AObject);
  for i := 0 to Pred(AJSON.Count) do
  begin
    objectItem := listType.AsInstance.MetaclassType.Create;
    objectItem.invokeMethod('create', []);

    AJSON.ItemAsJSONObject(i).ToObject(objectItem);
    AProp.GetValue(AObject).AsObject.InvokeMethod('Add', [objectItem]);
  end;
end;

class function THelpers4DJSONObject.ObjectToJSONString(AObject: TObject): string;
var
  rttiProperty: TRttiProperty;
begin
  result := '{';

  for rttiProperty in AObject.GetProperties do
  begin
    if (not IsIgnoreProperty(AObject, rttiProperty)) and
       (not rttiProperty.IsEmpty(AObject))
    then
    begin
      result := result + System.SysUtils.Format('"%s":', [rttiProperty.Name]);
      result := result + ValueToJson(AObject, rttiProperty) + ',';
    end;
  end;

  if Result.EndsWith(',') then
    Result[Length(Result)] := '}'
  else
    Result := Result + '}';
end;

function THelpers4DJSONObject.SaveToFile(const AFileName: string): TJSONObject;
var
  jsonFile: TStrings;
begin
  result := Self;
  jsonFile := TStringList.Create;
  try
    jsonFile.Text := Self.ToString;
    jsonFile.SaveToFile(AFileName);
  finally
    jsonFile.Free;
  end;
end;

procedure THelpers4DJSONObject.ToObject(AObject: TObject);
var
  rProp: TRttiProperty;
  jsonValue: TJSONValue;
begin
  if (not Assigned(Self)) or (not Assigned(AObject)) then
    Exit;

  for rProp in AObject.GetProperties do
  begin
    if IsIgnoreProperty(AObject, rProp) then
      Continue;

    jsonValue := Values[rProp.Name];
    if (not Assigned(jsonValue)) or (not rProp.IsWritable) then
      Continue;

    if rProp.IsString then
    begin
      rProp.SetValue(AObject, jsonValue.AsString);
      Continue;
    end;

    if rProp.IsVariant then
    begin
      rProp.SetValue(AObject, jsonValue.AsString);
      Continue;
    end;

    if rProp.IsInteger then
    begin
      rProp.SetValue(AObject, jsonValue.AsInteger);
      Continue;
    end;

    if rProp.IsEnum then
    begin
      rProp.SetValueEnum(AObject, jsonValue.AsEnumInteger(rProp.GetValue(AObject).TypeInfo));
      Continue;
    end;

    if rProp.IsObject then
    begin
      jsonValue.AsJSONObject.ToObject(rProp.GetValue(AObject).AsObject);
      Continue;
    end;

    if rProp.IsFloat then
    begin
      rProp.SetValue(AObject, jsonValue.AsFloat);
      Continue;
    end;

    if rProp.IsDateTime then
    begin
      rProp.SetValueDate(AObject, jsonValue.AsDateTime);
      Continue;
    end;

    if rProp.IsBoolean then
    begin
      rProp.SetValue(AObject, jsonValue.AsBoolean);
      Continue;
    end;

    if rProp.IsList then
    begin
      jsonObjectToObjectList(AObject, jsonValue.AsJSONArray, rProp);
      Continue;
    end;
  end;
end;

class procedure THelpers4DJSONObject.ToObject(JSONString: String; AObject: TObject);
var
  json: TJSONObject;
begin
  json := FromString(JSONString);
  try
    if Assigned(json) then
      json.ToObject(AObject);
  finally
    json.Free;
  end;
end;

class function THelpers4DJSONObject.ToObject<T>(JSONString: String): T;
var
  json : TJSONObject;
begin
  result := nil;
  json := TJSONObject.FromString(JSONString);
  try
    if Assigned(json) then
      result := json.ToObject<T>;
  finally
    json.Free;
  end;
end;

function THelpers4DJSONObject.ToObject<T>: T;
begin
  result := T.create;
  try
    ToObject(result);
  except
    Result.Free;
    raise;
  end;
end;

function THelpers4DJSONObject.Add(const Name, Value: string): TJSONObject;
begin
  result := Self;
  AddPair(Name, Value);
end;

function THelpers4DJSONObject.Add(const Name: string; Value: Integer): TJSONObject;
begin
  result := Self;
  AddPair(Name, TJSONNumber.Create(Value));
end;

function THelpers4DJSONObject.Add(const Name: string; Value: Double): TJSONObject;
begin
  result := Self;
  AddPair(Name, TJSONNumber.Create(Value));
end;

function THelpers4DJSONObject.ValueAsBoolean(Name: string; Default: Boolean): Boolean;
var
  strValue: string;
begin
  strValue := ValueAsString(Name, IfThen(Default, 'true', 'false')).ToLower;
  result := not strValue.Equals('false');
end;

function THelpers4DJSONObject.ValueAsDateTime(Name, AFormat: String; Default: TDateTime): TDateTime;
var
  strValue: string;
begin
  result := Default;
  strValue := ValueAsString(Name, '0');
  result.fromIso8601ToDateTime(strValue);
end;

function THelpers4DJSONObject.ValueAsFloat(Name: string; Default: Double): Double;
var
  strValue: string;
begin
  strValue := ValueAsString(Name, Default.ToString);
  result := StrToFloatDef(strValue, Default);
end;

function THelpers4DJSONObject.ValueAsInteger(Name: string; Default: Integer): Integer;
var
  strValue: string;
begin
  strValue := ValueAsString(Name, default.ToString);
  result := StrToIntDef(strValue, Default);
end;

function THelpers4DJSONObject.ValueAsJSONArray(Name: String): TJSONArray;
begin
  result := nil;
  if GetValue(Name) is TJSONArray then
    result := TJSONArray( GetValue(Name) );
end;

function THelpers4DJSONObject.ValueAsJSONObject(Name: String): TJSONObject;
begin
  result := nil;
  if GetValue(Name) is TJSONObject then
    result := TJSONObject( GetValue(Name) );
end;

function THelpers4DJSONObject.ValueAsString(Name, Default: string): string;
begin
  result := Default;
  if GetValue(Name) <> nil then
    result := GetValue(Name).Value;
end;

class function THelpers4DJSONObject.ValueListToJson(AObject: TObject; AProp: TRttiProperty): string;
var
  rttiType: TRttiType;
  method  : TRttiMethod;
  value   : TValue;
  i       : Integer;
begin
  value := AProp.GetValue(AObject);

  if value.AsObject = nil then
    Exit('[]');

  rttiType := value.AsObject.GetType;

  method := rttiType.GetMethod('ToArray');
  value  := method.Invoke(value.AsObject, []);

  if value.GetArrayLength = 0 then
    Exit('[]');

  result := '[';
  for i := 0 to value.GetArrayLength - 1 do
  begin
    if value.GetArrayElement(i).IsObject then
      result := Result + ObjectToJsonString(value.GetArrayElement(i).AsObject) + ','
  	else
	    result := Result + '"' + (value.GetArrayElement(i).AsString) + '"' + ',';
  end;

  result[Length(Result)] := ']';
end;

class function THelpers4DJSONObject.ValueToJson(AObject: TObject; AProp: TRttiProperty): string;
var
  value : TValue;
  data  : TDateTime;
begin
  value := AProp.GetValue(AObject);

  if AProp.IsString then
    Exit('"' + Value.AsString.Replace('\', '\\').Replace('"', '\"') + '"');

  if AProp.IsInteger then
    Exit(value.AsInteger.ToString);

  if AProp.IsEnum then
    Exit('"' + GetEnumName(AProp.GetValue(AObject).TypeInfo, AProp.GetValue(AObject).AsOrdinal) + '"');

  if AProp.IsFloat then
    Exit(value.AsExtended.ToString.Replace(',', '.'));

  if AProp.IsBoolean then
    Exit(IfThen(value.AsBoolean, 'true', 'false'));

  if AProp.IsDateTime then
  begin
    data := value.AsExtended;
    if data = 0 then
      Exit('""');

    result := '"' + data.DateTimeToIso8601 + '"';
    Exit;
  end;

  if AProp.IsObject then
    Exit(ObjectToJsonString(value.AsObject));

  if AProp.IsList then
    Exit(ValueListToJson(AObject, AProp));

  if AProp.IsVariant then
  begin
    if VarType(value.AsVariant) = varDate then
    begin
      data := value.AsVariant;
      if data = 0 then
        Exit('""');

      result := '"' + data.DateTimeToIso8601 + '"';
      Exit;
    end;
    Exit('"' + VartoStrDef(value.AsVariant, '') + '"')
  end;
end;

function THelpers4DJSONObject.Add(const Name: string; Value: Boolean): TJSONObject;
begin
  result := Self;
  AddPair(Name, TJSONBool.Create(Value));
end;

function THelpers4DJSONObject.Add(const Name: string; Value: TJSONArray): TJSONObject;
begin
  result := Self;
  AddPair(Name, Value);
end;

function THelpers4DJSONObject.Add(const Name: string; Value: TJSONObject): TJSONObject;
begin
  result := Self;
  AddPair(Name, Value);
end;

{ THelpers4DJSONArray }

function THelpers4DJSONArray.ActiveJSONObject: TJSONObject;
begin
  result := Items[Count - 1] as TJSONObject;
end;

function THelpers4DJSONArray.ClearEmptyValues: TJSONArray;
var
  i: Integer;
begin
  result := Self;
  for i := 0 to Pred(Count) do
  begin
    if ItemAsJSONObject(i) <> nil then
      ItemAsJSONObject(i).ClearEmptyValues;
  end;
end;

class function THelpers4DJSONArray.FromFile(const FileName: String): TJSONArray;
var
  jsonFile: TStrings;
begin
  jsonFile := TStringList.Create;
  try
    jsonFile.LoadFromFile(FileName);
    Result := Self.FromString(FileName);
  finally
    jsonFile.Free;
  end;
end;

class function THelpers4DJSONArray.FromObjectList<T>(AList: TObjectList<T>; bIgnoreEmptyValues: Boolean = True): TJSONArray;
var
  obj: T;
begin
  result := TJSONArray.Create;
  for obj in AList do
    Result.Add(TJSONObject.FromObject(obj, bIgnoreEmptyValues));
end;

class function THelpers4DJSONArray.FromString(Value: String; bIgnoreEmptyValues: Boolean = True): TJSONArray;
var
  json : string;
begin
  json := Value.Replace(#$D, EmptyStr)
               .Replace(#$A, EmptyStr);

  result := TJSONObject.ParseJSONValue(json) as TJSONArray;
  if bIgnoreEmptyValues then
    Result.ClearEmptyValues;
end;

function THelpers4DJSONArray.ItemAsJSONObject(Index: Integer): TJSONObject;
begin
  result := Items[Index] as TJSONObject;
end;

function THelpers4DJSONArray.SaveToFile(const AFileName: string): TJSONArray;
var
  jsonFile: TStrings;
begin
  result := Self;
  jsonFile := TStringList.Create;
  try
    jsonFile.Text := Self.ToString;
    jsonFile.SaveToFile(AFileName);
  finally
    jsonFile.Free;
  end;
end;

class function THelpers4DJSONArray.ToObjectList<T>(JSONString: String): TObjectList<T>;
var
  json: TJSONArray;
begin
  json := FromString(JSONString);
  try
    result := json.ToObjectList<T>;
  finally
    json.Free;
  end;
end;

procedure THelpers4DJSONArray.ToObjectList<T>(AList: TObjectList<T>);
var
  i: Integer;
begin
  for i := 0 to Pred(Count) do
    AList.Add(ItemAsJSONObject(i).ToObject<T>);
end;

function THelpers4DJSONArray.ToObjectList<T>: TObjectList<T>;
begin
  Result := TObjectList<T>.create;
  try
    ToObjectList<T>(Result);
  except
    Result.Free;
    raise;
  end;
end;

{ THelpers4DJSONValue }

function THelpers4DJSONValue.AsBoolean(ADefault: Boolean): Boolean;
begin
  result := ADefault;
  if Assigned(Self) then
    result := AsString('false').ToLower.Equals('true');
end;

function THelpers4DJSONValue.AsDateTime: TDateTime;
begin
  result := 0;
  if Assigned(Self) then
    result.fromIso8601ToDateTime(AsString);
end;

function THelpers4DJSONValue.AsEnumInteger(TypeInfo: PTypeInfo): Integer;
begin
  result := 0;
  if Assigned(Self) then
    result := GetEnumValue(TypeInfo, AsString)
end;

function THelpers4DJSONValue.AsFloat(ADefault: Double): Double;
begin
  result := ADefault;
  if Assigned(Self) then
    result := AsString.ToDouble;
end;

function THelpers4DJSONValue.AsInteger(ADefault: Integer): Integer;
begin
  result := ADefault;
  if Assigned(Self) then
    result := AsString.ToInteger;
end;

function THelpers4DJSONValue.AsJSONArray: TJSONArray;
begin
  result := nil;
  if Assigned(Self) then
    result := Self as TJSONArray;
end;

function THelpers4DJSONValue.AsJSONObject: TJSONObject;
begin
  result := nil;
  if Assigned(Self) then
    result := Self as TJSONObject;
end;

function THelpers4DJSONValue.AsString(ADefault: String): string;
begin
  result := ADefault;
  if Assigned(Self) then
    result := Value;
end;

function THelpers4DJSONValue.AsVariant: Variant;
begin
  result := AsString;
end;

end.


