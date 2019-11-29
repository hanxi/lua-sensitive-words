local tpack = table.pack
local ucodes = utf8.codes
local uchar = utf8.char
local ucodepoint = utf8.codepoint
local sformat = string.format
local tconcat = table.concat

local _M = {}

-- 分词处理
local function text_split(text)
    text = text:lower():gsub("[-_',.]", " "):gsub("(%w)(%W)", "%1 %2"):gsub("(%W)(%w)", "%1 %2")
    local i = 1
    local t = {" "}
    for k in text:gmatch("%S+") do
        i = i + 1
        t[i] = k
        i = i + 1
        t[i] = " "
    end
    return tconcat(t)
end

-- 屏蔽词汇分词处理
local function word_filter(word)
    word = word:lower():gsub("[-_']", " "):gsub("^%s*(.-)%s*$", "%1")
    if word:find("[^a-z0-9 ]") then
        -- 不是纯字母数字
        return word
    end
    -- 纯字母数字前后加空格
    return sformat(" %s ", word)
end

local function build_dict(words)
    local dict = {}
    local cur_dict
    local sub_dict
    for _,word in pairs(words) do
        word = word_filter(word)
        cur_dict = dict
        for _,c in ucodes(word) do
            sub_dict = cur_dict[c]
            if sub_dict and not next(sub_dict) then
                -- 最短匹配规则
                goto continue
            end
            if sub_dict then
                cur_dict = sub_dict
            else
                sub_dict = {}
                cur_dict[c] = sub_dict
                cur_dict = sub_dict
            end
        end
        -- 只当前最短的串
        for k,_ in pairs(cur_dict) do
            cur_dict[k] = nil
        end
        ::continue::
    end
    return dict
end

function _M:new(words)
    local _dict = build_dict(words)
    return setmetatable({ _dict = _dict }, { __index = self })
end

function _M:dict_dump()
    local dict = self._dict
    local function _dump(d)
        for k,v in pairs(d) do
            io.write(uchar(k))
            if next(v) then
                _dump(v)
            else
                io.write('\n')
            end
        end
    end
    _dump(dict)
end

function _M:check(text)
    text = text_split(text)
    local dict = self._dict
    local arr = tpack(ucodepoint(text, 1, #text))
    local len = #arr
    local flag = false
    for i=1,len do
        local node = nil
        for j=i,len do
            local c = arr[j]
            if node then
                node = node[c]
            else
                node = dict[c]
            end

            if node and not next(node) then
                flag = true
                break
            end

            if not node then
                break
            end
        end
        if flag then
            break
        end
    end
    return flag
end

return _M

