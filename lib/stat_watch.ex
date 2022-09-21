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
  def get_most_recent_quali_times do
    with [year, round] <- get_most_recent_race(),
         {:ok, %HTTPoison.Response{status_code: 200, body: response}} <- get_quali_times(round, year),
    do: {:ok, response}, else: (error -> error)
  end

  def format_quali_times({:ok, response}) do
    [year, round] = SweetXml.xpath(response, ~x"//RaceTable/@*"l)
    quali_list = SweetXml.xpath(response, ~x"//QualifyingResult"l)
    parse_data(quali_list)
  end

  defp parse_data(quali_times, map \\ %{})
  defp parse_data([], map), do: map
  defp parse_data([quali_time | rest], map) do
    quali_position = SweetXml.xpath(quali_time, ~x"//QualifyingResult/@position")
    quali_data = SweetXml.xpath(quali_time, ~x"//QualifyingResult",
        first: ~x"./Driver/GivenName/text()",
        last: ~x"./Driver/FamilyName/text()",
        constructor: ~x"./Constructor/Name/text()",
        q1: ~x"./Q1/text()",
        q2: ~x"./Q2/text()"o,
        q3: ~x"./Q3/text()"o)
    map = Map.put_new(map, quali_position, quali_data)
    parse_data(rest, map)
  end

  def get_quali_times(round, year) do
    HTTPoison.get(quali_times_endpoint(round, year))
  end
end
