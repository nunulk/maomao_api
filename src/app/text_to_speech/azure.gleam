import framework/http_request
import gleam/bytes_tree
import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/result
import simplifile

pub type AzureAPiError {
  AzureAPiError(message: String)
}

type SynthesisSpeed {
  Medium
  XFast
  Fast
  Slow
  XSlow
}

pub fn authenticate(api_key: String) -> Result(String, AzureAPiError) {
  let url = "https://japaneast.api.cognitive.microsoft.com/sts/v1.0/issueToken"
  let headers = [
    #("Content-Type", "application/x-www-form-urlencoded"),
    #("Content-Length", "0"),
    #("Ocp-Apim-Subscription-Key", api_key),
  ]

  let assert Ok(request) = request.to(url)
  use response <- result.try(
    request
    |> request.set_method(http.Post)
    |> http_request.prepend_headers(headers)
    |> hackney.send
    |> result.replace_error(AzureAPiError("authentication error")),
  )

  Ok(response.body)
}

pub fn synthesize(
  token: String,
  message: String,
  speed: String,
) -> Result(BitArray, AzureAPiError) {
  let url = "https://japaneast.tts.speech.microsoft.com/cognitiveservices/v1"
  let headers = [
    #("Authorization", "Bearer " <> token),
    #("Content-Type", "application/ssml+xml"),
    #("X-Microsoft-OutputFormat", "audio-16khz-32kbitrate-mono-mp3"),
  ]

  use speed <- result.try(synthesis_speed(speed))

  let assert Ok(request) = request.to(url)
  use response <- result.try(
    request
    |> request.set_method(http.Post)
    |> http_request.prepend_headers(headers)
    |> request.set_body(to_xml(message, speed))
    |> request.map(bytes_tree.from_string)
    |> hackney.send_bits
    |> result.replace_error(AzureAPiError("synthesis error")),
  )

  Ok(response.body)
}

pub fn save_to_file(
  data: BitArray,
  path: String,
) -> Result(String, AzureAPiError) {
  use _ <- result.try(
    simplifile.write_bits(to: path, bits: data)
    |> result.replace_error(AzureAPiError("write error: " <> path)),
  )
  Ok(path)
}

fn to_xml(message: String, speed: SynthesisSpeed) -> String {
  "<speak version='1.0' xml:lang='zh-TW'><voice xml:lang='zh-TW' xml:gender='female' name='zh-TW-HsiaoChenNeural'><prosody rate='"
  <> prosody_rate(speed)
  <> "'>"
  <> message
  <> "</prosody></voice></speak>"
}

fn synthesis_speed(value: String) -> Result(SynthesisSpeed, AzureAPiError) {
  case value {
    "medium" -> Ok(Medium)
    "x-fast" -> Ok(XFast)
    "fast" -> Ok(Fast)
    "slow" -> Ok(Slow)
    "x-slow" -> Ok(XSlow)
    _ -> Error(AzureAPiError("invalid request"))
  }
}

fn prosody_rate(speed: SynthesisSpeed) -> String {
  case speed {
    Medium -> "medium"
    XFast -> "x-fast"
    Fast -> "fast"
    Slow -> "slow"
    XSlow -> "x-slow"
  }
}
