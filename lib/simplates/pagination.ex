defmodule Simplates.Page do
  @enforce_keys [:raw, :compiled, :renderer, :content_type]
  defstruct raw: nil, compiled: nil, renderer: nil, content_type: nil, renderer_found: nil, content_type_found: nil
end

defmodule Simplates.Pagination do
  @moduledoc """
  Handles pagination for Simplates
  """

  import Simplates.Simplate, only: [config: 1]

  def parse_pages(raw) do   
    script = parse_scripts(Floki.find(raw, "script"))
    templates = parse_templates(Floki.find(raw, "template"))

    %{code: script, templates: templates}
  end

  defp parse_scripts(raw_script) when length(raw_script) == 1 do 
    # For now you can only have one script
    {tag_name, attributes, children_nodes} = raw_script |> hd()
    page_content = Floki.raw_html(children_nodes)

    %Simplates.Page{
      raw: page_content, 
      # Is this the right place to compile?
      compiled: Simplates.Renderers.CodeRenderer.compile(page_content), 
      renderer: Simplates.Renderers.CodeRenderer,
      content_type: nil
    }
  end
  defp parse_scripts([]) do
    %Simplates.Page{
      raw: "", 
      compiled: Simplates.Renderers.CodeRenderer.compile(""), 
      renderer: Simplates.Renderers.CodeRenderer,
      content_type: nil
    }
  end

  defp parse_templates(raw_templates) when length(raw_templates) >= 1 do
    Enum.reduce(raw_templates, %{}, fn(html_tree, acc) ->
      template = parse_template(html_tree)
      Map.put(acc, template.content_type, template)
    end)
  end
  defp parse_templates([]) do
    {}
  end

  defp parse_template({tag_name, attributes, children_nodes} = html_tree) do
    page_content = Floki.raw_html(children_nodes) |> String.trim_leading() |> String.trim_trailing()

    {renderer_found, renderer} = attr_or_default(:renderer, Floki.attribute([html_tree], "via"), config(:default_renderer))
    # content type will be fixed in simplates, due to bound simplates
    {content_type_found, content_type} = attr_or_default(:type, Floki.attribute([html_tree], "type"), nil)

    %Simplates.Page{
      raw: page_content, 
      # Is this the right place to compile?
      compiled: renderer.compile(page_content), 
      renderer: renderer,
      renderer_found: renderer_found,
      content_type: content_type,
      content_type_found: content_type_found
    }
  end

  defp attr_or_default(:type, html_tree, default) do
    if html_tree == [] do
      {false, default}
    else 
      {true, hd(html_tree)}
    end
  end

  defp attr_or_default(:renderer, html_tree, default) do
    if html_tree == [] do
      {false, default}
    else 
      {true, long_renderer(hd(html_tree))}
    end
  end

  defp long_renderer(short) do
    Module.concat(["Simplates","Renderers", short <> "Renderer"])
  end

end
