"""Neo4j connections, atomic loading, and question execution."""

from contextlib import contextmanager

from neo4j import READ_ACCESS, GraphDatabase

from app.settings import Settings


@contextmanager
def connect(settings: Settings):
    with GraphDatabase.driver(
        settings.uri,
        auth=(settings.username, settings.password.get_secret_value()),
        connection_timeout=10,
    ) as driver:
        driver.verify_connectivity()

        yield driver


@contextmanager
def read_session(settings: Settings):
    with (
        connect(settings) as driver,
        driver.session(
            database=settings.database, default_access_mode=READ_ACCESS
        ) as session,
    ):
        ready = session.run(
            "MATCH (p:Project {id: 'alpine'}) RETURN count(p) AS count"
        ).single()["count"]

        if not ready:
            raise ValueError("Corpus graph is not loaded. Run load --yes first.")

        yield session


def load_graph(driver, database, statements):
    schema = [
        statement
        for statement in statements
        if statement.startswith("CREATE CONSTRAINT")
    ]
    data = [
        statement
        for statement in statements
        if not statement.startswith("CREATE CONSTRAINT")
    ]

    with driver.session(database=database) as session:
        for statement in schema:
            session.run(statement).consume()

        # Reset and rebuild share one transaction: a failed import preserves the old graph.
        with session.begin_transaction() as transaction:
            for statement in data:
                transaction.run(statement).consume()

            counts = (
                transaction.run(
                    "MATCH (n) RETURN count(n) AS nodes, "
                    "COUNT { ()-[]->() } AS relationships"
                )
                .single()
                .data()
            )
            transaction.commit()

    return counts


def answer_question(session, question):
    return session.execute_read(
        lambda transaction: transaction.run(question["query"]).data()
    )
