unit frm_progress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls;

type

  { TfrmProgress }

  TfrmProgress = class(TForm)
    btnClose: TButton;
    labName: TLabel;
    pBar: TProgressBar;
    procedure btnCloseClick(Sender: TObject);
  private

  public
    procedure InitProgress(Title,LabelName:string;Max,Min,Current:integer);
    Procedure ProcProgress(Max,Current:integer);
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.lfm}

{ TfrmProgress }

procedure TfrmProgress.btnCloseClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmProgress.InitProgress(Title, LabelName: string; Max, Min,
  Current: integer);
begin
  self.Caption:=Title ;
  labName.Caption:= LabelName;
  pBar.Max :=Max;
  Pbar.Min :=Min;
  Pbar.Position :=Current;
  btnClose.Enabled :=false;
end;

procedure TfrmProgress.ProcProgress(Max, Current: integer);
begin
  if Current>=Max then
  begin
    btnClose.Enabled :=true;
    Pbar.Max :=Max;
    pbar.Position :=Current;
  end else
  begin
    Pbar.Position :=Current;
    Pbar.Max :=Max;
  end;
end;

end.

