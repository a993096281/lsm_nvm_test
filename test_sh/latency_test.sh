#! /bin/sh

db="/mnt/ssd/ceshi"
db_mem="/pmem/nvm"
value_size="4096"
write_buffer_size="64"  #unit：MB
nvm_buffer_size="4096"  #unit：MB; memtable -> immutable ; allocate nvm_buffer_size*1.5*1.5 ? 4G*1.5*1.5=9G

benchmarks="fillrandomcontrolrequest,stats"
#benchmarks="fillrandom,stats"
num="20000000"
#reads="100"


histogram="1"

threads="3"

request_rate_limit="20000"


per_queue_length="16"


const_params=""

function FILL_PATAMS() {
    if [ -n "$db" ];then
        const_params=$const_params"--db_disk=$db "
    fi

    if [ -n "$db_mem" ];then
        const_params=$const_params"--db_mem=$db_mem "
    fi

    if [ -n "$value_size" ];then
        const_params=$const_params"--value_size=$value_size "
    fi

    if [ -n "$write_buffer_size" ];then
        const_params=$const_params"--write_buffer_size=$write_buffer_size "
    fi

    if [ -n "$nvm_buffer_size" ];then
        const_params=$const_params"--nvm_buffer_size=$nvm_buffer_size "
    fi

    if [ -n "$benchmarks" ];then
        const_params=$const_params"--benchmarks=$benchmarks "
    fi

    if [ -n "$num" ];then
        const_params=$const_params"--num=$num "
    fi

    if [ -n "$reads" ];then
        const_params=$const_params"--reads=$reads "
    fi

    if [ -n "$threads" ];then
        const_params=$const_params"--threads=$threads "
    fi

    if [ -n "$histogram" ];then
        const_params=$const_params"--histogram=$histogram "
    fi

    if [ -n "$request_rate_limit" ];then
        const_params=$const_params"--request_rate_limit=$request_rate_limit "
    fi

    if [ -n "$report_ops_latency" ];then
        const_params=$const_params"--report_ops_latency=$report_ops_latency "
    fi

    if [ -n "$YCSB_uniform_distribution" ];then
        const_params=$const_params"--YCSB_uniform_distribution=$YCSB_uniform_distribution "
    fi

    if [ -n "$ycsb_workloada_num" ];then
        const_params=$const_params"--ycsb_workloada_num=$ycsb_workloada_num "
    fi

    if [ -n "$per_queue_length" ];then
        const_params=$const_params"--per_queue_length=$per_queue_length "
    fi

}
CLEAN_CACHE() {
    if [ -n "$db" ];then
        rm -f $db/*
    fi
    if [ -n "$db_mem" ];then
        rm -f $db_mem/*
    fi
    sleep 2
    sync
    echo 3 > /proc/sys/vm/drop_caches
    sleep 2
}
COPY_OUT_FILE(){
    mkdir $bench_file_dir/result > /dev/null 2>&1
    res_dir=$bench_file_dir/result/value-$value_size
    mkdir $res_dir > /dev/null 2>&1
    \cp -f $bench_file_dir/compaction.csv $res_dir/
    \cp -f $bench_file_dir/OP_DATA $res_dir/
    \cp -f $bench_file_dir/OP_TIME.csv $res_dir/
    \cp -f $bench_file_dir/out.out $res_dir/
    \cp -f $bench_file_dir/Latency.csv $res_dir/
    \cp -f $bench_file_dir/PerSecondLatency.csv $res_dir/
    #\cp -f $db/OPTIONS-* $res_dir/

    #\cp -f $db/LOG $res_dir/
}


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

FILL_PATAMS 
CLEAN_CACHE

cmd="$bench_file_path $const_params "

if [ "$1" == "numa" ];then
cmd="numactl -N 1 -m 1 $bench_file_path $const_params"
fi


echo $cmd
eval $cmd

if [ $? -ne 0 ];then
    exit 1
fi
COPY_OUT_FILE