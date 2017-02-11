defmodule Simplates.SimplateTest do
  use ExUnit.Case

  alias Simplates.Simplate, as: Simplate

  def simple_simplate(contents \\ "Greetings, program!", filepath \\ "index.html.spt") do
    Simplate.create(contents, filepath)
  end

  @basic_simplate """
    
    [---] text/plain
    Greetings, program!
    [---] text/html
    <h1>Greetings, program!</h1>
  """

  test "render is happy not to negotiate" do
    output = Simplate.render(simple_simplate(@basic_simplate, "index.spt"))
    assert output.text == "Greetings, program!\n"
  end

  test "render sets content_type when it doesnt negotiate" do
    output = Simplate.render(simple_simplate(@basic_simplate, "index.spt"))
    assert output.content_type == "text/plain"
  end

  test "render is happy not to negotiate with defaults" do
    output = Simplate.render(simple_simplate("[---]\nGreetings, program!\n", "index.spt"))
    assert output.text == "Greetings, program!\n"
  end

  test "render negotiates" do
    output = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html")
    assert output.text == "<h1>Greetings, program!</h1>\n"
  end

  test "render ignores busted accept" do
    output = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html;")
    assert output.text == "Greetings, program!\n"
  end

  test "render sets content_type when it does negotiate" do
    output = Simplate.render(simple_simplate(@basic_simplate, "index.spt"), "text/html")
    assert output.content_type == "text/html"
  end

end
