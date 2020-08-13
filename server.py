from flask import Flask, jsonify, request, Response
from flask_httpauth import HTTPBasicAuth
import subprocess
from flask_cors import CORS

app = Flask(__name__)
auth = HTTPBasicAuth()
CORS(app)


def pass_store():
    pass_store.var = 'mypass'


@auth.verify_password
def verify_password(username, password):
    pass_store.var = password
    if username != "":
        return True
    return False

@auth.get_password
def get_password(username):
    return pass_store.var

pass_store()


@app.route('/grades', methods = ['GET'])
@auth.login_required
def myhome():
    cmd = ['/bin/bash', '/opt/dualis-app/NOTEN.sh', '-u', auth.username(), '-p', get_password(auth.username())]
    o = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    data = o.decode('utf-8')
    if (data == "[\n]\n"):
        return Response("{\"error\": {\"status\": 401, \"message\":\"Bad Authentication data!\"}}", status=401, mimetype='application/json')
    return Response(data, mimetype='application/json')

@app.route('/modules', methods = ['GET'])
@auth.login_required
def mymodules():
    cmd = ['/bin/bash', '/opt/dualis-app/MODULE.sh', '-u', auth.username(), '-p', get_password(auth.username())]
    o = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    data = o.decode('utf-8')
    if (data == "[\n]\n"):
        return Response("{\"error\": {\"status\": 401, \"message\":\"Bad Authentication data!\"}}", status=401, mimetype='application/json')
    return Response(data, mimetype='application/json')


if __name__ == '__main__':
    app.run(debug = True, host='0.0.0.0', port='5001')

