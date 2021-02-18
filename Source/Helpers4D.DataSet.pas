unit Helpers4D.DataSet;

interface

uses
  Data.DB,
  Helpers4D.Objects,
  Helpers4D.RTTI,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.Variants,
  System.Classes;

type
  THelpers4DDataSet = class helper for TDataSet

  public
    function Clear: TDataSet;
    function CreateDataSet: TDataSet;
    function FilterDataSet(AFilter: String): TDataSet;
    function IndexFieldNames(Value: String): TDataSet;
    function MasterFields(Value: String): TDataSet;

    function AddStringField(const Name: string; Size: Integer; bRequired: Boolean = false): TDataSet;
    function AddDateTimeField(const Name: String): TDataSet;
    function AddIntegerField(const Name: String): TDataSet;
    function AddGraphicField(const Name: String): TDataSet;
    function AddBooleanField(const Name: String): TDataSet;
    function AddFloatField(const Name: String): TDataSet;

    procedure ForEach(Proc: TProc); overload;
    procedure ForEach(Proc: TProc<TDataSet>); overload;

    function SetValue(FieldName: string; FieldValue: Variant): TDataSet;
    function GetValue(FieldName: string; DefaultValue: Variant): Variant;

    function ToObject<T: class, constructor>: T; overload;
    function ToObject<T: class, constructor>(AFilter: String): T; overload;
    procedure ToObject(AObject: TObject); overload;
    procedure ToObject(AObject: TObject; AFilter: String); overload;

    function ToObjectList<T: class, constructor>: TObjectList<T>; overload;
    function ToObjectList<T: class, constructor>(AFilter: String): TObjectList<T>; overload;
    procedure ToObjectList<T: class, constructor>(AList: TObjectList<T>; AFilter: String); overload;
    procedure ToObjectList<T: class, constructor>(AList: TObjectList<T>); overload;
  end;

  THelpers4DField = class helper for TField
  public
    procedure SetValueToProperty(AObject: TObject; AProp: TRttiProperty);
  end;

implementation

{ THelpers4DDataSet }

function THelpers4DDataSet.AddBooleanField(const Name: String): TDataSet;
begin
  result := Self;
  FieldDefs.Add(Name, ftBoolean);
end;

function THelpers4DDataSet.AddDateTimeField(const Name: String): TDataSet;
begin
  result := Self;
  Self.FieldDefs.Add(Name, ftDateTime);
end;

function THelpers4DDataSet.AddFloatField(const Name: String): TDataSet;
begin
  result := Self;
  FieldDefs.Add(Name, ftFloat);
end;

function THelpers4DDataSet.AddGraphicField(const Name: String): TDataSet;
begin
  result := Self;
  FieldDefs.Add(Name, ftGraphic);
end;

function THelpers4DDataSet.AddIntegerField(const Name: String): TDataSet;
begin
  result := Self;
  FieldDefs.Add(Name, ftInteger);
end;

function THelpers4DDataSet.AddStringField(const Name: string; Size: Integer; bRequired: Boolean): TDataSet;
begin
  result := Self;
  FieldDefs.Add(Name, ftString, Size, bRequired);
end;

function THelpers4DDataSet.Clear: TDataSet;
begin
  result := Self;
  if not Assigned(Self) then
    Exit;

  if not Self.Active then
    Exit;

  Self.DisableControls;
  try
    Self.First;
    while not Self.Eof do
      Self.Delete;
  finally
    Self.EnableControls;
  end;
end;

function THelpers4DDataSet.CreateDataSet: TDataSet;
begin
  result := Self;
  Self.invokeMethod('createDataSet', []);
end;

function THelpers4DDataSet.FilterDataSet(AFilter: String): TDataSet;
begin
  result := Self;
  Filtered := False;
  Filter   := AFilter;
  Filtered := True;
  First;
end;

procedure THelpers4DDataSet.ForEach(Proc: TProc<TDataSet>);
var
  bookmark: TBookMark;
begin
  bookmark := GetBookmark;
  try
    DisableControls;
    First;
    while not Eof do
    begin
      Proc(self);
      Next;
    end;
  finally
    GotoBookmark(bookmark);
    FreeBookmark(bookmark);
    EnableControls;
  end;
end;

procedure THelpers4DDataSet.ForEach(Proc: TProc);
begin
  ForEach(
    procedure(ds: TDataset)
    begin
      Proc;
    end);
