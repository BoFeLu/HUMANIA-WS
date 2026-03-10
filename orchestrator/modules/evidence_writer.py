import json
import os
from datetime import datetime

EVIDENCE_DIR = r"C:\HUMANIA\orchestrator\evidence"

def write_evidence(record):

    ts = datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    filename = f"evidence_{ts}.json"

    path = os.path.join(EVIDENCE_DIR, filename)

    with open(path,"w",encoding="utf8") as f:
        json.dump(record,f,indent=2)

    return path
