<cffunction name="TransactionRollBack" output="no" returntype="void" hint="rolls back a pending transaction">
    <cftransaction action="rollback"/>
</cffunction>