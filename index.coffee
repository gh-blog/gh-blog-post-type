through2 = require 'through2'

# requires = ['html', 'info', 'embedly', 'images']

regexp =
    video: /youtube.com\/watch\?v=[a-zA-Z0-9-]{10}/gi

filters = [
    {
        type: 'image'
        fn: ($el) ->
            if $el.is 'img'
                return yes#$el.attr 'src'
            if $el.is 'picture'
                # @TODO: srcset... etc.
                return yes#$el.find('img').attr 'src'
            return no
    },
    {
        type: 'video'
        fn: ($el) ->
            switch
                when $el.is 'video'
                    return yes#$el.attr 'src'
                when href = $el.attr 'href' and href.match regexp.video
                    return yes#href
                else no
    },
    {
        type: 'audio'
        fn: ($el) ->
            switch
                when $el.is 'audio'
                    return yes#$el.attr 'src'
                else no
    },
    {
        type: 'link'
        fn: ($el) ->
            $el.is 'a[href]' and
            $el.parent('p').text().trim() is $el.text().trim()
    },
    {
        type: 'text'
        fn: ($el) -> yes
    }
]

module.exports = (options) ->
    processFile = (file, enc, done) ->
        if file.isPost
            { $ } = file
            stats = {
                video: file.videos.length || 0
                image: file.images.length
                audio: file.audios.length || 0
                link: file.links.length || 0
                text: 0
            }

            $root = $.root().filter ':not(.embed)'
            #@TODO: update selector, it won't work with text?
            $root.find('p > *:first-child:last-child').each (i, el) ->
                $el = $ el
                for value, key in filters
                    if value.fn $el
                        stats[value.type] += 1
                        break

            current_type = file.type || 'text'
            max_value = stats.text || 0
            
            for type, value of stats
                if value > max_value
                    current_type = type
                    max_value = value

            file.type = current_type

        done null, file

    through2.obj processFile