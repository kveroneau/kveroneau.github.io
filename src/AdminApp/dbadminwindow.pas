unit DBAdminWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, dbf, fpsimplejsonexport, Forms,
  Controls, Graphics, Dialogs, DBCtrls, ComCtrls, DBGrids, StdCtrls, fpjson,
  jsonparser, DateUtils{$IFDEF JSONDS}, extjsdataset{$ENDIF};

type

  { TDBAdminForm }

  TDBAdminForm = class(TForm)
    DBContentType: TDBLookupComboBox;
    TypeGrid: TDBGrid;
    TypeNavigator: TDBNavigator;
    TypesDS: TDataSource;
    Dbf: TDbf;
    TypesDB: TDbf;
    GridNavigator: TDBNavigator;
    ExportBtn: TButton;
    DataSource: TDataSource;
    DBContent: TDBMemo;
    DBNavigator: TDBNavigator;
    DBTitle: TDBEdit;
    DBPath: TDBEdit;
    DBGrid: TDBGrid;
    DBTabs: TPageControl;
    FormTab: TTabSheet;
    GridTab: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    JSONExporter: TSimpleJSONExporter;
    FilterTab: TTabSheet;
    TypesTab: TTabSheet;
    procedure DbfBeforePost(DataSet: TDataSet);
    procedure DbfNewRecord(DataSet: TDataSet);
    procedure ExportBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormTabResize(Sender: TObject);
    procedure GridTabShow(Sender: TObject);
    procedure TypesTabShow(Sender: TObject);
  private
    {$IFDEF JSONDS}
    FDataSet: TExtJSJSONDataSet;
    FJSON: TJSONObject;
    procedure LoadDatabase;
    {$ENDIF}
  public

  end;

var
  DBAdminForm: TDBAdminForm;

implementation

{$R *.lfm}

{ TDBAdminForm }

procedure TDBAdminForm.FormCreate(Sender: TObject);
begin
  {$IFDEF JSONDS}
  FDataSet:=TExtJSJSONDataSet.Create(Self);
  LoadDatabase;
  {$ELSE}
  if not DirectoryExists(Dbf.FilePathFull) then
    CreateDir(Dbf.FilePathFull);
  {$ENDIF}
end;

procedure TDBAdminForm.ExportBtnClick(Sender: TObject);
{$IFNDEF JSONDS}
var
  s: TStringStream;
  buf: string;
  json: TJSONObject;
{$ENDIF}
begin
  {$IFDEF JSONDS}
  FDataSet.SaveToFile('database.json', True);
  {$ELSE}
  json:=TJSONObject.Create;
  s:=TStringStream.Create;
  try
    s.LoadFromFile('metaData.json');
    json.Objects['metaData']:=GetJSON(s.DataString) as TJSONObject;
    s.Clear;
    JSONExporter.ExportToStream(s);
    json.Arrays['Data']:=GetJSON(s.DataString) as TJSONArray;
    s.Clear;
    s.WriteString(json.AsJSON);
    s.SaveToFile('website.json');
  finally
    s.Free;
    json.Free;
  end;
  {$ENDIF}
end;

procedure TDBAdminForm.DbfBeforePost(DataSet: TDataSet);
begin
  DataSet.Fields.FieldByName('MODIFIED').AsDateTime:=Now;
end;

procedure TDBAdminForm.DbfNewRecord(DataSet: TDataSet);
begin
  DataSet.Fields.FieldByName('CREATED').AsDateTime:=Now;
end;

procedure TDBAdminForm.FormDestroy(Sender: TObject);
begin
  {$IFDEF JSONDS}
  FDataSet.Close;
  {$ENDIF}
end;

procedure TDBAdminForm.FormResize(Sender: TObject);
begin
  DBTabs.Width:=ClientWidth;
  DBTabs.Height:=ClientHeight;
end;

procedure TDBAdminForm.FormTabResize(Sender: TObject);
begin
  DBContent.Width:=FormTab.ClientWidth-DBContent.Left-30;
  DBContent.Height:=FormTab.ClientHeight-DBContent.Top-100;
  DBNavigator.Top:=FormTab.ClientHeight-50;
  ExportBtn.Top:=FormTab.ClientHeight-50;
end;

procedure TDBAdminForm.GridTabShow(Sender: TObject);
begin
  DBGrid.Width:=GridTab.ClientWidth;
  DBGrid.Height:=GridTab.ClientHeight-GridNavigator.Height;
  GridNavigator.Top:=DBGrid.Height;
end;

procedure TDBAdminForm.TypesTabShow(Sender: TObject);
begin
  TypeGrid.Width:=600;
end;

{$IFDEF JSONDS}
procedure TDBAdminForm.LoadDatabase;
begin
  with TStringList.Create do
  try
    LoadFromFile('../database.json');
    FJSON:=GetJSON(Text) as TJSONObject;
    FDataSet.MetaData:=FJSON.Objects['metaData'];
    FDataSet.Rows:=FJSON.Arrays['Data'];
    FDataSet.Open;
    DataSource.DataSet:=FDataSet;
  finally
    Free;
  end;
end;
{$ENDIF}

end.

