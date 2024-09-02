#--------------------------------------------------------------------------------
# 참조 모듈 목록.
#--------------------------------------------------------------------------------
from __future__ import annotations
from typing import Any, Final, Callable, Iterator, Optional, Type, TypeVar, Union, Tuple, List, Dict, Set, cast
import builtins
import sys
import time
from dduk.application.application import Application


#--------------------------------------------------------------------------------
# 전역 상수 목록.
#--------------------------------------------------------------------------------



#--------------------------------------------------------------------------------
# 메인 함수.
#--------------------------------------------------------------------------------
def Main(arguments : list[str]) -> int:
	# 프로젝트 이름, 심볼, 인자 반환.
	Application.Log("dduk-application-template")
	Application.Log("# arguments")
	for argument in arguments:
		Application.Log(f"- {argument}")
	symbols : list[str] = Application.GetSymbols()
	Application.Log("# symbols")
	for symbol in symbols:
		Application.Log(f"- {symbol}")


	Application.Log(f"안녕하세요!!")
	return 0