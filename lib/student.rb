require_relative "../config/environment.rb"
class Student

  attr_accessor :name, :grade
  attr_reader :id
  
  # Create Student objects
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  # Create students table
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end

  # Drop students table
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  # Save instance data to database; get id of new data
	def save
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

  # Create and save students
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end 

  # Create and return new student from database row
  def self.new_from_db(row)
    new_student = self.new(row[1], row[2], row[0])
    new_student 
  end

  # Find student in database and create new Student object from matching row
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
  end 

  # Update student database entry
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end  
end
