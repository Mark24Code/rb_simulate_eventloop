function macro_task(name, f) {
  setTimeout(() => {
    console.log(name)

    f && f()
  }, 0);
}

function micro_task(name, f) {
  new Promise((resolve)=> {resolve()}).then(() => {
    console.log(name)

    f && f()
  })
}

macro_task(1, macro_task('1a'))
micro_task('m5', macro_task('micro5--macro5'))
micro_task('m6')
micro_task('m7')
macro_task(2,  micro_task('mactro2--micro2'))
macro_task(3,  macro_task('3a'))
macro_task(4,  macro_task('4a'))

// 5
// 6
// 7
// 1
// 2
// 3
// 4