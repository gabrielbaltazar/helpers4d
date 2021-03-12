unit Helpers4D.Test.CopyObjects;

interface

uses
  DUnitX.TestFramework,
  Helpers4D.Model.Test.Classes,
  Helpers4D.DTO.Test.Classes,
  Helpers4D.DateTime,
  Helpers4D.Objects,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes;


type
  [TestFixture]
  THelpers4DTestCopyObjects = class
  private
    FModel: TAccount;
    FDTO: TDTOAccount;

  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    constructor create;
    destructor Destroy; override;

    [Test]
    procedure TestPrimitiveTypes;

    [Test]
    procedure TestObjectTypes;

    [Test]
    procedure TestListTypes;
  end;

implementation

{ THelpers4DTestCopyObjects }

constructor THelpers4DTestCopyObjects.create;
begin

end;

destructor THelpers4DTestCopyObjects.Destroy;
begin
  inherited;
end;

procedure THelpers4DTestCopyObjects.Setup;
begin
  FModel := TAccount.create;
  FModel.id := '1';
  FModel.number := 2;
  FModel.value := 90.50;
  FModel.accountDate := Now;
  FModel.cancelled := False;
  FModel.customer.id := '2';
  FModel.customer.name := 'Customer 2';
  FModel.customer.address := 'Address 2';

  FModel.items.Add(TAccountItem.Create);
  FModel.items.Last.id := 1;
  FModel.items.Last.productName := 'Product 1';
  FModel.items.Last.quantity := 1;
  FModel.items.Last.value := 30;

  FModel.items.Add(TAccountItem.Create);
  FModel.items.Last.id := 2;
  FModel.items.Last.productName := 'Product 2';
  FModel.items.Last.quantity := 2;
  FModel.items.Last.value := 60.50;
end;

procedure THelpers4DTestCopyObjects.TearDown;
begin
  FreeAndNil(FModel);
  FreeAndNil(FDTO);
end;

procedure THelpers4DTestCopyObjects.TestListTypes;
begin
  FDTO := TDTOAccount.create;
  FDTO.CopyFrom(FModel);

  Assert.AreEqual(FModel.items.Count, FDTO.items.Count);
  Assert.AreEqual(2, FDTO.items.Count);

  Assert.AreEqual(FModel.items[0].id.ToString, FDTO.items[0].id.ToString);
  Assert.AreEqual(FModel.items[0].productName, FDTO.items[0].productName);
  Assert.AreEqual(FModel.items[0].quantity.ToString, FDTO.items[0].quantity.ToString);
  Assert.AreEqual(CurrToStr(FModel.items[0].value), CurrToStr(FDTO.items[0].value));

  Assert.AreEqual(FModel.items[1].id.ToString, FDTO.items[1].id.ToString);
  Assert.AreEqual(FModel.items[1].productName, FDTO.items[1].productName);
  Assert.AreEqual(FModel.items[1].quantity.ToString, FDTO.items[1].quantity.ToString);
  Assert.AreEqual(CurrToStr(FModel.items[1].value), CurrToStr(FDTO.items[1].value));
end;

procedure THelpers4DTestCopyObjects.TestObjectTypes;
begin
  FDTO := TDTOAccount.create;
  FDTO.CopyFrom(FModel);

  Assert.AreEqual(FModel.customer.id, FDTO.customer.id);
  Assert.AreEqual(FModel.customer.name, FDTO.customer.name);
  Assert.AreEqual(FModel.customer.address, FDTO.customer.address);
end;

procedure THelpers4DTestCopyObjects.TestPrimitiveTypes;
begin
  FDTO := TDTOAccount.create;
  FDTO.CopyFrom(FModel);

  Assert.AreEqual(FModel.id, FDTO.id);
  Assert.AreEqual(FModel.number, FDTO.number);
  Assert.AreEqual(CurrToStr(FModel.value), CurrToStr(FDTO.value));
  Assert.AreEqual(FModel.accountDate.FormatYYYY_MM_DD, FDTO.accountDate.FormatYYYY_MM_DD);
  Assert.AreEqual(FModel.cancelled, FModel.cancelled);
  Assert.AreEqual(1, Integer(FDTO.accountType));
end;

end.
