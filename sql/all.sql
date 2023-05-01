# Master configuration
CREATE USER IF NOT EXISTS 'slave-1'@'%' IDENTIFIED BY 'slave';
CREATE USER IF NOT EXISTS 'slave-2'@'%' IDENTIFIED BY 'slave';
GRANT REPLICATION SLAVE ON *.* TO 'slave-1'@'%';
GRANT REPLICATION SLAVE ON *.* TO 'slave-2'@'%';
FLUSH PRIVILEGES;

# Slave 1 configuration
# Take MASTER_LOG_FILE and MASTER_LOG_POS from "SHOW MASTER STATUS" in master server
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST ='mysql-master', MASTER_USER ='slave-1',
    MASTER_PASSWORD ='slave', MASTER_LOG_FILE ='', MASTER_LOG_POS =0;
START SLAVE;

# Slave 2 configuration
# Take MASTER_LOG_FILE and MASTER_LOG_POS from "SHOW MASTER STATUS" in master server
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST ='mysql-master', MASTER_USER ='slave-1',
    MASTER_PASSWORD ='slave', MASTER_LOG_FILE ='', MASTER_LOG_POS =0;
START SLAVE;

SHOW MASTER STATUS;
SHOW SLAVE STATUS;

SELECT COUNT(*) FROM db_replication_test.users;

ALTER TABLE db_replication_test.users DROP COLUMN name;
