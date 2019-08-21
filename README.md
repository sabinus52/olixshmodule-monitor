# olixshmodule-monitor
Module for oliXsh : System check for SNMP or Nagios


Les différents check peuvent être exécutés en ligne de commande ou lancés depuis les extends de SNMP.



### Exemple de procédure de check d'un point de montage WebDav

Sur le serveur à checker, modifier le fichier */etc/snmpd/snmpd.conf* en ajouter la ligne suivante :

```
extend webdav "/opt/olixsh/olixsh monitor mountpoints --no-warnings /media/webdav --writetest --checkfile=.webdav.check"
```

Sur le serveur Nagios, utiliser une des deux commandes suivantes :

```
check_snmp -H server.example.com -C public -o NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"webdav\" -r '^OK'
check_snmp -H server.example.com -C public -o .1.3.6.1.4.1.8072.1.3.2.3.1.2.6.119.101.98.100.97.118 -r '^OK'
```


### Check des points de montage

Command : `olixsh monitor mountpoints [mounts...] [--all] [--writetest] [--checkfile=<file>]`

- `mounts...` : Liste des points de montage que l'on veut checker
- `--all` : Utilise les montages à checker dans */etc/fstab*
- `--writetest` : Test l'écriture sur le point de montage
- `--checkfile=<file>` : Teste la présence d'un fichier `file`

