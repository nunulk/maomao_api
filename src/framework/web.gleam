import cors_builder as cors
import framework/config
import gleam/http
import gleam/list
import gleam/string
import wisp

pub type RequestHandler =
  fn(wisp.Request) -> wisp.Response

pub fn middleware(
  req: wisp.Request,
  handle_request: RequestHandler,
) -> wisp.Response {
  let req = wisp.method_override(req)

  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- cors.wisp_middleware(req, cors())

  handle_request(req)
}

fn cors() {
  let cors_allowed_origin_urls =
    config.get_or("CORS_ALLOWED_ORIGIN_URLS", "*")
    |> string.split(",")
    |> list.map(string.trim)

  cors.new()
  |> list.fold(cors_allowed_origin_urls, _, fn(acc, url) {
    cors.allow_origin(acc, url)
  })
  |> cors.allow_method(http.Get)
  |> cors.allow_method(http.Post)
}
