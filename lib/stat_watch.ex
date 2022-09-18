defmodule StatWatch do
  import SweetXml
  @moduledoc """
  Documentation for `StatWatch`.
  """

  def column_names do
    Enum.join(~w(Year Round Driver Q1 Q2 Q3), ",")
  end

  def recent_race_endpoint do
    "http://ergast.com/api/f1/current/last/results"
  end

  def quali_times_endpoint(round, year \\ 2021) do
    "http://ergast.com/api/f1/#{year}/#{round}/qualifying"
  end

  def season_schedule_endpoint(year) do
    "http://ergast.com/api/f1/#{year}"
  end

  def get_most_recent_race do
    case HTTPoison.get(recent_race_endpoint()) do
        {:ok, response} -> response.body |> SweetXml.xpath(~x"//RaceTable/@*"l) #[year, round]
        {:error, reason} -> {:error, reason}
    end
  end

# [year, round] = get_most_recent_race()

  def get_quali_times(round, year) do
    HTTPoison.get(quali_times_endpoint(round, year))
  end
end
