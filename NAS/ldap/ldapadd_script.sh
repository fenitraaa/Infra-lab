#!/bin/bash

BINDDN="cn=admin,dc=lab,dc=local"

echo "Enter LDAP Password:"
read -s PASS

for f in 02_ou.ldif 03_group.ldif 04_shares.ldif 05_user.ldif; do
    echo "ldapadd: $f"
    ldapadd -x -D "$BINDDN" -w "$PASS" -c -f "$f"
done

echo "→ ldapmodify : 06_memberships.ldif"
ldapmodify -x -D "$BINDDN" -w "$PASS" -c -f 06_memberships.ldif