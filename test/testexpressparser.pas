unit testexpressparser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, expressutils, fpcunit, testutils, testregistry, dbugintf;

type

  { TTestExpressParser }

  TTestExpressParser = class(TTestCase)
  private
    FExp: TExpressParser;
    FBuilder:TOperatorBuilder;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExpress;
    procedure TestSplitWords();
    procedure TestSplitwords2();
  end;

implementation

procedure TTestExpressParser.TestExpress;
var
  Node:TExpressNode;
begin
  //
  Node :=Fexp.Parser('3.15=3.15');

  Node.Process;
  checkequals( node.AsBoolean,true);
  Node :=FExp.Parser('4>3');
  Node.Process();
  CheckEquals(node.AsBoolean,true);
  Node :=FExp.Parser('"wangChong"="wangChong"');
  Node.Process();
  CheckEQuals(Node.AsBoolean,true);
end;

procedure TTestExpressParser.TestSplitWords;
var
  Express:string;
begin
  //
  fExp.SplitWords('3');
  Checkequals(fexp.WordsList.Pop,'3');
  FExp.SplitWords('3.15');
  CheckEquals(Fexp.WordsList.Pop,'3.15');
  FExp.SplitWords('ABC_5');
  checkequals(Fexp.WordsList.Pop,'ABC_5');
  FExp.SplitWords('ABc_5>3');
  CheckEquals(FExp.WordsList.Pop,'>');
  CheckEquals(FExp.WordsList.Pop,'3');
  CheckEquals(FExp.WordsList.Pop,'ABc_5');
end;

procedure TTestExpressParser.TestSplitwords2;
begin
  fexp.SplitWords('(not domain_name like "%.com") and (not domain_name like "%.org")');
  FExp.WordsList.SaveToFile('e:\temp\ccc.txt');
end;

procedure TTestExpressParser.SetUp;
begin
  FExp :=TExpressParser.Create(nil);
  FBuilder :=TOperatorBuilder.Create(nil);
  FExp.OperatorBuilder :=FBuilder;
end;

procedure TTestExpressParser.TearDown;
begin
  FreeAndnil(FBuilder);
  FreeAndnil(FExp);
end;

initialization

  RegisterTest(TTestExpressParser);
end.

