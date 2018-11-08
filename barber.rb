class Queue
  MAX_FREE_CHAIRS = 10

  def initialize
    @mutex = Mutex.new
    @customers = []
    @cv = ConditionVariable.new
  end

  def <<(customer)
    @mutex.synchronize do
      if @customers.size < MAX_FREE_CHAIRS
        puts 'added customer'
        @customers << customer
        @cv.signal
      else
        puts 'no hair cut for me...'
      end
    end
  end

  def shift
    @mutex.synchronize do
      while @customers.empty?
        puts 'no customers, go to sleep'
        @cv.wait(@mutex)
      end

      @customers.shift
    end
  end
end

class Customer
  def initialize
    @hair_cut_duration = rand(10)
  end

  def cut
    sleep(@hair_cut_duration)
  end
end

threads = []
queue = Queue.new

barber_thread = Thread.new do
  while true do
    customer = queue.shift

    if customer
      puts 'start cutting customer'
      customer.cut
      puts 'finish cutting customer'
    end
  end
end

customer_thread = Thread.new do
  while true do
    queue << Customer.new
    sleep(rand(10))
  end
end

threads << customer_thread
threads << barber_thread

threads.each(&:join)
