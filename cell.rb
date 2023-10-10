require 'rdkafka'
require 'fiber'

class Cell
  attr_reader :consumer_fiber, :neighborhood, :alive

  def initialize(
    pos:,
    alive: true,
    consumer: Rdkafka::Config.new(CONFIG.merge(:"group.id" => "cell_#{pos}",)).consumer,
    producer: Rdkafka::Config.new(CONFIG).producer
  )
    @neighborhood = new_neighborhood(center: pos)
    @neighbor_positions = @neighborhood.collect { |neighbor| neighbor[:pos]}
    @self_pos = pos
    @alive = alive
    @consumer = consumer
    @producer = producer
    @consumer_fiber = nil

    publish_state
    start_listener
  end

  def publish_state
    @producer.produce(
      topic:   "cell_stream",
      payload: Marshal.dump({
        pos: @self_pos,
        alive?: alive?
      }),
      key:     "Key #{@self_pos.inspect}"
    ).wait
  end

  def shutdown
    @consumer_fiber.kill
    @consumer.close
    @producer.close
  end

  private

  def alive?
    @alive
  end

  def start_listener
    @consumer.subscribe("cell_stream")
    @consumer_fiber = Fiber.new do
      @consumer.each_batch(timeout_ms: 250) do |messages|
        messages.each do |message|
          update_neighborhood(Marshal.load(message.payload))
        end
        recompute_state
        publish_state
        Fiber.yield
      end
    end
  end

  def update_neighborhood(payload)
    event_pos = payload[:pos]
    if @neighbor_positions.include? event_pos
      grid_offset = @self_pos.zip(event_pos).map { |a, b| b - a }
      neighbor_offset = ((grid_offset[0]+1) * 3) + grid_offset[1] + 1
      @neighborhood[neighbor_offset][:alive?] = payload[:alive?]
    end
  end

  def recompute_state
    alive_neighbors = @neighborhood.select { |neighbor| neighbor[:alive?] }.count

    if alive?
      @alive = false if alive_neighbors < 1 || alive_neighbors > 2
    else
      @alive = true if alive_neighbors == 2
    end
  end

  def new_neighborhood(center:)
    neighborhood = Array(9)
    start = 0
    (-1..1).each do |x|
      (-1..1).each do |y|
        neighborhood[start] = {
          pos: [center[0] + x, center[1] + y],
          alive?: start == 4 ? true : false
        }
        start += 1
      end
    end

    neighborhood
  end
end