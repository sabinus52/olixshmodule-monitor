###
# Module de la gestion du serveur MONITOR
# ==============================================================================
# @package olixsh
# @module monitor
# @label Check de monitoring
# @author Olivier <sabinus52@gmail.com>
##



###
# Paramètres du modules
##
OLIX_MODULE_MONITOR_STATE_OK=0
OLIX_MODULE_MONITOR_STATE_WARNING=1
OLIX_MODULE_MONITOR_STATE_CRITICAL=2
OLIX_MODULE_MONITOR_STATE_UNKNOW=3


###
# Chargement des librairies requis
##
olixmodule_monitor_require_libraries()
{
    load "modules/monitor/lib/*"
}


###
# Retourne la liste des modules requis
##
olixmodule_monitor_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_monitor_require_binary()
{
    echo -e ""
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_monitor_include_begin()
# {
# }


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_monitor_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
# olixmodule_monitor_list()
# {
# }
