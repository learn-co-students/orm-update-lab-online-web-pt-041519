require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_reader :id
  attr_accessor :name , :grade

  def initialize(name, grade , id=nil)
    @name, @grade, @id = name, grade, id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
      )
  SQL
  DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save #not a class
    if self.id
      self.update
    else
      sql = <<-SQL
       INSERT INTO students (name, grade)
       VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade) #hash of attribute
    student = Student.new(name, grade)  #create a new student objec
    student.save
    student #returns the new object that it instantiated
  end

  def self.new_from_db(row)
  # create a new Student object given a row from the database
    # self.new is the same as running Song.new
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(name,grade,id)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end
