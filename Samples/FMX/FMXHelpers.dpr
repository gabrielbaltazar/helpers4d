program FMXHelpers;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMXHelpers.Forms in 'FMXHelpers.Forms.pas' {Form1},
  Helpers4D.FMX.ListView in '..\..\Source\Helpers4D.FMX.ListView.pas',
  Helpers4D.FMX.ComboBox in '..\..\Source\Helpers4D.FMX.ComboBox.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
