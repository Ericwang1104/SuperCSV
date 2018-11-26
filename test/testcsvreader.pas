unit TestcsvReader;
{$IFDEF  FPC}
{$mode objfpc}{$H+}
{$ENDIF}

interface

uses
{$IFDEF  FPC}
	Classes, windows, SysUtils, CSVReader, LazLogger, fpcunit, testregistry,
	dbugintf;
{$ELSE}
	TestFramework, Classes, CSVReader, GuiTestRunner, SysUtils;
{$ENDIF}

type

  { TStringTypeTest }

  TStringTypeTest=Class(TTestCase)
  public
    procedure SetUp;override;
    procedure TearDown;override;
  published
    procedure TestStringType();
  end;

	{ TCSVReaderTest }
	TCSVReaderTest = class(TTestCase)
	strict private
	private
		FCSV: TCsvReader;
		function GetCSVFileName: string;
		function GetCSVFileName2: string;
	public
		procedure SetUp; override;
		procedure TearDown; override;
	published
		procedure TestReadCSVRowCount;
    procedure TestCheckCSVData;
		procedure GetCSVSize;

		procedure TestCheckMovePage;

		procedure TestForeCastBufferLineCount;
		procedure TestMoveBuffer();
		procedure TestSeek();
		procedure TestBuildBufferLineIndex();
		procedure TestCheckRowCount();
		procedure TestCSvReadMessyCode;
    procedure TestFilterCSV();
    procedure TestReadAndReaderBuffer();
    procedure TestReadaaa();

	end;

  { TCSVWriterTest }

  TCSVWriterTest=class(TTestCase)
  private
    FR:TCsvReader;
    FW:TCsvWriter;
  protected
		procedure SetUp; override;
		procedure TearDown; override;

  published
    procedure TestAppendData();
  end;

implementation

{ TStringTypeTest }

procedure TStringTypeTest.SetUp;
begin
  inherited;
end;

procedure TStringTypeTest.TearDown;
begin
  inherited;
end;

procedure TStringTypeTest.TestStringType;
var
  str:ansistring;
  astr:ansistring;
  ustr:UTF8String;
  rStr:RawByteString;
  wstr:Widestring;
begin
  str :='国';
  astr :=str;
  ustr:=str;
  rstr :=str;
	wstr :=str;
	{$IFDEF  FPC}
	dbugintf.SendSeparator;
  SendInteger('String Length',Length(str));
  SendInteger('ansi Length',Length(Astr));
  SendInteger( 'utf8 Length',Length(ustr));
  SendInteger('RawString Length',Length(rStr));
  SendInteger('Wide String Length',Length(wstr));
  rstr :=wstr;
	SendInteger(' wide string to raw byte string length',length(rstr));
	{$ENDIF}
  checkequals(length(str),7);
end;

{ TCSVWriterTest }

procedure TCSVWriterTest.SetUp;
begin
  inherited ;
  FR :=TCsvReader.Create();
  FW :=TCsvWriter.Create();
end;

procedure TCSVWriterTest.TearDown;
begin
  FreeAndnil(FW);
  FreeAndnil(FR);
  inherited ;
end;

procedure TCSVWriterTest.TestAppendData;
var
  cnt:integer;
begin
  cnt :=0;
  FR.OpenFile('e:\wifidata\testdata.csv');
  FW.WriteCSVFile('e:\temp\temp.csv');
  while fr.ReadLine do
  begin
    FW.AppendData(fr.PCurrentRow);
    inc(cnt);
    if cnt>100 then exit;
  end;
end;

procedure TCSVReaderTest.TestCheckMovePage;
var
	FileName, FileName2: string;
	RowCount1, RowCount2: int64;
	intPos: int64;
	CSV2: TCsvReader;
	Col1, Col2: TColumnItem;
begin
	FileName := GetCSVFileName();
	FileName2 := GetCSVFileName2();
	CSV2 := TCsvReader.Create();
	try
		FCSV.OpenFile(FileName);
		RowCount1 := 0;
		while FCSV.ReadLine() do
		begin
			//
			inc(RowCount1);
		end;
		intPos := FCSV.position;
		FCSV.MoveToFirst;
		RowCount2 := 0;
		while FCSV.ReadLine() do
		begin
			inc(RowCount2);

		end;
		CheckEquals(RowCount1, RowCount2);

		CSV2.OpenFile(FileName2, true);
		FCSV.MoveToFirst;
		while CSV2.ReadLine() do
		begin
			FCSV.ReadLine;
			Col1 := FCSV.Columns.ColumnItem[0];
			Col2 := CSV2.Columns.ColumnItem[0];
			CheckEquals(Col1.PCsvColData^.AsRawString, Col2.PCsvColData^.AsRawString);
		end;

	finally
		FreeAndNil(CSV2);
	end;

	CheckEquals(RowCount1, RowCount2);
end;

procedure TCSVReaderTest.TestReadCSVRowCount;
var
	FileName: string;
	FieldValue: string;
	I: integer;
	lst: TStringList;
  Cnt1,cnt2:Integer;
