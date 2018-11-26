unit frm_About;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,  FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLIntf;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    btnClose: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private

  public

  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.btnCloseClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmAbout.Label3Click(Sender: TObject);
begin

end;

end.

