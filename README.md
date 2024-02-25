# 4in1_contributor_report
計算團隊 git 的 代碼行數,代碼commit次數統計, 可以本月,上個月,昨日統計,並輸出csv到slack上

# 用法：
在Linux 下，把相關專案的 Git Repository git clone 都放到單一資料夾下

再把 4in1_contributor_report.sh
放到同一個資料夾下
<img width="723" alt="image" src="https://github.com/tbdavid2019/4in1_contributor_report/assets/56015064/8afa1cde-e754-49d8-a1b3-0d5dd8c6b5b0">


設定好執行權限
 chmod 700 4in1_contributor_report.sh 

執行
./4in1_contributor_report 

接著會在 logs4in 產生 四份csv 檔案

最後會上傳到  Slack 指定的頻道上
<img width="685" alt="image" src="https://github.com/tbdavid2019/4in1_contributor_report/assets/56015064/382b28d8-54b8-420b-8ee4-d1e8a66e41eb">
