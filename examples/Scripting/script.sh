sqlcmd -S <srv> -d <db> --authentication-method ActiveDirectoryServicePrincipal -U "<clientid>@<tenantid>" -P <pw> -i /script.sql