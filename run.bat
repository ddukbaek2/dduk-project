@echo off
:: chcp 65001 >nul
::------------------------------------------------------------------------
:: 콘솔 실행 관련 통합 배치 파일. (Windows 전용)
:: - 일관적으로 사용하기 위해 다른 배치 파일 기능까지 포함 되어있음.
::------------------------------------------------------------------------
echo __RUN_WINDOWS__

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

:: 매개 변수 전역 설정.
set NUMINDEX=0
for %%I in (%0 %*) do (
	call set ARGUMENT_%%NUMINDEX%%=%%I
	call set /a NUMINDEX=%%NUMINDEX%%+1
)

:: 입력된 레이블이 없을 경우.
if "%COMMAND%" == "" (
	:: 레이블 설명 출력.
	chcp 65001 >nul
	setlocal enabledelayedexpansion
	set TEXT=Usage: %EXECUTEFILENAME% {venv^|prepare^|tests^|source^|build^|service}
	echo !TEXT!
	set TEXT=run venv: 가상 환경 관련 명령
	echo !TEXT!
	set TEXT=run prepare: 실행 및 빌드 전 코드 생성 명령
	echo !TEXT!
	set TEXT=run tests: 단위테스트 실행 명령
	echo !TEXT!
	set TEXT=run source: 소스 실행 명령
	echo !TEXT!
	set TEXT=run build: 빌드 관련 명령
	echo !TEXT!
	set TEXT=run service: 서비스 관련 명령
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
:: 가상 환경 관련 명령.
::--------------------------------------------------------------------------------
:venv
	echo __RUN_VENV_WINDOWS__

	:: 변수 설정.
	set VENV_COMMAND=%ARGUMENT_2%

	:: 가상환경 명령.
	call "venv.bat" %VENV_COMMAND%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
exit /b 0


::--------------------------------------------------------------------------------
:: 실행/빌드 전 준비 명령. (포함 코드 생성)
::--------------------------------------------------------------------------------
:prepare
	echo __RUN_PREPARE_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 빌드 전 처리 실행.
	python "%SOURCEPATH%\__prepare__.py" "source"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
exit /b 0


::--------------------------------------------------------------------------------
:: 단위 테스트 실행 명령.
::--------------------------------------------------------------------------------
:tests
	echo __RUN_TESTS_WINDOWS__
	
	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 빌드 전 처리 실행.
	python "%SOURCEPATH%\__prepare__.py" "source"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 테스트 패키지 실행.
	:: 내부의 __main__.py 에서 전체 유닛테스트 스크립트 검색하여 실행.
	python "%TESTSPATH%"
exit /b 0


::--------------------------------------------------------------------------------
:: 소스 실행 명령.
::--------------------------------------------------------------------------------
:source
	echo __RUN_SOURCE_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 빌드 전 처리 실행.
	python "%SOURCEPATH%\__prepare__.py" "source"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 런처 실행.
	python "%SOURCEPATH%\__launch__.py"

		:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0


::--------------------------------------------------------------------------------
:: 빌드 관련 명령.
::--------------------------------------------------------------------------------
:build
	echo __RUN_BUILD_WINDOWS__

	:: 변수 설정.
	set BUILD_COMMAND=%ARGUMENT_2%

	:: 빌드 명령.
	call "build.bat" %BUILD_COMMAND%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 관련 명령.
::--------------------------------------------------------------------------------
:service
	echo __RUN_SERVICE_WINDOWS__

	:: 변수 설정.
	set SERVICE_COMMAND=%ARGUMENT_2%
	set SERVICE_TYPE=%ARGUMENT_3%

	:: 서비스 명령.
	call "service.bat" %SERVICE_COMMAND% %SERVICE_TYPE%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
exit /b 0