program SuperCSV;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, frm_main, data_module, frm_About, frm_Filter, frm_CSVDSet,
  frm_Ddatabasesetting, datareplace_wizard,
  frm_progress, frm_messycodefix, frm_defineheader;


{$R *.res}

begin
  Application.Scaled:=True;
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmFilter, frmFilter);
  Application.CreateForm(TfrmCsvSet, frmCsvSet);
  Application.CreateForm(TfrmDataBaseSet, frmDataBaseSet);
  Application.CreateForm(TfrmProgress, frmProgress);
  Application.CreateForm(TfrmMessyCodeFix, frmMessyCodeFix);
  Application.CreateForm(TfrmDefineHeader, frmDefineHeader);
  Application.Run;
end.

