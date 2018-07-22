#!/bin/sh

translate_patern() {
	echo $1 | sed -e "s#$2#$3#g"
}

translate_header() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "Redémarrer" "Reboot")
     page=$( translate_patern "$page" "Acceuil" "Home")   
     page=$( translate_patern "$page" "Code de connexion" "Access code")       
     page=$( translate_patern "$page" "Avancé" "Advanced")      
fi     
echo "$page"
}




translate_page_home() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "État du boîtier" "Box status")
     page=$( translate_patern "$page" "Etat du serveur" "Server status")  
     page=$( translate_patern "$page" "Temps d'activité" "Uptime")  
     page=$( translate_patern "$page" "Identifiant du boîtier" "Box ID")    
     page=$( translate_patern "$page" "Changement de mode" "Change mode")      
#    page=$( translate_patern "$page" "Internet" "Internet")
     page=$( translate_patern "$page" "Passage en mode client" "Switch to client mode") 
     page=$( translate_patern "$page" "détails" "details")
     page=$( translate_patern "$page" "Changer mode client" "Change client mode")     
     page=$( translate_patern "$page" "Cliquez sur les boutons ci-dessous pour changer le mode" "Click on the buttons below in order to change the mode")
     page=$( translate_patern "$page" "Mode hors-ligne" "Offline mode")    
     page=$( translate_patern "$page" "Mode réseau local" "Local mode")   
     page=$( translate_patern "$page" "Mode Entreprise" "Company mode")  
     page=$( translate_patern "$page" "Aide" "Help")     
     page=$( translate_patern "$page" "Attention" "Warning")         
     
     page=$( translate_patern "$page" "<b>Le mode hors-ligne</b> redirige automatiquement le navigateur vers cette interface d'administration, et ne permet d'accéder à rien d'autre." "<b>In offline mode</b> you can only access this web interface and your web browser is automatically redirected to it." )
     
     page=$( translate_patern "$page" "<b>Le mode réseau local</b> permet d'accéder au réseau local sur lequel est branché le boîtier,ce qui est principalement utile lorsqu'un réseau public requière une identification via un portail captif pour accéder à Internet." "<b>In local mode</b> you access the local network in which the telework-box is plugged. This is mostly usefull when an authentification is required with a captive portail" ) 
     
     page=$( translate_patern "$page" "<b>Le mode entreprise </b> permet de se connecter sur le réseau de l'entreprise distante, correspondant au code de connexion configuré." "<b>In Company mode</b> you access the remote network of your company, corresponding to the access code you configured." )  
     
     page=$( translate_patern "$page" "Vous êtes connecté au réseau de l'entreprise uniquement grâce au système de secourt. La connexion au réseau de l'entreprise risque d'être particulièrement lente. La connexion internet utilisée est peut-être trop filtrée, ou bien le serveur Telework-box dans votre entreprise est peut-être mal configuré." "You are only connected to the company network via the backup system. Connection to the company network may be particularly slow. The internet connection used may be too filtered, or the Telework-box server in your company may be poorly configured.")

fi
echo "$page"
}




