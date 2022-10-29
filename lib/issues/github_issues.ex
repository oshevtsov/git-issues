defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

  @moduledoc """
  Fetches the list of issues from a GitHub repo.
  """
  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {check_for_error(status_code), Jason.decode!(body)}
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
