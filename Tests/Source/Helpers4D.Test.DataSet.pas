unit Helpers4D.Test.DataSet;

interface

uses
  DUnitX.TestFramework,
  Data.DB,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  Helpers4D.Test.Base,
  Helpers4D.Test.Classes,
  Helpers4D.DataSet,
  System.Generics.Collections,
  System.DateUtils,
  System.SysUtils;

type
  [TestFixture]
  THelpers4DTestDataSet = class(THelpers4DBase)
  private
    FDataSet: TFDMemTable;
    FDataSetAddress: TFDMemTable;
    FDataSetPhones: TFDMemTable;
    FPerson : TPerson;
    FList: TObjectList<TPerson>;

    procedure createDataSet;
    procedure insertDataSet;
  public
    constructor create;
    destructor Destroy; override;

    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestDataSetToObject;

    [Test]
    procedure TestDataSetToList;
  end;

implementation

{ THelpers4DTestDataSet }

constructor THelpers4DTestDataSet.create;
begin
  createDataSet;
end;

procedure THelpers4DTestDataSet.createDataSet;
begin
  FDataSet := TFDMemTable.Create(nil);
  FDataSet
    .AddFloatField('id')
    .AddStringField('name', 100)
    .AddDateTimeField('birthdayDate')
    .AddBooleanField('isActive');

  FDataSet.CreateDataSet;
  FDataSet.Active := True;

  FDataSetAddress := TFDMemTable.Create(nil);
  FDataSetAddress
    .AddFloatField('personId')
    .AddStringField('street', 100)
    .AddStringField('complement', 100)
    .AddIntegerField('number')
    .AddStringField('city', 100)
    .AddBooleanField('principal')
    .AddIntegerField('addressType');

  FDataSetAddress.CreateDataSet;
  FDataSetAddress.Active := True;

  FDataSetPhones := TFDMemTable.Create(nil);
  FDataSetPhones
    .AddFloatField('personId')
    .AddStringField('id', 100)
    .AddStringField('number', 100);

  FDataSetPhones.CreateDataSet;
  FDataSetPhones.Active := True;
end;

destructor THelpers4DTestDataSet.Destroy;
begin
  FDataSet.Free;
  FDataSetAddress.Free;
  FDataSetPhones.Free;
  inherited;
end;

procedure THelpers4DTestDataSet.insertDataSet;
var
  count: Integer;
  personId: Integer;
begin
  count := FDataSet.RecordCount + 1;
  personId := count;
  FDataSet.Append;
  FDataSet
    .SetValue('id', personId)
    .SetValue('name', 'name ' + count.ToString)
    .SetValue('birthdayDate', EncodeDate(1990, 2, 13))
    .SetValue('isActive', count mod 2 = 0)
    .Post;

  count := FDataSetAddress.RecordCount + 1;
  FDataSetAddress.Append;
  FDataSetAddress
    .SetValue('personId', personId)
    .SetValue('street', 'Street ' + count.ToString)
    .SetValue('complement', 'Complement ' + count.ToString)
    .SetValue('number', count)
    .SetValue('city', 'City ' + count.ToString)
    .SetValue('principal', count mod 2 = 0)
    .SetValue('addressType', Integer(COMMERCIAL))
    .Post;

  count := FDataSetPhones.RecordCount + 1;
  FDataSetPhones.Append;
  FDataSetPhones
    .SetValue('personId', personId)
    .SetValue('id', count)
    .SetValue('number', count.ToString.PadRight(10, '9'))
    .Post;

  count := FDataSetPhones.RecordCount + 1;
  FDataSetPhones.Append;
  FDataSetPhones
    .SetValue('id', count)
    .SetValue('number', count.ToString.PadRight(10, '9'))
    .Post;
end;

procedure THelpers4DTestDataSet.Setup;
begin
  FPerson := nil;
  FList := nil;
end;

procedure THelpers4DTestDataSet.TearDown;
begin
  FreeAndNil(FPerson);
  FreeAndNil(FList);
end;

procedure THelpers4DTestDataSet.TestDataSetToList;
var
  i : Integer;
begin
  FDataSet.Clear;
  insertDataSet;
  insertDataSet;

  FList := FDataSet.ToObjectList<TPerson>;
  Assert.IsNotNull(FList);
  Assert.AreEqual(2, FList.Count);

  Assert.AreEqual('1', FList[0].id.ToString);
  Assert.AreEqual('name 1', FList[0].name);
  Assert.AreEqual('1990-02-13', FormatDateTime('yyyy-MM-dd', FList[0].birthdayDate));
  Assert.IsFalse(FList[0].isActive);

  Assert.AreEqual('2', FList[1].id.ToString);
  Assert.AreEqual('name 2', FList[1].name);
  Assert.AreEqual('1990-02-13', FormatDateTime('yyyy-MM-dd', FList[1].birthdayDate));
  Assert.IsTrue(FList[1].isActive);

  for i := 0 to Pred(FList.Count) do
  begin
    FDataSetAddress.ToObject(FList[i].address, 'personId = ' + FList[i].id.ToString);
    Assert.AreEqual('Street ' + (i + 1).ToString, FList[i].address.street);

    FDataSetPhones.ToObjectList<TPhone>(FList[i].phones, 'personId = ' + FList[i].id.ToString);
  end;

  for i := 0 to Pred(FList.Count) do
  begin
    Assert.AreEqual(2, FList[0].phones.Count);
  end;

end;

procedure THelpers4DTestDataSet.TestDataSetToObject;
begin
  insertDataSet;
  insertDataSet;
  FDataSet.First;
  FPerson := TPerson.create;

  FDataSet.ToObject(FPerson);
  FDataSetAddress.ToObject(FPerson.address, 'personId = ' + FPerson.id.ToString);

  Assert.AreEqual('1', FPerson.id.ToString);
  Assert.AreEqual('name 1', FPerson.name);
  Assert.AreEqual('1990-02-13', FormatDateTime('yyyy-MM-dd', FPerson.birthdayDate));
  Assert.IsFalse(FPerson.isActive);

  Assert.AreEqual('Street 1', FPerson.address.street);
  Assert.AreEqual('Complement 1', FPerson.address.complement);
  Assert.AreEqual(1, FPerson.address.number);
  Assert.AreEqual('City 1', FPerson.address.city);
  Assert.IsFalse(FPerson.address.principal);
  Assert.AreEqual(1, Integer(FPerson.address.addressType));
end;

end.