translate_page_wifi() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "État client wifi" "Wifi client status") 
     page=$( translate_patern "$page" "État wifi émis" "Access point status")   
     page=$( translate_patern "$page" "Paramètres client wifi" "Wifi client settings")
     page=$( translate_patern "$page" "Paramètres wifi émis" "Access point settings") 
     page=$( translate_patern "$page" "Activer l'émission du réseau Wifi" "Enable wireless access point")      
     page=$( translate_patern "$page" "Aucun Chiffrement" "No encryption")    
     page=$( translate_patern "$page" "Clef de Chiffrement" "Encryption key") 
     page=$( translate_patern "$page" "Méthode de chiffrement" "Encryption method")   
     page=$( translate_patern "$page" "Activer le client Wifi" "Enable wifi client")        
     page=$( translate_patern "$page" "Réseau caché" "Hidden network")     
     page=$( translate_patern "$page" "Chiffrement" "Encryption")  
     page=$( translate_patern "$page" "Valider" "Submit") 
     page=$( translate_patern "$page" "Scanner" "Scan")  
     page=$( translate_patern "$page" "Retour" "Back")      
     page=$( translate_patern "$page" "Annuler" "Cancel")     
     page=$( translate_patern "$page" "Scan des réseaux wifi environnants." "Scan surrounding wifi networks.")   
     page=$( translate_patern "$page" "Configurer un nouveau réseau wifi client" "Configure a new wifi network" )
     page=$( translate_patern "$page" "Configurer" "Configure") 
     page=$( translate_patern "$page" "Wifi coté serveur." "Wifi on server side")      
     page=$( translate_patern "$page" "Le wifi n'est pas utilisable coté serveur, pour des raisons techniques: seul un réseau sans-fil WDS peut-être techniquement être étendu. Si vous auriez aimé étendre un réseau WDS merci de nous contacter." "Wifi is not available on server side, for technical reasons: only a WDS wireless network could be extended. If you would like to extend a WDS network please contact us.")      
fi
echo "$page"
}



translate_page_code() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "Code en cours d'utilisation" "Current access code") 
     page=$( translate_patern "$page" "Historique des codes" "Code history")   
     page=$( translate_patern "$page" "Valider" "Submit")  
     page=$( translate_patern "$page" "Commentaire" "Comment")
     page=$( translate_patern "$page" "Hôte" "Host")     
     page=$( translate_patern "$page" "Hote" "Host")   
     page=$( translate_patern "$page" "Ajouter" "Add")       
     page=$( translate_patern "$page" "Codes d'accès." "Access codes.") 
     page=$( translate_patern "$page" "Afficher les codes" "Display codes")
     page=$( translate_patern "$page" "Cacher les codes" "Hide codes")     
     page=$( translate_patern "$page" "Chacun des code d'accès ci-dessous est propre à un employé et lui de se connecter au réseau" "Each of the access codes below is specific to an employee and allows him to connect to the network")     
     page=$( translate_patern "$page" "<b>Veuillez entrer sous-dessous les paramètres de connexion au serveur.</b> (Le commentaire est libre et permet uniquement de savoir à quoi chaque code correspond dans l'historique)." "<b>Please enter your server access codes.</b> (The comment is free and allows to find back codes in the history).")       
fi
echo "$page"
}


translate_page_avance() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "Valider" "Submit")
     page=$( translate_patern "$page" "Langue" "Langage")       
     page=$( translate_patern "$page" "Identifiant du boîtier" "Box ID")   
     page=$( translate_patern "$page" "Changement de mode" "Change mode")  
     page=$( translate_patern "$page" "Aide" "Help")       
     page=$( translate_patern "$page" "Passage en mode Serveur" "Switch to server mode")
     page=$( translate_patern "$page" "Passage en mode client" "Switch to client mode")     
     page=$( translate_patern "$page" "Paramètres generaux" "General settings") 
     page=$( translate_patern "$page" "Paramètres serveur" "Server settings")      
     page=$( translate_patern "$page" "Configurer ci-dessous la liste serveurs stun." "Configure the stun server list below.")     
     page=$( translate_patern "$page" "Serveur mandataire service cachés" "Hidden service proxy server")    
     page=$( translate_patern "$page" "Renseignez ci-dessous le serveur mandataire pour les services cachés" "Enter the proxy server for hidden services below.")         
     
     page=$( translate_patern "$page" "Serveur stun" "Stun servers")   
     page=$( translate_patern "$page" "Port stun" "Stun port")       
     page=$( translate_patern "$page" "Paramètres client" "Client settings")   
     page=$( translate_patern "$page" "Passage automatique en mode entreprise au démarrage lorsque la connexion internet est pleinement fonctionnelle." "Automatically switch to company mode at startup when Internet access is fully available")        
     
     
     page=$( translate_patern "$page" "Configurer ci-dessous la liste des ports publics sur lequel le serveur peut être joignable." "Configure below the list of public ports on which the server can be reached.")             
     
     
     page=$( translate_patern "$page" "Ce bouton permet de passer en <b>mode serveur</b> afin d'étendre le réseau d'une entreprise et permettre aux boîtiers client détenus par les salariés de s'y connecter. Si vous êtes employé, et souhaitez simplement vous connecter au réseau d'une entreprise, ne cliquez pas dessus." "This button allows you to switch to <b>server mode</b> in order to extend a company's network and allow employee's client boxes to connect to it. If you are an employee, and simply want to connect to a company's network, do not click on it.")            
     
     page=$( translate_patern "$page" "Ce bouton permet de passer en <b>mode client</b> afin de se connecter à distance à un réseau d'entreprise. Si ce boitier est branché dans le réseau de l'entreprise dans le but de l'étendre, ne cliquez pas sur ce bouton." "This button allows you to switch to <b>client mode</b> in order to connect remotely to an enterprise network. If this box is connected to the company network in order to extend it, do not click on this button.")   
     
     page=$( translate_patern "$page" "Mise à jour du Firmware" "Upgrade Firmware" )
  
     page=$( translate_patern "$page" "Fichier du Firmware:" "Firmware File:" )  
     
