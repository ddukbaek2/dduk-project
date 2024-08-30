@echo off
:: #------------------------------------------------------------------------
:: # 환경 변수 목록. (Windows)
:: #------------------------------------------------------------------------
echo __VARIABLE_WINDOWS__

:: 독립 실행 방지.
if not defined IS_VARIABLE (
	echo This batch file cannot be executed.
	exit /b 1
)

:: 루트 경로 설정.
set ROOTPATH=%~dp0
set ROOTPATH=%ROOTPATH:~0,-1%
for /f "tokens=1 delims=:" %%I in ("%ROOTPATH%") do set ROOTDRIVE=%%I:

:: 루트 이름 설정.
set ROOTNAME=%ROOTPATH%
for %%I in ("%ROOTPATH%") do set ROOTNAME=%%~NXI

:: 가상 환경을 만들 파이썬 인터프리터 파일 경로 설정. (오버라이드)
set PYTHONFILEPATH=C:\Program Files\Python312\python.exe

:: 가상 환경 관련 경로 설정.
set VENVNAME=.venv
set VENVPATH=%ROOTPATH%\%VENVNAME%
set VENVPYTHONPATH=%VENVPATH%\Scripts
set VENVSITEPACKAGESPATH=%VENVPATH%\Lib\site-packages
set VENVPYTHONFILEPATH=%VENVPYTHONPATH%\python.exe
set VENVACTIVATEFILEPATH=%VENVNAME%\Scripts\activate.bat
set VENVDEACTIVATEFILEPATH=%VENVNAME%\Scripts\deactivate.bat

:: 프로젝트 세부 경로 설정.
set VSCODENAME=.vscode
set VSCODEPATH=%ROOTPATH%\%VSCODENAME%
set BUILDPATH=%ROOTPATH%\build
set BUILDBINPATH=%BUILDPATH%\bin
set BUILDBINDEBUGPATH=%BUILDBINPATH%\%ROOTNAME%
set BUILDBINDEBUGINTERNALPATH=%BUILDDEBUGPATH%\_internal
set BUILDDISTPATH=%BUILDPATH%\dist
set BUILDSPECPATH=%BUILDPATH%\spec
set BUILDWORKPATH=%BUILDPATH%\work
set DOCSPATH=%ROOTPATH%\docs
set HINTSPATH=%ROOTPATH%\hints
set HOOKSPATH=%ROOTPATH%\hooks
set LIBSPATH=%ROOTPATH%\libs
set LOGSPATH=%ROOTPATH%\logs
set RESOURCEPATH=%ROOTPATH%\res
set SOURCEPATH=%ROOTPATH%\src
set TESTSPATH=%ROOTPATH%\tests
set WORKINGSPACEPATH=%ROOTPATH%\workingspace
set APPLICATIONDATAPATH=C:\ProgramData\dduk-python\dduk-application\%ROOTNAME%
set APPLICATIONDATAMETAPATH=%APPLICATIONDATAPATH%\meta
set APPLICATIONDATALIBSPATH=%APPLICATIONDATAPATH%\libs
set APPLICATIONDATALOGSPATH=%APPLICATIONDATAPATH%\logs

:: 프로젝트 패키지 파일 설정.
set REQUIREMENTSFILEPATH=%ROOTPATH%\requirements.txt

:: 배포를 위한 인증서 파일 경로 설정.
:: USERPROFILE=C:\Users\계정이름
set PYPIRCFILEPATH=%USERPROFILE%\.pypirc

:: 타임스탬프 설정. (YYYYMMDD-HHMMSS)
set YEAR=%DATE:~0,4%
set MONTH=%DATE:~5,2%
set DAY=%DATE:~8,2%
for /f "tokens=1-4 delims=:. " %%i in ("%TIME%") do (
	set HOUR=%%i
	set MINUTE=%%j
	set SECOND=%%k
)
set HOUR=0%HOUR%
set MINUTE=0%MINUTE%
set SECOND=0%SECOND%
set HOUR=%HOUR:~-2%
set MINUTE=%MINUTE:~-2%
set SECOND=%SECOND:~-2%
set TIMESTAMP=%YEAR%%MONTH%%DAY%-%HOUR%%MINUTE%%SECOND%

:: 빌드 이름. (오버라이드)
:: set BUILDNAME=dduk-unknown
set BUILDNAME=%ROOTNAME%

:: 빌드 파일 경로. (오버라이드)
set BUILDFILEPATH=%BUILDBINPATH%\%BUILDNAME%.exe

:: 디버그 빌드 파일 경로. (오버라이드)
set DEBUGBUILDFILEPATH=%BUILDBINPATH%\%BUILDNAME%\_internal\%BUILDNAME%.exe

:: 빌드시 CLI 감추기 여부 설정. (오버라이드)
set IS_BUILD_BIN_NOCONSOLE=false

:: 빌드시 디버그용 정보 포함 여부 설정. (오버라이드)
set IS_BUILD_BIN_DEBUGINFO=false

:: 변수 목록 확장 설정.
if exist "%ROOTPATH%\variable-override.bat" (
	set IS_VARIABLE_OVERRIDE=1
	call "variable-override.bat"
	set IS_VARIABLE_OVERRIDE=
)