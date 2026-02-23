@echo off
chcp 65001 > nul
echo ========================================
echo   Notion to Jekyll Converter
echo ========================================
echo.

REM 파일을 드래그앤드롭하거나 인자로 전달
if "%~1"=="" (
    echo 사용법: Notion HTML 파일을 이 파일에 드래그앤드롭 하세요!
    pause
    exit /b
)

set "INPUT_FILE=%~1"
set "FILENAME=%~n1"
set "OUTPUT_DIR=Paper_Review\collections\_posts"

echo 📂 입력 파일: %FILENAME%
echo.

REM PowerShell 스크립트 호출
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0convert_notion.ps1" "%INPUT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ 변환 완료!
    echo.
    echo 📁 현재 폴더에 생성됨
    echo.
    echo 다음 단계:
    echo   1. 생성된 HTML 파일을 Paper_Review\collections\_posts\ 폴더로 이동
    echo   2. 이미지 파일을 blog\{제목}\ 폴더에 복사
    echo   3. bundle exec jekyll build
    echo.
) else (
    echo.
    echo ❌ 변환 실패
    echo.
)

pause
