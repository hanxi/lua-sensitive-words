local words = {}
for line in io.lines("words.txt") do
    table.insert(words, line)
end

local sensitive_words = require "sensitive_words"
local sensitive_words_obj = sensitive_words:new(words)

sensitive_words_obj:dict_dump()

for text in io.lines("texts.txt") do
    local ret = sensitive_words_obj:check(text)
    print(ret, text)
end

