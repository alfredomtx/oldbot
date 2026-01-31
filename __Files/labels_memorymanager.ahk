
memoryFindClientGUILabel:
    MemoryManager.memoryFindClientGUI()
return


clientListFilterName := MemoryManager.clientName
TibiaClient.createClientsJsonList()

TibiaClient.listTibiaClientsGUI()
return


memoryFindClientGUIGuiEscape:
memoryFindClientGUIGuiClose:
    Gui, memoryFindClientGUI:Destroy
return