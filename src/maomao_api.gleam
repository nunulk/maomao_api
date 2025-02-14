import app/router
import framework/config
import framework/server

pub fn main() {
  config.load()
  server.start(router.new())
}
