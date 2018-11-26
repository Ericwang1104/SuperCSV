program FastCSV;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, frm_main, data_module, frm_About, frm_Filter, frm_CSVDSet,
  frm_Ddatabasesetting, zcomponent, datareplace_wizard,
  kgridlaz;


{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmFilter, frmFilter);
  Application.CreateForm(TfrmCsvSet, frmCsvSet);
  Application.CreateForm(TfrmDataBaseSet, frmDataBaseSet);
  Application.Run;
end.

