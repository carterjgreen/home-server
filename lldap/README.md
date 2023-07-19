# Instructions

1. Create namespace lldap
2. Create secret lldap-credentials with lldap-jwt-secret, lldap-ldap-user-pass, and base-dn
3. Access admin page with ```kubectl port-forward service/lldap-service 17170:17170 -n lldap```
