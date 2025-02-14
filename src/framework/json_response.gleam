import gleam/string_tree
import wisp

pub type HttpErrorResponse {
  UnprocessableEntityError(message: String)
  ServerError(message: String)
}

pub fn ok(body: String) -> wisp.Response {
  json_response(200, body)
}

pub fn error_response(error: HttpErrorResponse) -> wisp.Response {
  case error {
    UnprocessableEntityError(msg) -> unprocessable_entity_error(msg)
    ServerError(msg) -> server_error(msg)
  }
}

pub fn server_error(body: String) -> wisp.Response {
  json_response(500, body)
}

pub fn unprocessable_entity_error(body: String) -> wisp.Response {
  json_response(422, body)
}

fn json_response(code: Int, body: String) -> wisp.Response {
  string_tree.from_string(body) |> wisp.json_response(code)
}
