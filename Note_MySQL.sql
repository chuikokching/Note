NoSQL:Redis(内存):存放优先级较高的数据. MongoDB(硬盘):存放优先级较低的数据

MySQL:my.ini(配置文件)

#架构!!!!!!
PXC (percona xltraDB cluster): 任意数据库节点都是可读可写 节点之间相互同步数据
Replication : 读写分离,分为master(写)和slave(读)

create user 'ccpcuser'@'10.228.%' identified by '*ccpcMDB1*'
show grants for root;  // show grants 查看自身权限
grant .....(root的全部权限) to 'ccpcuser'@'10.228.%' WITH GRANT OPTION; //可以为别的账号授权
grant all privileges on 库名.*(表名) to '用户名'@'%' identified by '密码';
grant update,select on hwstore_admin_gray.* to 'hwstore_admin'@'%';
grant replication slave on *.* to 'repl'@'192.168.0.109' identified by 'repl';
flush privileges;
select * from mysql.user \G;

source 文件路径和文件 用于导入sql文件

DDL (Data Definition Language):
Create database XXX;
Show databases;
Drop database XXX;
Show tables;
use XXX;
desc XXX;
drop table XXX;
show create table XXX;
show create database XXX;

#查看主从库 读写分离 主库写 从库读   如果是从库,该记录会有输出
mysql> show slave status\G;
*************************** 1. row ***************************
Slave_IO_State:
Master_Host: 10.200.212.66
Master_User: repl
Master_Port: 3306
Connect_Retry: 60
Master_Log_File: mysql-bin.000004
Read_Master_Log_Pos: 150641419
Relay_Log_File: mysql-relay-bin.000009
Relay_Log_Pos: 4
Relay_Master_Log_File: mysql-bin.000004
Slave_IO_Running: No
Slave_SQL_Running: Yes
Replicate_Do_DB:
Replicate_Ignore_DB:
Replicate_Do_Table:
Replicate_Ignore_Table:
Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
Last_Errno: 0
Last_Error:
Skip_Counter: 0
Exec_Master_Log_Pos: 150641419
Relay_Log_Space: 240
Until_Condition: None
Until_Log_File:
Until_Log_Pos: 0
Master_SSL_Allowed: No
Master_SSL_CA_File:
Master_SSL_CA_Path:
Master_SSL_Cert:
Master_SSL_Cipher:
Master_SSL_Key:
Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
Last_IO_Errno: 2003
Last_IO_Error: error connecting to master 'repl@10.200.212.66:3306' - retry-time: 60 retries: 86400
Last_SQL_Errno: 0
Last_SQL_Error:
Replicate_Ignore_Server_Ids:
Master_Server_Id: 0
Master_UUID: 2e3c5fc9-8b01-11e8-a7f2-005056a6ac0b
Master_Info_File: /db/mysql/data/mydata/master.info
SQL_Delay: 0
SQL_Remaining_Delay: NULL
Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
Master_Retry_Count: 86400
Master_Bind:
Last_IO_Error_Timestamp: 191016 18:07:25
Last_SQL_Error_Timestamp:
Master_SSL_Crl:
Master_SSL_Crlpath:
Retrieved_Gtid_Set:
Executed_Gtid_Set: 2e3c5fc9-8b01-11e8-a7f2-005056a6ac0b:1-163031,
3d838987-8b2e-11e8-a918-005056a671cc:1-48721749
Auto_Position: 1
1 row in set (0.00 sec)


mysql> SHOW MASTER STATUS\G; #主库read_only状态一般是off.
+------------------+-----------+--------------+------------------+------------------------------------------------------------------------------------------------+
| File | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+-----------+--------------+------------------+------------------------------------------------------------------------------------------------+
| mysql-bin.000259 | 416932786 | | | 2e3c5fc9-8b01-11e8-a7f2-005056a6ac0b:1-163031,
3d838987-8b2e-11e8-a918-005056a671cc:1-48730726 |
+------------------+-----------+--------------+------------------+------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> show variables like 'read_only';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| read_only | OFF |
+---------------+-------+
1 row in set (0.00 sec)


#查看端口号
show global variables like 'port';
vim /etc/my.cnf;

