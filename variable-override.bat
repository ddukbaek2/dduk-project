@echo off
:: chcp 65001 >nul
:: #------------------------------------------------------------------------
:: # 환경 변수 목록 확장. (Windows)
:: #------------------------------------------------------------------------
echo __VARIABLE_OVERRIDE_WINDOWS__

:: 독립 실행 방지.
if not defined IS_VARIABLE_OVERRIDE (
	echo This batch file cannot be executed.
	exit /b 1
)

:: 가상 환경을 만들 파이썬 인터프리터 파일 경로 설정. (오버라이드)
set PYTHONFILEPATH=C:\Program Files\Python312\python.exe

:: 빌드 이름. (오버라이드)
set BUILDNAME=%ROOTNAME%

:: 빌드 파일 경로. (오버라이드)
set BUILDFILEPATH=%BUILDBINPATH%\%BUILDNAME%.exe

:: 빌드시 콘솔창 보이기. (오버라이드)
set IS_BUILD_BIN_NOCONSOLE=false

:: 빌드시 디버그용 정보 포함 여부 설정. (오버라이드)
set IS_BUILD_BIN_DEBUGINFO=false

:: 에그 인포 이름.
:: 빌드 이름에 하이픈이 들어있을 경우 언더바로 변환.
set EGGINFONAME=%BUILDNAME:-=_%.egg-info

:: 빌드 파일을 만들면서 생기는 에그 인포 디렉토리 경로.
set BUILDEGGINFOPATH=%SOURCEPATH%\%EGGINFONAME%

:: BPY 라이브러리 이름.
set BPYFILENAME=bpy-4.0.0-cp310-cp310-win_amd64.whl

:: BPY 라이브러리 다운로드 경로.
set BPYDOWNLOADFILEPATH=%APPLICATIONDATALIBSPATH%\%BPYFILENAME%

:: BPY 라이브러리 적용 경로.
set BPYFILEPATH=%LIBSPATH%\%BPYFILENAME%

:: BPY 라이브러리 다운로드 주소.
set BPYFILEURL=https://altavagroup.synology.me/conversion/download/%BPYFILENAME%