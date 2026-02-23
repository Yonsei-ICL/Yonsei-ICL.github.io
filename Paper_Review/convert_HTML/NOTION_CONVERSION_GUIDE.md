# Notion to Jekyll 변환 가이드

Notion에서 export한 HTML 파일을 Jekyll 블로그 post로 자동 변환하는 스크립트입니다.

## 문제점

Notion HTML export는 완전한 HTML 문서(`<html>`, `<head>`, `<body>`)로 되어 있어 Jekyll에서 그대로 사용하면:
1. **중첩된 body 태그** - Jekyll layout이 이미 body를 제공하므로 충돌
2. **중복 상태 표시점** - Notion의 Status 속성에 불필요한 `<div class="status-dot">` 포함
3. **완전한 문서 구조** - Jekyll은 content만 필요하므로 외부 HTML 구조 제거 필요

## 사용법

### 1. 스크립트 실행

```powershell
.\convert_notion_to_jekyll.ps1 "다운로드한_notion_파일.html"
```

### 2. 제목 입력

프롬프트가 나오면 블로그 post 제목을 입력하세요.

### 3. 확인

`collections\_posts\` 폴더에 변환된 파일이 생성됩니다.

## 자동 처리 항목

✓ `<body>`, `</body>` 태그 제거  
✓ `<html>`, `<head>`, `<!DOCTYPE>` 제거  
✓ 중복 status-dot div 제거  
✓ Jekyll front matter 추가 (없는 경우)  
✓ 파일명에서 날짜 자동 추출

## 예시

**변환 전 (Notion export):**
```html
<!DOCTYPE html>
<html>
<head>...</head>
<body>
  <article>
    <span class="status-value">
      <div class="status-dot status-dot-color-green"></div>
      Done
    </span>
  </article>
</body>
</html>
```

**변환 후 (Jekyll post):**
```html
---
layout: post
title: "제목"
date: 2026-01-21
---

<article>
  <span class="status-value">Done</span>
</article>
```

## 참고

- Notion export 파일명은 `YYYY-MM-DD-title.html` 형식 권장
- 날짜가 없으면 오늘 날짜 사용
- CSS는 Jekyll theme에서 처리되므로 제거됨
