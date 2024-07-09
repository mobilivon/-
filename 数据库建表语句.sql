create database braille;
use braille;

-- 用户表
create table user (
  id varchar(30) primary key comment 'ID',
  password varchar(32) comment '密码',
  name varchar(10) not null comment '姓名',
  age int unsigned comment '年龄',
  gender tinyint comment '性别,1是男，2是女',
  phone varchar(11)  not null comment '手机号',
  identity tinyint unsigned comment '身份, 说明: 0 超级管理员， 1 教师/管理员 2，普通用户/学生',
  vx_id varchar(30) comment '微信id',
  create_time datetime not null comment '创建时间'
) comment '用户表';

-- 班级表
create table class(
    class_id int unsigned unique comment '班级号',
    teacher_id  varchar(30)  comment '老师id',
    s_today_time int default(0) comment '学生今日学习时长',
    s_sum_time int default(0) comment '学生总的学习时长',
    s_number int unsigned default(0)  comment '学生人数',
    create_time datetime not null comment '创建时间'
) comment '班级表';


-- 班级通知表
create table class_notification(
    id int auto_increment primary key comment '编号',
    class_id int unsigned comment '班级号',
    c_time datetime comment '通知创建的时间',
    n_time date comment '通知设置的时间',
    notification varchar(50) comment '通知',
    number int unsigned  default(0) comment '查看人数',
    foreign key (class_id) references class(class_id)
) comment '班级通知表';

-- 学生 - 班级表
create table user_class (
    user_id varchar(30) comment '用户id',
    name varchar(10) comment '姓名',
    class_id int unsigned comment '班级号',
    remind int default 0 comment '一键提醒',
    accomplish int default 0 comment '是否完成任务',
    foreign key (user_id) references user(id),
    foreign key (class_id) references class(class_id)
) comment '班级表';



# -- 开启大小写敏感
# ALTER TABLE authcode CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- 触发器 自动更新 class中 学生数量
DELIMITER $$
CREATE TRIGGER tr_update_student_count_insert
AFTER insert ON user_class
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_number = (
        SELECT COUNT(*) FROM user_class
            WHERE user_class.class_id = class.class_id)
    WHERE new.class_id = class.class_id;
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_student_count_delete
AFTER delete ON user_class
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_number = (
        SELECT COUNT(*) FROM user_class
            WHERE user_class.class_id = class.class_id)
    WHERE old.class_id = class.class_id;
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_student_count_update
AFTER update ON user_class
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_number = (
        SELECT COUNT(*) FROM user_class
            WHERE user_class.class_id = class.class_id)
    WHERE old.class_id = class.class_id;

    UPDATE class
    SET class.s_number = (
        SELECT COUNT(*) FROM user_class
            WHERE user_class.class_id = class.class_id)
    WHERE new.class_id = class.class_id;

END;
$$
DELIMITER ;


