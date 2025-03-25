local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {
  s("main", {
    t({ "#include <iostream>", "", "int main() {", "\t" }),
    i(1, "// Your code here"),
    t({ "", "\treturn 0;", "}" }),
  }),
})
