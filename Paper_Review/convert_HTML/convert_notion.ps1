param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile
)

function Extract-Title {
    param([string]$Content)
    
    if ($Content -match '<title>(.*?)</title>') {
        return $matches[1].Trim()
    }
    
    if ($Content -match '<h1[^>]*>(.*?)</h1>') {
        $title = $matches[1] -replace '<[^>]+>', ''
        return $title.Trim()
    }
    
    return "Untitled"
}

function Extract-Date {
    param([string]$Content)
    
    if ($Content -match '@(\d{4})\S+ (\d{1,2})\S+ (\d{1,2})\S+') {
        $year = $matches[1]
        $month = $matches[2].PadLeft(2, '0')
        $day = $matches[3].PadLeft(2, '0')
        return "$year-$month-$day"
    }
    
    if ($Content -match '<time>(\d{4}-\d{2}-\d{2})') {
        return $matches[1]
    }
    
    return Get-Date -Format "yyyy-MM-dd"
}

function Extract-Description {
    param([string]$Content)
    
    # Extract TL;DR section
    if ($Content -match '<h2[^>]*>TL; DR</h2>.*?<figure[^>]*class="[^"]*callout[^"]*"[^>]*>.*?<div[^>]*>(.*?)</div>\s*</div>\s*</figure>') {
        $desc = $matches[1] -replace '<[^>]+>', ''
        $desc = $desc -replace '&quot;', '"'
        $desc = $desc -replace '&#x27;', "'"
        $desc = $desc -replace '&amp;', '&'
        $desc = $desc.Trim()
        return $desc
    }
    
    return ""
}

function Extract-Person {
    param([string]$Content)
    
    # Extract person name from user-icon
    if ($Content -match 'class="icon user-icon"[^>]*/>([^<]+)</span>') {
        return $matches[1].Trim()
    }
    
    return ""
}

function Extract-Keywords {
    param([string]$Content)
    
    # Extract keywords from multi_select row
    if ($Content -match 'property-row-multi_select[^>]*>.*?<th>.*?keywords</th>\s*<td>(.*?)</td>') {
        $keywordsHtml = $matches[1]
        $keywords = @()
        
        # Extract each keyword span
        $keywordMatches = [regex]::Matches($keywordsHtml, '<span[^>]*>([^<]+)</span>')
        foreach ($match in $keywordMatches) {
            $keyword = $match.Groups[1].Value.Trim()
            if ($keyword -ne "") {
                $keywords += $keyword
            }
        }
        
        return $keywords
    }
    
    return @()
}

function Extract-Conference {
    param([string]$Content)
    
    # Extract conference from conf'yy row
    if ($Content -match 'conf&#x27;yy</th>\s*<td>\s*<span[^>]*>([^<]+)</span>') {
        $conf = $matches[1].Trim()
        $conf = $conf -replace '&#x27;', "'"
        return $conf
    }
    
    return ""
}

function Clean-Filename {
    param([string]$Title)
    
    $cleaned = $Title -replace '[^\w\s-]', ''
    $cleaned = $cleaned -replace '\s+', '-'
    $cleaned = $cleaned.ToLower()
    
    if ($cleaned.Length -gt 100) {
        $cleaned = $cleaned.Substring(0, 100)
    }
    
    return $cleaned
}

