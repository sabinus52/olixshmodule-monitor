###
# Parse les paramètres de la commande en fonction des options
# ==============================================================================
# @package olixsh
# @module monitor
# @author Olivier <sabinus52@gmail.com>
##



###
# Parsing des paramètres
##
function olixmodule_monitor_params_parse()
{
    debug "olixmodule_monitor_params_parse ($@)"
    local ACTION=$1
    local PARAM

    shift
    while [[ $# -ge 1 ]]; do
        shift
    done
}
