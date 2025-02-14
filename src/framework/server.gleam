import framework/config
import framework/web
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import wisp
import wisp/wisp_mist

pub fn start(router) {
  wisp.configure_logger()
  let port =
    config.get_or("PORT", "8080")
    |> int.parse()
    |> result.unwrap(8080)
  let app_key = wisp.random_string(64)

  let handler = fn(req) {
    use req <- web.middleware(req)
    router(req)
  }

  let assert Ok(_) =
    wisp_mist.handler(handler, app_key)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}
