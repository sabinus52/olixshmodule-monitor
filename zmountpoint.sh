###
# Vérification des points de montage pour Zabbix
# ==============================================================================
# @package olixsh
# @module monitor
# @author Olivier <sabinus52@gmail.com>
# ------------------------------------------------------------------------------
# Retour d'erreur
# -  0 : OK
# - 10 : Le montage n'est pas monté
# - 11 ; Le dossier du montage n'existe pas
# - 20 : Le fichier de test de présence n'existe pas
# - 30 : Le montage est seulement en lecture seule
# - 31 : Pas de reponse pour créer un fichier dans le montage 
# - 32 : Impossible d'écrire dans le montage 
# - 70 : Le montage ne répond pas
##


TIME_TILL_STALE=3
load "utils/process.sh"



###
# Retour au format JSON pour Zabbix de la liste des montages
##
if [[ $OLIX_MODULE_MONITOR_MOUNTPOINTS_DISCOVERY == true ]]; then

    ! System.binary.exists "findmnt" && critical "Le binaire 'findmnt' n'existe pas"

    JSONFIRST=1
    echo "{ \"data\": ["
    while IFS='\n' read JSONLINE; do
        IFS=' ' read JSONNAME JSONTYPE <<< "$JSONLINE"
        [[ $JSONFIRST == 0 ]] && echo ", "
        JSONFIRST=0
        echo -n "  { \"{#MOUNTNAME}\": \"$JSONNAME\", \"{#MOUNTTYPE}\": \"$JSONTYPE\" }"
    done < <(findmnt --fstab -l -n -u -o TARGET,FSTYPE)
    echo && echo "] }"
    die 0

fi


###
# Test des paramètres
##
if ! System.binary.exists "mountpoint"; then
    critical "Le binaire 'mountpoint' n'existe pas"
fi
if [[ -z $OLIX_MODULE_MONITOR_MOUNTPOINT ]]; then
    critical "Pas de point de montage défini"
fi
info "Test du point de montage : $OLIX_MODULE_MONITOR_MOUNTPOINT"



###
# Test si le point de montage est monté
##
debug "Check mountpoint $OLIX_MODULE_MONITOR_MOUNTPOINT"
if ! mountpoint -q $OLIX_MODULE_MONITOR_MOUNTPOINT; then
    Monitor.zabbix.return 10 "$OLIX_MODULE_MONITOR_MOUNTPOINT not mount"
fi


###
# Check si le point de montage est actif ou répond
##
debug "Check df $OLIX_MODULE_MONITOR_MOUNTPOINT"
df -k $OLIX_MODULE_MONITOR_MOUNTPOINT &>/dev/null &
DFPID=$!
for (( i=1 ; i<$TIME_TILL_STALE ; i++ )) ; do
    # Et s'il repond dans les X secondes
    if Process.running $DFPID; then
        debug "No response du PID ($DFPID) df -k $OLIX_MODULE_MONITOR_MOUNTPOINT"
        sleep 1
    else
        break
    fi
done
if Process.running $DFPID; then
    # Si toujours pas de réponse, alors on kill le process DF
    #warning "No response de la commande df -k $OLIX_MODULE_MONITOR_MOUNTPOINT -> kill $DFPID"
    $(Process.kill $DFPID &>/dev/null)
    Monitor.zabbix.return 70 "$OLIX_MODULE_MONITOR_MOUNTPOINT n'a pas répondu dans les $TIME_TILL_STALE sec."
fi


###
# Test si le répertoire existe
##
if ! Directory.exists "$OLIX_MODULE_MONITOR_MOUNTPOINT"; then
    Monitor.zabbix.return 11 "Directory $OLIX_MODULE_MONITOR_MOUNTPOINT not exists"
fi


###
# Test de la présence d'un fichier
##
if [[ -n $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE ]]; then
    debug "Check if file $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE exists"
    if ! File.exists $OLIX_MODULE_MONITOR_MOUNTPOINT/$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE; then
        Monitor.zabbix.return 20 "$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE not exists in $OLIX_MODULE_MONITOR_MOUNTPOINT"
    fi
fi


###
# Test d'ecriture sur le point de montage
##
if [[ $OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST == true || $OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST == 1 ]]; then
    debug "Check if read/write"
    # Test si en read only
    if findmnt -O ro $OLIX_MODULE_MONITOR_MOUNTPOINT > /dev/null 2>&1; then
        Monitor.zabbix.return 30 "$OLIX_MODULE_MONITOR_MOUNTPOINT est en read only"
    fi
    TOUCHFILE=$OLIX_MODULE_MONITOR_MOUNTPOINT/.mount_test_from_$(date +%Y-%m-%d--%H-%M-%S).$RANDOM.$$
    debug "check touch $TOUCHFILE"
    touch $TOUCHFILE &>/dev/null &
    TOUCHPID=$!
    for (( i=1 ; i<$TIME_TILL_STALE ; i++ )) ; do
        if Process.running $TOUCHPID; then
            debug "No response du PID ($DFPID) touch $TOUCHFILE"
            sleep 1
        else
            break
        fi
    done
    if Process.running $TOUCHPID; then
        warning "No response de la commande touch $TOUCHFILE -> kill $TOUCHPID"
        $(Process.kill $TOUCHPID &>/dev/null)
        Monitor.zabbix.return 31 "Impossible d'ecrire dans $OLIX_MODULE_MONITOR_MOUNTPOINT en $TIME_TILL_STALE sec."
    else
        if ! File.exists $TOUCHFILE; then
            Monitor.zabbix.return 32 "$OLIX_MODULE_MONITOR_MOUNTPOINT is not writable"
        else
            rm $TOUCHFILE &>/dev/null
        fi
    fi
fi


###
# Tout est OK
##
Monitor.zabbix.return 0 "$OLIX_MODULE_MONITOR_MOUNTPOINT OK"
