initAPI = function(){
  window.GetContent = rtl.createSafeCallback(pas.program.Application, "GetContent");
  AfterInit = rtl.createSafeCallback(pas.program.Application, "AfterInit");
  AfterInit(true);
};

SetTitle = function(s){
  document.getElementById('title').innerHTML=s;
};

SetContent = function(s){
  document.getElementById('content').innerHTML=s;
};
