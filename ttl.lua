
module("luci.controller.fixttl.ttl", package.seeall)

function index()
    entry({"admin", "network", "fixttl"}, call("render_page"), _("Fix TTL 65"), 100).leaf = true
end

function is_ttl_enabled()
    local output = luci.sys.exec("nft list chain inet fw4 mangle_postrouting_ttl65 2>/dev/null")
    return output and output:match("ip ttl set 65") ~= nil
end

function render_page()
    local http = require "luci.http"
    local sys = require "luci.sys"
    local tpl = require "luci.template"
    local dispatcher = require "luci.dispatcher"

    local action = http.formvalue("action")
    local log_path = "/tmp/fixttl.log"
    local ttl_file = "/etc/nftables.d/ttl65.nft"
    local log_lines = {}

    local function log(msg)
        table.insert(log_lines, msg)
    end

    if action == "toggle" then
        if is_ttl_enabled() then
            log("Menonaktifkan TTL 65...")
            sys.call("nft delete chain inet fw4 mangle_postrouting_ttl65 2>/dev/null")
            sys.call("nft delete chain inet fw4 mangle_prerouting_ttl65 2>/dev/null")
            local f = io.open(ttl_file, "w")
            if f then
                f:write("## Fix TTL 65 - Aryo Brokolly - Youtube\n")
                f:close()
            end
            sys.call("(sleep 2; /etc/init.d/firewall restart) &")
            log("TTL 65 dinonaktifkan dan firewall direstart.")
        else
            log("Mengaktifkan TTL 65...")
            local f = io.open(ttl_file, "w")
            if f then
                f:write([[
## Fix TTL 65 - Aryo Brokolly (youtube)
chain mangle_postrouting_ttl65 {
    type filter hook postrouting priority 300; policy accept;
    counter ip ttl set 65
}
chain mangle_prerouting_ttl65 {
    type filter hook prerouting priority 300; policy accept;
    counter ip ttl set 65
}
]])
                f:close()
            end
            sys.call("nft -f " .. ttl_file)
            sys.call("(sleep 1; /etc/init.d/firewall restart) &")
            log("TTL 65 diaktifkan dan firewall direstart.")
        end

        -- Simpan log proses ke file
        local flog = io.open(log_path, "w")
        if flog then
            flog:write(table.concat(log_lines, "\n"))
            flog:close()
        end

        -- Redirect dan return biar tidak error
        http.redirect(dispatcher.build_url("admin", "network", "fixttl"))
        return
    end

    -- Ambil isi log
    local status_msg = ""
    local f = io.open(log_path, "r")
    if f then
        status_msg = f:read("*a")
        f:close()
    end

    tpl.render("fixttl/page", {
        status_msg = status_msg,
        ttl_active = is_ttl_enabled()
    })
end