use test;
Create table student{
    id INT unsigned primary key,
    name varchar(20) not null,
    sex char(1) not null,
    birthday date not null,
    tel char(11) not null,
    remark varchar(200)
};

#数据库backup备份
create table student_bak like student;
insert into student_bak select * from student;

插入数据
insert into student values (1,'',''),(2,'',''),(3,'','');
Ignore 忽略报错的语句继续插入数据,只插入不存在的数据 (具体可通过Affected rows判断)
insert ignore into student(字段,字段,字段) values ('','',''),('','',''),('','','');

清空表
Truncate table 表名;

删除数据
delete [ignore] from student where name ='....' order by xxx desc limit 3;

#删除XXX部门的全部员工记录
delete e,d from t_tmp e JOIN t_dep d ON e.department_id = d.department_id where d.name="XXX"
#删除每个低于部门平均薪金的员工
delete e from t_tmp e JOIN (select department_id , AVG(salary) as salary from t_tmp group by department_id) t
ON e.department_id = t.department_id AND e.salary < t.salary

#删除king和他的直辖下属记录
delete e from t_tmp e JOIN (select id from t_tmp where name = "King") d ON e.mgrid = d.id OR e.id = d.id;
#删除XXX部门员工,以及没有部门的员工
delete e from t_tmp e LEFT JOIN t_dep d ON e.department_id = d.department_id where d.name = "XXX" or e.department_id is null

修改数据
update 表名 set 字段=值,字段=值,字段=值;

#所有编号+1;
update t_tmp set id=id+1 , department_id=department_id+1 order by e.id desc;
#前3加300薪金;
update t_tmp set salary=salary+300 order by salary+IFNULL(comm,0) desc limit 3;

update 表1 JOIN 表2 ON 条件 set 字段=值,字段=值,字段=值;
update 表1 JOIN 表2 set 字段=值,字段=值,字段=值 where 条件;

*虽为表连接,但并不用写ON条件 具体问题具体分析
update t_tmp e JOIN t_dep d set e.department_id = d.department_id, e.job="XXX" 
where d.department_id="XXX" AND e.name="XXX";

#低于平均水准的都加50
update t_tmp e JOIN (select AVG(salary) as avg from t_tmp) t ON e.salary<t.avg set e.salary=e.salary+50;
#把没有部门的员工,或者XXX部门低于2000的员工,都调往20部门
update t_tmp e LEFT JOIN t_dep d ON e.department_id=d.department_id set e.department_id=20
where e.department_id IS NULL OR (d.dname = "XXX" and e.salary<=2000);

执行顺序:
update ->where ->order by ->limit  

修改表结构
alter table student
add address varchar(200) not null,
add home_tel char(11) not null;

修改字段类型
alter table student
modify home_tel varchar(11) not null;


修改字段名称
alter table student
change address home_address varchar(11) not null;

删除字段
alter table student 
drop home_tel,
drop home_address;

设计范式
1. 原子性(姓名 = 姓 + 名)
2. 唯一性(设置主键)
3. 字段间不存在依赖,只能依赖于主键 (主键检索速度快,自带索引功能)

主键：全表唯一 不能为null 建议数字类型,因为检索速度快 id INT primary key AUTO_INCREMENT
NUll: married Boolean(实际为tinyint, 0 or 1) not null default false
UNIQUE: 全表唯一 可为null tel varchar(20) not null UNIQUE
外键：Foreign key (字段) references 表名(字段) (保证两张表的逻辑关系 例如 部门和员工)
注意闭环问题,类似死锁,数据因外键约束无法删除

索引 (2分查找法树形结构)
(1).针对数据量大,经常被查询的数据表,读多写少  (日志表不适合,因为查询少 更多的是增删改)
(2).经常被用作检索的字段合适 (商品查询)
(3).大字段不合适 varchar(50)
建表时
Index [索引名称](字段) 

建表后
Create index 索引名称 on 表名(字段)
Alter table 表名 add index [索引名称](字段) 
Show index from 表名
Drop index 索引名称 on 表名

控制结果集范围(数据分页)
select * from t_tmp limit 0(起始位置),5(偏移量)
select * from t_tmp limit 5(偏移量)

执行顺序
from -> select -> order by -> limit

