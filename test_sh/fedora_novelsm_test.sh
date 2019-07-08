#! /bin/sh

bench_db_path="/home/lzw/ceshi"
bench_mem_path="/pmem/nvm"
bench_value="4096"
write_buffer_size="64"  #单位：MB
nvm_buffer_size="8192"  #单位：MB

#bench_benchmarks="fillseq,stats,readseq,readrandom,stats" #"fillrandom,fillseq,readseq,readrandom,stats"
#bench_benchmarks="fillrandom,stats,readseq,readrandom,stats"
#bench_benchmarks="fillrandom,stats,wait,stats,readseq,readrandom,readrandom,readrandom,stats"
bench_benchmarks="fillrandom,stats,wait,clean_cache,stats,readseq,readrandom,stats"
#bench_benchmarks="fillseq,stats"
bench_num="2000000"
bench_readnum="100000"


const_params="
    --db_disk=$bench_db_path \
    --value_size=$bench_value \
    --benchmarks=$bench_benchmarks \
    --num_levels=2 \
    --num=$bench_num \
    --reads=$bench_readnum \
    --db_mem=$bench_mem_path \
    --write_buffer_size=$write_buffer_size \
    --nvm_buffer_size=$nvm_buffer_size \
    "

bench_file_path="$(dirname $PWD )/out-static/db_bench"

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$PWD/out-static/db_bench"
fi

if [ ! -f "${bench_file_path}" ];then
echo "Error:${bench_file_path} or $(dirname $PWD )/out-static/db_bench not find!"
exit 1
fi

cmd="$bench_file_path $const_params "

if [ -n "$1" ];then
cmd="nohup $bench_file_path $const_params >>out.out 2>&1 &"
echo $cmd >out.out
fi

if [ -n "$bench_db_path" ];then
    rm -f $bench_db_path/*
fi
if [ -n "$bench_mem_path" ];then
    rm -f $bench_mem_path/*
fi
echo $cmd
eval $cmd
