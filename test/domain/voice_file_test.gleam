import birl
import domain/voice_file
import gleam/result
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn from_time_test() {
  birl.parse("2025-01-01+0900")
  |> result.map(voice_file.from_time)
  |> should.equal(Ok("20250101000000.mp3"))

  birl.parse("2025-01-01T01:01:01+0900")
  |> result.map(voice_file.from_time)
  |> should.equal(Ok("20250101010101.mp3"))
}
