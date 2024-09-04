@echo off
:: chcp 65001 >nul
::------------------------------------------------------------------------
:: 가상 환경 관련 통합 배치 파일. (Windows 전용)
::------------------------------------------------------------------------
echo __VENV_WINDOWS__

:: 변수 목록 불러오기.
set ROOTPATH=%~dp0
set ROOTPATH=%ROOTPATH:~0,-1%
if exist "%ROOTPATH%\variable.bat" (
	set IS_VARIABLE=1
	call "variable.bat"
	set IS_VARIABLE=
)

:: 변수 설정.
set EXECUTEFILENAME=%~N0
set COMMAND=%~1
set TEXT=

:: 입력된 레이블이 없을 경우.
if "%COMMAND%" == "" (
	:: 레이블 설명 출력.
	setlocal enabledelayedexpansion
	set TEXT=Usage: %EXECUTEFILENAME% {create^|destroy^|start^|stop^|update}
	echo !TEXT!
	set TEXT=venv create: 가상 환경 생성
	echo !TEXT!
	set TEXT=venv destroy: 가상 환경 제거
	echo !TEXT!
	set TEXT=venv start: 가상 환경 시작
	echo !TEXT!
	set TEXT=venv stop: 가상 환경 종료
	echo !TEXT!
	set TEXT=venv update: 가상 환경 생성 + 시작 + 패키지 설치
	echo !TEXT!
	endlocal
	exit /b 0
) else (
	:: 레이블 실행.
	call :%COMMAND%
)

:: 레이블을 실행한 뒤 오류 갯수 검사.
if %errorlevel% equ 0 (
	:: 레이블이 성공적으로 종료 되었으면 성공.
	exit /b 0
) else (
	:: 레이블이 성공적으로 종료되지 못했다면 실패.
	setlocal enabledelayedexpansion
	set TEXT=ERROR: %COMMAND%
	echo !TEXT!
	endlocal
	exit /b %errorlevel%
)


::--------------------------------------------------------------------------------
:: 가상 환경 생성.
:: - 기존 가상 환경이 활성화 되어있으면 비활성화.
:: - 기존 가상 환경이 존재하면 제거.
:: - 가상 환경이 없으면 새로운 가상 환경 생성.
:: - 가상 환경이 활성화 되어있지 않으면 활성화. 
::--------------------------------------------------------------------------------
:create
	echo __VENV_CREATE_WINDOWS__

	:: 가상 환경이 활성화 되어 있으면 비활성화.
	if defined VIRTUAL_ENV ( call "%VENVDEACTIVATEFILEPATH%" )
	
	:: 가상 환경이 있으면 제거.
	if exist "%VENVPATH%" (  rmdir /s /q "%VENVPATH%" )

	:: 가상 환경이 없으면 생성.
	if not exist "%VENVPATH%" ( "%PYTHONFILEPATH%" -m venv "%VENVPATH%" )

	:: 가상 환경이 활성화 되어있지 않으면 활성화.
	if not defined VIRTUAL_ENV ( call "%VENVACTIVATEFILEPATH%" )

	:: 가상 환경 패키지 업데이트.
	call :update
exit /b 0


::--------------------------------------------------------------------------------
:: 가상 환경 제거.
:: - 기존 가상 환경이 활성화 되어있으면 비활성화.
:: - 기존 가상 환경이 존재하면 제거.
::--------------------------------------------------------------------------------
:destroy
	echo __VENV_DESTROY_WINDOWS__

	:: 가상 환경이 활성화 되어 있으면 비활성화.
	if defined VIRTUAL_ENV ( call "%VENVDEACTIVATEFILEPATH%" )

	:: 가상 환경이 있으면 제거.
	if exist "%VENVPATH%" ( rmdir /s /q "%VENVPATH%" )
exit /b 0


::--------------------------------------------------------------------------------
:: 가상 환경 시작. (활성화)
:: - 가상 환경이 없으면 새로운 가상 환경 생성.
:: - 가상 환경이 활성화 되어있지 않으면 활성화. 
::--------------------------------------------------------------------------------
:start
	echo __VENV_START_WINDOWS__

	:: 가상 환경이 없으면 생성.
	if not exist "%VENVPATH%" ( "%PYTHONFILEPATH%" -m venv "%VENVPATH%" )

	:: 가상 환경이 활성화 되어있지 않으면 활성화.
	if not defined VIRTUAL_ENV ( call "%VENVACTIVATEFILEPATH%" )

	:: 가상 환경 패키지 업데이트.
	call :update
exit /b 0


::--------------------------------------------------------------------------------
:: 가상 환경 정지. (비활성화)
:: - 가상 환경이 존재하며 활성화 되어있을 때 비활성화.
::--------------------------------------------------------------------------------
:stop
	echo __VENV_STOP_WINDOWS__

	:: 가상 환경이 있을 때.
	if exist "%VENVPATH%" (
		:: 가상 환경이 활성화 되어 있으면.
		if defined VIRTUAL_ENV (
			:: 비활성화.
			call "%VENVDEACTIVATEFILEPATH%"
		)
	)
exit /b 0


::--------------------------------------------------------------------------------
:: 가상 환경 패키지 업데이트.
:: - 업데이트 전 가상 환경이 없으면 생성.
:: - 업데이트 전 가상 환경이 활성화 되어있지 않으면 활성화.
::--------------------------------------------------------------------------------
:update
	echo __VENV_UPDATE_WINDOWS__

	:: 가상 환경이 없으면 생성.
	if not exist "%VENVPATH%" ( "%PYTHONFILEPATH%" -m venv "%VENVPATH%" )

	:: 가상 환경이 활성화 되어있지 않으면 활성화.
	if not defined VIRTUAL_ENV ( call "%VENVACTIVATEFILEPATH%" )

	:: 패키지 설치.
	python --version
	python -m ensurepip --upgrade >nul 2>nul
	python -m pip install --upgrade pip >nul 2>nul
	python -m pip install --upgrade --force -r "%REQUIREMENTSFILEPATH%" >nul 2>nul

	:: C:\ProgramData\dduk-python\dduk-application\{projectName}\libs 폴더 생성.
	if not exist "%APPLICATIONDATALIBSPATH%" ( mkdir "%APPLICATIONDATALIBSPATH%" )

	:: C:\ProgramData\dduk-python\dduk-application\{projectName}\logs 폴더 생성.
	if not exist "%APPLICATIONDATALOGSPATH%" ( mkdir "%APPLICATIONDATALOGSPATH%" )

	:: 패키지 목록 확장 설정.
	if exist "%ROOTPATH%\venv-update-override.bat" (
		set IS_VENV_UPDATE_OVERRIDE=1
		call "venv-update-override.bat"
		set IS_VENV_UPDATE_OVERRIDE=
	)

	:: 현재 가상 환경에 설치된 모든 패키지 확인.
	python -m pip list
exit /b 0