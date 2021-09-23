class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    #CREATE TABLE
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY, 
                NAME TEXT, 
                BREED TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    ##DROP TABLE
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL

        DB[:conn].execute(sql)
    end

    #SAVE
    def save
        #insert into table
        sql = <<-SQL
            INSERT INTO dogs(name, breed) VALUES(?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        #get the id from the table and assign it to this dog
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
        #return this instance
        self
    end

    #CREATE
    def self.create(name:, breed:)

        dog = Dog.new(name: name, breed: breed)

        dog.save

        dog
    end

    #NEW FROM DB - this will create a dog instance, based on information found in a row
    def self.new_from_db(row)
        # dog = Dog.new
        # dog.id: row[0]
        # dog.name: row[1]
        # dog.breed: row[2]
        # dog
        id = row[0]
        name = row[1]
        breed = row[2]

        Dog.new(id: id, name: name, breed: breed)
    end

    #FIND BY ID
    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |dog|
            Dog.new_from_db(dog)
        end.first
    end

    #FIND OR CREATE BY
    def self.find_or_create_by(name:, breed:)

        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name, breed) #in the solution, it just puts name

        puts "This is the dog ID: #{dog}"

        if dog.empty?
            dog = Dog.create(name: name, breed: breed)
        else
            dog_row = dog[0]
            dog_id = dog_row[0]
            dog_name = dog_row[1]
            dog_breed = dog_row[2]
            dog = Dog.new(id: dog_id, name: dog_name, breed: dog_breed)
        end
        dog
    end

    #FIND BY NAME
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            Dog.new_from_db(row)
        end.first
    end

    #UPDATE
    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    # #JESS CODE
    # def update
    #     sql = <<-SQL
    #         UPDATE dogs
    #         SET name = ?, breed = ?
    #         WHERE id = ?
    #     SQL
    #     DB[:conn].execute(sql, self.name, self.breed, self.id)
    # end
    
    

end
