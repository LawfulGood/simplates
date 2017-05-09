defmodule Simplates.PaginationTest do
  use ExUnit.Case, async: true

  alias Simplates.Pagination, as: Pagination
  
  test "single page adds one code pages" do 
    pages = Pagination.parse_pages("<template>\nHello, world! I have no code!\n</template>")

    assert pages.code.raw == ""
    assert pages.templates[nil].raw == "Hello, world! I have no code!"
  end

  test "two page adds nothing" do
    pages = Pagination.parse_pages("
<script>
some_code = 3
</script>
<template>
Hello, world! I have SOME code!
</template>")

    assert String.trim(pages.code.raw) == "some_code = 3"
    assert String.trim(pages.templates[nil].raw) == "Hello, world! I have SOME code!"
  end

  test "two page adds nothing with specline" do
    pages = Pagination.parse_pages("
<script>
some_code = 2
</script>
<template type=\"media/type\" via=\"EEx\">
Hello, world! I have SOME code and a specline!
</template>")

    assert String.trim(pages.code.raw) == "some_code = 2"
    assert String.trim(pages.templates["media/type"].raw) == "Hello, world! I have SOME code and a specline!"
  end

  test "parser ignores any non-root level tags" do 
    pages = Pagination.parse_pages(~s(
<template>
    This test ensures anything inside this template tag is ignored entirely by the parser.

    <script>
    food = "bar";
    </script>

    <template>
        I could be a handlebars template or something, who knows :
    </template>
</template>))

    assert map_size(pages.templates) == 1
  end

  test "parser doesn't mess with htmlentities" do
    pages = Pagination.parse_pages(~s(<template>\n&#x3C;h2&#x3E;this is a test&#x3C;/h2&#x3E;\n</template>))

    assert pages.templates[nil].raw  == "&#x3C;h2&#x3E;this is a test&#x3C;/h2&#x3E;"
  end


  test "parser handles two template tags" do 
    pages = Pagination.parse_pages(~s(<template type="text/html">\n</template>\n<template type="text/plain">\n</template>))

    assert map_size(pages.templates) == 2
    assert pages.templates["text/html"]
    assert pages.templates["text/plain"]   
  end

end
