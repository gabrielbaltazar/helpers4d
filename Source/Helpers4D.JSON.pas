unit Helpers4D.JSON;

interface

uses
  System.JSON,
  Herlpers4D.DateTime,
  System.Generics.Collections,
  System.SysUtils,
  System.StrUtils;

type
  THelpers4DJSONObject = class helper for TJSONObject
  public
    function ValueAsString (Name: string; Default: string = ''): string;
    function ValueAsInteger(Name: string; Default: Integer = 0): Integer;
    function ValueAsFloat  (Name: string; Default: Double = 0): Double;
    function ValueAsDateTime(Name: string; AFormat: String = ''; Default: TDateTime = 0): TDateTime;
    function ValueAsBoolean(Name: string; Default: Boolean = True): Boolean;

    function ValueAsJSONObject(Name: String): TJSONObject;
    function ValueAsJSONArray (Name: String): TJSONArray;
  end;

  THelpers4DJSONArray = class helper for TJSONArray
  public
    function ItemAsJSONObject(Index: Integer): TJSONObject;
  end;

implementation

{ THelpers4DJSONObject }

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

{ THelpers4DJSONArray }

function THelpers4DJSONArray.ItemAsJSONObject(Index: Integer): TJSONObject;
begin
  result := Items[Index] as TJSONObject;
end;

end.


