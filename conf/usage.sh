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
    echo -e "${Cjaune} help      ${CVOID}  : Affiche cet écran"
}
