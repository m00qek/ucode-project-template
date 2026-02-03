import { test, assert_eq } from 'testing';
import { add, process_object } from 'mymodule';

test("Native: Add should sum numbers using C extension", function() {
    assert_eq(add(10, 20), 30, "10 + 20 should be 30");
    assert_eq(add(-5, 5), 0, "Negative numbers should work");
});

test("Native: process_object should clone and add field", function() {
    let input = { foo: "bar", count: 42 };
    let result = process_object(input);
    
    assert_eq(result.foo, "bar", "Should preserve existing fields");
    assert_eq(result.count, 42, "Should preserve numbers");
    assert_eq(result.processed, true, "Should add 'processed' field");
    // Note: Shallow copy implies input isn't modified by ucv_object_add on the new object
    assert_eq(input.processed, null, "Should not modify original");
});
