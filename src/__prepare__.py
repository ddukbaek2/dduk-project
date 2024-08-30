#--------------------------------------------------------------------------------
# 참조 모듈 목록.
#--------------------------------------------------------------------------------
from __future__ import annotations
from typing import Any, Final, Callable, Iterator, Optional, Type, TypeVar, Union, Tuple, List, Dict, Set, cast
import builtins
import sys
from dduk.application.preparer import Preparer
from dduk.application.executetype import ExecuteType


#--------------------------------------------------------------------------------
# 파일 진입점.
#--------------------------------------------------------------------------------
if __name__ == "__main__":
	try:
		# builtins.print("__PREPARE_START__")

		# 반드시 1개의 인자가 필요.
		if not sys.argv:
			raise Exception("A required argument is missing.")

		# 애플리케이션 실행 종류로 변환.
		executeType : ExecuteType = ExecuteType.ToValue(sys.argv[1])

		# 실행 준비 처리기 실행.
		# C:\ProgramData\dduk-python\dduk-application\{프로젝트루트디렉터리이름}\meta\manifest.yaml
		preparer = Preparer()
		preparer.Prepare(executeType)
		# builtins.print("__PREPARE_END__")
	except Exception as exception:
		builtins.print("__PREPARE_FAILURE__")
		builtins.print(exception)