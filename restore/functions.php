<?php
//Good ol'functions!

function hostlist(){
	$files = scandir('../conf/');
	//I primi due elemnti saranno sempre . e .., che a me non interessano
	$files = array_slice($files, 2);
	echo '<label>Lista degli host disponibili:<br />';
	foreach($files as $host){
		echo '
				<input type="radio" name="selected_host" value="'.$host.'">'.$host.'<br />

		';
	}
	echo '</label>';
}

function parse_config($param){
	$file = '../configure';
	$handle = fopen($file, 'r');
	$file = fread($handle, filesize($file));
	preg_match_all('/"(.*)"/', $file, $configure);
	$configure = array_filter($configure[1]);
	//print_r($configure);

	$script_conf = array(
		"BACKUP_DIR" => $configure[0],
		"RETENTION" => $configure[5]
	);

	return $script_conf["$param"];
}

?>