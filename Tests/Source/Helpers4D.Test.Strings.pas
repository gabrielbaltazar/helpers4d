unit Helpers4D.Test.Strings;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Helpers4D.Strings;

type
  [TestFixture]
  THelpers4DTestStrings = class
  private
    FText: string;
  public
    [Setup]
    procedure Setup;

    [Test]
    [TestCase('Cpf', '131557.677/58', '131.557.677-58')]
    [TestCase('Cnpj', '12.362-568/000131', '12.362.568/0001-31')]
    procedure FormatCpfCnpj(AText, AExpected: string);
  end;

implementation

{ THelpers4DTestStrings }

procedure THelpers4DTestStrings.FormatCpfCnpj(AText, AExpected: string);
begin
  FText := AText;
  Assert.AreEqual(AExpected, FText.FormatCpfCnpj);
end;

procedure THelpers4DTestStrings.Setup;
begin
  FText := EmptyStr;
end;

end.
