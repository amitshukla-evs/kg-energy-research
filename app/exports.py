"""CSV export preserving question fields and structured graph answers."""

import csv
import json


def export_csv(path, questions, answers):
    fields = list(dict.fromkeys(key for question in questions for key in question))
    fields.append("graph_answer")

    if len(questions) != len(answers):
        raise ValueError("Each question must have exactly one graph result.")

    with path.open("w", encoding="utf-8", newline="") as output:
        writer = csv.DictWriter(output, fieldnames=fields)
        writer.writeheader()

        for question, answer in zip(questions, answers, strict=True):
            row = {
                key: json.dumps(value, ensure_ascii=False)
                if isinstance(value, (dict, list))
                else value
                for key, value in question.items()
            }
            row["graph_answer"] = json.dumps(answer, ensure_ascii=False)
            writer.writerow(row)
