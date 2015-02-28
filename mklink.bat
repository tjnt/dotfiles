@echo off

set HOME=%HOMEDRIVE%%HOMEPATH%

for %%f in (.vimrc .gvimrc .pluginrc .vimperatorrc) do (
    if exist "%HOME%\%%f" del "%HOME%\%%f"
    mklink "%HOME%\%%f" "%~dp0%%f"
)

pause
exit 0
