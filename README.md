# maomao_api

```
### generate voice
POST http://{{host}}:{{port}}/voices
Content-Type: application/json

{
  "text": "你好",
  "speed": "fast"
}

### get a generated voice
GET http://{{host}}:{{port}}/voices/20250101102030.mp3
```

speed: x-slow, slow, medium, fast, x-fast

## Preparation

This application uses Microsoft Azure Text to speech API.

https://learn.microsoft.com/en-us/azure/ai-services/speech-service/overview

Set environment variables from Azure portal following the below document.

https://learn.microsoft.com/en-us/azure/ai-services/speech-service/get-started-text-to-speech

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
