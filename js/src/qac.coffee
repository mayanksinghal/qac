class QAC
	logArea = null
	tipHandle = null
	defaultDict = [{
		sendUpdates: false
		url: 'js/words.php?jsoncallback=?'
	}]
	wordTrie = null
	globalInputHandle = null
	
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
		showPrevious: () ->
			startOffset -= 1
			if startOffset < 0
				startOffset = allCandidates.length - 1
			return showTip()
	log = (msg, cls = "info") ->
		if logArea?
			logArea.prepend $("<tr></tr>").addClass(cls).append $("<td></td>").html(msg)
		else
			if console? and console.log?
				console.log cls + ": " + msg

	class WordTrie
		trie = null
		pingList = []

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
		constructor: () ->
			trie = new goog.structs.Trie()
		loadDicts: (dicts) ->
			loadDict dictInfo for dictInfo in dicts
		getCandidates: (prefix) ->
			wordTrie.getKeys prefix

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
		word = getCurrentWord inputArea
		pos = inputArea.caret()
		if word.length == 0
			tipHandle.hide()
			return word
		candidates = wordTrie.getCandidates word
		currentCandidate = tipHandle.show candidates, word.length, inputArea.getCaretPosition(), inputArea.offset()
		if currentCandidate
			renderOnInputArea inputArea, currentCandidate, word.length, pos.start 
		return word

	class GlobalInputHandle
		isActive = false
		
		isTempDisabled = false
		isGlobalDisabled = false
		isToolTipDisabled = false

		qacIcon = null

		isShiftPressed = false
		isOtherModifierPressed = false

		# Helpers
		# Checks if v is in Array l.
		inList = (v, l) ->
				inL = false
				hn = (li) ->
					if v == li
						inL = true
				hn li for li in l
				return inL
		# Returns the word before the caret position
		resetCharRegex = /[~`!@#$%^&*()_\-=+\[\]{};:'"<>,./?\\|\s]/
		getCurrentWord = (inputArea) ->
			position = inputArea.caret().start
			text = inputArea.val().substring 0, position
			resetPos = text.split("").reverse().join("").search resetCharRegex
			if resetPos == -1
				return text
			resetPos = text.length - resetPos
			if resetPos == text.length
				return ""
			return text.substring resetPos

		# Credits: https://github.com/loopj/jquery-tokeninput/blob/master/src/jquery.tokeninput.js
		keys = 
			tab: 9
			space: 32
			backspace: 8
			enter: 13
			escape: 27
			up: 38
			down: 40
			shift: 16
			ctrl: 17
			alt: 18
			window: 91
			other_meta: 93
			yet_another_meta: 224
		
		isKeyCharacters = (keyCode) ->
			return ((keyCode >= 48 && keyCode <= 90) ||     # 0-1a-z
					(keyCode >= 96 && keyCode <= 105))    # numpad 0-9
		isPrintableCharacter = (keyCode) ->
			numbers = if isShiftPressed and (keyCode >= 48 and keyCode <= 57) then false else (keyCode >= 48 and keyCode <= 57)
			return (numbers || (keyCode >= 58 && keyCode <= 90) ||     # 0-1a-z
	                (keyCode >= 96 && keyCode <= 111) ||    # numpad 0-9 + - / * .
	                (keyCode >= 186 && keyCode <= 192) ||   # ; = , - . / ^
	                (keyCode >= 219 && keyCode <= 222))    # ( \ ) '
		isResetCharacters = (keyCode) ->
			return (isShiftPressed and (keyCode >= 48 and keyCode <= 57)) or inList(keyCode, [192, 189, 187, 219, 221, 220, 186, 222, 188, 190, 191, 111, 106, 109, 107, 110, 13, keys.space])
		isSpecialType1 = (keyCode) ->
			return keyCode == keys.backspace or keyCode == keys.space
			
		# Flag handles.
		resetTempDefaults = () ->
			isActive = false
			isTempDisabled = false
			tipHandle.hide()
		tempDisable = () ->
			isActive = false
			isTempDisabled = true
			tipHandle.hide()
			qacIcon.addClass "temp_disabled"
		tempEnable = () ->
			isTempDisabled = false
			qacIcon.removeClass "temp_disabled"
		globalDiable = () ->
			isActive = false
			isGlobalDisabled = true
			qacIcon.addClass "disabled"
			tipHandle.hide()
		globalEnable = () ->
			isGlobalDisabled = false
			qacIcon.removeClass "disabled"

		# Main functions.
		renderIcon = () ->
			qacIcon = $("<div></div>").addClass "qac_icon"
			qacIcon.hover(() ->
				qacIcon.toggleClass "hover"
			)
			qacIcon.click (() ->
				if isGlobalDisabled then globalEnable() else globalDiable()
			)
			$('body').append qacIcon

		renderOnEle = (ele, partToRender, caretPosStart, caretPosEnd) ->
			if !caretPosEnd?
				caretPosEnd = caretPosStart	
			oldVal = ele.val()
			newVal = oldVal.substring(0, caretPosStart) + partToRender + oldVal.substring(caretPosEnd)
			ele.val(newVal).caret({
				start: caretPosStart
				end: partToRender.length + caretPosStart
			})
		doBackSpace = (ele) ->
			caretPos = ele.caret()
			renderOnEle ele, "", (caretPos.start - 1), caretPos.end

		findAndRenderCandidates = (ele) ->
			isActive = true
			currentWord = getCurrentWord ele
			if (currentWord.length > 0) and ((candidates = wordTrie.getCandidates currentWord).length > 0) 
				tipHandle.show candidates, currentWord.length, ele.getCaretPosition(), ele.offset()
				renderOnEle ele, candidates[0].substring(currentWord.length), ele.caret().start, ele.caret().end
			else 
				isActive = false
				tipHandle.hide()
			return currentWord
		showPrevious = (ele) ->
			currentWord = getCurrentWord ele
			currentCandidate = tipHandle.showPrevious()
			if currentCandidate
				caretPos = ele.caret()
				renderOnEle ele, currentCandidate.substring(currentWord.length), caretPos.start, caretPos.end
		showNext = (ele) ->
			currentWord = getCurrentWord ele
			currentCandidate = tipHandle.showNext()
			if currentCandidate
				caretPos = ele.caret()
				renderOnEle ele, currentCandidate.substring(currentWord.length), caretPos.start, caretPos.end
		acceptSuggestion = (ele) ->
			caretPos = ele.caret()
			renderOnEle ele, "", caretPos.end, caretPos.end

		# Event handlers.
		onFocus = (ele, event) ->
			qacIcon.css({
				top: ele.offset().top
				left: ele.offset().left
			})
			qacIcon.fadeIn 200
			# Do more?
		onBlur = (ele, event) ->
			qacIcon.fadeOut 100
			resetTempDefaults()

		isShift = false
		onKeyDown = (ele, event) ->
			if isGlobalDisabled
				return
			else if event.keyCode == keys.shift and !isShift
				isShiftPressed = true
			else if inList(event.keyCode, [keys.ctrl, keys.alt, keys.window, keys.other_meta])
				isOtherModifierPressed = true
				tempDisable()
			# Press BACKSPACE to remove characters
			else if isActive and event.keyCode == keys.backspace
				# If suggestion, remove suggestion and a character.
				event.preventDefault()
				doBackSpace(ele)
				findAndRenderCandidates ele
			else if isActive and event.keyCode == keys.up
				event.preventDefault()
				showPrevious ele
			else if isActive and event.keyCode == keys.down
				event.preventDefault()
				showNext ele
			else if !isTempDisabled and isActive and (event.keyCode == keys.tab or event.keyCode == keys.enter)
				event.preventDefault()
		onKeyUp = (ele, event) ->
			if event.keyCode == keys.shift
				isShiftPressed = false
			if inList(event.keyCode, [keys.ctrl, keys.alt, keys.window, keys.other_meta])
				isOtherModifierPressed = false
				tempEnable()
			if isOtherModifierPressed
				return
			# Press ESCAPE to disable QAC, first temporarily and then globally. Renable if disabled.
			if event.keyCode == keys.escape
				if isGlobalDisabled
					tempEnable()
					globalEnable()
				else
					if isTempDisabled then globalDiable() else tempDisable()
			if isGlobalDisabled
				return
			# If nothing to remove, re-enable QAC 
			else if event.keyCode == keys.backspace and isTempDisabled and getCurrentWord(ele).length == 0
				tempEnable()
			# For 'key' characters, do autocomplete.
			else if !isTempDisabled and isKeyCharacters(event.keyCode)
				currentWord = findAndRenderCandidates ele
			# For reset characters, do reset of words.
			else if !isTempDisabled and isResetCharacters(event.keyCode)
				# Do something.
				resetTempDefaults()
			else if !isTempDisabled and isActive and (event.keyCode == keys.tab or event.keyCode == keys.enter)
				event.preventDefault()
				acceptSuggestion(ele)
				tempDisable()
			else if isTempDisabled and event.keyCode == keys.space
				tempEnable()

		constructor: () ->
			renderIcon()
		# Attach New Element.
		addElement: (eleSelector) ->
			ele = $(eleSelector)
			ele.bind "keyup", (event) ->
				onKeyUp $(this), event
			ele.bind "keydown", (event) ->
				onKeyDown $(this), event
			ele.bind "focus", (event) ->
				onFocus $(this), event
			ele.bind "blur", (event) ->
				onBlur $(this), event
	constructor: (logAreaSel, dictionaries = defaultDict) ->
		if logAreaSel?
			logArea  = $(logAreaSel)
			log "Debugging started"
		wordTrie = new WordTrie()
		wordTrie.loadDicts dictionaries
		tipHandle = new TipHandle()
		globalInputHandle = new GlobalInputHandle()
	listen: (inputAreaSelector) ->
		if inputAreaSelector?
			globalInputHandle.addElement inputAreaSelector
$ ->
	qac = new QAC "div.log table tbody"
	qac.listen "#tryarea"
