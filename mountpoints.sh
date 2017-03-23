###
# Vérification des points de montage
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
# @see https://github.com/echocat/nagios-plugin-check_mountpoints
##


TIME_TILL_STALE=3
ERR_MESG=()
FSTAB="/etc/fstab"


# Si aucun point de montage défini, on les récupère tous dans /etc/fstab
if [[ -z $OLIX_MODULE_MONITOR_MOUNTPOINTS ]]; then
    Module.execute.usage "mountpoints"
    critical "Pas de point de montage défini"
fi


for MP in $OLIX_MODULE_MONITOR_MOUNTPOINTS; do

    info "Test du point de montage : $MP"

    # Check si le point de montage est actif
    debug "Check df $MP "
    df -k $MP &>/dev/null &
    DFPID=$!
    for (( i=1 ; i<$TIME_TILL_STALE ; i++ )) ; do
        # Et s'il repond dans les X secondes
        if ps --pid $DFPID > /dev/null ; then
            debug "No response du PID ($DFPID) df -k $MP"
            sleep 1
        else
            break
        fi
    done

    if ps --pid $DFPID > /dev/null ; then
        # Si toujours pas de réponse, alors on kill le process DF
        debug "No response de la commande df -k $MP -> kill $DFPID"
        $(kill -s SIGTERM $DFPID &>/dev/null)
        ERR_MESG[${#ERR_MESG[*]}]="$MP n'a pas répondu dans les $TIME_TILL_STALE sec."

    elif ! Directory.exists "$MP"; then
        #log "CRIT: ${MP} doesn't exist on filesystem"
        debug "Directory $MP not exists"
        ERR_MESG[${#ERR_MESG[*]}]="$MP n'existe pas dans le filesystem"

    else

        if [[ -n $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE ]]; then
            # Test de la présence d'un fichier
            debug "Check if file $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE exists"
            if ! File.exists $MP/$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE; then
                debug "$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE not exists in $MP"
                ERR_MESG[${#ERR_MESG[*]}]="Le fichier $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE n'existe pas dans le point de montage $MP"
            fi
        fi

        if [[ $OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST == true ]]; then
            debug "Check if read/write"
            ISWRITE=true
            # Vérifie si le point de montage est en lecture seule ou en lecture/ecriture
            for OPT in $(grep -w $MP $FSTAB |awk '{print $4}'| sed -e 's/,/ /g'); do
                [[ "$OPT" == "ro" ]] && ISWRITE=false
            done
            [[ $ISWRITE == false ]] && debug "$MP est en read only"
            if [[ $ISWRITE == true ]]; then
                TOUCHFILE=$MP/.mount_test_from_$(date +%Y-%m-%d--%H-%M-%S).$RANDOM.$$
                debug "check touch $TOUCHFILE"
                touch $TOUCHFILE &>/dev/null &
                TOUCHPID=$!
                for (( i=1 ; i<$TIME_TILL_STALE ; i++ )) ; do
                    if ps --pid $TOUCHPID > /dev/null ; then
                        debug "No response du PID ($DFPID) touch $TOUCHFILE"
                        sleep 1
                    else
                        break
                    fi
                done
                if ps --pid $TOUCHPID > /dev/null ; then
                    debug "No response de la commande touch $TOUCHFILE -> kill $TOUCHPID"
                    $(kill -s SIGTERM $TOUCHPID &>/dev/null)
                    ERR_MESG[${#ERR_MESG[*]}]="Impossible d'ecrire dans $MP en $TIME_TILL_STALE sec."
                else
                    if ! File.exists $TOUCHFILE; then
                        debug "$TOUCHFILE is not writable"
                        ERR_MESG[${#ERR_MESG[*]}]="Impossible d'ecrire dans $MP."
                    else
                        rm $TOUCHFILE &>/dev/null
                    fi
                fi
            fi
        fi

    fi

done



if [[ ${#ERR_MESG[*]} -ne 0 ]]; then
    echo -n "CRITICAL: "
    for I in "${ERR_MESG[@]}"; do
        echo -n ${I}" ; "
    done
    echo
    die $OLIX_MODULE_MONITOR_STATE_CRITICAL
fi

echo "OK: Tous les points de montage sont bons ($(String.trim $OLIX_MODULE_MONITOR_MOUNTPOINTS))"
die $OLIX_MODULE_MONITOR_STATE_OK
