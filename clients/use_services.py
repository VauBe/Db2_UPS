import requests
import getpass
import json

##########################################################
#   YOUR CHANGES HERE
##########################################################
user     = 'YOU'            # User to create Services
db2_ip   = 'DB2-IP'         # Db2 IP-Adress / Servicename
db2_port = 'DB2-PORT'       # Db2 Port
collectionID = 'IDUGSVC'    # Collection for Packages
                            # Packages are created autom.
# Parameters for Sample / IVP                            
table_schema = 'IDUG'       # Schema of sample table
table_name   = 'PROCPROT'   # Sample table name
#
dbname       = 'DBIDUG'     # Sample Database Name
tsname       = 'TSIDUG01'   # Sample Tablespace Name
##########################################################


# Db2 Service Manager
url = f"http://{db2_ip}:{db2_port}/services/{collectionID}/"

pwd = getpass.getpass(f"RACF-PW for user {user}")
headers = {"Content-Type":"application/json","Accept":"application/json"}

def use_svc(fkt, data):
    service = url + fkt.upper()
    print("CALLING DB2 SERVICE:  " + service) 
    response = requests.post(service, auth=(user, pwd), headers=headers, json=data, verify=False)
    response.raise_for_status()

    text = json.loads(response.text)
    for k, v in text.items():
        #print(f"Key = {k} mit Value: {v}")
        if "ResultSet" in k:
            for row in v:
                print(f"{fkt.upper()}: {row}")   


############################################################################
# Define BODY for Services
############################################################################
#
# Bodies are almost everywhere the same for "TS" and "TB"
# COPY has additional Parameter I_HLQ for HLQ of Dataset
# DISPLAY has additional Parameter I_OPT for Display OPTION
#

# CHECK TABLE (CHECKTB)
checktb =  {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "RETCODE": '',
        "LFDNR":   ''}

# CHECK TABLESPACE (CHECKTS)
checkts = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

# COPY TABLE (COPYTB)
copytb = {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "I_HLQ" : '',
        "RETCODE": '',
        "LFDNR":   ''}

# COPY TABLESPACE (COPYTS)
copyts = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "I_HLQ": '',
        "RETCODE": '',
        "LFDNR":   ''}

# DISPLAY TABLE (DISPLAYTB)
displaytb = {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "I_OPT" : 'ADV',
        "RETCODE": '',
        "LFDNR":   ''}

# DISPLAY TABLESPACE (DISPLAYTS)
displayts = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "I_OPT": 'ADV',
        "RETCODE": '',
        "LFDNR":   ''}

# QUIESCE TABLE (QUIESCETB)
quiescetb = {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "RETCODE": '',
        "LFDNR":   ''}

# QUIESCE TABLESPACE (QUIESCETS)
quiescets = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

# REORG TABLE (REORGTB)
reorgtb = {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "RETCODE": '',
        "LFDNR":   ''}

# REORG TABLESPACE (REORGTS)
reorgts = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

# RUNSTATS TABLE (RUNSTATSTB)
runstatstb = {"I_SCHEMA": table_schema,
        "I_TBNAME": table_name,
        "RETCODE": '',
        "LFDNR":   ''}

# RUNSTATS TABLESPACE (RUNSTATSTS)
runstatsts = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

############################################################################
# END of Define BODY for Services
############################################################################

############################################################################
# CALL / USE SERVICES
############################################################################

# Check
use_svc('checktb', checktb)
use_svc('checkts', checkts)

# COPY
use_svc('copytb', copytb)
use_svc('copyts', copyts)

# DISPLAY
use_svc('displaytb', displaytb)
use_svc('displayts', displayts)

# QUIESCE
use_svc('quiescetb', quiescetb)
use_svc('quiescets', quiescets)

# REORG
use_svc('reorgtb', reorgtb)
use_svc('reorgts', reorgts)

# RUNSTATS
use_svc('runstatstb', runstatstb)
use_svc('runstatsts', runstatsts)


