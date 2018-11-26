unit testcsvexpress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, csvexpress, expressutils, csvreader, fpcunit, testutils,
  testregistry, dbugintf;

type

  { TTestCSVVarBuilfer }

  TTestCSVVarBuilfer= class(TTestCase)
  private
    FCsvBuilder:TCsvVarBuilder;
    FR :TCsvReader;
    FOpt:TExpressNode;
    FW:TCsvWriter;
    FParser :TExpressParser;
    procedure FilterEvent(var Filtered:boolean );
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure LoadCSVData();
    procedure WriteFiterData();
  published
    procedure TestCsvBuilder;
    procedure TestFilterExportTest();
    procedure TestFilterExport2();
    procedure TestFilterSplitPage();
    procedure TestMultiArray();
    procedure TestCsvExprotBufferAndReadLine();

  end;

implementation

procedure TTestCSVVarBuilfer.TestCsvBuilder;
var
  opt:TExpressNode;
  cnt:integer;
  BufferCount:integer;
  I,J:integer;
begin
  opt :=FParser.Parser('(not domain_name like "%.com") and (not domain_name like "%.org")');
  cnt :=0;
  BufferCount :=FR.BufferCount;
  while fr.ReadLine do
  begin
    opt.Process();
    if opt.AsBoolean then
    begin
      inc(cnt);
      if (cnt mod 10000)=0 then
      begin
        dbugintf.SendInteger('FilterCount:',cnt);
      end;
    end;
  end;







end;

procedure TTestCSVVarBuilfer.TestFilterExportTest;
var
  opt:TExpressNode;
  cnt:integer;
  BufferCount:integer;
  I,J:integer;
begin
    opt :=FParser.Parser('domain_name like "%.org"');
    cnt :=0;
    BufferCount :=FR.BufferCount;
    while FR.ReadLine do
    begin
      opt.Process();
      if opt.AsBoolean then
      begin
        FW.AppendData(FR.PCurrentRow);
        inc(cnt);
        if (cnt mod 10000)=0 then
        begin
          dbugintf.SendInteger('FilterCount:',cnt);
        end;
      end;
  end;

end;

procedure TTestCSVVarBuilfer.TestFilterExport2;
var
  opt:TExpressNode;
  cnt:integer;
  BufferCount:integer;
  I,J:integer;
begin
    opt :=FParser.Parser('domain_name like "%.org"');
    cnt :=0;
    BufferCount :=FR.BufferCount;
    for I:=0 to BufferCount-1 do
    begin
      fr.MoveToBuffer(I);
      fr.BuildDataIndex();
      for J := 0 to Fr.BufferRowCount-1 do
      begin
        fr.ParserRowIndex(J);
        opt.Process();
        if opt.AsBoolean then
        begin
          FW.AppendData(FR.PCSVDataItems[J]);
          inc(cnt);
          {$IFOPT D+}
          if (cnt mod 10000)=0 then
          begin
            SendInteger('FilterCount:',cnt);
          end;
          {$ENDIF}
        end;

      end;


    end;

end;

procedure TTestCSVVarBuilfer.TestFilterSplitPage;
var
  opt:TExpressNode;
begin
  LoadCSVData;
  opt :=FParser.Parser('domain_name like "%.net" or domain_name like "%.com"');
  Fr.MoveToBuffer(0);
  fr.BuildDataIndex();
end;

procedure TTestCSVVarBuilfer.TestMultiArray;
type
  Tarr=array of array of integer;
var
  arr:TArr;
begin
  SetLength(Arr,1,2);
  Arr[0,0] :=1;
  arr[0,1] :=2;
  SetLength(Arr,2,2);
  arr[1,0] :=3;
  Arr[1,1] :=4;
  CheckEquals(Arr[0,0],1);
  checkequals(Arr[0,1],2);
  CheckEquals(Arr[1,0],3);
  CheckEQuals(Arr[1,1],4);
end;

