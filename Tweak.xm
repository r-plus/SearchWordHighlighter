@interface BrowserController : NSObject
+ (id)sharedBrowserController;
- (id)activeWebView;
- (id)webView;
@end

static NSMutableString *searchWord = [NSMutableString string];
static NSString *const jsString = @"function uiWebview_HighlightAllOccurencesOfStringForElement(element,keyword){if(element){if(element.nodeType==3){while(true){var value=element.nodeValue;var idx=value.toLowerCase().indexOf(keyword);if(idx<0)break;var span=document.createElement('span');var text=document.createTextNode(value.substr(idx,keyword.length));span.appendChild(text);span.setAttribute('class','uiWebviewHighlight');span.style.backgroundColor='yellow';span.style.color='black';text=document.createTextNode(value.substr(idx+keyword.length));element.deleteData(idx,value.length-idx);var next=element.nextSibling;element.parentNode.insertBefore(span,next);element.parentNode.insertBefore(text,next);element=text}}else if(element.nodeType==1){if(element.style.display!='none'&&element.nodeName.toLowerCase()!='select'){for(var i=element.childNodes.length-1;i>=0;i--){uiWebview_HighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword)}}}}}function uiWebview_HighlightAllOccurencesOfString(keyword){uiWebview_RemoveAllHighlights();uiWebview_HighlightAllOccurencesOfStringForElement(document.body,keyword.toLowerCase())}function uiWebview_RemoveAllHighlightsForElement(element){if(element){if(element.nodeType==1){if(element.getAttribute('class')=='uiWebviewHighlight'){var text=element.removeChild(element.firstChild);element.parentNode.insertBefore(text,element);element.parentNode.removeChild(element);return true}else{var normalize=false;for(var i=element.childNodes.length-1;i>=0;i--){if(uiWebview_RemoveAllHighlightsForElement(element.childNodes[i])){normalize=true}}if(normalize){element.normalize()}}}}return false}function uiWebview_RemoveAllHighlights(){uiWebview_RemoveAllHighlightsForElement(document.body)}";

%hook BrowserController
- (void)_doSearch:(id)search
{
  %orig;
  if (![searchWord isEqualToString:search])
    [searchWord setString:search];
}

- (void)_hideAddressView
{
  %orig;
  if ([searchWord length] == 0)
    return;
  
  // lazy...
  //NSString *searchWord = [[self addressView] searchTextForFindOnThisPage];
  id webView = [[self activeWebView] webView];
  
  [webView stringByEvaluatingJavaScriptFromString:jsString];
  
  NSString *startSearch = [NSString stringWithFormat:@"uiWebview_HighlightAllOccurencesOfString('%@')",searchWord];
  [webView stringByEvaluatingJavaScriptFromString:startSearch];
}
%end
