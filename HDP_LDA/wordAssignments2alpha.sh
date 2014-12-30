#!/bin/bash

#引数理解
if [ $# -ne 1 ]; then
  echo "usage: $0 [number_of_iterations]-word-assignments.dat"
  echo "i.g.:  $0 01000-word-assignments.dat > 01000.alpha"
  exit 1
fi
input_file=$1
if [ ! -e $input_file ]; then
  echo "$input_file is not found."
  exit 1
fi

#*-word-assignments.dat形式を*.alpha形式に変換
cat "$input_file" | ruby -ne '
  BEGIN{
    topic_doc_count = {}; 
    nof_docs = 0
  }; 
  
  topic_id = $_.split(" ")[2]; 
  next if topic_id != topic_id.to_i.to_s; 
  topic_id = topic_id.to_i; 

  topic_doc_count[topic_id] = 0 unless topic_doc_count.has_key?(topic_id); 
  topic_doc_count[topic_id] += 1; 
  nof_docs += 1; 
  
  END{
    (0..topic_doc_count.keys.max).map{|i| topic_doc_count[i] = 0.0 unless topic_doc_count.has_key?(i)};
    print topic_doc_count.to_a.
      map{|e| [e.first, e.last.to_f/nof_docs.to_f]}.
      sort{|a,b| a.first<=>b.first}.
      map{|e| e.last}.
      join(" ")
  }'