try {
    Write-Host "Converting Notion HTML to Jekyll post..." -ForegroundColor Cyan
    
    $content = Get-Content -Path $InputFile -Raw -Encoding UTF8
    
    $title = Extract-Title -Content $content
    $date = Extract-Date -Content $content
    $description = Extract-Description -Content $content
    $person = Extract-Person -Content $content
    $keywords = Extract-Keywords -Content $content
    $conference = Extract-Conference -Content $content
    
    Write-Host "Title: $title" -ForegroundColor Green
    Write-Host "Date: $date" -ForegroundColor Green
    Write-Host "Description: $description" -ForegroundColor Green
    Write-Host "Person: $person" -ForegroundColor Green
    Write-Host "Keywords: $($keywords -join ', ')" -ForegroundColor Green
    Write-Host "Conference: $conference" -ForegroundColor Green
    
    if ($content -match '(?s)</head><body>(.*)') {
        $articleContent = $matches[1]
    } else {
        Write-Warning "Body tag not found. Using entire content."
        $articleContent = $content
    }
    
    # Remove status dots
    $articleContent = $articleContent -replace '<div class="status-dot status-dot-color-[^"]*"></div>', ''
    
    # Remove Google profile images from person property
    $articleContent = $articleContent -replace '<img src="https://lh3\.googleusercontent\.com/[^"]*"\s*class="icon user-icon"/>', ''
    
    # Remove properties table (Person, Status, date, keywords, etc.)
    $articleContent = $articleContent -replace '(?s)<table class="properties">.*?</table>', ''
    
    $filenameBase = Clean-Filename -Title $title
    
    # Create blog image folders (relative to batch file location)
    $paperReviewRoot = Split-Path $PSScriptRoot -Parent
    $blogFolder = Join-Path $paperReviewRoot "blog\$filenameBase"
    $thumbnailFolder = Join-Path $blogFolder "thumbnails"
    
    Write-Host "Creating image folders..." -ForegroundColor Cyan
    New-Item -Path $blogFolder -ItemType Directory -Force | Out-Null
    New-Item -Path $thumbnailFolder -ItemType Directory -Force | Out-Null
    Write-Host "Created: $blogFolder" -ForegroundColor Green
    Write-Host "Created: $thumbnailFolder" -ForegroundColor Green
    
    # Convert image paths (skip absolute URLs like https://)
    $articleContent = $articleContent -replace '(src|href)="(?!https?://)([^"]*\.(png|jpg|jpeg|gif|svg|webp))"', "`$1=`"../../blog/$filenameBase/`$2`""
    $articleContent = $articleContent -replace '(src|href)="(?!https?://)image', "`$1=`"../../blog/$filenameBase/image"
    
    # Always add thumbnail path to front matter (will show blank image until replaced)
    $thumbnailImagePath = "image: /blog/$filenameBase/thumbnails/thumbnail.png`n"
    
    # Create blank thumbnail placeholder
    $blankThumbPath = Join-Path $thumbnailFolder "thumbnail.png"
    if (-not (Test-Path $blankThumbPath)) {
        # Create a 1x1 transparent PNG as placeholder
        $blankPngBytes = [System.Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
        [System.IO.File]::WriteAllBytes($blankThumbPath, $blankPngBytes)
        Write-Host "Created blank thumbnail placeholder" -ForegroundColor Yellow
    }
    
    # Build front matter
    $frontMatter = "---`nlayout: post`ntitle: `"$title`"`ndate: $date`n"
    
    # Add authors if person exists
    if ($person -ne "") {
        $frontMatter += "authors: [`"$person`"]`n"
    }
    
    # Add categories (keywords + research)
    $categories = @("research")
    if ($keywords.Count -gt 0) {
        $categories = $keywords + $categories
    }
    $categoriesStr = ($categories | ForEach-Object { "`"$_`"" }) -join ", "
    $frontMatter += "categories: [$categoriesStr]`n"
    
    # Add conference if exists
    if ($conference -ne "") {
        $frontMatter += "conference: `"$conference`"`n"
    }
    
    # Add description if exists
    if ($description -ne "") {
        $frontMatter += "description: `"$description`"`n"
    }
    
    $frontMatter += "$thumbnailImagePath---`n`n"
    
    $jekyllContent = $frontMatter + $articleContent
    
    $outputFilename = "$date-$filenameBase.html"
    $postsFolder = Join-Path $paperReviewRoot "collections\_posts"
    $outputPath = Join-Path $postsFolder $outputFilename
    
    $jekyllContent | Out-File -FilePath $outputPath -Encoding UTF8 -NoNewline
    
    Write-Host ""
    Write-Host "Conversion completed!" -ForegroundColor Green
    Write-Host "Saved to: $outputPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Copy images to: $blogFolder" -ForegroundColor White
    Write-Host "2. (Optional) Add thumbnail.png to: $thumbnailFolder" -ForegroundColor White
    Write-Host ""
    
    exit 0
    
} catch {
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
