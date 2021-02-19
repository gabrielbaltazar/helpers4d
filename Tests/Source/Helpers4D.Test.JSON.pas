unit Helpers4D.Test.JSON;

interface

uses
  DUnitX.TestFramework,
  Helpers4D.Test.Base,
  Helpers4D.JSON,
  Helpers4D.Objects,
  Helpers4D.DateTime,
  Helpers4D.Test.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.JSON;

type
  [TestFixture]
  THelpers4DTestJSON = class(THelpers4DBase)

  private
    FJSON: TJSONObject;
    FPerson: TPerson;

    procedure createJSON;

  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestReadValues;

    [Test]
    procedure TestJSONToObject;

    [Test]
    procedure TestObjectToJSON;
end;

implementation

{ THelpers4DTestJSON }

procedure THelpers4DTestJSON.createJSON;
var
  jsonAddress: TJSONObject;
  jsonPhones : TJSONArray;
begin
  FJSON := TJSONObject.Create;
  FJSON
    .Add('id', 1)
    .Add('name', 'Name 1')
    .AddDt('birthdayDate', EncodeDate(1990, 2, 13))
    .Add('height', 1.72)
    .Add('weight', 80.52)
    .Add('isActive', False);

  jsonAddress := TJSONObject.Create;
  jsonAddress
    .Add('street', 'street 1')
    .Add('complement', 'complement 1')
    .Add('number', 1)
    .Add('city', 'city 1')
    .Add('principal', False)
    .Add('addressType', 'COMMERCIAL');

  jsonPhones := TJSONArray.Create;
  jsonPhones.AddElement(TJSONObject.Create);
  jsonPhones.ActiveJSONObject
    .Add('id', 1)
    .Add('number', '999999');

  jsonPhones.AddElement(TJSONObject.Create);
  jsonPhones.ActiveJSONObject
    .Add('id', 2)
    .Add('number', '888888');

  FJSON
    .Add('address', jsonAddress)
    .Add('phones', jsonPhones);
end;

procedure THelpers4DTestJSON.Setup;
begin
  FJSON := nil;
  FPerson := nil;
end;

procedure THelpers4DTestJSON.TearDown;
begin
  FreeAndNil(FJSON);
  FreeAndNil(FPerson);
end;

procedure THelpers4DTestJSON.TestJSONToObject;
begin
  createJSON;
  FPerson := FJSON.ToObject<TPerson>;

  Assert.IsNotNull(FPerson);
  Assert.AreEqual('1', FPerson.id.ToString);
  Assert.AreEqual('Name 1', FPerson.name);
  Assert.AreEqual('1990-02-13', FPerson.birthdayDate.FormatYYYY_MM_DD);
  Assert.AreEqual('1,72', FPerson.height.ToString);
  Assert.AreEqual('80,52', FPerson.weight.ToString);
  Assert.IsFalse(FPerson.isActive);

  Assert.AreEqual('street 1', FPerson.address.street);
  Assert.AreEqual('complement 1', FPerson.address.complement);
  Assert.AreEqual(1, FPerson.address.number);
  Assert.AreEqual('City 1', FPerson.address.city);
  Assert.IsFalse(FPerson.address.principal);
  Assert.AreEqual(COMMERCIAL, FPerson.address.addressType);

  Assert.AreEqual(2, FPerson.phones.Count);
  Assert.AreEqual('1', FPerson.phones[0].id);
  Assert.AreEqual('999999', FPerson.phones[0].number);
  Assert.AreEqual('2', FPerson.phones[1].id);
  Assert.AreEqual('888888', FPerson.phones[1].number);
end;

procedure THelpers4DTestJSON.TestObjectToJSON;
var
  jsonAddress: TJSONObject;
  jsonPhones: TJSONArray;
begin
  createJSON;
  FPerson := FJSON.ToObject<TPerson>;
  FreeAndNil(FJSON);
  FJSON := TJSONObject.FromObject(FPerson);

  Assert.IsNotNull(FJSON);
  Assert.AreEqual(1, FJSON.ValueAsInteger('id'));
  Assert.AreEqual('Name 1', FJSON.ValueAsString('name'));
  Assert.AreEqual('1990-02-13', FJSON.ValueAsDateTime('birthdayDate').Format('yyyy-MM-dd'));
  Assert.AreEqual('1,72', FJSON.ValueAsFloat('height').ToString);
  Assert.AreEqual('80,52', FJSON.ValueAsFloat('weight').ToString);
  Assert.IsFalse(FJSON.ValueAsBoolean('isActive'));

  jsonAddress := FJSON.ValueAsJSONObject('address');
  jsonPhones  := FJSON.ValueAsJSONArray('phones');

  Assert.IsNotNull(jsonAddress);
  Assert.IsNotNull(jsonPhones);
  Assert.AreEqual(2, jsonPhones.Count);

  Assert.AreEqual('street 1', jsonAddress.ValueAsString('street'));
  Assert.AreEqual('complement 1', jsonAddress.ValueAsString('complement'));
  Assert.AreEqual(1, jsonAddress.ValueAsInteger('number'));

  Assert.AreEqual(1, jsonPhones.ItemAsJSONObject(0).ValueAsInteger('id'));
  Assert.AreEqual(2, jsonPhones.ItemAsJSONObject(1).ValueAsInteger('id'));

  Assert.AreEqual('999999', jsonPhones.ItemAsJSONObject(0).ValueAsString('number'));
  Assert.AreEqual('888888', jsonPhones.ItemAsJSONObject(1).ValueAsString('number'));
end;

procedure THelpers4DTestJSON.TestReadValues;
begin
  createJSON;
  Assert.AreEqual(1, FJSON.ValueAsInteger('id'));
  Assert.AreEqual('Name 1', FJSON.ValueAsString('name'));
  Assert.AreEqual('1990-02-13', FJSON.ValueAsDateTime('birthdayDate').Format('yyyy-MM-dd'));
  Assert.AreEqual('1,72', FJSON.ValueAsFloat('height').ToString);
  Assert.AreEqual('80,52', FJSON.ValueAsFloat('weight').ToString);
  Assert.IsFalse(FJSON.ValueAsBoolean('isActive'));
end;

end.
