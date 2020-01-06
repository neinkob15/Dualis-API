# Using flask to make an api
# import necessary libraries and functions
from flask import Flask, jsonify, request, Response
from flask_httpauth import HTTPBasicAuth
import subprocess
from flask_cors import CORS
from flask_caching import Cache

config = {
    "DEBUG": True,
    "CACHE_TYPE": "simple",
    "CACHE_DEFAULT_TIMEOUT": 0
}

# creating a Flask app
app = Flask(__name__)
auth = HTTPBasicAuth()
app.config.from_mapping(config)
CORS(app)
cache = Cache(app)


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

# on the terminal type: curl http://127.0.0.1:5000/
# returns hello world when we use GET.
# returns the data that we send when we use POST.
@app.route('/', methods = ['GET', 'POST'])
@auth.login_required
@cache.cached(timeout=20)
def home():
    if(request.method == 'GET'):
        cmd = (['/opt/dualis-app/NOTEN.sh', '-u', auth.username(), '-p', get_password(auth.username())])
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        o, e = proc.communicate()

        data = o.decode('utf-8')
        return Response(data, mimetype='application/json')


# driver function
if __name__ == '__main__':

    app.run(debug = True, host='0.0.0.0', port='5001')

