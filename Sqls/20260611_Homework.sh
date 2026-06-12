# 游戏1：三位数字彩票游戏
# 题目要求
# 系统随机生成3 个 0～9 之间的独立数字，组成一个三位数彩票号码。
# 让用户依次输入3 个 0-9 的数字进行竞猜。
# 每一位数字都必须完全一样、顺序也一样才算中奖。
# 如果没猜对，提示 “未中奖，请再试一次！” 并继续游戏。
# 如果 3 个数字全部猜对，提示 “恭喜你！中奖啦！” 并结束游戏。

#!/bin/bash

echo "===== 三位数字彩票游戏 ====="
echo "系统已生成一个三位数彩票号码（每位0-9）"
echo "请依次输入您猜测的三个数字（每输入一个按回车）"

# 生成随机彩票号码
a=$((RANDOM % 10))
b=$((RANDOM % 10))
c=$((RANDOM % 10))

while true; do
    read -p "请输入第1位数字（0-9）: " u1
    read -p "请输入第2位数字（0-9）: " u2
    read -p "请输入第3位数字（0-9）: " u3

    # 检查输入是否合法（简单判断是否为数字且在0-9之间）
    #if [[ ! $u1 =~ ^[0-9]$ ]] || [[ ! $u2 =~ ^[0-9]$ ]] || [[ ! $u3 =~ ^[0-9]$ ]]; then
    #    echo "输入无效，请确保每位都是0-9之间的单个数字！"
    #    continue
    #fi

    if [[ $u1 -eq $a && $u2 -eq $b && $u3 -eq $c ]]; then
        echo "恭喜你！中奖啦！"
        break
    else
        echo "未中奖，请再试一次！"
        ([[ $u1 -gt $a ]] && echo "第一个数字大了") || ([[ $u1 -lt $a ]] && echo "第一个数字小了") || ([[ $u1 -eq $a ]] && echo "第一个数字正确")
        ([[ $u2 -gt $b ]] && echo "第二个数字大了") || ([[ $u2 -lt $b ]] && echo "第二个数字小了") || ([[ $u2 -eq $b ]] && echo "第二个数字正确")
        ([[ $u3 -gt $c ]] && echo "第三个数字大了") || ([[ $u3 -lt $c ]] && echo "第三个数字小了") || ([[ $u3 -eq $c ]] && echo "第三个数字正确")
    fi
done


# 游戏2：剪刀石头布
# 题目要求
# 电脑随机出：剪刀、石头、布
# 用户直接输入中文：剪刀 / 石头 / 布
# 判断胜负：平局继续，分出胜负就结束
# 输出清晰结果

#!/bin/bash

# 剪刀石头布游戏
# 电脑随机出：剪刀、石头、布
# 用户输入中文，平局继续，分出胜负结束

echo "===== 剪刀石头布 ====="
echo "请输入：剪刀、石头、布"

array=(剪刀 石头 布)
while true; do
    # 电脑随机选择：0=剪刀, 1=石头, 2=布
    computer_choice=${array[((RANDOM % 3))]}
    # computer=$((RANDOM % 3))
    # case $computer in
    #     0) computer_choice=${array[0]};;
    #     1) computer_choice=${array[1]};;
    #     2) computer_choice=${array[2]};;
    # esac

    read -p "你的选择: " user_choice

    # 验证用户输入
    # if [[ "$user_choice" != "剪刀" && "$user_choice" != "石头" && "$user_choice" != "布" ]]; then
    #     echo "输入无效，请输入中文：剪刀、石头、布"
    #     continue
    # fi

    echo "电脑出了：$computer_choice"

    # 判定胜负
    if [[ "$user_choice" == "$computer_choice" ]]; then
        echo "平局，再来一局！"
        continue
    fi

    #转化
    user_choice_index=4
    computer_choice_index=4
    for i in ${!array[@]}
    do
        if [[ $(($user_choice_index | $computer_choice_index)) -lt 4  ]];then
        	break;
        fi
        if [ "$computer_choice" == ${array[$i]} ]; then
            computer_choice_index=${i}
        fi
        if [ "$user_choice" == ${array[$i]} ]; then
            user_choice_index=${i}
        fi
    done

	#echo "$((($user_choice_index  << 1) & 3))"
	#echo $computer_choice_index
    #if [ $((($user_choice_index  << 1) & 3)) -le "$computer_choice_index" ];then
    if [ $((($user_choice_index - $computer_choice_index + 3) % 3)) -eq 2 ];then
    # 用户赢的情况
    # if [[ ( "$user_choice" == "剪刀" && "$computer_choice" == "布" ) ||
    #       ( "$user_choice" == "石头" && "$computer_choice" == "剪刀" ) ||
    #       ( "$user_choice" == "布" && "$computer_choice" == "石头" ) ]]; then
        echo "你输了！"
        break
    else
        echo "你赢了！"
        break
    fi
done



# 游戏3：口算小达人(乘法版)
# 题目要求
# 系统随机出一道 1～9 的乘法题（比如 3×5、7×2）。
# 让用户输入答案。
# 答对提示 “答对啦！” 并结束；答错提示 “再试试”，继续答题。


