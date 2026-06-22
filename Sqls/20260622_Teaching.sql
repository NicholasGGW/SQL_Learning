

--先创表，然后
--直接sqoop自动执行load data
sqoop import --connect "jdbc:mysql://master:3306/test?useSSL=false" --username root --password 123456 --table student --hive-import --hive-database test --hive-table student6 --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --m 1 --delete-target-dir




/*
Warning: /home/sqoop-1.4.5-cdh5.3.6/../hbase does not exist! HBase imports will fail.
Please set $HBASE_HOME to the root of your HBase installation.
Warning: /home/sqoop-1.4.5-cdh5.3.6/../hcatalog does not exist! HCatalog jobs will fail.
Please set $HCAT_HOME to the root of your HCatalog installation.
Warning: /home/sqoop-1.4.5-cdh5.3.6/../accumulo does not exist! Accumulo imports will fail.
Please set $ACCUMULO_HOME to the root of your Accumulo installation.
Warning: /home/sqoop-1.4.5-cdh5.3.6/../zookeeper does not exist! Accumulo imports will fail.
Please set $ZOOKEEPER_HOME to the root of your Zookeeper installation.
26/06/22 11:06:21 INFO sqoop.Sqoop: Running Sqoop version: 1.4.5-cdh5.3.6
26/06/22 11:06:21 WARN tool.BaseSqoopTool: Setting your password on the command-line is insecure. Consider using -P instead.
26/06/22 11:06:21 INFO manager.MySQLManager: Preparing to use a MySQL streaming resultset.
26/06/22 11:06:21 INFO tool.CodeGenTool: Beginning code generation
26/06/22 11:06:21 INFO manager.SqlManager: Executing SQL statement: SELECT t.* FROM `student` AS t LIMIT 1
26/06/22 11:06:21 INFO manager.SqlManager: Executing SQL statement: SELECT t.* FROM `student` AS t LIMIT 1
26/06/22 11:06:21 INFO orm.CompilationManager: HADOOP_MAPRED_HOME is /home/hadoop-2.8.2
Note: /tmp/sqoop-root/compile/2276d9fc4c973b66efc1fb3202c5d035/student.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
26/06/22 11:06:22 INFO orm.CompilationManager: Writing jar file: /tmp/sqoop-root/compile/2276d9fc4c973b66efc1fb3202c5d035/student.jar
26/06/22 11:06:23 INFO tool.ImportTool: Destination directory student is not present, hence not deleting.
26/06/22 11:06:23 WARN manager.MySQLManager: It looks like you are importing from mysql.
26/06/22 11:06:23 WARN manager.MySQLManager: This transfer can be faster! Use the --direct
26/06/22 11:06:23 WARN manager.MySQLManager: option to exercise a MySQL-specific fast path.
26/06/22 11:06:23 INFO manager.MySQLManager: Setting zero DATETIME behavior to convertToNull (mysql)
26/06/22 11:06:23 INFO mapreduce.ImportJobBase: Beginning import of student
26/06/22 11:06:23 INFO Configuration.deprecation: mapred.jar is deprecated. Instead, use mapreduce.job.jar
26/06/22 11:06:23 INFO Configuration.deprecation: mapred.map.tasks is deprecated. Instead, use mapreduce.job.maps
26/06/22 11:06:23 INFO client.RMProxy: Connecting to ResourceManager at master/192.168.159.131:8032
26/06/22 11:06:30 INFO db.DBInputFormat: Using read commited transaction isolation
26/06/22 11:06:30 INFO mapreduce.JobSubmitter: number of splits:1
26/06/22 11:06:30 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1781577024068_0017
26/06/22 11:06:30 INFO impl.YarnClientImpl: Submitted application application_1781577024068_0017
26/06/22 11:06:30 INFO mapreduce.Job: The url to track the job: http://master:8088/proxy/application_1781577024068_0017/
26/06/22 11:06:30 INFO mapreduce.Job: Running job: job_1781577024068_0017
26/06/22 11:06:37 INFO mapreduce.Job: Job job_1781577024068_0017 running in uber mode : false
26/06/22 11:06:37 INFO mapreduce.Job:  map 0% reduce 0%
26/06/22 11:06:43 INFO mapreduce.Job:  map 100% reduce 0%
26/06/22 11:06:44 INFO mapreduce.Job: Job job_1781577024068_0017 completed successfully
26/06/22 11:06:44 INFO mapreduce.Job: Counters: 30
        File System Counters
                FILE: Number of bytes read=0
                FILE: Number of bytes written=164856
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=87
                HDFS: Number of bytes written=102
                HDFS: Number of read operations=4
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
        Job Counters
                Launched map tasks=1
                Other local map tasks=1
                Total time spent by all maps in occupied slots (ms)=2539
                Total time spent by all reduces in occupied slots (ms)=0
                Total time spent by all map tasks (ms)=2539
                Total vcore-milliseconds taken by all map tasks=2539
                Total megabyte-milliseconds taken by all map tasks=2599936
        Map-Reduce Framework
                Map input records=3
                Map output records=3
                Input split bytes=87
                Spilled Records=0
                Failed Shuffles=0
                Merged Map outputs=0
                GC time elapsed (ms)=37
                CPU time spent (ms)=910
                Physical memory (bytes) snapshot=177901568
                Virtual memory (bytes) snapshot=2118258688
                Total committed heap usage (bytes)=117440512
        File Input Format Counters
                Bytes Read=0
        File Output Format Counters
                Bytes Written=102


//从这里对比target-dir多了
26/06/22 11:06:44 INFO mapreduce.ImportJobBase: Transferred 102 bytes in 20.6776 seconds (4.9329 bytes/sec)
26/06/22 11:06:44 INFO mapreduce.ImportJobBase: Retrieved 3 records.
26/06/22 11:06:44 INFO manager.SqlManager: Executing SQL statement: SELECT t.* FROM `student` AS t LIMIT 1
26/06/22 11:06:44 WARN hive.TableDefWriter: Column createtime had to be cast to a less precise type in Hive
26/06/22 11:06:44 INFO hive.HiveImport: Loading uploaded data into Hive
26/06/22 11:06:45 INFO hive.HiveImport: which: no hbase in (/home/jdk1.8.0_144/bin:/home/hadoop-2.8.2/sbin:/home/hadoop-2.8.2/bin:/home/apache-hive-2.1.1-bin/bin:/home/sqoop-1.4.5-cdh5.3.6/bin:/home/jdk1.8.0_144/bin:/home/hadoop-2.8.2/sbin:/home/hadoop-2.8.2/bin:/home/apache-hive-2.1.1-bin/bin:/home/jdk1.8.0_144/bin:/home/hadoop-2.8.2/sbin:/home/hadoop-2.8.2/bin:/home/jdk1.8.0_144/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/server/flume/bin:/root/bin)
26/06/22 11:06:45 INFO hive.HiveImport: SLF4J: Class path contains multiple SLF4J bindings.
26/06/22 11:06:45 INFO hive.HiveImport: SLF4J: Found binding in [jar:file:/home/apache-hive-2.1.1-bin/lib/log4j-slf4j-impl-2.4.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
26/06/22 11:06:45 INFO hive.HiveImport: SLF4J: Found binding in [jar:file:/home/hadoop-2.8.2/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
26/06/22 11:06:45 INFO hive.HiveImport: SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
26/06/22 11:06:45 INFO hive.HiveImport: SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
26/06/22 11:06:47 INFO hive.HiveImport:
26/06/22 11:06:47 INFO hive.HiveImport: Logging initialized using configuration in jar:file:/home/apache-hive-2.1.1-bin/lib/hive-common-2.1.1.jar!/hive-log4j2.properties Async: true
26/06/22 11:06:52 INFO hive.HiveImport: OK
26/06/22 11:06:52 INFO hive.HiveImport: Time taken: 0.753 seconds
26/06/22 11:06:52 INFO hive.HiveImport: Loading data to table test.student6
26/06/22 11:06:53 INFO hive.HiveImport: OK
26/06/22 11:06:53 INFO hive.HiveImport: Time taken: 0.655 seconds
26/06/22 11:06:53 INFO hive.HiveImport: Hive import complete.
26/06/22 11:06:53 INFO hive.HiveImport: Export directory is not empty, keeping it.




*/


