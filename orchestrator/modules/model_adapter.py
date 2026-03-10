import requests

LMSTUDIO_URL = "http://127.0.0.1:1234/v1/chat/completions"
MODEL_NAME = "mistralai/mistral-7b-instruct-v0.3"


def invoke_model(request, context):

    user_prompt = f"""
You are assisting the ULTRAHUMANIA orchestrator.

Request ID: {request.get("request_id")}
Description: {request.get("description")}

Knowledge context:
{context.get("knowledge_context", "")}

Return a short operational analysis.
"""

    payload = {
        "model": MODEL_NAME,
        "messages": [
            {
                "role": "user",
                "content": user_prompt
            }
        ],
        "temperature": 0.2,
        "max_tokens": 256
    }

    r = requests.post(LMSTUDIO_URL, json=payload, timeout=120)

    data = r.json()

    if "choices" in data:
        response_text = data["choices"][0]["message"]["content"]
    else:
        response_text = str(data)

    proposal = {
        "proposal_id": "proposal_llm",
        "action": "analysis",
        "model_name": MODEL_NAME,
        "provider": "lm_studio_local",
        "llm_response": response_text,
        "context": context
    }

    return proposal
