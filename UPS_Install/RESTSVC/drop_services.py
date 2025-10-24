import requests
import getpass

##########################################################
#   YOUR CHANGES HERE
##########################################################
user     = 'YOU'            # User to create Services
db2_ip   = 'DB2-IP'         # Db2 IP-Adress / Servicename
db2_port = 'DB2-PORT'       # Db2 Port
collectionID = 'IDUGSVC'    # Collection for Packages
                            # Packages are created autom.
owner    = 'IDUG'           # Owner of Package                                                
                            # and Qualifier for objects (Tables, Functions, Procedures)
##########################################################


# Db2 Service Manager
url = f"http://{db2_ip}:{db2_port}/services/DB2ServiceManager"

pwd = getpass.getpass(f"RACF-PW for user {user}")
headers = {"Content-Type":"application/json"}


# Define Function for create service
def drop_svc(serviceName):
    
    body = {
        "requestType": "dropService",
        "collectionID": collectionID,
        "serviceName": serviceName.upper(),
        "version"      : "V1",
    }
    response = requests.post(url, auth=(user, pwd), headers=headers, json=body, verify=False)
    # Check for HTTP codes other than 202
    if response.status_code != 201: 
        print('Status:', response.status_code, 'Headers:', response.headers, 'Error Response:', response.content)
    print(response.content) 

# Check
#drop_svc('checktb')
#drop_svc('checkts')

# Copy
#drop_svc('copytb')
#drop_svc('copyts')

# DISPLAY
#drop_svc('displaytb')
#drop_svc('displayts')

# QUIESCE
#drop_svc('quiescetb')
#drop_svc('quiescets')

# REORG
#drop_svc('reorgtb')
#drop_svc('reorgts')

# RUNSTATS
#drop_svc('runstatstb')
#drop_svc('runstatsts')




