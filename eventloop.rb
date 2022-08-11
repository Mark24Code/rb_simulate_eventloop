require 'thread'

class EventLoop
  
  attr_accessor :macro_queue, :micro_queue
  def initialize
    @running = true
    
    @macro_queue = Queue.new
    @micro_queue = Queue.new

    @time_thr_queue = Queue.new
  end


  def before_loop_sync_tasks
    # do sth setting
    @first_task.call
  end

  def task(&block)
    # 这里放置第一次同步任务
    # 
    # 外部书写的代码，模拟读取js
    # 提供内部的api
    @first_task = -> () { instance_eval(&block) }
  end

  def after_loop
    puts "[after_loop] eventloop is quit :D"
  end

  def macro_queue_works
    while !@macro_queue.empty?
      job = @macro_queue.shift
      job.call
    end
  end

  def micro_queue_works
    while !@micro_queue.empty?
      job = @micro_queue.shift
      job.call
    end
  end

  def start
    begin
      before_loop_sync_tasks

      while @running

        macro_queue_works

        micro_queue_works

        # avoid CPU 100%
        sleep 0.1
      end
    ensure
      after_loop
    end
  end

  # dsl public api
  # inner api
  def macro_task(&block)
    @macro_queue.push(block)
  end

  def micro_task(&block)
    @micro_queue.push(block)
  end

  def settimeout(time, &block)
    # 模拟定时器线程
    if time == 0
      time = 0.1
    end

    # 这里的线程必须是一个，排队的
    t = Thread.new do
      sleep time
      @micro_queue.push(block)
    end

    ## !!! 这里一定不能阻塞，一旦阻塞就不是单线程模型
    ## 有外循环控制不会结束
    # t.join
  end
end
