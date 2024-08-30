#--------------------------------------------------------------------------------
# 참조 모듈 목록.
#--------------------------------------------------------------------------------
from __future__ import annotations
from typing import Any, Final, Callable, Iterator, Optional, Type, TypeVar, Union, Tuple, List, Dict, Set, cast
import builtins
import sys
from dduk.application.testslauncher import TestsLauncher


#--------------------------------------------------------------------------------
# 파일 진입점.
#--------------------------------------------------------------------------------
if __name__ == "__main__":
	try:
		# builtins.print("__TESTS_LAUNCH_START__")
		launcher = TestsLauncher()
		exitcode = launcher.Launch()
		# builtins.print("__TESTS_LAUNCH_END__")
		sys.exit(exitcode)
	except KeyboardInterrupt as exception:
		# builtins.print("__TESTS_LAUNCH_END__")
		sys.exit(0)
	except Exception as exception:
		builtins.print("__TESTS_LAUNCH_FAILURE__")
		builtins.print(exception)	