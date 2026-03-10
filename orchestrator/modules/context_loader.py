from modules.knowledge_db import fetch_recent_knowledge

def load_context():

    knowledge = fetch_recent_knowledge()

    context = {
        "knowledge_context": knowledge
    }

    return context
