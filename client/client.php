<?php
class Vellum {
	private $_debug=false;
	private $_loglevel=array(
		'debug'=>1,
		'info'=>2,
		'warning'=>3,
		'error'=>4,
		'fatal'=>5
	);
	private $_appid='';
	private $_authcode='';
	private $_url='';

	public function __construct($host,$port){
		$this->_url='http://'.str_replace('http://', '', $host).':'.$port;
	}

	public function setApp($appid,$authcode){
		$this->_appid=$appid;
		$this->_authcode=$authcode;
		return $this;
	}

	public function debug(){
		$this->_debug=true;
	}

	public function pushUserLog($content,$action='default',$operator=0,$level='info'){
		$data=array(
			'appid'=>$this->_appid,
			'authcode'=>$this->_authcode,
			'content'=>$content,
			'type'=>$action,
			'operator'=>$operator,
			'level'=>$this->_loglevel[$level]
		);
		$url=$this->_url.'/log/write/user';
		return $this->_curl($data,$url);
	}

	public function pushSysLog($content,$level='info'){
		$data=array(
			'appid'=>$this->_appid,
			'authcode'=>$this->_authcode,
			'content'=>$content,
			'level'=>$this->_loglevel[$level]
		);
		$url=$this->_url.'/log/write/sys';
		return $this->_curl($data,$url);
	}

	private function _curl($data,$url) {
		if($this->_debug){
			$data['debug']=1;
		}
		$data=json_encode($data);
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array(  
			'Content-Type: application/json; charset=utf-8',  
			'Content-Length: ' . strlen($data))  
		);  
		curl_setopt($ch, CURLOPT_HEADER, 0);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
		if(!$this->_debug){
			curl_setopt($ch, CURLOPT_TIMEOUT, 1);
		}
		$output = curl_exec($ch);
		curl_close($ch);
		return $output;
	}
}