--hive-database <数据库名>：指定数据要导入到 Hive 的哪个数据库中（如果不加，默认导入到 default 库）24。
--hive-table <表名>：指定数据要导入到 Hive 的哪张表中（如果不加，默认使用 MySQL 的源表名）25。
--create-hive-table：如果 Hive 中还没有这张表，加上此参数可以让 Sqoop 自动建表（如果表已存在，不加此参数会报错）15。
--hive-overwrite：如果 Hive 表中已经存在数据，加上此参数会清空原有数据后再导入（覆盖写入）24。

sqoop import --connect "jdbc:mysql://master:3306/test?useSSL=false" --username root --password 123456 --table student --hive-import --hive-database test --hive-table student6 --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N'  --hive-overwrite

--使用灵活字段导入，必须要target-dir参数（因为原来有table参数会自动有一个hdfs路径，但现在他变了参数没了，临时的query必须要要显式指定），还需要--split-by
----hive-import下就是自动loaddata，如果--hive-table和--target-dir一样就会跳过移动文件的步骤，直接清理掉一些临时标记文件，然后成功返回
/*--如果把 --target-dir 设置成了 Hive 表的真实路径，千万不要在 Sqoop 命令里加 --delete-target-dir 参数！
--因为 --delete-target-dir 会在抽取前“简单粗暴”地删除整个物理目录。如果这个目录恰好是 Hive 表的底层存储目录，删除它会导致 Hive 表直接报错（表存在但找不到底层文件），甚至可能导致 Hive 元数据与物理数据不一致。*/

