unit Helpers4D.FMX.ComboBox;

interface

uses
  FMX.ListBox,
  System.UITypes;

type
  TComboBoxHelper = class helper for TComboBox
  public
    function FontSize(AValue: Integer): TComboBox;
    function FontColor(AValue: TAlphaColor): TComboBox;
    function FontFamily(AValue: string): TComboBox;
  end;

implementation

{ TComboBoxHelper }

function TComboBoxHelper.FontColor(AValue: TAlphaColor): TComboBox;
var
  LItem: TListBoxItem;
  I: Integer;
begin
  Result := Self;
  for I := 0 to Pred(Self.Count) do
  begin
    LItem := Self.ListItems[I];
    LItem.FontColor := AValue;
  end;
end;

function TComboBoxHelper.FontFamily(AValue: string): TComboBox;
var
  LItem: TListBoxItem;
  I: Integer;
begin
  Result := Self;
  for I := 0 to Pred(Self.Count) do
  begin
    LItem := Self.ListItems[I];
    LItem.Font.Family := AValue;
  end;
end;

function TComboBoxHelper.FontSize(AValue: Integer): TComboBox;
var
  LItem: TListBoxItem;
  I: Integer;
begin
  Result := Self;
  for I := 0 to Pred(Self.Count) do
  begin
    LItem := Self.ListItems[I];
    LItem.Font.Size := AValue;
  end;
end;

end.