-- 触发器 自动更新class中 学生今日学习的时间
DELIMITER $$
CREATE TRIGGER tr_update_s_today_time_insert
AFTER insert ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_today_time = (
        SELECT sum(game_time_today) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE new.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_s_today_time_delete
AFTER delete ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_today_time = (
        SELECT sum(game_time_today) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE old.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_s_today_time_update
AFTER update ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_today_time = (
        SELECT sum(game_time_today) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE old.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);

   UPDATE class
    SET class.s_today_time = (
        SELECT sum(game_time_today) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE new.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);

END;
$$
DELIMITER ;


-- 触发器 自动更新class中 学生总的学习时间
DELIMITER $$
CREATE TRIGGER tr_update_s_sum_time_insert
AFTER insert ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_sum_time = (
        SELECT sum(game_time_sum) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE new.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_s_sum_time_delete
AFTER delete ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_sum_time = (
        SELECT sum(game_time_sum) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE old.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);
END;
$$

DELIMITER $$
CREATE TRIGGER tr_update_s_sum_time_update
AFTER update ON game_user
FOR EACH ROW
BEGIN
    UPDATE class
    SET class.s_sum_time = (
        SELECT sum(game_time_sum) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE old.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);

   UPDATE class
    SET class.s_sum_time = (
        SELECT sum(game_time_sum) FROM game_user
            WHERE game_user.user_id in (
                SELECT user_id from user_class where user_class.class_id = class.class_id
                )
            )
    WHERE new.user_id in (SELECT user_id from user_class where user_class.class_id = class.class_id);

END;
$$
DELIMITER ;


# show triggers;
# drop trigger tr_update_student_count_update;
# drop trigger tr_update_student_count_delete;
# drop trigger tr_update_student_count_insert;

-- 关卡表
create table game(
    chapter_id int comment '所属章节id',
    level_id int comment '关卡id',
    chinese varchar(10) comment '中文',
    braille json comment '盲文'
) comment '关卡表';

ALTER TABLE game
ADD UNIQUE INDEX idx_chapter_level (chapter_id, level_id);

-- 用户 - 关卡表
create table game_user(
    user_id varchar(20) comment '玩家id',
    chapter_id int comment '进行到章节id',
    right_num int unsigned comment '正确数量',
    total_num int unsigned comment '总数量',
    game_time_today int default(0) comment '今日学习时间/min',
    game_time_sum int default(0) comment '总的学习时间/min',
    foreign key (chapter_id) references game(chapter_id),
    foreign key (user_id) references user(id)
) comment '用户关卡表';


-- 创建一个定时事件，在每天的凌晨清零 用户-关卡表中的学习时间
DELIMITER $$
CREATE EVENT reset_game_time_today
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    UPDATE game_user
    SET game_time_today = 0;  -- 清零 game_time_today 字段
END $$

-- 关卡记录
create table game_record(
    id int auto_increment unique key  comment '编号',
    user_id varchar(20) comment '玩家id',
    content varchar(10) comment '学习内容',
    study_time int unsigned comment '学习时间',
    right_num int unsigned comment '正确数量',
    total_num int unsigned comment '总数量',
    pass_time datetime comment '完成时间',
    foreign key (user_id) references user(id)
) comment '关卡记录';


create table reading(
    book_name  varchar(20) unique key comment '书名',
    up_id varchar(30) comment '上传者id',
    time date comment '上传日期',
    num int default(0) comment '浏览次数',
    content text comment '内容'
)comment '读物';








insert into user values ('542213330330','123456','王',23,'1','15503736285','2',null,now());
insert into user values ('542213330331','123456','李',22,'1','15503736000','2',null,now());
insert into user values ('542213330332','123456','刘备',55,'2','15503736001','2',null,now());
insert into user values ('542213330333','123456','阮',20,'1','15503736002','2',null,now());
insert into user values ('542213330334','123456','辛',21,'1','15503736003','2',null,now());
insert into user values ('542213330335','123456','吕布',30,'1','15503736004','2',null,now());
insert into user values ('542213330336','123456','关羽',40,'1','15503736005','1',null,now());
insert into user values ('542213330337','123456','张飞',35,'1','15503736006','1',null,now());
insert into user values ('542213330338','123456','项羽',32,'1','15503736007','1',null,now());


insert into class values (1,'542213330336',0,0,0,now());
insert into class values (2,'542213330337',0,0,0,now());
insert into class values (3,'542213330338',0,0,0,now());

insert into user_class values ('542213330330','王',1,0,0);
insert into user_class values ('542213330331','李',1,0,0);
insert into user_class values ('542213330332','刘备',1,0,0);

insert into user_class values ('542213330333','阮',2,0,0);
insert into user_class values ('542213330334','辛',2,0,0);

insert into user_class values ('542213330335','吕布',3,0,0);


insert into game values (1,1,'早上','[["11", "456"], ["456", "123"]]');
insert into game values (1,2,'下午','[["12", "456"], ["456", "123"]]');
insert into game values (1,3,'晚上','[["13", "456"], ["456", "123"]]');
insert into game values (1,4,'凌晨','[["14", "456"], ["456", "123"]]');
insert into game values (1,5,'傍晚','[["15", "456"], ["456", "123"]]');
insert into game values (1,6,'午夜','[["16", "456"], ["456", "123"]]');
insert into game values (2,1,'一月','[["21", "456"], ["456", "123"]]');
insert into game values (2,2,'二月','[["22", "456"], ["456", "123"]]');
insert into game values (2,3,'三月','[["23", "456"], ["456", "123"]]');
insert into game values (2,4,'四月','[["24", "456"], ["456", "123"]]');
insert into game values (2,5,'五月','[["25", "456"], ["456", "123"]]');
insert into game values (2,6,'六月','[["26", "456"], ["456", "123"]]');
insert into game values (3,1,'七月','[["31", "456"], ["456", "123"]]');
insert into game values (3,2,'八月','[["32", "456"], ["456", "123"]]');
insert into game values (3,3,'九月','[["33", "456"], ["456", "123"]]');
insert into game values (3,4,'十月','[["34", "456"], ["456", "123"]]');
insert into game values (3,5,'十一月','[["35", "456"], ["456", "123"]]');
insert into game values (3,6,'十二月','[["36", "456"], ["456", "123"]]');
insert into game values (4,1,'鸡蛋','[["41", "456"], ["456", "123"]]');
insert into game values (4,2,'牛奶','[["42", "456"], ["456", "123"]]');
insert into game values (4,3,'面包','[["43", "456"], ["456", "123"]]');
insert into game values (4,4,'胡辣汤','[["44", "456"], ["456", "123"]]');
insert into game values (4,5,'包子','[["45", "456"], ["456", "123"]]');
insert into game values (4,6,'米粥','[["46", "456"], ["456", "123"]]');
insert into game values (5,1,'中国','[["51", "456"], ["456", "123"]]');
insert into game values (5,2,'日本','[["52", "456"], ["456", "123"]]');
insert into game values (5,3,'韩国','[["53", "456"], ["456", "123"]]');
insert into game values (5,4,'越南','[["54", "456"], ["456", "123"]]');
insert into game values (5,5,'印度','[["55", "456"], ["456", "123"]]');
insert into game values (5,6,'菲律宾','[["56", "456"], ["456", "123"]]');
insert into game values (6,1,'哥哥','[["61", "456"], ["456", "123"]]');
insert into game values (6,2,'弟弟','[["62", "456"], ["456", "123"]]');
insert into game values (6,3,'妹妹','[["63", "456"], ["456", "123"]]');
insert into game values (6,4,'姐姐','[["64", "456"], ["456", "123"]]');
insert into game values (6,5,'侄子','[["65", "456"], ["456", "123"]]');
insert into game values (6,6,'外甥','[["66", "456"], ["456", "123"]]');


insert into game_user values ('542213330330',1,23,100,0,0);
insert into game_user values ('542213330331',1,50,66,10,10);
insert into game_user values ('542213330332',1,30,40,5,50);
insert into game_user values ('542213330333',2,50,66,10,30);
insert into game_user values ('542213330334',5,30,55,20,100);
insert into game_user values ('542213330335',3,16,30,0,100);