begin
  lst :=TStringList.Create;
  try
    //FileName := GetCSVFileName;
    FileName :='E:\CSVSampleData\Consumer_Complaints.csv';
    lst.LoadFromFile(FileName);
	  FCSV.OpenFile(FileName, true);
    Cnt1 :=0;
    Cnt2 :=0;
	  while FCSV.ReadLine do
	  begin

        inc(Cnt1);

	  end;
    Cnt2 :=lst.Count-1;
    Checkequals(Cnt1,cnt2,'row count is not equals');

  finally
    FreeAndNil(lst);
  end;
end;

procedure TCSVReaderTest.TestCheckCSVData;
var
  FileName:string;
  lst,lst2:TStringList;
  Row:integer;
  str1,str2,strRow1,strRow2:string;
  I:integer;
  PRow:PAnsichar;
begin
	FileName :=GetCSVFileName;
  lst :=TStringList.Create;
  lst2 :=TStringList.Create;
  try
    lst.LoadFromFile(FileName);
    lst2.DelimitedText:=',';
    lst2.StrictDelimiter:= true;
    FCSv.OpenFile(FileName);
    Row :=1;
    while FCSV.ReadLine do
    begin
      if Row= 166722 then
      begin
        Row :=Row;
      end;
			strRow2:=lst.Strings[Row];
      lst2.DelimitedText :=StrRow2;
      PRow :=FCSV.PCurrentRow^.PRowS;
      PRow :=nil;
      for I := 0 to fCSV.Columns.Count-1 do
      begin
				str1 :=FCSV.Columns[I].PCsvColData^.AsRawString;
        str2 :=lst2.Strings[I];
        checkequals(str1,str2);
      end;
      inc(Row);
    end;
  finally
    FreeAndNil(lst2);
    FreeAndNil(lst);
  end;
end;

function TCSVReaderTest.GetCSVFileName: string;
var
	FileName: string;
begin
{$IFDEF DARWIN}
	result := '/Users/wangchong/Downloads/TestData.csv';
{$ELSE}
	result := 'E:\CSVSampleData\14zpallagi.csv';
{$ENDIF}
end;

function TCSVReaderTest.GetCSVFileName2: string;
begin
{$IFDEF DARWIN}
	result := '/Users/wangchong/Downloads/TestData2.csv';
{$ELSE}
	result := 'E:\CsvSampleData\14zpallagi2.csv';
{$ENDIF}
end;

procedure TCSVReaderTest.SetUp;
begin

	FCSV := TCsvReader.Create();
end;

procedure TCSVReaderTest.TearDown;
begin

	FreeAndNil(FCSV);
end;



procedure TCSVReaderTest.GetCSVSize;
var
	FileName: string;
  rec:TSearchRec;
begin
	FileName := GetCSVFileName;
  FindFirst(FileName,faAnyFile,rec);

	FCSV.OpenFile(FileName, true);
	CheckEquals(FCSV.Size,rec.Size );
end;



procedure TCSVReaderTest.TestForeCastBufferLineCount;
var
	FileName: string;
	Count: int64;
begin
	FileName := GetCSVFileName;
	FCSV.OpenFile(FileName);
	Count := FCSV.ForeCastBufferRowCount;
end;

procedure TCSVReaderTest.TestMoveBuffer();
var
	FileName: string;
	BufCount: int64;
	Index: int64;
	Col: TColumnItem;
	str: string;
begin
	// FileName :=GetCSVFileName();
	FileName := 'E:\WifiData\rlog_rand\rlog_rand.dat';
	FCSV.SplitChar := #9;
	FCSV.OpenFile(FileName);
	BufCount := FCSV.BufferCount;
	Index := BufCount - 1;
	FCSV.MoveToBuffer(Index);
	str := '';
	while FCSV.ReadLine do
	begin
		Col := FCSV.Columns[2];
		str := Col.PCsvColData^.AsRawString;
	end;
end;

procedure TCSVReaderTest.TestSeek();
var
	FileName: string;
begin
	//
	// FileName :=GetCSVFileName();
	FileName := 'E:\WIFIDATA\CityMap.csv';
	FCSV.OpenFile(FileName);
	CheckEquals(FCSV.BufferCount, 1000);

end;

procedure TCSVReaderTest.TestBuildBufferLineIndex();
var
	FileName: string;
	BufCount: int64;
	DataIndex: TDataIndex;
begin
	// 读取 缓冲区
	// 读取缓冲区行，发现断行 扩充缓冲区，读取增加部分
	//
  DataIndex :=nil;
	FileName := GetCSVFileName;
	FCSV.OpenFile(FileName);
	BufCount := FCSV.BufferCount;
	FCSV.MoveToBuffer(3);
	DataIndex := FCSV.BuildDataIndex();
end;

procedure TCSVReaderTest.TestCheckRowCount();
var
	FileName: string;
	str: string;
  RowCount1,RowCount2:integer;
  I,J:Integer;
