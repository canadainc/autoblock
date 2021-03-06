import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: root
        
        onActionMenuVisualStateChanged: {
            if (actionMenuVisualState == ActionMenuVisualState.VisibleFull)
            {
                tutorial.execOverFlow("searchLogs", qsTr("You can use the '%1' action from the menu to search the logs if a specific message that was blocked."), search );
                tutorial.execOverFlow("clearLogs", qsTr("If this list is getting too cluttered, you can always clear the logs by using the '%1' action from the menu."), clearLogsAction );
                tutorial.execOverFlow("testAction", qsTr("You can test out if your keywords and blocked list is properly set up by using the '%1' action from the menu.\n\nUsing this you can enter a sender's address (or phone number), their name, and a message subject or body to test out how well the app would be able to block such a message given the keywords and addresses you have set up in your database."), testAction );
            }
            
            reporter.record("LogPageMenuOpened", actionMenuVisualState.toString());
        }
        
        actions: [
            SearchActionItem
            {
                id: search
                imageSource: "images/menu/ic_search_logs.png"
                
                onQueryChanged: {
                    helper.fetchAllLogs(listView, query);
                }
                
                onTriggered: {
                    console.log("UserEvent: SearchLogs");
                }
            },
            
            ActionItem
            {
                id: testAction
                imageSource: "images/menu/ic_test.png"
                title: qsTr("Test") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    shortcut.active = true;
                    shortcut.object.testPrompt.reset();
                    shortcut.object.testPrompt.show();
                    
                    console.log("UserEvent: TestAction");
                }
                
                attachedObjects: [
                    Delegate {
                        id: shortcut
                        active: false
                        source: "TestHelper.qml"
                    }
                ]
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
            },
            
            DeleteActionItem
            {
                id: clearLogsAction
                enabled: listView.visible
                title: qsTr("Clear Logs") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_clear_logs.png"
                
                function onFinished(ok)
                {
                    console.log("UserEvent: ClearLogsConfirm", ok);
                    
                    if (ok) {
                        helper.clearLogs(listView);
                        toaster.init( qsTr("Cleared all blocked senders!"), "images/menu/ic_clear_logs.png" );
                        adm.clear();
                    }
                    
                    reporter.record( "ClearLogs", ok.toString() );
                }
                
                onTriggered: {
                    console.log("UserEvent: ClearLogs");
                    persist.showDialog( clearLogsAction, qsTr("Confirmation"), qsTr("Are you sure you want to clear all the logs?") );
                }
            }
        ]
        
        titleBar: AutoBlockTitleBar {}
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: ipd.imagePaint
            layout: DockLayout {}
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/empty/ic_empty_logs.png"
                labelText: qsTr("No spam messages detected yet.") + Retranslate.onLanguageChanged
            }
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: sli
                            title: ListItemData.address
                            imageSource: "images/menu/ic_log.png"
                            description: ListItemData.message.replace(/\n/g, " ").substr(0, 120) + "..."
                            status: offloader.renderStandardTime( new Date(ListItemData.timestamp) )
                            opacity: 0
                            
                            animations: [
                                FadeTransition {
                                    id: slider
                                    fromOpacity: 0
                                    toOpacity: 1
                                    easingCurve: StockCurve.SineOut
                                    duration: 800
                                    delay: sli.ListItem.indexInSection * 100
                                }
                            ]
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    slider.play();
                                }
                            }
                        }
                    }
                ]
                
                onTriggered: {
                    console.log("UserEvent: LogTapped", indexPath);
                    var data = dataModel.data(indexPath);
                    toaster.init( data.message.trim(), "images/tabs/ic_blocked.png", qsTr("The following message was blocked:") );
                    
                    reporter.record("LogTapped");
                }
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllLogs || id == QueryId.ClearLogs)
                    {
                        adm.clear();
                        adm.append(data);
                        
                        navigationPane.parent.unreadContentCount = data.length;
                        
                        if ( id == QueryId.FetchAllLogs && adm.size() > 300 && !persist.containsFlag("dontAskToClear") ) {
                            clearDialog.showing = true;
                        }
                    } else if (id == QueryId.FetchLatestLogs) {
                        adm.insert(0, data);
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        
                        navigationPane.parent.unreadContentCount = navigationPane.parent.unreadContentCount+data.length;
                    } else if (id == QueryId.ClearLogs) {
                        toaster.init( qsTr("Cleared all blocked senders!"), clearLogsAction.imageSource.toString() );
                    }

                    listView.visible = !adm.isEmpty();
                    emptyDelegate.delegateActive = adm.isEmpty();
                }
            }
            
            PermissionToast
            {
                id: tm
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                onCreationCompleted: {
                    var allMessages = [];
                    var allIcons = [];
                    
                    if ( !persist.hasEmailSmsAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to your Email/SMS messages Folder. This permission is needed for the app to access the SMS and email services it needs to do the filtering of the spam messages. If you leave this permission off, some features may not work properly. Select the icon to launch the Application Permissions screen where you can turn these settings on.");
                        allIcons.push("images/toast/no_email_access.png");
                    }
                    
                    if ( !persist.hasSharedFolderAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed for the app to properly allow you to backup & restore the database. If you leave this permission off, some features may not work properly. Select the icon to launch the Application Permissions screen where you can turn these settings on.");
                        allIcons.push("images/toast/no_shared_folder.png");
                    }
                    
                    if ( !persist.hasPhoneControlAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to control your phone. This permission is needed for the app to access the phone service required to be able to block calls based on the incoming number. Select the icon to launch the Application Permissions screen where you can turn these settings on.");
                        allIcons.push("images/toast/no_phone_control.png");
                    }
                    
                    if (allMessages.length > 0)
                    {
                        messages = allMessages;
                        icons = allIcons;
                        delegateActive = true;
                    }
                }
            }
        }
    }
    
    attachedObjects: [
        ImagePaintDefinition
        {
            id: ipd
            imageSource: "images/background.png"
        },
        
        SystemDialog
        {
            id: clearDialog
            property bool showing: false
            body: qsTr("You seem to have a lot of entries here, would you like to clear this list to improve app startup time?") + Retranslate.onLanguageChanged
            title: qsTr("Clear Logs") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
            rememberMeChecked: false
            includeRememberMe: true
            rememberMeText: qsTr("Don't Ask Again") + Retranslate.onLanguageChanged
            
            onShowingChanged: {
                if (showing) {
                    show();
                }
            }
            
            onFinished: {
                showing = false;
                console.log("UserEvent: ClearNoticePrompt", value);
                
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    helper.clearLogs(listView);
                    adm.clear();
                    reporter.record("ClearSuggestion", "Yes");
                } else if ( rememberMeSelection() ) {
                    persist.setFlag("dontAskToClear", 1);
                    reporter.record("ClearSuggestion", "NoDontAskAgain");
                } else {
                    reporter.record("ClearSuggestion", "No");
                }
            }
        },
        
        ComponentDefinition {
            id: definition
        }
    ]
    
    function onRefreshNeeded(type)
    {
        if (type == QueryId.FetchLatestLogs) {
            helper.fetchLatestLogs(listView);
        } else if (type == QueryId.FetchAllLogs || type == QueryId.ClearLogs) {
            helper.fetchAllLogs(listView);
        }
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(root, listView);
        helper.refreshNeeded.connect(onRefreshNeeded);
        tutorial.execCentered("logPane", qsTr("In this tab you will be able to view all the messages that were blocked.") );

        helper.fetchAllLogs(listView);
    }
}