through2 = require 'through2'

# requires = ['html', 'info', 'embedly']

regexp =
    video: /youtube.com\/watch\?v=[a-zA-Z0-9-]{10}/gi

filters = [
    {
        type: 'images'
        fn: ($el) ->
            if $el.is 'img'
                return $el.attr 'src'
            if $el.is 'picture'
                # @TODO: srcset... etc.
                return $el.find('img').attr 'src'
            return no
    },
    {
        type: 'videos'
        fn: ($el) ->
            switch
                when $el.is 'video'
                    return $el.attr 'src'
                when href = $el.attr 'href' and href.match regexp.video
                    return href
                else no
    },
    {
        type: 'audios'
        fn: ($el) ->
            switch
                when $el.is 'audio'
                    return $el.attr 'src'
                else no
    },
    {
        type: 'links'
        fn: ($el) -> $el.is 'a[href]'
    }
]

module.exports = (options) ->
    processFile = (file, enc, done) ->
        if file.isPost
            { $ } = file

            $root = $.root().filter ':not(.embedded)'
            $root.find('p > :first-child').each (i, el) ->
                $el = $ el
                for value, key in filters
                    url = value.fn $el
                    if url
                        file.stats[value.type].push url
                        break if url

        done null, file

    through2.obj processFile