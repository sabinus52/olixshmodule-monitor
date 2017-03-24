###
# Vérification des points de montage
# ==============================================================================
# @package olixsh
# @module monitor
# @author Olivier <sabinus52@gmail.com>
# @see https://github.com/echocat/nagios-plugin-check_mountpoints
##


TIME_TILL_STALE=3
FSTAB="/etc/fstab"
Array.new ERR_MESG
load "utils/process.sh"


###
# Test des paramètres
##
if ! System.binary.exists "mountpoint"; then
    critical "Le binaire 'mountpoint' n'existe pas"
fi

# Recupère les partitions dans le /etc/fstab
if [[ $OLIX_MODULE_MONITOR_MOUNTPOINTS_ALL == true ]]; then
    OLIX_MODULE_MONITOR_MOUNTPOINTS=$( grep -v '^#' $FSTAB | awk '{if ($3=="ext3" || $3=="xfs" || $3=="auto" || $3=="ext4" || $3=="nfs" || $3=="nfs4" || $3=="davfs" || $3=="cifs" || $3=="fuse" || $3=="glusterfs" || $3=="ocfs2" || $3=="lustre" || $3=="ufs" || $3=="zfs")print $2}' | tr '\n' ' ' | sed -e 's/\/$//i' )
fi
if [[ -z $OLIX_MODULE_MONITOR_MOUNTPOINTS ]]; then
    Module.execute.usage "mountpoints"
    critical "Pas de point de montage défini"
fi


###
# Traitement pour chaque point de montage à tester
##
for MP in $OLIX_MODULE_MONITOR_MOUNTPOINTS; do
    info "Test du point de montage : $MP"


    ###
    # Test si le point de montage est monté
    ##
    debug "Check mountpoint $MP "
    if ! mountpoint -q $MP; then
        warning "$MP not mount"
        ERR_MESG.push "$MP n'est pas monté"
    else


        ###
        # Check si le point de montage est actif ou répond
        ##
        debug "Check df $MP"
        df -k $MP &>/dev/null &
        DFPID=$!
        for (( i=1 ; i<$TIME_TILL_STALE ; i++ )) ; do
            # Et s'il repond dans les X secondes
            if Process.running $DFPID; then
                debug "No response du PID ($DFPID) df -k $MP"
                sleep 1
            else
                break
            fi
        done

        if Process.running $DFPID; then
            # Si toujours pas de réponse, alors on kill le process DF
            warning "No response de la commande df -k $MP -> kill $DFPID"
            $(Process.kill $DFPID &>/dev/null)
            ERR_MESG.push "$MP n'a pas répondu dans les $TIME_TILL_STALE sec."


        ###
        # Test si le répertoire existe
        ##
        elif ! Directory.exists "$MP"; then
            warning "Directory $MP not exists"
            ERR_MESG.push "$MP n'existe pas dans le filesystem"
        else


            ###
            # Test de la présence d'un fichier
            ##
            if [[ -n $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE ]]; then
                debug "Check if file $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE exists"
                if ! File.exists $MP/$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE; then
                    warning "$OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE not exists in $MP"
                    ERR_MESG.push "Le fichier $OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE n'existe pas dans le point de montage $MP"
                fi
            fi


            ###
            # Test d'ecriture sur le point de montage
            ##
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
                        ERR_MESG.push "Impossible d'ecrire dans $MP en $TIME_TILL_STALE sec."
                    else
                        if ! File.exists $TOUCHFILE; then
                            warning "$TOUCHFILE is not writable"
                            ERR_MESG.push "Impossible d'ecrire dans $MP."
                        else
                            rm $TOUCHFILE &>/dev/null
                        fi
                    fi
                fi
            fi

        fi

    fi

done


###
# Resultat
##
if [[ $(ERR_MESG.count) -ne 0 ]]; then
    echo -n "CRITICAL: "
    for I in $(ERR_MESG.index); do
        echo -n "$(ERR_MESG.get $I) ; "
    done
    echo
    die $OLIX_MODULE_MONITOR_STATE_CRITICAL
fi

echo "OK: Tous les points de montage sont bons ($(String.trim "$OLIX_MODULE_MONITOR_MOUNTPOINTS"))"
die $OLIX_MODULE_MONITOR_STATE_OK
