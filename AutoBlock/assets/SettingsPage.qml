import bb.cascades 1.0

Page
{
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            PersistCheckBox
            {
                key: "sound"
                text: qsTr("Sound") + Retranslate.onLanguageChanged
                
                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("A sound will be played every time a spam message is blocked.");
                    } else {
                        infoText.text = qsTr("No sound will be played every time a spam message is blocked.");
                    }
                }
            }
            
            PersistCheckBox
            {
                topMargin: 10
                key: "whitelistContacts"
                text: qsTr("Whitelist All Contacts") + Retranslate.onLanguageChanged
                
                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("Messages from your contacts will never be marked as spam.");
                    } else {
                        infoText.text = qsTr("Messages from your contacts should still be tested for spam keywords/senders.");
                    }
                }
            }
            
            PersistCheckBox
            {
                topMargin: 10
                key: "startAtConversations"
                text: qsTr("Start At Conversations Tab") + Retranslate.onLanguageChanged
                
                onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The app will start at the Conversations tab when it is loaded.");
                    } else {
                        infoText.text = qsTr("The app will start at the Logs tab when it is loaded.");
                    }
                }
            }
            
            Label {
                topMargin: 40
                id: infoText
                multiline: true
                textStyle.fontSize: FontSize.XXSmall
                textStyle.textAlign: TextAlign.Center
                verticalAlignment: VerticalAlignment.Bottom
                horizontalAlignment: HorizontalAlignment.Center
            }
        }
    }
}