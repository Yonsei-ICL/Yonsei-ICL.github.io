# Yonsei ICL Paper Reviews

연세대학교 ICL 연구실의 논문 리뷰 블로그입니다.

Based on
(https://www.zerostatic.io/theme/jekyll-atlantic/)

## 📝 새 포스트 추가하기

### 1. Notion에서 HTML 내보내기

1. Notion에서 작성한 논문 리뷰 페이지를 엽니다
2. 우측 상단 `...` 메뉴 클릭 → `내보내기` 선택
3. **내보내기 형식**: `HTML` 선택
4. **모든 하위 콘텐츠 포함**: 체크
5. 다운로드된 ZIP 파일을 압축 해제

### 2. HTML을 Jekyll 포스트로 변환

1. 압축 해제한 HTML 파일을 `Paper_Review/convert_HTML/` 폴더로 드래그
2. 또는 `convert.bat` 파일로 드래그하여 자동 변환
3. 변환된 Markdown 파일이 `Paper_Review/_posts/`에 자동 생성됩니다

**변환 시 자동으로 추출되는 정보:**
- 제목 (title)
- 날짜 (date)
- TL;DR (description)
- 작성자 (authors)
- 키워드 (categories)
- 학회명 (conference)

### 3. 이미지 복사

Notion에서 내보낸 이미지들을 Jekyll 블로그로 복사합니다:

```bash
# Notion 내보내기 폴더의 이미지들을 복사
# 예: Paper_Review/blog/[포스트-제목]/
```

**이미지 경로 구조:**
```
Paper_Review/
└── blog/
    └── [포스트-제목]/
        ├── image1.png
        ├── image2.png
        └── thumbnails/
            └── thumbnail.png
```

### 4. 썸네일 추가 (선택사항)

메인 페이지에 표시될 썸네일 이미지를 추가합니다:

1. `Paper_Review/blog/[포스트-제목]/thumbnails/` 폴더 생성
2. `thumbnail.png` 파일 추가 (권장 크기: 640x360)

썸네일이 없으면 1x1 투명 PNG가 자동으로 사용됩니다.

### 5. 로컬 테스트

```bash
cd Paper_Review
bundle exec jekyll serve
```

브라우저에서 `http://localhost:4000` 접속하여 확인

### 6. GitHub에 업로드

```bash
# 변경사항 추가
git add .

# 커밋
git commit -m "Add: [논문 제목] 리뷰 추가"

# GitHub에 푸시
git push origin main
```

GitHub Actions가 자동으로 빌드하고 배포합니다 (약 1-2분 소요).

## 🎨 포스트 Front Matter 예시

```yaml
---
layout: post
title: "논문 제목"
date: 2026-02-25
authors: ["민영_최", "승환_이"]
categories: ["research", "computer vision"]
conference: "CVPR 2024"
description: "논문의 핵심 내용을 한 줄로 요약"
image: /blog/gradient-cuff.../thumbnails/thumbnail.png
---
```

## 🔧 변환 스크립트 기능

`Paper_Review/convert_HTML/convert_notion.ps1`은 다음을 자동으로 처리합니다:

- ✅ Notion HTML → Jekyll Markdown 변환
- ✅ Front matter 자동 생성
- ✅ 이미지 경로 수정 (`../../blog/[제목]/`)
- ✅ Liquid 템플릿 문법 보호
- ✅ Properties 테이블 제거
- ✅ 썸네일 placeholder 생성
- ✅ Google 이미지 제거
- ✅ Status dot 제거

## 📂 프로젝트 구조

```
Paper_Review/
├── _config.yml              # Jekyll 설정
├── _posts/                  # Jekyll 포스트 (변환된 파일)
├── _layouts/                # 페이지 레이아웃
├── _includes/               # 재사용 컴포넌트
├── assets/                  # CSS, 이미지, JS
├── blog/                    # 블로그 포스트 이미지
├── categories/              # 카테고리 페이지
│   └── research.md
├── collections/_posts/      # Notion에서 변환된 HTML
└── convert_HTML/            # 변환 도구
    ├── convert_notion.ps1
    └── convert.bat
```

## 🏷️ 카테고리 시스템

키워드 배지를 클릭하면 해당 카테고리의 포스트만 필터링됩니다.

**새 카테고리 추가:**

1. `categories/` 폴더에 새 파일 생성 (예: `deep-learning.md`)
2. Front matter 작성:

```yaml
---
layout: category
title: deep-learning
permalink: /category/deep-learning
---
```

## 👤 저자 관리

`_data/authors.yml`에 저자 정보 추가:

```yaml
민영_최:
  name: '최민영'
  image: 'assets/images/author/minyoung-choi.jpg'
```

**주의:** 키는 `이름_성` 형식으로 작성 (underscore 사용)

## 🚀 배포

GitHub Pages를 통해 자동 배포됩니다:

1. `main` 브랜치에 push
2. GitHub Actions 워크플로우 실행 (`.github/workflows/jekyll-ghpages.yml`)
3. Node.js 설치 → npm install → Jekyll build
4. GitHub Pages에 배포

**배포 상태 확인:** Repository → Actions 탭

## 🎨 커스터마이징

### 폰트 변경

`_layouts/default.html`과 `tailwind.config.js`에서 Google Fonts 설정 수정

### 로고 변경

`_config.yml`에서 로고 이미지와 텍스트 수정:

```yaml
logo:
  logo_desktop_image: /assets/images/logo/your-logo.jpg
  logo_desktop_text: "Your <strong>Text</strong>"
```

### 색상 테마

`tailwind.config.js`에서 Tailwind 색상 설정 수정

## ⚙️ 로컬 개발 환경 설정

### 필수 요구사항

- Ruby 2.7+
- Node.js 18+
- Bundler
- npm

### 초기 설정

```bash
# Ruby 패키지 설치
bundle install

# Node.js 패키지 설치
npm install

# Jekyll 서버 실행
bundle exec jekyll serve
```

## 🐛 트러블슈팅

### PostCSS 에러
```bash
npm install
```

### Browserslist 경고
```bash
npx browserslist@latest --update-db
```

### 이미지가 표시되지 않음
- 이미지 경로가 `../../blog/[포스트-제목]/`로 올바른지 확인
- `Paper_Review/blog/` 폴더에 이미지가 있는지 확인

### 카테고리 페이지가 비어있음
- 카테고리 파일의 `title`과 포스트의 `categories` 대소문자 일치 확인
- Jekyll 서버 재시작


---

**Powered by Jekyll + Tailwind CSS + GitHub Pages**


```
bundle install
``` 

To start the Jekyll local development server.

```
bundle exec jekyll serve
``` 

To build the theme.
 
```
bundle exec jekyll build
```

# Important
Our website was built using the following open-source software. 
(https://www.zerostatic.io/theme/jekyll-atlantic/)

We adhere to the license terms of the site as they are.
### Netlify

Use Netlify to deploy this theme. This theme contains a valid and tested `netlify.toml`

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/zerostaticthemes/jekyll-atlantic-theme)

### Github Pages
This theme has been tested to work with Github Pages (and Github Project Pages). When using Github Pages you will need to update the `baseurl` in the `_config.yml` otherwise all the css, images and paths will be broken.

For example the site https://zerostaticthemes.github.io/jekyll-atlantic-theme would have `baseurl: "/jekyll-atlantic-theme/"`

## Extras

### License

- Don't create ports or new versions of this theme without asking me
- You can't re-distribute or re-sell this theme as your own template

### Credits 

- Beautiful royalty free Illustrations by Icons8 - https://icons8.com/illustrations/style--pixeltrue
- Stock images by Unsplash - https://unsplash.com/
- Feature icons by Noun Project - https://thenounproject.com/

### Other Jekyll Themes by Zerostatic

- [Jekyll Serif](https://github.com/zerostaticthemes/jekyll-serif-theme) - Open Source
- [Jekyll Advance](https://www.zerostatic.io/theme/jekyll-advance/) - Premium
- [Jekyll Curate](https://github.com/zerostaticthemes/jekyll-curate) - Premium
- [Jekyll Origin](https://www.zerostatic.io/theme/jekyll-origin/) - Premium

🇦🇺 **Made in Australia** by Robert Austin - Support our work - **Star this repo** ⭐

<a href="https://www.buymeacoffee.com/zerostatic" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
