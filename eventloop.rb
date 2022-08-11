require 'thread'

class EventLoop
  
  attr_accessor :macro_queue, :micro_queue
  def initialize
    @running = true
    
    @macro_queue = Queue.new
    @micro_queue = Queue.new

    @time_thr_task_queue = Queue.new

    @timer = Timer.new(@time_thr_task_queue, @macro_queue)

    # 计时线程，是一个同步队列
    # 会把定时任务结果塞回宏队列
    @timer_thx = Thread.new do
      @timer.run
    end
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

    # 线程模拟存在问题
    # 抢占的返回顺序不是固定的
    # t = Thread.new do
    #   sleep time
    #   @micro_queue.push(block)
    # end

    ## !!! 这里一定不能阻塞，一旦阻塞就不是单线程模型
    ## 有外循环控制不会结束
    # t.join

    # 用单独线程来运算
    @time_thr_task_queue.push({
      sleep_time: Time.now.to_i + time,
      job: -> () { @micro_queue.push(block) }
    })

  end
end

class Timer
  def initialize(task_queue, macro_queue)
    @task_queue = task_queue
    @macro_queue = macro_queue
  end
  def run
    while (task = @task_queue.shift)
      sleep_time = task[:sleep_time]
      if sleep_time >= Time.now.to_i
        @macro_queue.push(task[:job])
      else
        @task_queue.push(task)
      end
    end
  end
end