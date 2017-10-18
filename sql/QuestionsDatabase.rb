require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end





class User
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_author_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @fname, @lname)
      INSERT INTO
        users (id, fname, lname)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @fname, @lname)
      UPDATE
        users
      SET
        id = ?, fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end


  def followed_questions_for_user_id
    Question_Follows.followed_questions_for_user_id(@id)
  end


end








class Question
  attr_accessor :title, :body, :author_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless question.length > 0

    Question.new(question.first)
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @title, @body, @author_id)
      INSERT INTO
        questions (id, title, body, author_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @title, @body, @author_id)
      UPDATE
        question
      SET
        id = ?, title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

  def followers
    Question_Follows.followers_for_question_id(@id)
  end



end






class Reply
  attr_accessor :question_id, :parent_id, :author_id, :body

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_author_id(author_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def author
    User.find_by_id(@author_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_reply
    reply = QuestionsDBConnection.instance.execute(<<-SQL, @id)

      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @question_id, @parent_id, @author_id, @body)
      INSERT INTO
        replies (id, question_id, parent_id, author_id, body)
      VALUES
        (?, ?, ?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @question_id, @parent_id, @author_id, @body)
      UPDATE
        replies
      SET
        id = ?, question_id = ?, parent_id = ?, author_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end
end






class Question_Like
  attr_accessor :user_id, :question_id,

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| Questions.new(datum) }
  end

  def self.likers_for_questions_id(question_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, question_id)

      SELECT
        user_id
      FROM
        question_likes
      WHERE
        question = ?

    SQL

    questions.map {|user_id| User.find_by_id(user_id)}
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      INSERT INTO
        replies (id, user_id, question_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      UPDATE
        question_likes
      SET
        id = ?, user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end
end






class Question_Follows
  attr_accessor :user_id, :question_id,

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions_follows")
    data.map { |datum| Question_Follows.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      INSERT INTO
        replies (id, user_id, question_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      UPDATE
        question_likes
      SET
        id = ?, user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.followers_for_question_id(question_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        user_id
      FROM
        questions_follows
      WHERE
        question_id = ?
    SQL
    hold = question.map { |h| h['user_id'] }
    hold.map { |e| User.find_by_id(e) }
  end

  def self.followed_questions_for_user_id(user_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        questions_follows
      WHERE
        user_id = ?
    SQL
    hold = question.map { |h| h['question_id'] }
    hold.map { |e| Question.find_by_author_id(e) }
  end

  def most_followed_questions(n)
    follows = QuestionsDBConnection.instance.execute(<<-SQL, n)

      SELECT
        *
      FROM
        questions
      GROUP BY
        question_id
      HAVING


  end

end
