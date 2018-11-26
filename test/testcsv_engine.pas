unit testcsv_engine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, csvengine, fpcunit, testutils, testregistry;

type

  { TCsvEngineTest }

  TCsvEngineTest= class(TTestCase)
  protected
    FE:TCSVEngine;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCsvEngine;
  end;

implementation

procedure TCsvEngineTest.TestCsvEngine;
begin
  //
  FE.OpenCSVFile('E:\WifiData\TestData.Csv');
  FE.Filter:= 'domain_name like "%.org"';
  FE.FilterActive:= true;
  FE.ExportCSVFile('e:\temp\temp.csv');

end;

procedure TCsvEngineTest.SetUp;
begin
  FE :=TCSVEngine.Create(nil);
end;

procedure TCsvEngineTest.TearDown;
begin
  FreeAndnil(FE);
end;

initialization

  RegisterTest(TCsvEngineTest);
end.

