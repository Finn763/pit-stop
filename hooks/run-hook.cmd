: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for the L2 guardrail: cmd.exe finds bash on
REM Windows, sh/bash runs the script on Unix. Hook commands point at this file
REM instead of a .sh path, because Claude Code on Windows prepends "bash" to any
REM hook command containing ".sh" (which would make "bash bash ...").
REM
REM Usage: run-hook.cmd <script-name>   -- the script name has no extension.
REM Adapted from obra/superpowers hooks/run-hook.cmd (MIT), with a different
REM missing-bash policy: pit-stop warns instead of passing silently.

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

setlocal
set "HOOK_DIR=%~dp0"
set "BASH_EXE="

REM System-wide Git for Windows.
if exist "C:\Program Files\Git\bin\bash.exe" set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
if not defined BASH_EXE if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "BASH_EXE=C:\Program Files (x86)\Git\bin\bash.exe"

REM Per-user Git for Windows (no admin rights). The defined-check matters: with
REM LOCALAPPDATA unset the path collapses to \Programs\Git\... on the current
REM drive, where any user can create it.
if not defined BASH_EXE if defined LOCALAPPDATA if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "BASH_EXE=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"

REM bash on PATH. where.exe is called by full path and with $PATH: so neither it
REM nor bash can come from the current directory. Skips extensionless matches and
REM the WSL launchers (System32, Sysnative, the Store alias in WindowsApps), which
REM fail when no Linux distro is installed.
if not defined BASH_EXE if defined SystemRoot for /f "delims=" %%B in ('"%SystemRoot%\System32\where.exe" $PATH:bash 2^>nul') do if not defined BASH_EXE if not "%%~xB"=="" if /i not "%%~dpB"=="%SystemRoot%\System32\" if /i not "%%~dpB"=="%SystemRoot%\Sysnative\" if /i not "%%~dpB"=="%LOCALAPPDATA%\Microsoft\WindowsApps\" set "BASH_EXE=%%B"

REM No bash, no guardrail. Blocking every Bash call would stop the session, so
REM warn loudly and let the call through. README states L2 is inactive here.
if not defined BASH_EXE (
    echo pit-stop: no bash found, so the L2 destructive-command guard is NOT active >&2
    exit /b 0
)

REM Run outside any parenthesized block: cmd expands %ERRORLEVEL% when it parses
REM the block, which would drop the hook's exit code 2.
"%BASH_EXE%" "%HOOK_DIR%%~1"
exit /b %ERRORLEVEL%
CMDBLOCK

# Unix: run the named script, splitting $0 on its last / or \ (cmd passes
# Windows paths) instead of calling dirname. $BASH is bash's own absolute path
# and is set whenever the harness already ran this file with bash.
if [ -z "$1" ]; then
  echo "run-hook.cmd: missing script name" >&2
  exit 1
fi
case "$0" in
  */*|*\\*) SCRIPT_DIR="$(cd "${0%[/\\]*}" && pwd)" ;;
  *) SCRIPT_DIR="$(pwd)" ;;
esac
exec "${BASH:-bash}" "${SCRIPT_DIR}/$1"
