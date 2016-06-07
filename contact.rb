require 'csv'

# Represents a person in an address book.
class Contact

  attr_accessor :id, :name, :email, :phones

  def initialize(id, name, email, phones)
    @id = id
    @name = name
    @email = email
    @phones = phones
  end

  # Provides functionality for managing a list of Contacts in a database.
  class << self

    @@file_path = 'contacts.csv'

    # Returns an Array of Contacts loaded from the database.
    def all
      CSV.read(@@file_path).map { |row| Contact.new(row[0].to_i, row[1], row[2], deserialize_phones(row[3])) }
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    def create(name, email, phones)
      raise 'A contact with that email already exists' if all.any? { |contact| contact.email == email }
      contact = Contact.new(next_id, name, email, phones)
      CSV.open(@@file_path, 'a') { |csv| csv << [contact.id, contact.name, contact.email, serialize_phones(contact.phones)] }
      contact
    end

    # Returns the id that should be assigned to the next contact that is created.
    def next_id
      (all.map(&:id).max || 0) + 1
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      all.find { |contact| contact.id == id }
    end

    # Returns an array of contacts who match the given term.
    def search(term)
      all.select { |contact| contact.name.include?(term) || contact.email.include?(term) }
    end

    def serialize_phones(phones)
      (phones || []).map { |phone| "#{phone[:type]}:#{phone[:number]}" }.join(';')
    end

    def deserialize_phones(string)
      (string || '').split(';').map do |substring|
        parts = substring.split(':')
        {
          type: parts[0],
          number: parts[1]
        }
      end
    end

  end

end