按照某一个字段进行排序输出
select * from t_tmp order by (字段) desc;
select * from t_tmp order by (字段) asc;
可规定多个排序规则
select * from t_tmp order by (字段) asc,(字段) desc,(字段) asc;

去除重复记录
select distinct 字段 from t_tmp;
多个字段情况下distinct可能会失效,因为其他字段会不同,系统认为有区别,且必须写在首个字段前面
select distinct 字段1,字段2 from t_tmp; (可能失效)
select 字段1, distinct 字段2 from t_tmp; (错误)

IFNULL(字段,0) 如果字段为null,则返回0
select * from t_tmp where tuition+IFNULL(dorm_money,0)>=400 AND tuition+IFNULL(dorm_money,0)>=500;
select * from t_tmp where tuition+IFNULL(dorm_money,0) between 400 AND 500;
DATEDIFF(字段1,字段2) 返回两个日期字段相差的天数 # /365
select 字段 from t_tmp where 条件 AND salary+(IFNULL(字段,0))>=50000 AND DATEDIFF(NOW(),日期字段)

where
1. 字段 is null
2. 字段 is not null
3. 字段 between 200 AND 300
4. 字段 like "%A%" (%：0-∞) like "A%","%A","_ack"
5. 字段 REGEXP "^[\\u4e00-\\u9fa5]{2,4}$" 
(^:字符串开头,$:字符串结尾,[\\u4e00-\\u9fa5]代表所有中文名字集合,名字2-4个字)
[a-zA-Z]{0,10} or [a-zA-Z]{5}, ^[a-l]+s$(以a-l开头,以s结尾)

where 条件优先级 1. 索引 2. 筛选掉最多记录的条件 3. 普通检索条件
执行顺序
from -> where -> select -> order by -> limit

union 进行多表查询 选出多表中不同的值
SELECT country FROM Websites
UNION
SELECT country FROM apps
ORDER BY country;
country : cn ,usa, jap

union all 进行多表查询 包含相同的值
SELECT country FROM Websites
UNION ALL
SELECT country FROM apps
ORDER BY country;
country : cn ,cn ,cn ,usa, usa, jap, jap, jap

聚合函数 *聚合函数不能出现在WHERE,ON子句当中
AVG(salary+IFNULL(字段,0))
SUM(字段)
MAX(字段)
MIN(字段)
MAX(Length())
select FLOOR(9.3) *向下取整
select CEIL(9.3) *向上取整


count(字段)：统计字段非空值记录行数
count(*): 包含空值记录行数 一般可用于统计满足某些条件的记录行数
select count(*) from where id in(10,20) 

分组查询 *select当中的字段内容要匹配group by的字段
select department_id,Round(AVG(salary)) from t_tmp group by department_id;
select department_id,job , count(*),AVG(*) from t_tmp group by department_id,job order by department_id

WITH ROLLUP: 对group by结果进行再次统计
select department_id, count(*),AVG(*),MIN(*), MAX(*) from t_tmp group by department_id with rollup

针对count(*)和group by的非分组字段,可以用group_concat()把非分组字段进行链接
select department_id, count(*), group_concat(name) from t_tmp where salary>=2000 group by department_id 

执行顺序：
from -> where -> group by -> select -> order by -> limit

HAVING *必须依赖group by子句 和where比较主要针对group by的时候HAVING支持聚合函数

select department_id from t_tmp group by 1 HAVING AVG(salary)>=2000; #group by 第一个字段
select department_id , count(*) from t_tmp group by 1; (1代表按照第一个字段进行分组)
select department_id , count(*) from t_tmp group by 1 HAVING department_id in (10,20);

表连接查询
三种变形
select e.name,e.id ,d.dname from t_tmp e join t_dep d on e.department_id = d.department_id;
select e.name,e.id ,d.dname from t_tmp e join t_dep d where e.department_id = d.department_id;
select e.name,e.id ,d.dname from t_tmp e , t_dep d where e.department_id = d.department_id;

inner join (多张表的交集)
select e.id,e.name,..... from t_tmp e join t_dep d ON e.department_id=d.department_id
join t_smp s ON e.salary between s.lowsal AND s.highsal *没有同名字段也可以连接,主要是逻辑关系

相同的表也可以自连接 P.S. 查找与SCOTT相同部门的员工
select e2.name from t_tmp e1 join t_tmp e2 ON e1.department_id = e2.department_id
where e1.name = "scott" AND e2.name != "scott"

