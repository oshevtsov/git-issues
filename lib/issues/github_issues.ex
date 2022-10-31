defmodule Issues.GithubIssues do
  require Logger

  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]
  @github_url Application.compile_env!(:issues, :github_url)

  @moduledoc """
  Fetches the list of issues from a GitHub repo.
  """
  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")

    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code = #{status_code}")
    Logger.debug(fn  -> inspect(body) end)
    {check_for_error(status_code), Jason.decode!(body)}
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
