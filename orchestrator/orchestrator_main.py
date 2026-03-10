from datetime import datetime, UTC
from modules.context_loader import load_context
from modules.model_adapter import invoke_model
from modules.approval_gate import request_approval
from modules.execution_dispatch import dispatch_execution
from modules.evidence_writer import write_evidence

def run():

    run_ts = datetime.now(UTC).strftime("%Y%m%d_%H%M%S")
    request_id = f"req_{run_ts}"

    request = {
        "request_id": request_id,
        "description": "test orchestration cycle"
    }

    print(f"[UH_ORCH] run start: {request_id}")

    context = load_context()
    print("[UH_ORCH] context loaded")

    proposal = invoke_model(request, context)
    print("[UH_ORCH] model invoked")

    approval = request_approval(proposal)
    print(f"[UH_ORCH] approval decision: {approval['decision']}")

    if approval["decision"] != "approved":
        evidence_path = write_evidence({
            "run_id": request_id,
            "timestamp_utc": run_ts,
            "stage": "approval",
            "result": "rejected",
            "proposal": proposal
        })
        print(f"[UH_ORCH] evidence written: {evidence_path}")
        return

    result = dispatch_execution(proposal)
    print("[UH_ORCH] execution dispatched")

    evidence_path = write_evidence({
        "run_id": request_id,
        "timestamp_utc": run_ts,
        "stage": "execution",
        "proposal": proposal,
        "result": result
    })

    print(f"[UH_ORCH] evidence written: {evidence_path}")
    print(f"[UH_ORCH] run complete: {request_id}")

if __name__ == "__main__":
    run()
