defmodule GlobalSovereignWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component

  @doc """
  Renders a simple error display.
  """
  attr :id, :string, required: true
  attr :errors, :list, default: []

  def error(assigns) do
    ~H"""
    <div id={@id}>
      <%= for msg <- @errors do %>
        <p><%= msg %></p>
      <% end %>
    </div>
    """
  end
end
