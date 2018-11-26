unit frm_CSVDSet;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, KGrids, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TfrmCsvSet }

  TfrmCsvSet = class(TForm)
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    KGrid1: TKGrid;
    Label1: TLabel;
  private

  public

  end;

var
  frmCsvSet: TfrmCsvSet;

implementation

{$R *.lfm}

end.

