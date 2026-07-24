"""
main.py -- Library Management System console application

This program connects to the SQL Server LibraryDB database and performs
the required SELECT, INSERT, UPDATE, DELETE, and JOIN operations.
"""

import sys
import pyodbc


class LibraryDatabase:
    def __init__(self, server="localhost", database="LibraryDB"):
        self.server = server
        self.database = database
        self.conn = None

    def connect(self):
        installed_drivers = pyodbc.drivers()

        if "ODBC Driver 18 for SQL Server" in installed_drivers:
            driver = "ODBC Driver 18 for SQL Server"
        elif "ODBC Driver 17 for SQL Server" in installed_drivers:
            driver = "ODBC Driver 17 for SQL Server"
        else:
            raise RuntimeError(
                "ODBC Driver 17 or 18 for SQL Server is not installed."
            )

        connection_string = (
            f"DRIVER={{{driver}}};"
            f"SERVER={self.server};"
            f"DATABASE={self.database};"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;"
        )

        self.conn = pyodbc.connect(connection_string)
        print(f"Connected to {self.database}.")
        return self.conn

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")

    # Required action #1: SELECT
    def get_all_books(self):
        cursor = self.conn.cursor()

        cursor.execute(
            """
            SELECT
                b.BookID,
                b.Title,
                b.ISBN,
                a.FirstName + ' ' + a.LastName AS Author,
                g.GenreName,
                b.PublishedYear,
                b.CopiesAvailable
            FROM lib.Books AS b
            INNER JOIN lib.Authors AS a
                ON b.AuthorID = a.AuthorID
            INNER JOIN lib.Genres AS g
                ON b.GenreID = g.GenreID
            ORDER BY b.BookID;
            """
        )

        return cursor.fetchall()

    # Required action #2: INSERT
    def add_book(self, title, isbn, author_id, genre_id, year, copies):
        cursor = self.conn.cursor()

        cursor.execute(
            """
            INSERT INTO lib.Books
                (Title, ISBN, AuthorID, GenreID, PublishedYear, CopiesAvailable)
            VALUES (?, ?, ?, ?, ?, ?);
            """,
            title,
            isbn,
            author_id,
            genre_id,
            year,
            copies,
        )

        self.conn.commit()
        return cursor.rowcount

    # Required action #3: UPDATE
    def update_book_copies(self, book_id, new_copies):
        cursor = self.conn.cursor()

        cursor.execute(
            """
            UPDATE lib.Books
            SET CopiesAvailable = ?
            WHERE BookID = ?;
            """,
            new_copies,
            book_id,
        )

        rows_changed = cursor.rowcount
        self.conn.commit()
        return rows_changed

    # Required action #4: DELETE
    def delete_book(self, book_id):
        cursor = self.conn.cursor()

        cursor.execute(
            """
            DELETE FROM lib.Books
            WHERE BookID = ?;
            """,
            book_id,
        )

        rows_changed = cursor.rowcount
        self.conn.commit()
        return rows_changed

    # Required action #5: JOIN and GROUP BY
    def get_checkout_report(self):
        cursor = self.conn.cursor()

        cursor.execute(
            """
            SELECT
                m.MemberID,
                m.FirstName + ' ' + m.LastName AS MemberName,
                COUNT(c.CheckoutID) AS BooksCheckedOut
            FROM lib.Members AS m
            INNER JOIN lib.Checkouts AS c
                ON m.MemberID = c.MemberID
            INNER JOIN lib.Books AS b
                ON c.BookID = b.BookID
            WHERE c.ReturnDate IS NULL
            GROUP BY
                m.MemberID,
                m.FirstName,
                m.LastName
            ORDER BY m.MemberID;
            """
        )

        return cursor.fetchall()


def print_rows(headers, rows):
    if not rows:
        print("\nNothing to show.")
        return

    print()
    print(" | ".join(headers))
    print("-" * 100)

    for row in rows:
        print(" | ".join(str(value) for value in row))


def main_menu(db):
    menu = """
==============================
   LIBRARY MANAGEMENT SYSTEM
==============================
1. List all books        (SELECT)
2. Add a new book        (INSERT)
3. Update book copies    (UPDATE)
4. Delete a book         (DELETE)
5. Checkout report       (JOIN + GROUP BY)
0. Exit
Choose an option: """

    while True:
        choice = input(menu).strip()

        try:
            if choice == "1":
                rows = db.get_all_books()

                print_rows(
                    [
                        "Book ID",
                        "Title",
                        "ISBN",
                        "Author",
                        "Genre",
                        "Published Year",
                        "Copies Available",
                    ],
                    rows,
                )

            elif choice == "2":
                print("\nAdd a New Book")

                title = input("Title: ").strip()

                isbn = input(
                    "ISBN (press Enter to leave blank): "
                ).strip()

                if isbn == "":
                    isbn = None

                author_id = int(input("Author ID: "))
                genre_id = int(input("Genre ID: "))

                year_input = input(
                    "Published year (press Enter to leave blank): "
                ).strip()

                if year_input == "":
                    year = None
                else:
                    year = int(year_input)

                copies = int(input("Copies available: "))

                if title == "":
                    print("Title cannot be blank.")

                elif copies < 0:
                    print("Copies cannot be negative.")

                else:
                    db.add_book(
                        title,
                        isbn,
                        author_id,
                        genre_id,
                        year,
                        copies,
                    )

                    print("Book added successfully.")

            elif choice == "3":
                print("\nUpdate Book Copies")

                book_id = int(input("Book ID: "))
                new_copies = int(input("New number of copies: "))

                if new_copies < 0:
                    print("Copies cannot be negative.")

                else:
                    rows_changed = db.update_book_copies(
                        book_id,
                        new_copies,
                    )

                    if rows_changed > 0:
                        print("Book updated successfully.")
                    else:
                        print("No book was found with that ID.")

            elif choice == "4":
                print("\nDelete a Book")

                book_id = int(input("Book ID: "))

                confirmation = input(
                    "Type YES to confirm the deletion: "
                ).strip()

                if confirmation.upper() != "YES":
                    print("Deletion canceled.")

                else:
                    rows_changed = db.delete_book(book_id)

                    if rows_changed > 0:
                        print("Book deleted successfully.")
                    else:
                        print("No book was found with that ID.")

            elif choice == "5":
                rows = db.get_checkout_report()

                print_rows(
                    [
                        "Member ID",
                        "Member Name",
                        "Books Checked Out",
                    ],
                    rows,
                )

            elif choice == "0":
                print("Goodbye!")
                break

            else:
                print("Invalid option. Choose 0 through 5.")

        except ValueError:
            print(
                "Invalid input. Enter a whole number where required."
            )

        except pyodbc.IntegrityError as error:
            db.conn.rollback()

            print("\nThe database rejected the change.")
            print(
                "Check for a duplicate ISBN, an invalid author or "
                "genre ID, or a book connected to a checkout."
            )
            print("Database details:", error)

        except pyodbc.Error as error:
            db.conn.rollback()
            print("\nDatabase error:", error)


def main():
    # YOU MAY NEED TO CHANGE THIS CODE DEPENDING ON YOUR SQL SERVER INSTANCE
    db = LibraryDatabase(
        server=r"localhost\SQLEXPRESS",
        database="LibraryDB"
    )

    try:
        db.connect()
        main_menu(db)

    except (pyodbc.Error, RuntimeError) as error:
        print("\nCould not connect to LibraryDB.")
        print(
            "Run FinalProject-2.sql in SQL Server Management Studio "
            "before starting this program."
        )
        print("Details:", error)
        sys.exit(1)

    finally:
        db.close()


if __name__ == "__main__":
    main()