#!/bin/bash

# 口算小达人（乘法）
# 随机出1-9的乘法题，答对结束，答错继续

echo "===== 口算小达人（乘法） ====="

times=0
a=$((RANDOM % 9 + 1))   # 1-9
b=$((RANDOM % 9 + 1))
correct=$((a * b))
while true; do


    read -p "请回答：\$a × \$b = ? " answer

    # 检查输入是否为整数
    if [[ ! "$answer" =~ ^-?[0-9]+$ ]]; then
        echo "请输入整数答案！"
        continue
    fi

    if [[ $answer -eq $correct ]]; then
        echo "答对啦！"
        exit 0
    else
        [ $answer -gt $correct ] && echo "大了" || echo "小了"
        echo "再试试"
        
    	[ $times -eq 3 ] && echo "尝试3次错误，给出提示第一个数是：$a"
        [ $times -eq 6 ] && echo "太惨了，尝试8次错误，给出提示第二个数是：$b"
        ((times++))
    fi
done



#练习题
# **:在/root/temp/创建0613文件夹，再创建一个新文件hello.txt
# 写入：
# hello world!
# hello world again!
# hello hello !
# nice to meet you!

# 题目 1：统计hello.txt文件中特定单词出现次数

# 要求：
# 编写脚本，统计指定文件中 "hello" 出现的次数（区分大小写）。
# 输入：文件路径（如 hello.txt）。
# 输出：单词 "hello" 的出现次数。


#!/bin/bush
count=grep -o "hello" $1 | wc -l
echo $count



# 题目 2：打印 10 以内的偶数
# 要求：
# 使用循环打印 2 到 10 之间的所有偶数（每行一个数字）。

for((i=2;i<=10;i++))
do
    [ $[$i % 2] -eq 0 ] && echo $i 
done

  
  

# 题目 3：列出目录下所有 .txt 文件
# 要求：
# 编写脚本，列出当前目录下所有 .txt 文件的名称（不含路径）。

file_array=$(find $PWD -name "*.txt")
for f in $file_array
do
    echo $(basename -s ".txt" $f)
done



# 题目 4：批量创建文件
# 要求：创建 5 个文件：file1.txt、file2.txt、...、file5.txt，每个文件包含一行内容：This is file X（X 为文件编号）。

for ((i=1;i<=5;i++))
do
    touch file$i.txt
    echo "This is file $i" > file$i.txt
done




# 题目 5：统计目录下文件数量
# 要求：编写脚本，统计指定目录下的 普通文件 数量（不包括目录）。
# 输入：目录路径（如 /tmp）。
# 输出：文件数量。
find . -maxdepth 1 -type f | wc -l




# 题目 6：读取用户输入并判断是否为数字
# 要求：
# 编写脚本，提示用户输入一个值，判断该值是否为整数（如 123 是，abc 或 1.2 不是）。


read -p "input:" num;
echo $num
if [[ "$num" =~ ^[0-9]+$ ]];then
    echo "Y"
else
    echo "N"
fi


# 提示：
# 使用 read 读取用户输入。
# 使用正则表达式判断是否为整数：^[0-9]+$。


# 题目 7：计算 1 到 100 的和
# 要求：
# 使用循环计算 1 到 100 的所有整数之和。


# 题目 8：检查文件是否存在
# 要求：
# 编写脚本，检查用户输入的文件是否存在。如果存在，显示文件类型（普通文件 / 目录 / 符号链接）。

```
stat 命令 —— 获取结构化类型信息
stat 可以输出更规范的类型标识：

bash
stat -c %F /etc/passwd   # 输出: regular file
stat -c %F /tmp          # 输出: directory
stat -c %F /bin          # 输出: symbolic link
stat -c %F /dev/sda      # 输出: block special file
stat -c %F /dev/tty      # 输出: character special file
其他格式：

%F：人类可读类型（如 regular file、directory）

%f：十六进制模式字（如 81ed）

%A：权限字符串（如 -rw-r--r--
```
if [[ -e $1 ]];then
    stat -c %F $1
fi


# 题目 9：删除空文件
# 要求：
# 编写脚本，删除当前目录下所有大小为 0 的文件（需确认后再删除）。

# 提示：
# 使用 find -size 0 查找空文件。
# 使用 read 获取用户确认（如输入 y 继续）。

array=$(find $PWD -size 0)
echo $array
read -p "input :" confirm;
[[ "$confirm" == 'y' ]] && rm -f $array




解题技巧总结
常用命令：
ls：列出文件和目录。
grep：文本搜索。
wc：统计行数、字数、字符数。
find：查找文件。
du：估算文件大小。
rm：删除文件。
循环结构：
for i in {1..10}：数值循环。
for file in *.txt：遍历文件。
while：条件循环（如 while [ $i -le 10 ]）。
条件判断：
if [ -f "$file" ]：检查文件是否存在。
[[ $var =~ ^regex$ ]]：正则表达式匹配。
