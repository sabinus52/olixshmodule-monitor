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


###
# Chargement des librairies requis
##
olixmodule_alfresco_require_libraries()
{
    load "modules/monitor/lib/*"
}


###
# Retourne la liste des modules requis
##
olixmodule_alfresco_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_alfresco_require_binary()
{
    echo -e ""
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_alfresco_include_begin()
# {
# }


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_alfresco_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
# olixmodule_alfresco_list()
# {
# }
