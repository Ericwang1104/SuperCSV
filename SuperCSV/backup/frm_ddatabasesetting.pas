unit frm_Ddatabasesetting;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ZConnection, ZSqlMetadata;

type

  { TfrmDataBaseSet }

  TfrmDataBaseSet = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
  private

  public

  end;

var
  frmDataBaseSet: TfrmDataBaseSet;

implementation

{$R *.lfm}

end.

