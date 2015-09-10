
set vcpath=C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC
call "%vcpath%\vcvarsall.bat" amd64

pushd "%~dp0bundle\vimproc.vim"
nmake -f make_msvc.mak nodebug=1

pause

