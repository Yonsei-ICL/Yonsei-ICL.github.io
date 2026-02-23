# Notion → Jekyll 변환 가이드

## 🚀 빠른 사용법

### 1단계: Notion에서 HTML 내보내기
1. Notion 페이지 우측 상단 `...` → `내보내기`
2. 형식: **HTML** 선택
3. `Paper_Review/collections/_posts/` 폴더에 저장

### 2단계: Python 스크립트로 변환
```bash
# 기본 사용
python convert_notion_to_jekyll.py "Paper_Review/collections/_posts/파일명.html"

# 예시
python convert_notion_to_jekyll.py "Paper_Review/collections/_posts/A Probabilistic Perspective on Unlearning and Alig.html"
```

### 3단계: Jekyll 빌드 및 확인
```bash
bundle exec jekyll build
# 또는 서버 실행 중이면 자동 빌드됨
```

브라우저에서 `Ctrl+Shift+R`로 강력 새로고침

---

## 📋 자동 처리되는 항목

✅ HTML/CSS 래퍼 제거 (700+ 줄)  
✅ Jekyll front matter 자동 추가  
✅ 제목 자동 추출  
✅ 날짜 자동 추출 (date property에서)  
✅ 파일명 자동 생성 (YYYY-MM-DD-제목.html)  
✅ Status dot 중복 제거  
✅ 한글 파일명 지원  

---

## 🔧 고급 사용법

### 한 번에 여러 파일 변환 (PowerShell)
```powershell
Get-ChildItem "Paper_Review/collections/_posts/*.html" | 
    Where-Object { $_.Name -notmatch '^\d{4}-\d{2}-\d{2}' } | 
    ForEach-Object { python convert_notion_to_jekyll.py $_.FullName }
```

### 변환 후 원본 파일 자동 삭제
```bash
python convert_notion_to_jekyll.py "파일.html" && rm "파일.html"
```

---

## 🎯 스크립트가 하는 일

1. **HTML 파싱**: `<title>` 또는 `<h1>`에서 제목 추출
2. **날짜 추출**: 
   - Notion date property (`@2025년 11월 26일`)
   - ISO 형식 (`2025-11-26`)
   - 없으면 오늘 날짜 사용
3. **내용 추출**: `</head><body>` 이후의 `<article>` 내용만 추출
4. **정리**:
   - `<div class="status-dot ..."></div>` 제거
   - HTML/CSS wrapper 제거
5. **Jekyll front matter 생성**:
   ```yaml
   ---
   layout: post
   title: "제목"
   date: YYYY-MM-DD
   categories: [research]
   ---
   ```
6. **파일 저장**: `YYYY-MM-DD-제목.html` 형식으로 저장

---

## ❓ 문제 해결

### Python이 없는 경우
```bash
# Windows에서 Python 설치 확인
python --version

# 없으면 다운로드: https://www.python.org/downloads/
```

### 날짜가 자동 추출되지 않는 경우
- Notion에서 **date** property를 추가하고 값을 설정하세요
- 또는 오늘 날짜로 자동 설정됩니다

### 파일명이 이상한 경우
- 제목에 특수문자가 많으면 자동으로 정리됩니다
- 원하는 파일명으로 수동 변경 가능

---

## 💡 팁

1. **Notion 파일명은 상관없음**: 스크립트가 내용에서 제목/날짜를 추출
2. **원본 파일 보관**: 변환 확인 후 삭제 권장
3. **Jekyll 서버 실행 중**: 자동으로 재빌드되어 바로 확인 가능
4. **이미지 포함**: Notion 이미지도 그대로 포함됨

---

## 📝 변환 전/후 비교

### 변환 전 (Notion HTML)
```html
<html>
<head>
<title>A Probabilistic Perspective...</title>
<style>
/* 700 lines of CSS */
...
</style>
</head>
<body>
<article>...</article>
</body>
</html>
```

### 변환 후 (Jekyll Post)
```html
---
layout: post
title: "A Probabilistic Perspective..."
date: 2025-11-26
categories: [research]
---

<article>...</article>
```

---

## 🆘 도움이 필요하면

```bash
python convert_notion_to_jekyll.py
# 사용법이 출력됩니다
```
