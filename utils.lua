local utils = {}

-- File read function
function utils.read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

-- A simple template engine
function utils.render_template(template_path, context)
    local template = utils.read_file(template_path)
    if not template then return nil end

    -- Replace {{ key }} placeholders with data from context
    for key, value in pairs(context) do
        if type(value) == "string" then
            template = template:gsub("{{%s*" .. key .. "%s*}}", value)
        elseif type(value) == "table" and key == "blog_list" then
            local blog_entries = ""
            for _, blog in ipairs(value) do
                blog_entries = blog_entries .. "<div class='card mt-3'><div class='card-body'>" ..
                               "<h5 class='card-title'>" .. blog.title .. "</h5>" ..
                               "<p class='card-text'>" .. blog.description .. "</p>" ..
                               "<a href='" .. blog.link .. "' class='btn btn-primary'>Read More</a>" ..
                               "</div></div>"
            end
            template = template:gsub("{{%s*blog_list%s*}}", blog_entries)
        end
    end

    return template
end

return utils