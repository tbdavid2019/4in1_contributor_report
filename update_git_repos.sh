#!/bin/bash

# 設定目錄為包含所有 repos 的根目錄
cd /home/david/git
CUR_DIR=$(pwd)

# 提示腳本開始運行
echo "正在更新所有 repositories 為遠端版本..."

# 找到所有 Git repositories 並進行強制更新
for i in $(find . -name ".git" | cut -c 3-); do
    echo ""
    echo "正在處理 repository: $i"

    # 檢查 repository 是否損壞
    if [ ! -d "$i/objects" ] || [ ! -f "$i/HEAD" ]; then
        echo "跳過損壞的 repository: $i"
        continue
    fi

    # 進入 .git 父目錄
    cd "$i"
    cd ..

    # 檢查當前分支
    CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # 嘗試修復 repository
    echo "執行 git fsck 修復檢查..."
    git fsck --full || echo "檢測到損壞的 repository，繼續執行修復步驟。"

    # 清理無效物件
    echo "執行 git gc 清理..."
    git gc --prune=now --aggressive

    # 確保清理任何本地改動和未追蹤的文件
    echo "清理本地變更..."
    git reset --hard
    git clean -fd

    # 拉取遠端更新並強制同步
    echo "同步遠端更新..."
    git fetch --all
    git reset --hard "origin/$CUR_BRANCH" || echo "遠端分支 $CUR_BRANCH 不存在，跳過。"

    # 如果需要同步所有分支
    echo "同步所有分支..."
    git branch | tr '*' ' ' | while read -r branch; do
        if [ -n "$branch" ]; then
            git checkout "$branch"
            git reset --hard "origin/$branch" || echo "遠端分支 $branch 不存在，跳過。"
        fi
    done

    # 返回當前分支
    git checkout "$CUR_BRANCH"

    # 回到根目錄
    cd "$CUR_DIR"
done

echo "完成！所有 repositories 已同步為遠端版本。"