底薪超过公司平均底薪
select e.id,e.name,e.salary from t_tmp e JOIN (select AVG(salary) as avg from t_tmp) t ON e.salary>=t.avg;
底薪超过部门平均底薪
select e.id,e.name,e.salary from t_tmp e JOIN (select department_id,AVG(salary) as avg from t_tmp) t 
ON e.department_id=t.department_id AND e.salary>=t.avg;

查询部门名称和部门人数
LEFT JOIN
select d.name,count(e.department_id) from t_dep d LEFT JOIN t_tmp e 
ON d.department_id = e.department_id group by d.department_id;

select e.id,e.name,d.name from t_tmp e LEFT JOIN t_dep d ON e.department_id = d.department_id WHERE e.department_id=10;

RIGHT JOIN
select d.name,count(e.department_id) from t_dep d RIGHT JOIN t_tmp e 
ON d.department_id = e.department_id group by d.department_id;

子查询 *不推荐在WHERE,SELECT条件中使用 推荐在from中使用,通过结果集构建新表
select e.id,e.name,salary from t_tmp where salary>=(select AVG(salary) from t_tmp);

select e.id,e.name,e.salary,t.avg from t_tmp e JOIN 
(select department_id,AVG(sal) as avg from t_tmp group by department_id) t 
ON e.department_id = t.department_id where e.salary >= t.avg;

结果集当中大于其中任意一个 *任意
select e.name from t_tmp where salary >= ANY (select salary from t_tmp where e.name IN ("BB","AA")) AND e.name NOT IN ("BB","AA");
结果集全部大于 *所有
select e.name from t_tmp where salary >= ALL (select salary from t_tmp where e.name IN ("BB","AA")) AND e.name NOT IN ("BB","AA");

日期函数
select NOW() 获取年月日 秒时分
select CURDATE() 获取年月日
select CURTIME() 获得秒时分
select DATE_FORMAT("date",%Y%m%d) 
select DATE_FORMAT("2021/11/11",%W) 
select DATE_ADD(DATE_ADD(NOW(),INTERVAL -6 MONTH),INTERVAL 100 DAY) #日期偏移
UPDATE tpl_user_role_program_t set END_DATE = DATE_ADD(END_DATE, INTERVAL 3 YEAR) WHERE USER_ID = ;

字符函数
select CONCAT(salary,"$") 连接字符串
select LPAD(substring("133328289893",8,4),11,"*"); #左侧填充字符 *********9893
select RPAD(); #右侧填充字符 用法同上
select concat(rpad(substring(),length(),"*"),"");

条件函数
select e.id,e.name,
   CASE
      when d.name="a" then "p1" 
      when d.name="b" then "p2" 
      when d.name="c" then "p3" 
   END AS place
from t_tmp e JOIN t_dep d ON e.department_id  = d.department_id;

update ... set salary=(case ......)

事务机制
undo->redo
undo日志 拷贝数据 万一出现意外,可把数据恢复回滚到主服务器
redo日志 记录修改 比如update,delete 没有问题后同步到主服务器

ACID  (atomicity, consistency, isolation, durability)
原子性:要么全部成功,要么全部失败 不允许停留在中间状态
一致性:并发下不会出现数据歧义
隔离性:undo redo日志中数据被分别标记属于哪个事务
持久性:事务一旦提交,结构便是永久性的

4个隔离级别:
read uncommitted 允许读取其他事务未提交的数据 比如 A已买车票并订某个车位,记录在redo日志,事务未提交,B能查看A的redo日志,避免重复订购
set session transaction isolation level read uncommitted
Start transaction;
select id,name,salary from t_tmp;
commit;
rollback; #回滚只针对当前事务处理session内使用

read committed 只能读取其他事务提交的数据 比如 银行转账 事务A +1000 事务B -100 假如B rollback,A又读取了还没提交的B 则账号凭空少100
set session transaction isolation level read committed

repeatable read(默认) 只读取了事务开始前的数据,在这个数据集当中循环,运行过程中不会受到其他事务影响 比如 下单后,店主更改了商品价格 客户按照原来价格购买
注意undo日志里是否已有copy数据备份,没有的话仍然会从主服务器提取数据 造成提取了其他事务已经committed的数据
set session transaction isolation level repeatable read

