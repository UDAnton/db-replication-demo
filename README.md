# DB replication demo

## Replication configuration

---
1. Start up 3(master, slave-1, slave-2) mysql docker containers:
   ```
   docker-compose up -d
   ```
2. Connect to `mysql-master` server and run sql commands:
   ```
   CREATE USER IF NOT EXISTS 'slave-1'@'%' IDENTIFIED BY 'slave';
   CREATE USER IF NOT EXISTS 'slave-2'@'%' IDENTIFIED BY 'slave';
   GRANT REPLICATION SLAVE ON *.* TO 'slave-1'@'%';
   GRANT REPLICATION SLAVE ON *.* TO 'slave-2'@'%';
   FLUSH PRIVILEGES;
   ```
3. Check master status running commands and save "File", "Position":
   ```
   SHOW MASTER STATUS
   ```
   ![Alt text](report/master-status.png)
4. Connect to `mysql-slave-1` and `mysql-slave-2` server and run sql commands where MASTER_USER='slave-1'/'slave-2', MASTER_LOG_FILE="File" and  MASTER_LOG_POS="Position" from master status:

   ```
   STOP SLAVE;
   CHANGE MASTER TO MASTER_HOST ='mysql-master', MASTER_USER ='slave-1', MASTER_PASSWORD ='slave', MASTER_LOG_FILE ='mysql-bin.000003', MASTER_LOG_POS =1399;
   START SLAVE;
   ```

5. Check that Slave_IO_Running and Slave_SQL_Running have "Yes" value:
   ```
   SHOW SLAVE STATUS
   ````
   ![Alt text](report/slaves-status.png)
## Test results
Build and run demo application:
1. Install libs ```pip install mysql.connector Faker schedule```;
2. Start script ```python3 db-replication-demo-script.py```;
3. Connect to `mysql-master`, `mysql-slave-1` and `mysql-slave-2`, run ```SELECT COUNT(*) FROM db_replication_test.users``` and check that all servers contains data;
4. Stop `mysql-slave-1` or `mysql-slave-2`;
5. Start slave again, run ```SELECT COUNT(*) FROM db_replication_test.users``` and compare data with master data;
6. Connect to `mysql-slave-1` to `mysql-slave-2`, run ```ALTER TABLE db_replication_test.users DROP COLUMN name```
7. Check logs in slave server.
```
2023-05-01 09:27:01 2023-05-01T06:27:01.704459Z 12 [ERROR] [MY-013146] [Repl] Replica SQL for channel '': Worker 1 failed executing transaction 'ANONYMOUS' at source log mysql-bin.000003, end_log_pos 7123; 
Column 1 of table 'db_replication_test.users' cannot be converted from type 'varchar(1020(bytes))' to type 'date', Error_code: MY-013146
```
