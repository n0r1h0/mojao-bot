# Description:
#   slack attachment利用向け。callbackにtsを返却する。
#

m = require('moment')

module.exports = {
    postMessage: (robot, room, attaches, thread_ts, cb) ->
        cb = thread_ts if typeof thread_ts == 'function'

        ts = m().unix()
        attachments = [{ color: '#3cb371',
        mrkdwn_in: ["pretext", "text", "title", "fields", "fallback"] }]
        
        options = { as_user: true, link_names: 1,
        attachments: [Object.assign(attachments[0], attaches[0])], thread_ts: thread_ts }
        
        client = robot.adapter.client
        client.web.chat.postMessage(room, '', options)
        .then (result) ->
            cb result.ts
        .catch (error) ->
            # console.log "error", error
}