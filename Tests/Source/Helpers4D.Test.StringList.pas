unit Helpers4D.Test.StringList;

interface

uses
  DUnitX.TestFramework,
  Helpers4D.StringList,
  System.SysUtils,
  System.Classes;

const
  TEST_FILE = 'Helpers4D.txt';

type
  [TestFixture]
  THelpers4DTestStringList = class
  private
    FList: TStrings;

    procedure TestFileCreate;
    procedure TestFileDelete;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    constructor create;
    destructor Destroy; override;

    [Test]
    procedure CreateFromFileNotExist;

    [Test]
    procedure CreateFromFile;

    [Test]
    procedure SaveLogFile;

    [Test]
    procedure SaveLogFileOverriding;

    [Test]
    procedure TestAdd;
  end;

implementation

{ THelpers4DTestStringList }

constructor THelpers4DTestStringList.create;
begin
end;

procedure THelpers4DTestStringList.CreateFromFile;
begin
  FList := TStrings.CreateFromFile(TEST_FILE);
  Assert.IsNotNull(FList);
  Assert.AreEqual(1, FList.Count);
end;

procedure THelpers4DTestStringList.CreateFromFileNotExist;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FList := TStrings.CreateFromFile('aa.txt');
    end);

  Assert.IsNotNull(FList);
  Assert.IsTrue(FList.Count = 0);
end;

destructor THelpers4DTestStringList.Destroy;
begin
  inherited;
end;

procedure THelpers4DTestStringList.SaveLogFile;
begin
  TStrings.SaveLogFile(TEST_FILE, 'Test');
  FList := TStrings.CreateFromFile(TEST_FILE);
  Assert.AreEqual(2, FList.Count);
end;

procedure THelpers4DTestStringList.SaveLogFileOverriding;
begin
  TStrings.SaveLogFile(TEST_FILE, 'Test', True);
  FList := TStrings.CreateFromFile(TEST_FILE);
  Assert.AreEqual(1, FList.Count);
end;

procedure THelpers4DTestStringList.Setup;
begin
  FList := nil;
  TestFileCreate;
end;

procedure THelpers4DTestStringList.TearDown;
begin
  FreeAndNil(FList);
  TestFileDelete;
end;

procedure THelpers4DTestStringList.TestAdd;
begin
  FList := TStrings.CreateFromFile(TEST_FILE);
  FList
    .Add('Names=%s', ['Test']);
  FList.SaveToFile(TEST_FILE);
  FList.Free;

  FList := TStrings.CreateFromFile(TEST_FILE);

  Assert.AreEqual(2, FList.Count);
  Assert.AreEqual('Test', FList.Values['Names']);
end;

procedure THelpers4DTestStringList.TestFileCreate;
begin
  TStrings.SaveLogFile(TEST_FILE, 'Test=OK');
end;

procedure THelpers4DTestStringList.TestFileDelete;
begin
  DeleteFile(TEST_FILE);
end;

end.
