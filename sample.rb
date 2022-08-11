require './eventloop'

evtloop = EventLoop.new

evtloop.task do
  alias :promise :micro_task

  def settimeout_macro_task(name, f = nil)
    settimeout(0) { puts name }

    f && f.call
  end

  def promise_micro_task(name, f=nil) 
    micro_task { puts name }

    f && f.call
  end

  # 测试顺序
  # 环境: ruby 3.1.0p0 (2021-12-25 revision fb4df44d16) [x86_64-darwin21]

  settimeout_macro_task("macro 1", 
    promise_micro_task("macro1-micro1"))
  settimeout_macro_task("macro 2")
  settimeout_macro_task("macro 3")

  # 同步任务 
  puts "第一个出现"

  promise_micro_task("micro 1",
    settimeout_macro_task("micro1-macro1", 
      promise_micro_task("micro1-macro1-micro 1")))
  promise_micro_task("micro 2")
  promise_micro_task("micro 3")
end

evtloop.start

# ruby 3.1.0
# output: 

# 第一个出现
# macro1-micro1
# micro1-macro1-micro 1
# micro 1
# micro 2
# micro 3
# macro 1
# macro 2
# macro 3
# micro1-macro1
