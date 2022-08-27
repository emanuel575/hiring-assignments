from flask import Flask, make_response

import requests
from prometheus_client import Counter, generate_latest
import os

app = Flask(__name__)
app.config["DEBUG"] = True


REQUESTS = Counter('server_requests_total', 'Total number of requests to this webserver')



@app.route('/<id>', methods=['GET'])
def home(id):
    REQUESTS.inc()
    try:
        r = requests.get(f"{os.getenv('DUMMY_PNG_URL')}/{id}")
        response = make_response(r.content)
        response.headers['Content-Type'] = r.headers['Content-Type']
        return response
    except Exception as e:
        return f'{e}'
        
@app.route('/metrics',methods=['GET'])
def metrics():
    return generate_latest()

@app.route('/health',methods=['GET'])
def health():
    return {'alive': True}
