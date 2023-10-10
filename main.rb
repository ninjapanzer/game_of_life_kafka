require 'rdkafka'
require 'fiber'
require 'securerandom'

require_relative 'cell'

CONFIG = {
  :"bootstrap.servers" => "localhost:9092",
  :"group.id" => "ruby-test",
  # :"debug" => "consumer,topic,metadata"
}

SEED = Random.new(1234)

cells = [
  cell_one = Cell.new(pos: [0,0], alive: SEED.rand(2) == 1),
  cell_two = Cell.new(pos: [0,1], alive: SEED.rand(2) == 1),
  cell_three = Cell.new(pos: [0,2], alive: SEED.rand(2) == 1),
  cell_four = Cell.new(pos: [1,0], alive: SEED.rand(2) == 1),
  cell_five = Cell.new(pos: [1,1], alive: SEED.rand(2) == 1),
  cell_six = Cell.new(pos: [1,2], alive: SEED.rand(2) == 1),
  cell_seven = Cell.new(pos: [2,0], alive: SEED.rand(2) == 1),
  cell_eight = Cell.new(pos: [2,1], alive: SEED.rand(2) == 1),
  cell_nine = Cell.new(pos: [2,2], alive: SEED.rand(2) == 1),
  cell_ten = Cell.new(pos: [3,0], alive: SEED.rand(2) == 1),
  cell_eleven = Cell.new(pos: [3,1], alive: SEED.rand(2) == 1),
  cell_twelve = Cell.new(pos: [3,2], alive: SEED.rand(2) == 1),
  cell_thirteen = Cell.new(pos: [4,0], alive: SEED.rand(2) == 1),
  cell_fourteen = Cell.new(pos: [4,1], alive: SEED.rand(2) == 1),
  cell_fifteen = Cell.new(pos: [4,2], alive: SEED.rand(2) == 1),
  cell_sixteen = Cell.new(pos: [5,0], alive: SEED.rand(2) == 1),
  cell_seventeen = Cell.new(pos: [5,1], alive: SEED.rand(2) == 1),
  cell_eighteen = Cell.new(pos: [5,2], alive: SEED.rand(2) == 1),
]

cells.map { |cell| cell.consumer_fiber.resume }

def render(state:)
  puts state.map { |cell| cell == 1 ? 0 : ' ' }.to_a.join(" ")
  ""
end

def clear
  if RUBY_PLATFORM =~ /win32|win64|\.NET/i
    system("cls")
  else
    system("clear")
  end
end
clear
render(state: cells.map {|cell| cell.alive ? 1 : 0})

loop do
  cells.map { |cell| cell.consumer_fiber.resume }
  clear
  render(state: cells.map {|cell| cell.alive ? 1 : 0})
end

at_exit do
  cells.map { |cell| cell.shutdown }
end