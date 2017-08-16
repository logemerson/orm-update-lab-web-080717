require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize (name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
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
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    self.new(name, grade).save
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = ?
    SQL
    student = DB[:conn].execute(sql, name).flatten
    new_from_db(student)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (id, name, grade)
        VALUES (?, ?, ?)
      SQL
      DB[:conn].execute(sql, @id, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
  end
end
