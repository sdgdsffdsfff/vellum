# ************************************************************
# Sequel Pro SQL dump
# Version 4004
#


# Dump of table actiontype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `actiontype`;

CREATE TABLE `actiontype` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `appid` varchar(255) NOT NULL DEFAULT '' COMMENT '应用ID',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '操作类型名',
  `callname` varchar(255) NOT NULL DEFAULT '' COMMENT '调用名',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='操作类型表';



# Dump of table admin
# ------------------------------------------------------------

DROP TABLE IF EXISTS `admin`;

CREATE TABLE `admin` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL DEFAULT '' COMMENT '管理员用户名',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT '管理员密码',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='管理员表';

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;

INSERT INTO `admin` (`id`, `username`, `password`)
VALUES
	(1,'admin','21232f297a57a5a743894a0e4a801fc3');

/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table application
# ------------------------------------------------------------

DROP TABLE IF EXISTS `application`;

CREATE TABLE `application` (
  `appid` varchar(255) NOT NULL COMMENT '应用ID',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT '应用名',
  `authcode` varchar(255) NOT NULL DEFAULT '' COMMENT '应用授权码',
  PRIMARY KEY (`appid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='应用表';




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
