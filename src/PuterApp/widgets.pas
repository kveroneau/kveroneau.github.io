unit widgets;

{$mode ObjFPC}

interface

uses
  Web;

function GetElement(ElementId: string): TJSHTMLElement;
function MakeButton(ElementId, Title: string; onclick: THTMLClickEventHandler): TJSHTMLButtonElement;
function MakeInputField(ElementId, Title, AValue: string): TJSHTMLInputElement;

implementation

function GetElement(ElementId: string): TJSHTMLElement;
begin
  Result:=TJSHTMLElement(document.getElementById(ElementId));
end;

function MakeButton(ElementId, Title: string; onclick: THTMLClickEventHandler
  ): TJSHTMLButtonElement;
begin
  document.write('<button id="'+ElementId+'">'+Title+'</button>');
  Result:=TJSHTMLButtonElement(GetElement(ElementId));
  Result.onclick:=onclick;
end;

function MakeInputField(ElementId, Title, AValue: string): TJSHTMLInputElement;
begin
  document.write('<strong>'+Title+':</strong> ');
  document.write('<input id="'+ElementId+'" type="text" value="'+AValue+'"/>');
  Result:=TJSHTMLInputElement(GetElement(ElementId));
end;

end.

