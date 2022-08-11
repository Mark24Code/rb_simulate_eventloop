function settimeout_macro_task(name, f) {
  setTimeout(() => {
    console.log(name)

    f && f()
  }, 0);
}

function promise_micro_task(name, f) {
  new Promise((resolve)=> {resolve()}).then(() => {
    console.log(name)

    f && f()
  })
}


// 测试顺序
// 环境: node.js  v16.15.0

settimeout_macro_task("macro 1", 
promise_micro_task("macro1-micro1"))
settimeout_macro_task("macro 2")
settimeout_macro_task("macro 3")

console.log("第一个出现")

promise_micro_task("micro 1",
  settimeout_macro_task("micro1-macro1", 
    promise_micro_task("micro1-macro1-micro 1")))
promise_micro_task("micro 2")
promise_micro_task("micro 3")


// node.js  v16.15.0
// output: