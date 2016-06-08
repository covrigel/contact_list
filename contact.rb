require 'pry'
require 'pg'

# Represents a person in an address book.
class Contact

  attr_accessor :id, :name, :email

  def initialize(name, email, id = nil)
    @id = id
    @name = name
    @email = email
  end

  def save
    if id
      # do UPDATE

    else
      result = Contact.connection.exec('INSERT INTO CONTACTS (name, email) VALUES ($1, $2) RETURNING id;', [name, email])
      # self.class.connection.exec('INSERT INTO CONTACTS (name, email) VALUES ($1, $2);')
       @id = result.first["id"].to_i
    end
  end

  # Provides functionality for managing a list of Contacts in a database.
  # ========== CLASS METHODS, OBVIOUSLY ============
  class << self

    def connection
      PG.connect(
        host: 'localhost',
        dbname: 'contacts',
        user: 'development',
        password: 'development'
      )
    end

    # @@file_path = 'contacts.csv'

    # Returns an Array of Contacts loaded from the database.
    def all

      # CSV.read(@@file_path).map { |row| Contact.new(row[0].to_i, row[1], row[2], deserialize_phones(row[3])) }
      contacts = []
      connection.exec('SELECT id, name, email FROM contacts').each do |row|
        # do something with row['id'], row['name'], ..
        contacts << Contact.new(row["name"], row["email"], row["id"])
        # ...
      end
      contacts
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    def create(name, email)
      raise 'A contact with that email already exists' if all.any? { |contact| contact.email == email }
      contact = Contact.new(name, email)
      contact.save
      # CSV.open(@@file_path, 'a') { |csv| csv << [contact.id, contact.name, contact.email, serialize_phones(contact.phones)] }
      contact
    end

    # Returns the id that should be assigned to the next contact that is created.
    def next_id
      # (all.map(&:id).max || 0) + 1
      (all.map { |c| c.id }.max || 0) + 1
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # all.find { |contact| contact.id == id }
      connection.exec('SELECT * FROM contacts WHERE id = $1::int;', [id])[0]
    end

    # Returns an array of contacts who match the given term.
    def search(term)
      # all.select { |contact| contact.name.include?(term) || contact.email.include?(term) }
      result = []
      binding.pry
      connection.exec("SELECT * FROM contacts WHERE name LIKE $1 OR email LIKE $1;", ["%#{term}%"]).each do |row|
        binding.pry 
        result << Contact.new(row["name"], row["email"], row["id"])
      end
      result
    end

  end

end
