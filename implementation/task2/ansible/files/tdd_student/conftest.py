import os
import socket
import subprocess

# Path where pytest writes the JUnit XML report during this session
_JUNIT_XML = '/tmp/tdd_results.xml'


def pytest_configure(config):
    # Inject --junit-xml automatically so students do not need to pass it manually
    config.option.xmlpath = _JUNIT_XML


def pytest_sessionfinish(session, exitstatus):
    server_url = os.environ.get('SERVER_URL', '').rstrip('/')
    if not server_url:
        return

    if not os.path.exists(_JUNIT_XML):
        return

    student = socket.gethostname()
    url = f'{server_url}/results/{student}'

    try:
        with open(_JUNIT_XML, 'rb') as f:
            xml_data = f.read()

        # Use curl so there is no dependency on the requests library
        subprocess.run(
            ['curl', '-sf', '-X', 'POST',
             '-H', 'Content-Type: application/xml',
             '--data-binary', '@-',
             url],
            input=xml_data,
            check=False,
            timeout=10,
        )
    except Exception:
        # Never interrupt the student's pytest output due to a reporting failure
        pass
