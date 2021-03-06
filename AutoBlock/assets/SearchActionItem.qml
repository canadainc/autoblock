import bb.cascades 1.0

ActionItem
{
    property variant search
    title: qsTr("Search") + Retranslate.onLanguageChanged
    enabled: listView.visible
    ActionBar.placement: ActionBarPlacement.OnBar
    signal queryChanged(string query);
    
    shortcuts: [
        SystemShortcut {
            type: SystemShortcuts.Search
        }
    ]
    
    onTriggered: {
        console.log("UserEvent: SearchAction");
        
        if (!search) {
            search = searchDelegate.createObject();
            parent.content.add(search);
        }
        
        search.animator.fromY = 1000;
        search.animator.toY = 0;
        search.animator.easingCurve = StockCurve.QuinticOut;
        search.animator.delay = 0;
        search.animator.play();

        tutorial.execCentered( "searchExit", qsTr("Start typing your query to find matches. To dismiss this search bar, simply tap the RETURN key on the keyboard.") );
    }
    
    attachedObjects: [
        ComponentDefinition
        {
            id: searchDelegate
            
            TextField
            {
                id: textField
                property alias animator: tt
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                hintText: qsTr("Enter Query") + Retranslate.onLanguageChanged
                translationY: 750
                opacity: 0.9
                
                onTextChanging: {
                    if (text.length == 0 || text.length > 2) {
                        queryChanged( text.trim() );
                    }
                }
                
                input {
                    submitKey: SubmitKey.Search;
                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoPeriodOff

                    onSubmitted: {
                        textField.loseFocus();
                    }
                }
                
                onFocusedChanged: {
                    if (!focused)
                    {
                        tt.fromY = 0;
                        tt.toY = 1000;
                        tt.easingCurve = StockCurve.QuinticIn
                        tt.delay = 3000;
                        tt.play();
                    } else {
                        tt.stop();
                    }
                }
                
                animations: [
                    TranslateTransition
                    {
                        id: tt
                        duration: 1000
                        
                        onEnded: {
                            if (toY == 0) {
                                textField.requestFocus();
                            } else {
                                queryChanged("");
                            }
                        }
                    }
                ]
            }
        }
    ]
}
