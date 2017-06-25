# Benchmarking

brew install sysbench
 Create user sbstest with dba grants from the workbench
 Create a sbtest database from the workbench
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest --mysql-table-engine=myisam prepare
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=4 --mysql-table-engine=myisam run

sysbench 0.4.12:  multi-threaded system evaluation benchmark

No DB drivers specified, using mysql
Running the test with following options:
Number of threads: 4

    Doing OLTP test.
    Running mixed OLTP test
    Doing read-only test
    Using Special distribution (12 iterations,  1 pct of values are returned in 75 pct cases)
    Using "LOCK TABLES READ" for starting transactions
    Using auto_inc on the id column
    Threads started!
    Time limit exceeded, exiting...
    (last message repeated 3 times)
    Done.

    OLTP test statistics:
        queries performed:
            read:                            916370
            write:                           0
            other:                           130910
            total:                           1047280
        transactions:                        65455  (1090.91 per sec.)
        deadlocks:                           0      (0.00 per sec.)
        read/write requests:                 916370 (15272.74 per sec.)
        other operations:                    130910 (2181.82 per sec.)

    Test execution summary:
        total time:                          60.0004s
        total number of events:              65455
        total time taken by event execution: 239.5199
        per-request statistics:
             min:                                  1.74ms
             avg:                                  3.66ms
             max:                                145.89ms
             approx.  95 percentile:               5.07ms

    Threads fairness:
        events (avg/stddev):           16363.7500/85.88
        execution time (avg/stddev):   59.8800/0.00
