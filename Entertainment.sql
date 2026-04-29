
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Booking_Seats;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Show_Pricing;
DROP TABLE IF EXISTS Seats;
DROP TABLE IF EXISTS Shows;
DROP TABLE IF EXISTS Movie_Languages;
DROP TABLE IF EXISTS Languages;
DROP TABLE IF EXISTS Movie_Genres;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Screens;
DROP TABLE IF EXISTS Theatres;
DROP TABLE IF EXISTS Cities;
DROP TABLE IF EXISTS Users;



CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    user_email VARCHAR(100)
);

CREATE TABLE Cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100)
);

CREATE TABLE Theatres (
    theatre_id INT PRIMARY KEY,
    theatre_name VARCHAR(100),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Screens (
    screen_id INT PRIMARY KEY,
    theatre_id INT,
    screen_name VARCHAR(100),
    FOREIGN KEY (theatre_id) REFERENCES Theatres(theatre_id)
);

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100),
    duration INT
);

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(100)
);

CREATE TABLE Movie_Genres (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);

CREATE TABLE Languages (
    language_id INT PRIMARY KEY,
    language_name VARCHAR(100)
);

CREATE TABLE Movie_Languages (
    movie_id INT,
    language_id INT,
    PRIMARY KEY (movie_id, language_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (language_id) REFERENCES Languages(language_id)
);

CREATE TABLE Shows (
    show_id INT PRIMARY KEY,
    movie_id INT,
    screen_id INT,
    show_date DATE,
    show_time TIME,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

CREATE TABLE Seats (
    seat_id INT PRIMARY KEY,
    screen_id INT,
    seat_number VARCHAR(20),
    seat_type VARCHAR(50),
    is_available BOOLEAN,
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

CREATE TABLE Show_Pricing (
    pricing_id INT PRIMARY KEY,
    show_id INT,
    seat_type VARCHAR(50),
    price DECIMAL(10,2),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    user_id INT,
    show_id INT,
    booking_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE Booking_Seats (
    booking_id INT,
    seat_id INT,
    PRIMARY KEY (booking_id, seat_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    payment_date DATE,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);




INSERT INTO Users VALUES
(1, 'Vaishnavi', 'vaish@example.com'),
(2, 'Goutami', 'gout@example.com');

INSERT INTO Cities VALUES
(1, 'Bangalore'),
(2, 'Mangalore');

INSERT INTO Theatres VALUES
(1, 'PVR Forum', 1),
(2, 'INOX Mall', 2);

INSERT INTO Screens VALUES
(1, 1, 'Screen 1'),
(2, 1, 'Screen 2');

INSERT INTO Movies VALUES
(1, 'Avengers', 180),
(2, 'Interstellar', 170);

INSERT INTO Genres VALUES
(1, 'Action'),
(2, 'Sci-Fi');

INSERT INTO Movie_Genres VALUES
(1, 1),
(1, 2),
(2, 2);

INSERT INTO Languages VALUES
(1, 'English'),
(2, 'Hindi');

INSERT INTO Movie_Languages VALUES
(1, 1),
(2, 1),
(2, 2);

INSERT INTO Shows VALUES
(1, 1, 1, '2026-04-30', '18:00:00'),
(2, 2, 2, '2026-04-30', '21:00:00');

INSERT INTO Seats VALUES
(1, 1, 'A1', 'Gold', 1),
(2, 1, 'A2', 'Gold', 1),
(3, 1, 'A3', 'Silver', 1),
(4, 2, 'B1', 'Gold', 1);

INSERT INTO Show_Pricing VALUES
(1, 1, 'Gold', 250.00),
(2, 1, 'Silver', 180.00),
(3, 2, 'Gold', 300.00);

INSERT INTO Bookings VALUES
(1, 1, 1, '2026-04-28'),
(2, 2, 2, '2026-04-28');

INSERT INTO Booking_Seats VALUES
(1, 1),
(1, 2),
(2, 4);

INSERT INTO Payments VALUES
(1, 1, 500.00, 'UPI', 'Paid', '2026-04-28'),
(2, 2, 300.00, 'Card', 'Pending', '2026-04-28');
SELECT
    b.booking_id,
    u.user_name,
    m.movie_name,
    t.theatre_name,
    s.show_date,
    s.show_time,
    se.seat_number,
    p.payment_status
FROM Bookings b
JOIN Users u
    ON b.user_id = u.user_id
JOIN Shows s
    ON b.show_id = s.show_id
JOIN Movies m
    ON s.movie_id = m.movie_id
JOIN Screens sc
    ON s.screen_id = sc.screen_id
JOIN Theatres t
    ON sc.theatre_id = t.theatre_id
JOIN Booking_Seats bs
    ON b.booking_id = bs.booking_id
JOIN Seats se
    ON bs.seat_id = se.seat_id
JOIN Payments p
    ON b.booking_id = p.booking_id
WHERE b.user_id = 1
AND b.booking_date BETWEEN '2026-04-01' AND '2026-04-30';
SELECT
    m.movie_name,
    COUNT(b.booking_id) AS total_bookings
FROM Bookings b
JOIN Shows s
    ON b.show_id = s.show_id
JOIN Movies m
    ON s.movie_id = m.movie_id
GROUP BY m.movie_name
ORDER BY total_bookings DESC
LIMIT 1;
SELECT
    sh.show_id,
    m.movie_name,
    sh.show_date,
    sh.show_time,
    COUNT(bs.seat_id) AS total_booked_seats,
    (
        SELECT COUNT(*)
        FROM Seats st
        WHERE st.screen_id = sh.screen_id
    ) - COUNT(bs.seat_id) AS available_seats
FROM Shows sh
JOIN Movies m
    ON sh.movie_id = m.movie_id
JOIN Screens sc
    ON sh.screen_id = sc.screen_id
JOIN Theatres t
    ON sc.theatre_id = t.theatre_id
LEFT JOIN Bookings b
    ON sh.show_id = b.show_id
LEFT JOIN Booking_Seats bs
    ON b.booking_id = bs.booking_id
WHERE t.theatre_id = 1
AND sh.show_date = '2026-04-30'
GROUP BY
    sh.show_id,
    m.movie_name,
    sh.show_date,
    sh.show_time,
    sh.screen_id;

BEGIN TRANSACTION;

SELECT *
FROM Seats
WHERE seat_id = 3
AND is_available = 1;

INSERT INTO Bookings VALUES
(3, 2, 1, '2026-04-28');

INSERT INTO Booking_Seats VALUES
(3, 3);

INSERT INTO Payments VALUES
(3, 3, 250.00, 'UPI', 'Pending', '2026-04-28');

UPDATE Seats
SET is_available = 0
WHERE seat_id = 3;

COMMIT;
/*or else rollback*/