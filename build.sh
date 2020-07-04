# /bin/bash
set -e

# building without R
./dev/make-distribution.sh --name custom-spark --pip --tgz -Psparkr -Phadoop-2.7 -Dhadoop.version=2.7.7 -Phive -Phive-thriftserver -Pmesos -Pyarn -Pkubernete
mv spark-2.4.5-bin-custom-spark.tgz ../
cd .. && tar -xvf spark-2.4.5-bin-custom-spark.tgz

for i in `seq 6 1 22`; do 
    echo node$i
    ssh administrator@node$i "rm -r ./shuffle_log; mkdir shuffle_log"
done

# test
/home/administrator/spark-2.4.5-bin-custom-spark/bin/spark-sql --master yarn --database tpcds_bin_partitioned_parquet_1000 -f /home/administrator/hive-testbench/sample-queries-tpcds/query12.sql

for i in `seq 6 1 22`; do 
    rsync -r administrator@node$i:~/shuffle_log/ ~/shuffle_log/
done


# check log
# yarn logs -applicationId xxx_xx
