#--------------------------------------------------------------------------------
# 참조 모듈 목록.
#--------------------------------------------------------------------------------
from __future__ import annotations
from typing import Any, Final, Callable, Iterator, Optional, Type, TypeVar, Union, Tuple, List, Dict, Set, cast
import builtins
import os
import sys
import unittest
from dduk.core.repository import Repository
from dduk.utility import strutility
from src import __main__ as srcmain


#--------------------------------------------------------------------------------
# 유닛테스트.
#--------------------------------------------------------------------------------
class Test(unittest.TestCase):
	#--------------------------------------------------------------------------------
	# 유닛테스트.
	#--------------------------------------------------------------------------------
	def test_Main(self):
		timestamp = strutility.GetTimestampString()
		builtins.print(timestamp)
		currentFilePath : str = os.path.abspath(__file__)

		path, name, extension = strutility.GetSplitFilePath(currentFilePath)
		builtins.print(f"path: {path}, name: {name}, extension: {extension}")

		srcmain.Main(sys.argv)