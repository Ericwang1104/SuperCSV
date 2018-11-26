program DTest;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options 
  to use the console test runner.  Otherwise the GUI test runner will be used by 
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  CSVReader in '..\common\CSVReader.pas',
  objecthash in '..\common\objecthash.pas',
  testcase1 in '..\test\testcase1.pas',
  testcsvreader in '..\test\testcsvreader.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

