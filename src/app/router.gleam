import app/routes/voices
import framework/web.{type RequestHandler}
import wisp

pub fn new() -> RequestHandler {
  fn(req: wisp.Request) -> wisp.Response {
    let segments = wisp.path_segments(req)
    case segments {
      ["voices"] -> voices.create_voice(req)
      ["voices", file] -> voices.show_voice(req, file)
      _ -> wisp.not_found()
    }
  }
}
