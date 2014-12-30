#!/bin/bash

#引数理解
if [ $# -ne 1 ]; then
  echo "usage: $0 [number_of_iterations]-topics.dat"
  echo "i.g.:  $0 01000-topics.dat > 01000.beta"
  exit 1
fi
input_file=$1
if [ ! -e $input_file ]; then
  echo "$input_file is not found."
  exit 1
fi

#*-topics.dat形式を*.beta形式に変換
cat "$input_file" | ruby -ne '
  #初期化
  BEGIN{array = []};

  #行列の値を正規化して格納
  #  行:トピックス
  #  列:単語
  #  値:%05d形式, 出現回数
  number_of_words = 0
  array.push($_.split(" ").
            map{|e| number_of_words += e.to_i; e.to_i}.
            map{|e| e.to_f / number_of_words.to_f})
  
  END{
    # 行列の転置を標準出力
    array.transpose.map{|e| print e.join(" ") + "\n"}
  }'
