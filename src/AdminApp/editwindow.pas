unit EditWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, SynEdit,
  SynHighlighterHTML, SynHighlighterPython, SynHighlighterJScript,
  SynHighlighterPas, SynEditHighlighter;

type

  { TSourceEditForm }

  TSourceEditForm = class(TForm)
    SynEdit: TSynEdit;
    SynHTML: TSynHTMLSyn;
    SynJScript: TSynJScriptSyn;
    SynObjPas: TSynPasSyn;
    SynPython: TSynPythonSyn;
    procedure FormResize(Sender: TObject);
  private
    procedure SetHighlighter(hl: TSynCustomHighlighter; content: string);
  public
    function EditHTML(content: string): string;
    function EditPython(content: string): string;
    function EditJS(content: string): string;
    function EditObjPas(content: string): string;
  end;

var
  SourceEditForm: TSourceEditForm;

implementation

{$R *.lfm}

{ TSourceEditForm }

procedure TSourceEditForm.FormResize(Sender: TObject);
begin
  SynEdit.Width:=ClientWidth;
  SynEdit.Height:=ClientHeight;
end;

procedure TSourceEditForm.SetHighlighter(hl: TSynCustomHighlighter;
  content: string);
begin
  SynEdit.Highlighter:=hl;
  hl.Enabled:=True;
  SynEdit.Text:=content;
  ShowModal;
  hl.Enabled:=False;
end;

function TSourceEditForm.EditHTML(content: string): string;
begin
  SetHighlighter(SynHTML, content);
  Result:=SynEdit.Text;
end;

function TSourceEditForm.EditPython(content: string): string;
begin
  SetHighlighter(SynPython, content);
  Result:=SynEdit.Text;
end;

function TSourceEditForm.EditJS(content: string): string;
begin
  SetHighlighter(SynJScript, content);
  Result:=SynEdit.Text;
end;

function TSourceEditForm.EditObjPas(content: string): string;
begin
  SetHighlighter(SynObjPas, content);
  Result:=SynEdit.Text;
end;

end.

