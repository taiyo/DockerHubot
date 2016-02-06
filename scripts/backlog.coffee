# Description:
#   Backlog to Slack
#
# Commands:
#   None

module.exports = (robot) ->
  robot.router.post "/room/:room", (req, res) ->
    room = req.params.room
    body = req.body

    console.log 'body type = ' + body.type
    console.log 'room = ' + room

    try
      switch body.type
          when 1
              label = '課題の追加'
          when 2, 3
              # 「更新」と「コメント」は実際は一緒に使うので、一緒に。
              label = '課題の更新'
          else
              # 課題関連以外はスルー
              return

      # 投稿メッセージを整形
      url = "#{process.env.BACKLOG_URL}/view/#{body.project.projectKey}-#{body.content.key_id}"
      if body.content.comment?.id?
          url += "#comment-#{body.content.comment.id}"

      message = "*Backlog #{label}*\n"
      message += "[#{body.project.projectKey}-#{body.content.key_id}] - "
      message += "#{body.content.summary} _by #{body.createdUser.name}_\n>>> "
      if body.content.comment?.content?
          message += "#{body.content.comment.content}\n"
      message += "#{url}"

      console.log 'message = ' + message
      # Slack に投稿
      if message?
        robot.messageRoom room, message
        # robot.messageRoom room, message
        res.end "OK"
      else
          robot.messageRoom room, "Backlog integration error."
          res.end "Error"
    catch error
      console.log error
      robot.send

  robot.respond /backlog\s+(.+)$/i, (msg) ->
    form =
      apiKey: process.env.BACKLOG_API_KEY
      projectId: process.env.BACKLOG_PROJECT_ID
      summary: msg.match[1]
      issueTypeId: 184019
      priorityId: 3

    url = process.env.BACKLOG_URL + "/api/v2/issues"
    robot.http(url)
      .query(form)
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .post() (err, res, body) ->
        if !err
          json = JSON.parse body
          console.log json
          url = process.env.BACKLOG_URL + "/view/" + json.issueKey
          message = "課題を追加しました：" + url
          robot.send message
