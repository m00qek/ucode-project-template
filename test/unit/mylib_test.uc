import { test, assert, assert_eq, assert_throws } from 'testing';

import { sum, get_config } from 'mylib'; 

test("Math: Sum should add numbers", function() {
    assert_eq(sum(2, 2), 4, "2+2 should be 4");
    assert_eq(sum(-1, 1), 0, "Negatives should work");
});

test("Logic: Config should be strictly checked", function() {
    let cfg = { enabled: true, timeout: 30 };
    assert(cfg.enabled, "Config should be enabled");
});

test("Exceptions: Should handle errors", function() {
    assert_throws(function() {
        // Simulating code that throws
        let x = null;
        print(x.foo); 
    }, "Accessing property of null should throw");
});

/* 
// Examples of failing tests:

test("Math: Should fail intentionally", function() {
    assert_eq(sum(2, 2), 5, "This math is wrong");
});

test("Runtime: This should cause an error", function() {
    let x = null;
    return x.invalid_call();
});
*/