serializable 数据库并发性下降 比如事务2会等待1 commit或者rollback后再执行
set session transaction isolation level serializable

数据库备份
全量备份 增量备份 

数据库导出
show create table XXX;
mysqldump -uroot -p [no-data] 逻辑库 > 路径 #no-data 只导出表结构 使用mysqldump需要配置环境变量
mysqldump -uroot -p demo > D:/data/demo.sql
mysqldump -h 10.40.20.144 –uroot –p -B forum_global > /forum/backup/forum_global.sql

视图View:
作用一：
    提高了重用性，就像一个函数。如果要频繁获取user的name和goods的name。就应该使用以下sql语言。示例：
        select a.name as username, b.name as goodsname from user as a, goods as b, ug as c where a.id=c.userid and c.goodsid=b.id;
    但有了视图就不一样了，创建视图other。示例
        create view other as select a.name as username, b.name as goodsname from user as a, goods as b, ug as c where a.id=c.userid and c.goodsid=b.id;
    创建好视图后，就可以这样获取user的name和goods的name。示例：
        select * from other;
    以上sql语句，就能获取user的name和goods的name了。
作用二：
    对数据库重构，却不影响程序的运行。假如因为某种需求，需要将表usera和表userb重新组合，该两张表的结构如下：
        测试表:usera有id，name，age字段
        测试表:userb有id，name，sex字段
    这时如果php端使用sql语句：select * from user;那就会提示该表不存在，这时该如何解决呢。解决方案：创建视图。以下sql语句创建视图：
        create view user as select a.name,a.age,b.sex from usera as a, userb as b where a.name=b.name;
        
作用三：
    提高了安全性能。可以对不同的用户，设定不同的视图。例如：某用户只能获取user表的name和age数据，不能获取sex数据。则可以这样创建视图。示例如下：
        create view other as select a.name, a.age from user as a;
    这样的话，使用sql语句：select * from other; 最多就只能获取name和age的数据，其他的数据就获取不了了。

View: tpl_sc_group_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_sc_group_v` AS select `tpl_sc_v`.`user_id` AS `user_id`,`tpl_sc_v`.`scope` AS `scope` from `tpl_sc_v` group by `tpl_sc_v`.`user_id`,`tpl_sc_v`.`scope`
character_set_client: utf8
collation_connection: utf8_general_ci

View: tpl_sc_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_sc_v` AS select `p`.`USER_ID` AS `user_id`,`rt`.`SCOPE` AS `scope` from (`tpl_role_t` `rt` join `tpl_user_role_program_t` `p`) where ((`p`.`ROLE_ID` = `rt`.`ROLE_ID`) and (`rt`.`STATUS` = 1) and (cast(`p`.`END_DATE` as date) >= cast(now() as date))) union select `ug`.`USER_ID` AS `user_id`,`g`.`APP_NAME` AS `scope` from (`tpl_group_t` `g` join `tpl_user_group_t` `ug`) where ((`g`.`GROUP_ID` = `ug`.`GROUP_ID`) and (cast(`ug`.`END_DATE` as date) >= cast(now() as date)))
character_set_client: utf8
collation_connection: utf8_general_ci

