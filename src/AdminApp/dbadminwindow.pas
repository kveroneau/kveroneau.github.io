unit DBAdminWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, dbf, dbftojson, Forms,
  Controls, Graphics, Dialogs, DBCtrls, ComCtrls, DBGrids, StdCtrls, fpjson,
  jsonparser, DateUtils, EditWindow{$IFDEF JSONDS}, extjsdataset{$ENDIF};

type

  { TDBAdminForm }

  TDBAdminForm = class(TForm)
    SrcEditBtn: TButton;
    ClearFilterBtn: TButton;
    DBContentType: TDBLookupComboBox;
    ContentTypeFilter: TDBLookupComboBox;
    FilterGrid: TDBGrid;
    FilterPath: TEdit;
    Label5: TLabel;
    Label6: TLabel;
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
    FilterTab: TTabSheet;
    TypesTab: TTabSheet;
    procedure ClearFilterBtnClick(Sender: TObject);
    procedure ContentTypeFilterChange(Sender: TObject);
    procedure DataSourceDataChange(Sender: TObject; Field: TField);
    procedure DBContentTypeChange(Sender: TObject);
    procedure DbfBeforePost(DataSet: TDataSet);
    procedure DbfNewRecord(DataSet: TDataSet);
    procedure ExportBtnClick(Sender: TObject);
    procedure FilterPathChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormTabResize(Sender: TObject);
    procedure GridTabShow(Sender: TObject);
    procedure SrcEditBtnClick(Sender: TObject);
    procedure TypesTabShow(Sender: TObject);
  private
    {$IFDEF JSONDS}
    FDataSet: TExtJSJSONDataSet;
    FJSON: TJSONObject;
    procedure LoadDatabase;
    {$ENDIF}
    procedure SetFilter;
    procedure ExportJSON(DS: TDataSet; AFile: string);
  public

  end;

var
  DBAdminForm: TDBAdminForm;

implementation

{$R *.lfm}

{ TDBAdminForm }

procedure TDBAdminForm.FormCreate(Sender: TObject);
begin
  SrcEditBtn.Visible:=False;
  {$IFDEF JSONDS}
  FDataSet:=TExtJSJSONDataSet.Create(Self);
  LoadDatabase;
  {$ELSE}
  if not DirectoryExists(Dbf.FilePathFull) then
    CreateDir(Dbf.FilePathFull);
  {$ENDIF}
end;

procedure TDBAdminForm.ExportBtnClick(Sender: TObject);
begin
  {$IFDEF JSONDS}
  FDataSet.SaveToFile('database.json', True);
  {$ELSE}
  ExportJSON(Dbf, 'website.json');
  ExportJSON(TypesDB, 'types.json');
  {$ENDIF}
end;

procedure TDBAdminForm.FilterPathChange(Sender: TObject);
begin
  SetFilter;
end;

procedure TDBAdminForm.DbfBeforePost(DataSet: TDataSet);
begin
  DataSet.Fields.FieldByName('MODIFIED').AsDateTime:=Now;
end;

procedure TDBAdminForm.ContentTypeFilterChange(Sender: TObject);
begin
  SetFilter;
  {$IFDEF ANNOYING}
  if dbf.Filtered and (FilterPath.Text = '') then
    DBTabs.TabIndex:=1;
  {$ENDIF}
end;

procedure TDBAdminForm.DataSourceDataChange(Sender: TObject; Field: TField);
begin
  DBContentTypeChange(Sender);
end;

procedure TDBAdminForm.DBContentTypeChange(Sender: TObject);
var
  kv: integer;
begin
  try
    kv:=DBContentType.KeyValue;
    if (kv = 0) or (kv = 50) or (kv = 51) then
      SrcEditBtn.Visible:=True
    else if (kv > 99) and (kv < 200) then
      SrcEditBtn.Visible:=True
    else
      SrcEditBtn.Visible:=False;
  except
    On EVariantError do SrcEditBtn.Visible:=False;
  end;
end;

procedure TDBAdminForm.ClearFilterBtnClick(Sender: TObject);
begin
  ContentTypeFilter.ItemIndex:=-1;
  FilterPath.Text:='';
  dbf.Filtered:=False;
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

procedure TDBAdminForm.SrcEditBtnClick(Sender: TObject);
begin
  DataSource.Edit;
  case DBContentType.KeyValue of
    0: DBContent.Text:=SourceEditForm.EditHTML(DBContent.Text);
    100: DBContent.Text:=SourceEditForm.EditObjPas(DBContent.Text);
    102: DBContent.Text:=SourceEditForm.EditPython(DBContent.Text);
    50: DBContent.Text:=SourceEditForm.EditJS(DBContent.Text);
    106: DBContent.Text:=SourceEditForm.EditJS(DBContent.Text);
    51: DBContent.Text:=SourceEditForm.EditPython(DBContent.Text);
  end;
end;

procedure TDBAdminForm.TypesTabShow(Sender: TObject);
begin
  TypeGrid.Width:=600;
end;

procedure TDBAdminForm.SetFilter;
var
  fbuf: string;
begin
  if Length(FilterPath.Text) > 2 then
  begin
    fbuf:='PATH='+QuotedStr('/'+FilterPath.Text+'*');
    if ContentTypeFilter.ItemIndex > -1 then
      dbf.Filter:=fbuf+' and CONTENTTYPE='+IntToStr(ContentTypeFilter.KeyValue)
    else
      dbf.Filter:=fbuf;
    dbf.Filtered:=True;
  end
  else if ContentTypeFilter.ItemIndex > -1 then
  begin
    dbf.Filter:='CONTENTTYPE='+IntToStr(ContentTypeFilter.KeyValue);
    dbf.Filtered:=True;
  end
  else
    dbf.Filtered:=False;
end;

procedure TDBAdminForm.ExportJSON(DS: TDataSet; AFile: string);
var
  json: TJSONObject;
  s: TStringStream;
begin
  json:=ExportDBF(DS);
  s:=TStringStream.Create;
  try
    s.WriteString(json.AsJSON);
    s.SaveToFile(AFile);
  finally
    s.Free;
    json.Free;
  end;
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

