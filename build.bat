@echo off
:: chcp 65001 >nul
::------------------------------------------------------------------------
:: 빌드 관련 통합 배치 파일. (Windows 전용)
::------------------------------------------------------------------------
echo __BUILD_WINDOWS__

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
	set TEXT=Usage: %EXECUTEFILENAME% {clear^|binary^|archive^|distribution}
	echo !TEXT!
	set TEXT=build clear: 빌드 폴더 비우기 명령
	echo !TEXT!
	set TEXT=build binary: 실행 가능한 바이너리 빌드 명령
	echo !TEXT!
	set TEXT=build archive: 아카이브 빌드 명령
	echo !TEXT!
	set TEXT=build distribution: PYPI 아카이브 배포 명령
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
:: 빌드 폴더 정리.
::--------------------------------------------------------------------------------
:clear
	echo __BUILD_CLEAR_WINDOWS__

	:: 빌드 전 폴더 정리.
	for /f "delims=" %%I in ('dir "%BUILDPATH%" /a /b /s') do (
		if /i not "%%~NXI" == ".gitkeep" (
			if exist "%%I\" (
				rd /s /q "%%I"
				call echo REMOVEDIRECTORY: "%%I"
			) else if exist "%%I" (
				del /f /q "%%I"
				call echo REMOVEFILE: "%%I"
			)
		)
	)
exit /b 0


::--------------------------------------------------------------------------------
:: 실행 가능한 바이너리 파일 빌드. (.EXE)
::--------------------------------------------------------------------------------
:binary
	echo __BUILD_BINARY_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 빌드 전 처리 실행.
	python "%SOURCEPATH%\__prepare__.py" "binary"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	echo SOURCEPATH: "%SOURCEPATH%"
	echo RESOURCEPATH: "%RESOURCEPATH%"
	echo APPLICATIONDATAMETAPATH: "%APPLICATIONDATAMETAPATH%"
	echo BUILDBINPATH: "%BUILDBINPATH%"
	echo BUILDSPECPATH: "%BUILDSPECPATH%"
	echo BUILDWORKPATH: "%BUILDWORKPATH%"
	echo BUILDNAME: "%BUILDNAME%"
	echo HOOKSPATH: "%HOOKSPATH%"

	:: 빌드 생성.
	set BUILD=python -m PyInstaller ^
	-F --clean^
	--paths="%SOURCEPATH%" ^
	--paths="%RESOURCEPATH%" ^
	--paths="%APPLICATIONDATAMETAPATH%" ^
	--collect-all=src ^
	--add-data "%SOURCEPATH%;src" ^
	--add-data "%RESOURCEPATH%;res" ^
	--add-data "%APPLICATIONDATAMETAPATH%;meta" ^
	--distpath "%BUILDBINPATH%" ^
	--specpath "%BUILDSPECPATH%" ^
	--workpath "%BUILDWORKPATH%" ^
	--name "%BUILDNAME%" ^
	--additional-hooks-dir="%HOOKSPATH%" ^
	--onefile "%SOURCEPATH%\__launch__.py" ^
	--noconfirm

	:: 콘솔창 설정.
	if "%IS_BUILD_BIN_NOCONSOLE%" == "true" (
		echo IS_BUILD_BIN_NOCONSOLE
		set BUILD=%BUILD% --noconsole
	)

	:: 디버그 정보 포함 설정.
	if "%IS_BUILD_BIN_DEBUGINFO%" == "true" (
		echo IS_BUILD_BIN_DEBUGINFO
		set BUILD=%BUILD% -D
	)

	:: 빌드 실행.
	%BUILD%

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 디버그 정보 포함 설정.
	:: 임시 폴더 제거.
	if "%IS_BUILD_BIN_DEBUGINFO%" == "true" (
		move /y "%BUILDBINDEBUGPATH%\%ROOTNAME%.exe" "%BUILDBINPATH%\%ROOTNAME%.exe"
		rmdir /s /q "%BUILDBINDEBUGINTERNALPATH%"
	)
exit /b 0


::--------------------------------------------------------------------------------
:: 배포 파일 빌드. (아카이브 파일: tar.gz, 휠 파일: .whl)
::--------------------------------------------------------------------------------
:archive
	echo __BUILD_ARCHIVE_WINDOWS__

	:: 가상환경 생성 ==> 활성화 ==> 업데이트.
	call "venv.bat" update

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 빌드 전 처리 실행.
	:: python "%SOURCEPATH%\__prepare__.py" "binary"

	:: 오류가 있으면 실패.
	:: if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 빌드 전 청소.
	call :clear

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 아카이브 파일 빌드. (*.tar.gz)
	:: 같이 생성되는 *.egg.info 폴더는 패키지 설치에 관련된 메타 데이터로 아카이브 파일을 만드는데 사용됨.
	python setup.py sdist -d "%BUILDPATH%" --formats=gztar

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 휠 파일 빌드. (.whl)
	:: 같이 생성되는 *.egg.info 폴더는 패키지 설치에 관련된 메타 데이터로 휠 파일을 만드는데 사용됨.
	:: 특정 플랫폼 종속적인 라이브러리 사용만 안하면 none-any로 빌드되며 모든 플랫폼에서 동작됨.
	python setup.py bdist_wheel -d "%BUILDPATH%"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: *.egg.info 이동. (소스 ==> 빌드)
	:: 도착 경로 뒤에 \를 붙여 도착 빌드 경로의 자식이 되게끔 이동.
	move /y "%BUILDEGGINFOPATH%" "%BUILDPATH%\"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )

	:: 쓸모 없는 폴더 제거.
	if exist "%BUILDPATH%\bdist.win-amd64" ( rd /q /s "%BUILDPATH%\bdist.win-amd64" )
	if exist "%BUILDPATH%\lib" ( rd /q /s "%BUILDPATH%\lib" )

    echo "%BUILDPATH%\%EGGINFONAME%"
	if exist "%BUILDPATH%\%EGGINFONAME%" ( rd /q /s "%BUILDPATH%\%EGGINFONAME%" )
exit /b 0


::--------------------------------------------------------------------------------
:: PYPI 배포.
::--------------------------------------------------------------------------------
:distribution
	echo __BUILD_DISTRIBUTION_WINDOWS__
	
	:: 인증서 파일이 없을 경우 실패.
	if not exist "%PYPIRCFILEPATH%" (
		echo ".pypirc not found."
		exit /b 1
	)

	:: 아카이브.
	call :archive

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
	
	:: 아카이브 파일 배포.
	:: 레포지토리 인증키 (C:\Users\{사용자이름}\.pypirc) 생성 필요.
	:: 레포지토리 인증키에 설정된 배포 될 저장소 이름. (pypi)
	:: 아카이브 파일, 휠 파일 둘 다 올려야 일반 사용자들이 정상적으로 설치할 수 있음.
	twine upload -r pypi "%BUILDPATH%\*.tar.gz" "%BUILDPATH%\*.whl"

	:: 오류가 있으면 실패.
	if not %errorlevel% equ 0 ( exit /b %errorlevel% )
exit /b 0