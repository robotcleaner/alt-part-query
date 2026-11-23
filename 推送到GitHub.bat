@echo off
title Push to GitHub
cd /d "%~dp0"

cls
echo ============================================
echo   Push frontend to GitHub Pages
echo ============================================
echo.

REM 检查 git
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] git not found. Please install Git first:
    echo         https://git-scm.com/download/win
    pause
    exit /b 1
)

if not exist ".git" (
    echo [1/4] Init git repo...
    git init
    git branch -M main
) else (
    echo [1/4] Git repo exists
)

echo.
echo [2/4] Set remote...
set /p REPO_URL=Enter your GitHub repo URL (e.g. https://github.com/username/alt-part-query.git): 

if "%REPO_URL%"=="" (
    echo [ERROR] Repo URL is required
    pause
    exit /b 1
)

git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

echo.
echo [3/4] Commit files...
git add .
git commit -m "Add alt part query frontend"

echo.
echo [4/4] Push...
git push -u origin main --force

echo.
echo ============================================
echo   Done
echo ============================================
echo.
echo Now enable GitHub Pages:
echo   1. Open your repo on github.com
echo   2. Settings - Pages
echo   3. Source: Deploy from a branch
echo   4. Branch: main   Folder: / (root)
echo   5. Click Save, wait 1-2 minutes
echo.
echo Your page will be at:
echo   https://YOUR-USERNAME.github.io/REPO-NAME/
echo.
pause
