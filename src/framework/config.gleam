import dotenv_gleam
import envoy
import gleam/result

pub fn load() -> Nil {
  dotenv_gleam.config()
}

pub fn get(key: String) -> Result(String, Nil) {
  envoy.get(key)
}

pub fn get_or(key: String, default: String) -> String {
  envoy.get(key) |> result.unwrap(default)
}
