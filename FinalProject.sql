/* ===================================================================
   FinalProject.sql
   Library Management System Database
   SQL Server Management Studio 22

   Running this entire script must fully recreate the database --
   no manual steps required.
   =================================================================== */

-- #1 Create the database
IF DB_ID('LibraryDB') IS NOT NULL
BEGIN
    ALTER DATABASE LibraryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryDB;
END
GO

CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

-- #2 Create a meaningful schema (avoid the default "dbo")
CREATE SCHEMA lib;
GO

-- #3 Table: lib.Authors
CREATE TABLE lib.Authors (
    AuthorID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Nationality  NVARCHAR(50) NULL
    -- TODO: any other columns you want to track for an author
);
GO

-- #4 Table: lib.Genres
CREATE TABLE lib.Genres (
    GenreID      INT IDENTITY(1,1) PRIMARY KEY,
    GenreName    NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- #5 Table: lib.Books
--    FK #1: Books.AuthorID -> Authors.AuthorID
--    FK #2: Books.GenreID  -> Genres.GenreID
CREATE TABLE lib.Books (
    BookID          INT IDENTITY(1,1) PRIMARY KEY,
    Title           NVARCHAR(150) NOT NULL,
    ISBN            NVARCHAR(20)  NULL UNIQUE,
    AuthorID        INT NOT NULL,
    GenreID         INT NOT NULL,
    PublishedYear   INT NULL,
    CopiesAvailable INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Books_Authors FOREIGN KEY (AuthorID) REFERENCES lib.Authors(AuthorID),
    CONSTRAINT FK_Books_Genres  FOREIGN KEY (GenreID)  REFERENCES lib.Genres(GenreID)
);
GO

-- #6 Table: lib.Members
CREATE TABLE lib.Members (
    MemberID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Email        NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- #7 Table: lib.Checkouts
--    TODO: decide if you want additional FKs/constraints here
--    (e.g. ReturnDate NULL = still checked out)
CREATE TABLE lib.Checkouts (
    CheckoutID   INT IDENTITY(1,1) PRIMARY KEY,
    BookID       INT NOT NULL,
    MemberID     INT NOT NULL,
    CheckoutDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate      DATE NOT NULL,
    ReturnDate   DATE NULL,
    CONSTRAINT FK_Checkouts_Books   FOREIGN KEY (BookID)   REFERENCES lib.Books(BookID),
    CONSTRAINT FK_Checkouts_Members FOREIGN KEY (MemberID) REFERENCES lib.Members(MemberID)
);
GO

-- #8 Sample data: lib.Authors (need at least 3 rows)
INSERT INTO lib.Authors (FirstName, LastName, Nationality) VALUES
('George', 'Orwell', 'British');
-- TODO: add at least 2 more author rows
GO

-- #9 Sample data: lib.Genres (need at least 3 rows)
INSERT INTO lib.Genres (GenreName) VALUES
('Dystopian');
-- TODO: add at least 2 more genre rows
GO

-- #10 Sample data: lib.Books (need at least 3 rows)
INSERT INTO lib.Books (Title, ISBN, AuthorID, GenreID, PublishedYear, CopiesAvailable) VALUES
('1984', '9780451524935', 1, 1, 1949, 3);
-- TODO: add at least 2 more book rows (make sure AuthorID/GenreID exist)
GO

-- #11 Sample data: lib.Members (need at least 3 rows)
INSERT INTO lib.Members (FirstName, LastName, Email) VALUES
('Ana', 'Torres', 'ana.torres@example.com');
-- TODO: add at least 2 more member rows
GO

-- #12 Sample data: lib.Checkouts (need at least 3 rows)
INSERT INTO lib.Checkouts (BookID, MemberID, DueDate) VALUES
(1, 1, DATEADD(DAY, 14, CAST(GETDATE() AS DATE)));
-- TODO: add at least 2 more checkout rows
GO

-- #13 TODO (optional): stored procedures, e.g. CheckOutBook / ReturnBook,
--     if you want to move some logic into the database layer.

-- #14 Sanity check queries (optional, run manually -- not part of recreate)
-- SELECT * FROM lib.Books;
-- SELECT * FROM lib.Checkouts;
