class QAC
	inputArea = null
	logArea = null
	tipHandle = null
	defaultDict = [{
		static: true
		url: 'js/words.php?jsoncallback=?'
	}]
	wordTrie = null
	
	class TipHandle
		tipArea = null
		constructor: (eleSel) ->
			tipArea = $("<div></div>").addClass "qac_tip"
			tipArea.insertAfter eleSel 
		show: (words, pos) ->
			tipArea.html "Ab"
			tipArea.fadeIn()


	log = (msg, cls = "info") ->
		if logArea?
			logArea.prepend $("<tr></tr>").addClass(cls).append $("<td></td>").html(msg)
		else
			if console? and console.log?
				console.log cls + ": " + msg

	initWordList = (dictionaries) ->
		loadDict = (dictInfo) ->
			handleStatDict = (response) ->
				wordTrie.add key, 1 for key in response
				log wordTrie.getKeys().length + " words loaded from <code>" + dictInfo.url + "</code>"
			if dictInfo.static
				$.ajax {
					url: dictInfo.url
					dataType: 'json'
					success: handleStatDict
				}
			else
				# Ignore dynamic dictionaries at the moment.
		wordTrie = new goog.structs.Trie()
		loadDict dictInfo for dictInfo in dictionaries
	KeyList = 
		tab: 9
		space: 32

	# Thanks to https://github.com/loopj/jquery-tokeninput/blob/master/src/jquery.tokeninput.js
	isPrintableCharacter = (keyCode) ->
		return ((keyCode >= 48 && keyCode <= 90) ||     # 0-1a-z
                (keyCode >= 96 && keyCode <= 111) ||    # numpad 0-9 + - / * .
                (keyCode >= 186 && keyCode <= 192) ||   # ; = , - . / ^
                (keyCode >= 219 && keyCode <= 222));    # ( \ ) '
	
	getCurrentWord = (position) ->
		text = inputArea.val().substring 0, position + 1
		spacePos = text.lastIndexOf " "
		if spacePos == -1
			return text
		return text.substring spacePos + 1
	initInputHandle = () ->
		inputArea.keyup((e) ->
			# if e.keyCode == KeyList
			# Make sure it is not a selection
			pos = $(this).caret()
			if pos.end != pos.start
				tipHandle.hide()
			else 
				if isPrintableCharacter e.keyCode
					# Find what is the current word.
					word = getCurrentWord pos.start
					console.log word
				else
					# Special Work

		)
	constructor: (inputAreaSelector, logAreaSel, dictionaries = defaultDict) ->
		if !inputAreaSelector?
			log "Unknown inputAreaSelector.", "error"
			return
		if logAreaSel?
			logArea  = $(logAreaSel)
			log "Debugging started"
		inputArea = $(inputAreaSelector)
		initWordList dictionaries
		tipHandle = new TipHandle inputAreaSelector
		initInputHandle()
$ ->
	new QAC "#tryarea", "table.log tbody"