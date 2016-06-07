#!/usr/bin/env ruby

require_relative 'contact'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  # Runs the appropriate command based on the input arguments given. The first element of args
  # should be the name of a command. Subsequent elements represent parameters of the specified
  # command. If the command is not recognized, invokes the help command.
  def run(args)
    case args[0]
    when 'new' then new
    when 'list' then list
    when 'show' then show(args[1].to_i)
    when 'search' then search(args[1])
    else help
    end
  end

  # Displays help information about this application.
  def help
    puts 'Here is a list of available commands:
    new    - Create a new contact
    list   - List all contacts
    show   - Show a contact
    search - Search contacts'
  end

  # Creates a new contact in the contact list from user input via standard in, displaying the new
  # contact's id to the user.
  def new
    print 'Name: '
    name = $stdin.gets.chomp
    print 'Email: '
    email = $stdin.gets.chomp
    phones = []
    while enter_a_phone_number?
      print 'Type: '
      type = $stdin.gets.chomp
      print 'Number: '
      number = $stdin.gets.chomp
      phones << {
        type: type,
        number: number
      }
    end
    contact = Contact.create(name, email, phones)
    puts "Contact #{contact.id} created"
  end

  def enter_a_phone_number?
    print 'Enter a phone number? (yes/no) '
    $stdin.gets.chomp == 'yes'
  end

  # Displays information about all the contacts in the list.
  def list
    contacts_index(Contact.all)
  end

  # Displays information about the contact with the provided id.
  def show(id)
    contact = Contact.find(id)
    puts contact ? full_contact(contact) : "Contact with id #{id} not found"
  end

  # Displays information about contacts that match the search term.
  def search(term)
    contacts_index(Contact.search(term))
  end

  def contacts_index(contacts)
    n_contacts = contacts.length
    contacts.each_slice(5) do |slice|
      n_contacts -= 5
      slice.each { |contact| puts list_contact(contact) }
      if n_contacts > 0
        print 'Press enter to continue: '
        $stdin.gets
      end
    end
    puts "---\n#{contacts.length} #{contacts.length == 1 ? 'record' : 'records'} total"
  end

  def list_contact(contact)
    "#{contact.id}: #{contact.name} (#{contact.email})"
  end

  def full_contact(contact)
    "ID: #{contact.id}\n" +
    "Name: #{contact.name}\n" +
    "Email: #{contact.email}\n" +
    "Phones: \n" +
    contact.phones.map { |phone| "    Type: #{phone[:type]}\n    Number: #{phone[:number]}\n" }.join
  end

end

if $0 == __FILE__
  ContactList.new.run(ARGV)
end
