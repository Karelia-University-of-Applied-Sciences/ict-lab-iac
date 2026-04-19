import os
import sqlite3
import xml.etree.ElementTree as ET
from datetime import datetime
from flask import Flask, request, render_template, abort

app = Flask(__name__)
DB_PATH = os.environ.get('TDD_DB', '/opt/tdd-lab/results.db')


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    with get_db() as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS results (
                student TEXT PRIMARY KEY,
                passed  INTEGER NOT NULL DEFAULT 0,
                failed  INTEGER NOT NULL DEFAULT 0,
                total   INTEGER NOT NULL DEFAULT 0,
                updated TEXT NOT NULL
            )
        ''')


@app.route('/results/<student>', methods=['POST'])
def receive_results(student):
    xml_data = request.get_data()
    if not xml_data:
        abort(400, 'Empty body')

    try:
        root = ET.fromstring(xml_data)
    except ET.ParseError:
        abort(400, 'Invalid XML')

    # Support both <testsuites> wrapper and bare <testsuite>
    suite = root if root.tag == 'testsuite' else root.find('testsuite')
    if suite is None:
        abort(400, 'No testsuite element found')

    total  = int(suite.get('tests',    0))
    failed = int(suite.get('failures', 0)) + int(suite.get('errors', 0))
    passed = total - failed

    with get_db() as conn:
        conn.execute('''
            INSERT INTO results (student, passed, failed, total, updated)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(student) DO UPDATE SET
                passed  = excluded.passed,
                failed  = excluded.failed,
                total   = excluded.total,
                updated = excluded.updated
        ''', (student, passed, failed, total, datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')))

    return '', 204


@app.route('/')
def dashboard():
    with get_db() as conn:
        rows = conn.execute(
            'SELECT student, passed, failed, total, updated FROM results ORDER BY student'
        ).fetchall()
    return render_template('dashboard.html', rows=rows)


if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)
