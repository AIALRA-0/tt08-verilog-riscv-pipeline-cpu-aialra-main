@echo off
setlocal

powershell -WindowStyle Hidden -Command "wsl -e /bin/bash -c 'gtkwave tb.vcd >/dev/null 2>&1'"

endlocal