fi
echo "$page"
}


translate_page_details() {
page=$(echo $1);
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
     page=$( translate_patern "$page" "Etat de tor" "Tor status")
     page=$( translate_patern "$page" "Etat tor" "Tor status")   
     page=$( translate_patern "$page" "IP publique" "Public IP")   
     page=$( translate_patern "$page" "Port publique" "Public port")        
     page=$( translate_patern "$page" "Etat de stun" "Stun status")
     page=$( translate_patern "$page" "Ports UDP" "UDP ports")     
     page=$( translate_patern "$page" "Etat du ping" "Ping status")  
     page=$( translate_patern "$page" "Détails Internet" "Internet status details")      
     page=$( translate_patern "$page" "Voulez-vous redémarrer le boîtier ?" "Do you wish to reboot the box?")      
     page=$( translate_patern "$page" "Annuler" "Cancel")   
     page=$( translate_patern "$page" "Redémarrer" "Reboot")       
     
fi
echo "$page"
}



translate_inline() {
langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
    case $1 in
        "Serveur") echo "Server";;
        "jour") echo "day";;
        "heure(s)") echo "hour(s)";;
        "Partiel") echo "Partial";;
        "Entreprise") echo "Company";; 
        "Hors-ligne") echo "Offline";; 
        "Connecté au réseau wifi" ) echo  "Connected to the wifi network";; 
        "Déconnecté du réseau wifi") echo "Disconnected from the wifi network";;  
        "En cours d'émission." ) echo  "Currently broadcasting.";; 
        "Pas d'émission wifi.") echo "No broadcast.";;        
        "Connecté à Internet.") echo "Connected to the internet";;   
        "Pas de connection à Internet.") echo "No wireless access to the internet";;   
        "(Pas d'IP)") echo "(No IP)";;
    esac
fi

if [ "$langue" = "fr" ]; then
echo $1;
fi
}


