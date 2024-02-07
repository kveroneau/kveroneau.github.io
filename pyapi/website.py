"""
Hello, if you are just randomly viewing the source code in my repo and might be wondering what the
heck a Python library essentially is here, well let me answer that question to what you ponder...
"""
from browser import window, document

def SetHTML(el, s):
    document.getElementById(el).innerHTML=s

def SetContent(s):
    SetHTML('content', s)

def SetTitle(s):
    SetHTML('title', s)

def GetContent(path):
    return window.pas.program.Application.GetContent(path)
