"""
main.py -- Library Management System console app (SKELETON)

Fill in the TODOs. Each required rubric action has its own method
stub so it's easy to demo separately in your video.

Connection string format required by the assignment:
    Server=localhost;Database=YourDatabaseName;Trusted_Connection=True;

For pyodbc you need to add a Driver= piece too -- see connect() below.
"""

import pyodbc


class LibraryDatabase:
    """Wraps the SQL Server connection. The app must fail if the DB
    doesn't exist -- do NOT fall back to in-memory/mock data."""

    def __init__(self, server="localhost", database="LibraryDB"):
        self.server = server
        self.database = database
        self.conn = None

    def connect(self):
        # TODO: confirm driver name installed on your machine
        # (17 or 18). This mirrors: Server=...;Database=...;Trusted_Connection=True;
        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"Server={self.server};Database={self.database};"
            f"Trusted_Connection=True;"
        )
        self.conn = pyodbc.connect(conn_str)  # will raise/fail if DB doesn't exist
        return self.conn

    def close(self):
        if self.conn:
            self.conn.close()

    # ---- Required action #1: READ (SELECT) ----
    def get_all_books(self):
        # TODO: SELECT from lib.Books (join Authors/Genres for readable output)
        pass

    # ---- Required action #2: CREATE (INSERT) ----
    def add_book(self, title, isbn, author_id, genre_id, year, copies):
        # TODO: parameterized INSERT into lib.Books
        # Use ? placeholders + a params list/tuple -- never string-format
        # user input directly into the SQL string.
        pass

    # ---- Required action #3: UPDATE ----
    def update_book_copies(self, book_id, new_copies):
        # TODO: parameterized UPDATE lib.Books SET CopiesAvailable = ? WHERE BookID = ?
        pass

    # ---- Required action #4: DELETE ----
    def delete_book(self, book_id):
        # TODO: parameterized DELETE FROM lib.Books WHERE BookID = ?
        pass

    # ---- Required action #5: JOIN query (bonus: + GROUP BY) ----
    def get_checkout_report(self):
        # TODO: SELECT ... FROM lib.Checkouts
        #       JOIN lib.Books ON ...
        #       JOIN lib.Members ON ...
        # Bonus: GROUP BY member and COUNT checkouts
        pass


def print_rows(rows):
    if not rows:
        print("  (nothing to show)")
        return
    for row in rows:
        print("  ", row)


def main_menu(db: LibraryDatabase):
    menu = """
==============================
   LIBRARY MANAGEMENT SYSTEM
==============================
1. List all books        (SELECT)
2. Add a new book         (INSERT)
3. Update book copies     (UPDATE)
4. Delete a book          (DELETE)
5. Checkout report        (JOIN)
0. Exit
Choose an option: """

    # TODO: loop until the user chooses to exit (menu must repeat)
    while True:
        choice = input(menu).strip()

        if choice == "1":
            # TODO: call db.get_all_books() and print_rows(result)
            pass

        elif choice == "2":
            # TODO: gather input() values, call db.add_book(...)
            pass

        elif choice == "3":
            # TODO: gather input() values, call db.update_book_copies(...)
            pass

        elif choice == "4":
            # TODO: gather input() value, call db.delete_book(...)
            pass

        elif choice == "5":
            # TODO: call db.get_checkout_report() and print_rows(result)
            pass

        elif choice == "0":
            print("Goodbye!")
            break

        else:
            print("Invalid option, try again.")


def main():
    db = LibraryDatabase(server="localhost", database="LibraryDB")
    db.connect()  # should raise an error here if LibraryDB doesn't exist
    try:
        main_menu(db)
    finally:
        db.close()


if __name__ == "__main__":
    main()
