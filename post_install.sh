#!/bin/bash

set -x

date
start_date=$(date)

chmod 755 ./start_web.sh

postgres_user=$(echo ${DATABASE_URL} | awk -F':' '{print $2}' | sed -e 's/\///g')
postgres_password=$(echo ${DATABASE_URL} | grep -o '/.\+@' | grep -o ':.\+' | sed -e 's/://' | sed -e 's/@//')
postgres_server=$(echo ${DATABASE_URL} | awk -F'@' '{print $2}' | awk -F':' '{print $1}')
postgres_dbname=$(echo ${DATABASE_URL} | awk -F'/' '{print $NF}')

echo ${postgres_user}
echo ${postgres_password}
echo ${postgres_server}
echo ${postgres_dbname}

export PGPASSWORD=${postgres_password}

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
CREATE TABLE t_pattern (
 pattern_id int primary key
,preg_match_pattern character varying(255) NOT NULL
,preg_replace_pattern character varying(255)
,replacement character varying(255)
);
__HEREDOC__
cat /tmp/sql_result.txt

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
CREATE TABLE m_pattern (
 pattern_id serial primary key
,preg_match_pattern character varying(512) NOT NULL
,record_type int NOT NULL
);
__HEREDOC__
cat /tmp/sql_result.txt

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
CREATE TABLE t_link (
 uri character varying(512) primary key
,create_time timestamp DEFAULT localtimestamp NOT NULL
);
__HEREDOC__
cat /tmp/sql_result.txt

# ***** phppgadmin *****

pushd www
git clone --depth 1 https://github.com/phppgadmin/phppgadmin.git phppgadmin
cp ../config.inc.php phppgadmin/conf/
cp ../Connection.php phppgadmin/classes/database/
popd

echo ${start_date}
date
