#!/bin/bash
# 計算本folder下方所有 git repo 的作者貢獻。包含所有分支內容

# 自動抓本月區間 
first_day=$(date "+%Y-%m-01")
today=$(date "+%Y-%m-%d")
csv_file="${today}_this_month_all_branch.csv"
echo "repo,author,commits,additions,deletions" > "$csv_file"

for dir in */; do
    if [ -d "${dir}.git" ]; then
        cd "$dir"
        echo "Updating repo: $dir ..."
        git pull --all

        authors=$(git log --all --since="$first_day" --until="$today" --format='%ae' | sort | uniq)
        for author in $authors; do
            commits=$(git log --all --author="$author" --since="$first_day" --until="$today" --oneline | wc -l)
            additions=$(git log --all --author="$author" --since="$first_day" --until="$today" --numstat | awk '{if($1 ~ /^[0-9]+$/) s+=$1} END {print s+0}')
            deletions=$(git log --all --author="$author" --since="$first_day" --until="$today" --numstat | awk '{if($2 ~ /^[0-9]+$/) s+=$2} END {print s+0}')
            echo "${dir%/},$author,$commits,$additions,$deletions" >> "../$csv_file"
        done
        cd ..
    fi
done

echo "統計完成，請查看 $csv_file"
