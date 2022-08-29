from flask import Flask, make_response

import requests
from prometheus_client import Counter, generate_latest
import os
import sys
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)


app = Flask(__name__)
app.config["DEBUG"] = True


REQUESTS = Counter('server_requests_total', 'Total number of requests to this webserver')



@app.route('/<id>', methods=['GET'])
def home(id):
    REQUESTS.inc()
    try:
        logging.info(f"Requests will be at: {os.getenv('DUMMY_PNG_URL')}/{id}")
        r = requests.get(f"{os.getenv('DUMMY_PNG_URL')}/{id}")
        response = make_response(r.content)
        response.headers['Content-Type'] = r.headers['Content-Type']
        logging.info("Done request")
        return response
    except Exception as e:
        logging.error(f"Exceptions: {e}")
        return f'{e}'
        
@app.route('/metrics',methods=['GET'])
def metrics():
    return generate_latest()

@app.route('/health',methods=['GET'])
def health():
    return {'alive': True}
