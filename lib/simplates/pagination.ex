defmodule Simplates.Page do
  @enforce_keys [:raw, :compiled, :renderer, :content_type]
  defstruct raw: nil, compiled: nil, renderer: nil, content_type: nil, specline_status: nil
end

defmodule Simplates.Pagination do
  @moduledoc """
  Handles pagination for Simplates
  """

  @page_split_regex ~r/()\[---+\]()/

  @doc """
  Takes the raw input of the simplate and splits it out into Pages. 

  * If there's one page, it's a template
  * If there's two pages, the top is code the bottom is a template'
  """
  def parse_pages(raw) do    
    pages = raw 
      |> split_pages()
      |> fill_blank_pages()

    %{code: hd(pages), templates: templates_by_content_type(tl(pages))}
  end

  defp split_pages(raw) do
    # Split page, keep specline in raw for do_page
    Regex.split(@page_split_regex, raw, on: [1]) |> Enum.map(fn(p) -> 
      do_page(p)
    end)
  end

  defp do_page(raw_page) do
    # Remove [---]
    raw = Regex.replace(@page_split_regex, raw_page, "")
    split = String.split(raw, "\n")
    first_line = String.trim(hd(split))
    {status, renderer, content_type} = Simplates.Specline.parse_specline(first_line)

    # If specline, we need to remove the specline
    page_content = 
      case status do
        :empty -> raw |> String.trim()
        _ -> tl(split) |> Enum.join(" ") |> String.trim()
      end

    %Simplates.Page{
      raw: page_content, 
      # Is this the right place to compile?
      compiled: renderer.compile(page_content), 
      renderer: renderer,
      content_type: content_type,
      specline_status: status
    }
  end

  defp fill_blank_pages(pages) do
    blank = [ %Simplates.Page{raw: "", compiled: nil, renderer: nil, content_type: nil} ] 
    
    case length(pages) do
      1 -> blank ++ pages
      _ -> pages
    end
  end
  
  defp templates_by_content_type(pages) do
    Enum.reduce(pages, %{}, fn page, acc ->
      Map.put(acc, page.content_type, page) 
    end)
  end

end
