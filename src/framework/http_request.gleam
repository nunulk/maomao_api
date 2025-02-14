import framework/config
import gleam/http/request
import gleam/list

pub fn prepend_headers(
  request: request.Request(String),
  headers: List(#(String, String)),
) -> request.Request(String) {
  let assert Ok(app_name) = config.get("APP_NAME")

  request.prepend_header(request, "User-Agent", app_name)
  list.fold(headers, request, fn(request, header) {
    request.prepend_header(request, header.0, header.1)
  })
}
