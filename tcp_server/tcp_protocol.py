import json

class TCPProtocol:
    @staticmethod
    def parse_message(raw_data):
        try:
            message = json.loads(raw_data.decode('utf-8'))
            if "action" not in message or "parameters" not in message:
                return None, "Format JSON invalide"
            return message, None
        except json.JSONDecodeError:
            return None, "JSON invalide"

    @staticmethod
    def make_response(status="OK", response_data=None):
        return json.dumps({
            "status": status,
            "response": response_data or {}
        }).encode('utf-8')
