awaiting_customers = 0
threads = []
customers = []
mutex = Mutex.new
cv = ConditionVariable.new

MAX_FREE_CHAIRS = 10

class Customer
  def initialize
    @hair_cut_duration = rand(10)
  end

  def cut
    sleep(@hair_cut_duration)
  end
end

barber_thread = Thread.new do
  while true do
    customer = nil
    mutex.synchronize do
      if customers.empty?
        cv.wait(mutex)
      end

      if customers.any?
        customer = customers.shift
      else
        puts 'no customers, go to sleep'
      end
    end

    if customer
      puts 'start cutting customer'
      customer.cut
      puts 'finish cutting customer'
    end
  end
end

customer_thread = Thread.new do
  while true do
    mutex.synchronize do
      if awaiting_customers < MAX_FREE_CHAIRS
        puts 'added customer'
        awaiting_customers += 1
        customers << Customer.new
        cv.signal
      else
        puts 'no hair cut for me...'
      end
    end
    sleep(rand(10))
  end
end

threads << customer_thread
threads << barber_thread

threads.each(&:join)
