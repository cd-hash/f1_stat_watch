defmodule StatWatch do
  @moduledoc """
  Documentation for `StatWatch`.
  """

  def quali_times_url(round, year \\ 2021) do
    "http://ergast.com/api/f1/#{year}/#{round}/qualifying"
  end
end
