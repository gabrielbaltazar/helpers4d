unit Helpers4D.DataSet;

interface

uses
  Data.DB,
  Helpers4D.Objects,
  Helpers4D.RTTI,
  System.Rtti,
  System.SysUtils,
  System.Variants,
  System.Classes;

type
  THelpers4DDataSet = class helper for TDataSet

  public
    function Clear: TDataSet;
    function CreateDataSet: TDataSet;
    function IndexFieldNames(Value: String): TDataSet;
    function MasterFields(Value: String): TDataSet;

    function AddStringField(const Name: string; Size: Integer; bRequired: Boolean = false): TDataSet;
    function AddDateTimeField(const Name: String): TDataSet;
    function AddIntegerField(const Name: String): TDataSet;
    function AddGraphicField(const Name: String): TDataSet;
    function AddBooleanField(const Name: String): TDataSet;
    function AddFloatField(const Name: String): TDataSet;

    function SetFieldValue(FieldName: string; FieldValue: Variant): TDataSet;
    function GetFieldValue(FieldName: string; DefaultValue: Variant): Variant;

    procedure ToObject(AObject: TObject);
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

function THelpers4DDataSet.GetFieldValue(FieldName: string; DefaultValue: Variant): Variant;
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

function THelpers4DDataSet.SetFieldValue(FieldName: string; FieldValue: Variant): TDataSet;
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

  if AProp.IsVariant then
  begin
    AProp.SetValue(AObject, Self.AsVariant);
    Exit;
  end;
end;

end.
