unit Helpers4D.Test.Numbers;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Helpers4D.Numbers;

type
  [TestFixture]
  THelpers4DTestNumbers = class
  private
    FNumber: Currency;
  public
    [Setup]
    procedure Setup;

    [Test]
    [TestCase('Basic', '10;R$ 10,00', ';')]
    [TestCase('Centena', '100;R$ 100,00', ';')]
    [TestCase('Milhar', '1000;R$ 1.000,00', ';')]
    [TestCase('Decimal', '10.53;R$ 10,53', ';')]
    [TestCase('DecimalMilhar', '-1000.53;R$ -1.000,53', ';')]
    [TestCase('BasicNegative', '-10;R$ -10,00', ';')]
    [TestCase('CentenaNegative', '-100;R$ -100,00', ';')]
    [TestCase('MilharNegative', '-1000;R$ -1.000,00', ';')]
    [TestCase('DecimalNegative', '-10.53;R$ -10,53', ';')]
    [TestCase('DecimalMilharNegative', '-1000.53;R$ -1.000,53', ';')]
    procedure CurrencyTest(AValue: Currency; AExpected: string);
  end;

implementation

{ THelpers4DTestNumbers }

procedure THelpers4DTestNumbers.CurrencyTest(AValue: Currency; AExpected: string);
begin
  FNumber := AValue;
  Assert.AreEqual(AExpected, FNumber.Format);
end;

procedure THelpers4DTestNumbers.Setup;
begin
  FNumber := 0;
end;

end.
