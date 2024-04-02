#!/bin/bash

# Slack 相關設定
SLACK_CHANNEL="git-wts"
SLACK_TOKEN="xoxp-xxx"

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

# 生成四個統計CSV文件

generate_csv() {
    local start_date=$1
    local end_date=$2
    local csv_file_name="${WORK_DIR}/${log_folder}/${start_date}_${end_date}_contributor_stats.csv"
    echo "folder,author,commits,additions,deletions" > $csv_file_name

    # 保存當前目錄位置
    local current_dir=$(pwd)

    for folder in $(find . -type d -name ".git") ; do
        # 進入存儲庫目錄
        cd "$current_dir/$folder"

        # 獲取作者列表
        authors=$(git log --all --since="$start_date" --until="$end_date" --format='%ae' | sort -u)

        # 循環遍歷每個作者
        for author in $authors; do
            # 獲取作者的提交數
            commits=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --oneline | wc -l)

            # 獲取作者新增行數和刪除行數
            additions=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --format='%n' --numstat | awk '{s+=$1} END {print s}')
            deletions=$(git log --all --author="$author" --since="$start_date" --until="$end_date" --format='%n' --numstat | awk '{s+=$2} END {print s}')

            # 列印結果到 CSV 文件
            echo "$folder,$author,$commits,$additions,$deletions" >> $csv_file_name
        done
    done

    # 返回到原始目錄位置
    cd "$current_dir"




# 生成四個統計CSV文件
last_month_csv=$(generate_csv "$first_day_of_last_month" "$last_day_of_last_month")
current_month_csv=$(generate_csv "$first_day_of_current_month" "$today")
last_seven_days_csv=$(generate_csv "$first_day_of_last_seven_days" "$today")
yesterday_csv=$(generate_csv "$yesterday" "$yesterday")

# 上傳CSV文件到Slack
upload_to_slack() {
    local file=$1
    local repo=$2
    local message="Git Log 統計 for ${repo}"

curl -F file=@${file} -F channels=${SLACK_CHANNEL} -F initial_comment="${message}" -H "Authorization: Bearer ${SLACK_TOKEN}" https://slack.com/api/files.upload
}


upload_to_slack "${WORK_DIR}/${log_folder}/${first_day_of_last_month}_${last_day_of_last_month}_contributor_stats.csv" "上個月"
upload_to_slack "${WORK_DIR}/${log_folder}/${first_day_of_current_month}_${today}_contributor_stats.csv" "當月"
upload_to_slack "${WORK_DIR}/${log_folder}/${first_day_of_last_seven_days}_${today}_contributor_stats.csv" "前七日"
upload_to_slack "${WORK_DIR}/${log_folder}/${yesterday}_${yesterday}_contributor_stats.csv" "昨日"
