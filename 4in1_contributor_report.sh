#!/bin/bash

# Slack 相關設定
SLACK_CHANNEL="git-others"
SLACK_TOKEN="xoxp- "

# 獲取日期區間
today=$(date "+%Y-%m-%d")
first_day_of_last_month=$(date -d "last month" "+%Y-%m-01")
last_day_of_last_month=$(date -d "$first_day_of_last_month +1 month -1 day" "+%Y-%m-%d")
first_day_of_current_month=$(date "+%Y-%m-01")
first_day_of_last_seven_days=$(date -d "7 days ago" "+%Y-%m-%d")
yesterday=$(date -d "yesterday" "+%Y-%m-%d")

# 創建 log 資料夾（如果不存在）
WORK_DIR="/home/david/git"
log_folder="logs4in1"
mkdir -p ${WORK_DIR}/${log_folder}

# 日誌文件
log_file="${WORK_DIR}/${log_folder}/script_debug.log"
echo "開始執行腳本: $(date)" > "$log_file"

# 生成四個統計CSV文件
generate_csv() {
    local start_date=$1
    local end_date=$2
    local csv_file_name="${WORK_DIR}/${log_folder}/${start_date}_${end_date}_contributor_stats.csv"
    echo "folder,author,commits,additions,deletions" > $csv_file_name

    # 保存當前目錄位置
    local current_dir=$(pwd)

    for folder in $(find . -type d -name ".git"); do
        echo "處理 repository: $folder" | tee -a "$log_file"
        cd "$current_dir/$folder" || { echo "無法進入目錄: $folder" | tee -a "$log_file"; continue; }

        # 檢查 repository 是否損壞
        if [ ! -d "objects" ] || [ ! -f "HEAD" ]; then
            echo "損壞的 repository，跳過: $folder" | tee -a "$log_file"
            continue
        fi
        # 檢查是否有錯誤
        git fsck --full > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "檢測到損壞的 repository: $folder，跳過" | tee -a "$log_file"
            continue
        fi

        # 獲取作者列表
        authors=$(git log --all --since="$start_date" --until="$end_date" --format='%ae' | sort -u)
        if [ -z "$authors" ]; then
            echo "無作者數據，跳過: $folder" | tee -a "$log_file"
            continue
        fi

        # 循環遍歷每個作者
        for author in $authors; do
            echo "處理作者: $author" | tee -a "$log_file"

            # 獲取作者的提交數
            commits=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --oneline | wc -l)

            # 獲取作者新增行數和刪除行數
            additions=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --numstat | awk '{s+=$1} END {print s}')
            deletions=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --numstat | awk '{s+=$2} END {print s}')

            # 如果數據為空，則記錄錯誤並繼續
            if [ -z "$commits" ] || [ -z "$additions" ] || [ -z "$deletions" ]; then
                echo "無法獲取數據: $folder, 作者: $author" | tee -a "$log_file"
                continue
            fi

            # 打印結果到 CSV 文件
            echo "$folder,$author,$commits,$additions,$deletions" >> $csv_file_name
        done
    done

    # 返回到原始目錄位置
    cd "$current_dir" || exit
}


# 生成四個統計CSV文件
cross_month_csv=$(generate_csv "2024-01-01" "2024-12-31")

# 上傳CSV文件到Slack
upload_to_slack() {
    local file=$1
    local repo=$2
    local message="Git Log 統計 for ${repo}"

    curl -F file=@${file} -F channels=${SLACK_CHANNEL} -F initial_comment="${message}" -H "Authorization: Bearer ${SLACK_TOKEN}" https://slack.com/api/files.upload
}

upload_to_slack "${WORK_DIR}/${log_folder}/2024-01-01_2024-12-31_contributor_stats.csv" "2024年貢獻統計"

# 打印完成消息
echo "完成執行腳本: $(date)" | tee -a "$log_file"


# 上傳CSV文件到Slack
upload_to_slack() {
    local file=$1
    local repo=$2
    local message="Git Log 統計 for ${repo}"

    curl -F file=@${file} -F channels=${SLACK_CHANNEL} -F initial_comment="${message}" -H "Authorization: Bearer ${SLACK_TOKEN}" https://slack.com/api/files.upload
}

upload_to_slack "${WORK_DIR}/${log_folder}/2024-01-01_2024-12-31_contributor_stats.csv" "2024年貢獻統計"

# 打印完成消息
echo "完成執行腳本
