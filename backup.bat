@echo off

for /F "tokens=1-4 delims=/ " %%A in ('date /t') do (
    set DateDay=%%B
    set DateMonth=%%C
    set DateYear=%%D
)
set CurrentDate=%DateYear%%DateMonth%%DateDay%

for /F "tokens=1-2 delims=: " %%A in ("%TIME%") do (
    set TimeHour=%%A
    set TimeMin=%%B
)
set CurrentTime=%TimeHour%%TimeMin%

md \backup\%CurrentDate%-%CurrentTime%\
md \backup\%CurrentDate%-%CurrentTime%\chriprod\

copy \chriprod\*.* \backup\%CurrentDate%-%CurrentTime%\chriprod\

dir \backup\%CurrentDate%-%CurrentTime%
pause