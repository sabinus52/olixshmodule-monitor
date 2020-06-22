###
# Librairies pour le module MONITOR
# ==============================================================================
# @package olixsh
# @module monitor
# @author Olivier <sabinus52@gmail.com>
##



###
# Déclenche une erreur
# @param $1 : Message d'erreur
##
function Monitor.zabbix.return()
{
    debug "Monitor.zabbix.return ($1, $2)"
    warning "$2"
    echo "$1"
    die 0
}

