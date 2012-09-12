class QAC
	logArea = null
	tipHandle = null
	defaultDict = [{
		static: true
		sendUpdates: false
		url: 'js/words.php?jsoncallback=?'
	}]
	wordTrie = null
	
	class TipHandle
		tipArea = null
		startOffset = 0
		MaxRenderCount = 10
		allCandidates = null
		highlightLength = 0
		position = null
		offset = null
		showTip = () ->
			attachCandidate = (word) ->
				candidate = $("<span></span>").addClass "outer"
				candidate.html word.substring highlightLength
				candidate.prepend $("<span></span>").addClass("highlight").html(word.substring(0, highlightLength))
				tipArea.find("div.inner").append candidate
			tipArea.find("span").remove()
			renderCount = if MaxRenderCount > allCandidates.length then allCandidates.length else MaxRenderCount
			candidatesToShow = allCandidates.slice(startOffset, startOffset + renderCount)
			if startOffset + renderCount > allCandidates.length
				candidatesToShow.push ele for ele in allCandidates.slice(0, startOffset + renderCount - allCandidates.length)
			if candidatesToShow.length == 0
				return false
			attachCandidate word for word in candidatesToShow
			tipArea.css({
				left: offset.left + position.left,
				top: offset.top + position.top
			})
			tipArea.fadeIn(100)
			return candidatesToShow[0]

		constructor: () ->
			tipArea = $("<div></div>").addClass "qac_tip"
			tipArea.append $("<div></div>").addClass "inner"
			$("body").append tipArea
		hide: ->
			tipArea.fadeOut(50)
		show: (_words, _highlightLength, _pos, _offset) ->
			startOffset = 0
			allCandidates = _words
			highlightLength = _highlightLength
			position = _pos
			offset = _offset
			return showTip()
		showNext: () ->
			startOffset += 1
			if startOffset == allCandidates.length
				startOffset = 0
			return showTip()

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
	# Credits: https://github.com/loopj/jquery-tokeninput/blob/master/src/jquery.tokeninput.js
	keys = 
		tab: 9
		space: 32
		backspace: 8
		enter: 13
		escape: 27
		down: 40
	isPrintableCharacter = (keyCode) ->
		return ((keyCode >= 48 && keyCode <= 90) ||     # 0-1a-z
                (keyCode >= 96 && keyCode <= 111) ||    # numpad 0-9 + - / * .
                (keyCode >= 186 && keyCode <= 192) ||   # ; = , - . / ^
                (keyCode >= 219 && keyCode <= 222));    # ( \ ) '
	isSpecialType1 = (keyCode) ->
		return keyCode == keys.backspace or keyCode == keys.space
	
	getCurrentWord = (inputArea, position) ->
		text = inputArea.val().substring 0, position + 1
		spacePos = text.lastIndexOf " "
		if spacePos == -1
			return text
		else if spacePos == text.length
			return ""
		return text.substring spacePos + 1
	renderOnInputArea = (inputArea, candidate, wordLength, caretPosStart, caretPosEnd) ->
		partToRender = candidate.substring(wordLength)
		oldVal = inputArea.val()
		if !caretPosEnd?
			caretPosEnd = caretPosStart	
		newVal = oldVal.substring(0, caretPosStart) + partToRender + oldVal.substring(caretPosEnd)
		inputArea.val newVal
		inputArea.caret({
			start: caretPosStart
			end: partToRender.length + caretPosStart
		})

	takeInput = (inputArea) ->
		pos = inputArea.caret()
		word = getCurrentWord inputArea, pos.start
		if word.length == 0
			tipHandle.hide()
			return word
		candidates = wordTrie.getKeys word
		currentCandidate = tipHandle.show candidates, word.length, inputArea.getCaretPosition(), inputArea.offset()
		if currentCandidate
			renderOnInputArea inputArea, currentCandidate, word.length, pos.start 
		return word
	initInputHandle = (inputAreaSelector) ->
		inputArea = $(inputAreaSelector)
		word = null
		isDisabled = false
		disable = (pos) ->
			renderOnInputArea inputArea, "", word.length, pos.start, pos.end
			tipHandle.hide()
		disableToggler = (pos) ->
			isDisabled = !isDisabled
			if isDisabled
				disable(pos)
			else
				word = takeInput inputArea

		inputArea.keydown((e)->
			pos = $(this).caret()
			if (!isDisabled) and (pos.start != pos.end) and (e.keyCode == keys.enter or e.keyCode == keys.tab or e.keyCode == keys.backspace)
				e.preventDefault()
			if (!isDisabled) and (e.keyCode == keys.down)
				e.preventDefault()
		)
		inputArea.keyup((e) ->
			# Make sure it is not a selection
			pos = $(this).caret()
			commonHandles = () ->
				if e.keyCode == keys.escape
					disableToggler(pos)
				else if e.keyCode == keys.backspace
					if isDisabled and getCurrentWord(inputArea).length == 0
						isDisabled = false
					isDisabled = true
					disable(pos)
				else if e.keyCode == keys.down
					e.preventDefault()
					# Change render to next candidate
					newCandidate = tipHandle.showNext()
					if newCandidate?
						renderOnInputArea inputArea, newCandidate, word.length, pos.start, pos.end
			if pos.end != pos.start
				if e.keyCode == keys.enter or e.keyCode == keys.tab
					newPos = pos.end
					if newPos < pos.start
						newPos = pos.start
					inputArea.caret({
						start: newPos + 1
						end: newPos + 1
					})
					e.preventDefault()
				else
					commonHandles()
			else
				if (!isDisabled) and ((isPrintableCharacter e.keyCode) or (isSpecialType1 e.keyCode))
					# Find what is the current word.
					word = takeInput inputArea
				else if e.keyCode == keys.space and isDisabled
					isDisabled = false
				else
					commonHandles() 

		)
	constructor: (logAreaSel, dictionaries = defaultDict) ->
		if logAreaSel?
			logArea  = $(logAreaSel)
			log "Debugging started"
		initWordList dictionaries
		tipHandle = new TipHandle()
	listen: (inputAreaSelector) ->
		if inputAreaSelector?
			initInputHandle inputAreaSelector
$ ->
	qac = new QAC "table.log tbody"
	qac.listen "#tryarea"
