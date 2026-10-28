import json
import os
import uuid
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

import boto3
from botocore.exceptions import BotoCoreError, ClientError


REGION = os.environ["AWS_REGION"]
TABLE = boto3.resource("dynamodb", region_name=REGION).Table(os.environ["TABLE_NAME"])
INDEX = Path("/opt/active-active/index.html")
MAX_BODY_BYTES = 4096


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/healthz":
            self.send_json(200, {"status": "ok", "region": REGION})
            return
        if path == "/":
            body = INDEX.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if path == "/api/events":
            try:
                result = TABLE.scan(Limit=25)
            except (BotoCoreError, ClientError):
                self.log_error("DynamoDB scan failed")
                self.send_json(503, {"error": "Event store is temporarily unavailable"})
                return
            events = sorted(
                result.get("Items", []),
                key=lambda item: item.get("created_at", ""),
                reverse=True,
            )
            self.send_json(200, {"region": REGION, "events": events})
            return
        self.send_json(404, {"error": "Not found"})

    def do_POST(self):
        if urlsplit(self.path).path != "/api/events":
            self.send_json(404, {"error": "Not found"})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_json(400, {"error": "Invalid content length"})
            return
        if length < 1 or length > MAX_BODY_BYTES:
            self.send_json(413, {"error": "Request body must be between 1 and 4096 bytes"})
            return

        try:
            payload = json.loads(self.rfile.read(length))
        except (json.JSONDecodeError, UnicodeDecodeError):
            self.send_json(400, {"error": "Request body must be valid JSON"})
            return
        if not isinstance(payload, dict) or not isinstance(payload.get("message"), str):
            self.send_json(400, {"error": "A message string is required"})
            return

        message = payload["message"].strip()
        if not message or len(message) > 200:
            self.send_json(400, {"error": "Message must contain 1 to 200 characters"})
            return

        item = {
            "event_id": str(uuid.uuid4()),
            "message": message,
            "region": REGION,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        try:
            TABLE.put_item(Item=item)
        except (BotoCoreError, ClientError):
            self.log_error("DynamoDB put_item failed")
            self.send_json(503, {"error": "Event store is temporarily unavailable"})
            return
        self.send_json(201, {"status": "created", **item})

    def log_message(self, format_string, *args):
        print("%s - %s" % (self.address_string(), format_string % args), flush=True)


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