procedure TTestCSVVarBuilfer.TestCsvExprotBufferAndReadLine;
var
  R1,R2:TCsvReader;
  Bu1,Bu2:TCsvVarBuilder;
  Par1,Par2:TExpressParser;
  opt1,opt2:TExpressNode;
  I,J:integer;
  str,str2:string;
  RowCount1,RowCount2:integer;
begin
  R1 :=TCsvReader.Create;
  R2 :=TCsvReader.Create;
  Bu1 :=TCsvVarBuilder.Create(nil);
  Bu2 :=TCsvVarBuilder.Create(nil);
  Par1 :=TExpressParser.Create(nil);
  Par2 :=TExpressParser.Create(nil);
  try
    R1.OpenFile('E:\WIFIDATA\TEstData.csv');
    R2.OpenFile('E:\WIFIDATA\TestData2.csv');
    Par1.OperatorBuilder :=Bu1;
    Par2.OperatorBuilder :=Bu2;
    bu1.CSV :=R1;
    Bu2.CSV :=R2;
    Opt1 :=Par1.Parser('domain_name like "%.org"');
    Opt2 :=Par2.Parser('domain_name like "%.org"');
    RowCount1 :=0;
    RowCount2 :=0;
    r1.MoveToFirst;
    r2.MoveToFirst;
    for i := 0 to r1.BufferCount-1 do
    begin
      r1.MoveToBuffer(I);
      r1.BuildDataIndex();
      for j := 0 to r1.BufferRowCount-1 do
      begin
        str :=r1.CellData[J,0]^.AsRawString;
        Inc(RowCount1);
      end;

    end;
    while r2.ReadLine do
    begin
      str :=r2.Columns[0].PCsvColData^.AsRawString;
      inc(RowCount2);
    end;
    checkequals(rowcount1,rowcount2,'rowcount error');







    r1.MoveToFirst;
    r2.MoveToFirst;
    //r1.MoveToBuffer(0);
    //r2.MoveToBuffer(0);
    for I := 0 to r1.BufferCount-1 do
    begin
      R1.MoveToBuffer(I);
      r1.BuildDataIndex();
      for J := 0 to r1.BufferRowCount-1 do
      begin
        if r2.ReadLine then
        begin
          opt1.Process();
          opt2.Process();
          if opt1.AsBoolean=opt2.AsBoolean then
          begin
            str :=r1.CellData[J,0]^.AsRawString;
            str2 :=r2.Columns[0].PCsvColData^.AsRawString;
            checkequals( str,str2);

          end else
          begin
            checkequals (false,true,'数值不同!');
          end;
        end else
        begin
          checkequals(false,true,'row count error');
        end;
      end;

    end;


  finally
    FreeAndNil(Par2);
    FreeAndNil(Par1);
    FreeAndNil(Bu2);
    FreeAndnil(Bu1);
    FreeAndNil(R2);
    FreeAndNil(R1);
  end;
end;

procedure TTestCSVVarBuilfer.FilterEvent(var Filtered: boolean);
begin
  Filtered :=FOpt.AsBoolean;

end;

procedure TTestCSVVarBuilfer.SetUp;
begin
  FCsvBuilder :=TCsvVarBuilder.Create(nil);
  FR :=TCsvReader.Create;
  FW :=TCSVWriter.Create;
  FParser :=TExpressParser.Create(nil);
  FCsvBuilder.CSV :=FR;
  FParser.OperatorBuilder :=FCsvBuilder;
  //LoadCSVData();
  //WriteFiterData();
end;

procedure TTestCSVVarBuilfer.TearDown;
begin
  FreeAndNil(FParser);
  FreeAndNil(FW);
  FreeAndNil(FR);
  FreeAndNil(FCsvBuilder);
end;

procedure TTestCSVVarBuilfer.LoadCSVData;
begin
  FR.OpenFile('E:\WIFIDATA\TestData.csv');
end;

procedure TTestCSVVarBuilfer.WriteFiterData;
begin
  FW.WriteCSVFile('e:\temp\temp.csv');
end;

initialization

  RegisterTest(TTestCSVVarBuilfer);
end.

