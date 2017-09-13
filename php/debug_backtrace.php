<?php
// function a_test($str)
// {
//     throw new Exception("\nHi: $str");
//     // var_dump(debug_backtrace());
// }

// try {
//     a_test('friend');
// } catch (Exception $e) {
//     var_dump($e->getLine());
//     var_dump((new Exception('hoge'))->getLine());
//     //var_dump(debug_backtrace());
// }

error_reporting(E_ALL | E_STRICT);

function f() {
  $a = $b;
  var_dump(debug_backtrace());
}

//The backtrace generated here will not have file and line defined
call_user_func("f", Array());

//The backtrace generated here will have file and line defined.
f();
