"""Run the graph load, question queries, and CSV export pipeline."""

import argparse
from pathlib import Path

from neo4j import READ_ACCESS

from app.corpus import read_questions, read_statements
from app.database import answer_question, connect, load_graph
from app.exports import export_csv
from app.settings import settings_from_env


def run(output: Path = Path("answers.csv"), env_file: Path | None = None):
    if output.suffix.lower() != ".csv":
        raise ValueError("Export output must have a .csv extension.")

    statements = read_statements()
    questions = read_questions()
    settings = settings_from_env(env_file)

    print("- load the graph", flush=True)

    with connect(settings) as driver:
        counts = load_graph(driver, settings.database, statements)
        print(
            f"    loaded {counts['nodes']} nodes and {counts['relationships']} relationships",
            flush=True,
        )
        print("- run all the questions", flush=True)

        with driver.session(
            database=settings.database, default_access_mode=READ_ACCESS
        ) as session:
            answers = []

            for question in questions:
                answers.append(answer_question(session, question))
                print(
                    f"    answered question {question['question_no']}/{len(questions)}",
                    flush=True,
                )

    print("- export the CSV", flush=True)
    export_csv(output, questions, answers)
    print(f"    exported {len(questions)} questions to {output.resolve()}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--env",
        type=Path,
        default=None,
        help="Environment file to load (default: project-root .env)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("answers.csv"),
        help="Destination CSV path (default: answers.csv)",
    )
    args = parser.parse_args()

    try:
        run(args.output, args.env)
    except Exception as error:
        parser.exit(1, f"Error: {error}\n")


if __name__ == "__main__":
    main()
