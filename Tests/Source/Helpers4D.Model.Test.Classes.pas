unit Helpers4D.Model.Test.Classes;

interface

uses
  System.Generics.Collections;

type
  TAccountItem = class;
  TCustomer = class;

  TAccountType = (atTest, atProduction);

  TAccount = class
  private
    Fid: string;
    Fnumber: Integer;
    Fvalue: Currency;
    FaccountDate: TDateTime;
    Fcancelled: Boolean;
    Fcustomer: TCustomer;
    Fitems: TObjectList<TAccountItem>;
    FaccountType: TAccountType;
  public
    property id: string read Fid write Fid;
    property number: Integer read Fnumber write Fnumber;
    property value: Currency read Fvalue write Fvalue;
    property accountDate: TDateTime read FaccountDate write FaccountDate;
    property cancelled: Boolean read Fcancelled write Fcancelled;
    property customer: TCustomer read Fcustomer write Fcustomer;
    property accountType: TAccountType read FaccountType write FaccountType;
    property items: TObjectList<TAccountItem> read Fitems write Fitems;

    constructor create;
    destructor Destroy; override;
  end;

  TAccountItem = class
  private
    Fid: Double;
    FproductName: String;
    Fquantity: Double;
    Fvalue: Currency;
  public
    property id: Double read Fid write Fid;
    property productName: String read FproductName write FproductName;
    property quantity: Double read Fquantity write Fquantity;
    property value: Currency read Fvalue write Fvalue;
  end;

  TCustomer = class
  private
    Fid: string;
    Fname: String;
    Faddress: String;
  public
    property id: string read Fid write Fid;
    property name: String read Fname write Fname;
    property address: String read Faddress write Faddress;
  end;

implementation

{ TAccount }

constructor TAccount.create;
begin
  Fcustomer := TCustomer.Create;
  FaccountType := atProduction;
  Fitems := TObjectList<TAccountItem>.Create;
end;

destructor TAccount.Destroy;
begin
  Fcustomer.Free;
  Fitems.Free;
  inherited;
end;

end.
