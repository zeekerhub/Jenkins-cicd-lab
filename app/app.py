from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return f'''
    <h1>Jenkins + Docker CI/CD</h1>
    <p>Build Number: {os.environ.get("BUILD_NUMBER", "local")}</p>
    <p>Running on host: {socket.gethostname()}</p>
    <p>Version: 1.0.0/Version: 1.0.1/g'
    '''

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)