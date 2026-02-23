#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Notion HTML을 Jekyll 포스트로 변환하는 스크립트
사용법: python convert_notion_to_jekyll.py "Notion 파일.html"
"""

import sys
import os
import re
from datetime import datetime

def extract_title(html_content):
    """HTML에서 제목 추출"""
    match = re.search(r'<title>(.*?)</title>', html_content)
    if match:
        return match.group(1).strip()
    
    # title 태그가 없으면 h1에서 찾기
    match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content)
    if match:
        return re.sub(r'<[^>]+>', '', match.group(1)).strip()
    
    return "Untitled"

def extract_date(html_content):
    """HTML에서 날짜 추출 (date property에서)"""
    # @YYYY년 MM월 DD일 형식 찾기
    match = re.search(r'@(\d{4})년 (\d{1,2})월 (\d{1,2})일', html_content)
    if match:
        year, month, day = match.groups()
        return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
    
    # ISO 형식 날짜 찾기
    match = re.search(r'<time>(\d{4}-\d{2}-\d{2})', html_content)
    if match:
        return match.group(1)
    
    # 날짜를 찾지 못하면 오늘 날짜 사용
    return datetime.now().strftime('%Y-%m-%d')

def clean_filename(title):
    """파일명으로 사용 가능한 형태로 변환"""
    # 특수문자 제거 및 공백을 하이픈으로
    cleaned = re.sub(r'[^\w\s가-힣-]', '', title)
    cleaned = re.sub(r'\s+', '-', cleaned)
    cleaned = cleaned.lower()
    return cleaned[:100]  # 파일명 길이 제한

def convert_notion_to_jekyll(input_file):
    """Notion HTML을 Jekyll 포스트로 변환"""
    
    # 파일 읽기
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. 제목과 날짜 추출
    title = extract_title(content)
    date = extract_date(content)
    
    print(f"제목: {title}")
    print(f"날짜: {date}")
    
    # 2. <body> 태그 이후의 내용만 추출
    body_match = re.search(r'</head><body>(.*)', content, re.DOTALL)
    if body_match:
        article_content = body_match.group(1)
    else:
        print("⚠️  <body> 태그를 찾을 수 없습니다. 전체 내용을 사용합니다.")
        article_content = content
    
    # 3. status-dot div 제거
    article_content = re.sub(
        r'<div class="status-dot status-dot-color-[^"]*"></div>',
        '',
        article_content
    )
    
    # 4. Jekyll front matter 생성
    front_matter = f"""---
layout: post
title: "{title}"
date: {date}
categories: [research]
---

"""
    
    # 5. 최종 내용 조합
    jekyll_content = front_matter + article_content
    
    # 6. 출력 파일명 생성
    filename_base = clean_filename(title)
    output_filename = f"{date}-{filename_base}.html"
    output_path = os.path.join(
        'Paper_Review', 'collections', '_posts', 
        output_filename
    )
    
    # 7. 파일 저장
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(jekyll_content)
    
    print(f"\n✅ 변환 완료!")
    print(f"📁 저장 위치: {output_path}")
    
    return output_path

def main():
    if len(sys.argv) < 2:
        print("사용법: python convert_notion_to_jekyll.py <Notion HTML 파일>")
        print("\n예시:")
        print('  python convert_notion_to_jekyll.py "Paper_Review/collections/_posts/A Probabilistic Perspective on Unlearning and Alig.html"')
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    if not os.path.exists(input_file):
        print(f"❌ 파일을 찾을 수 없습니다: {input_file}")
        sys.exit(1)
    
    try:
        output_path = convert_notion_to_jekyll(input_file)
        
        print("\n다음 단계:")
        print("  1. 원본 Notion 파일 삭제 (선택사항)")
        print("  2. Jekyll 빌드: bundle exec jekyll build")
        print("  3. 브라우저에서 Ctrl+Shift+R로 새로고침")
        
    except Exception as e:
        print(f"❌ 변환 중 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
