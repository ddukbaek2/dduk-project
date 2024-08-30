@echo off
:: chcp 65001 >nul
::------------------------------------------------------------------------
:: 서비스 관련 통합 배치 파일. (Windows 전용)
::------------------------------------------------------------------------
echo __SERVICE_WINDOWS__

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
	set TEXT=Usage: %EXECUTEFILENAME% {create^|destroy^|start^|stop^|restart^|execute^|edit^|status^|list}, serviceName {이름}, serviceType {dev^|test^|live}
	echo !TEXT!
	set TEXT=service create {serviceName} {serviceType}: 서비스 설치.
	echo !TEXT!
	set TEXT=service destroy {serviceName}: 서비스 제거.
	echo !TEXT!
	set TEXT=service start {serviceName}: 서비스 시작.
	echo !TEXT!
	set TEXT=service stop {serviceName}: 서비스 정지.
	echo !TEXT!
	set TEXT=service restart {serviceName}: 서비스 재시작.
	echo !TEXT!
	set TEXT=service execute {serviceName}: 서비스 시작 테스트. 서비스로직이지만 서비스와 무관하게 즉시실행.
	echo !TEXT!
	set TEXT=service edit {serviceName}: 서비스 GUI 열기.
	echo !TEXT!
	set TEXT=service status {serviceName}: 현재 장비에 설정된 모든 서비스 목록 조회.
	echo !TEXT!
	set TEXT=service list: 현재 장비에 설정된 모든 서비스 목록 조회.
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
:: 서비스 생성.
::--------------------------------------------------------------------------------
:create
	echo __SERVICE_CREATE_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%
	set SERVICETYPE=%ARGUMENT_3%
	set SERVICEFILEPATH=%ROOTPATH%\service.bat
	set STDOUTLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-stdout.log
	set STDERRLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-stderr.log
	set PARAMETERS=execute %SERVICETYPE%
	echo SERVICENAME: %SERVICENAME%
	echo SERVICETYPE: %SERVICETYPE%
	echo SERVICEFILEPATH: %SERVICEFILEPATH%
	echo STDOUTLOGFILENAME: %STDOUTLOGFILENAME%
	echo STDERRLOGFILENAME: %STDERRLOGFILENAME%

	:: NSSM 설정.
	nssm install %SERVICENAME% "%SERVICEFILEPATH%"
	nssm set %SERVICENAME% Start SERVICE_AUTO_START
	nssm set "%SERVICENAME%" Priority REALTIME
	nssm set %SERVICENAME% AppDirectory "%ROOTPATH%"
	nssm set %SERVICENAME% AppParameters "%PARAMETERS%"
	nssm set %SERVICENAME% Description "%SERVICEDESCRIPTION%"
	:: nssm set %SERVICENAME% AppStdout ""
	:: nssm set %SERVICENAME% AppStderr ""
	nssm set %SERVICENAME% AppStdout "%STDOUTLOGFILENAME%"
	nssm set %SERVICENAME% AppStderr "%STDERRLOGFILENAME%"
	
exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 제거.
::--------------------------------------------------------------------------------
:destroy
	echo __SERVICE_DESTROY_WINDOWS__

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%
	echo SERVICENAME: %SERVICENAME%

	:: NSSM 설정.
	nssm stop %SERVICENAME%
	nssm remove %SERVICENAME% confirm
exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 시작.
::--------------------------------------------------------------------------------
:start
	echo __SERVICE_START_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%
	:: set STDOUTLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-stdout.log
	:: set STDERRLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-stderr.log
	:: set STDOUTLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-%TIMESTAMP%-stdout.log
	:: set STDOUTLOGFILENAME=%APPLICATIONDATALOGSPATH%\%SERVICENAME%-%TIMESTAMP%-stderr.log
	echo SERVICENAME: %SERVICENAME%
	:: echo STDOUTLOGFILENAME: %STDOUTLOGFILENAME%
	:: echo STDERRLOGFILENAME: %STDERRLOGFILENAME%

	:: NSSM 설정.
	nssm start %SERVICENAME%
exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 정지.
::--------------------------------------------------------------------------------
:stop
	echo __SERVICE_STOP_WINDOWS__

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%
	echo SERVICENAME: %SERVICENAME%

	:: NSSM 설정.
	nssm stop %SERVICENAME%
exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 재시작.
::--------------------------------------------------------------------------------
:restart
	echo __SERVICE_RESTART_WINDOWS__

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%
	echo SERVICENAME: %SERVICENAME%

	:: NSSM 설정.
	nssm restart %SERVICENAME%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 실행. (소스 실행 명령)
::--------------------------------------------------------------------------------
:execute
	echo __SERVICE_EXECUTE_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 변수 설정.
	set SERVICETYPE=%ARGUMENT_2%
	echo SERVICETYPE: %SERVICETYPE%

	:: 빌드 전 처리 실행.
	python "%SOURCEPATH%\__prepare__.py" "service"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 런처 실행.
	python "%SOURCEPATH%\__launch__.py" "%SERVICETYPE%"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 수정.
::--------------------------------------------------------------------------------
:edit
	echo __SERVICE_EDIT_WINDOWS__

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%

	:: NSSM 설정.
	nssm edit %SERVICENAME%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 상태 조회.
::--------------------------------------------------------------------------------
:status
	echo __SERVICE_STATUS_WINDOWS__

	:: 변수 설정.
	set SERVICENAME=%ARGUMENT_2%

	:: NSSM 설정.
	nssm status %SERVICENAME%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0


::--------------------------------------------------------------------------------
:: 서비스 목록 조회.
::--------------------------------------------------------------------------------
:list
	echo __SERVICE_LIST_WINDOWS__

	:: NSSM 설정.
	nssm list

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

exit /b 0