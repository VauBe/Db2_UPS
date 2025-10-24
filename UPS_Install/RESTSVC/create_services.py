import requests
import getpass

##########################################################
#   YOUR CHANGES HERE
##########################################################
user     = 'YOU'            # User to create Services
db2_ip   = 'DB2-IP'         # Db2 IP-Adress / Servicename
db2_port = 'DB2-PORT'       # Db2 Port
collectionID = 'IDUGSVC'    # Collection for Packages
                            # Packages are created automatically
                            # In Correlation to SCHEMA of Functions and Procedures
                            # Should not be the same because of Package Collection
                            # So "SERVICE-"Packages different Collection
owner    = 'IDUG'           # Owner of Package                                                
                            # and Qualifier for objects (Tables, Functions, Procedures)
##########################################################




# Db2 Service Manager
url = f"http://{db2_ip}:{db2_port}/services/DB2ServiceManager"

pwd = getpass.getpass(f"RACF-PW for user {user}")
headers = {"Content-Type":"application/json"}


# Define Function for create service
def create_svc(body):
    response = requests.post(url, auth=(user, pwd), headers=headers, json=body, verify=False)
    # Check for HTTP codes other than 201
    if response.status_code != 201: 
        print('Status:', response.status_code, 'Headers:', response.headers, 'Error Response:', response.content)
 
    print(response.content) 
    
############################################################################
# Define BODY for Services
############################################################################

# CHECK TABLE (CHECKTB)
checktb = {
    "requestType": "createService",
    "sqlStmt": "call CHECKTB(:I_SCHEMA, :I_TBNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "CHECKTB",
    "description": "Check Table",
    "owner"      : owner,
}

# CHECK TABLESPACE (CHECKTS)
checkts = {
    "requestType": "createService",
    "sqlStmt": "call CHECKTS(:I_DBNAME, :I_TSNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "CHECKTS",
    "description": "Check Tablespace",
    "owner"      : owner,
}
# COPY TABLE (COPYTB)
copytb = {
    "requestType": "createService",
    "sqlStmt": "call COPYTB(:I_SCHEMA, :I_TBNAME, :I_HLQ, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "COPYTB",
    "description": "Copy Table",
    "owner"      : owner,
}

# COPY TABLESPACE (COPYTS)
copyts = {
    "requestType": "createService",
    "sqlStmt": "call COPYTS(:I_DBNAME, :I_TSNAME, :I_HLQ, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "COPYTS",
    "description": "Copy Tablespace",
    "owner"      : owner,
}

# DISPLAY TABLE (DISPLAYTB)
displaytb = {
    "requestType": "createService",
    "sqlStmt": "call DISPLAYTB(:I_SCHEMA, :I_TBNAME, :I_OPT, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "DISPLAYTB",
    "description": "Display Table",
    "owner"      : owner,
}

# DISPLAY TABLESPACE (DISPLAYTS)
displayts = {
    "requestType": "createService",
    "sqlStmt": "call DISPLAYTS(:I_DBNAME, :I_TSNAME, :I_OPT, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "DISPLAYTS",
    "description": "Display Tablespace",
    "owner"      : owner,
}

# QUIESCE TABLE (QUIESCETB)
quiescetb = {
    "requestType": "createService",
    "sqlStmt": "call QUIESCETB(:I_SCHEMA, :I_TBNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "QUIESCETB",
    "description": "QUIESCE Table",
    "owner"      : owner,
}

# QUIESCE TABLESPACE (QUIESCETS)
quiescets = {
    "requestType": "createService",
    "sqlStmt": "call QUIESCETS(:I_DBNAME, :I_TSNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "QUIESCETS",
    "description": "QUIESCE Tablespace",
    "owner"      : owner,
}

# REORG TABLE (REORGTB)
reorgtb = {
    "requestType": "createService",
    "sqlStmt": "call REORGTB(:I_SCHEMA, :I_TBNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "REORGTB",
    "description": "Reorg Table",
    "owner"      : owner,
}

# REORG TABLESPACE (REORGTS)
reorgts = {
    "requestType": "createService",
    "sqlStmt": "call REORGTS(:I_DBNAME, :I_TSNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "REORGTS",
    "description": "Reorg Tablespace",
    "owner"      : owner,
}

# RUNSTATS TABLE (RUNSTATSTB)
runstatstb = {
    "requestType": "createService",
    "sqlStmt": "call RUNSTATSTB(:I_SCHEMA, :I_TBNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "RUNSTATSTB",
    "description": "Runstats Table",
    "owner"      : owner,
}

# RUNSTATS TABLESPACE (RUNSTATSTS)
runstatsts = {
    "requestType": "createService",
    "sqlStmt": "call RUNSTATSTS(:I_DBNAME, :I_TSNAME, :RETCODE, :LFDNR)",
    "collectionID": collectionID,
    "serviceName": "RUNSTATSTS",
    "description": "Runstats Tablespace",
    "owner"      : owner,
}


############################################################################
# END of Define BODY for Services
############################################################################

############################################################################
# CREATE SERVICES
############################################################################

# Check
create_svc(checktb)
create_svc(checkts)

# Copy
create_svc(copytb)
create_svc(copyts)

# DISPLAY
create_svc(displaytb)
create_svc(displayts)

# QUIESCE
create_svc(quiescetb)
create_svc(quiescets)

# REORG
create_svc(reorgtb)
create_svc(reorgts)

# RUNSTATS
create_svc(runstatstb)
create_svc(runstatsts)



