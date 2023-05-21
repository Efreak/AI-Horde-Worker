@echo off
cd /d "%~dp0"

:Isolation
SET CONDA_SHLVL=
SET PYTHONNOUSERSITE=1
SET PYTHONPATH=

setlocal EnableDelayedExpansion
for %%a in (%*) do (
    if /I "%%a"=="--hordelib" (
        set hordelib=true
    ) else (
        set hordelib=
    )
    if /I "%%a"=="--scribe" (
        set scribe=true
    ) else (
        set scribe=
    )
)
endlocal

if defined scribe (
  SET CONDA_ENVIRONMENT_FILE=environment_scribe.yaml

) else (
  SET CONDA_ENVIRONMENT_FILE=environment.yaml
)

Reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f 2>nul
:We do this twice the first time to workaround a conda bug where pip is not installed correctly the first time - Henk
IF EXIST CONDA GOTO WORKAROUND_END
umamba create --no-shortcuts -r conda -n windows -f %CONDA_ENVIRONMENT_FILE% -y
:WORKAROUND_END
umamba create --no-shortcuts -r conda -n windows -f %CONDA_ENVIRONMENT_FILE% -y

REM Check if hordelib argument is defined
if defined hordelib (
  umamba run -r conda -n windows python -s -m pip uninstall -y hordelib horde_model_reference
  umamba run -r conda -n windows python -s -m pip install hordelib horde_model_reference
) else (
  if defined scribe (
    umamba run -r conda -n windows python -s -m pip install -r requirements-scribe.txt
  ) else (
    umamba run -r conda -n windows python -s -m pip uninstall nataili
    umamba run -r conda -n windows python -s -m pip install -r requirements.txt
  )
)

echo If there are no errors above everything should be correctly installed (If not, try deleting the folder /conda/envs/ and try again).
