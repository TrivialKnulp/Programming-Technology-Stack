require_relative "lib/errors"
require_relative "lib/coordinates"
require_relative "lib/ship"
require_relative "lib/board"
require_relative "lib/game"
require_relative "lib/menu"

begin
  Menu.run
rescue Interrupt
  puts "\nДо побачення!"
end
