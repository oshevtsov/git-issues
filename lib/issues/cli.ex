defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and dispatch to the various functions that
  end up generating a table of the last _n_ issues in a GitHub project.
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a GitHub username, project name, and (optionally) the number
  of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  defp args_to_internal_representation([user, project, count]) do
      {user, project, String.to_integer(count)}
  end

  defp args_to_internal_representation([user, project]) do
      {user, project, @default_count}
  end

  defp args_to_internal_representation(_) do
    :help
  end

  @doc """
  Processes the command-line arguments.
  """
  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [ count | #{@default_count} ]
    """)
    System.stop(0)
  end

  def process({user, project, _count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    # The fact that there is error["message"] is a matter of knowing the GitHub API
    IO.puts("Error fetching from GitHub: #{error["message"]}")
    System.stop(2)
  end
end
