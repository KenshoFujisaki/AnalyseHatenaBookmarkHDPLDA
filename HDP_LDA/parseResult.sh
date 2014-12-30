#!/bin/bash

#引数理解
if [ $# -ne 2 ]; then
  echo "usage: ./parseBeta.sh [number_of_iterations]-topics.dat [number_of_rankings]"
  echo "e.g.:  ./parseBeta.sh ./hdp_output/01000-topics.dat 1000"
  exit 1
fi
input_file=$1
file_prefix=${input_file%.dat}
number_of_rankings=$2

# *-topics.dat形式から*.beta形式に変換
# *.beta形式: 各トピックについて語彙1の割合,..,語彙Nの割合
beta_file="$file_prefix.beta"
echo "converting from $input_file(*-topics.dat) into $beta_file(*.beta) is started."
./topicsDat2beta.sh "$input_file" > "$beta_file"
if [ $? -ne 0 ]; then
  echo "error at ./topicsDat2beta.sh"
  exit 1
fi
echo "converting from $input_file(*-topics.dat) into $beta_file(*.beta) is finished."

# *-word-assignments.dat形式から*.alpha形式に変換
# *.alpha形式: 全文書におけるトピック1の割合,..,トピックKの割合
word_assignment_file="${input_file%-topics.dat}-word-assignments.dat"
alpha_file="$file_prefix.alpha"
echo "converting from $word_assignment_file(*-word-assignments.dat) into $alpha_file(*.alpha) is started."
./wordAssignments2alpha.sh "$word_assignment_file" > "$alpha_file"
if [ $? -ne 0 ]; then
  echo "error at ./wordAssignments2alpha.sh"
  exit 1
fi
echo "converting from $word_assignment_file(*-word-assignments.dat) into $alpha_file(*.alpha) is finished."

# *.betaを可視化
number_of_topics=`wc -l "$input_file" | awk '{print $1}'`
echo "visualizing $beta_file(*.beta) is started."
./parseBeta.sh "$beta_file" $number_of_topics $number_of_rankings
if [ $? -ne 0 ]; then
  echo "error at ./parseBeta.sh"
  exit 1
fi
echo "visualizing $beta_file(*.beta) is finished."
echo "finished!!"
