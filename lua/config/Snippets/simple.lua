local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- You can combine multiple snippets in one add_snippets call
ls.add_snippets("cpp", {
	-- Main function snippet
	s("main", {
		t({ "#include <iostream>", "",  "int main() {", "\t" }),
		i(1, "// Your code here"),
		t({ "", "\treturn 0;", "}" }),
	}),

	-- Example/Exercise snippet
	s("Exc", {
		t({ "// ------- " }),
		i(1, "num"),
		t({ " -------", "", "" }),
		i(2, "// Code"),
		t({ "", "", "//----------------------" }),
	}),

  -- noobie using namespace std;
  s("ustd", {
		t({ "using namespace std;","" }),
		i(1, ""),

  })
})
