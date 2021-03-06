defmodule Simplates.Specline do
  @moduledoc """
  Sections in a simplate are either "code sections" or "content sections". Content 
  sections may have a "specline" after the `[---]` separator. The format of the specline 
  is `content-type` via `renderer`. The syntax of the content sections depends on the 
  renderer. The logic sections are Elixir.
  """

  import Simplates.Simplate, only: [config: 1]
    
  @specline_full_regex ~r/^(?P<content_type>[a-zA-Z\/]+)\s*via\s*(?P<renderer>\w+)$/
  @specline_content_regex ~r/^[a-zA-Z\/]+$/
  @specline_renderer_regex ~r/via\s*(?P<renderer>\w+)/

  @doc """ 
  Parses a specline like `media/type via EEx` into a tuple {status, renderer, content_type}

  Status can be:
    `:ok` => Specline so we need to trim the first line
    `:ok_missing_renderer` => :ok, but the renderer was missing
    `:ok_missing_content_type` => :ok, but the content_type was missing
    `:empty` => No specline at all, don't trim line
  """
  def parse_specline(line) do 
    cond do
      Regex.match?(@specline_full_regex, line) -> parse_full_specline(line)
      Regex.match?(@specline_content_regex, line) -> parse_content_specline(line)
      Regex.match?(@specline_renderer_regex, line) -> parse_renderer_specline(line) 
      true -> parse_empty_specline()
    end
  end

  def long_renderer(short) do
    Module.concat(["Simplates","Renderers", short <> "Renderer"])
  end

  defp parse_full_specline(line) do
    parsed = Regex.named_captures(@specline_full_regex, line)

    {:ok, long_renderer(Map.get(parsed, "renderer")), Map.get(parsed, "content_type")}
  end

  defp parse_content_specline(line) do
    {:ok_missing_renderer, config(:default_renderer), line}
  end

  defp parse_renderer_specline(line) do
    parsed = Regex.named_captures(@specline_renderer_regex, line)
    {:ok_missing_content_type, long_renderer(Map.get(parsed, "renderer")), config(:default_content_type)}
  end
  
  defp parse_empty_specline do
    {:empty, config(:default_renderer), config(:default_content_type)}
  end

end
