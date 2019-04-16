@set oldpath=%path%
@set path=%path%;c:\bcc7\bin
c:\harbour\bin\hbmk2 ormd.prg -comp=bcc -ldolphin -llibmysql -lhbwin -lxhb -lhbct
if errorlevel 0 ormd.exe
@set path=%oldpath%