local socket = require("socket")
local utils = require("utils")

-- Routing tables (URL => View Function)
local routes = {
    ["/"] = function() return "views/index.html", { title = "Prima pagină", blog_list = {
        { title = "Prima postare pe blog", description = "Aceasta este prima mea postare pe blog.", link = "/blog/1" },
        { title = "A doua postare pe blog", description = "Acesta este al doilea meu articol.", link = "/blog/2" }
    }} end,
    
    ["/blog/1"] = function() return "views/blog.html", { title = "Prima postare pe blog", content = "Conținutul primului meu articol este aici." } end,
    ["/blog/2"] = function() return "views/blog.html", { title = "A doua postare pe blog", content = "Iată conținutul celui de-al doilea articol al meu." } end
}

-- routing operation that directs the view function according to the URL
local function route_request(path)
    local view = routes[path]
    if view then
        return view()  -- Return template file and data
    else
        return nil, nil  -- for 404 page
    end
end

-- Start the server
local server = socket.bind("localhost", 8081)
local ip, port = server:getsockname()

print("Serverul rulează: http://" .. ip .. ":" .. port)

while true do
    local client = server:accept()
    client:settimeout(10)

    -- Read Request
    local request, err = client:receive()
    if not err then
        local path = request:match("GET (.*) HTTP")
        if path == "/" then path = "/" end  -- Homepage request

        -- Return template and data
        local template_path, context = route_request(path)
        if template_path then
            local content = utils.render_template(template_path, context)
            if content then
                local response = "HTTP/1.1 200 OK\r\n" ..
                                 "Content-Type: text/html\r\n\r\n" ..
                                 content
                client:send(response)
            else
                client:send("HTTP/1.1 500 Internal Server Error\r\n\r\n")
            end
        else
            client:send("HTTP/1.1 404 Not Found\r\n\r\n")
        end
    end
    client:close()
end