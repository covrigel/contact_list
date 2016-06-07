 require_relative 'contact'
 require 'pry'
# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  # TODO: Implement user interaction. This should be the only file where you use `puts` and `gets`.
  puts "new - Create a new contact"
  puts "list - List all contacts"
  puts "show - Show a contact"
  puts "search - Search contacts"

  @input = STDIN.gets.chomp
    input = @input
    if input == "new"
      puts "Type name"
      name = STDIN.gets.chomp
      puts "Type email"
      email = STDIN.gets.chomp
      Contact.create(name, email)
    elsif input == "list"
      puts Contact.all
    elsif input == "show"
      puts "Type ID"
      requested_id = STDIN.gets.chomp
      Contact.find(requested_id)
    elsif input == "search"
      search
    else puts "I do not recognize that command"
    end

end