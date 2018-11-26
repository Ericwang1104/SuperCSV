unit testzeosdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, ZConnection, ZSqlMetadata, testutils,
  testregistry, dbugintf;

type

  { TZeosTests }

  TZeosTests= class(TTestCase)
  private
    FzCn:TZConnection;
    FzMeta:TZSQLMetaData;
    procedure InitFireBirdDB;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published

    procedure Testqlite3Meta;
    procedure TestFireBirdMeta;
    procedure TestListAllColumn;
  end;

implementation

procedure TZeosTests.Testqlite3Meta;
var
  dbFile:string;
  I:integer;
begin
  dbFile :='E:\Finance\FINANCE.DB';
  fzcn.Database:= dbFile;
  FzCn.Protocol:='sqlite-3' ;
  fzcn.Connected:=true;
  FzMeta.MetadataType:=mdTables;
  FzMeta.Active:=true;

  while not FzMeta.EOF do
  begin
    SendDebug(fzmeta.FieldByName('TABLE_NAME').AsString);
    FzMeta.Next;
  end;
end;

procedure TZeosTests.TestFireBirdMeta;
var
  dbFile:string;
  I:integer;
begin
  InitFireBirdDB;
  FzMeta.MetadataType:=mdTables;
  FZMeta.Active:=true;
  for I := 0 to fzMeta.Fields.Count-1 do
  begin
    SendDebug('FieldName:'+Fzmeta.Fields[I].FieldName);
  end;


  while not FzMeta.EOF do
  begin
    dbugintf.SendDebug(fzmeta.FieldByName('TABLE_NAME').AsString+':'+Fzmeta.FieldByName('Table_SCHEM').AsString);
    FzMeta.Next;
    //
  end;

end;

procedure TZeosTests.TestListAllColumn;
var
  I,J:integer;
begin
  InitFireBirdDB;
  fzmeta.TableName:='TBL_FUSE';
  fzmeta.MetadataType:=mdColumns;
  FzMeta.Active:=true;
  for I := 0 to fzmeta.Fields.Count-1 do
  begin
    SendDebug(fzmeta.Fields[I].FieldName);
  end;
  SendSeparator;
  while not FzMeta.EOF do
  begin
    for I := 0 to FZmeta.Fields.Count-1 do
    begin
      SendDebug(FZmeta.Fields[I].FieldName+':'+FzMeta.Fields[I].AsString);
    end;
    SendSeparator;
    fzmeta.Next;
  end;


end;

procedure TZeosTests.InitFireBirdDB;
var
  DBName:string;
begin
  DBName :='e:\DB\Cross.FDB';
  fzcn.Protocol:='firebird-3.0';
  fzcn.HostName:='localhost';
  fzcn.Database:=dBName;
  fzcn.User:='sysdba';
  fzcn.Password:='wac1104';
  fzcn.LibraryLocation:='C:\Firebird3_x64\fbclient.dll';
  fzcn.Connect;
end;

procedure TZeosTests.SetUp;
begin
  FzCn :=TZConnection.Create(Nil);
  FzMeta :=TZSQLMetaData.Create(nil);
  FzMeta.Connection :=FzCn;
end;

procedure TZeosTests.TearDown;
begin
  FreeAndNil(FzMeta);
  FreeAndNil(FZCn);
end;

initialization

  RegisterTest(TZeosTests);
end.

