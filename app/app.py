from flask import Flask, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import os
import socket
import time

app = Flask(__name__)

# Create metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['endpoint', 'method'])
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration', ['endpoint'])

@app.route('/')
def home():
    start = time.time()
    REQUEST_COUNT.labels(endpoint='/', method='GET').inc()
    response = f'''
    <h1>Jenkins + Docker CI/CD</h1>
    <p>Build Number: {os.environ.get("BUILD_NUMBER", "local")}</p>
    <p>Running on host: {socket.gethostname()}</p>
    <p>Version: 2.0.0</p>
    '''
    REQUEST_DURATION.labels(endpoint='/').observe(time.time() - start)
    return response

@app.route('/health')
def health():
    REQUEST_COUNT.labels(endpoint='/health', method='GET').inc()
    return {"status": "healthy"}, 200

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