sqoop import --connect "jdbc:mysql://master:3306/test?useSSL=false" --username root --password 123456 --hive-import --hive-database test --hive-table student5 --split-by ',' --hive-overwrite --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --target-dir /user/hive/warehouse/test.db/student5 --query "select * from student where id=1"' and $CONDITIONS;'  

/*
--报错了
26/06/22 11:49:33 ERROR tool.ImportTool: Encountered IOException running import job: org.apache.hadoop.mapred.FileAlreadyExistsException: Output directory hdfs://master:9000/user/hive/warehouse/test.db/student5 already exists
*/
----num-mappers 1  只会启动一个 Map 任务，不需要--split-by
sqoop import --connect "jdbc:mysql://master:3306/test?useSSL=false" --username root --password 123456 --hive-import --hive-database test --hive-table student5 --hive-overwrite --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --target-dir /test/student2 --num-mappers 1 --query "select * from student where id=1"' and $CONDITIONS;'  

--使用--split-by，而且这样直接hive-import，临时的/test/student2是会自动删的
sqoop import --connect "jdbc:mysql://master:3306/test?useSSL=false" --username root --password 123456 --hive-import --hive-database test --hive-table student5 --hive-overwrite --fields-terminated-by ',' --null-string '\\N' --null-non-string '\\N' --target-dir /test/student2 --split-by id --query "select * from student where id=1 and \$CONDITIONS"  

/*
 --split-by 不是对已经 query 完的临时表数据进行切割，而是在数据抽取之前，指导 Sqoop 如何去源数据库（如 MySQL）进行“分片查询”。
当你指定了 --split-by id 并且设置了 -m 4（4个并发）时，Sqoop 并不是先执行 SELECT * FROM student 把所有数据拉下来再切分。
相反，Sqoop 会先向 MySQL 发送查询，获取 id 列的 MIN(id) 和 MAX(id)。
然后，它会根据这个范围，动态生成 4 条独立的 SQL 语句，分配给 4 个 Map 任务去 MySQL 并发执行：
Map 1: SELECT * FROM student WHERE id >= 0 AND id < 250
Map 2: SELECT * FROM student WHERE id >= 250 AND id < 500
Map 3: SELECT * FROM student WHERE id >= 500 AND id < 750
Map 4: SELECT * FROM student WHERE id >= 750 AND id <= 1000
所以，切割动作发生在源数据库端，而不是 HDFS 的临时表上。

先单线程把 1000 万条数据全部 query 出来放到临时表，然后再进行切割，那整个过程依然是单线程的，完全失去了 MapReduce 并行计算的意义。
--split-by 的本质，就是把“大查询”拆解成多个“小查询”，让多个 Map 任务同时去压榨源数据库的 IO，从而成倍提升数据抽取的速度。
*/

/*sqoop是针对 JDBC 数据库抽取场景，补齐了 Hadoop 原生无法感知外部数据库结构的短板。*/
/*MapReduce 最强大的能力不仅仅是计算，而是它天生具备任务切分、并发执行、容错重试的机制。
当你指定 -m 4 时，Sqoop 需要启动 4 个并发任务去连接 MySQL 拉取数据。如果不用 MapReduce，Sqoop 就需要自己写一套复杂的分布式调度系统。而直接复用 YARN + MapReduce 框架，Sqoop 只需要把“抽取数据”的逻辑塞进 Map 阶段即可，YARN 会自动帮它把这 4 个任务分配到集群的不同节点上并发运行。*/