View: tpl_user_group_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_user_group_v` AS select `u`.`W3_ACCOUNT` AS `account`,`g`.`NAME` AS `groupname`,`ug`.`USER_ID` AS `user_id`,`ug`.`GROUP_ID` AS `id`,`ug`.`BEGIN_DATE` AS `begin_date`,`ug`.`END_DATE` AS `end_date`,`g`.`APP_NAME` AS `app_name` from ((`tpl_user_t` `u` join `tpl_group_t` `g`) join `tpl_user_group_t` `ug`) where ((`u`.`USER_ID` = `ug`.`USER_ID`) and (`g`.`GROUP_ID` = `ug`.`GROUP_ID`) and (cast(`ug`.`END_DATE` as date) >= cast(now() as date)))
character_set_client: utf8
collation_connection: utf8_general_ci

View: tpl_user_role_program_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_user_role_program_v` AS select `u`.`W3_ACCOUNT` AS `account`,`p`.`PROGRAM_ID` AS `payroll_id`,`pt`.`NAME` AS `payroll_name`,`pt`.`DESCRIPTION` AS `description`,`p`.`ROLE_ID` AS `responsibility_id`,`p`.`BEGIN_DATE` AS `begin_date`,`p`.`END_DATE` AS `end_date`,`p`.`LAST_UPDATE_DATE` AS `last_update_date`,`rt`.`SCOPE` AS `scope` from (((`tpl_user_role_program_t` `p` join `tpl_role_t` `rt`) join `tpl_program_t` `pt`) join `tpl_user_t` `u`) where ((`p`.`USER_ID` = `u`.`USER_ID`) and (`p`.`ROLE_ID` = `rt`.`ROLE_ID`) and (`p`.`PROGRAM_ID` = `pt`.`PROGRAM_ID`) and (`rt`.`SCOPE` = `pt`.`SCOPE`) and (`rt`.`STATUS` = 1) and (`pt`.`STATUS` = 1) and (cast(`p`.`END_DATE` as date) >= cast(now() as date)))
character_set_client: utf8
collation_connection: utf8_general_ci

View: tpl_user_role_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_user_role_v` AS select `u`.`W3_ACCOUNT` AS `ACCOUNT`,max(`rt`.`ROLE_NAME`) AS `RESPONSIBILITY`,`p`.`ROLE_ID` AS `RESPONSIBILITY_ID`,max(`rt`.`AREA_CODE`) AS `DESCRIPTION`,max(`p`.`BEGIN_DATE`) AS `BEGIN_DATE`,max(`p`.`END_DATE`) AS `END_DATE`,max(`p`.`LAST_UPDATE_DATE`) AS `LAST_UPDATE_DATE`,max(`rt`.`SCOPE`) AS `scope` from ((`tpl_user_role_program_t` `p` join `tpl_role_t` `rt`) join `tpl_user_t` `u`) where ((`p`.`ROLE_ID` = `rt`.`ROLE_ID`) and (`p`.`USER_ID` = `u`.`USER_ID`) and (`rt`.`STATUS` = 1) and (cast(`p`.`END_DATE` as date) >= cast(now() as date))) group by `u`.`W3_ACCOUNT`,`p`.`ROLE_ID`
character_set_client: utf8
collation_connection: utf8_general_ci

View: tpl_user_v
Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tpl_user_v` AS select `sc`.`scope` AS `app_name`,`u`.`W3_ACCOUNT` AS `account`,0 AS `is_public_account`,`u`.`EMPLOYEE_NUMBER` AS `user_account`,'' AS `duty_id`,`u`.`START_DATE` AS `valid_begin_date`,`u`.`END_DATE` AS `valid_end_date`,`u`.`LAST_UPDATE_DATE` AS `last_update_date`,'W3' AS `auth_type`,'1' AS `is_cancel` from (`tpl_user_t` `u` join `tpl_sc_group_v` `sc`) where ((`sc`.`user_id` = `u`.`USER_ID`) and (not((`u`.`TYPE` like '%E/_%'))))
character_set_client: utf8
collation_connection: utf8_general_ci

#存储过程
DROP PROCEDURE IF EXISTS AddColumnUnlessExists;
delimiter $$
CREATE PROCEDURE AddColumnUnlessExists ( IN dbName TINYTEXT, IN tableName TINYTEXT, IN fieldName TINYTEXT, IN fieldDef text , IN commentDef text) BEGIN
    IF
        NOT EXISTS ( SELECT * FROM information_schema.COLUMNS WHERE column_name = fieldName AND table_name = tableName AND table_schema = dbName ) THEN
            
        SET @ddl = CONCAT( 'ALTER TABLE ', dbName, '.', tableName, ' ADD COLUMN ', fieldName, ' ', fieldDef, ' COMMENT ', commentDef );
        PREPARE stmt 
        FROM
            @ddl;
        EXECUTE stmt;   
    END IF; 
