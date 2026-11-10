"""Read and validate the curated question and graph setup files."""

import json

from app.settings import ROOT


def read_questions(path=ROOT / "questions.json"):
    questions = json.loads(path.read_text(encoding="utf-8"))

    if not isinstance(questions, list) or not questions:
        raise ValueError("questions.json must contain a nonempty array.")

    numbers = set()

    for question in questions:
        if not isinstance(question, dict):
            raise TypeError("Each question must be an object.")

        number = question.get("question_no")

        if type(number) is not int or number < 1 or number in numbers:
            raise ValueError("Question numbers must be unique positive integers.")

        if not all(
            isinstance(question.get(key), str) and question[key].strip()
            for key in ("category", "question", "query", "llm_answer")
        ):
            raise ValueError(
                f"Question {number} needs category, question, query, and llm_answer fields."
            )

        if "graph_answer" in question:
            raise ValueError("graph_answer is reserved for export results.")

        numbers.add(number)

    return questions


def read_statements(path=ROOT / "queries.cypher"):
    # This curated script forbids semicolons in strings and uses full-line comments only.
    text = "\n".join(
        line
        for line in path.read_text(encoding="utf-8").splitlines()
        if not line.lstrip().startswith("//")
    )
    statements = [part.strip() for part in text.split(";") if part.strip()]

    if not statements:
        raise ValueError("queries.cypher contains no statements.")

    return statements
