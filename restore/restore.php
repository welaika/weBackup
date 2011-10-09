<?php
//Impediamo di accedere a questo script direttamente:
//si deve passare dalla schermata di login per verificare
//l'autenticazione.
if(basename($_SERVER['SCRIPT_FILENAME']) != 'rdiff.php'){
die('Non fare il furbo con me! Non puoi aprire direttamente questo script. Quindi elimina qualsiasi "xxx.php" dall\'indirizzo e aggiorna la pagina...');
}
?>
<?php
    $comando = 'sudo rdiff-backup -v5 -r ';
    $bkp_dir = parse_config("BACKUP_DIR");
    //$run = `$comando`;
    //var_dump($run);
    //echo $run;
    $selected_host = escapeshellcmd($_POST['selected_host']);
    $path = escapeshellcmd($_POST['path']);
    $days = escapeshellcmd($_POST['days']);
    $run = $_POST['run'];
    $step1 = $_POST['step1'];

    //Developing debuggin
    print_r($_POST);
?>
<?php
if (empty($run)){
        if(empty($step1)) { ?>
            <p>Percorso = il percorso della cartella o del file da recuperare. E' necessario inserire il percorso assoluto cos&igrave; come si presenta
            sul server GODZILLA<br />
            Giorni = a quanti giorni fa si vuole che corrisponda lo status del file (siccome il backup viene fatto una volta al giorno si pu&ograve;
            tornare indietro di<br /> x giorni ed il massimo &egrave; di 15 giorni.
            </p>
            <form action="<?php $_SERVER['PHP_SELF']; ?>" name="restore" method="post">
                <?php hostlist() ?>
                <label>Percorso: 
                    <input class="path" type="text" name="path" value="<?php if(!empty($path)){ echo $path; } ?>" />
                </label>
                <label>Giorni: 
                    <input type="text" name="days" value="<?php if(!empty($path)){ echo $days; } ?>" maxlenght="2" />
                </label>
                <input type="hidden" name="step1" value="true" />
                <input type="submit" value="FALLO!" />
            </form>
            <p>OPPURE vuoi prima esplorare il percorso?</p><br />
            <form action="<?php $_SERVER['PHP_SELF']; ?>" name="checkpath" method="post">
                <?php hostlist() ?>
                <label>Percorso: 
                    <input class="path" type="text" name="path" value="<?php if(!empty($path)){ echo $path; } ?>" />
                </label>
                <input type="hidden" name="stephalf" value="true" />
                <input type="submit" value="FALLO!" />
            </form>
            <?php if (isset($_POST['stephalf'])){
                if(empty($selected_host))
                    die('La verifica non pu&ograve; funzionare se non selezioni un host dall\'elenco');
                $path = str_replace(' ', '\ ', $path);
                $cmd = "ls -l -p --group-directories-first $bkp_dir/$selected_host/$path";
                $run = `$cmd`;
                echo '<pre>' . $run . '</pre>';
                }
            ?>
        <?php
        } else {
            if(empty($path) || empty($days)){
                echo "ATTENZIONE: non hai inserito dei dati necessari...<br /><br />";
                echo '<a href="rdiff.php">Azzera e vai all\'inizio</a><br />';
                exit();
            }
            $path = str_replace(' ', '\ ', $path);
            $test = `sudo test -e $bkp_dir/$selected_host/$path; echo $?`;
            if ($test != 0){
                echo "ATTENZIONE: la directory specificata non sembra esistere...<br /><br />";
                echo '<a href="rdiff.php">Azzera e vai all\'inizio</a><br />';
                exit();
            }
            if ($days > 15){
                echo "ATTENZIONE: non posso risalire a backup pi&ugrave; vecchi di 15 giorni...<br /><br />";
                echo '<a href="rdiff.php">Azzera e vai all\'inizio</a><br />';
                exit();
            }
            $comando .= $days . 'D ' . $bkp_dir . '/' . $selected_host . '/' . $path . ' 192.168.2.252::' . $path;
        ?>
            <h4>Verifica il tuo comando:</h4>
            <pre><?php echo $comando; ?></pre>
            <form action="rdiff.php" name="run" method="post">
                <input type="hidden" name="run" value="<?php echo $comando; ?>" />
                <p>Se confermi l'esattezza del comando
                <input type="submit" value="Esegui Backup" /></p>
            </form>
            <p>altrimenti <a href="rdiff.php">azzera e vai all'inizio</a></p><br />
<?php   }
} else {    
    echo '<h4>Il backup &egrave; stato eseguito</h4>';
    $backup = `$run 2>&1`;
    echo '<pre>' . $backup . '</pre>';
    //var_dump($run);
    echo '<br /><a href="rdiff.php">Azzera e vai all\'inizio</a><br />';
}
?>
