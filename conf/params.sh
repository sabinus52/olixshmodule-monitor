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

    shift
    case $ACTION in
        mountpoints)
            olixmodule_monitor_params_parse_mountpoints $@
            ;;
        zmountpoint)
            olixmodule_monitor_params_parse_zmountpoint $@
            ;;
    esac
}


function olixmodule_monitor_params_parse_mountpoints()
{
    debug "olixmodule_monitor_params_parse_mountpoints ($@)"

    OLIX_MODULE_MONITOR_MOUNTPOINTS_ALL=false
    OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=false

    while [[ $# -ge 1 ]]; do
        case $1 in
            --all)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_ALL=true
                ;;
            --writetest)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=true
                ;;
            --checkfile=*)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE=$(String.explode.value $1)
                ;;
            *)
                OLIX_MODULE_MONITOR_MOUNTPOINTS="${OLIX_MODULE_MONITOR_MOUNTPOINTS} $1"
                ;;
        esac
        shift
    done

    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_ALL=${OLIX_MODULE_MONITOR_MOUNTPOINTS_ALL}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=${OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE=${OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS=${OLIX_MODULE_MONITOR_MOUNTPOINTS}"
}


function olixmodule_monitor_params_parse_zmountpoint()
{
    debug "olixmodule_monitor_params_parse_zmountpoint ($@)"

    OLIX_MODULE_MONITOR_MOUNTPOINTS_DISCOVERY=false
    OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=false

    while [[ $# -ge 1 ]]; do
        case $1 in
            --discovery)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_DISCOVERY=true
                ;;
            --writetest=*)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=$(String.explode.value $1)
                ;;
            --checkfile=*)
                OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE=$(String.explode.value $1)
                ;;
            *)
                OLIX_MODULE_MONITOR_MOUNTPOINT=$1
                ;;
        esac
        shift
    done

    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_DISCOVERY=${OLIX_MODULE_MONITOR_MOUNTPOINTS_DISCOVERY}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST=${OLIX_MODULE_MONITOR_MOUNTPOINTS_WRITETEST}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE=${OLIX_MODULE_MONITOR_MOUNTPOINTS_CHECKFILE}"
    debug "OLIX_MODULE_MONITOR_MOUNTPOINT=${OLIX_MODULE_MONITOR_MOUNTPOINT}"
}
