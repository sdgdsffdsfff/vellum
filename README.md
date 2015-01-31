vellum
=============
vellum 是一个多站点多应用的统一日志平台,各个应用可以通过客户端将日志提交至vellum,进行集中管理.方便统一日志格式,分析,归档等处理.


###使用方法
1.
```
	//下载
	git clone git@github.com:gloomyzerg/vellum.git
	//安装
	./install.sh
```
2.将根目录下的```install.sql```导入数据库  
3.修改根目录下的```config.json```中的数据库配置  
4.运行```node run.js```启动应用,程序将默认监听3000端口(可在app.js中修改)  
5.访问 http://yourip:port/admin/ 默认用户名密码均为admin  

###客户端使用
####php
```php
<?php
	include('client/client.php');
	$host='127.0.0.1';
	$port=3000;
	$vellum = new Vellum($host,$port);
	//默认是关闭debug模式的,此时是异步调用,接口会忽略错误,返回值总是success
	//开启debug模式接口会返回详细信息(包括错误)
	//$vellum->debug(); //开启debug

	$vellum-setApp(appid,authcode);
	$vellum->pushUserLog(日志详细内容,操作类型,操作人,日志级别);
	$vellum->pushSysLog(日志详细内容,日志级别);


```
