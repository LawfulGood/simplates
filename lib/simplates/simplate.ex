defmodule Simplates.Simplate do
  @enforce_keys [:raw, :code, :templates]
  defstruct raw: nil, code: nil, templates: [], filepath: nil

  def create_from_file(fs_path) do
    raw = File.read(fs_path)

    create(raw, fs_path)
  end

  def create_from_string(raw) do
    create(raw, nil)
  end

  def create(raw, fs_path) do
    %Simplates.Simplate{
      raw: raw,
      code: nil,
      templates: [],
      filepath: fs_path
    }
  end

  @doc """
  
  """
  def render(%Simplates.Simplate{} = simplate) do
    render(simplate, config(:default_content_type))
  end
  def render(%Simplates.Simplate{} = simplate, content_type) do
    render(simplate, content_type, {})
  end
  def render(%Simplates.Simplate{} = simplate, content_type, context) do
    %{text: nil, content_type: content_type}
  end

  def config(:default_content_type) do
    Application.get_env(:infuse, :default_content_type) || "text/plain"
  end

  def config(:default_renderer) do
    Application.get_env(:infuse, :default_renderer) || Simplates.Renderers.EExRenderer
  end
end
