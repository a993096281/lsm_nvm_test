#! /bin/sh

value_array=(1024 4096 16384 65536)
test_all_size=81920000000   #80G


bench_db_path="/mnt/ssd/ceshi"
bench_mem_path="/pmem/nvm"
bench_value="4096"
write_buffer_size="64"  #单位：MB
nvm_buffer_size="8192"  #单位：MB

#bench_benchmarks="fillseq,stats,readseq,readrandom,stats" #"fillrandom,fillseq,readseq,readrandom,stats"
#bench_benchmarks="fillrandom,stats,readseq,readrandom,stats"
bench_benchmarks="fillrandom,stats,wait,stats,readseq,readrandom,readrandom,readrandom,stats"
#bench_benchmarks="fillseq,stats"
bench_num="20000000"
bench_readnum="1000000"


bench_file_path="$(dirname $PWD )/out-static/db_bench"

bench_file_dir="$(dirname $PWD )"

if [ ! -f "${bench_file_path}" ];then
bench_file_path="$PWD/out-static/db_bench"
bench_file_dir="$PWD"
fi

if [ ! -f "${bench_file_path}" ];then
echo "Error:${bench_file_path} or $(dirname $PWD )/out-static/db_bench not find!"
exit 1
fi

RUN_ONE_TEST() {
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
    cmd="$bench_file_path $const_params >>out.out 2>&1"
    echo $cmd >out.out
    echo $cmd
    #eval $cmd
}

CLEAN_CACHE() {
    rm -f $bench_db_path/*
    rm -f $bench_mem_path/*
    sleep 2
    sync
    echo 3 > /proc/sys/vm/drop_caches
    sleep 2
}

COPY_OUT_FILE(){
    mkdir $bench_file_dir/result > /dev/null 2>&1
    res_dir=$bench_file_dir/result/value-$bench_value
    mkdir $res_dir > /dev/null 2>&1
    \cp -f $bench_file_dir/compaction.csv $res_dir/
    \cp -f $bench_file_dir/OP_DATA $res_dir/
    \cp -f $bench_file_dir/OP_TIME.csv $res_dir/
    \cp -f $bench_file_dir/out.out $res_dir/
}
RUN_ALL_TEST() {
    for value in ${value_array[@]}; do
        CLEAN_CACHE
        bench_value="$value"
        bench_num="`expr $test_all_size / $bench_value`"

        RUN_ONE_TEST
        if [ $? -ne 0 ];then
            exit 1
        fi
        COPY_OUT_FILE
        sleep 5
    done
}

RUN_ALL_TEST