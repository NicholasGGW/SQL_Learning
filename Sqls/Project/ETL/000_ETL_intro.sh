


# ================= 1. 路径和日志准备 =================
# 无论在哪个目录执行该脚本，都能正确找到同目录下的文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "当前文件目录为 $SCRIPT_DIR"
PROJECT_DIR=$(realpath "$SCRIPT_DIR/../")
echo "当前项目目录为 $PROJECT_DIR"



# 日志
LOG_DIR=$(realpath "$PROJECT_DIR/log/")
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/ETL_Task_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1


# 显式加载系统和用户的环境变量，让 crontab 拥有和手动执行一样的内核
source /etc/profile
source ~/.bashrc
source ~/.bash_profile

# ================= 2. 调用脚本路径 =================

to_ods_script="$SCRIPT_DIR/001_extract_mall_to_ods.sh"
to_dwd_script="$SCRIPT_DIR/002_ods_to_dwd.sh"
to_dws_script="$SCRIPT_DIR/003_dwd_to_dws.sh"

script_files=($to_ods_script $to_dwd_script $to_dws_script)


main(){
    for script_file in "${script_files[@]}"; do
        echo "即将执行 bash "$script_file" "$(date +%F)""
        # 把子脚本的外层输出扔进黑洞，断绝父脚本 tee 的干扰
        bash "$script_file" "$(date +%F)" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "[Success] 执行成功"
        else
            echo "[ERROR] 执行失败"
            exit 1
        fi
    done 
}

main