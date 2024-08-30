@echo off
:: chcp 65001 >nul
:: #------------------------------------------------------------------------
:: # 가상 환경 업데이트 확장. (Windows)
:: #------------------------------------------------------------------------
echo __VENV_UPDATE_OVERRIDE_WINDOWS__

:: 독립 실행 방지.
if not defined IS_VENV_UPDATE_OVERRIDE ( 
	echo This batch file cannot be executed.
	exit /b 1
)