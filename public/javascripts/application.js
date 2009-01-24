Ajax.Responders.register({
  onCreate: function() {
    if($('load_indicator') && Ajax.activeRequestCount>0)
      Effect.Appear('load_indicator',{duration:0.25,to:0.7,queue:'end'});
  },
  onComplete: function() {
    if($('load_indicator') && Ajax.activeRequestCount==0)
      Effect.Fade('load_indicator',{duration:1,from:0.7,queue:'end'});
  }
});

Ajax.RetroInPlaceEditor = Class.create(Ajax.InPlaceEditor, {
  initialize: function($super, element, url, options) {
    this._extraDefaultOptions = Ajax.RetroInPlaceEditor.DefaultOptions;
    $super(element, url, options);
    this._boundSubmitHandler = this.handleCustomFormSubmission.bind(this);
  },
  handleCustomFormSubmission: function(e) {
    var value = $F(this._controls.editor);
    this.handleFormSubmission(e);
    this.triggerCallback('onSuccess', value);
  },
  getText: function() {
    return new String(this.options.text ? this.options.text : this.element.innerHTML).unescapeHTML();
  }
});

Ajax.RetroInPlaceEditor.DefaultOptions = {
  ajaxOptions: { method: 'put' },
  text: null,
  onSuccess: function(ipe, value) { if (ipe.options.text) ipe.options.text = value; },
  onComplete: null,
  onEnterHover: null,
  onLeaveHover: null,
  externalControlOnly: true,
  clickToEditText: ''
};

function replaceSelection (input, replaceString) {
  var selectionStart = input.selectionStart;
  var selectionEnd = input.selectionEnd;
  var contentBeforeSelection = input.value.substring(0, selectionStart);
  var contentAfterSelection = input.value.substring(selectionEnd);
  var codeRegExp = /[\r\n]+\{{3}[^\}{3}]*$/;
  
  if (codeRegExp.test(contentBeforeSelection)) {
    input.value = contentBeforeSelection + replaceString + contentAfterSelection;    
    if (selectionStart != selectionEnd){ 
      input.focus();
      input.setSelectionRange(selectionStart, selectionStart + replaceString.length);
    } else {
      input.focus();
      input.setSelectionRange(selectionStart + replaceString.length, selectionStart + replaceString.length);
    }
    return true;  
  }
  return false;    
}

function catchTab(item, e){
  if(e.which == 9 && item.setSelectionRange){
    scrollPos = item.scrollTop;
    if (replaceSelection(item, '  ')) {
      setTimeout("$('"+item.id+"').focus();$('"+item.id+"').scrollTop=scrollPos;",0);
      return false;
    }
    return true;    
  }
}