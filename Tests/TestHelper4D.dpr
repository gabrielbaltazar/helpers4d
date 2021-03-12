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
  DUnitX.Loggers.Xml.NUnit,
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
  Helpers4D.Test.CopyObjects in 'Source\Helpers4D.Test.CopyObjects.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    IsConsole := False;
    ReportMemoryLeaksOnShutdown := True;
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
