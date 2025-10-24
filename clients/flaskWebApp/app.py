# change <db2-ip> and <db2-port> to your settings

from flask import Flask, render_template, request, url_for, flash, redirect, make_response
from flask_restful import Resource, Api, reqparse

import requests, json

app = Flask(__name__)
api = Api(app)

class Db2(Resource):
    # change <db2-ip> and <db2-port> to your settings
    db2rest = 'https://<db2-ip>:<db2-port>/services/IDUGSVC/'         # BASE-URL, IDUGSVC is Collection
    db2header = {"Content-Type":"application/json","Accept":"application/json"}
    
    def quiesce(self, username, password, dbname, tsname):
        print(f" User = {username}")
        service = self.db2rest + 'QUIESCETS'      
        
        data = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

        response = requests.post(service, auth=(username, password), headers=self.db2header, json=data, verify=False)
        response.raise_for_status()

        print(json.loads(response.text))
        return {"response": response.text}, 201
    
    def reorg(self, username, password, dbname, tsname):
        print(f" User = {username}")
        service = self.db2rest + 'REORGTS'    
        
        data = {"I_DBNAME": dbname,
        "I_TSNAME": tsname,
        "RETCODE": '',
        "LFDNR":   ''}

        response = requests.post(service, auth=(username, password), headers=self.db2header, json=data, verify=False)
        response.raise_for_status()

        print(json.loads(response.text))
        return {"response": response.text}, 201
    def get(self, fkt=''):
        print("get")
        print(f"FKT = {fkt}")
        return "GET", 200
    
    def post(self, fkt=''):
        message = "POST"
        data = request.get_json()
        #print(f"POST DATA = {data} using function = {fkt}")
        #data contains password!
        if fkt == 'quiesce':
            message = self.quiesce(username=data.get('username')
                                 , password=data.get('password')
                                 , dbname=data.get('dbname')
                                 , tsname=data.get('tsname')
                                 )
        if fkt == 'reorg':
            message = self.reorg(username=data.get('username')
                                 , password=data.get('password')
                                 , dbname=data.get('dbname')
                                 , tsname=data.get('tsname')
                                 )
        return message, 201
    
class Home(Resource):
    def get(self):
        headers = {'Content-Type': 'text/html'}
        return make_response(render_template('index.html'), 200, headers)
    

api.add_resource(Db2, "/db2/<fkt>", endpoint='/db2')
api.add_resource(Home, "/", endpoint='/home')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8889)
