program Test;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestCase1, CSVReader, TestcsvReader,
  expressutils, testexpressparser, csvexpress, testcsvexpress, csvengine,
  testcsv_engine, testzeosdb;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;

end.
