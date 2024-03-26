unit BlogList;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, widgets, Web, PuterDB;

type

  { TBlogList }

  TBlogList = class(TComponent)
  private
    FSubdomain: string;
    function RenderGrid: string;
    function ShowGrid(aEvent: TJSMouseEvent): boolean;
  public
    property Subdomain: string write FSubdomain;
    constructor Create(AOwner: TComponent); override;
  end;

var
  DBGrid: TBlogList;

implementation

const
  DATE_FORMAT = 'dddd mmmm d, yyyy "at" hh:nn';

{ TBlogList }

function TBlogList.RenderGrid: string;
begin
  Result:='<table><tr><th>Path</th><th>Title</th><th>Created</th><th>Modified</th></tr>';
  BlogDB.DataSet.First;
  repeat
    Result:=Result+'<tr><td><a href="https://'+FSubdomain+'.puter.site/#'+BlogDB.Strings['Path']+'" target="_new">'+BlogDB.Strings['Path']+'</a></td>';
    Result:=Result+'<td><a href="#" onclick="return pas.BlogEditor.BlogEditorForm.GotoRecord('''+BlogDB.Strings['Path']+''');">'+BlogDB.Strings['Title']+'</a></td>';
    Result:=Result+'<td>'+FormatDateTime(DATE_FORMAT, BlogDB.Dates['Created'])+'</td>';
    Result:=Result+'<td>'+FormatDateTime(DATE_FORMAT, BlogDB.Dates['Modified'])+'</td></tr>';
    BlogDB.DataSet.Next;
  until BlogDB.DataSet.EOF;
  Result:=Result+'</table>';
end;

function TBlogList.ShowGrid(aEvent: TJSMouseEvent): boolean;
begin
  if FSubdomain = '' then
  begin
    Result:=False;
    Exit;
  end;
  TabBody.setContent(RenderGrid);
end;

constructor TBlogList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GridTab:=TabSys.AddTab('Database Grid', 'GridTab', @ShowGrid);
  TabSys.renderHTML;
end;

end.