translate_inline_recup() {

langue=$(uci get bridgebox.general.langue);

if [ "$langue" = "en" ]; then
    case $1 in
        "Mise à jour de la configuration") echo "Updating configuration";;
        "Les codes d'accès ont été modifiés") echo "Access codes were modified";;
        "Le code doit contenir uniquement de lettres (majuscules ou minuscules) et Chiffres.<br> Il doit avoir un taille entre 8 et 127 caractères.") echo "The code must contain only letters (upper or lower case) and Numbers.<br> It must have a size between 8 and 127 characters.";;
        "Les paramètres avancés du serveur ont été mis à jour!") echo "Advanced settings were updated";;
        "Les paramètres avancés généraux ont été mis à jour!") echo "General advanced settings have been updated!";;
        "Veuillez patienter") echo "Please wait!";;
        "Passage en <b>mode") echo "Switching to <b>mode";;
        "Changement de mode de fonctionnement") echo "Changing the operating mode";;
        "Changement de mode de fonctionnement réussit") echo "Successful change of operating mode";;
        "réussit!") echo "Successful!";;
        "Erreur: n'a pas put passé en mode") echo "Error: Could not switch to " ;;
        "retour au mode") echo "back to" ;;  
        "Passage en mode") echo "Switching to " ;; 
        "local") echo "local mode" ;;
        "offline") echo "offline mode" ;;    
        "entreprise") echo "company mode" ;;  
        "Mauvais hote!") echo "Wrong host!" ;;
        "Les codes d'accès envoyés sont les même qu'avant!") echo "The access codes are the same as before!" ;;
        "Passage en mode entreprise.") echo "Switching to company mode." ;;
        "Passage en mode réseau local.") echo "Switching to local mode." ;;
        "Passage en mode hors-ligne.") echo "Switching to offline mode." ;;
        "Veuillez patienter: Mise à jour de la configuration") echo  "Please wait: Updating configuration";;
        "Bravo vous allez pouvoir utiliser le boîtier télétravail!") echo "Congratulations you will be able to use the Telework-box!";;
        "Bravo vous allez pouvoir utiliser le boîtier télétravail après redémarrage!")  echo "Congratulations you will be able to use the Telework-box after a reboot!";;
        "Félicitations, vous pourrez utiliser la boîte de télétravail après le redémarrage !")  echo "Congratulations you will be able to use the Telework-box after rebooting the it!";;
        "La langue utilisée est maintenant le français!") echo "The langage used is now english" ;;
        "<b>Redémarrage du Boitier. (Environ 2 minutes)") echo "<b>Rebooting the box. (Approximately 2 minutes)";;
        "Les paramètres du réseau wifi émis ont été mis à jour. <b>Le wifi va redémarrer!</b>") echo "Wifi network settings have been updated. <b>The wifi will restart!</b>";;
        "Les paramètres du client wifi ont été mis à jour. <b>Le wifi va redémarrer!</b>") echo "Wifi network settings have been updated. <b>The wifi will restart!</b>";;
        "Erreur ssid vide!") echo "Error: void ssid!";;
        "Erreur ssid trop long!") echo "Error: ssid too long!";;  
        "Clef WPA trop longue")  echo "WPA key too long!";;  
        "Clef WPA trop courte")  echo "WPA key too short!";;   
        "Mauvaise taille de clef WEP hexadecimale.") echo "Wrong WEP hexadecimal key size.";;
        "Clef wep trop courte") echo "WEP key too short.";;    
        "Clef wep trop longue") echo "WEP key too long.";;     
        "<u>Attention:</u> Il est nécessaire de déconnecter et reconnecter votre appareil au boîtier afin de récupérer l’adresse IP correspondante à votre réseau.") echo "<u>Caution:</u> It is necessary to disconnect and reconnect your device to the Telework-box in order to retrieve the IP address corresponding to your network.";;
        "<u>Attention:</u> Il sera nécessaire de déconnecter et reconnecter votre appareil au boîtier afin de récupérer l’adresse IP correspondante à votre réseau.") echo "<u>Caution:</u> It will be necessary to disconnect and reconnect your device to the Telework-box in order to retrieve the IP address corresponding to your network." ;;
        "Mise à jour du firmware") echo "Upgrading Firmware" ;;
        "Firmware correct!") echo "Firmware ok!";;
        "Mettre à jour") echo "Upgrade now";;
        "Mauvais firmware") echo "Wrong firmware";;
        "Le fichier envoyé n'est pas un fichier de firmware valable!") echo "The uploaded file is not a valid firmware file!";;
        "<b>Mise à jour du firmware. (Environ 5 minutes)") echo "<b>Upgrading firmware. (Approximately 2 minutes)";;
    esac
fi

if [ "$langue" = "fr" ]; then
echo $1;
fi


}
