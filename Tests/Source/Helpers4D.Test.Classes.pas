unit Helpers4D.Test.Classes;

interface

uses
  System.Generics.Collections;

type
  TAddressType = (RESIDENTIAL, COMMERCIAL);

  TAddress = class;
  TPhone = class;

  TPerson = class
  private
    Fid: Double;
    Fname: string;
    FbirthdayDate: TDateTime;
    FisActive: Boolean;
    Faddress: TAddress;
    Fphones: TObjectList<TPhone>;
    Fweight: Double;
    Fheight: Double;
  public
    property id: Double read Fid write Fid;
    property name: string read Fname write Fname;
    property birthdayDate: TDateTime read FbirthdayDate write FbirthdayDate;
    property weight: Double read Fweight write Fweight;
    property height: Double read Fheight write Fheight;
    property isActive: Boolean read FisActive write FisActive;
    property address: TAddress read Faddress write Faddress;
    property phones: TObjectList<TPhone> read Fphones write Fphones;

    constructor create;
    destructor Destroy; override;
  end;

  TAddress = class
  private
    Fstreet: string;
    Fcomplement: String;
    Fnumber: Integer;
    Fcity: string;
    Fprincipal: Boolean;
    FaddressType: TAddressType;
  public
    property street: string read Fstreet write Fstreet;
    property complement: String read Fcomplement write Fcomplement;
    property number: Integer read Fnumber write Fnumber;
    property city: string read Fcity write Fcity;
    property principal: Boolean read Fprincipal write Fprincipal;
    property addressType: TAddressType read FaddressType write FaddressType;
  end;

  TPhone = class
  private
    Fid: String;
    Fnumber: string;
  public
    property id: String read Fid write Fid;
    property number: string read Fnumber write Fnumber;
  end;

implementation

{ TPerson }

constructor TPerson.create;
begin
  Faddress := TAddress.Create;
  Fphones  := TObjectList<TPhone>.create;
end;

destructor TPerson.Destroy;
begin
  Faddress.Free;
  Fphones.Free;
  inherited;
end;

end.
