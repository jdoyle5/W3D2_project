DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
  -- questions_id INTEGER NOT NULL

  -- FOREIGN KEY (questions_id) REFERENCES questions(id)
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if exists questions_follows;

CREATE TABLE questions_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)

);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES question(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id)

);


DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES question(id)

);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Love'),
  ('Joey', 'Doyle'),
  ('Tim', 'Bob');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Day?', 'What day of the week is it today?', (SELECT id FROM users WHERE fname = 'John' AND lname = 'Love')),
  ('Project?', 'What project do we have tomorrow?', (SELECT id FROM users WHERE fname = 'Joey' AND lname = 'Doyle'));

INSERT INTO
  questions_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'John' AND lname = 'Love'), (SELECT id FROM questions WHERE title = 'Project?')),
  ((SELECT id FROM users WHERE fname = 'Tim' AND lname = 'Bob'), (SELECT id FROM questions WHERE title = 'Project?'));


INSERT INTO
  replies (question_id, parent_id, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Day?'), NULL, (SELECT id FROM users WHERE fname = 'Tim' AND lname = 'Bob'), 'It is a monday.');
  
INSERT INTO
  replies (question_id, parent_id, author_id, body)
  VALUES
  ((SELECT id FROM questions WHERE title = 'Day?'), (SELECT id FROM replies WHERE body = 'It is a monday.'), (SELECT id FROM users WHERE fname = 'John' AND lname = 'Love'), 'ty');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'John' AND lname = 'Love'), (SELECT id FROM questions WHERE title = 'Day?'));
