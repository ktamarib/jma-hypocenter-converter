#!/bin/bash
# 96カラムフォーマット震源ファイルをCSV形式に変換するツール
function usage(){
	echo "#  1 ヘッダ(J)"
	echo "#  2 年月日"
	echo "#  3 時分秒"
	echo "#  4 時間誤差(秒)"
	echo "#  5 緯度(度)"
	echo "#  6 緯度誤差(度)"
	echo "#  7 経度(度)"
	echo "#  8 経度誤差(度)"
	echo "#  9 深さ(km)"
	echo "# 10 深さ誤差(km)"
	echo "# 11 第１Ｍ"
	echo "# 12 第１Ｍ種別"
	echo "# 13 第２Ｍ"
	echo "# 14 第２Ｍ種別"
	echo "# 15 使用走時表"
	echo "# 16 震源評価"
	echo "# 17 震源情報"
	echo "# 18 最大震度"
	echo "# 19 被害規模"
	echo "# 20 津波規模"
	echo "# 21 大地域番号"
	echo "# 22 小地域番号"
	echo "# 23 震央地名"
	echo "# 24 観測点数"
	echo "# 25 決定フラグ"
	exit 1
}

## main
if   [ $# == 0 ]; then
	if [[ -p /dev/stdin ]]; then
		filename="/dev/stdin"
	else
		usage
	fi
elif [ $# == 1 ]; then
	filename=$1
	if [ ! -f $filename ]; then
		usage
	fi
else
	usage
fi

LANG=C awk '
!/^#/{
	if(/^A/||/^B/){
		FIELDWIDTHS="1 4 2 2 2 2 4 4 3 4 4 4 4 4 5 3 1 1 1 1 1 1 1 1 1 1 1 1 1 3 22 5 1"
	}
	else{
		FIELDWIDTHS="1 4 2 2 2 2 4 4 3 4 4 4 4 4 5 3 1 1 1 1 1 1 1 1 1 1 1 1 1 3 24 3 1"
	}
	gsub("","",$0)

	if      ($17==" "&&$18==" ") magn1=-99
	else if ($17=="-") magn1=    - $18
	else if ($17=="A") magn1=-10 - $18
	else if ($17=="B") magn1=-20 - $18
	else if ($17=="C") magn1=-30 - $18
	else               magn1=$17*10 + $18
	if      ($19==" ") magf1="N"
	else               magf1=$19
	if      ($20==" "&&$21==" ") magn2=-99
	else if ($20=="-") magn2=    - $21
	else if ($20=="A") magn2=-10 - $21
	else if ($20=="B") magn2=-20 - $21
	else if ($20=="C") magn2=-30 - $21
	else               magn2=$20*10 + $21
	if      ($22==" ") magf2="N"
	else               magf2=$22

	gsub(" ",0,$0)
	sec=$7/100.
	sece=$8/100.
	latmin=$10/100.
	lata=$9+latmin/60.
	late=$11/6000.
	lonmin=$13/100.
	lona=$12+lonmin/60.
	lone=$14/6000.
	dep=$15/100.
	depe=$16/100.

	magn1=magn1/10.
	magn2=magn2/10.
	gsub(0," ",$31)
	printf ("%1s,%04d-%02d-%02d,%02d:%02d:%05.2f,%5.2f,%8.4f,%7.4f,%9.4f,%7.4f,%6.2f,%5.2f,%4.1f,%1s,%4.1f,%1s,%1s,%1s,%1s,%1s,%1s,%1s,%1d,%3d,%24s,%3d,%1s\n",$1,$2,$3,$4,$5,$6,sec,sece,lata,late,lona,lone,dep,depe,magn1,magf1,magn2,magf2,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33)
}' $filename
