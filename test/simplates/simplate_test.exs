defmodule Simplates.SimplateTest do
  use ExUnit.Case, async: true

  alias Simplates.Simplate, as: Simplate

  def simple_simplate(contents \\ "Greetings, program!", filepath \\ "index.html.spt") do
    Simplate.create(contents, filepath)
  end

  test "create from file works" do
    assert Simplate.create_from_file("test/simplates/fake-www/index.spt") == simple_simplate("Greetings, program!", "test/simplates/fake-www/index.spt")
  end

  test "create from string works" do
    assert Simplate.create_from_string("Greetings, program!") == simple_simplate("Greetings, program!", nil)
  end

  @basic_simplate """
    
    [---] text/plain
    Greetings, program!
    [---] text/html
    <h1>Greetings, program!</h1>
  """

  test "render is happy not to negotiate" do
    res = Simplate.render(simple_simplate(@basic_simplate, "index.spt"))
    assert res.output == "Greetings, program!"
  end

  test "render sets content_type when it doesnt negotiate" do
    res = Simplate.render(simple_simplate(@basic_simplate, "index.spt"))
    assert  res.content_type == "text/plain"
  end

  test "render is happy not to negotiate with defaults" do
    res = Simplate.render(simple_simplate("[---]\nGreetings, program!\n", "index.spt"))
    assert res.output == "Greetings, program!"
  end

  test "render negotiates" do
    res = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html")
    assert res.output == "<h1>Greetings, program!</h1>"
  end

  test "render ignores busted accept" do
    res = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html;")
    assert res.output == "Greetings, program!"
  end

  test "render sets content_type when it does negotiate" do
    res = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html")
    assert res.content_type == "text/html"
  end

  test "create simplate sets default_content_type when bound simplate" do
    simp = simple_simplate("[---] \n <h1>content</h1>", "index.html.spt")
    assert simp.default_content_type == "text/html"
  end

  test "create simplate sets content_type on template page for bound simplate" do
    simp = simple_simplate("[---] \n example", "index.json.spt")

    assert simp.templates["application/json"]
    assert simp.templates["application/json"].content_type == "application/json"
  end

  test "render bound simplate properly uses simplate.default_content_type" do
    res = Simplate.render(simple_simplate("[---] \n example", "index.json.spt"), "application/json")
    assert res.content_type == "application/json"
  end

end
