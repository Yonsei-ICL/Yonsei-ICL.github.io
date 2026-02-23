# Notion HTML을 Jekyll post로 변환하는 스크립트
# 사용법: .\convert_notion_to_jekyll.ps1 "notion_export.html"

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile
)

if (-not (Test-Path $InputFile)) {
    Write-Error "파일을 찾을 수 없습니다: $InputFile"
    exit 1
}

Write-Host "변환 중: $InputFile" -ForegroundColor Cyan

# 파일 읽기
$content = Get-Content $InputFile -Raw -Encoding UTF8

# 1. <body> 태그 제거
$content = $content -replace '<body[^>]*>', ''
$content = $content -replace '</body>', ''

# 2. 중복 status dot 제거 (nested div 제거)
$content = $content -replace '<div class="status-dot status-dot-color-[^"]*"></div>', ''

# 3. <html>, <head> 태그 제거 (전체 문서 구조 제거)
$content = $content -replace '<!DOCTYPE[^>]*>', ''
$content = $content -replace '<html[^>]*>', ''
$content = $content -replace '</html>', ''
$content = $content -replace '<head>[\s\S]*?</head>', ''

# 4. 파일명에서 날짜 추출 (YYYY-MM-DD 형식)
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
if ($fileName -match '(\d{4}-\d{2}-\d{2})') {
    $date = $matches[1]
} else {
    $date = Get-Date -Format "yyyy-MM-dd"
    Write-Warning "파일명에서 날짜를 찾을 수 없어 오늘 날짜를 사용합니다: $date"
}

# 5. 출력 파일 경로 설정
$outputDir = "collections\_posts"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$outputFile = Join-Path $outputDir $fileName
if ($outputFile -notmatch '\.html$') {
    $outputFile += '.html'
}

# 6. Jekyll front matter 추가 (기존 파일에서 front matter가 있는지 확인)
if ($content -notmatch '^---[\s\S]*?---') {
    Write-Host "Jekyll front matter를 추가해야 합니다. 제목을 입력하세요:" -ForegroundColor Yellow
    $title = Read-Host "제목"
    
    $frontMatter = @"
---
layout: post
title: "$title"
date: $date
categories: []
---

"@
    $content = $frontMatter + $content
}

# 7. 파일 저장
$content | Set-Content $outputFile -Encoding UTF8 -NoNewline

Write-Host "`n✓ 변환 완료!" -ForegroundColor Green
Write-Host "출력 파일: $outputFile" -ForegroundColor Green
Write-Host "`n변환된 내용:" -ForegroundColor Cyan
Write-Host "- <body> 태그 제거됨" -ForegroundColor Gray
Write-Host "- <html>, <head> 태그 제거됨" -ForegroundColor Gray
Write-Host "- 중복 status-dot 제거됨" -ForegroundColor Gray
Write-Host "- Jekyll front matter 확인/추가됨" -ForegroundColor Gray
