unit Helpers4D.FMX.ListView;

interface

uses
  FMX.ListView,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  System.SysUtils;

type
  TListViewHelper = class helper for TListView
  public
    procedure Clear;
    function SelectedObject: TObject;
  end;

  TListViewItemHelper = class helper for TListViewItem
  public
    function ItemText(const AName: string): TListItemText;
    function ItemImage(const AName: string): TListItemImage;
  end;

  TListItemTextHelper = class helper for TListItemText
  private
    procedure SetAsCurrency(const AValue: Currency);
  public
    property AsCurrency: Currency write SetAsCurrency;
  end;

implementation

{ TListViewHelper }

procedure TListViewHelper.Clear;
begin
  Self.Items.Clear;
end;

function TListViewHelper.SelectedObject: TObject;
begin
  Result := nil;
  if Self.ItemIndex >= 0 then
    Result := Self.Items[Self.ItemIndex].TagObject;
end;

{ TListViewItemHelper }

function TListViewItemHelper.ItemImage(const AName: string): TListItemImage;
begin
  Result := TListItemImage(Self.Objects.FindDrawable(AName));
end;

function TListViewItemHelper.ItemText(const AName: string): TListItemText;
begin
  Result := TListItemText(Self.Objects.FindDrawable(AName));
end;

{ TListItemTextHelper }

procedure TListItemTextHelper.SetAsCurrency(const AValue: Currency);
begin
  Self.Text := FormatCurr('R$ ,0.00', AValue);
end;

end.
