import birl
import gleam/int
import gleam/string

pub fn from_time(t: birl.Time) -> String {
  format_time(t) <> ".mp3"
}

pub fn storage_path(file_name: String) -> String {
  "./static/uploaded/" <> file_name
}

fn format_time(t: birl.Time) -> String {
  let date = birl.get_day(t)
  let time = birl.get_time_of_day(t)

  int.to_string(date.year)
  <> int.to_string(date.month) |> fill_zero(2)
  <> int.to_string(date.date) |> fill_zero(2)
  <> int.to_string(time.hour) |> fill_zero(2)
  <> int.to_string(time.minute) |> fill_zero(2)
  <> int.to_string(time.second) |> fill_zero(2)
}

fn fill_zero(s: String, n: Int) -> String {
  fill_zero_recursive(s, n, int.max(n - string.length(s), 0))
}

fn fill_zero_recursive(s: String, n: Int, m: Int) -> String {
  case m {
    0 -> s
    _ -> fill_zero_recursive("0" <> s, n, m - 1)
  }
}