end;

function THelpers4DDataSet.GetValue(FieldName: string; DefaultValue: Variant): Variant;
var
  field: TField;
begin
  result := DefaultValue;
  try
    field  := FindField(FieldName);
    if (Assigned(field)) and (not (VarIsNull(field.Value))) then
      result := field.Value;
  except
  end;
end;

function THelpers4DDataSet.IndexFieldNames(Value: String): TDataSet;
begin
  result := Self;
  Self.SetPropertyValue('IndexFieldNames', Value);
end;

function THelpers4DDataSet.MasterFields(Value: String): TDataSet;
begin
  result := Self;
  Self.SetPropertyValue('MasterFields', Value);
end;

function THelpers4DDataSet.SetValue(FieldName: string; FieldValue: Variant): TDataSet;
var
  field: TField;
begin
  result := Self;
  field := FindField(FieldName);
  if Assigned(field) then
    field.Value := FieldValue;
end;

procedure THelpers4DDataSet.ToObject(AObject: TObject);
var
  i: Integer;
  field: TField;
  rttiProp: TRttiProperty;
begin
  if (not Assigned(AObject)) or (not Self.Active) then
    Exit;

  for i := 0 to Pred(AObject.GetPropertyCount) do
  begin
    rttiProp := AObject.GetProperty(i);
    field := Self.FindField(rttiProp.Name);
    if not Assigned(field) then
      Continue;

    field.SetValueToProperty(AObject, rttiProp);
  end;
end;

procedure THelpers4DDataSet.ToObject(AObject: TObject; AFilter: String);
begin
  FilterDataSet(AFilter);
  ToObject(AObject);
  Filtered := False;
end;

function THelpers4DDataSet.ToObject<T>(AFilter: String): T;
begin
  result := T.create;
  try
    ToObject(Result, AFilter);
  except
    Result.Free;
    raise;
  end;
end;

procedure THelpers4DDataSet.ToObjectList<T>(AList: TObjectList<T>);
var
  obj: T;
begin
  Self.ForEach(
  procedure
  begin
    obj := T.create;
    try
      Self.ToObject(obj);
      AList.Add(obj);
    except
      obj.Free;
      raise;
    end;
  end);
end;

procedure THelpers4DDataSet.ToObjectList<T>(AList: TObjectList<T>; AFilter: String);
begin
  FilterDataSet(AFilter);
  try
    ToObjectList<T>(AList);
  finally
    Filtered := False;
  end;
end;

function THelpers4DDataSet.ToObject<T>: T;
begin
  result := T.create;
  try
    ToObject(Result);
  except
    Result.Free;
    raise;
  end;
end;

function THelpers4DDataSet.ToObjectList<T>(AFilter: String): TObjectList<T>;
begin
  FilterDataSet(AFilter);
  try
    Result := ToObjectList<T>;
  finally
    Filtered := False;
  end;
end;

function THelpers4DDataSet.ToObjectList<T>: TObjectList<T>;
var
  obj: T;
  list: TObjectList<T>;
begin
  list := TObjectList<T>.create;
  try
    Self.ForEach(
      procedure
      begin
        obj := T.create;
        try
          Self.ToObject(obj);
          list.Add(obj);
        except
          obj.Free;
          raise;
        end;
      end);

    result := list;
  except
    list.Free;
    raise;
  end;
end;

{ THelpers4DField }

procedure THelpers4DField.SetValueToProperty(AObject: TObject; AProp: TRttiProperty);
begin
  if AProp.IsString then
  begin
    AProp.SetValue(AObject, Self.AsString);
    Exit;
  end;

  if AProp.IsInteger then
  begin
    AProp.SetValue(AObject, Self.AsInteger);
    Exit;
  end;

  if AProp.IsFloat then
  begin
    AProp.SetValue(AObject, Self.AsFloat);
    Exit;
  end;

  if AProp.IsDateTime then
  begin
    AProp.SetValue(AObject, Self.AsDateTime);
    Exit;
  end;

  if AProp.IsBoolean then
  begin
    AProp.SetValue(AObject, Self.AsBoolean);
    Exit;
  end;

  if AProp.IsEnum then
  begin
    AProp.SetValueEnum(AObject, Self.AsInteger);
    Exit;
  end;

  if AProp.IsVariant then
  begin
    AProp.SetValueVariant(AObject, Self.AsVariant);
    Exit;
  end;
end;

end.
