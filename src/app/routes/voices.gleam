import app/text_to_speech/azure
import birl
import domain/voice_file
import framework/config
import framework/json_response as response
import gleam/dynamic/decode
import gleam/http
import gleam/result
import simplifile
import wisp

type CreateVoiceRequest {
  CreateVoiceRequest(text: String, speed: String)
}

pub fn create_voice(req: wisp.Request) -> wisp.Response {
  case req.method {
    http.Post -> do_create_voice(req)
    _ -> wisp.method_not_allowed([http.Post])
  }
}

pub fn show_voice(req: wisp.Request, file: String) -> wisp.Response {
  case req.method {
    http.Get -> do_show_voice(file)
    _ -> wisp.method_not_allowed([http.Get])
  }
}

fn do_create_voice(req: wisp.Request) -> wisp.Response {
  let assert Ok(api_key) = config.get("AZURE_SUBSCRIPTION_KEY")

  use json <- wisp.require_json(req)

  let result = {
    use param <- result.try(
      decode.run(json, request_decoder())
      |> result.replace_error(response.UnprocessableEntityError(
        "Failed to decode",
      )),
    )
    synthesize(api_key, param.text, param.speed)
    |> result.map_error(fn(e) {
      response.ServerError("Failed to synthesize: " <> e.message)
    })
  }
  case result {
    Ok(file) -> do_show_voice(file)
    Error(resp) -> response.error_response(resp)
  }
}

fn request_decoder() -> decode.Decoder(CreateVoiceRequest) {
  use text <- decode.field("text", decode.string)
  use speed <- decode.optional_field("speed", "medium", decode.string)

  decode.success(CreateVoiceRequest(text:, speed:))
}

fn do_show_voice(file) -> wisp.Response {
  let file_path = voice_file.storage_path(file)
  let is_file = simplifile.is_file(file_path)
  case is_file {
    Ok(True) -> return_file(file_path)
    _ -> wisp.not_found()
  }
}

fn synthesize(
  api_key: String,
  text: String,
  speed: String,
) -> Result(String, azure.AzureAPiError) {
  let now = birl.utc_now()
  let file_name = voice_file.from_time(now)
  let file_path = voice_file.storage_path(file_name)

  use token <- result.try(azure.authenticate(api_key))
  use content <- result.try(azure.synthesize(token, text, speed))
  use _ <- result.try(azure.save_to_file(content, file_path))

  Ok(file_name)
}

fn return_file(path: String) -> wisp.Response {
  wisp.ok()
  |> wisp.set_header("Content-Type", "audio/mpeg")
  |> wisp.set_body(wisp.File(path))
}
