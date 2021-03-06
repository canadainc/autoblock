import bb.cascades 1.2
import com.canadainc.data 1.0

ActionItem
{
    id: updateAction
    imageSource: "images/dropdown/ic_sync.png"
    title: qsTr("Sync") + Retranslate.onLanguageChanged
    property variant progress
    signal confirmed()
    
    onConfirmed: {
        definition.source = "ProgressDialog.qml";
        progress = definition.createObject();
        progress.open();
    }
    
    function onFinished(confirm)
    {
        if (confirm)
        {
            persist.setFlag("updateTutorial", 1);
            confirmed();
        } else {
            enabled = true;
        }
        
        reporter.record( "SyncUpdate", confirm.toString() );
    }
    
    onTriggered: {
        console.log("UserEvent: SyncUpdate");
        
        if (reporter.online)
        {
            enabled = false;
            
            if ( !persist.containsFlag("updateTutorial") ) {
                persist.showDialog( updateAction, qsTr("Confirmation"), qsTr("The syncing may consume data. Make sure you are on an appropriate Wi-Fi connection or a good data plan. This action will sync your blocked list with our servers so that you can benefit from and benefit other users to report spammers. Would you like to proceed?") );
            } else {
                confirmed();
            }
        } else {
            toaster.init( qsTr("You seem to be offline. Please connect to a network and try again."), "images/common/ic_offline.png", qsTr("No Network Connection") );
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.BlockSenders) {
            toaster.init( qsTr("Addresses added to blocked list!"), "images/menu/ic_add_spammer.png", qsTr("Success") );
        } else if (id == QueryId.BlockKeywords) {
            toaster.init( qsTr("Keywords added to blocked list!"), "images/list/list_keyword.png", qsTr("Success") );
        }
    }
    
    function onSpammersSelected(toBlock)
    {
        var addresses = [];
        var keywords = [];
        
        for (var i = toBlock.length-1; i >= 0; i--)
        {
            var current = toBlock[i];
            
            if (current.type == "address") {
                addresses.push({'senderAddress': current.value});
            } else if (current.type == "keyword") {
                keywords.push(current.value);
            }
        }
        
        reporter.record( "AddressSelection", addresses.length );
        reporter.record( "KeywordSelection", keywords.length );
        
        if (addresses.length > 0) {
            helper.block(updateAction, addresses);
        }
        
        if (keywords.length > 0) {
            helper.blockKeywords(updateAction, keywords);
        }

        navigationPane.pop();
    }
    
    function onUpdatesAvailable(addresses)
    {
        enabled = true;
        
        if (progress) {
            progress.close();
            progress = undefined;
        }
        
        if (addresses.length > 0)
        {
            var inspectPage = updatePicker.createObject();
            inspectPage.elementsSelected.connect(onSpammersSelected);
            inspectPage.elements = addresses;
            
            navigationPane.push(inspectPage);
        } else {
            toaster.init( qsTr("There are no new known spammers available yet.\nCheck back in a few days."), "images/toast/ic_import.png" );
        }
    }
    
    onCreationCompleted: {
        updater.updatesAvailable.connect(onUpdatesAvailable);
    }
    
    attachedObjects: [
        ComponentDefinition
        {
            id: updatePicker
            
            ElementPickerPage {
                titleText: qsTr("Reported Spammers") + Retranslate.onLanguageChanged
                instructionText: qsTr("Which of the following reported spammers and keywords do you want to add to your blocked list?") + Retranslate.onLanguageChanged
                
                onCreationCompleted: {
                    tutorial.execCentered( "tapSelectReported", qsTr("These are the most popular spammers and keywords reported by our users.\n\nYou can scroll down to see the reported keywords.\n\nSimply tap on the addresses and keywords you would like to use. Make sure you review these entries because otherwise you may end up blocking unwanted messages.") );
                    tutorial.execActionBar("reportedBack", qsTr("To close this page, either swipe to the right or tap on this back button!"), "b" );
                }
            }
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
}