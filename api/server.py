from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

ALLOWED_COMMANDS = {
    "reboot": ["reboot"],
    "shutdown": ["poweroff"],
    "uptime": ["uptime"],
    "hostname": ["hostname"],
}

@app.route("/run", methods=["POST"])
def run_command():
    data = request.get_json(force=True)
    command = data.get("command")

    if command not in ALLOWED_COMMANDS:
        return jsonify({"error": "command not allowed"}), 403

    result = subprocess.run(
        ALLOWED_COMMANDS[command],
        capture_output=True,
        text=True
    )

    return jsonify({
        "stdout": result.stdout,
        "stderr": result.stderr,
        "exit_code": result.returncode
    })

app.run(host="127.0.0.1", port=9999)
