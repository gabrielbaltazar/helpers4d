program TestHelper4D;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  Helpers4D.Test.Base in 'Source\Helpers4D.Test.Base.pas',
  Helpers4D.DataSet in '..\Source\Helpers4D.DataSet.pas',
  Helpers4D.JSON in '..\Source\Helpers4D.JSON.pas',
  Helpers4D.Objects in '..\Source\Helpers4D.Objects.pas',
  Helpers4D.RTTI in '..\Source\Helpers4D.RTTI.pas',
  Helpers4D.DateTime in '..\Source\Helpers4D.DateTime.pas',
  Helpers4D.Test.Classes in 'Source\Helpers4D.Test.Classes.pas',
  Helpers4D.Test.DataSet in 'Source\Helpers4D.Test.DataSet.pas',
  Helpers4D.Test.JSON in 'Source\Helpers4D.Test.JSON.pas',
  Helpers4D.Horse in '..\Source\Helpers4D.Horse.pas',
  Helpers4D.Horse.Exception in '..\Source\Helpers4D.Horse.Exception.pas',
  Helpers4D.StringList in '..\Source\Helpers4D.StringList.pas',
  Helpers4D.Test.StringList in 'Source\Helpers4D.Test.StringList.pas',
  Helpers4D.Horse.Controller in '..\Source\Helpers4D.Horse.Controller.pas',
  Helpers4D.Model.Test.Classes in 'Source\Helpers4D.Model.Test.Classes.pas',
  Helpers4D.DTO.Test.Classes in 'Source\Helpers4D.DTO.Test.Classes.pas',
  Helpers4D.Test.CopyObjects in 'Source\Helpers4D.Test.CopyObjects.pas',
  Helpers4D.Numbers in '..\Source\Helpers4D.Numbers.pas',
  Helpers4D.Test.Numbers in 'Source\Helpers4D.Test.Numbers.pas',
  Helpers4D.Strings in '..\Source\Helpers4D.Strings.pas',
  Helpers4D.Test.Strings in 'Source\Helpers4D.Test.Strings.pas';

begin
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  TestInsight.DUnitX.RunRegisteredTests;
end.
