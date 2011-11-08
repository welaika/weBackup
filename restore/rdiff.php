<?php    
    session_start();
    $inactive = 600; 
    $session_life = time() - $_SESSION['timeout'];
        if($session_life > $inactive || $_GET['action'] == 'logout'){
            $_SESSION = array();
            //$_SESSION['login'] = 'FALSE';
        }
?>
<!--/*
 *      rdiff.php
 *
 *      Copyright 2010 Alessandro Fazzi <alessandro.fazzi@acmos.net>
 *
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation; either version 2 of the License, or
 *      (at your option) any later version.
 *
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *
 *      You should have received a copy of the GNU General Public License
 *      along with this program; if not, write to the Free Software
 *      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *      MA 02110-1301, USA.
 */ -->
<html>
<head>
<title>RDIFF-PHP-RESTORE</title>
    <style type="text/css">
        @import url(style.css);
    </style>
</head>
<body>
<?php

/*****************************
*VARIABILI GENERALI***********
*****************************/
error_reporting(E_ERROR | E_WARNING | E_PARSE); //per debug cazzuto aggiungere E_NOTICE
$filename = '.shadow'; 					//file in cui è memorizzata la password
$pwd = file("$filename", FILE_IGNORE_NEW_LINES); 	//leggo la pwd da dentro il file .shadow
$pwdctrl = $_POST['password'];				//imposto la variabile di controlla password
include("functions.php");


/*****************************/

    echo '<h1>Restoring a file or directory from backup</h1>';
    
	//Confronto la password inserita dall'utente, se già inserita, con quella impostata
	//Se corrispondono setto la sessione su loggata
    if(md5($pwdctrl) == $pwd[0])
    {
        $_SESSION['login'] = TRUE;
    }
    
    //Se non sei loggato <---------------------------------------------------------------------
    
    if(!$_SESSION['login'])
    //presenta il form di autenticazione
    { ?>

    <h3>Accesso ristretto</h3>
    <p>Se non sei autenticato non puoi visualizzare questa pagina.</p><br />
    <p>Autenticati qui sotto:</p><br />
    <form name="password" action="rdiff.php" method="POST">
        <label>Password: </label>
        <input type="password" name="password" />
        <input type="submit" value="Autenticati" />
    </form>

<?php

	//Se invece sei loggato ma hai scelto di cambiare la password <-----------------------------
	
    } elseif($_SESSION['login'] && $_GET['action'] == 'chpwd') {
    //presenta il form di cambio password
    	echo '<h3>Facciamo cambiare la password all\'utente...</h3>';
    	
	//la vecchia deve corrispondere a quella impostata, la vecchia e la nuova devono essere differenti, la nuova deve essere inserita due volte identica
		if(isset($_POST['oldpwd']) && md5($_POST['oldpwd']) == $pwd[0] && $_POST['newpwd'] != $_POST['oldpwd'] && $_POST['newpwd'] == $_POST['newpwd2']) { $pwdup = TRUE; } else { $pwdup = FALSE; }
		//if(!isset($_POST['oldpwd']) || md5($_POST['oldpwd']) !== $pwd[0] || $_POST['newpwd'] = $_POST['oldpwd'] || $_POST['newpwd'] != $_POST['newpwd2']) { $pwdup = FALSE; }
    	//Non so perché, ma la riga sopra forse faceva fastidio a qualcosa. Cmq sostituita con l'else alla riga sopra
    	
    	//Se le condizioni di cambio pwd non si verificano
    	if(!$pwdup){
			//Avvisa...
    		if($_POST['tried']){
				echo '<pre>Qualcosa non ha funzionato: devi avere inserito correttamente la vecchia password, la nuova deve essere differente e devi digitarla due volte correttamente. Riprova</pre>';
			}
			
			//...e mostra form di cambio password
    		?>
    		<form name="chpwd" action="rdiff.php?action=chpwd" method="POST">
			<label> Vecchia password: </label>
				<input type="password" name="oldpwd" />
			<label> Nuova password: </label>
				<input type="password" name="newpwd" />
			<label> Verifica nuova password: </label>
				<input type="password" name="newpwd2" />
				<input type="hidden" name="tried" value="TRUE" />
			<input type="submit" value="INVIA" />
			</form>
			<?php
		//Se le condizioni di cambio si verificano
		} else {
			//cerca il file di deposito della password e ne crea uno nuovo...
			if(file_exists($filename)){
    			rename($filename, "$filename\_OLD");
				touch($filename);
			}
			//...in cui scrivo la nuova password
    		$file = fopen($filename, w);
    		fwrite($file, md5($_POST['newpwd']));
    		fclose($file);
			
			echo '<pre>Password aggiornata correttamente. <a href="rdiff.php">Prosegui con il lavoro</a></pre>';
			//resetto le varie password dalle variabili
			$_POST['oldpwd'] = "";
			$_POST['newpwd'] = "";
			$_POST['newpwd2'] = "";
		}

		?>
		
		
	<?php
    }
    
    //Se sei loggato allora visualizza la schermata di restore <--------------------------------
    else {
		echo '<h3>Effettua il <a href="rdiff.php?action=logout" name="logout">LOGOUT</a> | ';
		echo 'Cambia la <a href="rdiff.php?action=chpwd" name="change pwd">password di accesso</a></h3>';
		echo '<br /><br /><hr /><br /><br />';
		include("restore.php");
		echo '<br /><br /><hr /><br /><br />';
    }
?>

</body>
</html>
<?php
$_SESSION['timeout']=time();
?>
