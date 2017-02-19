defmodule Simplates.PaginationTest do
  use ExUnit.Case, async: true

  alias Simplates.Pagination, as: Pagination
  
  test "single page adds one code pages" do 
    pages = Pagination.parse_pages("<template>Hello, world! I have no code!</template>")

    assert pages.code.raw == ""
    assert pages.templates[nil].raw == "Hello, world! I have no code!"
  end

  test "two page adds nothing" do
    pages = Pagination.parse_pages("
      <script>some_code = 3</script>
      <template>Hello, world! I have SOME code!</template>")

    assert String.trim(pages.code.raw) == "some_code = 3"
    assert String.trim(pages.templates[nil].raw) == "Hello, world! I have SOME code!"
  end

  test "two page adds nothing with specline" do
    pages = Pagination.parse_pages("
      <script>some_code = 2</script>
      <template type=\"media/type\" via=\"EEx\">
      Hello, world! I have SOME code and a specline!
      </script>")

    assert String.trim(pages.code.raw) == "some_code = 2"
    assert String.trim(pages.templates["media/type"].raw) == "Hello, world! I have SOME code and a specline!"
  end


end
