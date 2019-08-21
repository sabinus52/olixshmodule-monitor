###
# Usage du module MONITOR
# ==============================================================================
# @package olixsh
# @module monitor
# @author Olivier <sabinus52@gmail.com>


###
# Usage principale  du module
##
function olixmodule_monitor_usage_main()
{
    debug "olixmodule_monitor_usage_main ()"
    echo
    echo -e "Check pour SNMP"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}monitor ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} mountpoints ${CVOID}  : Vérification des points de montage"
    echo -e "${Cjaune} help        ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action MOUNTPOINTS
##
function olixmodule_monitor_usage_mountpoints()
{
    debug "olixmodule_alfresco_usage_mountpoints ()"
    echo
    echo -e "Vérification des points de montage"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}monitor ${CJAUNE}mountpoints [OPTIONS] [MOUNTPOINTS...]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --all ${CVOID}"; String.pad "--all" 30 " "; echo " : Utilise les montages dans /etc/fstab"
    echo -en "${CBLANC} --writetest ${CVOID}"; String.pad "--writetest" 30 " "; echo " : Test l'écriture sur le point de montage"
    echo -en "${CBLANC} --checkfile=FILE ${CVOID}"; String.pad "--checkfile=FILE" 30 " "; echo " : Teste la présence d'un fichier FILE"
    echo -en "${CBLANC} MOUNTPOINTS ${CVOID}"; String.pad "MOUNTPOINTS" 30 " "; echo " : Liste des points de montage à tester. Ignoré si --all est donné"
    echo -e "Exemple :"
    echo -e "Pour superviser un point de montage webdav via SNMP, rajouter la ligne suivante dans /etc/snmp/snmpd.conf :"
    echo -e " extend webdav \"/opt/olixsh/olixsh --no-warnings monitor mountpoints /mnt/webdav --writetest --checkfile=.webdav.check\""
}
