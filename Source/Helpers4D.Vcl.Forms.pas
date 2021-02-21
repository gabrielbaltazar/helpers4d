unit Helpers4D.Vcl.Forms;

interface

uses
  Vcl.Forms,
  Vcl.Controls,
  System.SysUtils,
  System.Classes,
  Winapi.Messages,
  Winapi.Windows;

procedure FormDragMove(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

implementation

procedure FormDragMove(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
   sc_DragMove = $f012;
begin
  ReleaseCapture;
  Perform(wm_SysCommand, sc_DragMove, 0);
end;

end.
