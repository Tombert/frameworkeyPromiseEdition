module.exports =
        action: () ->
                console.log 'yo'
                return 1
        action2: (item) ->
                console.log "#{item}"
                return {fart: 'yo'}
        makeAPI: (renderingItem) ->

                return {renderType: 'json', data: renderingItem}
                
        makeDOM: (renderingItem) ->
                return {renderType: 'html', data: renderingItem, page: 'testView'}
