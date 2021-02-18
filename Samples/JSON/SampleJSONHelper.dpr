program SampleJSONHelper;

uses
  Vcl.Forms,
  FSampleJSONHelper in 'FSampleJSONHelper.pas' {Form1},
  Helpers4D.RTTI in '..\..\Source\Helpers4D.RTTI.pas',
  Helpers4D.JSON in '..\..\Source\Helpers4D.JSON.pas',
  Herlpers4D.DateTime in '..\..\Source\Herlpers4D.DateTime.pas',
  Helpers4D.Objects in '..\..\Source\Helpers4D.Objects.pas',
  Helpers4D.DataSet in '..\..\Source\Helpers4D.DataSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
