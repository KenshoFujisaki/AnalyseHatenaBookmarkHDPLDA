#!/bin/bash

#引数理解
if [ $# -ne 3 ]; then
  echo "usage: $0 [model.beta] [number_of_topics] [number_of_rankings]"
  echo "i.g.:  $0 model.beta 40 1000"
  exit 1
fi
input_file=$1
file_prefix=${input_file%.beta}
number_of_topics=$2
number_of_rankings=$3

if [ ! -e $input_file ]; then
  echo "$input_file is not found."
  exit 1
fi
mkdir -p ./wordcloud/visualize_csv/$file_prefix
echo "./wordcloud/visualize_csv/$file_prefix folder is created."

cat $input_file | ruby -ne '
  #初期化
  BEGIN{
    array = []; 
    row = 0; 
    output_length = '"$number_of_rankings"'
  };

  #行列を変数に格納
  array[row] = $_.split(" ").map{|e| e.to_f}
  print "." if ARGF.lineno % 1000 == 0
  row+=1;

  END{
    puts "loading file is finished."

    #各トピックについての単語の生起確率（arrayの転置行列を，各行の中で列の値でソート）
    #  トピック１ [{最大生起単語の確率,morpheme_id}，{第２生起単語の確率,morpheme_id}，{第３生起単語の確率,morpheme_id}．．．]
    #  トピック２ [{最大生起単語の確率,morpheme_id}，{第２生起単語の確率,morpheme_id}，{第３生起単語の確率,morpheme_id}．．．]
    sorted_array = []
    for col in 0..array.first.length-1;
      print ".";
      sorted_array[col] = array.map.with_index{|e,row| [e[col], row+1]}.
        sort{|a,b| b.first<=>a.first}.
        slice(0..output_length-1)
    end
    array = nil;
    puts "sorting array is finished.";

    #各トピックの生起確率を取得
    alpha = `cat '"$file_prefix"'.alpha`;
    alpha_topic_scores = (alpha.length==0) ? [] : alpha.split(" ")

    #各トピックについて単語の生起確率を上位N個出力
    for topic_id in 0..sorted_array.length-1;
      alpha_topic_score = (alpha_topic_scores.length==0) ? "" : alpha_topic_scores[topic_id];
      puts "topic" + (topic_id+1).to_s + ":" + alpha_topic_score;
      
      #CSV結果出力
      file = "./wordcloud/visualize_csv/'"$file_prefix"'/topic" + topic_id.to_s + ".csv"
      open(file, "w") {|f|
        f.write("name,value\n");

        #SQL-query準備(morpheme_id->形態素名)
        morpheme_score_max = sorted_array[topic_id][0][0];
        morpheme_ids = [];
        morpheme_scores = [];
        for word_id in 0..output_length-1;
          morpheme_scores.push(sorted_array[topic_id][word_id][0]);
          morpheme_ids.push(sorted_array[topic_id][word_id][1]);
        end;
        morpheme_ids_str = morpheme_ids.join(",");

        #SQL実行(morpheme_id->形態素名)
        sql_query = "mysql -N -uhatena -phatena -Dhatena_bookmark -e \"
          select name from morpheme where id in(#{morpheme_ids_str}) order by field(id,#{morpheme_ids_str})\"";
        `#{sql_query}`.split("\n").each_with_index{|morpheme_name, index|
          print morpheme_name + " ";
          f.write(morpheme_name + "," + morpheme_scores[index].to_s + "\n");
        };
        sorted_array[topic_id] = nil;
        print "\n\n";
      }
    end;
  }'

#結果を画像に出力
for ((i=0; i<$number_of_topics; i++)); do
  echo "topic${i}:"
  ./mkwordcloudhtml.sh "./${file_prefix}/topic${i}.csv" "./wordcloud/visualize_csv/index.html"
  wkhtmltoimage --crop-w 2000 --height 2000 --zoom 4.4 "file://`pwd`/wordcloud/visualize_csv/index.html" "./wordcloud/visualize_csv/${file_prefix}/topic${i}.png"
done
rm ./wordcloud/visualize_csv/index.html
echo "drawing wordcloud(./wordcloud/visualize_csv/${file_prefix}/) is finished!"