begin
	FileName := GetCSVFileName;
  FileName :='e:\wifidata\testdata.csv';
	FCSV.OpenFile(FileName,true,1*1024*1024);
  RowCount1 :=0;
  while FCsv.ReadLine do
  begin
    inc(RowCount1);
  end;
  RowCount2 :=0;
  fcsv.OpenFile(FileName);
  for I := 0 to FCsv.BufferCount-1 do
  begin
  	FCSV.MoveToBuffer(I);
  	FCSV.BuildDataIndex();
    RowCount2 :=RowCount2+FCSV.BufferRowCount;
  end;
  checkequals(RowCount1,RowCount2);


end;

procedure TCSVReaderTest.TestCSvReadMessyCode;
var
	FileName:string;
	Col :TColumnItem;
	colData:UTF8String;
begin
	FileName :='F:\CNNIC\党建项目\results-survey75321 (1).csv';
	FCSV.OpenFile(FileName);
	FCSV.EnCode :=cUtf8;
	Col :=FCSV.Columns[4];
	Col.SouceCodePage :=cp_Western_Windows_Latin1;
	col.DesCodePage :=cp_UTF8;
	Col.EnableCodeConvert :=true;
	while Fcsv.ReadLine do
	begin

		//ColData :=col.ConvertCode(TEncoding.GetEncoding(1252),
		//TEncoding.GetEncoding(CP_UTF8));

	end;
end;

procedure TCSVReaderTest.TestFilterCSV();
begin
  { TODO : CSV筛选功能单元测试 }
  FCsv.ForeCastBufferRowCount;
	assert(false,'还未完成此功能');
end;

procedure TCSVReaderTest.TestReadAndReaderBuffer();
var
  R1,R2:TCsvReader;
  I,J:integer;
  str,str2:string;
  RowCount1,RowCount2:integer;
  bln,BlnReadLine:boolean;
  P1,P2:Pansichar;
begin
  R1 :=TCsvReader.Create;
  R2 :=TCsvReader.Create;
  try
    R1.OpenFile('E:\CSVSampleData\14zpallagi.csv');
    R2.OpenFile('E:\CSVSampleData\14zpallagi2.csv');
    RowCount1 :=0;
    RowCount2 :=0;

    while r1.ReadLine do
    begin

    end;

    r1.MoveToFirst;
    r2.MoveToFirst;
    for I := 0 to r1.BufferCount-1 do
    begin
      Blnreadline :=false;
      R1.MoveToBuffer(I);
			r1.BuildDataIndex();
			{$IFDEF  FPC}
			{$IFOPT D+}
				SendInteger('BufferIndex',I);
				SendInteger('R1 ReadBuffer BufferSize',r1.BufferSize);
        SendInteger('R2 ReadBuffer BufferSize',R2.BufferSize);
        SendInteger('R1 BufferEnd Capacity',R1.BufferCapacity);
        SendInteger('R2 Buffer Capacity',R2.BufferCapacity);
        dbugintf.SendSeparator;
			{$ENDIF}
			{$ENDIF}

      for J := 0 to r1.BufferRowCount-1 do
      begin
        if r2.ReadLine then
        begin
					{$IFOPT D+}
          if not BlnReadLine then
          begin
            BlnReadLine :=true;
            P1 :=R1.PBuffer;
            P2 :=R2.PBuffer;
            bln :=CompareMem(P1,P2,r1.BufferSize);
          end;
          {$ENDIF}
          str :=r1.CellData[J,0]^.AsRawString;
          str2 :=r2.Columns[0].PCsvColData^.AsRawString;
          checkequals( str,str2);
        end else
        begin
          checkequals(false,true,'row count error');
        end;
      end;
    end;
  finally
    FreeAndNil(R2);
    FreeAndNil(R1);
  end;
end;

procedure TCSVReaderTest.TestReadaaa();
var
  Data:utf8string;
  I,J:integer;
begin
  FCsv.OpenFile('E:\CSVSampleData\aaa.csv',false);
  FCsv.MoveToBuffer(0);
  FCsv.BuildDataIndex();
  for I := 0 to FCsv.ColCount-1 do
  begin
    Data :=FCSV.CellData[16,I]^.AsUtf8;
    SendDebug(Data);
  end;


  try
  for I := 0 to FCSv.BufferRowCount-1 do
  begin
    for J := 0 to FCSV.ColCount-1 do
    begin
      SendInteger('Row',I);
      SendInteger('Col',J );
      SendSeparator;
      Data :=FCSV.CellData[I,J]^.AsUtf8;
    end;
  end;

  except
    on e:exception do
    begin
      SendInteger('Row',I);
      SendInteger('Col',J );
      SendSeparator;
    end;
  end;

end;

initialization

{$IFDEF  FPC}
  RegisterTest(TStringTypeTest);
	RegisterTest(TCSVReaderTest);
  RegisterTest(TCsvWriterTest);
{$ELSE}

	RegisterTest(TCSVReaderTest.Suite);
  RegisterTest(TCsvWriterTest.Suite);
{$ENDIF}

end.