END$$
delimiter ;
call AddColumnUnlessExists(DATABASE(), 'sgw_service_signature', 'uuid', 'varchar(50) DEFAULT NULL','"随机生成的uuid"');
call AddColumnUnlessExists(DATABASE(), 'sgw_signature_verification', 'uuid', 'varchar(50) DEFAULT NULL','"随机生成的uuid"');
call AddColumnUnlessExists(DATABASE(), 'sgw_cfg_service_dispatch', 'service_signature_uuid', 'varchar(50) DEFAULT NULL','"关联的服务签名uuid"');
call AddColumnUnlessExists(DATABASE(), 'sgw_cfg_service', 'signature_verification_uuid', 'varchar(50) DEFAULT NULL','"关联的签名验签uuid"');
call AddColumnUnlessExists(DATABASE(), 'sgw_service_grant_info', 'grant_tag', 'int(1) DEFAULT 0','"是否取消授权，1 是取消授权"');
call AddColumnUnlessExists(DATABASE(), 'sgw_service_signature', 'app_code', 'varchar(50) DEFAULT NULL','"app_code"');
call AddColumnUnlessExists(DATABASE(), 'sgw_signature_verification', 'app_code', 'varchar(50) DEFAULT NULL','"app_code"');

#使用concat()拼接多个字段为新字段并进行group by统计
select count(*),concat(first_name,last_name,profession) AS new_string from promo_user_center_info where first_name is not null AND last_name is not null AND profession is not null group by new_string Having count(*)>=2 limit 100;

select count(*),concat(first_name,last_name,profession) AS new_string from promo_user_center_info group by new_string Having new_string=



MySQL 8.0 New Features

1.创建用户和用户授权命令需要分开执行：
    create user 'ckc'@'%' identified by 'chuikokching';
    grant all privileges on *.* to 'ckc'@'%'

2.默认身份认证插件是caching_sha2_password, 替代了之前的mysql_native_password.
    show variables like 'default_authentication%'
    alter user 'ckc'@'%' identified with mysql_native_password by 'chuikokching';

3.密码管理
    desc mysql.password_history

4.角色管理 (权限的集合, 用户可套用不同角色, 实现用户权限高效管理)
    create role 'read_role'
    select * from mysql.user //角色实际上也是用户
    grant select,insert on *.* to 'read_role'
    grant 'read_role' to 'ckc'
    show grants for 'ckc' using 'read_role'
    show grants for 'read_role'
    select user(); // 为none,则角色没有激活
    set role 'read_role' //切换角色后才能查询
    set default role 'read_role' to 'ckc' //默认登录角色
    select * from mysql.default_roles;
    select * from mysql.role_edges; //查看用户角色信息
    revoke insert on *.* from 'read_role' 

5.隐藏索引 invisible index
    应用场景：软删除 灰度发布
    explain select * from t1 where j=1 //查看key字段的值是否为索引,或者为NULL 查询净化器使用索引的情况
    select @@optimizer_switch => use_invisible_indexed=on
    set session optimizer_switch="use_invisible_indexed=on"
    alter table t1 alter index j_idx visible|invisible

6.降序索引 descending index
    group by 的字段不再进行自动排序 需要添加order by;
    create table t2(c1 int, c2 int , index idx1(c1 asc, c2 desc)) //提高排序性能 
    explain select * from t2 order by c1,c2 desc;   

7.函数索引 
    create index func_idx on t3 ( (UPPER(c2)) );
    explain select * from t3 where upper(c2)='ABC'  
    alter table t3 add column c3 varchar(10) generated always as (upper(c1))  
    create index idx3 on t3(c3)
    explain select * from t3 where upper(c1)='ABC' //虚拟链
 
8.非递归CTE
    select * from (select 1) as dt;
    with cte as (select 1) select * from cte;

    with cte1(id) as (select 1), cte2(id) as (select id+1 from cte1)  
    select * from cte1 join cte2;

9.递归CTE
    可用于模拟生成数据
    with recursive cte(n) as(
        select 1
        union all
        select n+1 from cte where n < 10
    )
    select * from cte;

    适用于查询上下级关系链路的场景
    with recursive employee_paths(id,name,path) as(
        select id,name,cast(id as char(200)) //基础数据
        from employees
        where manager_id is null
        union all
        select e.id , e.name, concat(ep.path,',',e.id)
        from employee_paths as ep join employees as e
        on ep.id = e.manager_id
        )
        select * from employee_paths order by path

    *默认存在递归上限界限

10. 窗口函数 (分析函数) 适合做报表
    



