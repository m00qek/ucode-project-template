import * as uci from 'uci';
import * as ubus from 'ubus';
import * as fs from 'fs';

// --- UCI Example ---
export function toggle_wifi() {
    let ctx = uci.cursor();
    
    // Read config
    let wifi_disabled = ctx.get("wireless", "radio0", "disabled");
    
    // Toggle state
    let new_state = (wifi_disabled == "1") ? "0" : "1";
    
    // Write back
    ctx.set("wireless", "radio0", "disabled", new_state);
    ctx.commit("wireless");
    
    return new_state == "1"; // Return true if disabled
};

// --- ubus Example ---
export function get_system_board() {
    let conn = ubus.connect();
    if (!conn) die("Could not connect to ubus");
    
    let board = conn.call("system", "board");
    return board;
};

// --- Filesystem Example ---
export function write_log(msg) {
    let path = "/tmp/myapp.log";
    let f = fs.open(path, "a"); // Append mode
    if (!f) die(`Could not open ${path}`);
    
    f.write(`${time()}: ${msg}\n`);
    f.close();
    
    return true;
};

