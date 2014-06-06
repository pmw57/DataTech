@echo off
set harbour=\hmg.3.2\HARBOUR
set config=contrib\hbformat\hbformat.ini

%harbour%\bin\hbformat.exe @%harbour%\%config% %1
