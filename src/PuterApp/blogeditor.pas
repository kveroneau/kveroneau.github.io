unit BlogEditor;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, bulma, Web, widgets, PuterDB, puterjs, DateUtils;

type

  { TBlogEditorForm }

  TBlogEditorForm = class(TComponent)
  private
    FTitle, FPath: TBulmaInput;
    FType: TJSHTMLSelectElement;
    FContent: TJSHTMLTextAreaElement;
    FSubdomain: string;
    function SaveEntry(aEvent: TJSMouseEvent): boolean;
    function AddEntry(aEvent: TJSMouseEvent): boolean;
    function NextRec(aEvent: TJSMouseEvent): boolean;
    function PrevRec(aEvent: TJSMouseEvent): boolean;
  public
    property Subdomain: string write FSubdomain;
    constructor Create(AOwner: TComponent); override;
    procedure FillRecord;
    procedure Show;
  end;

var
  BlogEditorForm: TBlogEditorForm;

implementation

{ TBlogEditorForm }

function TBlogEditorForm.SaveEntry(aEvent: TJSMouseEvent): boolean;
begin
  BlogDB.DataSet.Edit;
  BlogDB.Dates['Modified']:=Now;
  BlogDB.Strings['Title']:=FTitle.Value;
  BlogDB.Strings['Path']:=FPath.Value;
  BlogDB.Ints['ContentType']:=StrToInt(FType.value);
  BlogDB.Strings['Content']:=FContent.value;
  BlogDB.DataSet.Post;
  Puter.WriteFile(FSubdomain+'/website.json', BlogDB.GetJSON);
end;

function TBlogEditorForm.AddEntry(aEvent: TJSMouseEvent): boolean;
begin
  BlogDB.DataSet.Append;
  BlogDB.Dates['Created']:=Now;
  BlogDB.Dates['Modified']:=Now;
  BlogDB.Ints['ContentType']:=1;
  BlogDB.DataSet.Post;
  FillRecord;
end;

function TBlogEditorForm.NextRec(aEvent: TJSMouseEvent): boolean;
begin
  BlogDB.DataSet.Next;
  FillRecord;
end;

function TBlogEditorForm.PrevRec(aEvent: TJSMouseEvent): boolean;
begin
  BlogDB.DataSet.Prior;
  FillRecord;
end;

constructor TBlogEditorForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TBlogEditorForm.FillRecord;
begin
  FTitle.Value:=BlogDB.Strings['Title'];
  FPath.Value:=BlogDB.Strings['Path'];
  FType.Value:=IntToStr(BlogDB.Ints['ContentType']);
  FContent.value:=BlogDB.Strings['Content'];
end;

procedure TBlogEditorForm.Show;
var
  btn1, btn2, next, prior: TBulmaButton;
begin
  with TabBody do
  begin
    next:=TBulmaButton.Create(Self, ' &gt;&gt; ', 'NextBtn', @NextRec);
    prior:=TBulmaButton.Create(Self, ' &lt;&lt; ', 'PrevBtn', @PrevRec);
    setContent(prior.renderHTML+next.renderHTML+'<br/>');
    FTitle:=TBulmaInput.Create(Self, 'Title', 'ftitle');
    FPath:=TBulmaInput.Create(Self, 'Path', 'fpath');
    Write(FTitle.renderHTML+'<br/>'+FPath.renderHTML+'<br/>'+TypesDropDown+'<br/>');
    Write('<textarea id="fcontent" rows="30" cols="80"></textarea><br/>');
    btn1:=TBulmaButton.Create(Self, 'Save', 'SaveBtn', @SaveEntry);
    btn2:=TBulmaButton.Create(Self, 'Add', 'AddBtn', @AddEntry);
    Write(btn1.renderHTML+btn2.renderHTML);
    FType:=TJSHTMLSelectElement(GetElement('ftype'));
    FContent:=TJSHTMLTextAreaElement(GetElement('fcontent'));
    btn1.Bind;
    btn2.Bind;
    next.Bind;
    prior.Bind;
  end;
  FillRecord;
end;

end.

