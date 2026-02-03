import { test, assert, assert_eq } from 'testing';
import * as examples from 'openwrt_examples';
import * as fs from 'fs';

test("OpenWrt: Filesystem example should write log", function() {
    let result = examples.write_log("Test log entry");
    assert(result, "Log write should succeed");
    
    // Verify file exists
    let content = fs.readfile("/tmp/myapp.log");
    assert(index(content, "Test log entry") >= 0, "Log file should contain message");
});

test("OpenWrt: ubus example should attempt connection", function() {
    try {
        let board = examples.get_system_board();
        // If it succeeds (e.g. running on router), verify structure
        assert(type(board) == "object", "Board info should be an object");
    } catch (e) {
        // If it fails (e.g. CI without ubusd), verify it's the expected error
        // This confirms the code path was entered
        assert(index(e, "Could not connect") >= 0 || index(e, "ubus") >= 0, 
               "Should fail with ubus error in isolated env");
    }
});

test("OpenWrt: UCI example existence", function() {
    // UCI requires config files to be present. In CI, they might not be.
    // We strictly check the function is exported.
    assert(type(examples.toggle_wifi) == "function", "toggle_wifi should be exported");
});
