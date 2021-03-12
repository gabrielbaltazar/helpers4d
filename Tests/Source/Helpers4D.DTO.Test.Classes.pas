unit Helpers4D.DTO.Test.Classes;

interface

uses
  System.Generics.Collections;

type
  TDTOAccountItem = class;
  TDTOCustomer = class;

  TDTOAccountType = (dtoTest, dtoProduction);

  TDTOAccount = class
  private
    Fid: string;
    Fnumber: Integer;
    Fvalue: Currency;
    FaccountDate: TDateTime;
    Fcancelled: Boolean;
    Fcustomer: TDTOCustomer;
    Fitems: TObjectList<TDTOAccountItem>;
    FaccountType: TDTOAccountType;
  public
    property id: string read Fid write Fid;
    property number: Integer read Fnumber write Fnumber;
    property value: Currency read Fvalue write Fvalue;
    property accountDate: TDateTime read FaccountDate write FaccountDate;
    property cancelled: Boolean read Fcancelled write Fcancelled;
    property accountType: TDTOAccountType read FaccountType write FaccountType;
    property customer: TDTOCustomer read Fcustomer write Fcustomer;
    property items: TObjectList<TDTOAccountItem> read Fitems write Fitems;

    constructor create;
    destructor Destroy; override;
  end;

  TDTOAccountItem = class
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

  TDTOCustomer = class
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

{ TDTOAccount }

constructor TDTOAccount.create;
begin
  FaccountType := dtoTest;
  Fcustomer := TDTOCustomer.Create;
  Fitems := TObjectList<TDTOAccountItem>.Create;
end;

destructor TDTOAccount.Destroy;
begin
  Fcustomer.Free;
  Fitems.Free;
  inherited;
end;

end.

