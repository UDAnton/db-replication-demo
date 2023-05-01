import mysql.connector
import logging
import schedule

from faker import Faker

logging.basicConfig(level=logging.INFO, filemode='w', format='%(message)s')

db_master_connection = mysql.connector.connect(host='localhost', port=3306, user='root', password='root', database='db_replication_test')

db_master_connection_cursor = db_master_connection.cursor()

user_table_query = """
CREATE TABLE IF NOT EXISTS users
(
    id         INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       varchar(255) NOT NULL,
    birth_year DATE         NOT NULL,
    email      varchar(255) NOT NULL,
    address    varchar(255) NOT NULL
) ENGINE = InnoDB;
"""
db_master_connection_cursor.execute(user_table_query)
db_master_connection.commit()

fake = Faker()


def create_user():
    user_query = "INSERT INTO users (name, birth_year, email, address) VALUES (%s, %s, %s, %s)"
    user = [fake.name(), fake.date(), fake.email(), fake.address()]
    logging.info(f'Created user: {user}')
    db_master_connection_cursor.execute(user_query, user)
    db_master_connection.commit()


schedule.every(2).seconds.do(create_user)

while True:
    schedule.run_pending()
