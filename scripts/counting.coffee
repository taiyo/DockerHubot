module.exports = (robot) ->
  robot.respond /記念日/i, (msg) ->
    request = msg.http('http://localhost:8080/counting').get()

    request (err, res, body) ->
      json = JSON.parse body
      msg.send json.url
