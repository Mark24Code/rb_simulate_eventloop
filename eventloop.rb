require 'thread'

class EventLoop
  
  def initialize
    @running = true
    
    @macro_queue = []
    @micro_queue = []
  end
  def before_loop_sync_tasks
    # 这里放置第一次同步任务
    @task.call
  end

  def task(&block)
    # 外部书写的代码，模拟读取js
    # 提供内部的api
    instance_eval(&block)
  end

  def macro_task(&block)
    @macro_queue.push(block)
  end

  def micro_task(&block)
    @micro_queue.push(block)
  end


  def after_loop
    puts "[after_loop] eventloop is quit :D"
  end

  def macro_queue_works
    while @macro_queue
      job = @macro_queue.shift
      job.call
    end
  end

  def micro_queue_works
    while @micro_queue
      job = @micro_queue.shift
      job.call
    end
  end

  def start
    begin
      before_loop_sync_tasks

      while @running
        # dosth

        macro_queue_works

        # micro_queue_works
        
      end
    rescue => exception
      # dosth
    ensure
      after_loop
    end
  end
end

evtloop = EventLoop.new

evtloop.task do

  macro_task do
    puts 1
  end

  macro_task do
    puts 2
  end
end

evtloop.start