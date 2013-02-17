#!/bin/bash

f1="tmp183"
f2="tmp204"
#f3="tmp210"
if [ $# != "2" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
	echo 
	echo "Usage: `basename $0` old_sql_file new_sql_file"
	echo "       执行本脚本以后，会把 old_sql_file 在 new_sql_file 中所缺的表或字段输出到tb.sql中(建表或增加字段的sql语句)"
	echo 
	echo "注: 1.本脚本只对mysql导出的数据库文件进行测试过，其它数据库未做测试"
	echo "    2.所用file必须是mysqldump导出的file，且file中必须使用完整的建表语句"
	echo "    3.所有使用MyISAM引擎的表会被强制更改为InnoDB引擎"
	echo 
	echo "Author: maoting"
	echo "Version: 1.0"
	echo 
	exit 2
fi

of=$1
nf=$2

function seperateList()
{
	cat /dev/null > ${1}_tmp
	awk -v tname="${1}_tmp" '
	{
		if($0 ~ /^CREATE TABLE/){
			#在create table语句中增加库名，以便后续处理
			split($0,tmpx,"`");
			printf("%s%s.%s%s\n", tmpx[1], usg, tmpx[2], tmpx[3]) >> tname;
			sub(/^CREATE TABLE `/,"");
			sub(/` \(.*/,"");
			string=usg","$0;
		}else{
			printf("%s\n",$0) >> tname;
			if($0 ~ /^  `/){
				sub(/^  `/,"");
				sub(/` .*/,"");
				string=string","$0;
			}else if($0 ~ /^\) ENGINE/){
				print string;
			}else if($0 ~ /^USE/){
					sub(/USE `/,"");
				sub(/`.*/,"");
				usg=$0;
			}
		}
	}
	' $1 > ${1}_list
}

#提取建表语句
sed -n "/^USE/p;/CREATE TABLE/,/) ENGINE=/p" $of > $f1
sed -n "/^USE/p;/CREATE TABLE/,/) ENGINE=/p" $nf > $f2

#处理建表语句，形成：库名,表名,字段1,字段2,...的格式，以便后续处理
seperateList $f1
seperateList $f2

m204="`cat ${f2}_list`"
fl="${f1}_list"

sqlFile="tb.sql"
cat /dev/null > $sqlFile

#检查是否需要创建数据库
mDB="`awk 'BEGIN{FS="\`"}/^USE/{print $2}' $f2`"
for db in $mDB; do
	[ `grep -c "$db" $f1` == "0" ] && echo "CREATE DATABASE $db;" >> $sqlFile
done

for st in $m204; do
	unset arry
	arry=( `echo "$st" | awk 'BEGIN{FS=","}{for(i=1;i<=NF;i++)printf("%s ",$i)}'` )
	echo "processing: ${arry[0]}.${arry[1]}"
	if [ `grep -c "${arry[0]},${arry[1]}" $fl` == "0" ]; then
		#强制转换MyISAM引擎为InnoDB引擎，若不需强制转换，则去掉第2个sed
		sed -n "/^CREATE TABLE ${arry[0]}.${arry[1]}/,/) ENGINE=/p" ${f2}_tmp | sed 's/MyISAM/InnoDB/g' >> $sqlFile
	else
		num=${#arry[*]}
		#表的字段从第3列开始
		for ((i=2;i<$num;i++)); do
			if [ `grep -c "${arry[0]},${arry[1]}.*${arry[i]}" $fl` == "0" ]; then
				ln=`sed -n "/^CREATE TABLE ${arry[0]}.${arry[1]}/,/) ENGINE=/p" ${f2}_tmp | grep -w "${arry[i]}"`
				lln=${ln## }
				echo "alter table ${arry[0]}.${arry[1]} add column${lln%,};" >> $sqlFile
			fi
		done
	fi
done

#删除临时文件
[ -f $f1 ] && rm -f $f1
[ -f $f2 ] && rm -f $f2
[ -f ${f1}_list ] && rm -f ${f1}_list
[ -f ${f2}_list ] && rm -f ${f2}_list
[ -f ${f1}_tmp ] && rm -f ${f1}_tmp
[ -f ${f2}_tmp ] && rm -f ${f2}_tmp
